## Plugins

Obsidian does not have any native support or plugins to help with this, so we need to look at other options.

The first that came to mind was [the QuickAdd plugin for Obsidian](https://quickadd.obsidian.guide). After all, this is exactly the kind of thing that this plugin is designed to do. Personally, I have tried this plugin several times and I get what it can do, but the user interface has never clicked for me. Setting up entries, macros, etc. always felt unintuitive and at times confusing.

That being said, do take a look at it, and if it works for you, then you need read no further. Make the most of tapping into the power that plugin provides.

My alternative to this was to utilise one of my favourite Obsidian plugins, [Templater](https://silentvoid13.github.io/Templater/introduction.html). Using this plugin, you can build basic plugins of your own, and that is the path I went down. Admittedly, there was some effort involved in producing the initial set up, but the result now is that I have a flexible way of adding entries to other notes in the flow of work, and maybe you will too.


## The Script

To make the solution as flexible as possible, I created a script that I could reuse for a variety of different types of updates. Templater allows this script to be referenced in Templater templates that execute dynamic content, and so by passing it parameters to specify what I want it to do, I can build out the quick entry elements I need.

The principle the script takes is it will locate a file by name in the current Obsidian vault. It will then take the content and find the insertion point in the content based on a couple of pieces of data passed to it. The content is then rebuilt with the new content included at the insertion point and written back to the original note file.

The script is provided below and is heavily commented to help you understand how it works. You should save this as `addToNote.js` in your Templater scripts folder.

You can find out more about the overall structure of this script and get the gist of how it is utilised by reading the [Templater documentation page on user scripts](https://silentvoid13.github.io/Templater/user-functions/script-user-functions.html).

As noted above, there are a number of parameters that the script includes

|Parameter|Type|Description|
|---|---|---|
|`p_tp`|Templater Object|This should always be set as `tp` when calling the `addToNote()` function.|
|`p_strNoteBaseName`|String|This is the unique name of the note you wish to update.|
|`p_strSection`|String|This is the unique string in the note you wish to place your new text before or after.|
|`p_bAppend`|Boolean|This Boolean when set to `true` will cause the entered text to be added after the section string (append), or when set to `false`, before it (prepend).|
|`p_strPrefix`|String|This should be set to any string of text to prefix to any any entered text.|
|`p_strSuffix`|String|This should be set to any string of text to append to any any entered text.|
|`p_strPrompt`|String|This is the text that will be shown to the user in the prompt to enter text.|
|`p_strDefaultEntry`|String|This is the text that will be placed in the prompt for user text entry that the user can then modify.|
|`p_bMultiLine`|Boolean|This Boolean when set to `true` will provide a multi-line prompt for text entry, and when `false`, just a single line field.|

## Building an Example Template

My number one use case for this was to be able to insert a line into the “Activities” section of my daily note.

Taking the script above I can build a non-functioning template like this.

```
<%* await tp.user.addToNote(tp, {Note Base Name}, {Section}, {Append?}, {Prefix String}, {Suffix String}, {Prompt Label String}, {Default Prompt String}, {Multi-line?}); %>
```

It is non-functioning because the entries in curly braces (`{}` ) are just place holders for the actual information. So let’s take a look at each of them one by one. Note however that the first parameter is not a place holder - we always put `tp` in there.

### Parameters

#### Note Base Name

My daily note is titled as a typical date stamp with the year, month, and day are hyphenated in that order, and use the full year and leading zeros on the month and day. For example, today’s daily note would be a file with the name `2024-05-25.md`

Because this changes on a daily basis, in this instance I need to pass in a varying value for the file base name (the part without the `.md` file extension).

Templater includes access to a date module and so it is quite straight forward to produce a snippet of code that will return the date stamp in this format.

```
tp.date.now("YYYY-MM-DD")
```

#### Section

The section I want to enter content into is a section titled “## Activities”. It is not the first or last section in my daily note structure, so I need to think about this carefully. The script will insert the entered text before or after the section text. However, I want my entries adding at the ‘Activities’ section.

To do this I need to look at what the next section heading is. It happens to be “## Meetings/Calls”. To add to the end of the “## Activities” section, what I need to tell the script to do is to add the text before the following section - “## Meetings/Calls”.

Therefore, the section parameter should logically be the title of that section. Well, almost. You see I like to keep a blank line between those two sections so I need to account for that too. In order to do this, I am going to also include a newline token (`\n`) before the section name so it is looking for the section name **and** the blank line before it.

```
\n## Meetings/Calls
```

#### Append?

As noted for the previous parameter, what we need to do here is prefix the text in the section parameter. Is this an append? No. This is a prepend/prefix of the entered text.

The Append? parameter is therefore set to `false`.

#### Prefix String

Each of my daily note activity entries is a part of a Markdown bulleted list, so rather than typing this in each time, I can add a hyphen and a space into this parameter to address this. So the parameter is simply set to be `-` .

#### Suffix String

I don’t have a suffix to include each time, do for this parameter I can just specify an empty string.

#### Prompt Label String

The text for the prompt label above the text entry field is set to the following to describe what the user should enter.

```
Enter activity for daily note, it will be automatically bulleted.
```

_Note that the prompt label does not currently support newlines, so anything you have here needs to read well as a single paragraph/_

### Default Prompt String

When the prompt is displayed, the text entry field can be prepopulated, but I don’t have any need for that with this particular use case, and so I just set the string to be empty.

## Multi-line?

Because I am adding single bulleted entries, I do no require multi-line input and so this parameter is set to `false`. A single line text entry field will therefore be used.

### Final Template

Putting all of this together, I end up with the following template entry.

```
<%* await tp.user.addToNote(tp, tp.date.now("YYYY-MM-DD"), "\n## Meetings/Calls", false, "- ", "", "Enter activity for daily note, it will be automatically bulleted.", "", false); %>
```

The prompt is displayed and I can enter any text in it I like. For example, entering “lorem ipsum” will insert the text “- lorem ipsum” at the end of the ‘Activities’ section in my daily note.

![](https://www.thoughtasylum.com/assets/images/2024/2024-05-25-daily-note-activity-prompt.png)

## Additional Examples

Hopefully that gives you some ideas, but here are a few more examples to get you thinking about the possibilities.

### Event Log

This is similar to the activities logging, but instead adds a time based entry to the end of an ongoing “Event Log” file. The time entry is added in a standard format to the prompt to allow the user the option of modifying the timestamp.

```
<%* await tp.user.addToNote(tp, "Event Log", "", true, "", "", "Enter log entry.", tp.date.now("YYYY-MM-DD-HH.mm.ss") + ": ", false); %>
```

Note that because no section is provided and the append parameter is set to `true`, the content is logged at the end of the file.

![](https://www.thoughtasylum.com/assets/images/2024/2024-05-25-example-error-log.png)

### Reverse Clipboard Entries in Daily Note Section

This one is certainly a contrived example, but shows off several features. It goes back to updating my daily note. This time a section called “General Notes”, a level two Markdown heading. The template is set to append content to this section, but as an append with a section specified, every entry added is going to be immediately added after the section heading.

The template is set to add both a prefix and a suffix to the entered text. The suffix is a separator line and some newline characters. The prefix is a little more involved. It sets up a Markdown quote, inserts the content of the clipboard, and then a couple of newlines before the user entered text is included. This effectively inserts a quoted version of the clipboard in a sub section with your notes about the clipboard.

The text entry is set up with no default, but it is set to allow for multi-line text entry.

```
<%* await tp.user.addToNote(tp, tp.date.now("YYYY-MM-DD"), "## General Notes", true, `> "${await tp.system.clipboard()}"\n\n`, "\n\n---\n", "Enter notes about clipboard content.", "", true); %>
```

Like I say, this is a little contrived to show off a few features, but entering a bit of text about a third entry like this…

![](https://www.thoughtasylum.com/assets/images/2024/2024-05-25-multiline-entry.png)

… results in output in the relevant section of the daily note like this.

![](https://www.thoughtasylum.com/assets/images/2024/2024-05-25-multiline-result.png)

## Faster Access With Hotkeys

One final point is to note that if you have a template for quick entry that you use frequently and want quick access to it, you can set up a keyboard shortcut to trigger the template.

In the Templater plugin settings, add your template to the list of templates Templater exposes to Obsidian’s _Hotkeys_ section.

![](https://www.thoughtasylum.com/assets/images/2024/2024-05-25-template-hotkey.png)

Then, in the _Hotkeys_ section, locate your template and assign it a keyboard shortcut.

![](https://www.thoughtasylum.com/assets/images/2024/2024-05-25-hotkey.png)

## Conclusion

Hopefully that gives you some useful ideas about how you can utilise and tailor this approach to your own needs.

While the above may not sound as simple to apply as using the very popular QuickAdd plugin, I believe that there are some benefits in this approach.

1. I try with varying degrees of success not to overload my Obsidian vaults with plugins. I do strive to minimise the number to minimise the number of plugins to ensure I keep the vaults performant and as simple as possible. The fewer add ins, the fewer things there are to go wrong. How many times have you seen the interactions of third party plugins cause an issue for example?
2. This approach also allows me to tweak and tailor the solution as much as I care to. If say I wanted to modify the script to allow you to bypass the user prompt entirely and just feed in text, I can do that. If I wanted to create new notes in the background using this, I could do that too. Because the code is relatively straight forward and easily accessible within my vaults, I can quickly build it out in any way I might choose.
3. As previously noted, the QuickAdd plugin just didn’t gel for me, and because this is just some Templater scripting, which I am fairly comfortable with, this was just an easier mental fit for me.

It is also worth noting that the QuickAdd plugin can do other things that this script simply does not cater for. I simply have not had need to do those things yet, so that hasn’t tipped me over into needing the plugin.

I strongly suspect, and with any luck, I am not be the only Obsidian user who might find this approach useful. Regardless, my hope is that after reading this you will be enjoying quick entry from anywhere in your vault regardless of the solution you choose. No one has ever accused the Obsidian ecosystem of not offering its users choices.

**Author:** [Stephen Millard](https://www.thoughtasylum.com/authors/stephen_millard)

**Tags:** | [obsidian](https://www.thoughtasylum.com/tags/obsidian/) |

