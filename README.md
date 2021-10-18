# fox-choose

System for choosing default applications, programs, and utilities

Like `update-alternatives`, but local to user and more flexible. Requires a database of applications and their defaults at `"${XDG_CONFIG_HOME:-$HOME/.config}/chooses/defaults"`

## Summary

- Default application manager
  - Double click on file / launch with xdg-open, we control that
    - Abstract image/png, image/jpeg etc. behind 'image-viewer'. associate with single app at a time
- Default application exec
  - Execute command associated with utility (ex. 'image-viewer's)

## Installation

Use [Basalt](https://github.com/hyperupcall/basalt), a Bash package manager, to install this project globally

```sh
basalt global add hyperupcall/choose
```

## Environment Variables

- CHOOSE_DB_DIR
  - by default at `$XDG_CONFIG_HOME/choose/db`

## Folder Structure

The author's config can be found [here](https://github.com/hyperupcall/dots/tree/main/user/.config/choose/db)
- db

  - terminal-emulator

    - alacritty
    - kitty
      - launch.sh
      - set.sh
      - get.sh
    - termite

    - launch.sh
    - set.sh
    - get.sh

  - image-viewer

## TODO

- 'get' subcommand
- use choose when using fuzzer / filter (dmenu vs rofi -dmenu, etc.)
- application categories standardizable?
- new command
- sourcing pre-exec does does output on --verbose flag (or another)
