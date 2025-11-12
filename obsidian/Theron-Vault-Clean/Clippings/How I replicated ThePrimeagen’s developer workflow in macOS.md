---
title: "How I replicated ThePrimeagen’s developer workflow in macOS"
source: "https://linkarzu.com/posts/macos/prime-workflow/"
author:
  - "[[linkarzu]]"
published: 2025-03-22
created: 2025-04-10
description: "I watched a video about this guy called ThePrimeagen, and it changed the way I navigated my system and accessed my files"
tags:
  - "clippings"
---
## Contents

- [YouTube video](https://linkarzu.com/posts/macos/prime-workflow/#youtube-video)
- [What started all this?](https://linkarzu.com/posts/macos/prime-workflow/#what-started-all-this)
- [With my 55 inch TV, I thought I was productive](https://linkarzu.com/posts/macos/prime-workflow/#with-my-55-inch-tv-i-thought-i-was-productive)
- [Prime’s workflow requirements](https://linkarzu.com/posts/macos/prime-workflow/#primes-workflow-requirements)
- [i3 window manager](https://linkarzu.com/posts/macos/prime-workflow/#i3-window-manager)
	- [i3 WM prime config](https://linkarzu.com/posts/macos/prime-workflow/#i3-wm-prime-config)
	- [My i3 alternative in macOS](https://linkarzu.com/posts/macos/prime-workflow/#my-i3-alternative-in-macos)
	- [Bonus yabai tip](https://linkarzu.com/posts/macos/prime-workflow/#bonus-yabai-tip)
- [Tmux](https://linkarzu.com/posts/macos/prime-workflow/#tmux)
- [I can switch to tmux sessions from any app](https://linkarzu.com/posts/macos/prime-workflow/#i-can-switch-to-tmux-sessions-from-any-app)
- [Tmux session cleanup script](https://linkarzu.com/posts/macos/prime-workflow/#tmux-session-cleanup-script)
- [Vim telescope harpoon](https://linkarzu.com/posts/macos/prime-workflow/#vim-telescope-harpoon)
- [Be careful with the hyper key you choose](https://linkarzu.com/posts/macos/prime-workflow/#be-careful-with-the-hyper-key-you-choose)
- [Where can you find my config?](https://linkarzu.com/posts/macos/prime-workflow/#where-can-you-find-my-config)
- [Conclusion](https://linkarzu.com/posts/macos/prime-workflow/#conclusion)
- [If you like my content, and want to support me](https://linkarzu.com/posts/macos/prime-workflow/#if-you-like-my-content-and-want-to-support-me)
- [Discord server](https://linkarzu.com/posts/macos/prime-workflow/#discord-server)
- [Follow me on social media](https://linkarzu.com/posts/macos/prime-workflow/#follow-me-on-social-media)
- [All links in the video description](https://linkarzu.com/posts/macos/prime-workflow/#all-links-in-the-video-description)
- [How do you manage your passwords?](https://linkarzu.com/posts/macos/prime-workflow/#how-do-you-manage-your-passwords)

## YouTube video

![](https://www.youtube.com/watch?v=ckBs1Z9KCT4)

## What started all this?

- Just to add more context, the year was 2024, around April, it was like my 4th round trying vim motions, because I used Vim at the time in servers through SSH. I felt like a bitch when I used nano and I wanted to feel like one of them Vim chads.
- I was one day just doing watching `ma yutubs` I probably searched something related to vim, and this guy called ThePrimeagen showed up.
- I noticed he talked to a really understanding and kind lady named Karen, in which he expressed his concerns and he sometimes was called into her office, due to his inappropriate behavior.
- He talked fast and just cranked jokes out of nowhere, which made the experience like watching a Dave Chappelle stand-up tech tutorial, and I liked it
- Anyway, I ended up in this video by ThePrimeagen:
	- [My Developer Workflow - How I use i3, tmux, and vim](https://youtu.be/bdumjiHabhQ)

## With my 55 inch TV, I thought I was productive

- At the time, I used a 55 inch, 4K TV, as a monitor
- I spent like 3 years thinking I was at the peak of productivity, since I had so much space to organize all my apps.
- I had to use an app called Moom to configure the position of each one of the apps on the screen, I had slack on the top right, a bit below I had obsidian, in the middle my browser, etc.
- I had multiple macOS desktops, on desktop 1 I’d start a few apps, in desktop 2 other apps, etc.
- This meant that I had to decide which app would start on which macOS desktop. So every time I opened my mail app, I wanted it on the 2nd desktop, Obsidian on the 1st one, etc.
	- In macOS you do this by right clicking the app on the dock, then selecting the desktop in `Options - Assign to`
- So I moved my mouse and clicked on the desired app. I didn’t use the magnet app (this is an app that gives you sort of a tiling functionality). As I wanted the apps to overlap with other ones on the screen, and not have their dedicated space.
- So as you can read above, and now that I think about it (my stomach hurts) this was a nightmare I used to live in, I just didn’t know better.
- I was just an unbased macOS folk, using it the traditional way, and it was exhausting
- Just visually searching for the app I wanted to open, and then clicking on it, was really ineffective and I wasted a lot of time. I also had to remember: “Oh, I have mail on desktop 2 and Obsidian on desktop one”. But I was better (at least I thought so), because I swiped between desktops using my magic mouse (swiping with 2 fingers allows you to switch desktops)

## Prime’s workflow requirements

- In prime’s video above you’ll see that his requirements are:
	- Fast reacting when he presses a key
	- Get to where you want to go with as few keystrokes and mental overhead as possible
- His inspiration came from playing StarCraft, literally, decades ago, when he was young.

[![Image](https://linkarzu.com/assets/img/imgs/250322-kekw.avif)](https://linkarzu.com/assets/img/imgs/250322-kekw.avif)*kekw*

## i3 window manager

### i3 WM prime config

- **This is for navigating `between` different applications**
- You want to know what the experience is without a window manager, read the [With my 55 inch TV, I thought I was productive](https://linkarzu.com/posts/macos/prime-workflow/#with-my-55-inch-tv-i-thought-i-was-productive) section
- Prime has (or had) workspaces configured:
	- `alt+3` will take him to his terminal
	- `alt+2` for the browser
	- `alt+1` twitch and fun stuff
	- `alt+5` slack
	- `alt+6` gimp
	- `alt+7` VPN
	- `alt+9` utility windows
- The goal is getting to the app that you want without thinking and by just pressing a single keymap
- In the video he’s right about it’s not that great to set this up in macOS, as macOS usually has desktop animations, which means that when you transition between desktops there will be a slight delay
- But this is where I did things differently and you’ll see that in a little while

### My i3 alternative in macOS

- I noticed that prime keeps a single app on the screen at a time, and he’s also a monogamous man, what that means is that he uses a single monitor.
	- I don’t remember the video in which I saw this, if you find the video, please let me know so that I can reference it in this guide
- The i3 window manager is not available on macos, so I had to come up with a solution, and that’s how I met the `Yabai` window manager in macOS
- You’ll find several tutorials on YouTube about yabai, most of them organize applications in different spaces, but I don’t do that, I don’t want to think about where applications should live. I don’t want to move them around and waste any time on that at all
- So I keep all my application in a single macOS desktop, and all I do is to switch between them using keyboard shortcuts.
- Notice that I use hyper sub layers, and to switch between apps I use `a`, for example:
	- `hyper+a+j` -> The terminal
	- `hyper+a+k` -> The browser
	- `hyper+a+y` -> YouTube app
	- `hyper+a+f` -> Finder (macOS file explorer)
	- `hyper+a+d` -> Discord
	- And I have way more
- **This is pretty useful, as you don’t have to deal with any sort of animations, the switch is done instantly and you don’t rely on macOS desktops at all**

---

- To keep a single application on the screen I use Yabai, but I use it in `stack` mode.
- The other mode is `BSP` which partitions your screen, but this never made sense to me, because you fall in the exact same problem I’m running away from:
	- Organizing apps in different desktops, so if I want to have my terminal by itself, I have to make sure it starts in a desktop and nothing else starts there
- Yabai allows me to keep only one app on the screen and keep it maximized, so I don’t get distracted by other apps in the background, and I can focus on 1 thing at a time.
	- Yes, I used to think that having multiple monitors was the best thing for productivity, but I’ve proven to myself, that that’s not the case.
	- I’m faster using a single monitor, anyway, your eyes can only look at 1 thing at a time, right?
	- Another big reason I decided to go with a **single monitor**, is that when I worked on my laptop, I used to be way slower. Because I had to adapt my workflow to the small screen, so all my apps were piled in a really strange way, had to navigate with cmd+tab, so it was basically unmanageable
	- Now, I have the same setup on my desk computer and on my laptop, so it doesn’t matter which computer I’m on, I’ll be as efficient on either.
	- Yabai also allows me to set **transparency in some select apps**, which I cover in another video

---

- Pro tips:
	- I usually switch between 2 apps, let’s say my terminal and the browser. So to switch between the last 2 apps, **I always use cmd+tab**.
		- Here’s the pro tip, I created a keymap in karabiner-elements so that when I tap `left ctrl` it will send `cmd+tab`. If I leave `ctrl` pressed it will work as regular `ctrl`
	- I also tend to switch between 2 instances of the same app, let’s say I have 2 browser windows (not tabs), or 2 instances of the YouTube app, so to switch between those I use the cmd+\` macOS default keymap.
		- I think I learned this thanks to `Theo - t3․gg` (prime’s wife)
		- I dedicated a key on my keyboard as well that sends cmd+\` when I press it
	- Difficult to explain this in a written form, but I demo it in the video

---

- To learn how I do all my different mappings to switch between apps, change system settings, and way more, check out my karabiner-elements video:
	- [karabiner-elements configuration updates 2024](https://youtu.be/dqEiDVYRWLk)

---

- To learn how I use yabai in `stack` mode, how I set my terminal transparent, and overall how I do window management in macOS, check this video out:
	- [Yabai configuration updates 2024](https://youtu.be/9SQG5ogWEug)

### Bonus yabai tip

- Notice that I have a striped down version of my Neovim config running in kitty in a small window on the right-hand side.
- I called this “app” `skitty-notes` and it lives in the `right padding` section of yabai
- This padding section is like the “margin” section, and it’s not managed by yabai, so when I start kitty, I have a startup command that changes its size and sets its position to that section of the screen. This positioning is done with Yabai
- It’s basically a sticky notes app. The main reason I came up with it, is that it allows me to use vim motions to edit text
- I have a full tutorial on how to set it up, you can find it here:
	- [skitty-notes - Markdown Sticky Notes app in Neovim in the Kitty Terminal](https://youtu.be/M0B_24d0MWw)

## Tmux

- **This is for navigating `between` different projects**
- When specifically in the terminal, Prime needed to easily go to the projects he visits often with a single keymap
	- `prefix shift+j` -> vim with me project
	- It seems he mapped the tmux prefix to `ctrl+a`, the default is `ctrl+b`
- And fuzzy find (get a list) of all the other directories he accesses, but doesn’t get to that often `ctrl+f`
- When navigating to each one of these projects it will create a tmux session
- You can jump between sessions and your files will remain the way they were. Even if you close your terminal, re-open and run the `tmux attach` command you’ll get back to the sessions you had open before you quit
- You no longer have to `cd` around

---

- In my case I remapped the default tmux prefix key `ctrl+b` to `hyper+f`, but I rarely use it
- I created another hyper key sub layer `hyper+t` for my tmux sessions, so for example:
	- `hyper+t+j` -> my dotfiles
	- `hyper+t+u` -> my notes
	- `hyper+t+l` -> my blogpost
	- `hyper+t+h` -> my home session
- And for the not so used directories I use:
	- `hyper+t+n`
- I also created another little script that parses your `~/.ssh/config` file (I named it `tmux-sshonizer-agen` ), and I use another hyper sub layer `hyper+e` for that:
	- `hyper+e+j` -> `docker3` host
	- `hyper+e+k` -> `storage3` host
	- `hyper+e+u` -> `lb3` host
- Parse my `~/.ssh/config` file and show it in a fzf menu
	- `hyper+e+n`

---

- To switch between tmux sessions I’m using Prime’s tmux sessionizer script
- I explain everything in detail in the video below:
	- [Primeagen’s tmux-sessionizer and tmux-sshonizer-agen](https://youtu.be/MCbEPylDEWU)
- I would also highly recommend you to watch the karabiner-elements video shared above to understand my keymaps

## I can switch to tmux sessions from any app

- In the video you’ll notice that I don’t have to be in the terminal to execute the `hyper+t+j` or any other keymap
- This is because karabiner-elements, which is my keyboard mapper, calls BetterTouchTool, and then BetterTouchTool brings the terminal to the front and presses the tmux keys `prefix+key` to switch to the different sessions
- And karabiner-elements also directly switches to each application when executed
- All of this is covered in my `tmux-sessionizer` and `karabiner-elements` videos shared above

## Tmux session cleanup script

- If you open each different project in a new tmux sessions, and if you’re like me, you will probably end up with 20 or 25 tmux sessions.
- I don’t usually clean them up, and I end up with too many
- So I created a small script that I run every 2 hours, that cleans up sessions that have not been accessed for a bit less than 2 hours
- You can configure it every day or week, however you like
- The script can be found here: [linkarzu/tmuxKillSessions.sh](https://github.com/linkarzu/dotfiles-latest/blob/main/tmux/tools/linkarzu/tmuxKillSessions.sh)
- But I also created a video in which I set up everything from scratch, and since I use macOS I configure the `LauncAgent` (basically the cron job):
	- [Tmux Cleanup Session Script - Automatically Kill Unused Tmux Sessions](https://youtu.be/3axjsVR7QfA)

## Vim telescope harpoon

- **This is for navigating `inside` a project or codebase**
- Open telescope to search for files
- Harpoon the 3 or 4 files used the most

---

- I used telescope for a long time, but I recently switched to the snacks picker. Why? Short answer, for me, personally it feels snappier and it allows me to preview images in the preview window. It also includes the `frecency` feature I love so much that I had in telescope using the `telescope-frecency.nvim` plugin
- I do have harpoon installed, but I don’t use it like I should. This probably is because I don’t code too much, I’m more focused in markdown and technical documentation. But I do see the usefulness in a codebase where you need access to the same files over and over
- My preferred way of navigating when inside the terminal is using the **alternate buffer**, In my case I personally configured a keymap `<Leader>backspace` that takes me to the alternate buffer
- Also, I can quickly switch to the **alternate tmux session** by typing the `left_shift` key (I configure and demo this in my karabiner video)

---

- If you want to learn how to set up the snacks plugin [Why I’m Moving from Telescope to Snacks Picker - Why I’m not Using fzf-lua - Frecency feature](https://youtu.be/7hEWG3GP6m0)

---

- I also have a video in which I go over how I use harpoon: [Snipe vs Harpoon in Neovim](https://youtu.be/SuKhJlqGb5A)

## Be careful with the hyper key you choose

- I use keymaps for basically everything, for example
- To switch to all my apps:
	- The terminal `hyper+a+j`
	- The browser `hyper+a+k`
	- YouTube app `hyper+a+y`
- To open:
	- my [Raindrop Bookmarks (video)](https://youtu.be/ew9ItaL4zh8) in Raycast `hyper+r+j`
- To restart:
	- The [Yabai window manager (video)](https://youtu.be/9SQG5ogWEug) `hyper+u+o`
	- The [Ghostty terminal (video)](https://youtu.be/rCiq5CyFFhA) `hyper+u+g`
- To switch tabs in the browser `hyper+s+h` and `hyper+s+l`
- So when I started doing this, my hyper key was set to `caps lock`, you will see that recommendation in many tutorials and blogs, but I learned the hard way that it’s not the best option
- If you’ll be using a lot of keyboard mappings the way I do, you’ll be using your hyper key a lot. If you set it to `caps lock` your pinky will suffer and you will end up with forearm pain in the long run
- That’s why I switched my `hyper` key to the `right command` key, which now I press with my thumb
- **It does not matter if I’m on the glove80 or the regular laptop keyboard, the hyper key will be on my thumb**
- If you want to learn about all the different keymaps I use, I have a video in which I go over this in detail: [karabiner-elements configuration updates 2024 (video)](https://youtu.be/dqEiDVYRWLk)

## Where can you find my config?

- All of my config files and scripts are in [my dotfiles](https://github.com/linkarzu/dotfiles-latest)
- ⭐⭐⭐ If you like what you find there, consider giving them a star

## Conclusion

- Hopefully some day we’ll get an updated version of Prime’s developer workflow, as the video I used to get started is 3 years old
- It would be interesting to see what new tricks he has under his sleeve and grab some inspiration
- I love my new way of navigating around

## If you like my content, and want to support me

- If you want to share a tip, you can [donate here](https://ko-fi.com/linkarzu/goal?g=6)
- I recently was laid off, so if you know about any SRE related roles, please let me know

## Discord server

- My discord server is now open to the public, feel free to join and hang out with others
- join the [discord server in this link](https://discord.gg/NgqMgwwtMH)

[![Image](https://linkarzu.com/assets/img/imgs/250210-discord-free.avif)](https://discord.gg/NgqMgwwtMH)

- [Twitter (or “X”)](https://x.com/link_arzu)
- [LinkedIn](https://www.linkedin.com/in/christianarzu)
- [TikTok](https://www.tiktok.com/@linkarzu)
- [Instagram](https://www.instagram.com/link_arzu)
- [GitHub](https://github.com/linkarzu)
- [Threads](https://www.threads.net/@link_arzu)
- [OnlyFans 🍆](https://linkarzu.com/assets/img/imgs/250126-whyugae.avif)
- [YouTube (subscribe MF, subscribe)](https://www.youtube.com/@linkarzu)
- [Ko-Fi](https://ko-fi.com/linkarzu/goal?g=6)

## All links in the video description

- The following links will be in the YouTube video description:
	- Each one of the videos shown
	- A link to this blogpost

## How do you manage your passwords?

- I’ve tried many different password managers in the past, I’ve switched from `LastPass` to `Dashlane` and finally ended up in `1password`
- You want to find out why? More info in my article:
	- [How I use 1password to keep all my accounts safe](https://linkarzu.com/posts/1password/1password/)
- **If you want to support me in keeping this blogpost ad free, start your 1password 14 day free trial by clicking the image below**

[![Image](https://linkarzu.com/assets/img/imgs/250124-1password-banner.avif)](https://www.dpbolvw.net/click-101327218-15917064)

This post is licensed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/) by the author.Share