# Releasing

This is the maintainer guide for validating changes and cutting a release
without GitHub-hosted CI. The workflows in `.github/workflows/` still describe
the automated path. When hosted runners are unavailable, follow the local steps
below. The public repo never gets a self-hosted runner, because a fork's pull
request must not be able to run code on a maintainer machine.

## Validate before pushing

```bash
./scripts/validate.sh          # every check in validate.yml (~10 s)
./scripts/validate.sh --quick  # skip the install round-trip
```

It runs the JSON lint, the manifest freshness check, the plugin-layer check,
`doctor.sh`, the hook bench, the install round-trip, and the install-over-other-kit
test. If you add, move, or remove a kit file, run `./scripts/sync-manifest.sh`
first.

To run it on every push, you can install it as a pre-push hook:

```bash
ln -sf ../../scripts/validate.sh .git/hooks/pre-push
```

When a required check cannot report on a PR, paste the `validate: all checks
passed` line into the PR. An admin then merges with the ruleset bypass.

## Cut a release

The version lives in six places, and all of them must match:
`VERSION`, `package.json`, `.claude-plugin/plugin.json`,
`.claude-plugin/marketplace.json` (two fields), and
`.release-please-manifest.json`.

1. **Branch.** Start from an up-to-date `main`. With `OLD`/`NEW` set to the
   current and next version (for example `0.1.7` and `0.1.8`):

   ```bash
   git switch -c release-$NEW
   sed -i.bak "s/$OLD/$NEW/g" VERSION package.json .claude-plugin/plugin.json \
     .claude-plugin/marketplace.json .release-please-manifest.json
   rm -f VERSION.bak package.json.bak .claude-plugin/*.bak .release-please-manifest.json.bak
   git diff   # every hunk must be a version bump, nothing else
   ```

2. **CHANGELOG.** Add a section at the top in the release-please format.
   List `feat` commits under `### Features` and `fix` commits under
   `### Bug Fixes`. Leave out `docs`, `test`, `chore`, and `ci` commits:

   ```markdown
   ## [NEW](https://github.com/tansuasici/claude-research-kit/compare/vOLD...vNEW) (YYYY-MM-DD)

   ### Bug Fixes

   * **scope:** subject ([#PR](https://github.com/tansuasici/claude-research-kit/issues/PR)) ([abc1234](https://github.com/tansuasici/claude-research-kit/commit/<full-sha>))
   ```

   To list the commits since the last tag, run
   `git log --oneline v$OLD..main`.

3. **Validate and open the PR.** Run `./scripts/validate.sh`, then commit as
   `chore(main): release NEW`, push, and open the PR. Merge it as a squash.

4. **Tag and GitHub release.** On the merged `main`, pass the full SHA, because
   the API rejects a short one:

   ```bash
   git switch main && git pull
   gh release create v$NEW --target "$(git rev-parse HEAD)" --title v$NEW \
     --notes-file <(awk "/^## \\[$NEW\\]/{f=1;next} /^## \\[/{f=0} f" CHANGELOG.md)
   ```

5. **npm.** A maintainer logged in as the package owner runs this
   (`npm whoami` shows who you are logged in as):

   ```bash
   npm publish --access public
   npm view @tansuasici/claude-research-kit version   # can lag a few minutes
   ```

6. **Docs site.** The site has its own repo and deploys from its server-side
   runner when its `main` changes. To refresh it for a kit release without a
   web change, trigger its Deploy workflow manually, or run
   `pnpm run deploy` from a local web checkout that sits next to this repo.

The release-please CLI (`npx release-please release-pr` / `github-release`)
can do steps 1, 2, and 4. It needs a GitHub token, though, and the result has
to be checked the same way.
