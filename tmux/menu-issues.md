## Status Line Issues.

The text of the context mode "󰙀 TMUX" is literally at the edge of the screen almost out of view, can you add a spacer before it? can you also add a space after the text and add an angled divider between that and the sessssion name.

# TMUX Menu Issues

## Major Issue

1. All menu options labeled with "Browse" and "File Explorer" invoke a floating window with yazi inside of it, this currently crashed the entire TMUX server when invoked as yazi throws an error. I think yazi is initialized too fast, i'm not entirely aware of what the issue is. We need to do one of the following:
   1. get rid of these functions completely and come up with different behavior for ease of access into configuration directories.
   2. Fix the behavior which will also probably require us to expand the yazi with another plugin or custom code to handle this specific use case.

Considering we're aiming for yazi to be integrated with the yazibar plugin, I think I want to approach this by coming up with a new handling method for ease of access configuration navigation. I think it would be better to have the popup menu simply start a new window/shell in a "configs" session with the window label named after the tool, this will give me a sense of state persistence when editing/modifying configuation files in a popup window so i'm not having to constantly reinitialize the files I want to modify every time I want to make a change. This will also give me the ability to have multiple configuration windows open at the same time if I want to modify multiple files at the same time.

So for all of the menu options that invoke a floating tmux window for configuration, I want to have one window for that tool that does not close after I close out of the floating window. When I close out of the floating window it should exit out of the neovim instance as accumulating a multitude of neovim instances will consume resources overtime especially as they idle over time.

I almost think that all of the neovim sessions invoked with this method should use the custom session integration we have into neovim automatically, without question everytime, it should save the session name as something like "tmux-window-session-toolname" so that way it invokes the same session on launch and it will always save the session when exiting the neovim instance.

We have a lot of these configuration menus that show files that I can open, I think it should simply be "Edit Config" for each tool which will pop me back up into that session. Thinking about it that way, there might not even be a reason to keep the window active after I close out of the floating window if I'm just going to load back into the same neovim session.

## Other Issues

There is major redundancy in the current TMUX menu we have, here are the notes I've taken down for each menu:

### TMUX Menu

- #### TMUX Main Menu
  1. Remove Prefix Mode
  2. Move commands inside of inspect.
  3. Move the `Kill Server` option into the manage menu.

- ##### Panes Menu
  - Get rid of `Navigate to Next/Previous window` options, we already have easy keybinds for this type of navigation
  - Update all of the FZF pickers to use a preview located at the top, it gives a better view of the panes i'm interacting with, there's no point in having so much dead space being utilized.

- ##### Windows Menu
  - Get rid of `Navigate Switch/Next/Previous/Last window` options, again we already have easy keybinds for this type of navigation
  - Integrate a FZF Picker into the `Move To Session` option instead of having it prompt me for the session name.

- ##### Sessions Menu
  - Conslidate the different sections, just keep all of the session actions under one section, get rid of the state persistence section and move it into the `Manage Menu`.

##### Inspect Menu

##### Configure Menu

    We'e going to completely get rid of this menu, the options here can be consolidated into other menus.
        - Edit Options Section -> `Inspect Menu` (From what it looks like to me this entire section is already inside of the inspect menu (Options by scope sub section)
        - Quick Settings -> `Manage Menu`
        - Ignore the rest of the menu options, they will be handled else where.

- ## Manage Menu
  - Remove
