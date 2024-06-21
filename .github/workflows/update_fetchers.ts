const REGEX_OWNER = `owner\\s*=\\s*"(.+)"`;
const REGEX_REPO = `repo\\s*=\\s*"(.+)"`;
const REGEX_REV = `rev\\s*=\\s*"(.+)"`;
const REGEX_HASH = `hash\\s*=\\s*"(.+)"`;
const REGEX_URL = `url\\s*=\\s*"(.+)"`;

async function gh<T>(url: string): Promise<T> {
  const headers = new Headers();
  headers.set("Accept", "application/vnd.github.v3+json");
  const response = await fetch(url, { headers });
  return await response.json();
}

async function update_static_site(path: string) {
  console.log(`Updating static site at ${path}`);
  const config = await Deno.readTextFile(path);
  const owner = new RegExp(REGEX_OWNER).exec(config)![1];
  const repo = new RegExp(REGEX_REPO).exec(config)![1];
  const rev = new RegExp(REGEX_REV).exec(config)![1];
  const hash = new RegExp(REGEX_HASH).exec(config)![1];
  console.log(`--> Owner: ${owner}`);
  console.log(`--> Repo: ${repo}`);
  console.log(`--> Rev: ${rev}`);
  console.log(`--> Hash: ${hash}`);

  const commits = await gh<unknown[]>(
    `https://api.github.com/repos/${owner}/${repo}/commits`,
  );
  const latestCommit = commits[0];
  const newRev = latestCommit["sha"];

  if (newRev === rev) {
    console.log("--> No changes detected");
    return;
  }

  console.log(`--> Updating from ${rev} to ${newRev}`);

  const tarball =
    `https://github.com/${owner}/${repo}/archive/${newRev}.tar.gz`;
  const prefetchData = await new Deno.Command("nix-prefetch-url", {
    args: ["--unpack", tarball],
    stdout: "piped",
  }).output();
  const newHash = new TextDecoder().decode(prefetchData.stdout).trim();

  console.log(`--> New hash: ${newHash}`);
  const newConfig = config.replace(rev, newRev).replace(hash, newHash);
  await Deno.writeTextFile(path, newConfig);
}

async function update_modpack() {
  console.log(`Updating modpack`);
  const config = await Deno.readTextFile("./machines/lyra/configuration.nix");
  const modpackVersions =
    config.split("# modpack-version-begin")[1].split(
      "# modpack-version-end",
    )[0];
  const url = new RegExp(REGEX_URL).exec(modpackVersions)![1];
  const hash = new RegExp(REGEX_HASH).exec(modpackVersions)![1];
  const rev = url.split("/").pop()!;

  const commits = await gh<unknown[]>(
    `https://api.github.com/repos/Jamalam360/pack/commits`,
  );
  const latestCommit = commits[0];
  const newRev = latestCommit["sha"];

  if (newRev === rev) {
    console.log("--> No changes detected");
    return;
  }

  console.log(`--> Updating from ${rev} to ${newRev}`);

  const newUrl = `https://raw.githubusercontent.com/Jamalam360/pack/${newRev}`;
  const nixExpr =
    `:b import ./.github/workflows/fetch_sculk_pack.nix { pkgs = import <nixpkgs> {}; sculk = builtins.getFlake "github:sculk-cli/sculk?dir=nix"; url = "${newUrl}"; }`;
  const nixCmd = new Deno.Command("/bin/sh", {
    args: ["./.github/workflows/fetch_sculk_pack.sh", nixExpr],
    stderr: "piped",
  }).spawn();

  const { stderr } = await nixCmd.output();  
  const newHash = `sha256-${new TextDecoder().decode(stderr)
    .trim()
    .split("sha256-")
    .pop()!
    .trim()}`;

  console.log(`--> New hash: ${newHash}`);
  const newModpackVersions = modpackVersions.replace(hash, newHash).replace(
    url,
    newUrl,
  );
  const newConfig = config.replace(modpackVersions, newModpackVersions);
  await Deno.writeTextFile("./machines/lyra/configuration.nix", newConfig);
}

for (
  const site of [
    "./services/lyra/static/cdn.nix",
    "./services/lyra/static/its-clearing-up.nix",
    "./services/lyra/static/teach-man-fish.nix",
  ]
) {
  await update_static_site(site);
}

await update_modpack();
