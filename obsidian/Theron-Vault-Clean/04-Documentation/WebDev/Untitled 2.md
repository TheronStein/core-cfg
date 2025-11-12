  
[#software-engineering](https://publish.obsidian.md/#software-engineering)  

[#software-engineering/remix](https://publish.obsidian.md/#software-engineering/remix)

[

GitHub - yesmeck/remix-routes: Typesafe routing for your Remix apps.

Typesafe routing for your Remix apps. Contribute to yesmeck/remix-routes development by creating an account on GitHub.

![fluidicon.png](https://github.com/fluidicon.png) https://github.com/yesmeck/remix-routes

](https://github.com/yesmeck/remix-routes)

## What is it?

a util to help remix dev.

## How to use it?

1. simply install it and run `npx remix-routes`. This will generate the static routes params type in `./node_modules`
2. you can defined typed search params using `zod` and `remix-params-helper`
3. you can also type check the url params
4. on client side, you get the type for routes which can be used in `useLoaderData` and `useRouteLoaderData`

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

```tsx
import type { ActionFunction } from 'remix';
import { $params } from 'remix-routes'; // <-- Import $params helper.

export const action: ActionFunction = async ({ params }) => {
  const { id } = $params("/posts/:id/update", params) // <-- It's type safe, try renaming `id` param.

  // ...
}
```

## Alternatives and comparisons