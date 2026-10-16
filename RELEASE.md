# Releasing the PER kit

For maintainers. Users never need this file. Run every block from the repository root on
a clean checkout of `main`. Nothing here runs until the site's /experiments page is live.

Maintainer tools: `git`, `gh` (signed in as crimson-knight), `zip`/`unzip`, and
`shasum` or `sha256sum` (each block picks whichever exists).

Release identity: GitHub repository `crimson-knight/per-kit`, tag `v0.1.0`, archive
`per-kit-v0.1.0.zip`.

## 1. Regenerate and check SHA256SUMS

SHA256SUMS lists every tracked file except itself. Only plain file names are supported
(letters, digits, `.`, `_`, `-`, `/`, `&`).

```sh
set -eu
if command -v shasum >/dev/null 2>&1; then SHA="shasum -a 256"; else SHA=sha256sum; fi
export LC_ALL=C
test -z "$(git status --porcelain)"                    # clean tree, or stop
if git ls-files | grep -q '[^A-Za-z0-9._/&-]'; then echo "unsupported file name" >&2; exit 1; fi
git ls-files | grep -v '^SHA256SUMS$' | sort | while IFS= read -r f; do
  $SHA "$f"
done > SHA256SUMS
chmod 644 SHA256SUMS
./verify.sh                                            # must end RESULT: PASS
git add SHA256SUMS
git diff --cached --quiet || git commit -m "Regenerate SHA256SUMS"
```

## 2. Tag and build the archive

The README already links the release page for this version
(`https://github.com/crimson-knight/per-kit/releases/tag/v0.1.0`). The SHA256SUMS hash
is published on that page and in the release notes, never inside a tracked file, because
SHA256SUMS covers every tracked file. For a later version, update the version in the
README's release line and in the blocks below, then rerun step 1.

```sh
set -eu
if command -v shasum >/dev/null 2>&1; then SHA="shasum -a 256"; else SHA=sha256sum; fi
VERSION=v0.1.0
./verify.sh
grep -q "releases/tag/$VERSION" README.md
git tag -a "$VERSION" -m "PER kit $VERSION"
COMMIT=$(git rev-parse "$VERSION^{commit}")
git archive --format=zip --prefix=per-kit/ -o "per-kit-$VERSION.zip" "$VERSION"
ZIP_SHA=$($SHA "per-kit-$VERSION.zip" | cut -d' ' -f1)
SUMS_SHA=$($SHA SHA256SUMS | cut -d' ' -f1)
echo "commit $COMMIT"; echo "zip $ZIP_SHA"; echo "sums $SUMS_SHA"
```

## 3. Check the archive as a stranger would

```sh
set -eu
if command -v shasum >/dev/null 2>&1; then SHA="shasum -a 256"; else SHA=sha256sum; fi
VERSION=v0.1.0
T=$(mktemp -d)
unzip -q "per-kit-$VERSION.zip" -d "$T"
(cd "$T/per-kit" && ./verify.sh --strict)              # must end RESULT: PASS
rm -rf "$T"
```

## 4. Publish

```sh
set -eu
if command -v shasum >/dev/null 2>&1; then SHA="shasum -a 256"; else SHA=sha256sum; fi
VERSION=v0.1.0
COMMIT=$(git rev-parse "$VERSION^{commit}")
ZIP_SHA=$($SHA "per-kit-$VERSION.zip" | cut -d' ' -f1)
SUMS_SHA=$($SHA SHA256SUMS | cut -d' ' -f1)
cat > release-notes.md <<NOTES
PER kit $VERSION: a plan, execute, reflect loop for Claude Code and Codex, with four
business tasks that run on sample data in about 10 minutes.

- Commit: \`$COMMIT\`
- per-kit-$VERSION.zip sha256: \`$ZIP_SHA\`
- SHA256SUMS sha256: \`$SUMS_SHA\`

Verify before running anything:

    shasum -a 256 per-kit-$VERSION.zip    # must equal the zip sha256 above
    unzip per-kit-$VERSION.zip && cd per-kit
    shasum -a 256 SHA256SUMS              # must equal the SHA256SUMS sha256 above
    ./verify.sh --strict                  # must end RESULT: PASS

More: https://agentc.consulting/experiments?ref=per-kit
NOTES
gh repo create crimson-knight/per-kit --public --source=. --remote=origin \
  --description "Plan, execute, reflect: a free loop kit for Claude Code and Codex"
git push origin main "$VERSION"
gh release create "$VERSION" "per-kit-$VERSION.zip" SHA256SUMS \
  --title "PER kit $VERSION" --notes-file release-notes.md --verify-tag
rm release-notes.md
```

## 5. After publishing

- Open the release page and confirm the commit, both hashes, and the README release line
  agree.
- Point the "kit" slot on https://agentc.consulting/experiments at the release page.
