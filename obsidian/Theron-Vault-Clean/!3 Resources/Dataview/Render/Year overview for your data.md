## Basic[¶](https://s-blu.github.io/obsidian_dataview_example_vault/20%20Dataview%20Queries/Render%20a%20year%20overview%20for%20your%20data/#basic "Permanent link")

Track activities in your dailies, i.e. if you have prayed.

```dataviewjs
const values = dv.pages('"10 Example Data/dailys"').where(p => p.praying === "yes");
const year = 2022;
const color = "green";
const emptyColor = "rgba(255,255,255,0.1)";

// == Create calendar data ==
let date = dv.luxon.DateTime.utc(year)
const calendar = [];
for(let i = 1; i <= 12; i++) {
    calendar[i] = []
}

// == Fill calendar ==
while (date.year == year) {
    const col = !!values.find(p => p.day.equals(date.startOf('day'))) ? color : emptyColor;
    calendar[date.month].push(getDayEl(date, col))

    date = addOneDay(date);
}

// == Render calendar ==
calendar.forEach((month, i) => {
    const monthEl = `<span style='display:inline-block;min-width:30px;font-size:small'>${dv.luxon.DateTime.utc(year, i).toFormat('MMM')}</span>`

    dv.el("div", monthEl + month.reduce((acc, curr) => `${acc} ${curr}`, ""))
})

function addOneDay(date) {
    return dv.luxon.DateTime.fromMillis(date + dv.duration("1d"))
}

function getDayEl(date, color) {
    const sizeOfDays = "12px";
    return `<span style="width:${sizeOfDays};height:${sizeOfDays};border-radius:2px;background-color:${color};display:inline-block;font-size:4pt;" title="${date.toFormat('yyyy-MM-dd')}"></span>`
}
```

## Variants[¶](https://s-blu.github.io/obsidian_dataview_example_vault/20%20Dataview%20Queries/Render%20a%20year%20overview%20for%20your%20data/#variants "Permanent link")

### Use a meta data field with a date instead of file.day[¶](https://s-blu.github.io/obsidian_dataview_example_vault/20%20Dataview%20Queries/Render%20a%20year%20overview%20for%20your%20data/#use-a-meta-data-field-with-a-date-instead-of-fileday "Permanent link")

See on one glimpse the **start** and **finish** dates of your projects.

```dataviewjs
const values = dv.pages('"10 Example Data/projects"').where(p => p.started);
const year = 2022;
const emptyColor = "rgba(255,255,255,0.1)";

// == Fill data ==
let date = dv.luxon.DateTime.utc(year)
const calendar = [];
for(let i = 1; i <= 12; i++) {
    calendar[i] = []
}

while (date.year == year) {
    calendar[date.month].push(getDayEl(date, determineColor(date)))

    date = addOneDay(date);
}

// == Render calendar ==
calendar.forEach((month, i) => {
    const monthEl = `<span style='display:inline-block;min-width:30px;font-size:small'>${dv.luxon.DateTime.utc(year, i).toFormat('MMM')}</span>`

    dv.el("div", monthEl + month.reduce((acc, curr) => `${acc} ${curr}`, ""))
})

function addOneDay(date) {
    return dv.luxon.DateTime.fromMillis(date + dv.duration("1d"))
}
function getDayEl(date, color) {
    const sizeOfDays = "12px";
    return `<span style="width:${sizeOfDays};height:${sizeOfDays};border-radius:2px;background-color:${color};display:inline-block;font-size:4pt;" title="${date.toFormat('yyyy-MM-dd')}"></span>`
}

function determineColor(date) {
    const started = values.find(p => p.started?.startOf('day').equals(date.startOf('day')));
    const finished = values.find(p => p.finished?.startOf('day').equals(date.startOf('day')));
    let color = emptyColor;

    if (started && finished) {
        color = '#9959ff';  
    } else if (started) {
        color = '#ff5976'
    } else if (finished) {
        color = 'green'
    }

    return color;
}
```

### Add information on hover[¶](https://s-blu.github.io/obsidian_dataview_example_vault/20%20Dataview%20Queries/Render%20a%20year%20overview%20for%20your%20data/#add-information-on-hover "Permanent link")

Hover over a dot and wait a moment to see which project started or finished.

```dataviewjs
const values = dv.pages('"10 Example Data/projects"').where(p => p.started);
const year = 2022;
const emptyColor = "rgba(255,255,255,0.1)";

// == Fill data ==
let date = dv.luxon.DateTime.utc(year)
const calendar = [];
for(let i = 1; i <= 12; i++) {
    calendar[i] = []
}

while (date.year == year) {
    calendar[date.month].push(getDayEl(date, determineColor(date), createTooltip()))

    date = addOneDay(date);

    function createTooltip() {
        let tooltip = "";
        const vals = values.filter(p => checkDateEq(p.started, date) || checkDateEq(p.finished, date))
        for (let val of vals) {
            tooltip += `${val.file.name} `
        }
        return tooltip;
    }
}

// == Render calendar ==
calendar.forEach((month, i) => {
    const monthEl = `<span style='display:inline-block;min-width:30px;font-size:small'>${dv.luxon.DateTime.utc(year, i).toFormat('MMM')}</span>`

    dv.el("div", monthEl + month.reduce((acc, curr) => `${acc} ${curr}`, ""))
})

function addOneDay(date) {
    return dv.luxon.DateTime.fromMillis(date + dv.duration("1d"))
}
function getDayEl(date, color, hoverInfo) {
    const sizeOfDays = "12px";
    return `<span style="width:${sizeOfDays};height:${sizeOfDays};border-radius:2px;background-color:${color};display:inline-block;font-size:4pt;" title="${hoverInfo}"></span>`
}

function checkDateEq(date1, date2) {
    if (!date1 || !date2) return false
    return date1.startOf('day').equals(date2.startOf('day'))
}

function determineColor(date) {
    const started = values.find(p => p.started?.startOf('day').equals(date.startOf('day')));
    const finished = values.find(p => p.finished?.startOf('day').equals(date.startOf('day')));
    let color = emptyColor;

    if (started && finished) {
        color = '#9959ff';  
    } else if (started) {
        color = '#ff5976'
    } else if (finished) {
        color = 'green'
    }

    return color;
}
```

### Use a intensity to display different values[¶](https://s-blu.github.io/obsidian_dataview_example_vault/20%20Dataview%20Queries/Render%20a%20year%20overview%20for%20your%20data/#use-a-intensity-to-display-different-values "Permanent link")

```dataviewjs
const values = dv.pages('"10 Example Data/dailys"').where(p => p.wellbeing?.mood);
const year = 2022;
const emptyColor = "rgba(255,255,255,0.1)";

// == Fill data ==
let date = dv.luxon.DateTime.utc(year)
const calendar = [];
for(let i = 1; i <= 12; i++) {
    calendar[i] = []
}

while (date.year == year) {
    calendar[date.month].push(
    getDayEl(
        date, 
        determineColor(date)))

    date = addOneDay(date);
}

// == Render calendar ==
calendar.forEach((month, i) => {
    const monthEl = `<span style='display:inline-block;min-width:30px;font-size:small'>${dv.luxon.DateTime.utc(year, i).toFormat('MMM')}</span>`

    dv.el("div", monthEl + month.reduce((acc, curr) => `${acc} ${curr}`, ""))
})

function addOneDay(date) {
    return dv.luxon.DateTime.fromMillis(date + dv.duration("1d"))
}

function getDayEl(date, color) {
    const sizeOfDays = "12px";
    return `<span style="width:${sizeOfDays};height:${sizeOfDays};border-radius:2px;background-color:${color};display:inline-block;font-size:4pt;" title="${date.toFormat('yyyy-MM-dd')}"></span>`
}

function determineColor(date) {
    console.log(values.find(p => !p.day))
    const page = values.find(p => p.file.day.startOf('day').equals(date.startOf('day')));
    if (!page) return emptyColor;


    let opacity = (page.wellbeing.mood / 4) ;
    return `rgba(177, 200, 51, ${opacity})`;

}
```

### Use as a view file for reusability[¶](https://s-blu.github.io/obsidian_dataview_example_vault/20%20Dataview%20Queries/Render%20a%20year%20overview%20for%20your%20data/#use-as-a-view-file-for-reusability "Permanent link")

![What is#^dv-view](https://s-blu.github.io/obsidian_dataview_example_vault/00%20Meta/Vault%20Infos/What%20is/#dv-view)

**Simple case** - input pages to display, the year to render and an "active" color

```dataviewjs
await dv.view("00 Meta/dataview_views/year_overview", 
    {
        pages: dv.pages('"10 Example Data/dailys"').where(p => p.praying === "yes"),
        year: 2022,
        color: "green"
    })
```

**Complex case** - Provide functions to determine color and tooltip. Both function will be called with the date to fill as argument and need to give back a string.

```dataviewjs
const pages = dv.pages('"10 Example Data/dailys"').where(p => p.wellbeing?.mood);

await dv.view("00 Meta/dataview_views/year_overview", 
    {
        pages: pages,
        year: 2022,
        color: determineColor,
        tooltipFn: generateTooltip
    })

function determineColor(date) {
    const page = pages.find(p => p.day.startOf('day').equals(date.startOf('day')));
    if (!page) return "rgba(9, 99, 199, 0.15)";

    let opacity = (page.wellbeing.mood / 4) ;
    return `rgba(177, 200, 51, ${opacity})`;

}

function generateTooltip(date) {
    const page = pages.find(p => p.day.startOf('day').equals(date.startOf('day')));
    if (!page) return date.toFormat('yyyy-MM-dd');

    return `${page.file.name}: ${page.wellbeing?.mood ?? ''}`
}
```

### Render more than one meta data per day[¶](https://s-blu.github.io/obsidian_dataview_example_vault/20%20Dataview%20Queries/Render%20a%20year%20overview%20for%20your%20data/#render-more-than-one-meta-data-per-day "Permanent link")

Rendering multiple values

The amount of color blocks is determined by the number of colors given back, so all you need to tweak is what `determineColor` is giving back - and maybe increase the size of the day elements. 😉  
If you want to use intensity too, `determineColor` needs to return something like ``[`rgba(177, 200, 51, ${(page.wellbeing.mood / 4)})`, `rgba(50, 90, 220, ${(page.wellbeing.health / 4)})`]``

```dataviewjs
const values = dv.pages('"10 Example Data/dailys"').where(p => p.wellbeing?.mood);
const year = 2022;
const emptyColor = "rgba(255,255,255,0.1)";

// == Fill data ==
let date = dv.luxon.DateTime.utc(year)
const calendar = [];
for(let i = 1; i <= 12; i++) {
    calendar[i] = []
}

while (date.year === year) {
    calendar[date.month].push(
    getDayEl(
        date, 
        determineColor(date)))

    date = addOneDay(date);
}

// == Render calendar ==
calendar.forEach((month, i) => {
    const monthEl = `<span style='display:inline-block;min-width:30px;font-size:small'>${dv.luxon.DateTime.utc(year, i).toFormat('MMM')}</span>`

    dv.el("div", monthEl + month.reduce((acc, curr) => `${acc} ${curr}`, ""))
})

function addOneDay(date) {
    return dv.luxon.DateTime.fromMillis(date + dv.duration("1d"))
}

function getDayEl(date, colors) {
    const sizeOfDays = 14;
    const sizeOfColors = Math.round(sizeOfDays / colors.length)
    let dayEl = `<span style="width:${sizeOfDays}px;height:${sizeOfDays}px;display:inline-flex;flex-direction:column" title="${date.toFormat('yyyy-MM-dd')}">`
    for (let color of colors) {
        dayEl += `<span style="width:${sizeOfDays}px;height:${sizeOfColors}px;background-color:${color};display:inline-flex;"></span>`
    }
    dayEl += "</span>"
    return dayEl;
}

function determineColor(date) {
    const page = values.find(p => p.file.day.startOf('day').equals(date.startOf('day')));
    if (!page) return [emptyColor, emptyColor];

    return [
        page.beingthankful ? "#be83eb" : emptyColor,
        page.praying ? "#6c79b5" : emptyColor
    ]
}
```