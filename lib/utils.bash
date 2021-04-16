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
  list_github_tags
}

is_prerelease() {
  if [[ $version == *-* ]]; then
    return 0
  fi
  return 1
}

is_supported() {
  # Validates the minimum version is 2.15. Previous versions are not supported by this plugin.

  local required_version_major=2
  local required_version_minor=15
  local proposed_version_major=$(echo $version | cut -c1)
  local proposed_version_minor=$(echo $version | cut -d'.' -f 2)

  if [[ "${proposed_version_major}" -lt "${required_version_major}" ]]; then
    return 1
  elif [[ "${proposed_version_major}" -eq "${required_version_major}" ]] && [[ "${proposed_version_minor}" -lt "${required_version_minor}" ]]; then
    return 1
  fi
  return 0
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
  local formatted=$version

  if ! is_supported; then
    echo "This version is not supported. Supported versions: 2.15.x or above."
    exit 1
  fi

  if is_prerelease; then
    formatted=${version//[-]/.}
  fi

  if [ "$install_type" != "version" ]; then
    fail "asdf-aws-nuke supports release and pre-release installs only"
  fi

  local release_file="$install_path/aws-nuke-v${formatted}-${platform}-$ARCH.tar.gz"
  (
    mkdir -p "$install_path/bin"
    download_release "$version" "$release_file"
    tar -xzf "$release_file" -C "$install_path/bin" || fail "Could not extract $release_file"
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
