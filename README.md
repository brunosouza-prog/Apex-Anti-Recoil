
# Apex-Anti-Recoil

An AutoHotKey script (works on multiple resolutions) to minimize recoil with auto weapon detection for Apex Legends.

This script was designed to run using KeySharp 0.0.0.7 (not AHK). Download it here: [KeySharp Download](https://bitbucket.org/mfeemster/keysharp/downloads/)

To run this script, use the following command in your Windows terminal (make sure to run as admin):

```
[KEYSHARP_INSTALLATION_PATH]\Keysharp.exe [ANTI-RECOIL-SCRIPT-PATH]\apexmaster.ahk
```

For example:

```
"C:\Program Files\Keysharp\Keysharp.exe" "C:\Users\yourusername\Downloads\Apex-Anti-Recoil\apexmaster.ahk"
```

Thanks to Lew29 for the changes made from the original `mgsweet/Apex-NoRecoil-2021` fork that saved me heaps of time to get this together.

## Note

Before running the script, make sure to modify the `settings.ini` file to match your current game setup. Below are the settings and their descriptions:

### [screen settings]
- `resolution`: Set this to your in-game resolution (e.g., `1920x1080`).
- `colorblind`: The colorblind mode you are using in Apex (e.g., `Normal`, `Protanopia`, `Deuteranopia`, `Tritanopia`).

### [mouse settings]
- `sens`: The sensitivity value that matches your in-game sensitivity.
- `zoom_sens`: The sensitivity when aiming down sights (ADS).
- `auto_fire`: Set this to `1` to enable auto fire, `0` to disable. NOTE: Currently not working.
- `ads_only`: Set this to `1` to apply recoil control only when ADS, `0` to apply it always.

### [other settings]
- `debug`: Set to `1` to enable debug mode for troubleshooting, `0` to disable.

### [trigger settings]
- `trigger_only`: Set to `1` if you want the script to only activate on trigger press, `0` for it to be always active.
- `trigger_button`: The key that activates the script (e.g., `Capslock`).


## My Changes

- Reorganized and removed some stuff
- Updated original AHK to work using KeySharp
- Added Devo and R99 to supply for the new season and updated the pattern

## Previous Changes by Lew29

- Updated Patterns
- Removed everything related to the gold optics aimbot
- Fixed Alternator not having an `ALTERNATOR_PIXELS`
- Renamed "Sella" to "Sheila" (not sure why it was like this anyway)
- Removed Wingman

## Todo

- Improve recoil further
- Bring back the rapid-fire feature and fix any issues with it
- Fix Sheila
- Add superglide macro (press and hold C with shift)
