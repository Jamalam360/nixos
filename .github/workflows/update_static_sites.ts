const REGEX_OWNER = /owner\s*=\s*"(.+)"/gm;
const REGEX_REPO = /repo\s*=\s*"(.+)"/gm;
const REGEX_REV = /rev\s*=\s*"(.+)"/gm;
const REGEX_HASH = /hash\s*=\s*"(.+)"/gm;

async function gh<T>(url: string): Promise<T> {
  const headers = new Headers();
  headers.set("Accept", "application/vnd.github.v3+json");
  const response = await fetch(url, { headers });
  return await response.json();
}

async function update_static_site(path: string) {
  console.log(`Updating static site at ${path}`);
  const config = await Deno.readTextFile(path);
  const owner = REGEX_OWNER.exec(config)![1];
  const repo = REGEX_REPO.exec(config)![1];
  const rev = REGEX_REV.exec(config)![1];
  const hash = REGEX_HASH.exec(config)![1];
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
  }).output();
  const newHash = new TextDecoder().decode(prefetchData.stdout).trim();

  console.log(`--> New hash: ${newHash}`);
  const newConfig = config.replace(rev, newRev).replace(hash, newHash);
  await Deno.writeTextFile(path, newConfig);
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
