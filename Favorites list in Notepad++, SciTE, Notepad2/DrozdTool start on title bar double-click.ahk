#SingleInstance force
Menu, Tray, Icon, shell32.dll, 100
Menu, Tray, Add, Exit , Close 
Menu, Tray, Default, Exit 

WorkingDir:=A_ScriptDir

TCAPTION:=2	; title bar
WM_NCHITTEST := 0x0084

CoordMode Mouse, Screen

	GroupAdd, group_, ahk_class SciTEWindow	
	GroupAdd, group_, ahk_class Notepad++	
	GroupAdd, group_, ahk_class Notepad2U	
	GroupAdd, group_, ahk_exe Notepad2.exe
	
#IfWinActive, ahk_group group_  
~LButton:: Gosub, Click_
#If	


Click_:
MouseGetPos,x, y, Win_ID, control
if(InStr(control,"MSTaskListWClass")) ; Shell_TrayWnd MSTaskListWClass1
	return 
SendMessage 0x0084 , 0, (y << 16) + x , ,ahk_id %Win_ID% ; WM_NCHITTEST
	NCHI_:=ErrorLevel
	;if( NCHI_= TCAPTION)
		;WinSet,Style,-0x10000, ahk_id %Win_ID% ;Disable Maximize 
WinGetPos, x1,,w1,, ahk_id %Win_ID%
	x2:=x-x1
	WinGetClass, class_, ahk_id %Win_ID%  
	WinGet, pname, ProcessName,ahk_id %Win_ID%
	WinGet, PID , PID, ahk_id %Win_ID%  

	if(NCHI_ = TCAPTION){
		DetectHiddenWindows, On
		if(class_="SciTEWindow"){			;single click
			if !Is_Ctrl_in_Win("ahk_id " Win_ID)
			Run, "DrozdTool class.ahk" "not_permanent" "SciTE.exe"
		}else if(class_="Notepad++"){	
			if !Is_Ctrl_in_Win("ahk_id " Win_ID)
			Run, "DrozdTool class.ahk" "not_permanent"	"notepad++.exe"
		}else if(pname="Notepad2.exe"){	
			if !Is_Ctrl_in_Win("ahk_id " Win_ID)
				Run, "DrozdTool class.ahk" "not_permanent" "Notepad2.exe"			

/* 		}else if(class_="Photo_Lightweight_Viewer"){	
			if !Is_Ctrl_in_Win_AHK("ahk_id " Win_ID)
			Run, C:\AutoHotkey Scripts\DrozdTool PhotoViewer.ahk
 */
		}
		DetectHiddenWindows, Off
	}
	
	
/* 	if( NCHI_= TCAPTION)
		WinSet,Style,-0x10000, ahk_id %Win_ID% ;Disable Maximize 
	if(A_PriorHotKey = A_ThisHotKey && A_TimeSincePriorHotkey < 400){
		
	}
	 */
return



Is_Ctrl_in_Win(win){
	WinGet, ctrl_list, ControlList, %win% 
	Sort, ctrl_list
	str:=""
	Loop, parse, ctrl_list, `n
	{
		if InStr(A_LoopField,"AutoHotkeyGUI"){
			ControlGetText, text,%A_LoopField%, %win% 
			if InStr(text,"Drozd_AdOn") 
				return 1
		}
	} 
		return 0
}


Close:
;Esc:: 
ExitApp
	