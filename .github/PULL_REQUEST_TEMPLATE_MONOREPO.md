This PR converts the repository into a monorepo skeleton and sets up CI-driven Vercel deployments.

What changed:
- Moved web app files into `apps/web` (retained app history where possible)
- Added skeleton `apps/api` and `apps/mobile` placeholders
- Added workspace packages: `packages/shared`, `packages/ui`, `packages/database`, `packages/web-shared`, `packages/mobile-shared`
- Added/updated `turbo.json`, `pnpm-workspace.yaml`, root scripts, and workspace `package.json`
- Added GitHub workflows: PR preview deploys (`.github/workflows/preview-deploy.yml`) and production CI deployments to Vercel (`.github/workflows/deploy-web.yml`, `.github/workflows/deploy-api.yml`)
- Added `.env.example` and `DEPLOYING_TO_VERCEL.md` documenting required secrets and steps

Checklist (before merging):
- [ ] Add GitHub secrets: `VERCEL_TOKEN`, `VERCEL_ORG_ID`, `VERCEL_PROJECT_WEB_ID`, `VERCEL_PROJECT_API_ID`
- [ ] Enable "Include source files outside of the Root Directory" in each Vercel project (if apps import from `packages/*`)
- [ ] Confirm Vercel project IDs and token permissions for CI deployments
- [ ] Run a final CI build or test deploy on a staging branch

Notes:
- I kept `.env.local` out of the repo and added `.env.example` for reference.
- If you want me to squash/rewrite history or open as a draft PR instead, tell me and I will adjust.