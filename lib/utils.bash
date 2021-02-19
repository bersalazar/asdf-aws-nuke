#!/usr/bin/env bash

set -euo pipefail

GH_REPO="https://github.com/rebuy-de/aws-nuke"
ARCH="amd64"

fail() {
  echo -e "asdf-aws-nuke: $*"
  exit 1
}

curl_opts=(-fsSL)

# NOTE: You might want to remove this if aws-nuke is not hosted on GitHub releases.
if [ -n "${GITHUB_API_TOKEN:-}" ]; then
  curl_opts=("${curl_opts[@]}" -H "Authorization: token $GITHUB_API_TOKEN")
fi

sort_versions() {
  sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
    LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

list_github_tags() {
  git ls-remote --tags --refs "$GH_REPO" |
    grep -o 'refs/tags/.*' | cut -d/ -f3- |
    sed 's/^v//' # NOTE: You might want to adapt this sed to remove non-version strings from tags
}

list_all_versions() {
  # TODO: Adapt this. By default we simply list the tag names from GitHub releases.
  # Change this function if aws-nuke has other means of determining installable versions.
  list_github_tags
}

is_prerelease() {
  if [[ $version == *-* ]]; then
    return 0
  fi
  return 1
}

platform="$(uname -s | awk '{print tolower($0)}')"

download_release() {
  local version formatted filename url
  version="$1"
  filename="$2"
  formatted=$version

  if is_prerelease; then
    formatted=${version//[-]/.}
    echo "A pre-release version was specified. Formatted to: $formatted"
  fi

  url="$GH_REPO/releases/download/v${version}/aws-nuke-v${formatted}-${platform}-$ARCH.tar.gz"

  echo "* Downloading aws-nuke release $version..."
  curl "${curl_opts[@]}" -o "$filename" -C - "$url" || fail "Could not download $url"
}

install_version() {
  local install_type="$1"
  local version="$2"
  local install_path="$3"
  local extra_args="--strip-components=1"
  local formatted=$version

  if is_prerelease; then
    extra_args=""
    formatted=${version//[-]/.}
  fi

  if [ "$install_type" != "version" ]; then
    fail "asdf-aws-nuke supports release and pre-release installs only"
  fi

  local release_file="$install_path/aws-nuke-v${formatted}-${platform}-$ARCH.tar.gz"
  (
    if is_prerelease; then
      extra_args=""
    fi

    mkdir -p "$install_path/bin"
    download_release "$version" "$release_file"
    tar -xzf "$release_file" -C "$install_path/bin" $extra_args || fail "Could not extract $release_file"
    mv "$install_path/bin/aws-nuke-v${formatted}-${platform}-$ARCH" "$install_path/bin/aws-nuke"
    chmod +x "$install_path/bin/aws-nuke" || fail "Could not set executable bit on binary"
    rm "$release_file"

    local tool_cmd
    tool_cmd="$(echo "aws-nuke version" | cut -d' ' -f1)"
    test -x "$install_path/bin/$tool_cmd" || fail "Expected $install_path/bin/$tool_cmd to be executable."

    echo "aws-nuke $version installation was successful!"
  ) || (
    rm -rf "$install_path"
    fail "An error ocurred while installing aws-nuke $version."
  )
}
