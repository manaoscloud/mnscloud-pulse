#!/usr/bin/env bash
# Stamps the pubspec.yaml version into lib/src/version/app_build_info.dart, so the web bundle knows
# its own version and can compare it with the build.json of the release that is live.
set -Eeuo pipefail
cd "$(dirname "$0")/.."
file="lib/src/version/app_build_info.dart"
version="$(sed -n 's/^version:[[:space:]]*//p' pubspec.yaml | head -n 1 | tr -d '[:space:]')"
[[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+([-+][0-9A-Za-z.-]+)?$ ]] ||
  { printf '[sync-app-build-info] invalid pubspec version: %s\n' "$version" >&2; exit 1; }
grep -qE '^[[:space:]]*version: "[^"]*",$' "$file" ||
  { printf '[sync-app-build-info] version field not found in %s\n' "$file" >&2; exit 1; }
sed -i -E "s/^([[:space:]]*)version: \"[^\"]*\",$/\1version: \"${version}\",/" "$file"
grep -qF "version: \"${version}\"," "$file" ||
  { printf '[sync-app-build-info] stamping failed\n' >&2; exit 1; }
printf '[sync-app-build-info] %s = %s\n' "$file" "$version"
