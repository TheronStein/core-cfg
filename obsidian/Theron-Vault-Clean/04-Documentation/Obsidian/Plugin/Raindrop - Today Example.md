The below Templater command will grab your raindrop links and then filter for those made today. You can adjust the date matching to grab yesterday, etc.

You'll need a raindrop API test token for your account by creating an app. You can do that here:

[Raindrop Integrations](https://app.raindrop.io/settings/integrations)

```
<%*
const TEST_TOKEN = $put_token_here
const output = await fetch("https://api.raindrop.io/rest/v1/raindrops/0", 
{headers: {"Authorization": `Bearer ${TEST_TOKEN}`}})
	.then(res => res.json())
	.then(json => json.items
		.filter(item => moment(item.created).format("YYYY-MM-DD") === moment().format("YYYY-MM-DD"))
		.map(item => `- [${item.title}](${item.link}) ${item.tags.map(tag => `#${tag}`).join(" ")}`)
)
tR += output.join("\n")
%>
```