# Dotfiles

## Application

### Terminal

```
Font: Menlo
Font size: 14pt
Width: 100
Height: 40
Only show 'Active process name'
Cursor: block (blink)
Close if the shell exited cleanly
Declare terminal as: xterm-256color
```


### Sublime Text 3

#### Packages

Install package control from here: https://sublime.wbond.net/installation

```
Backbone.js
Better CoffeeScript
Git
GitGutter
GoSublime
Theme - Spacegray
```

#### Settings

```javascript
// Settings in here override those in "Default/Preferences.sublime-settings", and
// are overridden in turn by file type specific settings.
{
  "auto_complete_commit_on_tab": true,
  "theme": "Spacegray.sublime-theme",
  "color_scheme": "Packages/Theme - Spacegray/base16-ocean.dark.tmTheme",
  "draw_white_space": "all",
  "font_size": 16,
  "highlight_line": true,
  "hot_exit": false,
  "ignored_packages":
  [
    "Vintage"
  ],
  "remember_open_files": false,
  "rulers":
  [
    80
  ],
  "tab_size": 2,
  "translate_tabs_to_spaces": true,
  "tree_animation_enabled": false,
  "trim_trailing_white_space_on_save": true,
  "word_wrap": false
}
```
