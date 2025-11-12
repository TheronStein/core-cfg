[#software-engineering](https://publish.obsidian.md/#software-engineering)  

[#software-engineering/remix](https://publish.obsidian.md/#software-engineering/remix)

[Module Constraints | Remix](https://remix.run/docs/en/main/guides/constraints)

[Gotchas | Remix](https://remix.run/docs/en/main/guides/gotchas)

## Splitting up Client and Server Code

Remix lets you write code that [runs on both the client and the server](https://remix.run/docs/en/main/discussion/server-vs-client.md). Out-of-the-box, Vite doesn't support mixing server-only code with client-safe code in the same module. Remix is able to make an exception for routes because we know which exports are server-only and can remove them from the client.

There are a few ways to isolate server-only code in Remix. The simplest approach is to use `.server` modules.

### [](https://remix.run/docs/en/main/future/vite#server-modules)`.server` Modules

While not strictly necessary, `.server` modules are a good way to explicitly mark entire modules as server-only. The build will fail if any code in a `.server` file or `.server` directory accidentally ends up in the client module graph.

```txt
app
├── .server 👈 marks all files in this directory as server-only
│   ├── auth.ts
│   └── db.ts
├── cms.server.ts 👈 marks this file as server-only
├── root.tsx
└── routes
    └── _index.tsx
```

`.server` modules must be within your Remix app directory.

### [](https://remix.run/docs/en/main/future/vite#vite-env-only)vite-env-only

If you want to mix server-only code and client-safe code in the same module, you can use [vite-env-only](https://github.com/pcattori/vite-env-only). This Vite plugin allows you to explicitly mark any expression as server-only so that it gets replaced with `undefined` in the client.

For example, once you've added the plugin to your Vite config, you can wrap any server-only exports with `serverOnly$`:

```tsx
import { serverOnly$ } from "vite-env-only";

import { db } from "~/.server/db";

export const getPosts = serverOnly$(async () => {
  return db.posts.findMany();
});

export const PostPreview = ({ title, description }) => {
  return (
    <article>
      <h2>{title}</h2>
      <p>{description}</p>
    </article>
  );
};
```

Copy code to clipboard

This example would be compiled into the following code for the client:

```tsx
export const getPosts = undefined;

export const PostPreview = ({ title, description }) => {
  return (
    <article>
      <h2>{title}</h2>
      <p>{description}</p>
    </article>
  );
};
```

in remix you can use client only to use make sure component only runs on client

[remix-utils/src/react/client-only.tsx at main · sergiodxa/remix-utils (github.com)](https://github.com/sergiodxa/remix-utils/blob/main/src/react/client-only.tsx)

## Best Practice

1. explicit separate client and server module using `serverOnly$` or `.server.ts`
2. use common module / duplicate for code that used in both client and server