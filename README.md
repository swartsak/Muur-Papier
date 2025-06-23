# Muur-Papier
A place to share cool wallpapers.
Let's try and keep resolution high, 1920x1080 and 2560x1440 should be the lower bounds
This is an example of a cool wallpaper:

![Feet_Drawing](https://github.com/user-attachments/assets/38784589-da33-444b-aa51-894f6a461568)

[**Sauce**](https://myanimelist.net/anime/16782/Kotonoha_no_Niwa)

## How to change wallpapers using yazi
This was tested for `Yazi 25.5.31`.

1. Install yazi:
    - The latest release:
    ```sh 
    pacman -S yazi
    ```
    - The bleeding edge development version. You will need to compile it on your machine and thus this command will install rust for you! This is a bit bloated for most people I reckon:
    ```sh 
    paru -S yazi-git
    ```
2. Create the [keymap config file](https://github.com/sxyazi/yazi/blob/shipped/yazi-config/preset/keymap-default.toml) at `$XDG_CONFIG_HOME/yazi/keymap.toml`. You don't need to populate this with anything.
3. Add the following to `$XDG_CONFIG_HOME/yazi/keymap.toml`:
```toml 
[[mgr.prepend_keymap]]
on = "w"
run = 'shell --orphan -- swww img -t none "$@"'
desc = "Change this image to the current wallpaper"
for = "linux"
```
If your wallpaper backend is different than swww, you can just insert the command after the `shell --orphan --` part. For instance with `Gnome` you can rebind this to work with `<C-w>` (control w):

```toml 
[[mgr.prepend_keymap]]
on = "<C-w>"
run = 'shell --orphan -- gsettings set org.gnome.desktop.background picture-uri-dark "file://$@"'
desc = "Change this image to the current wallpaper"
for = "linux"
```
