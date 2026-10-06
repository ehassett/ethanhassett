# ethanhassett.com

[![Release](https://github.com/ehassett/ethanhassett/actions/workflows/release.yml/badge.svg)](https://github.com/ehassett/ethanhassett/actions/workflows/release.yml)

Repo for https://ethanhassett.com

# Contents

- [ethanhassett.com](#ethanhassettcom)
- [Contents](#contents)
- [Development](#development)
- [Deployment](#deployment)

# Development

- Follow [conventional commits v1.0.0](https://www.conventionalcommits.org/en/v1.0.0/) for commits _and_ PR titles.
- For IaC changes, follow [the Terraform best practices](https://www.terraform-best-practices.com) as close as possible.
- Make sure any app code changes also include a version bump, following [Semantic Versioning](https://semver.org).
- Use Node.js 24.21.0 LTS from [`.tool-versions`](./.tool-versions). [The build version file](./app/.node-version) mirrors this pin for Workers Builds, and CI checks that they match.

Install dependencies:

```sh
cd app
npm ci
```

For local contact form testing, define these secrets in `app/.dev.vars`:

- `MAILGUN_API_KEY`
- `TURNSTILE_SECRET_KEY`

Run `npm run dev` for Astro's local Workers runtime with hot reload. The default URL is http://localhost:4321.

```sh
npm run types       # Generate runtime and binding declarations
npm run check       # Generate types and check Astro/TypeScript
npm run build       # Check and build the Worker
npm run preview     # Preview the built Worker locally
```

`npm run preview` is local-only. `npm run deploy` publishes production, while `npm run deploy:preview` publishes a Preview named after the current branch. Both require a build first.

Generated bindings are ignored by git and regenerated before development and builds. `secrets.required` declares secret names so CI can generate types without live secret values.

Astro 7, Cloudflare adapter 14, and TypeScript 6 are used. TypeScript 7 is deferred until Astro Check supports it. Astro's formatter remains at 0.14.1 because the latest v1 formatter does not yet work with published Tailwind class sorting; the changelog's 0.14.2 fallback is not published.

# Deployment

The deployment process follows [GitHub Flow](https://githubflow.github.io). Version 2.0.0 targets Cloudflare Workers, not Pages. GitHub Actions performs PR checks and creates releases; [Workers Builds](https://developers.cloudflare.com/workers/ci-cd/builds/) owns application deployment and branch previews.
