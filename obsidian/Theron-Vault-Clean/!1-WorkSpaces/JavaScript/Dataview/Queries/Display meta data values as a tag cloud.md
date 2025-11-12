## Basic[¶](https://s-blu.github.io/obsidian_dataview_example_vault/20%20Dataview%20Queries/Display%20meta%20data%20values%20as%20a%20tag%20cloud/#basic "Permanent link")

![What is#^dv-view](https://s-blu.github.io/obsidian_dataview_example_vault/00%20Meta/Vault%20Infos/What%20is/#dv-view)

Sources

You'll find the sources of this dv.view snippet under `00 Meta/dataview_views/tagcloud`. It expects the values you want to display as an array in the second argument.

```js
await dv.view("00 Meta/dataview_views/tagcloud", 
    {
        values: dv.pages('"10 Example Data/dailys"').where(p => p.person).person
    })
```

Usage in the dataview example vault

This query is used to render the [Topic Overview](https://s-blu.github.io/obsidian_dataview_example_vault/30%20Dataview%20Resources/31%20Query%20Overviews/Topic%20Overview/)!