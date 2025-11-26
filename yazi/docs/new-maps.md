# Yazi Keybindings Quick Reference

## Navigation
| Key | Action |
|-----|--------|
| `i` / `k` | Up / Down |
| `Ctrl+i` / `Ctrl+k` | Half page up/down |
| `I` / `K` | Full page up/down |
| `j` / `l` | Parent dir / Enter dir |
| `J` / `L` | Back / Forward history |
| `gg` | Jump to top |
| `G` | Jump to bottom |
| `go` | Jump to path (type it) |
| `gj` | Jump to character |
| `gh` | Go home (~) |
| `gc` | Go to ~/.config |
| `gd` | Go to ~/Downloads |
| `gf` | Follow symlink |
| `gr` | Go to git root |

## Find / Search
| Key | Action |
|-----|--------|
| `ff` | Fuzzy find file/directory |
| `fd` | Search by filename (fd) |
| `fr` | Search file contents (ripgrep) |
| `fz` | Jump via zoxide |
| `fi` | Filter files in current dir |
| `fe` / `fq` | Find next/previous match |
| `fc` | Cancel search |
| `E` / `Q` | Next/prev found result |

## File Operations
| Key | Action |
|-----|--------|
| `o` | Open file |
| `O` / `Enter` | Open with... |
| `ee` | Rename file |
| `ea` | Rename (cursor at end) |
| `ec` | Create file/directory |
| `ed` / `d` | Trash file |
| `eD` | Delete permanently |
| `el` | Symlink (relative) |
| `eL` | Hardlink |
| `.` | Toggle hidden files |

## Copy / Yank / Paste
| Key | Action |
|-----|--------|
| `cc` / `y` | Yank/copy files |
| `cx` / `x` | Cut files |
| `cp` | Copy file path |
| `cd` | Copy directory path |
| `cf` | Copy filename |
| `cn` | Copy name without extension |
| `pp` | Paste files |
| `pf` | Paste (overwrite) |
| `ps` | Symlink yanked files |
| `pP` | Smart paste into hovered dir |
| `Y` / `X` | Cancel yank |

## Selection
| Key | Action |
|-----|--------|
| `v` | Enter visual mode |
| `V` | Enter visual mode (unset) |
| `Space` | Toggle selection |
| `Tab` | Spot/preview file |
| `Ctrl+a` | Select all |
| `Ctrl+r` | Invert selection |

## Tabs
| Key | Action |
|-----|--------|
| `t` | New tab (current dir) |
| `T` | New tab (home) |
| `[` / `]` | Previous/next tab |
| `{` / `}` | Swap tab left/right |
| `1-9` | Switch to tab 1-9 |

## Bookmarks (b prefix)
| Key | Action |
|-----|--------|
| `bf` | Fuzzy search bookmarks |
| `bj` | Jump bookmark (fzf) |
| `bJ` | Jump bookmark (key) |
| `bs` | Bookmark current dir |
| `bS` | Bookmark hovered file/dir |
| `bt` / `bT` | Temporary bookmark |
| `br` | Rename bookmark (fzf) |
| `bR` | Rename bookmark (key) |
| `bd` | Delete bookmarks (fzf) |
| `bD` | Delete bookmark (key) |

## Projects (P prefix)
| Key | Action |
|-----|--------|
| `Ps` | Save current project |
| `PS` | Save & quit |
| `Pl` | Load project |
| `PL` | Load last project |
| `Pd` | Delete project |
| `PDA` | Delete all projects |
| `Pm` | Merge current tab |
| `PM` | Merge all tabs |

## SSH / Remote (S prefix)
| Key | Action |
|-----|--------|
| `Sm` | Mount & jump to remote |
| `Su` | Unmount SSHFS |
| `Sj` | Jump to mount |
| `Sa` | Add SSH host |
| `Sr` | Remove SSH host |
| `Sh` | Go to mount home |
| `Sc` | Go to ~/.ssh/ |
| `Ss` | SSHFS menu |

## Rsync (r prefix)
| Key | Action |
|-----|--------|
| `rc` | Rsync to default server |
| `rs` | Rsync (custom) |

## Root/Sudo (R prefix)
| Key | Action |
|-----|--------|
| `Rp` / `RP` | Sudo paste |
| `Rr` | Sudo rename |
| `Rls` / `Rlr` / `Rlh` | Sudo link operations |
| `Rc` | Sudo create |
| `Rd` / `RD` | Sudo trash/delete |

## Archive/Compress (z prefix)
| Key | Action |
|-----|--------|
| `zc` | Compress files |
| `zx` | Extract with ouch |
| `zh` | Previous btrfs snapshot |
| `zl` | Next btrfs snapshot |
| `ze` | Exit snapshot browsing |

## Preview Controls (u prefix)
| Key | Action |
|-----|--------|
| `ut` | Toggle tree/list preview |
| `u-` | Increase tree depth |
| `u_` | Decrease tree depth |
| `us` | Toggle follow symlinks |
| `uh` | Toggle hidden in preview |
| `ugi` | Toggle gitignore |
| `ugs` | Toggle git status |
| `um` | Preview markdown (glow) |

## Utilities
| Key | Action |
|-----|--------|
| `m` | Toggle file tag/mark |
| `M` | Clear all tags |
| `mc` | Change permissions (chmod) |
| `di` | Diff selected files |
| `vs` | Show disk usage |
| `vh` | Directory history (fzf) |
| `sk` | Send via KDE Connect |
| `sr` | Restore from trash |
| `Gc` | Show Git changes |
| `gl` | Open lazygit |
| `;` | Shell command |
| `:` | Shell (blocking) |
| `pc` | Yazi command prompt |

## Sorting (, prefix)
| Key | Action |
|-----|--------|
| `,m` / `,M` | Sort by modified time |
| `,b` / `,B` | Sort by birth time |
| `,e` / `,E` | Sort by extension |
| `,a` / `,A` | Sort alphabetically |
| `,n` / `,N` | Sort naturally |
| `,s` / `,S` | Sort by size |
| `,r` | Sort randomly |

## Linemode (\ prefix - rarely used)
| Key | Action |
|-----|--------|
| `\s` | Linemode: size |
| `\p` | Linemode: permissions |
| `\b` | Linemode: birth time |
| `\m` | Linemode: modified time |
| `\o` | Linemode: owner |
| `\n` | Linemode: none |

## System
| Key | Action |
|-----|--------|
| `` ` `` | Task manager |
| `~` / `F1` | Help |
| `q` | Quit |
| `Q` | Quit (no cwd-file) |
| `Ctrl+c` | Close tab / Cancel |
| `Esc` | Exit mode / Cancel |

## Tips
- **Hidden files**: Toggle with `.` - you have them ON by default
- **Archives**: Can browse into them (auto-extracts to tmp)
- **Tags/Marks**: Use `m` to mark files, `M` to clear all marks
- **Tree preview**: Use `u-`/`u_` to control depth dynamically
- **Btrfs snapshots**: Use `zh`/`zl` to browse, `ze` to exit
- **Quick jump**: `go` lets you type a path directly
