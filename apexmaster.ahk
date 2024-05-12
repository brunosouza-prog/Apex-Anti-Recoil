#NoEnv
#MaxHotkeysPerInterval 99000000
#HotkeyInterval 99000000
#KeyHistory 0
#SingleInstance force
#MaxThreadsBuffer on
#Persistent
Process, Priority, , A
SetBatchLines, -1
ListLines Off
SetWorkingDir %A_ScriptDir%
SetKeyDelay, -1, -1
SetMouseDelay, -1
SetDefaultMouseSpeed, 0
SetWinDelay, -1
SetControlDelay, -1
SendMode Input

global UUID := "05ca9afc92a1412ca2d872ddf6ebe497"

RunAsAdmin()
GoSub, IniRead
HideProcess()

; weapon type constant, mainly for debuging
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
global WINGMAN_WEAPON_TYPE := "WINGMAN"
global G7_WEAPON_TYPE := "G7"
global CAR_WEAPON_TYPE := "CAR"
global P3030_WEAPON_TYPE := "3030"
global SHOTGUN_WEAPON_TYPE := "shotgun"
global SNIPER_WEAPON_TYPE := "sniper"
global SHEILA_WEAPON_TYPE := "shiela"

; x, y pos for weapon1 and weapon 2
global WEAPON_1_PIXELS := LoadPixel("weapon1")
global WEAPON_2_PIXELS := LoadPixel("weapon2")

; weapon color
global LIGHT_WEAPON_COLOR := 0x2D547D
global HEAVY_WEAPON_COLOR := 0x596B38
global ENERGY_WEAPON_COLOR := 0x286E5A
global SUPPY_DROP_COLOR_NORMAL := 0x3701B2
global SUPPY_DROP_COLOR_PROTANOPIA := 0x714AB2
global SUPPY_DROP_COLOR_DEUTERANOPIA := 0x1920B2
global SUPPY_DROP_COLOR_TRITANOPIA := 0x312E90
global SHOTGUN_WEAPON_COLOR := 0x07206B
global SNIPER_WEAPON_COLOR := 0x8F404B
global SHEILA_WEAPON_COLOR := 0xA13CA1
global SUPPY_DROP_COLOR := SUPPY_DROP_COLOR_NORMAL
global colorblind
if (colorblind == "Protanopia") {
    SUPPY_DROP_COLOR := SUPPY_DROP_COLOR_PROTANOPIA
} else if (colorblind == "Deuteranopia") {
    SUPPY_DROP_COLOR := SUPPY_DROP_COLOR_DEUTERANOPIA
} else if (colorblind == "Tritanopia") {
    SUPPY_DROP_COLOR := SUPPY_DROP_COLOR_TRITANOPIA
}

; light weapon
global R99_PIXELS := LoadPixel("r99")
global ALTERNATOR_PIXELS := LoadPixel("alternator")
global R301_PIXELS := LoadPixel("r301")
global P2020_PIXELS := LoadPixel("p2020")
global RE45_PIXELS := LoadPixel("re45")
global G7_PIXELS := LoadPixel("g7")
global SPITFIRE_PIXELS := LoadPixel("spitfire")
; heavy weapon
global FLATLINE_PIXELS := LoadPixel("flatline")
global PROWLER_PIXELS := LoadPixel("prowler")
global RAMPAGE_PIXELS := LoadPixel("rampage")
global HEMLOK_PIXELS := LoadPixel("hemlok")
global P3030_PIXELS := LoadPixel("p3030")
; special
global CAR_PIXELS := LoadPixel("car")
; energy weapon
global DEVOTION_PIXELS := LoadPixel("devotion")
global DEVOTION_TURBOCHARGER_PIXELS := LoadPixel("devotion_turbocharger")
global HAVOC_PIXELS := LoadPixel("havoc")
global HAVOC_TURBOCHARGER_PIXELS := LoadPixel("havoc_turbocharger")
global NEMESIS_PIXELS := LoadPixel("nemesis")
global NEMESIS_FULL_CHARGE_PIXELS := LoadPixel("nemesis_full_charge")
global VOLT_PIXELS := LoadPixel("volt")
global LSTAR_PIXELS := LoadPixel("lstar")
; sniper weapon
global WINGMAN_PIXELS := LoadPixel("wingman")
; single mode
global SINGLE_MODE_PIXELS := LoadPixel("single_mode")

; each player can hold 2 weapons
LoadPixel(name) {
    global resolution
    IniRead, weapon_pixel_str, %A_ScriptDir%\resolution\%resolution%.ini, pixels, %name%
    weapon_num_pixels := []
    Loop, Parse, weapon_pixel_str, `,
    {
        if StrLen(A_LoopField) == 0 {
            Continue
        }
        weapon_num_pixels.Insert(A_LoopField)
    }
    return weapon_num_pixels
}

; load pattern from file
LoadPattern(filename) {
    FileRead, pattern_str, %A_ScriptDir%\pattern\%filename%
    pattern := []
    Loop, Parse, pattern_str, `n, `, , `" ,`r 
    {
        if StrLen(A_LoopField) == 0 {
            Continue
        }
        pattern.Insert(A_LoopField)
    }
    return pattern
}

; light weapon pattern
global R301_PATTERN := LoadPattern("R301.txt")
global R99_PATTERN := LoadPattern("R99.txt")
global P2020_PATTERN := LoadPattern("P2020.txt")
global RE45_PATTERN := LoadPattern("RE45.txt")
global G7_Pattern := LoadPattern("G7.txt")
global SPITFIRE_PATTERN := LoadPattern("Spitfire.txt")
global ALTERNATOR_PATTERN := LoadPattern("Alternator.txt")
; energy weapon pattern
global DEVOTION_PATTERN := LoadPattern("Devotion.txt")
global TURBODEVOTION_PATTERN := LoadPattern("DevotionTurbo.txt")
global HAVOC_PATTERN := LoadPattern("Havoc.txt")
global VOLT_PATTERN := LoadPattern("Volt.txt")
global NEMESIS_PATTERN = LoadPattern("Nemesis.txt")
global NEMESIS_CHARGED_PATTERN = LoadPattern("NemesisCharged.txt")
; special
global CAR_PATTERN := LoadPattern("CAR.txt")
; heavy weapon pattern
global FLATLINE_PATTERN := LoadPattern("Flatline.txt")
global RAMPAGE_PATTERN := LoadPattern("Rampage.txt")
global RAMPAGEAMP_PATTERN := LoadPattern("RampageAmp.txt")
global PROWLER_PATTERN := LoadPattern("Prowler.txt")
global P3030_PATTERN := LoadPattern("3030.txt")
; sinper weapon pattern
global WINGMAN_PATTERN := LoadPattern("Wingman.txt")
; supply drop weapon pattern
global LSTAR_PATTERN := LoadPattern("Lstar.txt")
global HEMLOK_PATTERN := LoadPattern("Hemlok.txt")
global HEMLOK_SINGLE_PATTERN := LoadPattern("HemlokSingle.txt")
; sheila
global SHEILA_PATTERN := LoadPattern("Sheila.txt")

; voice setting
SAPI:=ComObjCreate("SAPI.SpVoice")
SAPI.rate:=7
SAPI.volume:=80

; weapon detection
global current_pattern := ["0,0,0"]
global current_weapon_type := DEFAULT_WEAPON_TYPE
global current_weapon_num := 0
global is_single_mode := false

; mouse sensitivity setting
zoom := 1.0/zoom_sens
global modifier := 4/sens*zoom

; check whether the current weapon match the weapon pixels
CheckWeapon(weapon_pixels)
{
    target_color := 0xFFFFFF
    i := 1
    loop, 3 {
        PixelGetColor, check_point_color, weapon_pixels[i], weapon_pixels[i + 1]
        if (weapon_pixels[i + 2] != (check_point_color == target_color)) {
            return False
        }
        i := i + 3
    }
    return True
}

CheckTurbocharger(turbocharger_pixels)
{
    target_color := 0xFFFFFF
    PixelGetColor, check_point_color, turbocharger_pixels[1], turbocharger_pixels[2]
    if (check_point_color == target_color) {
        return true
    }
    return false
}

IsNemesisFullCharge()
{
    target_color := 0xD6BD62
    PixelGetColor, check_point_color, NEMESIS_FULL_CHARGE_PIXELS[1], NEMESIS_FULL_CHARGE_PIXELS[2]
    if (check_point_color == target_color) {
        return true
    }
    return false
}

CheckSingleMode()
{
    target_color := 0xFFFFFF
    PixelGetColor, check_point_color, SINGLE_MODE_PIXELS[1], SINGLE_MODE_PIXELS[2]
    if (check_point_color == target_color) {
        return true
    }
    return false
}

Reset()
{
    is_single_mode := false
    current_weapon_type := DEFAULT_WEAPON_TYPE
    check_point_color := 0
    current_weapon_num := 0
}

IsShiela()
{
    PixelGetColor, check_weapon2_color, WEAPON_2_PIXELS[1], WEAPON_2_PIXELS[2]
    return check_weapon2_color == SHEILA_WEAPON_COLOR
}

SetShiela()
{
    current_weapon_type := SHEILA_WEAPON_TYPE
    current_pattern := SHEILA_PATTERN
    global debug
    if (debug) {
        Say(current_weapon_type)
    }
}

IsValidWeaponColor(weapon_color)
{
    return weapon_color == LIGHT_WEAPON_COLOR || weapon_color == HEAVY_WEAPON_COLOR || weapon_color == SNIPER_WEAPON_COLOR 
    || weapon_color == ENERGY_WEAPON_COLOR || weapon_color == SUPPY_DROP_COLOR || weapon_color == SHOTGUN_WEAPON_COLOR
}

DetectAndSetWeapon()
{
    Reset()
    
    if IsShiela() {
        SetShiela()
        return
    }

    is_single_mode := CheckSingleMode()

    ; first check which weapon is activate
    PixelGetColor, weapon1_color, WEAPON_1_PIXELS[1], WEAPON_1_PIXELS[2]
    PixelGetColor, weapon2_color, WEAPON_2_PIXELS[1], WEAPON_2_PIXELS[2]
    if (IsValidWeaponColor(weapon1_color)) {
        check_point_color := weapon1_color
        current_weapon_num := 1
    } else if (IsValidWeaponColor(weapon2_color)) {
        check_point_color := weapon2_color
        current_weapon_num := 2
    } else {
        return
    }

    ; then check the weapon type
    if (check_point_color == LIGHT_WEAPON_COLOR) {
        if (CheckWeapon(R301_PIXELS)) {
            current_weapon_type := R301_WEAPON_TYPE
            current_pattern := R301_PATTERN
        } else if (CheckWeapon(R99_PIXELS)) {
            current_weapon_type := R99_WEAPON_TYPE
            current_pattern := R99_PATTERN
        } else if (CheckWeapon(P2020_PIXELS)) {
            current_weapon_type := P2020_WEAPON_TYPE
            current_pattern := P2020_PATTERN
        } else if (CheckWeapon(RE45_PIXELS)) {
            current_weapon_type := RE45_WEAPON_TYPE
            current_pattern := RE45_PATTERN
        } else if (CheckWeapon(ALTERNATOR_PIXELS)) {
            current_weapon_type := ALTERNATOR_WEAPON_TYPE
            current_pattern := ALTERNATOR_PATTERN
        } else if (CheckWeapon(CAR_PIXELS)) { 
            current_weapon_type := CAR_WEAPON_TYPE 
            current_pattern := CAR_PATTERN 
        } else if (CheckWeapon(G7_PIXELS)) {
            current_weapon_type := G7_WEAPON_TYPE
            current_pattern := G7_Pattern
        } else if (CheckWeapon(SPITFIRE_PIXELS)) {
            current_weapon_type := SPITFIRE_WEAPON_TYPE
            current_pattern := SPITFIRE_PATTERN 
        } else if (CheckWeapon(RE45_PIXELS)) {
            current_weapon_type := RE45_WEAPON_TYPE
            current_pattern := RE45_PATTERN
        }
    } else if (check_point_color == HEAVY_WEAPON_COLOR) {
        if (CheckWeapon(FLATLINE_PIXELS)) {
            current_weapon_type := FLATLINE_WEAPON_TYPE
            current_pattern := FLATLINE_PATTERN
        } else if (CheckWeapon(PROWLER_PIXELS)) {
            current_weapon_type := PROWLER_WEAPON_TYPE
            current_pattern := PROWLER_PATTERN
        } else if (CheckWeapon(RAMPAGE_PIXELS)) {
            current_weapon_type := RAMPAGE_WEAPON_TYPE
            current_pattern := RAMPAGE_PATTERN
        } else if (CheckWeapon(CAR_PIXELS)) { 
            current_weapon_type := CAR_WEAPON_TYPE 
            current_pattern := CAR_PATTERN 
        } else if (CheckWeapon(P3030_PIXELS)) {
            current_weapon_type := P3030_WEAPON_TYPE 
            current_pattern := P3030_PATTERN
        } else if (CheckWeapon(HEMLOK_PIXELS)) {
            current_weapon_type := HEMLOK_WEAPON_TYPE
            current_pattern := HEMLOK_PATTERN
            if (is_single_mode) {
                current_weapon_type := HEMLOK_SINGLE_WEAPON_TYPE
                current_pattern := HEMLOK_SINGLE_PATTERN
            }
        }
    } else if (check_point_color == ENERGY_WEAPON_COLOR) {
        if (CheckWeapon(VOLT_PIXELS)) {
            current_weapon_type := VOLT_WEAPON_TYPE
            current_pattern := VOLT_PATTERN
        } else if (CheckWeapon(HAVOC_PIXELS)) {
            current_weapon_type := HAVOC_WEAPON_TYPE
            current_pattern := HAVOC_PATTERN
            if (CheckTurbocharger(HAVOC_TURBOCHARGER_PIXELS)) {
                current_weapon_type := HAVOC_TURBO_WEAPON_TYPE
            }
        } else if (CheckWeapon(NEMESIS_PIXELS)) {
            current_weapon_type := NEMESIS_WEAPON_TYPE
            current_pattern := NEMESIS_PATTERN
            if (IsNemesisFullCharge()) {
                current_weapon_type := NEMESIS_CHARGED_WEAPON_TYPE
                current_pattern := NEMESIS_CHARGED_PATTERN
            }
        } else if (CheckWeapon(LSTAR_PIXELS)) {
            current_weapon_type := LSTAR_WEAPON_TYPE
            current_pattern := LSTAR_PATTERN
        }
    } else if (check_point_color == SUPPY_DROP_COLOR) {
        if (CheckWeapon(DEVOTION_PIXELS)) {
            current_pattern := TURBODEVOTION_PATTERN
            current_weapon_type := DEVOTION_TURBO_WEAPON_TYPE
        }
    } else if (check_point_color == SHOTGUN_WEAPON_COLOR) {
        current_weapon_type := SHOTGUN_WEAPON_TYPE
    } else if (check_point_color == SNIPER_WEAPON_COLOR) {
        current_weapon_type := SNIPER_WEAPON_TYPE
    }

    global debug
    if (debug) {
        Say(current_weapon_type)
    }
}

IsAutoClickNeeded() 
{
    global auto_fire
    return auto_fire && (current_weapon_type == P2020_WEAPON_TYPE || current_weapon_type == HEMLOK_SINGLE_WEAPON_TYPE)
}

~$*E Up::
~$*B::
    Sleep, 300
    DetectAndSetWeapon()
return

~$*1::
~$*2::
~$*R::
    Sleep, 100
    DetectAndSetWeapon()
return

~$*3::
~$*G Up::
    Reset()
return

~$*Z::
    Sleep, 400  
    if IsShiela() {
        SetShiela()
    } else {
        Reset()
    }
return

~$*End::
    ExitApp
return

~$*LButton::
    if (IsMouseShown() || current_weapon_type == DEFAULT_WEAPON_TYPE || current_weapon_type == SHOTGUN_WEAPON_TYPE || current_weapon_type == SNIPER_WEAPON_TYPE)
        return

    if (is_single_mode && !(IsAutoClickNeeded()))
        return

    if (ads_only && !GetKeyState("RButton"))
        return

    if (trigger_only && !GetKeyState(trigger_button,"T"))
        return

    if (current_weapon_type == HAVOC_WEAPON_TYPE) {
        Sleep, 400
    }
    
    if (current_weapon_type == NEMESIS_WEAPON_TYPE || current_weapon_type == NEMESIS_CHARGED_WEAPON_TYPE)
    {
        if (IsNemesisFullCharge()) {
            current_weapon_type := NEMESIS_CHARGED_WEAPON_TYPE
            current_pattern := NEMESIS_CHARGED_PATTERN
        } else {
            current_weapon_type := NEMESIS_WEAPON_TYPE
            current_pattern := NEMESIS_PATTERN
        }
    }

    Loop {
        x := 0
        y := 0
        interval := 20
        if (A_Index <= current_pattern.MaxIndex()) {
            compensation := StrSplit(current_pattern[Min(A_Index, current_pattern.MaxIndex())],",")
            if (compensation.MaxIndex() < 3) {
                return
            }
            x := compensation[1]
            y := compensation[2]
            interval := compensation[3]
        }

        if (IsAutoClickNeeded()) {
            Click
            Random, rand, 1, 20
            interval := interval + rand
        }
        
        DllCall("mouse_event", uint, 0x01, uint, Round(x * modifier), uint, Round(y * modifier))
        if (debug) {
            ToolTip % x " " y " " a_index
        }
        
        Sleep, interval

        if (!GetKeyState("LButton","P")) {
            break
        }
    }
return

~$+c::
    if (IsMouseShown() || !superglide) {
        Send, {Blind}{c down}
        return
    }
    Send, {Space}
    Sleep, 1
    Send, {Control down}
    KeyWait, c
    Send {Control up}
return

IniRead:
    IfNotExist, settings.ini
    {
        MsgBox, Couldn't find settings.ini. I'll create one for you.

        IniWrite, "1920x1080", settings.ini, screen settings, resolution
        IniWrite, "Normal"`n, settings.ini, screen settings, colorblind
        IniWrite, "5.0", settings.ini, mouse settings, sens
        IniWrite, "1.0", settings.ini, mouse settings, zoom_sens
        IniWrite, "1", settings.ini, mouse settings, auto_fire
        IniWrite, "0"`n, settings.ini, mouse settings, ads_only
        IniWrite, "0", settings.ini, trigger settings, trigger_only
        IniWrite, "Capslock"`n, settings.ini, trigger settings, trigger_button
        IniWrite, "0", settings.ini, other settings, superglide
        IniWrite, "0", settings.ini, other settings, debug
        Run "apexmaster.ahk"
    }
    Else {
        IniRead, resolution, settings.ini, screen settings, resolution
        IniRead, colorblind, settings.ini, screen settings, colorblind
        IniRead, zoom_sens, settings.ini, mouse settings, zoom_sens
        IniRead, sens, settings.ini, mouse settings, sens
        IniRead, auto_fire, settings.ini, mouse settings, auto_fire
        IniRead, ads_only, settings.ini, mouse settings, ads_only
        IniRead, trigger_only, settings.ini, trigger settings, trigger_only
        IniRead, trigger_button, settings.ini, trigger settings, trigger_button
        IniRead, superglide, settings.ini, other settings, superglide
        IniRead, debug, settings.ini, other settings, debug
    }
return

; Suspends the script when mouse is visible ie: inventory, menu, map.
IsMouseShown()
{
    StructSize := A_PtrSize + 16
    VarSetCapacity(InfoStruct, StructSize)
    NumPut(StructSize, InfoStruct)
    DllCall("GetCursorInfo", UInt, &InfoStruct)
    Result := NumGet(InfoStruct, 8)

    if Result > 1
        return true
    else
        Return false
}

ActiveMonitorInfo(ByRef X, ByRef Y, ByRef Width, ByRef Height)
{
    CoordMode, Mouse, Screen
    MouseGetPos, mouseX, mouseY
    SysGet, monCount, MonitorCount
    Loop %monCount% {
        SysGet, curMon, Monitor, %a_index%
        if ( mouseX >= curMonLeft and mouseX <= curMonRight and mouseY >= curMonTop and mouseY <= curMonBottom ) {
            X := curMonTop
            y := curMonLeft
            Height := curMonBottom - curMonTop
            Width := curMonRight - curMonLeft
            return
        }
    }
}

Say(text)
{
    global SAPI
    SAPI.Speak(text, 1)
    sleep 150
return
}

Tooltip(Text)
{
    ActiveMonitorInfo(X, Y, Width, Height)
    xPos := Width / 2 - 50
    yPos := Height / 2 + (Height / 10)
    Tooltip, %Text%, xPos, yPos
return
}

RunAsAdmin()
{
    Global 0
    IfEqual, A_IsAdmin, 1, Return 0

    Loop, %0%
        params .= A_Space . %A_Index%

    DllCall("shell32\ShellExecute" (A_IsUnicode ? "":"A"),uint,0,str,"RunAs",str,(A_IsCompiled ? A_ScriptFullPath : A_AhkPath),str,(A_IsCompiled ? "": """" . A_ScriptFullPath . """" . A_Space) params,str,A_WorkingDir,int,1)
    ExitApp
}

HideProcess() 
{
    if ((A_Is64bitOS=1) && (A_PtrSize!=4))
        hMod := DllCall("LoadLibrary", Str, "hyde64.dll", Ptr)
    else if ((A_Is32bitOS=1) && (A_PtrSize=4))
        hMod := DllCall("LoadLibrary", Str, "hyde.dll", Ptr)
    else
    {
        MsgBox, Mixed Versions detected!`nOS Version and AHK Version need to be the same (x86 & AHK32 or x64 & AHK64).`n`nScript will now terminate!
        ExitApp
    }

    if (hMod)
    {
        hHook := DllCall("SetWindowsHookEx", Int, 5, Ptr, DllCall("GetProcAddress", Ptr, hMod, AStr, "CBProc", ptr), Ptr, hMod, Ptr, 0, Ptr)
        if (!hHook)
        {
            MsgBox, SetWindowsHookEx failed!`nScript will now terminate!
            ExitApp
        }
    }
    else
    {
        MsgBox, LoadLibrary failed!`nScript will now terminate!
        ExitApp
    }
return
}

ExitSub:
    if (hHook)
    {
        DllCall("UnhookWindowsHookEx", Ptr, hHook)
        MsgBox, % "Process unhooked!"
    }
    if (hMod)
    {
        DllCall("FreeLibrary", Ptr, hMod)
        MsgBox, % "Library unloaded"
    }
ExitApp
