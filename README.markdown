# Dotfiles

## Application

### Terminal

```
Font: Menlo
Font size: 14
Width: 100
Height: 40
Only show 'Active process name'
Cursor: block (blink)
Close if the shell exited cleanly
Declare terminal as: xterm-256color
```


### Sublime Text 2

```
cd ~/Library/Application\ Support/Sublime\ Text\ 2/Packages/
git clone git://github.com/kemayo/sublime-text-2-git.git Git
```

```
cd ~/Library/Application\ Support/Sublime\ Text\ 2/Packages/
git clone git@github.com:jisaacks/GitGutter.git
```

```javascript
// Settings in here override those in "Default/Preferences.sublime-settings", and
// are overridden in turn by file type specific settings.
{
  "auto_complete_commit_on_tab": true,
  "color_scheme": "Packages/User/Railscasts.tmTheme",
  "font_size": 15.0,

  "tab_size": 2,
  "translate_tabs_to_spaces": true,

  "word_wrap": false,
  "rulers": [80],
  "highlight_line": true,

  "draw_white_space": "all",
  "trim_trailing_white_space_on_save": true,

  "hot_exit": false,
  "remember_open_files": false,

  "tree_animation_enabled": false
}
```
