# Deploying this Monorepo to Vercel

This document outlines recommended steps to connect and configure the monorepo on Vercel (recommended: one Vercel project per app).

## Per-app settings (recommended)
- Create separate projects for:
  - `apps/web` (Next.js)
  - `apps/api` (Node / Inngest / Edge functions)
  - `apps/mobile` (if you host any build artifacts)

For each Vercel project:
- **Root Directory**: `apps/<app-name>` (e.g., `apps/web`) — set this in the **Project Settings** on Vercel (not in `vercel.json`).
- **Build Command**: `pnpm turbo build --filter=@hq-operations/<app-package-name>`
  - Example: `pnpm turbo build --filter=@hq-operations/web`
- **Install Command**: `pnpm install`
- **Output Directory**: Next.js: `.next` / API: `dist` or leave default

**Vercel-specific notes**:
- Do **not** rely on `rootDirectory` inside `vercel.json`; Vercel expects the Root Directory to be configured in the project settings in the dashboard.
- If your app imports code from `packages/*` (outside the Root Directory), enable **Include source files outside of the Root Directory** in the project settings so the build can access shared packages.
- Use the **Ignored Build Step** setting in the project UI if you want to prevent Vercel from building on certain commits; this setting runs in the configured Root Directory and uses a shallow clone (depth 10).
- `.vercelignore` files placed inside `apps/<app>/` take precedence over a repo-root `.vercelignore` — add one per project if you need fine-grained ignores.

## Environment Variables & CI Secrets
Add the variables from `.env.example` in both **Preview** and **Production** as appropriate. Important keys:
- `UPSTASH_REDIS_REST_URL` and `UPSTASH_REDIS_REST_TOKEN`
- `KV_REST_API_URL` and `KV_REST_API_TOKEN`
- `DATABASE_URL` (if used)
- Any third-party secrets (Stripe, Sentry, etc.)

Do **not** commit `.env.local` or any real secrets to the repo. Use `.env.example` only.

### Vercel CI deployment secrets (GitHub Actions)
To deploy from CI using Vercel CLI, set the following GitHub repository secrets (Repository Settings → Secrets → Actions):
- `VERCEL_TOKEN` — a Vercel token with deploy permissions. See Vercel Dashboard → Settings → Tokens.
- `VERCEL_ORG_ID` — your Vercel organization ID (optional but recommended).
- `VERCEL_PROJECT_WEB_ID` — the Vercel project ID for the `apps/web` project.
- `VERCEL_PROJECT_API_ID` — the Vercel project ID for the `apps/api` project.

If you'd like PR preview deployments via CI, ensure `VERCEL_TOKEN` has preview/deploy rights. If you prefer Vercel to run builds instead of CI, you can disable these deployment workflows and enable Vercel Git integration per project.

### Optional: Automate project secret creation from the workflow 🔐
If you want the `Create Vercel Projects` workflow to automatically store discovered Vercel project IDs as repository secrets, create a GitHub Personal Access Token (PAT) and add it as the repository secret `REPO_MANAGEMENT_TOKEN`.

- Create a PAT (Settings → Developer settings → Personal access tokens → Generate new token (classic)).
  - Recommended scopes: **repo** (full control of private repositories). The token will be used by the `gh` CLI inside the workflow to set repository secrets.
  - Optionally add **workflow** if you plan to allow the token to interact with Actions in other ways.
- Add the token as a **Repository secret** named `REPO_MANAGEMENT_TOKEN` (Settings → Secrets → Actions).
- Re-run the **Create Vercel Projects** workflow (Actions → Create Vercel Projects → Run workflow) on the branch/PR; the workflow will use that secret to set `VERCEL_PROJECT_WEB_ID` and `VERCEL_PROJECT_API_ID` in the repository.

Security tips:
- Use the least-privilege token you can and rotate it regularly.
- Keep the PAT in the repository secrets store (not in any code or PRs).

## Git integration & Preview Deploys
1. Connect your Git provider (GitHub/GitLab/Bitbucket) to Vercel.  
2. Add the repository and configure each project to use the correct Root Directory.  
3. Enable Deploy Previews on pull requests (default).  

## Optional: CI gating
Even with Vercel builds, we recommend running PR checks (type-check and build) via GitHub Actions before merging. This repo includes a sample PR check workflow that runs TypeScript and Turbo builds.

## Additional notes
- Ensure Node engine compatibility in `package.json` (Node 18+ recommended).  
- Keep `.env.local` for local development only and add secrets to Vercel dashboard for preview/production.  
- If you use monorepo-specific features (Turbo caching, custom outputs), verify build settings in Vercel to allow workspace caching.
