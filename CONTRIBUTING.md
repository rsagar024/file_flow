# Contributing

## Branching

Work happens on `feat/*` or `fix/*` branches, merged via pull request into `development` or `master`:
- Merging into `development` triggers an automatic dev release (patch version bump with a `-dev` suffix, APKs attached to a GitHub Release).
- Merging into `master` triggers an automatic production release (minor version bump, APKs + AAB attached).

See `.github/workflows/flutter-auto-release-dev.yml` and `flutter-auto-release-master.yml`.

## Commit messages

Follow the `[TAG]: description` convention used throughout the git history, e.g.:
```
[ADD]: implement device management features including logout and device status tracking.
[FIX]: github workflows.
```
Common tags seen so far: `ADD`, `FIX`, `REFACTOR`. Use whichever best describes the change.

## Pull requests

- If your change should appear in the auto-generated release notes, include a `Release Note:` section in the PR body — the release workflows extract this section verbatim.
- Before opening a PR, run:
  ```bash
  flutter analyze
  flutter test
  ```
  There is currently no CI check that runs these automatically on a PR — the GitHub workflows only build and publish releases after a merge — so this is on you to run locally.

## Code conventions

See [`CLAUDE.md`](CLAUDE.md) for the architecture pattern (clean architecture + BLoC + get_it), naming/folder conventions, and known gaps to be aware of before assuming a feature is already wired up. See [`design.md`](design.md) and [`flow.md`](flow.md) for deeper architecture and navigation-flow references.
