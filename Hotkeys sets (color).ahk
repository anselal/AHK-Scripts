#SingleInstance force
Menu, Tray, Icon, Shell32.dll, 177 
;Menu, Tray,Tip , ✔ Script #2 ❷
Menu, Tray,Tip , Script #2
;#NoTrayIcon

/* 
	● Save script in unicode
	● The script creates a set of hotkeys. 
	● Each hotkey has a set of texts to send
	● can go through the set of texts which are shown in tooltip
	● "MyHotkeys" array is a set of hotkeys. like "LAlt & z", "LAlt & a", etc.
	● "hotkeys_texts" arrays contain the texts assigned to each hotkey respectively
	● For instance: 
		hotkey: "LAlt & a" 
		while pressing the left "Alt" key, press "a" key repeatedly to go through the list shown in a tooltip. 
		To paste the chosen text release the left "Alt" key
*/

;***********************   ***************************************
; Send_texts

; q w e r t 
; a s d f
; z x c v

MyHotkeys := ["LAlt & z","LAlt & a","LAlt & s","LAlt & x"]

hotkeys_texts := Object()



hotkeys_texts[1] := [ "•", "●", "✔", "？｜","∕ ∶∖","àéü","*.*",""] 
hotkeys_texts[2] := ["Rome","Berlin","Cracovia","Madrid","Athens","Paris",""] 
hotkeys_texts[3] :=["Barcelona","Real","Bayern","Wisła",""] 
hotkeys_texts[4] :=["Maradona","Ronaldinho","Messi","Ronaldo",""] 





Loop, % MyHotkeys.Length(){
	HotKey, % MyHotkeys[A_Index] , Send_text
}


 
Send_text:
    Loop, % MyHotkeys.MaxIndex(){
        TempHotkey := MyHotkeys[A_Index]          
        If (TempHotkey = A_ThisHotkey){
					Hot_keys := StrSplit(MyHotkeys[A_Index], "&", A_Space)
					key_1 := Hot_keys[1]
					key_2 := Hot_keys[2]
					texts := hotkeys_texts[A_Index]
					gosub, Send_texts
            Break                                   
        }

    }
		
	ToolTipFont("s9", "Segoe UI Semibold")
	ToolTipColor("F2EEDC", "800000")
	;ToolTipColor("F2EEDC", "000000")
return
 
Send_texts: 
	Loop, % texts.MaxIndex(){
		tip_text:= tip_text . " `n  " texts[A_Index] 
		if((A_Index==3 || A_Index==6 || A_Index==9 || A_Index==12) && texts[1]!="• "){
		tip_text:= tip_text . "`n`  ───── "
		}
	}
	tip_text := "  ¯¯¯¯" . tip_text
	
	index=1
	Paste:=tip_text
	ToolTip, % Paste
	KeyWait, % key_2
	SetTimer, 2_Key_Down_Timer, 5 
	
	KeyWait, % key_1
	SetTimer, 2_Key_Down_Timer, off
	ToolTip
	if !InStr(Paste, "¯¯¯¯"){	
/* 	clipboard_backup := clipboard
		;Clipboard:=Paste
	Clipboard:=Paste " "

	Send ^v
	clipboard := clipboard_backup
 */
	SendInput % (Paste!="") ? Paste " " : "" ; too slow
	
	}
	tip_text=
return


2_Key_Down_Timer:
	if (GetKeyState(key_2, "P") = 1){				
		if (index> texts.MaxIndex()){
			index:=1 
		}
		Paste:=texts[index]
		
		Loop, % texts.MaxIndex(){
		  if((A_Index==4 || A_Index==7 || A_Index==10 || A_Index==13)){
		  tip_text:= tip_text . "`n`  ───── "
		  }	
		  
		  if(A_Index==index && A_Index!=texts.MaxIndex()){
		  tip_text:= tip_text . " `n  " texts[A_Index] " ✔"
		  }else
		  tip_text:= tip_text . " `n  " texts[A_Index] 
		}
			
		ToolTip, % tip_text	
		index+=1
		KeyWait, %key_2%
	} 
	tip_text := ""
 return		
 

 
;===================================================
;===================================================

;~Esc:: ExitApp


 
ToolTipFont(Options := "", Name := "", hwnd := ""){ ;lexikos https://autohotkey.com/boards/viewtopic.php?t=4777
    static hfont := 0
    if (hwnd = "")
        hfont := Options="Default" ? 0 : _TTG("Font", Options, Name), _TTHook()
    else
        DllCall("SendMessage", "ptr", hwnd, "uint", 0x30, "ptr", hfont, "ptr", 0)
}
 
ToolTipColor(Background := "", Text := "", hwnd := ""){
    static bc := "", tc := ""
    if (hwnd = "") {
        if (Background != "")
            bc := Background="Default" ? "" : _TTG("Color", Background)
        if (Text != "")
            tc := Text="Default" ? "" : _TTG("Color", Text)
        _TTHook()
    }
    else {
        VarSetCapacity(empty, 2, 0)
        DllCall("UxTheme.dll\SetWindowTheme", "ptr", hwnd, "ptr", 0
            , "ptr", (bc != "" && tc != "") ? &empty : 0)
        if (bc != "")
            DllCall("SendMessage", "ptr", hwnd, "uint", 1043, "ptr", bc, "ptr", 0)
        if (tc != "")
            DllCall("SendMessage", "ptr", hwnd, "uint", 1044, "ptr", tc, "ptr", 0)
    }
}
 
_TTHook(){
    static hook := 0
    if !hook
        hook := DllCall("SetWindowsHookExW", "int", 4
            , "ptr", RegisterCallback("_TTWndProc"), "ptr", 0
            , "uint", DllCall("GetCurrentThreadId"), "ptr")
}
 
_TTWndProc(nCode, _wp, _lp) {
    Critical 999
   ;lParam  := NumGet(_lp+0*A_PtrSize)
   ;wParam  := NumGet(_lp+1*A_PtrSize)
    uMsg    := NumGet(_lp+2*A_PtrSize, "uint")
    hwnd    := NumGet(_lp+3*A_PtrSize)
    if (nCode >= 0 && (uMsg = 1081 || uMsg = 1036)) {
        _hack_ = ahk_id %hwnd%
        WinGetClass wclass, %_hack_%
        if (wclass = "tooltips_class32") {
            ToolTipColor(,, hwnd)
            ToolTipFont(,, hwnd)
        }
    }
    return DllCall("CallNextHookEx", "ptr", 0, "int", nCode, "ptr", _wp, "ptr", _lp, "ptr")
}
 
_TTG(Cmd, Arg1, Arg2 := "") {
    static htext := 0, hgui := 0
    if !htext {
        Gui _TTG: Add, Text, +hwndhtext
        Gui _TTG: +hwndhgui +0x40000000
    }
    Gui _TTG: %Cmd%, %Arg1%, %Arg2%
    if (Cmd = "Font") {
        GuiControl _TTG: Font, %htext%
        SendMessage 0x31, 0, 0,, ahk_id %htext%
        return ErrorLevel
    }
    if (Cmd = "Color") {
        hdc := DllCall("GetDC", "ptr", htext, "ptr")
        SendMessage 0x138, hdc, htext,, ahk_id %hgui%
        clr := DllCall("GetBkColor", "ptr", hdc, "uint")
        DllCall("ReleaseDC", "ptr", htext, "ptr", hdc)
        return clr
    }
}

;==================================
