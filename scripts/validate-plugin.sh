#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
manifest="$repo_root/.claude-plugin/plugin.json"
skill="$repo_root/skills/zenn-post/SKILL.md"
readme="$repo_root/README.md"

if ! command -v node >/dev/null 2>&1; then
  echo "error: node is required to parse plugin.json" >&2
  exit 1
fi

version="$(
  MANIFEST="$manifest" node <<'NODE'
const fs = require('fs');
const manifestPath = process.env.MANIFEST;
const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
for (const key of ['name', 'version', 'description']) {
  if (!manifest[key]) {
    console.error(`missing required manifest field: ${key}`);
    process.exit(1);
  }
}
if (!/^\d+\.\d+\.\d+$/.test(manifest.version)) {
  console.error(`version must be semver x.y.z: ${manifest.version}`);
  process.exit(1);
}
console.log(manifest.version);
NODE
)"

description="$(
  MANIFEST="$manifest" node <<'NODE'
const fs = require('fs');
const manifest = JSON.parse(fs.readFileSync(process.env.MANIFEST, 'utf8'));
console.log(manifest.description);
NODE
)"

latest_readme_version="$(sed -nE 's/^### v([0-9]+\.[0-9]+\.[0-9]+).*/\1/p' "$readme" | head -n 1)"

if [ -z "$latest_readme_version" ]; then
  echo "error: could not find latest README changelog version" >&2
  exit 1
fi

if [ "$version" != "$latest_readme_version" ]; then
  echo "error: plugin.json version ($version) does not match latest README changelog ($latest_readme_version)" >&2
  exit 1
fi

skill_description="$(sed -nE '1,/^---$/p' "$skill" | sed -nE 's/^description: //p' | head -n 1)"

for term in Zenn Qiita dev.to Hashnode; do
  if [[ "$description" != *"$term"* ]]; then
    echo "error: plugin.json description must mention $term" >&2
    exit 1
  fi

  if [[ "$skill_description" != *"$term"* ]]; then
    echo "error: skill description must mention $term" >&2
    exit 1
  fi
done

echo "Plugin metadata is consistent for v$version."
