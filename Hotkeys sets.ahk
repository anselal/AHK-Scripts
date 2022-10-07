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



hotkeys_texts[1] := [ "•", "●", "✔", " $T","？ ∕ ∶∖","àéü","*.*",""] 
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

return
 
Send_texts: 
	Loop, % texts.MaxIndex(){
		tip_text:= tip_text . " `n  " texts[A_Index] 
		if((A_Index==3 || A_Index==6 || A_Index==9 || A_Index==12) && texts[1]!="• "){
		tip_text:= tip_text . "`n`   ---------- "
		}
	}
	tip_text := "   ¯¯¯¯" . tip_text
	
	index=1
	Paste:=tip_text
	ToolTip, % Paste
	KeyWait, % key_2
	SetTimer, 2_Key_Down_Timer, 5 
	
	KeyWait, % key_1
	SetTimer, 2_Key_Down_Timer, off
	ToolTip
	if !InStr(Paste, "¯¯¯¯"){	

	clipboard_backup := clipboard
	if(RegExMatch(Paste, "i)\$T")){
		Clipboard:=Paste
	}else{
		Clipboard:=Paste " "
	}
	Send ^v
	clipboard := clipboard_backup

	;SendInput % Paste " " ; too slow  
	;SendInput % WinActive("ahk_class CabinetWClass") ?  RegExReplace(Paste,"i)•","") " " : Paste " " 
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
		  tip_text:= tip_text . "`n`   ---------- "
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







