---
title: "Tmux and Vim — even better together"
source: "https://smartbear.com/blog/tmux-and-vim/"
author:
published:
created: 2025-04-10
description: "There are numerous benefits of using tmux. The benefits I discussed there are independent of one’s choice of text editor. But if you’re a vim user, the benefits of tmux reach even further. One of the best aspects of tmux is that it unlocks the potential for a more powerful vim-based development environment, allowing vim …"
tags:
  - "clippings"
---
![Tmux and Vim — even better together](https://imagedelivery.net/PVooPtpJE-25QaNkbEuXvw/e4f50fc1-1d59-4ce1-3003-55dccf0ff100/gamma=0)

There are numerous benefits of using tmux. The benefits I discussed there are independent of one’s choice of text editor. But if you’re a vim user, the benefits of tmux reach even further. One of the best aspects of tmux is that it unlocks the potential for a more powerful vim-based development environment, allowing vim and the shell to feel more like a single cohesive tool.

In this post we’ll look at a few ways of customizing tmux and vim to help get more done with less typing and context switching. Configuring tmux and vim to get the exact behavior you want can be a time consuming endeavor, but in my view it’s worth it. Over the last few years of using tmux and vim together, I’ve found a few tips and plugins that have really stood out. This post is a collection of those essential tips that have become indispensable parts of my development workflow.

If you’re just getting started with tmux and vim, see the related reading section for links to some resources to get you up to speed.

### Moving around vim and tmux

### Seamless navigation

As a general goal, I want to be able to use vim-style movements and text editing patterns whether I’m in vim or some other tmux pane.

In vim, we use [splits](http://blogs.sourceallies.com/2009/11/vim-splits-an-introduction/) to divide up the current view, allowing us to edit several files side by side, or even to edit multiple regions of a single file without having to scroll around. Similarly, tmux’s [panes](http://blogs.sourceallies.com/2009/11/vim-splits-an-introduction/) allow us to divide up our window so we can run and view several terminal based commands and programs at the same time.

I’m constantly using vim splits, so being able to move between splits efficiently is crucial. By default, if you want to move from one split to another, vim requires that you hit `ctrl-W` and then one of the directional keys (i.e. h, j, k, l).This isn’t as efficient as it could be, especially for such a common operation.

To address this, like many vim users, I edited my `.vimrc` to [simplify split navigation](https://robots.thoughtbot.com/vim-splits-move-faster-and-more-naturally#easier-split-navigations), so that I can jump between vim splits using `ctrl-j`, `ctrl-k`, etc. This is already a great efficiency win. With tmux in the picture, we can use [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator) to not only set up these vim key bindings, but also to set up similar key bindings for tmux pane navigation. This allows us to use `ctrl-<direction>` to move anywhere in our tmux window, whether we’re jumping between vim splits or tmux panes.

### Customizing tmux navigation behavior

You may find yourself wanting to customize these navigation key bindings in programs other than vim.

For example, recently I’ve been using the command line fuzzy finder [fzf](https://github.com/junegunn/fzf) quite a lot. Out of the box, fzf supports `ctrl-k` and `ctrl-j` for moving up and down its list of search matches. Unfortunately, this won’t work if you’re using vim-tmux-navigator’s [suggested](https://github.com/christoomey/vim-tmux-navigator#add-a-snippet) key bindings in your `.tmux.conf`, which are as follows:

```bash
is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
    | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"
bind-key -n C-h  if-shell  "$is_vim"  "send-keys C-h"  "select-pane -L"
bind-key -n C-j   if-shell  "$is_vim"  "send-keys C-j"   "select-pane -D"
bind-key -n C-k  if-shell  "$is_vim"  "send-keys C-k"  "select-pane -U"
bind-key -n C-l   if-shell  "$is_vim"  "send-keys C-l"   "select-pane -R"
bind-key -n C-\   if-shell  "$is_vim"  "send-keys C-\\"  "select-pane -l"
```

This bit of configuration works by adding conditional logic to the `ctrl-<direction>` key bindings. When one of these movement commands is used, it checks if the current tmux pane is running vim. If so, the appropriate vim split navigation command is sent. Otherwise, the appropriate tmux pane navigation command is sent.

Using a slightly different approach, we can add logic so that tmux will treat fzf like it treats vim, sending fzf its own internal navigation commands rather than tmux’s pane navigation commands.

```bash
is_vim="ps -o state= -o comm= -t '#{pane_tty}' \ 
| grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"
is_fzf="ps -o state= -o comm= -t '#{pane_tty}' \
  | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?fzf$'"
bind -n C-h run "($is_vim && tmux send-keys C-h) || \
                          tmux select-pane -L"
bind -n C-j run "($is_vim && tmux send-keys C-j)  || \
                         ($is_fzf && tmux send-keys C-j) || \
                         tmux select-pane -D"
bind -n C-k run "($is_vim && tmux send-keys C-k) || \
                          ($is_fzf && tmux send-keys C-k)  || \
                          tmux select-pane -U"
bind -n C-l run  "($is_vim && tmux send-keys C-l) || \
                          tmux select-pane -R"
bind-key -n C-\if-shell "$is_vim" "send-keys C-\\" "select-pane -l"
```

Using this general pattern in your `.tmux.conf`, you can further customize vim-tmux-navigator’s behavior to work nicely with any command line utilities that use vim-style navigation.

The following demonstrates how you can move around vim splits, tmux panes, and fzf results all using `ctrl-<direction>`.

![](https://imagedelivery.net/PVooPtpJE-25QaNkbEuXvw/423025e7-15fe-457a-cb69-8e4312b03b00/gamma=0)

It’s worth noting that you don’t need to do this just to use vim-tmux-navigator and fzf together. In addition to `ctrl-j` and `ctrl-k`, fzf supports `ctrl-n` and `ctrl-p` for navigating search results. It even has a `--bind` option for setting custom fzf key bindings. But, if you specifically want to maximize the versatility of the `ctrl-j`, `ctrl-k`, etc. bindings across several applications running in tmux, this pattern will help.

Tmux and bash both have support for vi modes, which can help make your shell feel more like your editor. This is great because it means that when you move from a vim pane to a shell pane, you don’t have to do as big of a context switch. Many of the same patterns for moving around and working with text can still apply.

You can use tmux’s [vi mode](https://sanctum.geek.nz/arabesque/vi-mode-in-tmux/) to make tmux’s copy mode feel more like vim. In this mode you can use familiar vim commands to scroll, search, select, and copy text.

Similarly, you can try bash’s [vi editing-mode](http://www.catonmat.net/blog/bash-vi-editing-mode-cheat-sheet/).Being able to use vi style movements and character matching commands to quickly edit shell commands is really nice. Suddenly writing shell commands in bash and lines of code in vim begin to feel a lot more similar. Also, if you find yourself editing a complex shell command and you want to jump into vim for real, just enter normal mode and hit `v`. This will drop you into vim, where you can finish editing your command, writing this file will bring you back to the shell and execute the command.

It’s common practice for vim users to remap custom keys to escape, so we can [avoid reaching](http://vim.wikia.com/wiki/Avoid_the_escape_key) so far every time we change from insert to normal mode. For example, I’m using the sequence `kj` to bring me out of insert mode. In order for bash’s vi mode to feel comfortable, it’s important to be able to use your familiar mapping to go from insert to normal mode on the command line.

This can be configured in your `~/.inputrc` file. In my case, to make `kj` work,I’ve added the following:

```bash
set editing-mode vi 
‍
# vi settings 
$if mode=vi 
    set keymap vi-insert 
    "kj" # remap escape
$endif
```

### Simplify vim split and tmux pane creation

Splits and panes are both foundational concepts and should be really easy to use. We’ve already covered standardizing the way we move between splits and panes, but what about creating them in the first place?

I’m not a big fan of tmux’s defaults for a working with panes for a few reasons. First, if you’re already familiar with vim split terminology, the words horizontal and vertical will mean the opposite of what you’d expect when it comes to tmux panes. And second, the default commands ( `<Prefix>%` and `<Prefix>"` ) for creating tmux splits never seemed intuitive to me.

I’m using on the following in my `.tmux.conf`:

```bash
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"
```

The beauty of this is that it allows you to continue thinking about splits and panes in terms of the orientation of the divider, the same way you’d think about a vim split. With these bindings, `<Prefix>|` adds a vertical pane divider (like a vertical split in vim), and `<Prefix>-` adds a horizontal one. If I remember correctly, I first saw these bindings recommended in the book [Tmux: Productive Mouse-FreeDevelopment](https://pragprog.com/book/bhtmux/tmux), which is full of great tmux tips and really worth a read.

In vim, I primarily use vertical splits. So I’ve set the following in my `.vimrc` which means that from normal mode, creating a new vertical split is as simple as hitting `vv`.

```bash
" vv to generate new vertical split
nnore map <silent> vv <C-w>v
```

Splits and panes are excellent features, so the most important thing is to find key bindings that make them quick and intuitive for you to use.

### Quickly run shell commands without leaving vim

Using what we’ve already covered, we now have the ability to quickly create tmux panes and move between them, running commands where we wish. Easy as this is, it’s sometimes preferable to create a pane and run a command in it without leaving vim at all.

I use [vimux](https://github.com/benmills/vimux) and its associated plugins to run terminal commands from inside vim.

### Vimux essential commands

One of the basic features of vimux is its ability to run an arbitrary shell command from within vim. Once vimux is installed, you can access the command prompt from within vim by running `:VimuxPromptCommand`. You can then immediately start typing your shell command. Pressing enter will run the command in a tmux pane in the current window. If necessary, vimux will create a new pane for the command to run in.

Typing `:VimuxPromptCommand` every time you want to run a command isn’t the best, so it’s recommended to add a mapping to your `.vimrc` like the following:

```bash
" Prompt for a command to run
map <Leader>vp :VimuxPromptCommand<CR>
```

Now, from normal mode you’ll be able to type `<Leader>vp` to bring up the prompt and issue commands, as shown here.

![](https://imagedelivery.net/PVooPtpJE-25QaNkbEuXvw/acecc528-e942-4b1b-861f-1f34c9bb3200/gamma=0)

That’s already useful, especially for running tests, builds, or data processing scripts. In many cases, especially for tests, you’ll find yourself wanting to run a shell command, make some code changes, and then run the shell command again.

```bash
" Run last command executed by VimuxRunCommand
map <Leader>vl :VimuxRunLastCommand<CR>
```

Now, from normal mode `<Leader>vl` will rerun the most recent vimux command. This really shines when it comes to running tests.

### On running tests with vimux

Vimux is especially helpful when you have a failing test that you are trying to fix. The workflow looks like this:

1. Locate the failing test, read it, and run it
2. Make changes to the application code to get the test passing
3. Rerun the last test (i.e. that last vimux command) using `<Leader>vl`
4. Repeat steps 2 and 3 until the test passes

Using this workflow, it’s possible to more efficiently get a failing test passing, all without ever leaving vim. Quickly rerunning the last test command is especially helpful.

When possible, consider using a vimux [platform-specific-plugin](https://github.com/benmills/vimux#platform-specific-plugins). These provide support for running the currently focused test in a test file, running all the tests in the current file, etc.

### Quickly copying vimux output

Let’s say you want to scroll through or copy a bit of output from the vimux pane. You could use `ctrl-<direction>` to move from vim to the vimux pane, then you’d enter tmux’s copy mode using `<prefix>`. That’s a bit involved. Fortunately, vimux offers a shortcut for this workflow.

Add the following to your `.vimrc`:

```bash
" Inspect runner pane
map <Leader>vi :VimuxInspectRunner<CR>
```

Now `<Leader>vi` is all you need to jump from vim into the vimux pane, already in copy mode. From here, you can use [vi style movements](https://sanctum.geek.nz/arabesque/vi-mode-in-tmux/) as mentioned earlier, to move around, select text, and copy it to the clipboard.

### Getting a better look at vimux output

Sometimes, especially when looking at test output on a laptop screen, it can be a little cumbersome to read long lines in a small pane. There are all sorts of ways you can efficiently resize your panes with tmux, but in this case, I’ve found vimux’s zoom feature to be a big help. If you haven’t used zoom before, it’s a tmux feature that maximizes the active pane to fill the space of the entire tmux window. When you’re done zooming, you’ll return to the previous pane arrangement you had before. More info on tmux zoom can be found [here](https://sanctum.geek.nz/arabesque/zooming-tmux-panes/). I’ve mapped vz to the vimux command which will zoom in on the tmux runner pane.

```bash
" Zoom the tmux runner pane
<leader>vz :VimuxZoomRunner<CR>
```

Now, you can run your tests with one vimux command, and if you need to, zoom in on the results with `<Leader>vz`. Typically, at this point in order to leave the zoomed mode, you’d have to use tmux’s `<Prefix>z`, and that’ll work just fine. But, if you’re using vim-tmux-navigator as mentioned above, you can also use the `ctrl-<direction>` commands to exit the zoom mode as well.

### Going faster with chords

I use vimux commands a lot. So much so, that using leader-prefixed commands like I’ve described above (e.g., `<Leader>vl` ) began to feel inefficient. ~3 keystrokes is too much for an action that has become so central to my vim workflow.

In practice, I’ve set up [vim chords](https://github.com/kana/vim-arpeggio) for common use cases like running a single test, running all the tests in a file rerunning the last command etc. If you haven’t given chords a try, I’d highly recommend it. Anytime the leader key starts feeling more like a speed bump than a shortcut, I start asking whether I should use a chord. Vim chords can be mapped to whatever functionality you like, but personally I use them almost exclusively for vimux bindings.

Here’s a basic example, showing a simple workflow for fixing a failing test. This combines several of the elements discussed so far:

- The test is originally run using a chord mapped to [vimux-ruby’s](https://github.com/pgr0ss/vimux-ruby-test) `RunRubyFocusedTest` test method. The chord is effectively a single keystroke.
- The vim split navigation is done using `ctrl-l`
- Subsequent test runs are done using another chord that reruns the last vimux command.
![](https://imagedelivery.net/PVooPtpJE-25QaNkbEuXvw/9908a4d1-686a-49e7-904e-8179f59adf00/gamma=0)

### Final thoughts

Over the last few years, tmux and vim together with these customizations and practices, have formed the basis of a really enjoyable development environment for me. This post covers just a few of the many possible ways to configure tmux and vim to get even more out of both.

The underlying principle here is about seeking efficiency. When practical, we should reduce the keystrokes and the cognitive load required to do common bits of work. Whether you use vim and tmux or not, it’s worth considering the intent behind these tips as it applies to your own development tools. I hope you find the process as fun as I have.

Are you developing an application? Whether it’s web, mobile, or anything else, your users deserve a great digital experience. Insight Hub offers [performance monitoring](https://smartbear.com/insight-hub/performance-monitoring/), [error monitoring](https://smartbear.com/insight-hub/error-monitoring/), and [app stability](https://smartbear.com/insight-hub/) solutions so you can make sure your app stays up and running at the highest level of quality for your users.

You can try Insight Hub [free for 14 days](https://app.bugsnag.com/user/new/), no credit card required. You can also contact us to [check out a demo](https://www.bugsnag.com/demo-request/).

Many thanks to [Bram Moolenaar](http://www.moolenaar.net/), [Chris Toomey](https://github.com/christoomey), [Ben Mills](https://github.com/benmills), and [Junegunn Choi](https://github.com/christoomey) for their thoughtful comments on earlier versions of this post and more importantly for their invaluable open-source contributions.

- [vim + tmux: A Perfect Match](https://teamgaslight.com/blog/vim-plus-tmux-a-perfect-match)
- [Thoughtbot’s tmux course](https://thoughtbot.com/upcase/tmux)
- [What are some good resources for learning vim?](https://www.quora.com/What-are-some-good-resources-for-learning-Vim/answer/Abhinay-Dronavalli)

———