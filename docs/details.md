# Details

To use `choose`, you need a directory structure

Given a `CHOOSE_DB_DIR` variable of `~/db`, layout a structure like the following

```txt
db
 - <category-name-1>
   - <application-name-1>
     - launch.sh
   - <application-name-2>
     - launch.sh
```

For example...

```txt
db
 - window-manager/
   - _.current
   - awesome/
     - launch.sh
   - i3/
     - launch.sh
 - menu-bar/
   - _.current
   - lemonbar/
     - launch.sh
   - xmobar/
     - launch.sh
```
