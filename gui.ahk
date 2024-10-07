; environment settings
#Requires AutoHotkey v2.0
#SingleInstance force
#MaxThreadsBuffer on
SendMode Input
SetWorkingDir A_ScriptDir
DetectHiddenWindows On
SetTitleMatchMode RegEx

; default variables
global version := "3.0.0"
global resolution := "1920x1080"
global colorblind := "Normal"
global sens := "5.0"
global zoom_sens := "1.0"
global auto_fire := "1"
global ads_only := "0"
global debug := "1"
global error_level := "error"
global trigger_only := "0"
global trigger_button := "Capslock"
global superglide := "1"
global tempFilePath := A_ScriptDir "\debug_log.txt"
global UUID := GenerateUUID() ; Start with a random UUID

; Clear the debug log file at the start of the script
if FileExist(tempFilePath) {
    FileDelete(tempFilePath)
}
FileAppend("Script Version " version "`n", tempFilePath)

; First, read the settings from the ini file
ReadIni()

; To avoid any issues, lets regenerate the UUID since it was moved into the settings.ini
if (UUID == "") {
    UUID := GenerateUUID()  ; Regenerate UUID
}

; Make sure it runs as admin
RunAsAdmin()

; Convert sens to slider format
global slider_sen := sens * 10

; GUI
LogMessage("Initializing GUI...")

; Create a new GUI window
MyGui := Gui("New", "Apex NoRecoil Settings v" version)

; Set the font and title for the window
MyGui.SetFont("s24 wBold", "Verdana")
MyGui.Add("Text", "Center w400", "Apex NoRecoil")

; Add a UUID section with smaller font size and place "Regenerate UUID" button below it
MyGui.SetFont("s10", "Verdana")
UUIDText := MyGui.Add("Text", "x20 y60 w350", "UUID: " UUID)  ; Display UUID
MyGUIBtn := MyGui.Add("Button", "Center w190 h30", "Regenerate UUID")

; Add a separator for sectioning off parts of the GUI
MyGui.Add("Text", "x20 y130 Center w400", "----------------------------------------")

; Add Sensitivity Slider below the separator
MyGui.SetFont("s10", "Verdana")
MyGui.Add("Text", "x20 y160", "Mouse Sensitivity:")
MySlider := MyGui.Add("Slider", "x150 y155 w200 range0-200 tickinterval1 vsens", slider_sen)
MySlider.Value := slider_sen  ; Set the slider to reflect the current sensitivity value

; Add toggle checkboxes (3 rows)
MyGui.SetFont("s10", "Verdana")
MyGui.Add("CheckBox", "x20 y200 w105 h25 vauto_fire", "Auto Fire").Value := auto_fire
MyGui.Add("CheckBox", "x125 y200 w105 h25 vads_only", "ADS Only").Value := ads_only
MyGui.Add("CheckBox", "x230 y200 w115 h25 vsuperglide", "Superglide").Value := superglide

; Separate line for Debug checkbox
MyGui.Add("CheckBox", "x20 y240 w100 h25 vdebug", "Debug").Value := debug

; Error Level Dropdown (below Debug checkbox)
MyGui.Add("Text", "x20 y280", "Error Level:")
ErrorLevelDDL := MyGui.Add("DropDownList", "x150 y275 w100 verror_level Choose" ChooseItem(error_level), ["info", "error"])

; Trigger Mode on a separate row above Trigger Button
MyGui.Add("CheckBox", "x20 y320 w150 h25 vtrigger_only", "Trigger Mode").Value := trigger_only
MyGui.Add("Text", "x20 y360", "Trigger Button:")

; Dropdown for Trigger Button with pre-selection
TriggerButtonDDL := MyGui.Add("DropDownList", "x150 y355 w100 vtrigger_button Choose" ChooseItem(trigger_button), ["Capslock", "NumLock", "ScrollLock"])

; Add a dropdown for resolution settings with pre-selection
MyGui.Add("Text", "x20 y400", "Resolution:")
resolutions := ["1280x720", "1366x768", "1600x900", "1920x1080", "2560x1440", "3840x2160", "customized"]
ResolutionDDL := MyGui.Add("DropDownList", "x150 y395 w150 vresolution Choose" ChooseItem(resolution), resolutions)

; Add Colorblind Mode dropdown with pre-selection
MyGui.Add("Text", "x20 y440", "Colorblind Mode:")
ColorblindDDL := MyGui.Add("DropDownList", "x150 y435 w150 vcolorblind Choose" ChooseItem(colorblind), ["Normal", "Protanopia", "Deuteranopia", "Tritanopia"])

; Add Save and Run Button
MyGui.SetFont("s12 wBold", "Verdana")
MyBtn := MyGui.Add("Button", "Center w190 h40", "Save and Run!")

; Adjust and center the GUI on the screen
MyGui.Show("AutoSize Center", "Apex NoRecoil Settings")

LogMessage("GUI initialization complete.")

; Event handling
LogMessage("Adding Event handling...")
MyGUIBtn.OnEvent("Click", (*) => RegenerateUUID(UUIDText))
MyBtn.OnEvent("Click", (*) => btSave())
MySlider.OnEvent("Change", (*) => Slide())
MyGui.OnEvent("Close", (*) => GuiClose())

; Function to regenerate UUID and update the GUI
RegenerateUUID(UUIDText) {
    global UUID
    UUID := GenerateUUID()  ; Regenerate UUID
    UUIDText.Text := "UUID: " UUID  ; Update UUID text in GUI
    LogMessage("New UUID generated: " UUID)
}

Slide() {
    sens := MySlider.Value() / 10
	ToolTip(sens)
	SetTimer () => ToolTip(), -500
}

btSave() {
	global UUID ; Make sure it's visible
	
    Saved := MyGui.Submit()
	 
	; Adjust the sensitivity value before saving
    sens := Saved.sens / 10
	
    IniWrite(Saved.resolution, "settings.ini", "screen settings", "resolution")
    IniWrite(Saved.colorblind, "settings.ini", "screen settings", "colorblind")
    IniWrite(sens, "settings.ini", "mouse settings", "sens")
    IniWrite(Saved.auto_fire, "settings.ini", "mouse settings", "auto_fire")
    IniWrite(Saved.ads_only, "settings.ini", "mouse settings", "ads_only")
    IniWrite(Saved.trigger_only, "settings.ini", "trigger settings", "trigger_only")
    IniWrite(Saved.trigger_button, "settings.ini", "trigger settings", "trigger_button")
    IniWrite(Saved.debug, "settings.ini", "other settings", "debug")
    IniWrite(Saved.error_level, "settings.ini", "other settings", "error_level")
    IniWrite(UUID, "settings.ini", "other settings", "UUID")
    IniWrite(Saved.superglide, "settings.ini", "other settings", "superglide")
	
	; Run KeySharp with apexmaster.ahk as a parameter
    keysharpPath := "Keysharp.exe" ; Adjust this path as needed
    scriptPath := A_ScriptDir "\apexmaster.ahk" ; Path to your AHK script
    Run('"' keysharpPath '" "' scriptPath '"')
	
    ExitApp()
}

GuiClose() {
    ExitApp()
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

; Helper function to return Choose item index
ChooseItem(currentValue) {
    if (currentValue = "Capslock" or currentValue = "1280x720" or currentValue = "Normal" or currentValue = "info") {
        return 1
    } else if (currentValue = "NumLock" or currentValue = "1366x768" or currentValue = "Protanopia" or currentValue = "error") {
        return 2
    } else if (currentValue = "ScrollLock" or currentValue = "1600x900" or currentValue = "Deuteranopia") {
        return 3
    } else if (currentValue = "1920x1080" or currentValue = "Tritanopia") {
        return 4
    } else if (currentValue = "2560x1440") {
        return 5
    } else if (currentValue = "3840x2160") {
        return 6
    } else if (currentValue = "customized") {
        return 7
    }
    return 1  ; Default to the first option if not matched
}

ActiveMonitorInfo(&X, &Y, &Width, &Height) {
	monCount := MonitorGetCount()
    MouseGetPos(&mouseX, &mouseY)
    
    Loop monCount {
		MonitorGetWorkArea(A_Index, &WL, &WT, &WR, &WB)
        if mouseX >= WL && mouseX <= WR && mouseY >= WT && mouseY <= WB {
            X := WL
			Y := WT
			Width := WR - WL
			Height := WB - WT
			return
        }
    }
    
	X := 0
	Y := 0
	Width := 0
	Height := 0
	return
}

ReadIni() {
    global resolution, colorblind, zoom_sens, sens, auto_fire, ads_only, debug, error_level, trigger_only, trigger_button, version, UUID, superglide ; Make sure it's visible
    
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
        IniWrite("0", iniFilePath, "other settings", superglide)
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
        superglide := ReadIniValue(iniFilePath, "other settings", "superglide")
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
        LogMessage("superglide=" superglide)
        LogMessage("trigger_only=" trigger_only)
        LogMessage("trigger_button=" trigger_button)
    }
}

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
            LogMessage("[ERROR] Manual read failed for " key)
    }
    return Trim(StrReplace(value.ToString(), '"'))
}

ManualIniRead(iniFilePath, section, key) {
    LogMessage("Starting ManualIniRead. File: " iniFilePath ", Section: " section ", Key: " key)
    
    content := FileRead(iniFilePath)
    
    if (content) {
        LogMessage("File content successfully read.")
    } else {
        LogMessage("[ERROR] Failed to read file content.")
        return ""
    }

    section_found := false
    for line in StrSplit(content, "`n") {
        line := Trim(line)
        LogMessage("Processing line: " line)

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

RunAsAdmin() {
    LogMessage("RunAsAdmin called.")
    
    if (A_IsAdmin) {
        LogMessage("Already running as Admin.")
        return 0
    }

    MsgBox("v" version " - Please run the script as administrator.")

    ExitSub()
}

LogMessage(message) {
    global debug, tempFilePath, version
    
    if (debug == "1") {
        try {
            if (!FileExist(tempFilePath)) {
                FileAppend("", tempFilePath)  ; Create if the file does not exist
            }
            FileAppend("v" version " - " message "`n", tempFilePath)
        } catch {
            MsgBox("v" version " - Error writing to log file.")
        }
    }
}

ExitSub() {
    global version
    
    LogMessage("Exiting application.")
    MsgBox("v" version " - Exiting application!")
    
    ExitApp()
}