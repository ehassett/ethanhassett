# ethanhassett.com

[![Release](https://github.com/ehassett/ethanhassett/actions/workflows/release.yml/badge.svg)](https://github.com/ehassett/ethanhassett/actions/workflows/release.yml)

Repo for https://ethanhassett.com

# Contents

- [ethanhassett.com](#ethanhassettcom)
- [Contents](#contents)
- [Contributing](#contributing)
- [Development](#development)
- [Deployment](#deployment)
- [Testing](#testing)

# Contributing

- Follow [conventional commits v1.0.0](https://www.conventionalcommits.org/en/v1.0.0/) for commits _and_ PR titles.
- For IaC changes, follow [the Terraform best practices](https://www.terraform-best-practices.com) as close as possible.
- Follow [GitHub Flow](https://githubflow.github.io) for branching strategy and PR process.
- Make sure any app code changes also include a version bump, following [Semantic Versioning](https://semver.org).

# Development

Make sure you're using the versions in the `.tool-versions` files in both [app](./app/.tool-versions) and [infrastructure](./infrastructure/.tool-versions).

# Deployment

The deployment process follows [GitHub Flow](https://githubflow.github.io).

When code is merged to `main`:

1. Any changes to the [app](./app/) will trigger a new tag and release based off of the version in `package.json`.
2. A Docker image is created with the new version.
3. Infrastructure changes are deployed via Spacelift.

# Testing

To test changes to the application with Astro only:

1. Run `cd app && npm run dev`.
2. Navigate to `localhost:4321` in your browser.
3. Verify things are running properly and there are no Astro warnings.

To test changes with Docker:

1. Build the Docker image locally by running `docker build --tag ethanhassett:test .`.
2. Run the container with:

```bash
docker run --detach \
  --name ethanhassett.com \
  --publish 80:4321 \
  ethanhassett:test
```

3. Navigate to `localhost` in your browser.
4. Verify things are running properly.
5. (Optional) Stop the container and cleanup with:

```bash
docker stop ethanhassett.com && \
  docker container rm ethanhassett.com && \
  docker image rm ethanhassett:test
```
