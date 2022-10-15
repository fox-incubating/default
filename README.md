# choose

System for choosing default applications, programs, and utilities

The default application selector to rule them all

## Use Cases

Like `update-alternatives`, but local to user and more flexible. Requires a database of applications and their defaults at `"${XDG_CONFIG_HOME:-$HOME/.config}/chooses/defaults"`

1. Launch with file

Control which applications are selected when opening a file. This works irrespective of the desktop environment. `xdg-open` falls flat because it doesn't work with directories. Furthermore, different applications can be configured to work in a different context (X, Terminal emulator, Linux console).

Since these are just shell scripts, arbitrary arguments should be supported, like `--column` and `--row` for example, if using a text editor.

2. Launch without file

The current 'Browser' or 'Image Viewer' can be launched. Again, this is intended to work across distributions and user interfaces.

See more info in [details.md](./docs/details.md)

## Roadmap

- 'get' subcommand
- use choose when using fuzzer / filter (dmenu vs rofi -dmenu, etc.)
- sourcing pre-exec does does output on --verbose flag (or another)
- GUI selector (select via GUI if there are multiple options), optional
- doctor command to ensure that git config attributes, ranger attributes, etc. are all valid and point to choose properly
- before launch dialog, have UI where can download the application with help of (woof?)

## Application / Category Attributions

- cli vs tui vs gui
- use on conditions (only X11, wayland, etc. have fallback (ordering))
- launching vs shell (interactive, non-interactive), DE (.desktop, etc.), tty vs ptty etc.
- an editor vs viewer
- ones meant to generalize across application vs choosing a specific thing (without last common denominator cli argument flags, etc. compatability)
  - capability based?
- printing to stdout, running a blocking application, running a non-blocking application, exec'ing into a new process, and running a daemon
- execution helpers (if it requires a terminal, must wrap it in terminal invocation)
