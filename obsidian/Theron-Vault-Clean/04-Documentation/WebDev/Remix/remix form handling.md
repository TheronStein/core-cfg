  
[#software-engineering](https://publish.obsidian.md/#software-engineering)  

[#software-engineering/remix](https://publish.obsidian.md/#software-engineering/remix)

1. we manage as least client state as possible
2. use html validation as much as possible
3. submit the form to action
4. server side runtime validation
5. multiple form to single action function

## What Are the Choices?

1. simple zod validation
    1. ✅ clean and simple
    2. ✅ compatible with many things, good documentation
2. remix-hook-form
    1. ✅ clean and simple
    2. ✅ use [react hook form](https://yomaru.dev/react+hook+form), trustworthy
    3. ✅ server and client helper
3. conform
    1. ✅ Clean and simple
    2. ⛔ it is not using remix hook form under the hood, implement own form solution
    3. ⛔ doesn't have action schema validation helper
4. [remix-forms](https://github.com/seasonedcc/remix-forms)
    1. ⛔ force you to use domain function

## Principles

1. forms should be server side as possible
2. never do client side async validation

Warning

But I met a circumstance that I really need client side async validation. That happens when we do the top tier testimonials demo. The demo need user to input their datasource credential and the demo never call our server api. Therefore, the whole demo is completely client side. To validate the credentials, we would need client side validation.

## Simple Form + Zod Validation in Action

1. easy but limited
2. will redirect to another page if the action is in another route

## Fetcher Form + Zod Validation in Action

```tsx
const fetcher = useFetcher() ;

return <fetcher.Form>...</fetcher.Form>
```

## Fetcher Form + Zod Validation

✅ name action use [action reducer pattern](https://sergiodxa.com/articles/multiple-forms-per-route-in-remix) so that we can have multiple form to a single action

`remix-utils` provide named action but I prefer doing it by myself so that I don’t need to install `remix-utils`

## Mantine Form (component only) + Fetcher Form + Zod Validation

mantine form will be responsible for client side form handling, fetcher for sending the request to action.

1. ⛔ validation is only done in server side
2. ⛔ difficult to handle complex form state
3. ⛔ difficult to handle nested form state

```tsx
// eslint-disable-next-line @typescript-eslint/no-explicit-any
function getError(fetcher: FetcherWithComponents<any>, value: string) {
  return fetcher.data?.errors?.[value]?._errors[0];
}

export const NotionSection = () => {
  const fetcher = useFetcher<typeof action>();
  const currentProject = useCurrentProject();
  // two inputs
  // one for notion access token
  // one for notion page id
  // one button to save
  return (
    <fetcher.Form action="/api/update-project" method="POST">
      <TextInput
        type="text"
        name="notionAccessToken"
        placeholder="Notion Access Token"
        defaultValue={currentProject.notion_access_token ?? ""}
        error={getError(fetcher, "notionAccessToken")}
      />
      <TextInput
        type="text"
        name="notionDatabaseId"
        placeholder="Notion Database ID"
        defaultValue={currentProject.notion_database_id ?? ""}
      />
      <input type="hidden" name="action" value="notion" />
      {/* hidden field */}
      <input type="hidden" name="projectId" value={currentProject.id} />
      <Button type="submit">Save</Button>
    </fetcher.Form>
  );
};

```

## mantine form (component + hook) + fetcher + Zod Validation

> Until this stage, the form functionality already pretty comprehensive

✅ client and server side validation  
✅ show client and server side validation error on input  
✅ inject form valid to `useForm` hook

notice that since we store the initialValues in `useForm` hook and it will not be refresh when the url params is change, therefore, we need to set a key on the form to completely refresh the state of the component

```tsx
import { useCurrentProject } from "@/utils/useCurrentProject";
import { FetcherWithComponents, useFetcher } from "@remix-run/react";
import { TextInput, Button } from "@mantine/core";
import { action } from "@/routes/api+/update-project";
import { useForm, zodResolver } from "@mantine/form";
import { $path } from "remix-routes";
import { notionFormSchema } from "@/utils/schemas";

// eslint-disable-next-line @typescript-eslint/no-explicit-any
function getError(fetcher: FetcherWithComponents<any>, value: string) {
  return fetcher.data?.errors?.[value]?._errors[0];
}

export const NotionSection = () => {
  const fetcher = useFetcher<typeof action>();
  const currentProject = useCurrentProject();
  const form = useForm({
    initialValues: {
      notionAccessToken: currentProject.notion_access_token ?? "",
      notionDatabaseId: currentProject.notion_database_id ?? "",
      projectId: currentProject.id,
      action: "notion",
    },
    validate: zodResolver(notionFormSchema),
  });

  const onSubmit = form.onSubmit((values) =>
    fetcher.submit(values, {
      method: "POST",
      action: $path("/api/update-project"),
    })
  );

  return (
    <form onSubmit={onSubmit}>
      <TextInput
        type="text"
        placeholder="Notion Access Token"
        {...form.getInputProps("notionAccessToken")}
        error={
          form.errors.notionAccessToken ??
          getError(fetcher, "notionAccessToken")
        }
      />
      <TextInput
        type="text"
        placeholder="Notion Database ID"
        {...form.getInputProps("notionDatabaseId")}
        error={
          form.errors.notionDatabaseId ?? getError(fetcher, "notionDatabaseId")
        }
      />
      <Button type="submit">Save</Button>
    </form>
  );
};
```

## Client side optimization

1. we need to set the submit button loading to `fetcher.state !== "idle`
2. when the form is not dirty, we should disable the button. After submission, we need to do `form.resetDirty()`