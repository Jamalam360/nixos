import argparse
import json
import os
import re
import shlex
import subprocess
import sys
import urllib.error
import urllib.parse
import urllib.request

USER_AGENT = "Jamalam360/nixos"
FABRIC_META = "https://meta.fabricmc.net/v2"
NEOFORGE_MAVEN = "https://maven.neoforged.net"
MODRINTH_API = "https://api.modrinth.com/v2"


def request(url):
    return urllib.request.urlopen(urllib.request.Request(url, headers={"User-Agent": USER_AGENT}))


def get_json(url):
    with request(url) as resp:
        return json.load(resp)


def download(url, dest):
    print(f"  -> {os.path.basename(dest)}")
    tmp = dest + ".part"
    with request(url) as resp, open(tmp, "wb") as f:
        while chunk := resp.read(1 << 16):
            f.write(chunk)
    os.replace(tmp, dest)


def version_key(v):
    return tuple(int(n) for n in re.findall(r"\d+", v))


def java_version(mc):
    parts = version_key(mc)
    if parts[0] != 1:
        return 25
    if parts[:3] < (1, 20, 5):
        return 17
    return 21


def java_cmd(java, args):
    return ["nix", "shell", f"nixpkgs#temurin-bin-{java}", "-c", "java", *args]


def install_fabric(directory, mc, loader_version):
    if loader_version is None:
        loaders = get_json(f"{FABRIC_META}/versions/loader/{mc}")
        if not loaders:
            sys.exit(f"error: Fabric does not support Minecraft {mc}")
        loader_version = next((entry["loader"]["version"] for entry in loaders if entry["loader"]["stable"]), loaders[0]["loader"]["version"])
    installers = get_json(f"{FABRIC_META}/versions/installer")
    installer = next(i["version"] for i in installers if i["stable"])
    print(f"Installing Fabric loader {loader_version} (installer {installer})")
    download(f"{FABRIC_META}/versions/loader/{mc}/{loader_version}/{installer}/server/jar", os.path.join(directory, "server.jar"))
    return ["-Xmx4G", "-jar", "server.jar", "nogui"]


def neoforge_prefix(mc):
    # 1.21.1 -> "21.1.", 1.21 -> "21.0.", 26.1 -> "26.1.0.", 26.1.2 -> "26.1.2."
    parts = mc.split(".")
    if parts[0] == "1":
        parts = parts[1:]
        width = 2
    else:
        width = 3
    parts += ["0"] * (width - len(parts))
    return ".".join(parts) + "."


def install_neoforge(directory, mc, loader_version, java):
    if loader_version is None:
        versions = get_json(f"{NEOFORGE_MAVEN}/api/maven/versions/releases/net/neoforged/neoforge")["versions"]
        prefix = neoforge_prefix(mc)
        matching = [v for v in versions if v.startswith(prefix)]
        if not matching:
            sys.exit(f"error: no NeoForge version found for Minecraft {mc} (prefix {prefix})")
        stable = [v for v in matching if "-" not in v]
        loader_version = max(stable or matching, key=version_key)
    print(f"Installing NeoForge {loader_version}")
    installer = f"neoforge-{loader_version}-installer.jar"
    download(f"{NEOFORGE_MAVEN}/releases/net/neoforged/neoforge/{loader_version}/{installer}", os.path.join(directory, installer))
    subprocess.run(java_cmd(java, ["-jar", installer, "--installServer"]), cwd=directory, check=True)
    for leftover in (installer, installer + ".log", "run.sh", "run.bat"):
        path = os.path.join(directory, leftover)
        if os.path.exists(path):
            os.remove(path)
    return ["@user_jvm_args.txt", f"@libraries/net/neoforged/neoforge/{loader_version}/unix_args.txt", "nogui"]


class ModResolver:
    def __init__(self, mods_dir, loader, mc):
        self.mods_dir = mods_dir
        self.loader = loader
        self.mc = mc
        self.seen = set()

    def install(self, project, required_by=None):
        query = urllib.parse.urlencode({
            "loaders": json.dumps([self.loader]),
            "game_versions": json.dumps([self.mc]),
        })
        try:
            versions = get_json(f"{MODRINTH_API}/project/{urllib.parse.quote(project)}/version?{query}")
        except urllib.error.HTTPError as e:
            if e.code == 404:
                print(f"warning: Modrinth project '{project}' not found", file=sys.stderr)
                return
            raise
        if not versions:
            suffix = f" (required by {required_by})" if required_by else ""
            print(f"warning: '{project}'{suffix} has no {self.loader} version for {self.mc}, skipping", file=sys.stderr)
            return
        version = max(versions, key=lambda v: v["date_published"])
        if version["project_id"] in self.seen:
            return
        self.seen.add(version["project_id"])

        file = next((f for f in version["files"] if f["primary"]), version["files"][0])
        label = f"dependency of {required_by}" if required_by else project
        print(f"Mod {file['filename']} ({label})")
        download(file["url"], os.path.join(self.mods_dir, file["filename"]))

        for dep in version["dependencies"]:
            if dep["dependency_type"] != "required":
                continue
            dep_project = dep.get("project_id")
            if dep_project is None and dep.get("version_id"):
                dep_project = get_json(f"{MODRINTH_API}/version/{dep['version_id']}")["project_id"]
            if dep_project and dep_project not in self.seen:
                self.install(dep_project, required_by=project)


def main():
    sys.stdout.reconfigure(line_buffering=True)
    parser = argparse.ArgumentParser(description="Scaffold a throwaway Fabric or NeoForge test server.")
    parser.add_argument("directory")
    parser.add_argument("--loader", required=True, choices=["fabric", "neoforge"])
    parser.add_argument("--mc", required=True, help="Minecraft version, e.g. 1.21.1")
    parser.add_argument("--mods", default="", help="comma-separated Modrinth slugs")
    parser.add_argument("--loader-version", help="override the loader version")
    args = parser.parse_args()

    directory = os.path.abspath(args.directory)
    mods_dir = os.path.join(directory, "mods")
    os.makedirs(mods_dir, exist_ok=True)
    java = java_version(args.mc)

    if args.loader == "fabric":
        java_args = install_fabric(directory, args.mc, args.loader_version)
    else:
        java_args = install_neoforge(directory, args.mc, args.loader_version, java)

    resolver = ModResolver(mods_dir, args.loader, args.mc)
    for slug in filter(None, (s.strip() for s in args.mods.split(","))):
        resolver.install(slug)

    with open(os.path.join(directory, "eula.txt"), "w") as f:
        f.write("eula=true\n")

    start = os.path.join(directory, "start.sh")
    with open(start, "w") as f:
        f.write("#!/usr/bin/env bash\n")
        f.write('cd "$(dirname "$0")"\n')
        f.write("exec " + shlex.join(java_cmd(java, java_args)) + ' "$@"\n')
    os.chmod(start, 0o755)

    print(f"\nServer ready in {directory} (Java {java}). Run ./start.sh to start it.")


if __name__ == "__main__":
    main()
