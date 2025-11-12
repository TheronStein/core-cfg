These are mini templates utilized by the [DnD Character Sheet](https://publish.obsidian.md/hub/03+-+Showcases+%26+Templates/Templates/TTRPG+notes/DnD+Character+Sheet) Template to easily add multiple traits/actions with formatting already in place.

These use the [buttons](https://publish.obsidian.md/hub/02+-+Community+Expansions/02.05+All+Community+Expansions/Plugins/buttons) plugin to insert the template using `^button-name` on other templates. I usually have 1 note with a whole list of button codeblock to point to for my other templates that use [buttons](https://publish.obsidian.md/hub/02+-+Community+Expansions/02.05+All+Community+Expansions/Plugins/buttons).

###### Trait

````markdown
```button
name Add Trait
type prepend template
action Path/To/Trait Template
```
^button-trait
````

```markdown
###### Trait
**Description of trait**

- Bullet list of what traits do
```

###### Actions

````markdown
```button
name Add Action
type prepend template
action Path/To/Actions Template
```
^button-action
````

```markdown
###### Name

Type | To Hit | Hit | Reach | Targets |
---|:---:|:---:|---|:---:|
**==Weapon/Feat Type==** |||||
```