#!/usr/bin/env bash
# Rewrites the checked-out (filtered) upstream tree into golubets layout and
# naming, and commits the result on top of upstream HEAD.
#
# Merging this commit instead of raw upstream keeps the merge base intact (no
# history rewrite) while removing the noise conflicts caused by our rename:
#   * packages/pigeon -> packages/golubets (git rename detection fails for
#     heavily changed files and leaves stray copies under packages/pigeon).
#   * Pigeon* -> Golubets* identifiers in the sources where the fork renamed
#     them, so new upstream code arrives with our names.
#   * upstream .github is dropped entirely.
#
# Usage: prepare_upstream.sh <upstream-repo-dir>
set -euo pipefail

cd "$1"
pkg=packages/golubets

if [ -d packages/pigeon ]; then
  git mv packages/pigeon "$pkg"
fi
if [ -f "$pkg/lib/pigeon.dart" ]; then
  git mv "$pkg/lib/pigeon.dart" "$pkg/lib/golubets.dart"
fi

# Upstream's GitHub config (release/labeler/dependabot workflows, ...) is not
# ours. Dropping it from both normalized sides means upstream changes there
# never reach us, while our own .github stays as "added by us".
git rm -r -q --ignore-unmatch .github

# Only the files the fork renamed. C++/GObject/Java/ObjC generators and their
# generated symbols intentionally keep pigeon names.
git ls-files -z \
    "$pkg/lib/golubets.dart" \
    "$pkg/lib/src/pigeon_lib.dart" \
    "$pkg/lib/src/pigeon_lib_internal.dart" \
    "$pkg/lib/src/pigeon_cl.dart" \
    "$pkg/lib/src/generator_tools.dart" \
    "$pkg/lib/src/ast.dart" \
    "$pkg/lib/src/dart/*.dart" \
    "$pkg/lib/src/swift/*.dart" \
    "$pkg/lib/src/kotlin/*.dart" \
    "$pkg/test/*.dart" \
    "$pkg/test/**/*.dart" \
    "$pkg/tool/*.dart" \
    "$pkg/tool/**/*.dart" \
    "$pkg/pigeons/*.dart" \
    "$pkg/example/**/pigeons/*.dart" \
    "$pkg/platform_tests/**/*.swift" \
    "$pkg/platform_tests/**/*.kt" |
  # Protect names the fork kept, rename the rest, then restore.
  xargs -0 perl -pi -e '
    s/\bpigeon_lib\b/__KEEP_PL__/g;
    s/\bpigeon_cl\b/__KEEP_PC__/g;
    s/\bpigeons\//__KEEP_PS__/g;
    s/_formalParameterToPigeonParameter/__KEEP_FP__/g;
    s/_writePigeon/__KEEP_WP__/g;
    s/\bmergePigeonMaps\b/mergeMaps/g;
    s/dev\.flutter\.pigeon/dev.bayori.golubets/g;
    s/Pigeon/Golubets/g;
    s/pigeon/golubets/g;
    s/PIGEON/GOLUBETS/g;
    s/__KEEP_PL__/pigeon_lib/g;
    s/__KEEP_PC__/pigeon_cl/g;
    s/__KEEP_PS__/pigeons\//g;
    s/__KEEP_FP__/_formalParameterToPigeonParameter/g;
    s/__KEEP_WP__/_writePigeon/g;
  '

git add -A
git -c user.name="GitHub Actions Bot" \
  -c user.email="github-actions[bot]@users.noreply.github.com" \
  commit -q -m "Rename upstream pigeon to golubets layout" --allow-empty
