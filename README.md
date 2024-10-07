
# Apex-Anti-Recoil

An AutoHotKey script (works on multiple resolutions) to minimize recoil with auto weapon detection for Apex Legends.

This script was designed to run using KeySharp 0.0.0.7 (not AHK). Download it here: [KeySharp Download](https://bitbucket.org/mfeemster/keysharp/downloads/)

## How to start the script

To run this script, use the following command in your Windows terminal (make sure to run as admin):

```
Keysharp.exe gui.ahk
```

Or using full Path:

```
"C:\Program Files\Keysharp\Keysharp.exe" "C:\Users\yourusername\Downloads\Apex-Anti-Recoil\gui.ahk"
```

### Note

Alternatively you can run the `run_apexmaster.bat`, make a shortcut to your Desktop then right click on the shortcut -> go to `Show more options` -> `Properties` -> `Shortcut` -> `Advanced` -> `Run as administrator` -> `Ok` -> `Ok` then you will be able to run it straight from your desktop.

## Current Settings

Below are the settings and their descriptions:

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
- `error_level`: Set to `error` to save log error logs, `info` to save all the logs.
- `UUID`: Your universally unique identifier.
- `superglide`: If you want shift + c to trigger the superglide.

### [trigger settings]
- `trigger_only`: Set to `1` if you want the script to only activate on trigger press, `0` for it to be always active.
- `trigger_button`: The key that activates the script (e.g., `Capslock`).

## Don't forget this

After you run it once and it's all working as expected, make sure debug is disabled using the `gui.ahk` UI or set to `0` in the `gui.ahk` and `apexmaster.ahk` files, otherwise your debug file will get really large really soon.

## My Changes

- Reorganized and removed some stuff
- Updated original AHK to work using KeySharp
- Added Devo and R99 to supply for the new season and updated the pattern
- Moved UUID to settings.ini
- Created a UUID function to help creating a new UUID and not use the python script
- Auto Fire is back (use with caution, working with hemlock and r301)
- Added charged up rampage logic
- Fixed turbocharger devo logic
- Fixed Hemlock/3030 logic
- Improved E pick up was blocking the mouse
- Fixed B (change weapon mode) logic
- Fixed Sheila

## Previous Changes by Lew29

- Updated Patterns
- Removed everything related to the gold optics aimbot
- Fixed Alternator not having an `ALTERNATOR_PIXELS`
- Renamed "Sella" to "Sheila" (not sure why it was like this anyway)
- Removed Wingman
- Add superglide macro (press and hold C with shift)

## Todo

- Improve recoil further
- Add Gold Optics back

## Special Thanks

Thanks to Lew29 for the changes made from the original `mgsweet/Apex-NoRecoil-2021` fork that saved me heaps of time to get this together.
Also thanks to mgsweet and all the original contibutors to the `mgsweet/Apex-NoRecoil-2021` fork that made this happen.

Happy Days!