# ethanhassett.com

[![Release](https://github.com/ehassett/ethanhassett/actions/workflows/release.yml/badge.svg)](https://github.com/ehassett/ethanhassett/actions/workflows/release.yml)

Repo for https://ethanhassett.com

# Contents

- [ethanhassett.com](#ethanhassettcom)
- [Contents](#contents)
- [Contributing](#contributing)
- [Development](#development)
- [Deployment](#deployment)
  - [Staging](#staging)
  - [Production](#production)

# Contributing

- Follow [conventional commits v1.0.0](https://www.conventionalcommits.org/en/v1.0.0/) for commits _and_ PR titles.
- For IaC changes, follow [the Terraform best practices](https://www.terraform-best-practices.com) as close as possible.
- Follow [GitHub Flow](https://githubflow.github.io) for branching strategy and PR process.
- Make sure any app code changes also include a version bump, following [Semantic Versioning](https://semver.org).

# Development

To run the development environment locally, first ensure the following environment variables are defined in `app/.dev.vars`:

- `MAILGUN_API_KEY`
- `TURNSTILE_SITE_KEY`
- `TURNSTILE_SECRET_KEY`

Run `cd app && npm run dev` which deploys the development version of the site using [wrangler](https://developers.cloudflare.com/pages/functions/local-development/).

# Deployment

The deployment process follows [GitHub Flow](https://githubflow.github.io).

## Staging

When code is merged to the `staging` branch, Cloudflare Pages automatically deploys the new version of the site. This is protected by a OTP, accessible at https://staging.ethanhassett.com.

## Production

When code is merged to `main`:

1. Any changes to the [app](./app/) will trigger a new tag and release based off of the version in `package.json`.
2. Cloudflare Pages automatically deploys the new version to https://ethanhassett.com.
