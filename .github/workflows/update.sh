#!/usr/bin/env bash

# $1: path to file with fetchFromGitHub derivation
# $2: attribute to find
get_attribute_from_fetch_from_gh() {
	sed -n "/fetchFromGitHub/,/};/s/.*$2 *= *\"\([^\"]*\)\".*/\1/p" "$1"
}

# $1: json
# $2: attribute
get_attribute_from_json() {
	echo "$1" | sed -n "s/.*\"$2\": *\"\([^\"]*\)\".*/\1/p"
}

# $1: path to file with fetchFromGitHub derivation
update_fetch_from_gh() {
	owner=$(get_attribute_from_fetch_from_gh "$1" "owner")
	repo=$(get_attribute_from_fetch_from_gh "$1" "repo")
	rev=$(get_attribute_from_fetch_from_gh "$1" "rev")
	hash=$(get_attribute_from_fetch_from_gh "$1" "hash")
	echo "Checking for updates for $owner/$repo"

	data=$(nix-prefetch-github --json "$owner" "$repo")
	new_rev=$(get_attribute_from_json "$data" "rev")
	new_hash=$(get_attribute_from_json "$data" "hash")

	if [[ $rev == "$new_rev" ]]; then
		echo "    $owner/$repo is already up to date ($rev)"
		return 0
	fi

	sed -i -e "s/$rev/$new_rev/" "$1"
	sed -i -e "s/$hash/$new_hash/" "$1"
	echo "    Updated $owner/$repo from $rev to $new_rev"
}

# $1: path to file with fetchSculkModpack derivation
update_modpack() {
	url=$(sed -n 's/.*url *= *"\([^"]*\)".*/\1/p' "$1")
	hash=$(sed -n 's/.*hash *= *"\([^"]*\)".*/\1/p' "$1")
	owner=$(echo "$url" | cut -d "/" -f 4)
	repo=$(echo "$url" | cut -d "/" -f 5)
	rev=$(echo "$url" | cut -d "/" -f 6)
	echo "Checking for updates for $owner/$repo"

	data=$(nix-prefetch-github --json "$owner" "$repo")
	new_rev=$(get_attribute_from_json "$data" "rev")

	if [[ $rev == "$new_rev" ]]; then
		echo "    $owner/$repo is already up to date ($rev)"
		return 0
	fi

	echo "    Building $owner/$repo"
	sed -i -e "s/$rev/$new_rev/" "$1"
	sed -i -e "s~\"$hash\"~pkgs.lib.fakeHash~" "$1"
	build_output=$(nix build --file "$1" --json --arg pkgs "import <nixpkgs> { overlays = [ (final: prev: { inherit ((builtins.getFlake "github:sculk-cli/sculk?dir=nix").packages.x86_64-linux) sculk; }) ]; }" --arg inputs "{ sculk = builtins.getFlake "github:sculk-cli/sculk?dir=nix"; }" 2>&1)
	new_hash=$(echo "$build_output" | grep "got" | cut -d "-" -f 2)

	if [[ -z $new_hash ]]; then
		sed -i -e "s/$new_rev/$rev/" "$1"
		sed -i -e "s~pkgs.lib.fakeHash~\"$hash\"~" "$1"
		echo "    Failed to build $owner/$repo"
		return 1
	fi

	echo "    Built $owner/$repo"

	sed -i -e "s~pkgs.lib.fakeHash~\"sha256-$new_hash\"~" "$1"
	echo "    Updated $owner/$repo from $rev to $new_rev"
}

mode=$1
file=$2

if [[ $mode == "modpack" ]]; then
	update_modpack "$file"
elif [[ $mode == "github" ]]; then
	update_fetch_from_gh "$file"
fi
