# fox-choose

System for choosing default applications, programs, and utilities

Like `update-alternatives`, but local to user and more flexible. Requires a database of applications and their defaults at "${XDG_CONFIG_HOME:-$HOME/.config}/chooses/defaults"

## Summary

- Default application manager
  - Double click on file / launch with xdg-open, we control that
    - Abstract image/png, image/jpeg etc. behind 'image-viewer'. associate with single app at a time
- Default application exec
  - Execute command associated with utility (ex. 'image-viewer's)

## Installation

```sh
git clone https://github.com/eankeen/choose
cd choose

./choose.sh set
```

- CHOOSE_DB_DIR
  - by default at `$XDG_CONFIG_HOME/choose/db`

# Folder Structure

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
