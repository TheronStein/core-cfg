# Run Multiple Commands in a Button Using QuickAdd and Macros

The number one request I get for Buttons is the ability to run multiple things with one button click. I'm looking into the best way to support that. In the meantime, there are two other community plugins that can run multiple commands: [QuickAdd](https://github.com/chhoumann/quickadd) and [Macros](https://github.com/phibr0/obsidian-macros). You can use these with Buttons to fulfill your multiple commands in a single click dreams.

Note: If you want to cycle through different commands when clicking a button multiple times then check out [Swap Buttons](https://github.com/shabegom/buttons#swap-button). They are a special type of Inline Button!

## Macros

[Macros](https://github.com/phibr0/obsidian-macros) is a community plugin that lets you chain together multiple commands from the command palette into a single command. It can be installed via the community plugin directory.

Creating a new Macro is really easy. Open Macros settings and click the + button. A modal will show up with some options:

![CleanShot 2021-08-13 at 14.37.21.png](https://publish-01.obsidian.md/access/aa4cdac5308d63d25e1b40e5575e1424/blog/obsidian/images/CleanShot%202021-08-13%20at%2014.37.21.png)

Let's make a simple Macro that creates a vertical split, opens my daily notes page, and pins the pane.

1. Give the Macro a descriptive name
2. Choose an appropriate icon
3. Delay: Sometimes you'll need a delay between each command execution. The default is 10 milliseconds. If the commands don't fire correctly, recreate the macro with a longer delay.
4. Add the commands! Notice that you can't save the Macro until you've added 2 or more commands.
5. Click the Create Macro button

Here's my DNP Split Macro:  
![CleanShot 2021-08-13 at 14.41.39.png](https://publish-01.obsidian.md/access/aa4cdac5308d63d25e1b40e5575e1424/blog/obsidian/images/CleanShot%202021-08-13%20at%2014.41.39.png)  
You can run a Macro directly from the Command Palette:  
![CleanShot 2021-08-13 at 14.44.32.png](https://publish-01.obsidian.md/access/aa4cdac5308d63d25e1b40e5575e1424/blog/obsidian/images/CleanShot%202021-08-13%20at%2014.44.32.png)  
If you want to learn how to use this Macro in a Button go to the [Combine with Buttons](https://shbgm.ca/blog/obsidian/quickadd-multi-buttons#Combine with Buttons) Section.

The QuickAdd community plugin can also create Macros. It is a more complex plugin with a bunch of additional features like inserting templates or text. Let's setup a macro in QuickAdd next.

## QuickAdd

[QuickAdd](https://github.com/chhoumann/quickadd) can do **a lot of things**. It can feel a bit overwhelming to get started. I highly recommend going through the examples in the github repo and playing around with all the features to get comfortable with this super powerful tool.

Why would you use QuickAdd instead of Macros? QuickAdd can run commands, but it can also insert text or templates into a note, or even create a new note from a template. For anyone who needs these advanced features, QuickAdd macros are great!

In the OMG Discord, user @Kippy wanted to make a button that ran a command and then added text to their current note.  
![CleanShot 2021-08-13 at 14.53.31.png](https://publish-01.obsidian.md/access/aa4cdac5308d63d25e1b40e5575e1424/blog/obsidian/images/CleanShot%202021-08-13%20at%2014.53.31.png)  
This isn't possible inside Buttons, but we can make a QuickAdd Macro that does this! Install QuickAdd and open the QuickAdd Settings. To add a Macro, click the Manage Macros button.  
![CleanShot 2021-08-13 at 14.55.05.png](https://publish-01.obsidian.md/access/aa4cdac5308d63d25e1b40e5575e1424/blog/obsidian/images/CleanShot%202021-08-13%20at%2014.55.05.png)  
In the Macro Manager input a name for your new Macro and click the Add Macro button.  
![CleanShot 2021-08-13 at 14.56.13.png](https://publish-01.obsidian.md/access/aa4cdac5308d63d25e1b40e5575e1424/blog/obsidian/images/CleanShot%202021-08-13%20at%2014.56.13.png)  
The new Macro will appear in the list of Macros. Click the Configure button to start editing what the Macro does. Macros in QuickAdd can do a bunch of different things!

1. Capture: display a prompt to enter some text, and insert that text into the current note. [For more on Capture, read the QuickAdd docs](https://github.com/chhoumann/quickadd/blob/master/docs/Choices/CaptureChoice.md).
2. Template: create a new note using a template. [For more on Template, read the QuickAdd docs](https://github.com/chhoumann/quickadd/blob/master/docs/Choices/TemplateChoice.md).
3. Delay: the clock button adds a configurable delay to the macro. This is so you can insert a pause in between actions.
4. Obsidian Command: run a command palette command
5. Editor Commands: cut/copy/paste commands to manipulate text in edit mode of a note
6. User Scripts: for power users to run custom JavaScript.
7. Choices: I'm honestly not sure what this is for! If someone tells me I'll update this tutorial...

To create the Pomodoro button that @Kippy wants, we'll need to use the Obsidian Command and Capture options.  
![CleanShot 2021-08-13 at 15.06.51.png](https://publish-01.obsidian.md/access/aa4cdac5308d63d25e1b40e5575e1424/blog/obsidian/images/CleanShot%202021-08-13%20at%2015.06.51.png)  
I typed in the Pomodoro command and hit Add, and clicked the Capture button. Notice how my Capture action is called "Untitled Capture Choice"? That's because I need to configure it still. I can do that by clicking the gear icon.

![CleanShot 2021-08-13 at 15.10.20.png](https://publish-01.obsidian.md/access/aa4cdac5308d63d25e1b40e5575e1424/blog/obsidian/images/CleanShot%202021-08-13%20at%2015.10.20.png)

1. To rename the Capture action you click on the title. This was tricky to find the first time!
2. Toggle Capture to active file in order to add text to the current note
3. Toggle Capture format to specify a specific format
4. Enter the text you want to insert  
    By default, capture displays a prompt to enter text, but because I've chosen Capture format and supplied custom text, it will just insert the specified text into the note.

These settings automatically save, so when you're done you can close the modal. One thing Capture can't do is insert the text at a specific line in the note (as far as I could tell). Maybe the plugin developer will add that option in the future!

Now that the QuickAdd macro is all setup, we're almost ready to trigger it with a button. The last step is to add it to the list of QuickAdd choices and enable it to appear in the command palette.  
![CleanShot 2021-08-13 at 15.16.46.png](https://publish-01.obsidian.md/access/aa4cdac5308d63d25e1b40e5575e1424/blog/obsidian/images/CleanShot%202021-08-13%20at%2015.16.46.png)

1. Enter a name (use the same name as the macro to keep it simple)
2. Choose Macro from the dropdown
3. Click the Add Choice button  
    Once the new choice is in the list, you need to set it to trigger the Macro we made. Click the gear icon and choose the appropriate macro.  
    ![CleanShot 2021-08-13 at 15.18.49.png](https://publish-01.obsidian.md/access/aa4cdac5308d63d25e1b40e5575e1424/blog/obsidian/images/CleanShot%202021-08-13%20at%2015.18.49.png)  
    Then click the lightning bolt icon. This makes that QuickAdd Choice show up as a command in the command palette.  
    ![CleanShot 2021-08-13 at 15.19.50.png](https://publish-01.obsidian.md/access/aa4cdac5308d63d25e1b40e5575e1424/blog/obsidian/images/CleanShot%202021-08-13%20at%2015.19.50.png)  
    Whew! Ok! Now we're ready to turn this into a Button. As you can see, QuickAdd is much more complex than the Macros plugin. WIth that added complexity comes more power that let's you add text, or templates into notes.

The next section will show you have to turn the macros into Buttons

## Combine with Buttons

The easiest way to make a new button is with the Button Maker. Open the command palette and choose the Button Maker command. This will pop up a WYSIWG modal to create your new button.

### Macros Button

![CleanShot 2021-08-13 at 15.23.57.png](https://publish-01.obsidian.md/access/aa4cdac5308d63d25e1b40e5575e1424/blog/obsidian/images/CleanShot%202021-08-13%20at%2015.23.57.png)

1. Give the Button a Name
2. Choose the Command type of Button
3. Select the Macros: DNP Split Command  
    You button codeblock should look like this:  
    ![CleanShot 2021-08-13 at 15.25.14.png](https://publish-01.obsidian.md/access/aa4cdac5308d63d25e1b40e5575e1424/blog/obsidian/images/CleanShot%202021-08-13%20at%2015.25.14.png)  
    When I click the Button, my multi-command macro runs. A new pane is split, my daily notes page opens and the pane gets pinned!  
    ![CleanShot 2021-08-13 at 15.27.44.gif](https://publish-01.obsidian.md/access/aa4cdac5308d63d25e1b40e5575e1424/blog/obsidian/images/CleanShot%202021-08-13%20at%2015.27.44.gif)

### QuickAdd Button

![CleanShot 2021-08-13 at 15.30.56.png](https://publish-01.obsidian.md/access/aa4cdac5308d63d25e1b40e5575e1424/blog/obsidian/images/CleanShot%202021-08-13%20at%2015.30.56.png)

1. Add the Button Name
2. Choose a Command type Button
3. Select the QuickAdd: Pomo Time command

The inserted button should look like:  
![CleanShot 2021-08-13 at 15.33.53.png](https://publish-01.obsidian.md/access/aa4cdac5308d63d25e1b40e5575e1424/blog/obsidian/images/CleanShot%202021-08-13%20at%2015.33.53.png)  
It's hard to show this Button in action, but it will pause the Pomodoro Timer and insert the text specified in the QuickAdd Macro. If you want the text inserted at a specific line, you could investigate building a Templater command that does this, or writing a custom JavaScript action.

## Conclusion

In this tutorial we built two multi-command Buttons. One was simple using the [Macros](https://github.com/phibr0/obsidian-macros) community plugin. The other was more powerful and used [QuickAdd](https://github.com/chhoumann/quickadd).

I'm not an expert in either of these plugins (especially QuickAdd), so if I did something wrong, or there are better approaches, let me know in the OMG Discord.

Catch y'all next time!