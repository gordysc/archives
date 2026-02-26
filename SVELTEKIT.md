# 🔥 Svelte 5 & SvelteKit Modern Features Reference

> Covers Svelte 5.20–5.49 and SvelteKit 2.17–2.50 (2025–2026).

---

## 🧩 Runes — Svelte 5 Reactivity

Runes are compiler-level reactive primitives that replace the old `$:` reactive declarations and `export let` props.

### `$state`

Creates reactive state. Arrays and objects have deep reactivity — internal mutations automatically update the UI without reassignment.

```svelte
<script>
  let count = $state(0);
  let items = $state([{ name: "first" }]);

  // This just works — no reassignment needed
  items[0].name = "updated";
</script>
```

### `$state.eager` (v5.41+)

Immediately updates the UI instead of waiting for an async resolution. Useful for instant visual feedback like navigation indicators.

```svelte
<script>
  let activeTab = $state.eager("home");
</script>
```

### `$derived`

Computed values that automatically update when dependencies change. Memoized — only recalculated when needed.

```svelte
<script>
  let count = $state(0);
  let doubled = $derived(count * 2);

  // For complex derivations
  let filtered = $derived.by(() => {
    return items.filter(i => i.active);
  });
</script>
```

### `$effect`

Runs side effects after the DOM updates when dependencies change. Return a cleanup function for teardown.

```svelte
<script>
  let query = $state("");

  $effect(() => {
    const controller = new AbortController();
    fetch(`/api/search?q=${query}`, { signal: controller.signal });
    return () => controller.abort();
  });
</script>
```

### `$props`

Declares component props, replacing `export let`.

```svelte
<script>
  let { title, count = 0, children } = $props();
</script>
```

### `$props.id()` (v5.20+)

SSR-safe unique ID generation — unique per component instance, stable across server and client.

```svelte
<script>
  let { label } = $props();
  let id = $props.id();
</script>

<label for={id}>{label}</label>
<input {id} />
```

---

## 🔗 Attachments (v5.29+)

A more flexible successor to actions. Attachments are functions that receive a DOM node and optionally return a cleanup function. Unlike actions, **attachments work on both DOM elements and Svelte components**.

```svelte
<script>
  import { createAttachmentKey } from "svelte/attachments";

  function tooltip(node) {
    const tip = document.createElement("div");
    node.appendChild(tip);
    return () => tip.remove();
  }
</script>

<button {@attach tooltip}>Hover me</button>
```

### Converting Actions to Attachments

```ts
import { fromAction } from "svelte/attachments";

const attachment = fromAction(existingAction, options);
```

### Programmatic Attachments

```ts
import { createAttachmentKey } from "svelte/attachments";

const key = createAttachmentKey();
const props = { [key]: tooltip };
```

Spread onto elements and the attachment is recognized automatically.

---

## 🧵 Snippets

Reusable pieces of markup embedded directly in components without creating a new file. Support generics for type-safe reuse (v5.30+).

```svelte
{#snippet row<T>(item: T, index: number)}
  <tr>
    <td>{index}</td>
    <td>{item.name}</td>
  </tr>
{/snippet}

{#each items as item, i}
  {@render row(item, i)}
{/each}
```

---

## ⏳ Async Components & SSR

### Experimental Async SSR (v5.39+ / SvelteKit 2.43+)

Use `await` anywhere in your app without wrapping in a `{#await}` block with a pending snippet. The compiler handles loading states automatically.

**Configuration:**

```js
// svelte.config.js
export default {
  compilerOptions: {
    experimental: {
      async: true
    }
  }
};
```

```svelte
<script>
  let posts = await fetchPosts();
</script>

{#each posts as post}
  <article>{post.title}</article>
{/each}
```

### `fork` API (v5.42+)

Enables offscreen state modifications to detect async work without rendering changes to the screen. Used internally by SvelteKit (v2.48+) for improved async handling.

---

## 📡 Remote Functions (Experimental, SvelteKit 2.27+)

Type-safe server communication without traditional API routes. Functions are defined in `.remote.ts` files, execute on the server, and are callable from anywhere in the app.

**Configuration:**

```js
// svelte.config.js
export default {
  kit: {
    experimental: {
      remoteFunctions: true
    }
  },
  compilerOptions: {
    experimental: {
      async: true
    }
  }
};
```

### `query` — Read Data

```ts
// src/routes/posts.remote.ts
import { query } from "@sveltejs/kit";

export const getPosts = query(async () => {
  return await db.sql`SELECT * FROM post`;
});
```

```svelte
{#each await getPosts() as post}
  <p>{post.title}</p>
{/each}
```

- Returns a Promise with `.loading`, `.error`, and `.current` properties
- Cached per page — same call returns identical object
- `.refresh()` re-fetches data

### `query.batch` — Solve N+1 Problems (v2.38+)

Batches simultaneous calls within the same macrotask into a single HTTP request.

```ts
export const getWeather = query.batch(v.string(), async (cityIds) => {
  const weather = await db.sql`SELECT * FROM weather WHERE city_id = ANY(${cityIds})`;
  const lookup = new Map(weather.map((w) => [w.city_id, w]));
  return (cityId) => lookup.get(cityId);
});
```

### `form` — Progressive Enhancement

Type-safe form submissions with schema validation. Works without JavaScript.

```ts
export const createPost = form(
  v.object({
    title: v.pipe(v.string(), v.nonEmpty()),
    content: v.pipe(v.string(), v.nonEmpty())
  }),
  async ({ title, content }) => {
    await db.sql`INSERT INTO post (title, content) VALUES (${title}, ${content})`;
    redirect(303, `/blog/${slug}`);
  }
);
```

```svelte
<form {...createPost}>
  <input {...createPost.fields.title.as("text")} />
  <textarea {...createPost.fields.content.as("text")}></textarea>
  <button>Publish</button>
</form>
```

**Key features:**

- Schema-based validation with Zod/Valibot
- Imperative validation via `invalid()` helper (v2.46+)
- Multiple form instances with `.for(id)` (v2.45+)
- Multiple submit buttons: `.as("submit", "login")`
- Sensitive fields: prefix with `_` to prevent re-population
- Single-flight mutations: `.refresh()` server-side, `.updates()` client-side
- Streaming file uploads in form remote functions (v2.49+)
- `.enhance()` for custom submission behavior
- `.preflight()` for client-side pre-validation

### `command` — Direct Server Calls

Execute server operations without form elements.

```ts
export const addLike = command(v.string(), async (itemId) => {
  await db.sql`UPDATE item SET likes = likes + 1 WHERE id = ${itemId}`;
});
```

```svelte
<button onclick={() => addLike(itemId).updates(getLikes(itemId))}>
  Like
</button>
```

Supports optimistic updates:

```ts
await addLike(itemId).updates(getLikes(itemId).withOverride((n) => n + 1));
```

### `prerender` — Build-Time Data

Cache data as static assets, updated only on redeployment.

```ts
export const getPosts = prerender(async () => {
  return await db.sql`SELECT * FROM post`;
});
```

Use `{ dynamic: true }` to keep a server version alongside the prerendered one.

---

## 🛣️ Server-Side Route Resolution (v2.17+)

The server runtime resolves routes per-request instead of loading the full routing manifest in the client. Reduces client bundle size and improves initial load.

---

## 🔭 Observability — OpenTelemetry (v2.31+)

Built-in OpenTelemetry integration through a dedicated `instrumentation.server.ts` file, guaranteed to run before application code.

```ts
// src/instrumentation.server.ts
import { NodeSDK } from "@opentelemetry/sdk-node";

const sdk = new NodeSDK({
  // your configuration
});

sdk.start();
```

Automatic tracing covers:

- Handle hooks
- Load functions
- Form actions
- Remote functions

Supported by all official adapters with a server component.

---

## 🔌 WebSocket Support (Experimental)

Native WebSocket support using [crossws](https://github.com/unjs/crossws), compatible with all major runtimes. Configured via `hooks.server.ts` to extend the WebSocket server when the development or production server starts.

---

## 🧰 Other Notable Features

### `createContext` Type Passing (v5.40+)

Types flow automatically with stored context — no need to repeatedly type `getContext` return values.

### State in Class Constructors (v5.31+)

`$state` fields can be declared inside class constructors.

### CSS Parser Export (v5.48+)

`parseCss` function available from `svelte/compiler` — a lightweight CSS AST parser.

### Custom Styleable `<select>` (v5.47+)

Modern browsers support styleable `<select>` elements with CSS and rich HTML content. Svelte now supports these out of the box.

### ShadowRootInit Support (v5.49+)

Pass a `ShadowRootInit` object to `attachShadow()` when creating custom element shadow roots.

### `hydratable` with CSP (v5.46+)

The `hydratable` option supports a `csp` parameter in the render function for Content Security Policy compliance.

### XHTML Fragment Mode (v5.33+)

`fragments: 'html' | 'tree'` option for improved CSP compliance with HTML output.

### `%sveltekit.version%` Placeholder (v2.41+)

Use in `app.html` to inject the current app version.

### Header Validation in Dev (v2.17+)

`cache-control` and `content-type` header values validated during development to catch errors early.

### Svelte MCP Server

Official Model Context Protocol server for AI tools, providing documentation and static analysis suggestions for generating valid Svelte 5 code.

---

## 🛠️ CLI Improvements

| Feature | Version | Description |
| --- | --- | --- |
| `npx sv create --add` | sv 0.10+ | Add add-ons during project creation |
| `npx sv create --from-playground <url>` | sv 0.9.5+ | Create project from playground URL |
| `--no-dir-check` | sv 0.9.15+ | Suppress directory validation prompts |
| Cloudflare Workers setup | sv 0.11+ | Full automated Cloudflare Pages/Workers config |

---

## 📊 Performance Highlights

- 15–30% smaller bundles compared to Svelte 4 due to runes compilation
- Improved tree-shaking with lazy discovery of remote functions (v2.39+)
- Vite 7 compatibility
- Deno and edge runtime support (Cloudflare Workers, Vercel Edge)
- Node 24 support via Vercel adapter (v6.2+)
