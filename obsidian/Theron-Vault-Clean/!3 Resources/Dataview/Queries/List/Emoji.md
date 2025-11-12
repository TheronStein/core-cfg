## Basic[¶](https://s-blu.github.io/obsidian_dataview_example_vault/20%20Dataview%20Queries/List%20all%20open%20projects%20with%20a%20emoji%20age%20indicator/#basic "Permanent link")

```dataview
TABLE "😡" * (date(now) - date(started)).weeks AS "Score"
FROM "10 Example Data/projects"
WHERE status != "finished"
```

## Variants[¶](https://s-blu.github.io/obsidian_dataview_example_vault/20%20Dataview%20Queries/List%20all%20open%20projects%20with%20a%20emoji%20age%20indicator/#variants "Permanent link")

### Use different emojis for certain timespans[¶](https://s-blu.github.io/obsidian_dataview_example_vault/20%20Dataview%20Queries/List%20all%20open%20projects%20with%20a%20emoji%20age%20indicator/#use-different-emojis-for-certain-timespans "Permanent link")

```dataviewjs
const projects = dv.pages('"10 Example Data/projects"')
    .where(p => p.status != "finished")
    .mutate(p => {
        p.age = dv.luxon.Duration.fromMillis(Date.now() - p.started.toMillis())
        p.emojiAgeScore = getEmojiScore(p)
    })

dv.table(["Score", "Project", "Started", "Age"], projects.map(p => [p.emojiAgeScore, p.file.link, p.started, p.age.toFormat("y'y' M'm' w'w'")]))

function getEmojiScore(p) {
    const age = p.age.shiftTo('months').toObject()
    let score = "";

    score += addEmojis("👿", age.months / 6)  
    score += addEmojis("😡", (age.months % 6) / 3)
    score += addEmojis("😒", (age.months % 6 % 3)) 

    return score;
}

function addEmojis(emoji, max) {
    let emojis = "";
    for (let i = 1; i < max; i++) emojis += emoji;
    return emojis;
}
	```