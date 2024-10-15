const REGEX_OWNER = `owner\\s*=\\s*"(.+)"`;
const REGEX_REPO = `repo\\s*=\\s*"(.+)"`;
const REGEX_REV = `rev\\s*=\\s*"(.+)"`;
const REGEX_HASH = `hash\\s*=\\s*"(.+)"`;
const REGEX_URL = `url\\s*=\\s*"(.+)"`;
const GITHUB_TOKEN = Deno.env.get("GITHUB_TOKEN");

async function gh<T>(url: string): Promise<T> {
  const headers = new Headers();
  headers.set("Accept", "application/vnd.github.v3+json");
  headers.set("Authorization", `Bearer ${GITHUB_TOKEN}`);
  const response = await fetch(url, { headers });

  if (!response.ok) {
    throw new Error(`Failed to fetch ${url}: ${response.statusText}`);
  }

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

  // TODO: use nix-prefetch-github instead
  const prefetchData = await new Deno.Command("nix", {
    args: ["store", "prefetch-file", tarball],
    stderr: "piped",
  }).output();
  const newHash = new TextDecoder().decode(prefetchData.stderr).trim().split("sha256-")[1].split("'")[0];

  console.log(`--> New hash: ${newHash}`);
  const newConfig = config.replace(rev, newRev).replace(hash, `sha256-${newHash}`);
  await Deno.writeTextFile(path, newConfig);
}

async function update_modpack(name: string, owner: string, repo: string) {
  console.log(`Updating modpack`);
  const config = await Deno.readTextFile("./machines/lyra/configuration.nix");
  const modpackVersions =
    config.split(`# ${name}-version-begin`)[1].split(
      `# ${name}-version-end`,
    )[0];
  const originalUrl = new RegExp(REGEX_URL).exec(modpackVersions)![1];
  const hash = new RegExp(REGEX_HASH).exec(modpackVersions)![1];
  const rev = originalUrl.split("/").pop()!;

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

  const newUrl = `https://raw.githubusercontent.com/${owner}/${repo}/${newRev}`;
  const nixExpr =
    `:b import ./.github/workflows/fetch_sculk_pack.nix { pkgs = import <nixpkgs> {}; sculk = builtins.getFlake "github:sculk-cli/sculk?dir=nix"; url = "${newUrl}"; }`;
  const nixCmd = new Deno.Command("/bin/sh", {
    args: ["./.github/workflows/fetch_sculk_pack.sh", nixExpr],
    stderr: "piped",
  }).spawn();

  const { stderr } = await nixCmd.output();  
  const output = new TextDecoder().decode(stderr).trim();

  const newHash = `sha256-${output
    .split("sha256-")
    .pop()!
    .trim()}`;

  console.log(`--> New hash: ${newHash}`);
  const newModpackVersions = modpackVersions.replace(hash, newHash).replace(
    originalUrl,
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

await update_modpack("modded-modpack", "Jamalam360", "pack");
await update_modpack("vanilla-modpack", "Jamalam360", "vanilla-server");
