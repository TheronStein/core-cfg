INPUT[progressBar(class(red-progress-bar)):someProperty]

```c
interface ButtonConfig {
    label: string; // The text displayed on the button
    icon?: string; // An optional lucide icon to display on the button
    style: 'default' | 'primary' | 'destructive' | 'plain'; // The style of the button
    class?: string; // Optional CSS classes to add to the button. Multiple classes can be separated by spaces
    tooltip?: string; // Optional tooltip to display when hovering over the button. If not set, the label is used
    id?: string; // The optional id of the button, used for referencing the button in inline buttons
    hidden?: boolean; // Whether this button should be hidden, useful when only using the button in inline buttons
    action?: ButtonAction; // The action to perform when the button is clicked
    actions?: ButtonAction[]; // Optionally multiple actions can be performed when the button is clicked
}

requestLoadSnippets
style: primary
label: Meta Bind Help
id: help-button
action:
  type: command
  command: obsidian-meta-bind-plugin:open-faq
```



```meta-bind-button
label: Hide Mounts
icon: ""
hidden: false
class: hidemnts
tooltip: ""
id: hidemnts
style: primary
actions:
  - type: js
    file: "!1 WorkSpaces/Vault/Scripts/HideMounts.js"
    args: {}
```
    
