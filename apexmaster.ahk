; environment settings
#Requires AutoHotkey v2.0
#MaxHotkeysPerInterval 99000000
#HotkeyInterval 99000000
#KeyHistory 0
#SingleInstance force
#MaxThreadsBuffer on
#Persistent
ProcessSetPriority "A"
ListLines 0
SetWorkingDir A_ScriptDir
SetKeyDelay -1, -1
SetMouseDelay -1
SetDefaultMouseSpeed 0
SetWinDelay -1
SetControlDelay -1
SendMode "Input"
CoordMode "Pixel", "Screen"

; default variables
global version := "1.0.0"
global resolution := "1920x1080"
global colorblind := "Normal"
global sens := "5.0"
global zoom_sens := "1.0"
global auto_fire := "0"
global ads_only := "1"
global debug := "0"
global error_level := "error"
global trigger_only := "0"
global trigger_button := "Capslock"
global show_tooltip := "0"
global tempFilePath := A_ScriptDir "\debug_log.txt"
global hMod, hHook
global UUID := GenerateUUID() ; Start with a random UUID

; weapon type constant, mainly for debug
global DEFAULT_WEAPON_TYPE := "DEFAULT"
global R99_WEAPON_TYPE := "R99"
global R301_WEAPON_TYPE := "R301"
global FLATLINE_WEAPON_TYPE := "FLATLINE"
global SPITFIRE_WEAPON_TYPE := "SPITFIRE"
global LSTAR_WEAPON_TYPE := "LSTAR"
global DEVOTION_WEAPON_TYPE := "DEVOTION"
global DEVOTION_TURBO_WEAPON_TYPE := "DEVOTION TURBO"
global VOLT_WEAPON_TYPE := "VOLT"
global HAVOC_WEAPON_TYPE := "HAVOC"
global HAVOC_TURBO_WEAPON_TYPE := "HAVOC TURBO"
global NEMESIS_WEAPON_TYPE := "NEMESIS"
global NEMESIS_CHARGED_WEAPON_TYPE := "NEMESIS CHARGED"
global PROWLER_WEAPON_TYPE := "PROWLER"
global HEMLOK_WEAPON_TYPE := "HEMLOK"
global RE45_WEAPON_TYPE := "RE45"
global ALTERNATOR_WEAPON_TYPE := "ALTERNATOR"
global P2020_WEAPON_TYPE := "P2020"
global RAMPAGE_WEAPON_TYPE := "RAMPAGE"
global G7_WEAPON_TYPE := "G7"
global CAR_WEAPON_TYPE := "CAR"
global P3030_WEAPON_TYPE := "3030"
global SHOTGUN_WEAPON_TYPE := "SHOTGUN"
global SNIPER_WEAPON_TYPE := "SNIPER"
global PEACEKEEPER_WEAPON_TYPE := "PEACEKEEPER"
global SHEILA_WEAPON_TYPE := "SHIELA"

; x, y pos for weapon1 and weapon 2
global WEAPON_1_PIXELS, WEAPON_2_PIXELS

; weapon color
global LIGHT_WEAPON_COLOR := "0x7D542D" ;0x2D547D
global HEAVY_WEAPON_COLOR := "0x386B59" ;0x596B38
global ENERGY_WEAPON_COLOR := "0x5A6E28" ;0x286E5A
global SUPPY_DROP_COLOR_NORMAL := "0xB20137" ;0x3701B2
global SUPPY_DROP_COLOR_PROTANOPIA := "0xB24A71" ;0x714AB2
global SUPPY_DROP_COLOR_DEUTERANOPIA := "0xB22019" ;0x1920B2
global SUPPY_DROP_COLOR_TRITANOPIA := "0x902E31" ;0x312E90
global SUPPY_DROP_COLOR := SUPPY_DROP_COLOR_NORMAL

global colorblind

global SHOTGUN_WEAPON_COLOR := "0x6B2007" ;0x07206B
global SNIPER_WEAPON_COLOR := "0x4B408F" ;0x8F404B
global SHEILA_WEAPON_COLOR := "0xA13CA1" ;NO CHANGES

; Declare global variables without loading the pixel data
global R99_PIXELS, ALTERNATOR_PIXELS, R301_PIXELS, P2020_PIXELS, RE45_PIXELS, G7_PIXELS, SPITFIRE_PIXELS
global FLATLINE_PIXELS, PROWLER_PIXELS, RAMPAGE_PIXELS, P3030_PIXELS, CAR_PIXELS
global DEVOTION_PIXELS, HAVOC_PIXELS, VOLT_PIXELS, NEMESIS_PIXELS
global HEMLOK_PIXELS, LSTAR_PIXELS, HAVOC_TURBOCHARGER_PIXELS, DEVOTION_TURBOCHARGER_PIXELS
global NEMESIS_FULL_CHARGE_PIXELS, SINGLE_MODE_PIXELS, PEACEKEEPER_PIXELS, CHARGED_MODE_PIXELS

global DEFAULT_PATTERN = ["0,0,0"]

; weapon detection
global current_pattern := DEFAULT_PATTERN
global current_weapon_type := DEFAULT_WEAPON_TYPE
global current_weapon_num := 0
global peackkeeper_lock := false
global is_single_mode := false

; Declare global variables without loading the patterns
global R301_PATTERN, R99_PATTERN, P2020_PATTERN, RE45_PATTERN, G7_PATTERN, SPITFIRE_PATTERN, ALTERNATOR_PATTERN
global DEVOTION_PATTERN, TURBODEVOTION_PATTERN, HAVOC_PATTERN, VOLT_PATTERN, NEMESIS_PATTERN, NEMESIS_CHARGED_PATTERN
global CAR_PATTERN, FLATLINE_PATTERN, RAMPAGE_PATTERN, RAMPAGEAMP_PATTERN, PROWLER_PATTERN, P3030_PATTERN
global LSTAR_PATTERN, HEMLOK_PATTERN, HEMLOK_SINGLE_PATTERN, SHEILA_PATTERN

; Clear the debug log file at the start of the script
if (FileExist(tempFilePath)) {
    FileDelete(tempFilePath)
}
; Recreate an empty log file
FileAppend("Script Version "version "`n", tempFilePath)

; First, read the settings from the ini file
ReadIni()

; To avoid any issues, lets regenerate the UUID since it was moved into the settings.ini
if (UUID == "") {
    UUID := GenerateUUID()  ; Regenerate UUID
}

; Make sure it run as admin
RunAsAdmin()

; Check if user is using colorblind mode and set the right color
if (colorblind == "Protanopia") {
    SUPPY_DROP_COLOR := SUPPY_DROP_COLOR_PROTANOPIA
} else if (colorblind == "Deuteranopia") {
    SUPPY_DROP_COLOR := SUPPY_DROP_COLOR_DEUTERANOPIA
} else if (colorblind == "Tritanopia") {
    SUPPY_DROP_COLOR := SUPPY_DROP_COLOR_TRITANOPIA
}

; Load the weapon pixel data
LoadWeaponPixels()

; Set the mouse sensitivity setting now that the ini was loaded
zoom := 1.0/zoom_sens
global modifier := 4/sens*zoom

; Load the weapon patterns
LoadWeaponPatterns()

; Declare the weapon_check_map globally so it's initialized once
global weapon_check_map := {
    "light_weapon_color": [
        {weapon: "R301", pixels: R301_PIXELS, pattern: R301_PATTERN},
        {weapon: "R99", pixels: R99_PIXELS, pattern: R99_PATTERN},
        {weapon: "P2020", pixels: P2020_PIXELS, pattern: P2020_PATTERN},
        {weapon: "RE45", pixels: RE45_PIXELS, pattern: RE45_PATTERN},
        {weapon: "ALTERNATOR", pixels: ALTERNATOR_PIXELS, pattern: ALTERNATOR_PATTERN},
        {weapon: "CAR", pixels: CAR_PIXELS, pattern: CAR_PATTERN},
        {weapon: "G7", pixels: G7_PIXELS, pattern: G7_PATTERN},
        {weapon: "SPITFIRE", pixels: SPITFIRE_PIXELS, pattern: SPITFIRE_PATTERN}
    ],
    "heavy_weapon_color": [
        {weapon: "FLATLINE", pixels: FLATLINE_PIXELS, pattern: FLATLINE_PATTERN},
        {weapon: "PROWLER", pixels: PROWLER_PIXELS, pattern: PROWLER_PATTERN},
        {weapon: "RAMPAGE", pixels: RAMPAGE_PIXELS, pattern: RAMPAGE_PATTERN, charged_pattern: RAMPAGEAMP_PATTERN},
        {weapon: "CAR", pixels: CAR_PIXELS, pattern: CAR_PATTERN},
        {weapon: "HEMLOK", pixels: HEMLOK_PIXELS, pattern: HEMLOK_PATTERN, single_mode: HEMLOK_SINGLE_PATTERN},
        {weapon: "3030", pixels: P3030_PIXELS, pattern: P3030_PATTERN}
    ],
    "energy_weapon_color": [
        {weapon: "VOLT", pixels: VOLT_PIXELS, pattern: VOLT_PATTERN},
        {weapon: "DEVOTION", pixels: DEVOTION_PIXELS, pattern: DEVOTION_PATTERN, turbo_pixels: DEVOTION_TURBOCHARGER_PIXELS, turbo_pattern: TURBODEVOTION_PATTERN},
        {weapon: "HAVOC", pixels: HAVOC_PIXELS, pattern: HAVOC_PATTERN, turbo_pixels: HAVOC_TURBOCHARGER_PIXELS},
        {weapon: "NEMESIS", pixels: NEMESIS_PIXELS, pattern: NEMESIS_PATTERN, charged_pattern: NEMESIS_CHARGED_PATTERN},
        {weapon: "LSTAR", pixels: LSTAR_PIXELS, pattern: LSTAR_PATTERN}
    ],
	"sheila_weapon_color": [
        {weapon: "SHIELA", pattern: SHEILA_PATTERN},
	]
}

; Now hide the process
HideProcess()

~$*E Up::
~$*WheelDown::
~$*1::
~$*2::
~$*R::
    Sleep(100)
    DetectAndSetWeapon()
return

~$*B Up::
    Sleep(1000)
    DetectAndSetWeapon()
return

~$*3::
    Reset()
return

~$*G Up::
    Reset()
return

~$*Z::
    Sleep(600) ; @TODO Make sure Shiela ult is working properly
    if IsShiela() {
        SetShiela()
    } else {
        Reset()
    }
return

~End::
	ExitSub()
return

~$*LButton::
{
    try {
        MoveMouse()
    } catch {
        LogMessage("Error occurred during LButton hotkey handler.", "error")
    }
}

RunAsAdmin() {
    LogMessage("RunAsAdmin called.")
    
    if (A_IsAdmin) {
        LogMessage("Already running as Admin.")
        return 0
    }
	
	MsgBox("v"version " - Run the script as administrator.")

    ExitSub()
}

GenerateUUID() {
    characters := "0123456789abcdef"  ; Hexadecimal characters
    uuid := ""
    
    ; Generate the random UUID with hyphen positions at 9, 14, 19, 24
    Loop 8
        uuid .= SubStr(characters, Random(1, 16), 1)
    Loop 4
        uuid .= SubStr(characters, Random(1, 16), 1)
    Loop 4
        uuid .= SubStr(characters, Random(1, 16), 1)
    Loop 4
        uuid .= SubStr(characters, Random(1, 16), 1)
    Loop 12
        uuid .= SubStr(characters, Random(1, 16), 1)
    
    return uuid
}

ReadIni() {
    global resolution, colorblind, zoom_sens, sens, auto_fire, ads_only, debug, error_level, trigger_only, trigger_button, version, UUID ; Make sure it's visible
    
    iniFilePath := A_ScriptDir "\settings.ini"
    
    LogMessage("Checking if settings.ini exists at: " iniFilePath)
    
    if (!FileExist(iniFilePath)) {
        LogMessage("settings.ini not found. Creating a new one.")
        IniWrite("1920x1080", iniFilePath, "screen settings", "resolution")
        IniWrite("Normal", iniFilePath, "screen settings", "colorblind")
        IniWrite("5.0", iniFilePath, "mouse settings", "sens")
        IniWrite("1.0", iniFilePath, "mouse settings", "zoom_sens")
        IniWrite("1", iniFilePath, "mouse settings", "auto_fire")
        IniWrite("0", iniFilePath, "mouse settings", "ads_only")
        IniWrite("0", iniFilePath, "other settings", "debug")
        IniWrite("error", iniFilePath, "other settings", "error_level")
        IniWrite(GenerateUUID(), iniFilePath, "other settings", "UUID")
        IniWrite("0", iniFilePath, "trigger settings", "trigger_only")
        IniWrite("Capslock", iniFilePath, "trigger settings", "trigger_button")
        LogMessage("New settings.ini file created.")
    } else {
		error_level := ReadIniValue(iniFilePath, "other settings", "error_level")
        debug := ReadIniValue(iniFilePath, "other settings", "debug")
		UUID := ReadIniValue(iniFilePath, "other settings", "UUID")
        resolution := ReadIniValue(iniFilePath, "screen settings", "resolution")
        colorblind := ReadIniValue(iniFilePath, "screen settings", "colorblind")
        zoom_sens := ReadIniValue(iniFilePath, "mouse settings", "zoom_sens")
        sens := ReadIniValue(iniFilePath, "mouse settings", "sens")
        auto_fire := ReadIniValue(iniFilePath, "mouse settings", "auto_fire")
        ads_only := ReadIniValue(iniFilePath, "mouse settings", "ads_only")
        trigger_only := ReadIniValue(iniFilePath, "trigger settings", "trigger_only")
        trigger_button := ReadIniValue(iniFilePath, "trigger settings", "trigger_button")
        LogMessage("resolution=" resolution)
        LogMessage("colorblind=" colorblind)
        LogMessage("zoom_sens=" zoom_sens)
        LogMessage("sens=" sens)
        LogMessage("auto_fire=" auto_fire)
        LogMessage("ads_only=" ads_only)
		LogMessage("debug=" debug)
        LogMessage("error_level=" error_level)
        LogMessage("UUID=" UUID)
        LogMessage("trigger_only=" trigger_only)
        LogMessage("trigger_button=" trigger_button)
    }
}

; Helper function to read INI values with fallback and logging
ReadIniValue(iniFilePath, section, key) {
    try {
        value := IniRead(iniFilePath, section, key)
        LogMessage("IniRead success for " key ": " value)
    } catch {
        LogMessage("IniRead failed for " key ". Attempting manual file read.")
        value := ManualIniRead(iniFilePath, section, key)
        if (value != "")
            LogMessage("Manual read success for " key ": " value)
        else
            LogMessage("Manual read failed for " key, "error")
    }
	
    ; Remove extra quotation marks and ensure the value is returned as a string
    return Trim(StrReplace(value.ToString(), '"'))
}

LoadWeaponPixels() {
	; Make sure the variables are visible in this function
	global R99_PIXELS, ALTERNATOR_PIXELS, R301_PIXELS, P2020_PIXELS, RE45_PIXELS, G7_PIXELS, SPITFIRE_PIXELS
	global FLATLINE_PIXELS, PROWLER_PIXELS, RAMPAGE_PIXELS, P3030_PIXELS, CAR_PIXELS
	global DEVOTION_PIXELS, HAVOC_PIXELS, VOLT_PIXELS, NEMESIS_PIXELS
	global HEMLOK_PIXELS, LSTAR_PIXELS, HAVOC_TURBOCHARGER_PIXELS, DEVOTION_TURBOCHARGER_PIXELS
	global NEMESIS_FULL_CHARGE_PIXELS, SINGLE_MODE_PIXELS, PEACEKEEPER_PIXELS, CHARGED_MODE_PIXELS
	global WEAPON_1_PIXELS, WEAPON_2_PIXELS
    LogMessage("Loading weapon pixels...")
	
	; x, y pos for weapon1 and weapon 2
	WEAPON_1_PIXELS := LoadPixel("weapon1")
	WEAPON_2_PIXELS := LoadPixel("weapon2")

    ; Load light weapon pixels
    R99_PIXELS := LoadPixel("r99")
	ALTERNATOR_PIXELS := LoadPixel("alternator")
    R301_PIXELS := LoadPixel("r301")
    P2020_PIXELS := LoadPixel("p2020")
    RE45_PIXELS := LoadPixel("re45")
    G7_PIXELS := LoadPixel("g7")
    SPITFIRE_PIXELS := LoadPixel("spitfire")

    ; Load heavy weapon pixels
    FLATLINE_PIXELS := LoadPixel("flatline")
    PROWLER_PIXELS := LoadPixel("prowler")
    RAMPAGE_PIXELS := LoadPixel("rampage")
    HEMLOK_PIXELS := LoadPixel("hemlok")
    P3030_PIXELS := LoadPixel("p3030")

    ; Load special weapon pixels
    CAR_PIXELS := LoadPixel("car")

    ; Load energy weapon pixels
    DEVOTION_PIXELS := LoadPixel("devotion")
    DEVOTION_TURBOCHARGER_PIXELS := LoadPixel("devotion_turbocharger")
    HAVOC_PIXELS := LoadPixel("havoc")
    HAVOC_TURBOCHARGER_PIXELS := LoadPixel("havoc_turbocharger")
    NEMESIS_PIXELS := LoadPixel("nemesis")
    NEMESIS_FULL_CHARGE_PIXELS := LoadPixel("nemesis_full_charge")
    VOLT_PIXELS := LoadPixel("volt")
    LSTAR_PIXELS := LoadPixel("lstar")
	
    ; Load Nemesis full charge and single mode pixels
    SINGLE_MODE_PIXELS := LoadPixel("single_mode")
	
    ; Load Rampage charged mode pixels
	CHARGED_MODE_PIXELS := LoadPixel("rampage_charged")

    ; Load shotgun pixels
    PEACEKEEPER_PIXELS := LoadPixel("peacekeeper")

    LogMessage("Weapon pixels loaded successfully.")
}

LoadWeaponPatterns() {
	; Make sure the variables are visible in this function
	global R301_PATTERN, R99_PATTERN, P2020_PATTERN, RE45_PATTERN, G7_PATTERN, SPITFIRE_PATTERN, ALTERNATOR_PATTERN
	global DEVOTION_PATTERN, TURBODEVOTION_PATTERN, HAVOC_PATTERN, VOLT_PATTERN, NEMESIS_PATTERN, NEMESIS_CHARGED_PATTERN
	global CAR_PATTERN, FLATLINE_PATTERN, RAMPAGE_PATTERN, RAMPAGEAMP_PATTERN, PROWLER_PATTERN, P3030_PATTERN
	global LSTAR_PATTERN, HEMLOK_PATTERN, HEMLOK_SINGLE_PATTERN, SHEILA_PATTERN
	
    LogMessage("Loading weapon patterns...")

    ; Load light weapon patterns
    R301_PATTERN := LoadPattern("R301.txt")
    R99_PATTERN := LoadPattern("R99.txt")
    P2020_PATTERN := LoadPattern("P2020.txt")
    RE45_PATTERN := LoadPattern("RE45.txt")
    G7_PATTERN := LoadPattern("G7.txt")
    SPITFIRE_PATTERN := LoadPattern("Spitfire.txt")
    ALTERNATOR_PATTERN := LoadPattern("Alternator.txt")

    ; Load energy weapon patterns
    DEVOTION_PATTERN := LoadPattern("Devotion.txt")
    TURBODEVOTION_PATTERN := LoadPattern("DevotionTurbo.txt")
    HAVOC_PATTERN := LoadPattern("Havoc.txt")
    VOLT_PATTERN := LoadPattern("Volt.txt")
    NEMESIS_PATTERN := LoadPattern("Nemesis.txt")
    NEMESIS_CHARGED_PATTERN := LoadPattern("NemesisCharged.txt")

    ; Load special weapon patterns
    CAR_PATTERN := LoadPattern("CAR.txt")

    ; Load heavy weapon patterns
    FLATLINE_PATTERN := LoadPattern("Flatline.txt")
    RAMPAGE_PATTERN := LoadPattern("Rampage.txt")
    RAMPAGEAMP_PATTERN := LoadPattern("RampageAmp.txt")
    PROWLER_PATTERN := LoadPattern("Prowler.txt")
    P3030_PATTERN := LoadPattern("3030.txt")

    ; Load supply drop weapon patterns
    LSTAR_PATTERN := LoadPattern("Lstar.txt")
    HEMLOK_PATTERN := LoadPattern("Hemlok.txt")
    HEMLOK_SINGLE_PATTERN := LoadPattern("HemlokSingle.txt")

    ; Load sheila weapon pattern
    SHEILA_PATTERN := LoadPattern("Sheila.txt")

    LogMessage("Weapon patterns loaded successfully.")
}

HideProcess() {
    global hMod, hHook, version ; Make sure it's visible

    LogMessage("Starting HideProcess...")

    ; Check if the OS is 64-bit and if pointer size is correct
    if (A_Is64bitOS and A_PtrSize != 4) {
        hMod := DllCall("LoadLibrary", "Str", "hyde64.dll", "Ptr")
        LogMessage("Attempting to load hyde64.dll")
    } else {
        hMod := DllCall("LoadLibrary", "Str", "hyde.dll", "Ptr")
        LogMessage("Attempting to load hyde.dll")
    }

    ; If the library is loaded successfully
    if (hMod) {
        LogMessage("Library loaded successfully.")
        
        hHook := DllCall("SetWindowsHookEx", "Int", 5, "Ptr", DllCall("GetProcAddress", "Ptr", hMod, "AStr", "CBProc", "Ptr"), "Ptr", hMod, "Ptr", 0, "Ptr")

        ; If the hook was not set successfully, terminate the script
        if (!hHook) {
            LogMessage("SetWindowsHookEx failed. Exiting the script.", "error")
            ExitSub()
        } else {
            LogMessage("SetWindowsHookEx succeeded. Hook set.")
        }
    } else {
        LogMessage("LoadLibrary failed. Exiting the script.", "error")
        ExitSub()
    }

    ; If everything was successful, notify the user and log the process
    LogMessage("Process (" A_ScriptName ") hidden successfully.")
    MsgBox("v"version " - Process ('" A_ScriptName "') hidden! `nYour uuid is " UUID)
}


LoadPixel(name) {
    global resolution, version ; Make sure it's visible
	
    iniFilePath := A_ScriptDir "\resolution\" resolution ".ini"
	
    ; Log the start of the function
    LogMessage("Starting LoadPixel for weapon: " name)

    ; Check if the .ini file exists before reading
    if (!FileExist(iniFilePath)) {
        LogMessage("File not found: " iniFilePath, "error")
        ExitSub()
    }

    LogMessage("Found iniFilePath: " iniFilePath)
	
    ; Use IniRead if available, otherwise fallback to manual file reading
    try {
        weapon_pixel_str := IniRead(iniFilePath, "pixels", name)
        LogMessage("IniRead success for " name)
    } catch {
        LogMessage("IniRead failed for " name ". Attempting manual file read.")
        weapon_pixel_str := ManualIniRead(iniFilePath, "pixels", name)
    }
    
    ; Log the read pixel data
    LogMessage("weapon_pixel_str: " weapon_pixel_str)
    
    ; Create an empty array to store pixel data
    weapon_num_pixels := []
    
    ; Use 'StrSplit' to split the string into an array by commas
    if (weapon_pixel_str) {
        pixelArray := StrSplit(weapon_pixel_str, ",")
        
        ; Log the split array
        LogMessage("pixelArray: " pixelArray)
        
        ; Iterate through the array and push non-empty entries into 'weapon_num_pixels'
        for pixel in pixelArray {
            if (StrLen(pixel) > 0) {
                cleanedPixel := Trim(StrReplace(pixel, '"'))  ; Remove extra quotes and spaces
                LogMessage("Processing pixel: " cleanedPixel)
                weapon_num_pixels.Push(Round(cleanedPixel))  ; Ensure it's an integer
            }
        }
    } else {
        LogMessage("No pixel data found for " name, "error")
    }

    ; Log the final pixel array
    LogMessage("weapon_num_pixels for " name ": " weapon_num_pixels)

    return weapon_num_pixels
}

ManualIniRead(iniFilePath, section, key) {
    ; Log the start of the function
    LogMessage("Starting ManualIniRead. File: " iniFilePath ", Section: " section ", Key: " key)
    
    content := FileRead(iniFilePath) ; Read the entire file
    
    ; Log if the content is read
    if (content) {
        LogMessage("File content successfully read.")
    } else {
        LogMessage("Failed to read file content.", "error")
        return ""
    }

    section_found := false
    for line in StrSplit(content, "`n") {
        line := Trim(line)
        
        ; Log the current line being processed
        LogMessage("Processing line: " line)

        ; Check for the section header
        if (line = "[" section "]") {
            section_found := true
            LogMessage("Section found: [" section "]")
            continue
        }

        ; Read the key if we're inside the section
        if (section_found and InStr(line, key "=")) {
            value := Trim(StrSplit(line, "=")[2])
            LogMessage("Key found: " key " with value: " value)
            return value
        }
    }

    ; Log if the section or key was not found
    LogMessage("Section [" section "] or key " key " not found in the file.", "error")
    return ""
}

LoadPattern(filename) {
	global version ; Make sure it's visible
	
    filePath := A_ScriptDir "\pattern\" filename
    LogMessage("Loading pattern from file: " filePath)
	
    ; Read the file and get its contents directly
    try {
        pattern_str := FileRead(filePath)
        LogMessage("File read successfully.")
    } catch {
        LogMessage("Error reading file: " filePath)
        MsgBox("v"version " - Error reading file: " filePath)
        ExitSub()
    }
    
    ; Initialize an empty array to store the pattern
    pattern := []
    
    ; Use StrSplit to handle newlines and commas
    patternArray := StrSplit(pattern_str, "`n,`, ,`r")
    
    ; Initialize a temporary array to hold triplets
    temp := []
    
    ; Loop through the split array and process each value
    for line in patternArray {
        if (StrLen(line) > 0) {
            temp.Push(Trim(line))  ; Add value to the temporary array
            if (temp.Length() == 3) {
                ; Once we have 3 values, log and join them as a triplet and push to the pattern array
                triplet := temp[1] "," temp[2] "," temp[3]
                LogMessage("Adding triplet to pattern: " triplet)
                pattern.Push(triplet)
                temp := []  ; Reset the temporary array for the next triplet
            }
        }
    }
    
    LogMessage("Pattern loaded with " pattern.Length() " triplets.")
    return pattern
}

Reset() {
	global current_pattern, is_single_mode, peackkeeper_lock, current_weapon_type, current_weapon_num, current_pattern ; Make sure it's visible
	global DEFAULT_WEAPON_TYPE, DEFAULT_PATTERN ; Make sure it's visible
	
    is_single_mode := false
    peackkeeper_lock := false
    current_weapon_type := DEFAULT_WEAPON_TYPE
    current_weapon_num := 0
	current_pattern := DEFAULT_PATTERN
}

IsShiela() {
	global WEAPON_2_PIXELS, WEAPON_2_PIXELS, SHEILA_WEAPON_COLOR ; Make sure it's visible

    ; Get the color at the specified pixel coordinates
    check_weapon2_color := PixelGetColor(WEAPON_2_PIXELS[1], WEAPON_2_PIXELS[2])
    
    ; Return whether the color matches SHEILA_WEAPON_COLOR
    return check_weapon2_color == SHEILA_WEAPON_COLOR
}

SetShiela() {
	global current_pattern, current_weapon_type, SHEILA_WEAPON_TYPE, SHEILA_PATTERN ; Make sure it's visible
	
    ; Set the current weapon type and pattern to SHEILA
    current_weapon_type := SHEILA_WEAPON_TYPE
    current_pattern := SHEILA_PATTERN
    
    ; Log with the current weapon type
    LogMessage(current_weapon_type)
}

CheckSingleMode() {
    global SINGLE_MODE_PIXELS

    target_color := "0xFFFFFF"
	
    check_point_color := PixelGetColor(SINGLE_MODE_PIXELS[1], SINGLE_MODE_PIXELS[2])
    
	if (check_point_color == target_color) {
        return true
    }
    return false
}

CheckWeapon(weapon_pixels) {
    target_color := "0xFFFFFF"
    i := 1
    
    ; Loop over weapon pixels, now using new loop syntax
    Loop 3 {
        check_point_color := PixelGetColor(weapon_pixels[i], weapon_pixels[i + 1])
        if (weapon_pixels[i + 2] != (check_point_color == target_color)) {
            return false
        }
        i += 3
    }
    return true
}

CheckRampageCharged() {
    global CHARGED_MODE_PIXELS

    target_color := "0xEA9C42"
		
    check_point_color := PixelGetColor(CHARGED_MODE_PIXELS[1], CHARGED_MODE_PIXELS[2])
	    
	if (check_point_color == target_color) {
        return true
    }
    return false
}

CheckTurbocharger(turbocharger_pixels) {
    target_color := "0xFFFFFF"
    check_point_color := PixelGetColor(turbocharger_pixels[1], turbocharger_pixels[2])
    
    ; Return true if the color matches the target color
    return check_point_color == target_color
}

IsNemesisFullCharge() {
	global NEMESIS_FULL_CHARGE_PIXELS, NEMESIS_FULL_CHARGE_PIXELS ; Make sure it's visible
    target_color := "0xD6BD62"
    check_point_color := PixelGetColor(NEMESIS_FULL_CHARGE_PIXELS[1], NEMESIS_FULL_CHARGE_PIXELS[2])
    
    ; Return true if the color matches the target color
    return check_point_color == target_color
}

IsValidWeaponColor(weapon_color) {
    global LIGHT_WEAPON_COLOR, HEAVY_WEAPON_COLOR, SNIPER_WEAPON_COLOR, ENERGY_WEAPON_COLOR, SUPPY_DROP_COLOR, SHOTGUN_WEAPON_COLOR, SHEILA_WEAPON_COLOR ; Make sure it's visible
    	
    ; Log the current weapon color being checked
    LogMessage("Checking weapon color: " weapon_color)
    
    ; Log all the defined weapon colors
    LogMessage("LIGHT_WEAPON_COLOR: " LIGHT_WEAPON_COLOR)
    LogMessage("HEAVY_WEAPON_COLOR: " HEAVY_WEAPON_COLOR)
    LogMessage("SNIPER_WEAPON_COLOR: " SNIPER_WEAPON_COLOR)
    LogMessage("ENERGY_WEAPON_COLOR: " ENERGY_WEAPON_COLOR)
    LogMessage("SUPPY_DROP_COLOR: " SUPPY_DROP_COLOR)
    LogMessage("SHOTGUN_WEAPON_COLOR: " SHOTGUN_WEAPON_COLOR)
    LogMessage("SHEILA_WEAPON_COLOR: " SHEILA_WEAPON_COLOR)
	
    ; Check if the weapon color matches any of the predefined valid colors
    if (weapon_color == LIGHT_WEAPON_COLOR) {
		LogMessage("Weapon color " weapon_color " is valid.")
        return {valid: true, color_name: "light_weapon_color"}
    } else if (weapon_color == HEAVY_WEAPON_COLOR) {
		LogMessage("Weapon color " weapon_color " is valid.")
        return {valid: true, color_name: "heavy_weapon_color"}
    } else if (weapon_color == SNIPER_WEAPON_COLOR) {
		LogMessage("Weapon color " weapon_color " is valid.")
        return {valid: true, color_name: "sniper_weapon_color"}
    } else if (weapon_color == ENERGY_WEAPON_COLOR) {
		LogMessage("Weapon color " weapon_color " is valid.")
        return {valid: true, color_name: "energy_weapon_color"}
    } else if (weapon_color == SUPPY_DROP_COLOR) {
		LogMessage("Weapon color " weapon_color " is valid.")
        return {valid: true, color_name: "supply_drop_color"}
    } else if (weapon_color == SHOTGUN_WEAPON_COLOR) {
		LogMessage("Weapon color " weapon_color " is valid.")
        return {valid: true, color_name: "shotgun_weapon_color"}
    } else if (weapon_color == SHEILA_WEAPON_COLOR) {
		LogMessage("Weapon color " weapon_color " is valid.")
        return {valid: true, color_name: "sheila_weapon_color"}
    } else {
		LogMessage("Weapon color " weapon_color " is not valid.")
        return {valid: false, color_name: ""}
    }
}

IsMouseShown() {
    StructSize := A_PtrSize + 16
    InfoStruct := Buffer(StructSize)  ; Allocate buffer for CURSORINFO

    ; Set the size of the structure (cbSize) in the first element of the buffer using the new NumPut syntax
    NumPut("UInt", StructSize, InfoStruct)  ; The structure's first element (cbSize) is the size of the structure
    
    ; Call GetCursorInfo with the pointer to the buffer
    if (DllCall("GetCursorInfo", "Ptr", InfoStruct)) {
        ; Get the flags from the buffer at the 9th byte (offset 8) to check visibility
        flags := NumGet(InfoStruct, 8, "UInt")
        
        ; If flags > 1, cursor is visible
        return flags > 1
    }
    
    return false  ; Default return if DllCall fails
}

ShowToolTip(Text) {
	global show_tooltip ; Make sure it's visible

	if (show_tooltip == "1") {
		; Show the tooltip at the calculated position
		ToolTip(Text)
		; Set a timer to remove the tooltip
		SetTimer () => ToolTip(), -500
	}
}

ExitSub() {
    global hHook, hMod, version  ; Make sure it's visible
    
    LogMessage("Starting ExitSub...")

    if (hHook) {
        ; Unhook the Windows hook if it exists
        DllCall("UnhookWindowsHookEx", "Ptr", hHook)
        LogMessage("Windows hook unhooked.")
    } else {
        LogMessage("No hook found to unhook.")
    }
    
    if (hMod) {
        ; Free the library if it was loaded
        DllCall("FreeLibrary", "Ptr", hMod)
        LogMessage("Library unloaded.")
    } else {
        LogMessage("No library found to unload.")
    }
    
    ; Exit the application
    LogMessage("Exiting application.")
    MsgBox("v"version " - Exiting application!")
    ExitApp
}

LogMessage(message, message_level := "info") {
    global debug, tempFilePath, version, error_level  ; Ensure they are accessible
    
    ; Define the hierarchy of log levels
    level_rank := { "info": 1, "error": 2 }

    ; If the message level is lower than the global error level, do not log
    if (level_rank[message_level] < level_rank[error_level]) {
        return  ; Exit the function without logging
    }
    
    ; Proceed with logging if the message level is sufficient
    if (debug == "1") {
        try {
            if (!FileExist(tempFilePath)) {  ; Check if log file exists
                FileAppend("", tempFilePath)  ; Create it if not
            }
            ; Dynamically prepend the error level
            log_entry := "v" version " - [" message_level "] " message "`n"
            ; Append the message to the log file
            FileAppend(log_entry, tempFilePath)
        } catch {
            MsgBox("v" version " - Error writing to log file")
        }
    }
}

; Check weapons using global weapon_check_map
CheckWeapons(weapon_list) {
	global current_pattern, current_weapon_type, is_single_mode
	
	LogMessage("CheckWeapons called", "info")
	
	for weapon_data in weapon_list {	
		; Check if it's Sheila
		if (weapon_data.weapon = "SHIELA") {
			current_weapon_type := weapon_data.weapon
			current_pattern := weapon_data.pattern
			LogMessage("Weapon: " weapon_data.weapon, "info")
			return true  ; Exit once a match is found
		} else if (CheckWeapon(weapon_data.pixels)) {
			current_weapon_type := weapon_data.weapon
			current_pattern := weapon_data.pattern
			LogMessage("Weapon: " weapon_data.weapon, "info")
			
			; Special case for turbo or single mode
			if (weapon_data.HasProp("turbo_pixels") && CheckTurbocharger(weapon_data.turbo_pixels)) {
				current_pattern := weapon_data.turbo_pattern
				LogMessage("Weapon with turbo: " weapon_data.weapon, "info")
			} else if (weapon_data.HasProp("single_mode") && is_single_mode) {
				current_pattern := weapon_data.single_mode
				LogMessage("Weapon in single mode: " weapon_data.weapon, "info")
			} else if (weapon_data.weapon = "RAMPAGE" && CheckRampageCharged()) {
				current_pattern := weapon_data.charged_pattern
				LogMessage("Weapon in charged mode: " weapon_data.weapon, "info")
			}
			return true  ; Exit once a match is found
		}
	}
	return false
}

IsAutoClickNeeded() {
    global auto_fire, current_weapon_type
	
    return ((auto_fire == "1") && (current_weapon_type == HEMLOK_WEAPON_TYPE || current_weapon_type == R301_WEAPON_TYPE))
}
	
DetectAndSetWeapon() {
    global current_pattern, current_weapon_type, weapon_check_map
    global WEAPON_1_PIXELS, WEAPON_2_PIXELS
    global LIGHT_WEAPON_COLOR, HEAVY_WEAPON_COLOR, ENERGY_WEAPON_COLOR
    global SHOTGUN_WEAPON_COLOR, SNIPER_WEAPON_COLOR, SUPPY_DROP_COLOR
	global is_single_mode

    LogMessage("DetectAndSetWeapon called")

    Reset()

    is_single_mode := CheckSingleMode()
    LogMessage("Single mode: " . is_single_mode, "info")

    ; First, check which weapon is active
    weapon1_color := PixelGetColor(WEAPON_1_PIXELS[1], WEAPON_1_PIXELS[2])
    weapon2_color := PixelGetColor(WEAPON_2_PIXELS[1], WEAPON_2_PIXELS[2])

    LogMessage("Weapon 1 Color: " . weapon1_color, "info")
    LogMessage("Weapon 2 Color: " . weapon2_color, "info")

    ; Check if the weapon color is valid and get the associated color name
    weapon_check := IsValidWeaponColor(weapon1_color)
    if (weapon_check.valid) {
        check_point_color := weapon1_color
        current_weapon_num := 1
        LogMessage("Weapon 1 is valid", "info")
    } else {
        weapon_check := IsValidWeaponColor(weapon2_color)
        if (weapon_check.valid) {
            check_point_color := weapon2_color
            current_weapon_num := 2
            LogMessage("Weapon 2 is valid", "info")
        } else {
            LogMessage("No valid weapon color found", "error")
            return
        }
    }

    ; Use the color name to look up the appropriate weapons
    if (weapon_check_map.HasProp(weapon_check.color_name) && CheckWeapons(weapon_check_map[weapon_check.color_name])) {
        return
    }

    ; Check for special colors like Shotgun, Sniper, and Supply Drop
    if (check_point_color == SHOTGUN_WEAPON_COLOR) {
        current_weapon_type := SHOTGUN_WEAPON_TYPE
        current_pattern := DEFAULT_PATTERN
        LogMessage("Weapon: SHOTGUN", "info")
    } else if (check_point_color == SNIPER_WEAPON_COLOR) {
        current_weapon_type := SNIPER_WEAPON_TYPE
        current_pattern := DEFAULT_PATTERN
        LogMessage("Weapon: Sniper", "info")
    } else if (check_point_color == SUPPY_DROP_COLOR) {
        if (CheckWeapon(R99_PIXELS)) {
            current_weapon_type := R99_WEAPON_TYPE
            current_pattern := R99_PATTERN
            LogMessage("Weapon: R99 from Supply Drop", "info")
        } else if (CheckWeapon(DEVOTION_PIXELS)) {
            current_weapon_type := DEVOTION_WEAPON_TYPE
            current_pattern := DEVOTION_PATTERN
            if (CheckTurbocharger(DEVOTION_TURBOCHARGER_PIXELS)) {
                current_pattern := TURBODEVOTION_PATTERN
                current_weapon_type := DEVOTION_TURBO_WEAPON_TYPE
            }
            LogMessage("Weapon: Devotion from Supply Drop", "info")
        } else {
            current_weapon_type := DEFAULT_WEAPON_TYPE
            current_pattern := DEFAULT_PATTERN
        }
    } else {
        current_weapon_type := DEFAULT_WEAPON_TYPE
        current_pattern := DEFAULT_PATTERN
    }

    LogMessage(current_weapon_type, "info")
}

MoveMouse() {
	global debug, current_pattern, is_single_mode, ads_only, trigger_only ; Make sure it's visible
	
    LogMessage("LButton pressed. Starting checks.")

    ; Check if the mouse is visible or the weapon type should be ignored
    if (IsMouseShown() || current_weapon_type == DEFAULT_WEAPON_TYPE || current_weapon_type == SHOTGUN_WEAPON_TYPE || current_weapon_type == SNIPER_WEAPON_TYPE) {
        LogMessage("Mouse is shown or weapon type is ignored. Exiting.")
        return
    }
	
	; Check if current_pattern is empty
	if (!current_pattern || !IsObject(current_pattern) || current_pattern.Length() == 0) {
		LogMessage("Invalid pattern detected, exiting MoveMouse.", "error")
		return
	}
	
	try {
		auto_click_needed := IsAutoClickNeeded()
	} catch {
		LogMessage("Error in IsAutoClickNeeded", "error")
		auto_click_needed := false  ; Set a fallback
	}

    ; Check if single mode is active
    if (is_single_mode == "1" && !auto_click_needed) {
        LogMessage("Single mode is active. Exiting.")
        return
    }

    ; Check if ads_only is true and right mouse button isn't pressed
    if (ads_only == "1" && !GetKeyState("RButton")) {
        LogMessage("ADS only is true and RButton not pressed. Exiting.")
        return
    }

    ; Check if trigger_only is true and the trigger button isn't pressed
    if (trigger_only == "1" && !GetKeyState(trigger_button, "T")) {
        LogMessage("Trigger only is true and trigger button not pressed. Exiting.")
        return
    }

    ; Handle HAVOC_WEAPON_TYPE special delay
    if (current_weapon_type == HAVOC_WEAPON_TYPE) {
        LogMessage("Current weapon is HAVOC. Adding delay of 400ms.")
        Sleep(400)
    }

    ; Handle NEMESIS and RAMPAGE weapon charged behavior
    if (current_weapon_type == NEMESIS_WEAPON_TYPE || current_weapon_type == NEMESIS_CHARGED_WEAPON_TYPE) {
        LogMessage("Current weapon is NEMESIS. Checking charge status.")
        if (IsNemesisFullCharge()) {
            current_weapon_type := NEMESIS_CHARGED_WEAPON_TYPE
            current_pattern := NEMESIS_CHARGED_PATTERN
            LogMessage("NEMESIS fully charged. Using charged pattern.")
        } else {
            current_weapon_type := NEMESIS_WEAPON_TYPE
            current_pattern := NEMESIS_PATTERN
            LogMessage("NEMESIS not fully charged. Using normal pattern.")
        }
    } else if (current_weapon_type == RAMPAGE_WEAPON_TYPE) {
        LogMessage("Current weapon is RAMPAGE. Checking charge status.")
        if (CheckRampageCharged()) {
            current_pattern := RAMPAGEAMP_PATTERN
            LogMessage("RAMPAGE fully charged. Using charged pattern.")
        } else {
            current_pattern := RAMPAGE_PATTERN
            LogMessage("RAMPAGE not fully charged. Using normal pattern.")
        }
    }
	
	; Log the entire current pattern and its length
	LogMessage("Current Pattern: " current_pattern)
	LogMessage("Current Pattern Length: " current_pattern.Length())

	; Loop to manage recoil compensation with try-catch for error handling
    try {
		Loop {
			x := 0
			y := 0
			interval := 20
			
			; Check if current_pattern is empty
			if (!current_pattern || !IsObject(current_pattern) || current_pattern.Length() == 0) {
				LogMessage("Invalid pattern detected, exiting MoveMouse.", "error")
				return
			}
						
			; Exit the loop if the left mouse button is no longer held
			if (!GetKeyState("LButton", "P")) {
				LogMessage("LButton released. Exiting loop.")
				break
			}
			
			; If within current pattern, get the compensation values
			if (A_Index < current_pattern.Length()) {
				; Ensure the current pattern index is valid
				if (!IsSet(current_pattern[A_Index]) || current_pattern[A_Index] = "") {
					LogMessage("Invalid or empty pattern at index " A_Index, "error")
					return
				}
				
				compensation := StrSplit(current_pattern[A_Index], ",")
	 
				; Log the full compensation array for debug
				LogMessage("Compensation Array: " compensation)

				; If invalid compensation, exit the loop
				if (compensation.Length() < 3) {
					LogMessage("Invalid compensation found. Exiting.")
					return
				}

				x := compensation[1]
				y := compensation[2]
				interval := compensation[3]

				LogMessage("Recoil compensation - X: " x ", Y: " y ", Interval: " interval)
			}
			
			if (auto_click_needed) {
				Click
				rand := Random(1, 20)
				interval := interval + rand
			}
			
			; Apply the recoil compensation with DllCall to mouse_event
			try {
				DllCall("mouse_event", "UInt", 0x01, "Int", Round(x * modifier), "Int", Round(y * modifier))
				LogMessage("Mouse event called with X: " Round(x * modifier) ", Y: " Round(y * modifier))
			} catch {
				LogMessage("Error calling DllCall for mouse_event", "error")
			}
			
			; Show tooltip if debug is enabled
			if (debug == "1") {
				ShowToolTip(x " " y " " A_Index)
				LogMessage("Tooltip shown for recoil X: " x ", Y: " y ", Index: " A_Index)
			}
			
			; Wait for the interval before applying the next step in the recoil pattern
			LogMessage("Sleeping for " interval "ms.")
			Sleep(Round(interval))
			
			; Exit the loop if the left mouse button is no longer held
			if (!GetKeyState("LButton", "P")) {
				LogMessage("LButton released. Exiting loop.")
				break
			}
		}
	} catch {
        LogMessage("Error occurred in recoil compensation loop", "error")
    }
    return
}