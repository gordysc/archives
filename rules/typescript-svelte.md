---
paths:
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.svelte"
  - "**/package.json"
---

# TypeScript / Svelte conventions

- **Package manager:** pnpm only (`pnpm install`, `pnpm add`, `pnpm dlx`, `pnpm run`) — never npm or yarn. Never run `npm install`; if a `package-lock.json` appears, delete it.
- **JSDoc:** thorough JSDoc on all TypeScript — functions, types, exported members — with `@param`, `@returns`, `@throws`, `@example` where applicable.
- **Single responsibility:** keep components small and focused; split large components into smaller composable pieces.
- **File naming:** component file names are kebab-cased (e.g. `user-profile.svelte`).
- **Styling:** Tailwind CSS utility classes exclusively — never `<style>` blocks or inline `style=` attributes.
- **Animations:** minimize animations; only transitions that convey meaningful state change.
- **SvelteKit structure — vertical slices:** organize app code by feature in `src/features/<domain>/` (e.g. `auth`, `accounts`), aliased as `$features` (add `alias: { $features: "./src/features" }` to the SvelteKit config). Each slice holds only the files it needs: `schema.ts` (zod form schemas), `types.ts` (domain types), `api.ts` (API calls), `components/`. A `shared` slice holds cross-feature UI such as the app shell. Cross-slice imports go through `$features/...`; within a slice use relative paths. Keep `$lib` for infrastructure only: ShadCN primitives in `$lib/components/ui`, generic utils/hooks in `$lib`, server-only code in `$lib/server` (or `*.server.ts` inside a slice) so SvelteKit's server-only guard applies. Routes stay thin and import from slices. Never create empty placeholder files — add a file when it gains content.
