# fox-choose

System for choosing default applications, programs, and utilities

Like `update-alternatives`, but local to user and more flexible. Requires a database of applications and their defaults at "${XDG_CONFIG_HOME:-$HOME/.config}/fox-defaults/defaults"

## Summary

-  Default application manager
   -  Double click on file / launch with xdg-open, we control that
      -  Abstract image/png, image/jpeg etc. behind 'image-viewer'. associate with single app at a time
-  Default application exec
   -  Execute command associated with utility (ex. 'image-viewer's)

## Installation

```sh
git clone https://github.com/eankeen/fox-default
cd fox-default

./fox-default.sh set
```

## TODO

match completion for new 'set' features
TODO: move foo.current to foo/.current

# TODO: fox-default for selection chooser / filter thing
