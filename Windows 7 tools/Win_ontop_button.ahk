#SingleInstance force
#NoEnv

/*  Widnow on top button
	● choose "On Top" switch icon with: onTopPinIcon:= (1 or 2) 
	● choose transparent: transpGUI:=1 	
	● for slow starting windows click on title bar to show the "On Top" switch icon	
*/


FileGetVersion, ver, wmploc.dll ;C:\WINDOWS\System32\wmploc.dll
RegExMatch(ver,"(\d+)\.\d+\.(\d+)", out) ;new 12.0.10240.16384 
new_wmploc:=(out1>=10 && out2>=8000) 
global onTop_ico:=new_wmploc ? 13 : 17
Menu, Tray, Icon, wmploc.dll, %onTop_ico%
#NoTrayIcon
Menu, Tray, Add, Exit , Exit 
Menu, Tray, Default, Exit 

Menu, ContextMenu, Add, Remove this, destroyGui
Menu, ContextMenu, Add, Info-this, Info_this
Menu, ContextMenu, Add,
Menu, ContextMenu, Add, Restart, Reload
Menu, ContextMenu, Add, Exit, Exit
Menu, ContextMenu, Icon, Exit, Shell32.dll, 132

SetWinDelay, -1
SetControlDelay, -1
SetBatchLines, -1

global onTopPinIcon:=2 ;pin: 1 or 2
global transpGUI:=0

global exclude_listClass:="#32770"  ; exclude class , on top button- NO 
global exclude_list:= "StikyNot.exe,regedit.exe" ; exclude processes, on top button - NO
global not_exclude_list:="taskmgr.exe,AU3_Spy.exe,SndVol.exe" ; on top button - YES ; processes from excluded class (Windows Task Manager)

;StikyNot.exe Sticky_Notes_Note_Adornment

global rel_X:=138, rel_Y:=4

if RegExMatch(A_OSVersion,"WIN_VISTA|WIN_7")
	rel_X:=130, rel_Y:=2


;=== click title bar
TCAPTION:=2	; title bar
WM_NCHITTEST := 0x0084
;===


EventHook := EWinHook_SetWinEventHook("EVENT_OBJECT_CREATE", "EVENT_OBJECT_LOCATIONCHANGE", 0, "WinProcCallback", 0, 0, "WINEVENT_OUTOFCONTEXT")
	
	OnExit(Func("ExitFunc").Bind(EventHook))
	;OnExit(Func("EWinHook_UnhookWinEvent").Bind(EventHook))

	global WS_CAPTION:=0x00C00000 , WS_BORDER:=0x00800000 , WS_SYSMENU:=0x00080000
	global WS_CHILD:=0x40000000 , WS_EX_TOOLWINDOW:=0x00000080 , WS_EX_TOPMOST := 0x00000008
	global WS_EX_NOACTIVATE:=0x08000000
	
global win_list:= Object()	
start()
;SetTimer, check_, 3000
OnMessage(0x201, "WM_LBUTTONDOWN") 
OnMessage(0x204, "WM_RBUTTONDOWN")
return


;========================================


WM_LBUTTONDOWN(){
	global win_list
	;MouseGetPos,,,Win_id, control
	if(A_Gui){
		for k,v in win_list {
			if(win_list[k].button=A_Gui){
				ownerId:=k, ctrl:=win_list[k].ctrl
				windowOnTop(ownerId,A_Gui,ctrl)
				return 0
			}
		}
	}	
}


WM_RBUTTONDOWN(){
  global last_Gui
	if(A_Gui){
		Gosub, Menu_
    last_Gui:=A_Gui
  }
}


start(){
	global win_list
	WinGet, List_, List,,, Program Manager 
	Loop, %List_%  {
		id:=List_%A_Index%
		checkWindow(id)
	}
}

checkWindow(id){
		global win_list 
		id:=Format("0x{1:x}", id) 

		if !DllCall("IsWindowVisible", "UInt", id)
			return
		if !DllCall("IsWindow", "UInt", id)
			return
		
		if(win_list.HasKey(id))
			return
		WinGet, pname, ProcessName,ahk_id %id%  
		WinGetClass, class_, ahk_id %id%  
		;WinGetTitle, Title, ahk_id %id% 
		WinGet, Style, Style, ahk_id %id%
		WinGet, ExStyle, ExStyle, ahk_id %id%
		cap:=(Style & WS_CAPTION), border:=(Style & WS_BORDER), sysmen:=(Style & WS_SYSMENU)
		child:=(Style & WS_CHILD), toolwin:=(ExStyle & WS_EX_TOOLWINDOW)	
			if(!cap || !border || !sysmen)
				return 
			if(child || toolwin)
				return
			
			if((InStr(exclude_listClass,class_) || InStr(exclude_list,pname)) && !InStr(not_exclude_list,pname)) ; dialogs, 'Save As', msg box
				return	

		GuiHwnd:=make_Gui(id)	

}



make_Gui(ownerId){
	global win_list, rel_X, rel_Y
	Gui, New, +ToolWindow -caption 	+HwndGuiHwnd 
	static G_color:="999999" 
	Gui, %GuiHwnd%: Color,%G_color%	
	Gui, %GuiHwnd%: +Owner%ownerId%
	
	WinGet, ExStyle, ExStyle, ahk_id %ownerId%
	if(ExStyle & WS_EX_TOPMOST){
		Gui, %GuiHwnd%: +AlwaysOnTop
		Gui, %GuiHwnd%: Add, Picture, x1 y0 w16 h16  +HwndonTopHwnd BackgroundTrans Icon%onTop_ico% AltSubmit, wmploc.dll
	}else{
		Gui, %GuiHwnd%: Add, Picture, x2 y0 w16 h16  +HwndonTopHwnd BackgroundTrans Icon247 AltSubmit, shell32.dll 
	}
	

	WinGetPos, x1,y1,w1,h1, ahk_id %ownerId%
	x:= (w1>300) ?  x1 + w1-rel_X : x1 + w1-120
	;x:=x1+ w1-rel_X
	y:=y1+rel_Y
	if(x && y){
		;Gui, %GuiHwnd%: Show, x%x% y%y% h16 w18 NA, DrozdTool ;NA NoActivate
		;WinActivate, ahk_id %ownerId%	
	

		WinGet, ExStyle, ExStyle, ahk_id %ownerId%

		if(ExStyle & WS_EX_TOPMOST){
			DllCall("SetWindowPos", "UInt",GuiHwnd , "Int",-1, "Int",x, "Int",y, "Int",18, "Int",16, "UInt",0x0254 ) 		
			DllCall("ShowWindow", "UInt", GuiHwnd, "Int", 8)
		}else{
			DllCall("SetWindowPos", "UInt",GuiHwnd , "Int",-2, "Int",x, "Int",y, "Int",18, "Int",16, "UInt",0x0254 )
			DllCall("ShowWindow", "UInt", GuiHwnd, "Int", 8) ; SW_SHOWNOACTIVATE:=4, SW_SHOWNA:=8
		}

		;WinActivate, ahk_id %ownerId%	
	}
		
	WinSet, ExStyle, %WS_EX_NOACTIVATE%, ahk_id %GuiHwnd%		
	
	if(transpGUI){
		WinSet, TransColor, %G_color%, ahk_id %GuiHwnd% ; transparent Gui
	}else{
		Winset, Transparent,200, ahk_id %GuiHwnd%
	}
	;WinSet, Region, 0-0 18-0 18-14 16-16 2-16 0-14 , ahk_id %GuiHwnd% 
	
	win_list[ownerId]:=Object()
	win_list[ownerId].button:=GuiHwnd
	win_list[ownerId].ctrl:=onTopHwnd
	return GuiHwnd
}



destroyButton(hwnd){
	global win_list, show_temp
	GuiHwnd:=win_list[hwnd].button
	GuiHwnd:=Format("0x{1:x}", GuiHwnd)
	if(WinExist("ahk_id " GuiHwnd)){	
		show_temp:= "`nGuiHwnd= " GuiHwnd "`nIsWindow= " DllCall("IsWindow", "UInt", GuiHwnd) "`nWin= " hwnd
		Winset, AlwaysOnTop, Off, ahk_id %GuiHwnd%
		if(WinExist("ahk_id " GuiHwnd))
			Gui, %GuiHwnd%: Destroy		
		;WinClose, ahk_id %GuiHwnd%
	}
		win_list.Delete(hwnd)
}



;================================================

WinProcCallback(hWinEventHook, event, hwnd){
	Critical
	global win_list, rel_X,rel_Y
	static x0, y0
	if !hwnd
    return
	event:=Format("0x{1:x}",event) ; decimal to hexadecimal
	hwnd:=Format("0x{1:x}",hwnd)
	if event not in 0x8000,0x8001,0x800B  ;EVENT_OBJECT_CREATE:= 0x8000, EVENT_OBJECT_DESTROY:= 0x8001, EVENT_OBJECT_LOCATIONCHANGE:= 0x800B
     return

	if(event=0x8000){ ; new window
			fn:=Func("checkWindow").Bind(hwnd)
			SetTimer, %fn% , -500	
/*  			fn:=Func("checkWindow").Bind(hwnd)
			fn2:=Func("checkWindow").Bind(hwnd)
			SetTimer, %fn% , -500
			SetTimer, %fn2% , -4000	 ; re-check		
			 */
	}else if(event=0x8001){ ; window closed
		 destroyButton(hwnd)
		
	}else if(event=0x800B){ ; move, re-size	

		if(win_list.HasKey(hwnd)){ 
			GuiHwnd:=win_list[hwnd].button
			WinGetPos, x1, y1,w1,h1, ahk_id %hwnd%

			y:=y1+rel_Y, x:= (w1>300) ?  x1 + w1-rel_X : x1 + w1-120
			if(x!=x0 || y!=y0){
				WinMove, ahk_id %GuiHwnd%,, %x%, %y%
			}
			x0:=y, y0:=x
		}	
	}		
}


;======================================

EWinHook_SetWinEventHook(eventMin, eventMax, hmodWinEventProc, lpfnWinEventProc, idProcess, idThread, dwflags) {
		Critical
    Static S_OK                              := 0x00000000, S_FALSE                           := 0x00000001
         , RPC_E_CHANGED_MODE                := 0x80010106, E_INVALIDARG                      := 0x80070057
         , E_OUTOFMEMORY                     := 0x8007000E, E_UNEXPECTED                      := 0x8000FFFF
         , EVENT_MIN                         := 0x00000001, EVENT_MAX                         := 0x7FFFFFFF
         , EVENT_SYSTEM_SOUND                := 0x0001,     EVENT_SYSTEM_ALERT                := 0x0002
         , EVENT_SYSTEM_FOREGROUND           := 0x0003,     EVENT_SYSTEM_MENUSTART            := 0x0004
         , EVENT_SYSTEM_MENUEND              := 0x0005,     EVENT_SYSTEM_MENUPOPUPSTART       := 0x0006
         , EVENT_SYSTEM_MENUPOPUPEND         := 0x0007,     EVENT_SYSTEM_CAPTURESTART         := 0x0008
         , EVENT_SYSTEM_CAPTUREEND           := 0x0009,     EVENT_SYSTEM_MOVESIZESTART        := 0x000A
         , EVENT_SYSTEM_MOVESIZEEND          := 0x000B,     EVENT_SYSTEM_CONTEXTHELPSTART     := 0x000C
         , EVENT_SYSTEM_CONTEXTHELPEND       := 0x000D,     EVENT_SYSTEM_DRAGDROPSTART        := 0x000E
         , EVENT_SYSTEM_DRAGDROPEND          := 0x000F,     EVENT_SYSTEM_DIALOGSTART          := 0x0010
         , EVENT_SYSTEM_DIALOGEND            := 0x0011,     EVENT_SYSTEM_SCROLLINGSTART       := 0x0012
         , EVENT_SYSTEM_SCROLLINGEND         := 0x0013,     EVENT_SYSTEM_SWITCHSTART          := 0x0014
         , EVENT_SYSTEM_SWITCHEND            := 0x0015,     EVENT_SYSTEM_MINIMIZESTART        := 0x0016
         , EVENT_SYSTEM_MINIMIZEEND          := 0x0017,     EVENT_SYSTEM_DESKTOPSWITCH        := 0x0020
         , EVENT_SYSTEM_END                  := 0x00FF,     EVENT_OEM_DEFINED_START           := 0x0101
         , EVENT_OEM_DEFINED_END             := 0x01FF,     EVENT_UIA_EVENTID_START           := 0x4E00
         , EVENT_UIA_EVENTID_END             := 0x4EFF,     EVENT_UIA_PROPID_START            := 0x7500
         , EVENT_UIA_PROPID_END              := 0x75FF,     EVENT_CONSOLE_CARET               := 0x4001
         , EVENT_CONSOLE_UPDATE_REGION       := 0x4002,     EVENT_CONSOLE_UPDATE_SIMPLE       := 0x4003
         , EVENT_CONSOLE_UPDATE_SCROLL       := 0x4004,     EVENT_CONSOLE_LAYOUT              := 0x4005
         , EVENT_CONSOLE_START_APPLICATION   := 0x4006,     EVENT_CONSOLE_END_APPLICATION     := 0x4007
         , EVENT_CONSOLE_END                 := 0x40FF,     EVENT_OBJECT_CREATE               := 0x8000
         , EVENT_OBJECT_DESTROY              := 0x8001,     EVENT_OBJECT_SHOW                 := 0x8002
         , EVENT_OBJECT_HIDE                 := 0x8003,     EVENT_OBJECT_REORDER              := 0x8004
         , EVENT_OBJECT_FOCUS                := 0x8005,     EVENT_OBJECT_SELECTION            := 0x8006
         , EVENT_OBJECT_SELECTIONADD         := 0x8007,     EVENT_OBJECT_SELECTIONREMOVE      := 0x8008
         , EVENT_OBJECT_SELECTIONWITHIN      := 0x8009,     EVENT_OBJECT_STATECHANGE          := 0x800A
         , EVENT_OBJECT_LOCATIONCHANGE       := 0x800B,     EVENT_OBJECT_NAMECHANGE           := 0x800C
         , EVENT_OBJECT_DESCRIPTIONCHANGE    := 0x800D,     EVENT_OBJECT_VALUECHANGE          := 0x800E
         , EVENT_OBJECT_PARENTCHANGE         := 0x800F,     EVENT_OBJECT_HELPCHANGE           := 0x8010
         , EVENT_OBJECT_DEFACTIONCHANGE      := 0x8011,     EVENT_OBJECT_ACCELERATORCHANGE    := 0x8012
         , EVENT_OBJECT_INVOKED              := 0x8013,     EVENT_OBJECT_TEXTSELECTIONCHANGED := 0x8014
         , EVENT_OBJECT_CONTENTSCROLLED      := 0x8015,     EVENT_SYSTEM_ARRANGMENTPREVIEW    := 0x8016
         , EVENT_OBJECT_END                  := 0x80FF,     EVENT_AIA_START                   := 0xA000
         , EVENT_AIA_END                     := 0xAFFF,     WINEVENT_OUTOFCONTEXT             := 0x0000
         , WINEVENT_SKIPOWNTHREAD            := 0x0001,     WINEVENT_SKIPOWNPROCESS           := 0x0002
         , WINEVENT_INCONTEXT                := 0x0004 


    ; eventMin/eventMax check
    If ( !%eventMin% || !%eventMax% )
        Return 0
    ; dwflags check
    If ( !RegExMatch( dwflags
                    , "S)^\s*(WINEVENT_(?:INCONTEXT|OUTOFCONTEXT))\s*\|\s*(WINEVENT_SKIPOWN(?:PROCESS|"
                    . "THREAD))[^\S\n\r]*$|^\s*(WINEVENT_(?:INCONTEXT|OUTOFCONTEXT))[^\S\n\r]*$"
                    , dwfArray ) )
        Return 0
    dwflags := (dwfArray1 && dwfArray2) ? %dwfArray1% | %dwfArray2% : %dwfArray3%
        
    nCheck := DllCall( "CoInitialize", "Ptr",0       )
              DllCall( "SetLastError", "UInt",nCheck ) ; SetLastError in case of success/error
              
    If ( nCheck == E_INVALIDARG || nCheck == E_OUTOFMEMORY ||  nCheck == E_UNEXPECTED )
        Return -1
    
    If ( isFunc(lpfnWinEventProc) )
        lpfnWinEventProc := RegisterCallback(lpfnWinEventProc)
        
    hWinEventHook := DllCall( "SetWinEventHook", "UInt",%eventMin%, "UInt",%eventMax%, "Ptr",hmodWinEventProc
                                               , "Ptr",lpfnWinEventProc, "UInt",idProcess, "UInt",idThread, "UInt",dwflags )
    Return (hWinEventHook) ? hWinEventHook : 0
}
; https://msdn.microsoft.com/en-us/library/windows/desktop/dd318066(v=vs.85).aspx

EWinHook_UnhookWinEvent(hWinEventHook) {
    DllCall("UnhookWinEvent", "Ptr",hWinEventHook)
    DllCall("CoUninitialize")
}



;================================================


windowOnTop(window, button,ctrl){
	WinGet, ExStyle, ExStyle, ahk_id %window%
	if(ExStyle & WS_EX_TOPMOST){
		
		;Winset, AlwaysOnTop, off, ahk_id %window%
		;Winset, AlwaysOnTop, off, ahk_id %button%
		
		DllCall("SetWindowPos", "UInt",window, "Int",-2, "Int",, "Int",, "Int",, "Int",, "UInt",0x0003 ) ;HWND_NOTOPMOST-2
		DllCall("SetWindowPos", "UInt",button, "Int",-2, "Int",, "Int",, "Int",, "Int",, "UInt",0x0217 )
		
		GuiControl,%button%:, %ctrl%  ,*icon247 *w16 *h16 shell32.dll 		
		ControlMove,, 2, , ,, ahk_id %ctrl%
	}else{
		
		;WinSet, AlwaysOnTop, on, ahk_id %window%
		;WinSet, AlwaysOnTop, on, ahk_id %button%
		
		DllCall("SetWindowPos", "UInt",window, "Int",-1, "Int",, "Int",, "Int",, "Int",, "UInt",0x0003 ) ;HWND_TOPMOST =-1
		DllCall("SetWindowPos", "UInt",button, "Int",-1, "Int",, "Int",, "Int",, "Int",, "UInt",0x0217 ) 
		

			
		if(onTopPinIcon=2){
			GuiControl,%button%:, %ctrl%  ,*icon%onTop_ico% *w16 *h16 wmploc.dll ; Icon%onTop_ico% AltSubmit, wmploc.dll
			ControlMove,,1, , ,, ahk_id %ctrl%
		}else{
			GuiControl,%button%:, %ctrl%  ,*icon248 *w16 *h16 shell32.dll ; 248 ontop
		}

	}
		;WinActivate, ahk_id %window%		
} 

		;SetWindowPos ;SWP_NOZORDER:=0x0004 , SWP_NOACTIVATE:=0x0010	, SWP_NOOWNERZORDER:=0x0200, SWP_SHOWWINDOW:=0x0040
		;SWP_NOMOVE =0x0002;SWP_NOSIZE=0x0001
;================================================

;================================================

;=== click title bar
~LButton::
	MouseGetPos,x, y, WinID_, control
	
	if(InStr(control,"MSTaskListWClass")) ; Shell_TrayWnd MSTaskListWClass1
		return
	if(win_list.HasKey(WinID_))
		return
	
	SendMessage 0x0084 , 0, (y << 16) + x , ,ahk_id %WinID_% ; WM_NCHITTEST
	NCHI_:=ErrorLevel
	if(NCHI_= TCAPTION){
		;MsgBox,4096,, % NCHI_  "`n" , 3 
		;ToolTip_(NCHI_ "`n" control "`n" win_list.HasKey(WinID_) , 2)	
		checkWindow(WinID_)		
	}
return

;================================================

check_:
	for k,v in win_list	{
	 if(!WinExist("ahk_id " k)){	
			GuiHwnd:=win_list[k].button
			if(WinExist("ahk_id " GuiHwnd)){
				Gui, %GuiHwnd%: Destroy
				ToolTip_("err",1)
			}
				win_list.Delete(k)			
		}
	}

return


restoreAll(){
	for k,v in win_list	{	
		Winset, AlwaysOnTop, Off, ahk_id %k%
	}
}

ExitFunc(hWinEventHook){
	EWinHook_UnhookWinEvent(hWinEventHook)
	;restoreAll()
}



;================================================
GuiContextMenu:
  Menu, ContextMenu, Show, %A_GuiX%, %A_GuiY%
return

Reload:
Reload
return

destroyGui:
	if(last_Gui){
		Gui, %last_Gui%: Destroy
		for k,v in win_list {
			if(win_list[k].button=last_Gui)
				Winset, AlwaysOnTop, Off, ahk_id %k%			
		}	
	}
return
		
Info_this:
	if(last_Gui){
		for k,v in win_list {
			if(win_list[k].button=last_Gui){
				WinGetTitle, Title, ahk_id %k% 
				WinGet, pname, ProcessName,ahk_id %k%
				WinGetClass, class_, ahk_id %k%  				
				MsgBox,,, %  pname ", id:"  Format("0x{1:x}", k) "`n" Title "`n" class_ "`n" A_Gui "`n" , 11  
			}
		}		
	}
return


Menu_:
;ToolTip_(A_Gui,t:=2)
return


~+^h:: Gosub, test2
~+^g:: Gosub, test


test2:
		WinGet, Win_id, ID, A
		WinGetClass, class_, ahk_id %Win_id%  
		WinGet, Style, Style, ahk_id %Win_id%
		WinGet, ExStyle, ExStyle, ahk_id %Win_id%
		cap:=(Style & WS_CAPTION), border:=(Style & WS_BORDER), sysmen:=(Style & WS_SYSMENU)
		child:=(Style & WS_CHILD), toolwin:=(ExStyle & WS_EX_TOOLWINDOW)
		MsgBox,,, % Style "`ntitle bar= " cap "`n" "border= " border  " , WS_SYSMENU= " sysmen "`nWS_CHILD= " child " , TOOLWINDOW= " toolwin  "`n" "on top= " (ExStyle & WS_EX_TOPMOST)
 
 		MsgBox,,, %	Win_id "`n" (!cap || !border || !sysmen)	"`n"		(child || toolwin)
	
return




test:
	WinGet , List_1, List, DrozdTool
	MsgBox,,, % "show_temp" show_temp "`n" List_1
	
	for k,v in win_list	{	
	WinGetTitle, Title, ahk_id %k% 
	WinGet, pname, ProcessName,ahk_id %k%  
	WinGetClass, class_, ahk_id %k%  	
	 ;MsgBox,,, % k " , " pname " , " class_ "`n" Title  "`n" ObjStr(v)
	 MsgBox,4100,, % "# " List_1 "`n" k " , " pname " , " class_ "`n" Title  "`n" ObjStr(v)
        IfMsgBox, No
            return		
/* 		if isObject(v){
			for k2,v2 in v
				MsgBox,,, % k "`n" k2 " = " v2
		}
		*/
	}
return



ObjStr(obj) {
 if(!isObject(obj))
  return false
  str:=""
 for k,v in obj
    str:=str  k " : " v ", "
 return str
}

ToolTip_(tekst,t:=2){
	GuiControlGet, Pos, Pos, edit_1
	tipX:= PosX+ 4, tipY:=PosY +2
	ToolTip, %tekst% ,%tipX%, %tipY%
	t:=t*1000
	Settimer, ToolTip_close , -%t%
}

ToolTip_close:
Settimer, ToolTip_close , Off
ToolTip
return


Exit:
;Esc::
ExitApp

