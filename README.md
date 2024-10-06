# ethanhassett.com

[![Release](https://github.com/ehassett/ethanhassett/actions/workflows/release.yml/badge.svg)](https://github.com/ehassett/ethanhassett/actions/workflows/release.yml)

Repo for https://ethanhassett.com

# Contents

- [ethanhassett.com](#ethanhassettcom)
- [Contents](#contents)
- [Contributing](#contributing)
- [Deployment](#deployment)

# Contributing

- Follow [conventional commits v1.0.0](https://www.conventionalcommits.org/en/v1.0.0/) for commits _and_ PR titles.
- For IaC changes, follow [the Terraform best practices](https://www.terraform-best-practices.com) as close as possible.
- Follow [GitHub Flow](https://githubflow.github.io) for branching strategy and PR process.
- Make sure any app code changes also include a version bump, following [Semantic Versioning](https://semver.org).

# Deployment

The deployment process follows [GitHub Flow](https://githubflow.github.io).

When code is merged to `main`:

1. Any changes to the [app](./app/) will trigger a new tag and release based off of the version in `package.json`.
2. A Docker image is created with the new version.
3. Infrastructure changes are deployed via Spacelift.
