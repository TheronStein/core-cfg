> I use this template for my [Lost Mine Of Phandelver](https://dnd.wizards.com/products/tabletop-games/rpg-products/rpg_starterset) game to keep track of my players stats.

I just took the [starter kit's character sheets](https://media.wizards.com/downloads/dnd/StarterSet_Charactersv2.pdf) and moved that to markdown to use with some of the [TTRPG Community Plugins](https://publish.obsidian.md/hub/04+-+Guides%2C+Workflows%2C+%26+Courses/for+TTRPG#Community Plugins).

---

This template uses [Templater](https://publish.obsidian.md/hub/02+-+Community+Expansions/02.05+All+Community+Expansions/Plugins/templater-obsidian), [Dataview](https://publish.obsidian.md/hub/02+-+Community+Expansions/02.05+All+Community+Expansions/Plugins/dataview), and [Buttons](https://publish.obsidian.md/hub/02+-+Community+Expansions/02.05+All+Community+Expansions/Plugins/buttons) plugins. It has some fields that make it handy to use with the [initiative-tracker](https://publish.obsidian.md/hub/02+-+Community+Expansions/02.05+All+Community+Expansions/Plugins/initiative-tracker) plugin.

It also makes some use of my [Image Adjustments](https://publish.obsidian.md/hub/02+-+Community+Expansions/02.05+All+Community+Expansions/CSS+Snippets/Image+Adjustments) snippet, [Center Tables](https://publish.obsidian.md/hub/02+-+Community+Expansions/02.05+All+Community+Expansions/CSS+Snippets/Center+Tables) snippet, and some classes from the [ITS Theme](https://publish.obsidian.md/hub/02+-+Community+Expansions/02.05+All+Community+Expansions/Themes/ITS+Theme), but it's not _necessary_ to have either or any of those to use this template. It's just to make the note look nice.

```markdown
---
alias: <% tp.file.title %>
tags: Entity/Player-Character, Multiverse/D&D
cssclass: hcl, table, t-c, readable

hp: 
ac: 
modifier: 
---
%%
Creator:: 
Universe:: 
Campaign:: 
Adventure_Diary:: 
%%
<i>**` dv= this.Creator`**
` dv= this.Universe`
` dv= this.Campaign`</i>

# <% tp.file.title %>
> (Description:: )

![[|locl+hs-med]] <i>[]()</i>

||
----|:---:|
**Class** | 
**Level** | 
**Race** | 
**Alignment** | 
**Background** | 

---
# Stats
HP | AC | Speed | Initiative |
:---:|:---:|:---:|:---:|
||||

Hit Dice | Proficiency Bonus | Temp HP | 
:---:|:---:|:---:|
|||

Senses | \# |
---|---|
**Passive Perception** ||

---
## Abilities
### Abilities
STR | DEX | CON | INT | WIS | CHA ||
:---:|:----:|:----:|:---:|:---:|:---:|---|
\# |  |  |  |  |  | **Stats** |
\# |  |  |  |  |  | **Modifier** |
\# |  |  |  |  |  | **Saving Throw** |


### Skills
\# | Skill | Ability |
:--:|-----|:------:|
.| Acrobatics | DEX |
.| Animal Handling | WIS |
.| Arcana | INT |
.| Athletics | STR |
.| Deception | CHA |
.| History | INT |
.| Insight | WIS |
.| Intimidation | CHA |
.| Investigation | INT |
.| Medicine | WIS |
.| Nature | WIS |
.| Perception | WIS |
.| Performance | CHA |
.| Persuasion | CHA |
.| Religion | INT |
.| Sleight of Hand | DEX |
.| Stealth | DEX |
.| Survival | WIS |

# Traits

`button-trait`


## Proficiencies

## Languages


# Actions

`button-action`

## Spells
Level |Spell Slots | Prepared Spells |
:---:|:---:|:---:|
\# |||
\# |||
 
 

# Equipment
CP | SP | EP | GP | PP |
:---:|:---:|:---:|:---:|:---:|
|||||

- 

# Personality
###### Personality Traits

###### Ideals

###### Bonds

###### Flaws

```

Image using the [D&D WOTC](https://publish.obsidian.md/hub/02+-+Community+Expansions/02.05+All+Community+Expansions/CSS+Snippets/All+Alternate+Themes+(ITS+Theme)#D D WOTC) Alternate Theme Snippet.

[![T-DnD--Character-Sheet.png](https://raw.githubusercontent.com/SlRvb/Obsidian--ITS-Theme/main/Images/Note-Showcase/T-DnD--Character-Sheet.png)](https://raw.githubusercontent.com/SlRvb/Obsidian--ITS-Theme/main/Images/Note-Showcase/T-DnD--Character-Sheet.png)