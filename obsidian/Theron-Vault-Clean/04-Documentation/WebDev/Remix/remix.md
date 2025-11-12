typesafe route in remix

  
[#software-engineering](https://publish.obsidian.md/#software-engineering)  

[#software-engineering/remix](https://publish.obsidian.md/#software-engineering/remix)

[yesmeck/remix-routes: Typesafe routing for your Remix apps. (github.com)](https://github.com/yesmeck/remix-routes)

## How to Use?

first you need to have a remix repo, follow [How to start a remix project quickly?](https://yomaru.dev/How+to+start+a+remix+project+quickly%3F). Then you need have some routes, see [Remix Routing](https://yomaru.dev/Remix+Routing).

1. `pnpm install remix-routes`
2. `pnpm install -D concurrently`
3. add this to `package.json`

```json
{
  "scripts": {
    "build": "remix-routes && remix build",
    "dev": "concurrently \"remix-routes -w\" \"remix dev\""
  }
}
```

4. `pnpm dev`, and there you go, you have the `$path` helper 🎉

![roy7ylnpniy3ssiso9sg.png](https://res.cloudinary.com/yomaru/image/upload/v1696746161/obsidian/roy7ylnpniy3ssiso9sg.png)

## Check Param

```tsx
import { ActionFunction } from "@remix-run/node";
import { $params } from "remix-routes"; // <-- Import $params helper.

export const action: ActionFunction = async ({ params: _params }) => {
  const params = $params("/post/:id", _params); // <-- It's type safe, try renaming `id` param.
  console.log(params.id);
  // ...
};

export default function Page() {
  return (
    <div>
      <h1>Post</h1>
    </div>
  );
}
```

## Get the Params Type

```ts
import type { Routes } from 'remix-routes';
import { useParams } from "@remix-run/react";

export default function Component() {
  const { id } = useParams<Routes['/posts/:id']['params']>();
  ...
}
```

## Get the search Query Param

Define type of query string by exporting a type named `SearchParams` in route file:

```tsx
// app/routes/posts.tsx

export type SearchParams = {
  view: 'list' | 'grid',
  sort?: 'date' | 'views',
  page?: number,
}
```

```tsx
import { $path } from 'remix-routes';

// The query string is type-safe.
$path('/posts', { view: 'list', sort: 'date', page: 1 });
```

You can combine this feature with [zod](https://github.com/colinhacks/zod) and [remix-params-helper](https://github.com/kiliman/remix-params-helper) to add runtime params checking:

```tsx
import { z } from "zod";
import { getSearchParams } from "remix-params-helper";

const SearchParamsSchema = z.object({
  view: z.enum(["list", "grid"]),
  sort: z.enum(["price", "size"]).optional(),
  page: z.number().int().optional(),
})

export type SearchParams = z.infer<typeof SearchParamsSchema>;

export const loader = async (request) => {
  const result = getSearchParams(request, SearchParamsSchema)
  if (!result.success) {
    return json(result.errors, { status: 400 })
  }
  const { view, sort, page } = result.data;
}
```