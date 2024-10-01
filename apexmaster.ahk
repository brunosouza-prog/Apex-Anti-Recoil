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
global auto_fire := "1" ; @TODO Bring it back auto_fire
global ads_only := "0"
global debug := "0"
global trigger_only := "0"
global trigger_button := "Capslock"
global show_tooltip := "0"
global tempFilePath := A_ScriptDir "\debug_log.txt"
global hMod, hHook
global UUID := "811e155bf4114204ae515ff9174ec383"

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
global HEMLOK_SINGLE_WEAPON_TYPE := "HEMLOK SINGLE"
global RE45_WEAPON_TYPE := "RE45"
global ALTERNATOR_WEAPON_TYPE := "ALTERNATOR"
global P2020_WEAPON_TYPE := "P2020"
global RAMPAGE_WEAPON_TYPE := "RAMPAGE"
global G7_WEAPON_TYPE := "G7"
global CAR_WEAPON_TYPE := "CAR"
global P3030_WEAPON_TYPE := "3030"
global SHOTGUN_WEAPON_TYPE := "shotgun"
global SNIPER_WEAPON_TYPE := "sniper"
global PEACEKEEPER_WEAPON_TYPE := "peacekeeper"
global SHEILA_WEAPON_TYPE := "shiela"

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
global NEMESIS_FULL_CHARGE_PIXELS, SINGLE_MODE_PIXELS, PEACEKEEPER_PIXELS

; weapon detection
global current_pattern := ["0,0,0"]
global current_weapon_type := DEFAULT_WEAPON_TYPE
global current_weapon_num := 0
global peackkeeper_lock := false
global is_single_mode := false

; Declare global variables without loading the patterns
global R301_PATTERN, R99_PATTERN, P2020_PATTERN, RE45_PATTERN, G7_PATTERN, SPITFIRE_PATTERN, ALTERNATOR_PATTERN
global DEVOTION_PATTERN, TURBODEVOTION_PATTERN, HAVOC_PATTERN, VOLT_PATTERN, NEMESIS_PATTERN, NEMESIS_CHARGED_PATTERN
global CAR_PATTERN, FLATLINE_PATTERN, RAMPAGE_PATTERN, RAMPAGEAMP_PATTERN, PROWLER_PATTERN, P3030_PATTERN
global LSTAR_PATTERN, HEMLOK_PATTERN, HEMLOK_SINGLE_PATTERN, SHEILA_PATTERN
global DEFAULT_PATTERN = ["0,0,0"]

; Clear the debug log file at the start of the script
if (FileExist(tempFilePath)) {
    FileDelete(tempFilePath)
}
; Recreate an empty log file
FileAppend("Script Version "version "`n", tempFilePath)

; First, read the settings from the ini file
ReadIni()

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

; Now hide the process
HideProcess()

~$*E Up::
    Sleep(300)
    DetectAndSetWeapon()
return

~$*WheelDown::
~$*1::
~$*2::
~$*B::
~$*R::
    Sleep(500)
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
	MoveMouse()
}

RunAsAdmin() {
    LogMessage("RunAsAdmin called.")
    
    if A_IsAdmin {
        LogMessage("Already running as Admin.")
        return 0
    }
	
	MsgBox("v"version " - Run the script as administrator.")

    ExitSub()
}

ReadIni() {
	global resolution, colorblind, zoom_sens, sens, auto_fire, ads_only, debug, trigger_only, trigger_button, version ; Make sure it's visible
    
	iniFilePath := A_ScriptDir "\settings.ini" ; Ensure the full path is being checked
    
    LogMessage("Checking if settings.ini exists at: " iniFilePath)
    
    if !FileExist(iniFilePath) {
        LogMessage("settings.ini not found. Creating a new one.")
        MsgBox("v"version " - Couldn't find settings.ini. I'll create one for you.")
        IniWrite("1920x1080", iniFilePath, "screen settings", "resolution")
        IniWrite("Normal", iniFilePath, "screen settings", "colorblind")
        IniWrite("5.0", iniFilePath, "mouse settings", "sens")
        IniWrite("1.0", iniFilePath, "mouse settings", "zoom_sens")
        IniWrite("1", iniFilePath, "mouse settings", "auto_fire")
        IniWrite("0", iniFilePath, "mouse settings", "ads_only")
        IniWrite("0", iniFilePath, "other settings", "debug")
        IniWrite("0", iniFilePath, "trigger settings", "trigger_only")
        IniWrite("Capslock", iniFilePath, "trigger settings", "trigger_button")
        LogMessage("New settings.ini file created.")
        MsgBox("v"version " - The settings.ini file was created, open it and make sure the settings match your in-game settings.")
		ExitSub()
    } else {
		debug := ReadIniValue(iniFilePath, "other settings", "debug")
        LogMessage("settings.ini found. Reading settings.")
		LogMessage("debug=" debug)
		resolution := ReadIniValue(iniFilePath, "screen settings", "resolution")
		LogMessage("resolution=" resolution)
		colorblind := ReadIniValue(iniFilePath, "screen settings", "colorblind")
		LogMessage("colorblind=" colorblind)
		zoom_sens := ReadIniValue(iniFilePath, "mouse settings", "zoom_sens")
		LogMessage("zoom_sens=" zoom_sens)
		sens := ReadIniValue(iniFilePath, "mouse settings", "sens")
		LogMessage("sens=" sens)
		auto_fire := ReadIniValue(iniFilePath, "mouse settings", "auto_fire")
		LogMessage("auto_fire=" auto_fire)
		ads_only := ReadIniValue(iniFilePath, "mouse settings", "ads_only")
		LogMessage("ads_only=" ads_only)
		trigger_only := ReadIniValue(iniFilePath, "trigger settings", "trigger_only")
		LogMessage("trigger_only=" trigger_only)
		trigger_button := ReadIniValue(iniFilePath, "trigger settings", "trigger_button")
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
        if value != ""
            LogMessage("Manual read success for " key ": " value)
        else
            LogMessage("[ERROR] Manual read failed for " key)
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
	global NEMESIS_FULL_CHARGE_PIXELS, SINGLE_MODE_PIXELS, PEACEKEEPER_PIXELS
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
    if hMod {
        LogMessage("Library loaded successfully.")
        
        hHook := DllCall("SetWindowsHookEx", "Int", 5, "Ptr", DllCall("GetProcAddress", "Ptr", hMod, "AStr", "CBProc", "Ptr"), "Ptr", hMod, "Ptr", 0, "Ptr")

        ; If the hook was not set successfully, terminate the script
        if !hHook {
            LogMessage("[ERROR] SetWindowsHookEx failed. Exiting the script.")
            MsgBox("v"version " - [ERROR] SetWindowsHookEx failed!`nScript will now terminate!")
            ExitSub()
        } else {
            LogMessage("SetWindowsHookEx succeeded. Hook set.")
        }
    } else {
        LogMessage("[ERROR] LoadLibrary failed. Exiting the script.")
        MsgBox("v"version " - [ERROR] LoadLibrary failed!`nScript will now terminate!")
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
    if !FileExist(iniFilePath) {
        LogMessage("[ERROR] File not found: " iniFilePath)
        MsgBox("v"version " - [ERROR] File not found: " iniFilePath)
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
        LogMessage("[ERROR] No pixel data found for " name)
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
    if content {
        LogMessage("File content successfully read.")
    } else {
        LogMessage("[ERROR] Failed to read file content.")
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
    LogMessage("[ERROR] Section [" section "] or key " key " not found in the file.")
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
        if StrLen(line) > 0 {
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
    return false ; @TODO Bring it back auto_fire
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
	global LIGHT_WEAPON_COLOR, HEAVY_WEAPON_COLOR, SNIPER_WEAPON_COLOR, ENERGY_WEAPON_COLOR, SUPPY_DROP_COLOR, SHOTGUN_WEAPON_COLOR ; Make sure it's visible
	
    ; Log the current weapon color being checked
    LogMessage("Checking weapon color: " weapon_color)
    
    ; Log all the defined weapon colors
    LogMessage("LIGHT_WEAPON_COLOR: " LIGHT_WEAPON_COLOR)
    LogMessage("HEAVY_WEAPON_COLOR: " HEAVY_WEAPON_COLOR)
    LogMessage("SNIPER_WEAPON_COLOR: " SNIPER_WEAPON_COLOR)
    LogMessage("ENERGY_WEAPON_COLOR: " ENERGY_WEAPON_COLOR)
    LogMessage("SUPPY_DROP_COLOR: " SUPPY_DROP_COLOR)
    LogMessage("SHOTGUN_WEAPON_COLOR: " SHOTGUN_WEAPON_COLOR)

    ; Check if the weapon color matches any of the predefined valid colors
    valid := weapon_color == LIGHT_WEAPON_COLOR 
        || weapon_color == HEAVY_WEAPON_COLOR 
        || weapon_color == SNIPER_WEAPON_COLOR 
        || weapon_color == ENERGY_WEAPON_COLOR 
        || weapon_color == SUPPY_DROP_COLOR 
        || weapon_color == SHOTGUN_WEAPON_COLOR

    ; Log whether the weapon color is valid or not
    if valid {
        LogMessage("Weapon color " weapon_color " is valid.")
    } else {
        LogMessage("Weapon color " weapon_color " is not valid.")
    }

    return valid
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

    if hHook {
        ; Unhook the Windows hook if it exists
        DllCall("UnhookWindowsHookEx", "Ptr", hHook)
        LogMessage("Windows hook unhooked.")
    } else {
        LogMessage("No hook found to unhook.")
    }
    
    if hMod {
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

LogMessage(message) {
	global debug, tempFilePath, version  ; Ensure they are accessible
	
    if (debug == "1") {
        try {
            if !FileExist(tempFilePath) {  ; Check if log file exists
                FileAppend("", tempFilePath)  ; Create it if not
            }
            ; Append the message to the log file
            FileAppend("v"version " - " message "`n", tempFilePath)
        } catch {
            MsgBox("v"version " - Error writing to log file")
        }
    }
}

DetectAndSetWeapon() {
	global current_pattern, current_weapon_type ; Make sure it's visible
	global WEAPON_1_PIXELS, WEAPON_2_PIXELS
	
    LogMessage("DetectAndSetWeapon called")

    Reset()

    if IsShiela() {
        SetShiela()
        LogMessage("Weapon: Sheila detected")
        return
    }

    is_single_mode := CheckSingleMode()
    LogMessage("Single mode: " . is_single_mode)

    ; First, check which weapon is active
    weapon1_color := PixelGetColor(WEAPON_1_PIXELS[1], WEAPON_1_PIXELS[2])
    weapon2_color := PixelGetColor(WEAPON_2_PIXELS[1], WEAPON_2_PIXELS[2])

    LogMessage("Weapon 1 Color: " . weapon1_color)
    LogMessage("Weapon 2 Color: " . weapon2_color)

    if IsValidWeaponColor(weapon1_color) {
        check_point_color := weapon1_color
        current_weapon_num := 1
        LogMessage("Weapon 1 is valid")
    } else if IsValidWeaponColor(weapon2_color) {
        check_point_color := weapon2_color
        current_weapon_num := 2
        LogMessage("Weapon 2 is valid")
    } else {
        LogMessage("No valid weapon color found")
        return
    }

    ; Then, check the weapon type
    if check_point_color == LIGHT_WEAPON_COLOR {
        if CheckWeapon(R301_PIXELS) {
            current_weapon_type := R301_WEAPON_TYPE
            current_pattern := R301_PATTERN
            LogMessage("Weapon: R301")
        } else if CheckWeapon(R99_PIXELS) {
            current_weapon_type := R99_WEAPON_TYPE
            current_pattern := R99_PATTERN
            LogMessage("Weapon: R99")
        } else if CheckWeapon(P2020_PIXELS) {
            current_weapon_type := P2020_WEAPON_TYPE
            current_pattern := P2020_PATTERN
            LogMessage("Weapon: P2020")
        } else if CheckWeapon(RE45_PIXELS) {
            current_weapon_type := RE45_WEAPON_TYPE
            current_pattern := RE45_PATTERN
            LogMessage("Weapon: RE45")
        } else if CheckWeapon(ALTERNATOR_PIXELS) {
            current_weapon_type := ALTERNATOR_WEAPON_TYPE
            current_pattern := ALTERNATOR_PATTERN
            LogMessage("Weapon: Alternator")
        } else if CheckWeapon(CAR_PIXELS) {
            current_weapon_type := CAR_WEAPON_TYPE
            current_pattern := CAR_PATTERN
            LogMessage("Weapon: CAR")
        } else if CheckWeapon(G7_PIXELS) {
            current_weapon_type := G7_WEAPON_TYPE
            current_pattern := G7_PATTERN
            LogMessage("Weapon: G7")
        } else if CheckWeapon(SPITFIRE_PIXELS) {
            current_weapon_type := SPITFIRE_WEAPON_TYPE
            current_pattern := SPITFIRE_PATTERN
            LogMessage("Weapon: Spitfire")
        }
    } else if check_point_color == HEAVY_WEAPON_COLOR {
        if CheckWeapon(FLATLINE_PIXELS) {
            current_weapon_type := FLATLINE_WEAPON_TYPE
            current_pattern := FLATLINE_PATTERN
            LogMessage("Weapon: Flatline")
        } else if CheckWeapon(PROWLER_PIXELS) {
            current_weapon_type := PROWLER_WEAPON_TYPE
            current_pattern := PROWLER_PATTERN
            LogMessage("Weapon: Prowler")
        } else if CheckWeapon(RAMPAGE_PIXELS) {
            current_weapon_type := RAMPAGE_WEAPON_TYPE
            current_pattern := RAMPAGE_PATTERN
            LogMessage("Weapon: Rampage")
        } else if CheckWeapon(CAR_PIXELS) {
            current_weapon_type := CAR_WEAPON_TYPE
            current_pattern := CAR_PATTERN
            LogMessage("Weapon: CAR")
        } else if CheckWeapon(P3030_PIXELS) {
            current_weapon_type := P3030_WEAPON_TYPE
            current_pattern := P3030_PATTERN
            LogMessage("Weapon: 3030")
        } else if CheckWeapon(HEMLOK_PIXELS) {
            current_weapon_type := HEMLOK_WEAPON_TYPE
            current_pattern := HEMLOK_PATTERN
            if is_single_mode {
                current_weapon_type := HEMLOK_SINGLE_WEAPON_TYPE
                current_pattern := HEMLOK_SINGLE_PATTERN
            }
            LogMessage("Weapon: Hemlok")
        }
    } else if check_point_color == ENERGY_WEAPON_COLOR {
        if CheckWeapon(VOLT_PIXELS) {
            current_weapon_type := VOLT_WEAPON_TYPE
            current_pattern := VOLT_PATTERN
            LogMessage("Weapon: Volt")
        } else if CheckWeapon(DEVOTION_PIXELS) {
            current_weapon_type := DEVOTION_WEAPON_TYPE
            current_pattern := DEVOTION_PATTERN
            if CheckTurbocharger(DEVOTION_TURBOCHARGER_PIXELS) {
                current_pattern := TURBODEVOTION_PATTERN
                current_weapon_type := DEVOTION_TURBO_WEAPON_TYPE
            }
            LogMessage("Weapon: Devotion")
        } else if CheckWeapon(HAVOC_PIXELS) {
            current_weapon_type := HAVOC_WEAPON_TYPE
            current_pattern := HAVOC_PATTERN
            if CheckTurbocharger(HAVOC_TURBOCHARGER_PIXELS) {
                current_weapon_type := HAVOC_TURBO_WEAPON_TYPE
            }
            LogMessage("Weapon: Havoc")
        } else if CheckWeapon(NEMESIS_PIXELS) {
            current_weapon_type := NEMESIS_WEAPON_TYPE
            current_pattern := NEMESIS_PATTERN
            if IsNemesisFullCharge() {
                current_weapon_type := NEMESIS_CHARGED_WEAPON_TYPE
                current_pattern := NEMESIS_CHARGED_PATTERN
            }
            LogMessage("Weapon: Nemesis")
        } else if CheckWeapon(LSTAR_PIXELS) {
            current_weapon_type := LSTAR_WEAPON_TYPE
            current_pattern := LSTAR_PATTERN
            LogMessage("Weapon: LSTAR")
        }
    } else if check_point_color == SHOTGUN_WEAPON_COLOR {
        current_weapon_type := SHOTGUN_WEAPON_TYPE
		current_pattern := DEFAULT_PATTERN
        LogMessage("Weapon: SHOTGUN")
    } else if check_point_color == SNIPER_WEAPON_COLOR {
		current_weapon_type := SNIPER_WEAPON_TYPE
		current_pattern := DEFAULT_PATTERN
		LogMessage("Weapon: Sniper")
    } else if check_point_color == SUPPY_DROP_COLOR {
        if CheckWeapon(R99_PIXELS) {
            current_weapon_type := R99_WEAPON_TYPE
            current_pattern := R99_PATTERN
            LogMessage("Weapon: R99 from Supply Drop")
        } else if CheckWeapon(DEVOTION_PIXELS) {
            current_weapon_type := DEVOTION_WEAPON_TYPE
            current_pattern := DEVOTION_PATTERN
            if CheckTurbocharger(DEVOTION_TURBOCHARGER_PIXELS) {
                current_pattern := TURBODEVOTION_PATTERN
                current_weapon_type := DEVOTION_TURBO_WEAPON_TYPE
            }
            LogMessage("Weapon: Devotion from Supply Drop")
        }
		else {
			current_weapon_type := DEFAULT_WEAPON_TYPE
			current_pattern := DEFAULT_PATTERN
		}
    } else {
		current_weapon_type := DEFAULT_WEAPON_TYPE
		current_pattern := DEFAULT_PATTERN
	}

    LogMessage(current_weapon_type)
}

MoveMouse() {
	global debug, current_pattern, is_single_mode, ads_only, trigger_only ; Make sure it's visible
	
    LogMessage("LButton pressed. Starting checks.")

    ; Check if the mouse is visible or the weapon type should be ignored
    if IsMouseShown() || current_weapon_type == DEFAULT_WEAPON_TYPE || current_weapon_type == SHOTGUN_WEAPON_TYPE || current_weapon_type == SNIPER_WEAPON_TYPE {
        LogMessage("Mouse is shown or weapon type is ignored. Exiting.")
        return
    }

    ; Check if single mode is active
    if is_single_mode == "1" {
        LogMessage("Single mode is active. Exiting.")
        return
    }

    ; Check if ads_only is true and right mouse button isn't pressed
    if ads_only == "1" && !GetKeyState("RButton") {
        LogMessage("ADS only is true and RButton not pressed. Exiting.")
        return
    }

    ; Check if trigger_only is true and the trigger button isn't pressed
    if trigger_only == "1" && !GetKeyState(trigger_button, "T") {
        LogMessage("Trigger only is true and trigger button not pressed. Exiting.")
        return
    }

    ; Handle HAVOC_WEAPON_TYPE special delay
    if current_weapon_type == HAVOC_WEAPON_TYPE {
        LogMessage("Current weapon is HAVOC. Adding delay of 400ms.")
        Sleep(400)
    }

    ; Handle NEMESIS weapon behavior
    if current_weapon_type == NEMESIS_WEAPON_TYPE || current_weapon_type == NEMESIS_CHARGED_WEAPON_TYPE {
        LogMessage("Current weapon is NEMESIS. Checking charge status.")
        if IsNemesisFullCharge() {
            current_weapon_type := NEMESIS_CHARGED_WEAPON_TYPE
            current_pattern := NEMESIS_CHARGED_PATTERN
            LogMessage("NEMESIS fully charged. Using charged pattern.")
        } else {
            current_weapon_type := NEMESIS_WEAPON_TYPE
            current_pattern := NEMESIS_PATTERN
            LogMessage("NEMESIS not fully charged. Using normal pattern.")
        }
    }
	
	; Log the entire current pattern and its length
	LogMessage("Current Pattern: " current_pattern)
	LogMessage("Current Pattern Length: " current_pattern.Length())

    ; Loop to manage recoil compensation
    Loop {
        x := 0
        y := 0
        interval := 20
		
		; If within current pattern, get the compensation values
        if A_Index <= current_pattern.Length() {
            compensation := StrSplit(current_pattern[Min(A_Index, current_pattern.Length())], ",")
 
			; Log the full compensation array for debug
			LogMessage("Compensation Array: " compensation)

            ; If invalid compensation, exit the loop
            if compensation.Length() < 3 {
                LogMessage("Invalid compensation found. Exiting.")
                return
            }

            x := compensation[1]
            y := compensation[2]
            interval := compensation[3]

            LogMessage("Recoil compensation - X: " x ", Y: " y ", Interval: " interval)
        }
		
		; Apply the recoil compensation with DllCall to mouse_event
        DllCall("mouse_event", "UInt", 0x01, "Int", Round(x * modifier), "Int", Round(y * modifier))
        LogMessage("Mouse event called with X: " Round(x * modifier) ", Y: " Round(y * modifier))
		
		; Show tooltip if debug is enabled
        if (debug == "1") {
            ShowToolTip(x " " y " " A_Index)
            LogMessage("Tooltip shown for recoil X: " x ", Y: " y ", Index: " A_Index)
        }
		
		; Wait for the interval before applying the next step in the recoil pattern
        LogMessage("Sleeping for " interval "ms.")
        Sleep(Round(interval))
		
        ; Exit the loop if the left mouse button is no longer held
        if !GetKeyState("LButton", "P") {
            LogMessage("LButton released. Exiting loop.")
            break
        }
    }
    return
}