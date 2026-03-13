# ✅ Conventional Commits Validator

[![GitHub Marketplace](https://img.shields.io/badge/GitHub%20Marketplace-Conventional%20Commits%20Validator-blue?logo=github)](https://github.com/marketplace/actions/conventional-commits-validator)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A GitHub Action that validates all commit messages in a push or pull request follow the [Conventional Commits](https://www.conventionalcommits.org/) specification — helping teams maintain a clean, machine-readable git history.

## Format

```
type(scope)!: description

feat(auth): add OAuth2 login
fix(api)!: change response format (BREAKING CHANGE)
docs: update contributing guide
```

**Allowed types:** `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`

---

## Usage

### Basic (validate on every push and PR)

```yaml
name: Lint Commits

on:
  push:
  pull_request:

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - uses: qualtio/conventional-commits-validator@v1
```

### With custom scopes and extra types

```yaml
- uses: qualtio/conventional-commits-validator@v1
  with:
    scopes: 'api,frontend,backend,infra,auth'
    extra-types: 'wip,release'
    fail-on-error: 'true'
```

### Only warn (don't fail the pipeline)

```yaml
- uses: qualtio/conventional-commits-validator@v1
  with:
    fail-on-error: 'false'
```

### Use the outputs

```yaml
- id: cc
  uses: qualtio/conventional-commits-validator@v1
  with:
    fail-on-error: 'false'

- name: Comment on PR if invalid
  if: steps.cc.outputs.valid == 'false'
  run: echo "Invalid commits found: ${{ steps.cc.outputs.invalid-commits }}"
```

---

## Inputs

| Input | Description | Required | Default |
|---|---|---|---|
| `token` | GitHub token | No | `github.token` |
| `fail-on-error` | Fail the job if commits are invalid | No | `true` |
| `scopes` | Comma-separated list of allowed scopes | No | *(any)* |
| `extra-types` | Extra allowed commit types | No | *(none)* |

## Outputs

| Output | Description |
|---|---|
| `valid` | `true` if all commits are valid |
| `invalid-commits` | JSON array of invalid commit messages |

---

## Why Conventional Commits?

- 📦 **Automatic changelogs** with tools like `semantic-release` or `conventional-changelog`
- 🔖 **Semantic versioning** driven by commit types (`feat` → minor, `fix` → patch, `!` → major)
- 🤝 **Better team communication** through a structured commit history
- 🤖 **AI-friendly history** — GitHub Copilot and other AI tools understand structured commits better

---

## License

MIT © 2026 Qualtio Soluciones Digitales, SLU
