/*
● "DrozdTool class" creates buttons for lists of 'favorites' in Notepad++, SciTE, Notepad2	
● For each program a new script must be made , 	by default it's set for Notepad++ 
	i.e. DrozdTool class SciTE.ahk , DrozdTool class Notepad++.ahk , DrozdTool class Notepad2.ahk
●	CHOOSE below: MainProgram := Notepad++.exe, SciTE.exe or Notepad2.exe  
	CHOOSE program paths: Scite_path:=... , Notepad_plus_path:=... , Notepad2_path:=...	
	CHOOSE number of buttons and names for buttons: ButtonSet[1].button:="Scripts", etc.
	for instance: "Scripts", "Temp","INI files", etc
	ButtonSet[1].addToEnd:=1 - add new item to the top or bottom
	
● Those scripts may run permanently and detect the launch of the program (MainProgram="Notepad++.exe").		
●	Or it may be launched with parameter "not_permanent" to start (it closes when program closes)
	For this case I use another script "start on title bar double-click"
  with commands like: Run, "DrozdTool class.ahk" "not_permanent" "SciTE.exe"
●	When working as a single script, it creates a different set of lists for each program
● Shortcuts:
  Shift click on button - add add to list  ;toaddToList()
  Alt click on button - add  separator   ;addToList("separator") 

● Last button - open menu : sort, Manage items order, add separator, Open file's folder, Open in...
● "Edit in DrozdRichEditor" - select a word and open in this editor to select all instances of the word (not necessary in Notepad++)
	;https://autohotkey.com/boards/viewtopic.php?f=6&t=53021#p243638
*/

#SingleInstance force
Menu, Tray, Icon, shell32.dll,  209 ;285
Menu, Tray, Add, Exit , Close 
Menu, Tray, Default, Exit 

;#NoTrayIcon
SetWinDelay, -1
SetControlDelay, -1
SetWorkingDir %A_ScriptDir%
FileEncoding, UTF-8


global MainProgram

;CHOOSE program. MainProgram := "Notepad++.exe"", "SciTE.exe"" or "Notepad2.exe""

MainProgram :="notepad++.exe"
;MainProgram :="SciTE.exe"
;MainProgram :="Notepad2.exe"

global rel_X:=270, rel_Y:=2 
;===========================

;CHOOSE program paths 
global Scite_path:="C:\Program Files\AutoHotkey\SciTE\SciTE.exe"
global Notepad_plus_path:="C:\Program Files (x86)\Notepad++\notepad++.exe"
global Notepad2_path:="C:\Program Files\Misc\Notepad2\Notepad2.exe"

global DrozdRichEditor_path:="C:\AutoHotkey Scripts\RichEdit Editor.ahk" ;https://autohotkey.com/boards/viewtopic.php?f=6&t=53021#p243638

;===========================

global maxNum:=60
global width_1:=500
global single_ico:=0 ; icon on all rows or on single row
global rel_X_LB:=40
;===========================

global param1, param2
param1= %1% 
param2= %2% 

if(param2)
MainProgram:=param2 

SetWorkingDir, %A_ScriptDir% 
WorkingDir:=A_ScriptDir
;global settings_ini :=A_ScriptDir "\DrozdTool.ini" 
global settings_ini := WorkingDir "\DrozdTool " StrReplace(MainProgram, ".exe", "") ".ini" 


	GroupAdd, group_, ahk_exe %MainProgram% 
	
;===========================

global DrozdTools:= Object() 
global ButtonObj:= Object()
global ButtonSet:= Object()

;CHOOSE number of buttons and names

ButtonSet[1]:= Object(), 
ButtonSet[1].button:="Scripts", ButtonSet[1].iniBlock:="Script list", ButtonSet[1].addToEnd:=1
ButtonSet[2]:= Object()
ButtonSet[2].button:="Temp", ButtonSet[2].iniBlock:="Temp script list", ButtonSet[2].addToEnd:=0

ButtonSet[3]:= Object()
ButtonSet[3].button:="JavaScript", ButtonSet[3].iniBlock:="JavaScript list", ButtonSet[3].addToEnd:=1
ButtonSet[4]:= Object()
ButtonSet[4].button:="INI", ButtonSet[4].iniBlock:="INI files list", ButtonSet[4].addToEnd:=1

;===========================

global ParentID, Win_id, GuiHwnd, But_id1, But_id2,But_id3,But_id4
global listGuis:="", listCtrls:="" , objListIDs:= Object() 
;global del_ico=0
	

;param1:="not_permanent" ;temp test

if(param1="not_permanent"){
	WinGet, WinP_ID,ID , % "ahk_exe " MainProgram
	WinGetClass, class_, ahk_id %WinP_ID% 
	if(class_="#32770"){
		WinP_ID:=DllCall("GetWindow", "Uint",WinP_ID, "Int",GW_OWNER:=4)
	}
	if !WinP_ID
		return
	ParentID:=WinP_ID
	make_Gui(ParentID)	
}

Gosub, ContextMenuMake

DllCall("RegisterShellHookWindow", "UInt",A_ScriptHwnd )
MsgNum := DllCall("RegisterWindowMessage", "Str","SHELLHOOK")
OnMessage(MsgNum,"ShellMessage")

OnMessage(0x100, "WM_KEYDOWN")
OnMessage(0x200, "WM_MOUSEMOVE")
return

WM_MOUSEMOVE(){
  MouseGetPos,x,y,, control,3		
	if control in %listCtrls% 	
	{
		select(control)
		;fn := Func("select").Bind(control)
		;SetTimer, % fn, -50
  }
}

select(ListBox_id){
	VarSetCapacity(POINT,8,0)
	DllCall("GetCursorPos","Ptr",&POINT)
	DllCall("ScreenToClient","Ptr",ListBox_id,"Ptr",&POINT)
	x:=NumGet(POINT,0,"Int")
	y:=NumGet(POINT,4,"Int")
		
	SendMessage,0x018B,0,0, ,% "ahk_id " ListBox_id ;LB_GETCOUNT:=0x018B
	len:=ErrorLevel
	SendMessage,0x01A1,1,0, ,% "ahk_id " ListBox_id ;LB_GETITEMHEIGHT:=0x01A1
	row_height:= ErrorLevel
	num:=Floor(y/row_height)
	;ToolTip_(x " , " y "`n" num "`n" row_height " , " len  ,1,1)
	
	SendMessage,0x0186,%num% ,0, ,% "ahk_id " ListBox_id ;LB_SETCURSEL:= 0x0186
	;del_icons(ListBox_id)
}


WM_KEYDOWN(wParam, lParam){	
	if(A_Gui==6){
		if(wParam = 13){ ; VK_ENTER := 13
		}else	if(wParam = 27){ ; Esc  
		}else	if(wParam = 46){ ;  del 	
			Gosub, remove_item
		}
	}
}

ShellMessage(wParam,lParam){
	Critical
  global WinP_ID
	if(wParam=1){   ;  HSHELL_WINDOWCREATED = 1  ; new program started
    ;WinGet, PID, PID , ahk_id %lParam%
		WinGetClass, class_, ahk_id %lParam%  	
    WinGet, pname, ProcessName,ahk_id %lParam%  	
		id:=Format("0x{1:x}", lParam) ; decimal to hexadecimal

		if(InStr(pname,MainProgram)){	
			ParentID:=id
			make_Gui(ParentID)
		}else if(RegExMatch(class_,"i)CabinetWClass")){ 
				fn:=Func("selectInWindow").Bind(id)
				SetTimer, %fn% , -500       
		}
  }

  if(wParam=2){ ; HSHELL_WINDOWDESTROYED=2 ; program stopped
		id:=Format("0x{1:x}",lParam) ; decimal to hexadecimal
    ;WinGet, PID, PID , ahk_id %id%
    ;WinGet, pname, ProcessName,ahk_id %id%
		if(id==WinP_ID){
			;if win_list.HasKey(hwnd){
			if(param1=="not_permanent"){
				ExitApp
			}else{
			}
		}
  } 
}

make_Gui(ParentID){
	Gui, New, +HwndGuiHwnd 
	Gui,%GuiHwnd%:Margin, 0,0
	Gui,%GuiHwnd%:+ToolWindow -Caption +AlwaysOnTop
	Gui,%GuiHwnd%: Font, s8 w400 , MS Shell Dlg		 
 
	for index, val in ButtonSet {			
			hwnd_:="But_id" index
			if(index=1)
				Gui,%GuiHwnd%:Add, Button, x0 y0  h20 +HWND%hwnd_% , % ButtonSet[index].button
			else
				Gui,%GuiHwnd%:Add, Button, x+0 y0  h20 +HWND%hwnd_% , % ButtonSet[index].button
			
			ButtonObj[index]:= New DrozdTool(%hwnd_%, ButtonSet[index].iniBlock, ButtonSet[index].addToEnd,GuiHwnd)
	}	

	;----------------------
	Gui,%GuiHwnd%:Add, Button, x+0 y0 w20 h20  +HWNDBut_id3 gOptions , % Chr(9679) ;● 
	WinGetPos, x1,y1,w1,h1, ahk_id %ParentID%
	Gui,%GuiHwnd%: +Parent%ParentID% 
	x:=w1-rel_X, y:=rel_Y
	add_name:="Drozd_AdOn_" RegExReplace(MainProgram,"i)\.exe","")
	Gui,%GuiHwnd%:Show,  x%x% y%y%  NA , %add_name%
		
}

Class DrozdTool {	
	__New(hwnd,block,addToEnd,GuiHwnd) {
		this.hwnd:=hwnd
		this.addToEnd:=addToEnd
		this.INIblock:=block
		this.GuiHwnd:=GuiHwnd
		
		fn:=this.Show_.Bind(this)
		GuiControl, +g, % this.hwnd, % fn		

		this.GuiList(this, block)
		listCtrls:= (listCtrls!="") ? listCtrls "," hwnd : hwnd	
	}

	GuiList(parent, block){		
			Gui, New, +HwndGui_Hwnd +ToolWindow -caption 	
			Gui,%Gui_Hwnd%:Color,%G_color%
			Gui,%Gui_Hwnd%:Margin, 0,0
			Gui,%Gui_Hwnd%:Font, S9 Q5  , Segoe UI 	

			queries:=""			
			Loop, % maxNum {
			 IniRead, name , %settings_ini%, %block%, %A_Index%
				if(name=="ERROR" || name=="")
				 continue				
				queries:= queries "|" name 
				queries:=RegExReplace(queries,"^\|","")
			}

			;Gui,%Gui_Hwnd%:Add, DropDownList, x0 y0 w%width_1%  +HWNDList_id  , %queries% ;% "1|2|3|4|" Gui_Hwnd ;%queries% vList_1
			arr1:=StrSplit(queries,"|"), len:=arr1.Length() 
			Gui,%Gui_Hwnd%:Add, ListBox, x0 y0 w%width_1%   +HWNDList_id  , %queries%
			
			;fn:=this.List_Func.Bind(this)
			fn:=ObjBindMethod(this, "List_Func")
			GuiControl, +g, % List_id, % fn

			WinGetPos, x1,y1,w1,h1, ahk_id %ParentID%
			x:=w1-rel_X, y:=rel_Y

			Gui,%Gui_Hwnd%:Show, Hide , % "Drozd_Tool_" Gui_Hwnd
			;Gui,%Gui_Hwnd%: Hide
			this.GuiListHwnd := Gui_Hwnd
			this.ListHwnd:=List_id

			listGuis:= (listGuis!="") ?  listGuis "," Gui_Hwnd : Gui_Hwnd
			listCtrls:= (listCtrls!="") ? listCtrls "," List_id : List_id		
			
/* 			CtrlHwnd:=List_id
			VarSetCapacity(CB_info, 40 + (3 * A_PtrSize), 0)
			NumPut(40 + (3 * A_PtrSize), CB_info, 0, "UInt")
			DllCall("User32.dll\GetComboBoxInfo", "Ptr", CtrlHwnd, "Ptr", &CB_info)
			List_id := NumGet(CB_info, 40 + (2 * A_PtrSize), "Ptr") ; 56/48			
			 */
			 
			List_id:=Format("0x{1:x}",List_id) 
			
			objListIDs[List_id]:=List_id			
			this.List_id:=List_id
			ThreadId := DllCall("GetWindowThreadProcessId", "Int", List_id, "UInt*", PID)	

		
		this.EventHook:=DllCall("SetWinEventHook","UInt",0x8006,"UInt",0x8006,"Ptr",0,"Ptr"
							,RegisterCallback("WinProcCallback")	,"UInt", PID,"UInt", ThreadId,"UInt", 0)  

			OnExit(Func("UnhookWinEvent").Bind(this.EventHook))	
	}
	
	Show_(){
		ParentID:=DllCall("GetParent", "UInt",this.GuiHwnd) 
		
		if(GetKeyState("Shift", "P")==1){ 
			this.addToList()
		;}else if(GetKeyState("Ctrl", "P")==1){	
		}else if(GetKeyState("Alt", "P")==1){	
			this.addToList("separator")	 
			return
		}else{

			SendMessage,0x018B,0,0, ,% "ahk_id " this.ListHwnd ;LB_GETCOUNT:=0x018B
			len:=ErrorLevel
			SendMessage,0x01A1,1,0, ,% "ahk_id " this.ListHwnd ;LB_GETITEMHEIGHT:=0x01A1
			row_height:= ErrorLevel
			new_height:=row_height*len +row_height* 3/4 ;
			
			;WinGetPos, x1,y1,w1,h1, % "ahk_id " GuiHwnd 
			WinGetPos, x2, y2, w, h, % "ahk_id " this.hwnd ;But_id1		
			;x:=x2-width_1, y:=y2 ; left
			x:=x2-width_1+w+rel_X_LB, y:=y2+20 ; below button
			Gui_Hwnd:=this.GuiListHwnd
			Gui,%Gui_Hwnd%:Show
			WinMove, % "ahk_id " this.GuiListHwnd,, %x%, %y%, ,% new_height-6
			GuiControl, Move, % this.ListHwnd, % "h" new_height 			
			
/* 			WinGetPos, x2, y2, w, h, % "ahk_id " this.hwnd ;But_id1		
			x:=x2-width_1, y:=y2
			Gui_Hwnd:=this.GuiListHwnd
			Gui,%Gui_Hwnd%:Show
			WinMove, % "ahk_id " this.GuiListHwnd,, %x%, %y%
			SendMessage,0x014F,1,0, , % "ahk_id " this.ListHwnd ;CB_SHOWDROPDOWN:=0x014F
			 */
		}
	}
	
	List_Func(hwnd){
		GuiControlGet, item ,, % hwnd
		
		del:=this.ComboDel(hwnd)
			if(del==1)
				return
		FilePath:=item
		if FileExist(FilePath){
			OpenFile(FilePath)
		}else
			MsgBox,4096,, % "File does not exist"  "`n" FilePath
	}


	ComboDel(hwnd){
		VarSetCapacity(POINT,8,0)
		DllCall("GetCursorPos","Ptr",&POINT)
		DllCall("ScreenToClient","Ptr",hwnd,"Ptr",&POINT)
		x:=NumGet(POINT,0,"Int")
		y:=NumGet(POINT,4,"Int") 

		GuiControlGet, Pos, Pos, %hwnd%
		GuiControlGet, item_,,	%hwnd%
		if InStr(item_,"------------"){
			MsgBox,4096,, %  "Delete separators in ""Manage items order"" menu" , 2 
			return 1
		}
		if(PosW-x<20){
			MsgBox, 0x00040003, , Do you want to delete this item? `n%item_% ;+100 "No" as default
				IfMsgBox, No
					return 1
				IfMsgBox Cancel
					return 1
				
		GuiControl, +AltSubmit, %hwnd%
		GuiControlGet, line_,, %hwnd%
		Control, Delete, %line_%,, ahk_id %hwnd%
		GuiControl, -AltSubmit, %hwnd%     
		ToolTip_("Deleted item:" "`n" item_ , 1)
		this.del_in_ini(item_)
				return 1	
		}
		return 0 
	}

	del_in_ini(item){
		block:=this.INIblock
		item:=Trim(item)
		Loop, % maxNum {
			IniRead, read_ , %settings_ini%, %block%, %A_Index%
				if(read_=="ERROR" || read_=="")
					continue
				if(read_==item){
					IniDelete, %settings_ini%, %block%, %A_Index% 
					break
				}		
		}
		sortINI(block)
		;sortNumberingINI(block)
	}
	
	
	addToList(sep:=""){
		block:=this.INIblock
		delEmptyItemsINI(block)
		sortINI(block)
		;sortNumberingINI(block)
		to_end:=this.addToEnd
		if(sep="separator"){
			FilePath:="----------------------------------------------------------------------"
		}else
		FilePath:=get_path()		
		
		if(to_end=1){
			;---- add to end ---
			Loop, % maxNum {
				IniRead, read_ , %settings_ini%, %block% , %A_Index%
					if(read_=="ERROR" || read_==""){
						IniWrite, %FilePath% , %settings_ini%, %block%, %A_Index% 
						;MsgBox,4096,, % A_Index  "`n" FilePath
						break
				}			
			}	
		}else{
			;---- add to begining ---
			IniRead, block_ , %settings_ini%, %block%, ;%A_Index%
				text_out:=""
				Loop, Parse, block_, "`r`n"  
				{		
					;if(RegExMatch(A_LoopField,"^\s*$"))
						;continue
					RegExMatch(A_LoopField,"^(\d+)=",out)
					repl:=out1+1 "="
					line_:=RegExReplace(A_LoopField,out, repl)		
					text_out:= text_out line_ "`n"
				}
				text_out:=  "1=" FilePath  "`n" text_out
				IniWrite, %text_out% , %settings_ini%, %block%
			
		}
		sortINI(block)
		
		queries:=""
		Loop, % maxNum  {
		 IniRead, name , %settings_ini%, %block%, %A_Index%	 
			if(name=="ERROR" || name=="")
			 continue		
			queries:= queries "|" name 
			queries:=RegExReplace(queries,"^\|","")
		}
		queries:=  "|" queries   ; "|"- replace old
		
		ListHwnd:=this.ListHwnd 
		GuiControl, , %ListHwnd%, %queries%
		
				;---- 
			ToolTip_("Added to " "Script list""`n" FilePath,1,0)	
	}
}


;===================================

WinProcCallback(hWinEventHook, event, hwnd, idObject, idChild, dwEventThread, dwmsEventTime){
  Critical 
  if !hwnd
    return
  event:=Format("0x{1:x}",event) ; decimal to hexadecimal
	hwnd:=Format("0x{1:x}",hwnd) 
	;ToolTip % "event= " event "`n" "hwnd= " hwnd
	;EVENT_OBJECT_REORDER:= 0x8004, EVENT_OBJECT_FOCUS:= 0x8005, EVENT_OBJECT_SELECTION:= 0x8006
	if(event=0x8006){ ;EVENT_OBJECT_SELECTION
		del_icons(hwnd,del_ico)
		return 0
	}
}

UnhookWinEvent(hWinEventHook){
  DllCall("UnhookWinEvent", "Ptr",hWinEventHook)
  DllCall("CoUninitialize")
}

;====================================================



del_icons(List_id,del_ico:=0){
	List_id:=objListIDs[List_id]
	
	SendMessage,0x018B,0,0, ,% "ahk_id " List_id ;LB_GETCOUNT:=0x018B
	len:=ErrorLevel
	SendMessage,0x01A1,1,0, ,% "ahk_id " List_id ;LB_GETITEMHEIGHT:=0x01A1
	row_height:= ErrorLevel
	if(del_ico)
		iconOnWin(List_id,len,row_height)
	else
		textOnWin(List_id,len,row_height,"X")
}


textOnWin(hwnd, len,row_h,text_:="X"){
	hDC := DllCall("User32.dll\GetDC", "Ptr", hwnd)

	WinGetPos, x, y, W, H, ahk_id %hwnd% 
	x:=W-14,y:=0
	heightF:=12, weight:=400,fontName:="Arial"  ;"Segoe Print"
	widthF:=6
	hFont:=DllCall("CreateFont", "Int", heightF,"Int",widthF, "Int", 0, "Int", 0,"Int", weight, "Uint", 0,"Uint", 0,"uint", 0, "Uint", 0, "Uint", 0, "Uint", 0, "Uint", 0, "Uint", 0, "str", fontName)
	DllCall("SelectObject", "UPtr", hDC, "UPtr", hFont, "UPtr")
	colorR:=0x0000BB
	colorG:=0xAFAFAF

 

	VarSetCapacity(POINT,8,0)
	DllCall("GetCursorPos","Ptr",&POINT)
	DllCall("ScreenToClient","Ptr",hwnd,"Ptr",&POINT)
	PosX:=NumGet(POINT,0,"Int"),		PosY:=NumGet(POINT,4,"Int") 
		
	colorR:=0x0000EE
	m:=2
	y:=m
	Loop, % len {

		if(PosY>=y-m && PosY<y+row_h-m){
			DllCall("SetTextColor", "UPtr", hDC, "UInt",colorR )
			DllCall("SetBkMode","Ptr",hDC,"Int",1) ;TRANSPARENT:=1, 2
			;DllCall("SetBkColor", "UPtr", hDC, "UInt", 0xFFFFFF)
			DllCall("TextOut", "uint",hDC, "int",x, "int",y, "str",text_, "int",StrLen(text_)) 		
		}else{	
			if(!single_ico){
				DllCall("SetTextColor", "UPtr", hDC, "UInt",colorG )
				DllCall("SetBkMode","Ptr",hDC,"Int",1) ;TRANSPARENT := 1
				DllCall("TextOut", "uint",hDC, "int",x, "int",y, "str",text_, "int",StrLen(text_)) 
			}
		}
		y+=row_h
	}

	DllCall("DeleteObject", "UPtr", hFont)
	DllCall("ReleaseDC", "Uint", hwnd, "Uint", hDC)
}


;==============================================
iconOnWin(hwnd,len,row_h){
	hIcon:=LoadPicture("C:\AutoHotkey Scripts\icons\test\Close_16x16.ico","",ImageType)
	;hIcon:=LoadPicture("shell32.dll","Icon132 w16 h-1" ,ImageType) ; Win8
	hIcon:=LoadPicture("imageres.dll","Icon162 w16 h-1" ,ImageType) ; Win7
	
	hDC := DllCall("User32.dll\GetDC", "Ptr", hwnd)
	
	WinGetPos, x, y, W, H, ahk_id %hwnd% 
	x:=W-18,y:=0
	VarSetCapacity(POINT,8,0)
	DllCall("GetCursorPos","Ptr",&POINT)
	DllCall("ScreenToClient","Ptr",hwnd,"Ptr",&POINT)
	PosX:=NumGet(POINT,0,"Int"),		PosY:=NumGet(POINT,4,"Int")

	cxWidth:=cyWidth:=0
	m:=0
	y:=m
	Loop, % len {
		if(PosY>=y-m && PosY<y+row_h-m){
			RC:=DllCall("DrawIconEx","Ptr",hDC,"Int",x ,"Int",y ,"Ptr",hIcon ,"Int",cxWidth ,"Int",cyWidth ,"UInt",0 ,"Ptr",0,"UInt",0x3)
		}
		y+=row_h
	}

	DllCall("ReleaseDC", "Uint", CtrlHwnd, "Uint", hDC)	
}

;====================================================


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

;============================

#IfWinActive, ahk_group group_  
~LButton:: Gosub, click_title_bar
#If

click_title_bar:
CoordMode Mouse, Screen
MouseGetPos ,x,y, Win_ID
;=== click title bar
/* 	if(InStr(control,"MSTaskListWClass")) ; Shell_TrayWnd MSTaskListWClass1
		return 
	 */
	SendMessage 0x0084 , 0, (y << 16) + x , ,ahk_id %Win_ID% ; WM_NCHITTEST
	NCHI_:=ErrorLevel
	if(NCHI_ = 2){  ;TCAPTION:=2	
		;DetectHiddenWindows, On
		WinGet, pname, ProcessName,ahk_id %Win_ID%
		if(InStr(pname,MainProgram)){	
				if !Is_Ctrl_in_Win("ahk_id " Win_ID){
					ParentID:=Win_ID
					make_Gui(ParentID)
				}
		}
	}
return

;========================

~LButton::
	MouseGetPos,x,y, Win_ID, control , 3
	if control not in %listCtrls%
	{
		SetTimer, Hide_ , -100 			
	}		
return

Hide_:
	arr:=StrSplit(listGuis,",") 
	str:=""
	Loop, % arr.Length(){
		WinHide, % "ahk_id " arr[A_Index]
	}
return

;==================


OpenFile(FilePath){
	WinGet, pname, ProcessName, ahk_id %ParentID% 
	WinGetClass, class_, ahk_id %ParentID% 	
	
	if(class_="SciTEWindow"){			;SciTE.exe
		Edit_in_Scite(FilePath)	
	}else if(class_="Notepad++"){	 ; Notepad++ , notepad++.exe
		Run , "%Notepad_plus_path%" "%FilePath%"
	}else if(pname="Notepad2.exe"){	
		Run , "%Notepad2_path%" /r "%FilePath%"	
	}
}




get_path(){
	clipboard_backup:=clipboard
	clipboard:=""	
	WinGet, pname, ProcessName, ahk_id %ParentID% 
	WinGetClass, class_, ahk_id %ParentID% 	
	
	if(class_="SciTEWindow"){			;SciTE.exe
		SendMessage,0x0111,118,,, ahk_id %ParentID% ; ahk_class SciTEWindow ;copy path	
	}else if(class_="Notepad++"){	 ; notepad++.exe
		SendMessage, 0x111, 42029,,, ahk_id %ParentID% ;ahk_class Notepad++ ;copy path
	}else if(pname="Notepad2.exe"){	
		SendMessage,0x0111,20032,,, ahk_id %ParentID% ;copy path
		;SendMessage,0x0111,20032,,,ahk_class Notepad2U ;copy path	
	}
	FilePath:=clipboard
	clipboard:= clipboard_backup
	FilePath:=Trim(FilePath)
	return FilePath
}


get_selection(){
	clipboard_backup:=clipboard
	clipboard:=""	
	WinGet, pname, ProcessName, ahk_id %ParentID% 
	WinGetClass, class_, ahk_id %ParentID% 	
	
	if(class_="SciTEWindow"){			;SciTE.exe
		SendMessage,0x0111,204,,, ahk_id %ParentID% ; ahk_class SciTEWindow ;copy
	}else if(class_="Notepad++"){	 ; notepad++.exe
		SendMessage, 0x111, 42002,,, ahk_id %ParentID% ;ahk_class Notepad++ ;copy
	}else if(pname="Notepad2.exe"){	
		SendMessage,0x0111,40303,,, ahk_id %ParentID% ;ahk_class Notepad2U ;copy	
	}
	selection:=clipboard
	clipboard:= clipboard_backup
	selection:=Trim(selection)
	return selection
}



;==================

sort_INI_items:
	RegExMatch(A_ThisMenuItem,"i)Sort ini items \((.+)\)", out) 
	block:=out1
	delEmptyItemsINI(block)
	sortINI(block)
return

	sort_INI_items(block){
		delEmptyItemsINI(block)
		sortINI(block)
	}

sortINI(block){
	obj:=Object()
	;IniRead, read_ , %settings_ini%, %block%,
	
	Loop, % maxNum {
   IniRead, name_ , %settings_ini%, %block%, %A_Index%
    if(name_=="ERROR" || name_=="")
			continue
		obj[A_Index]:=name_
	}	 
	 
	block_2:=""
	for index, val in obj {
		block_2:=block_2  A_Index "=" obj[index] "`n" 
			
	}
	IniWrite, %block_2% , %settings_ini%, %block% 
}

sortNumberingINI(block){
	;IniRead, read_ , %settings_ini%, %block%,
	Loop, % maxNum {
   IniRead, name , %settings_ini%, %block%, %A_Index%
    if(name=="ERROR" || name==""){
			ind:=A_Index
			Loop, % maxNum {
				if(A_Index<=ind)
					continue
				IniRead, name_ , %settings_ini%, %block%, %A_Index%
				if(name_!="ERROR"){
					IniWrite, %name_% , %settings_ini%, %block%, %ind%
					IniDelete, %settings_ini%, %block%, %A_Index%
					break
				}
			}     
		}else{
			IniWrite, %name% , %settings_ini%, %block%, %A_Index%
		}
	}
}

delEmptyItemsINI(block){
	IniRead, block_1 , %settings_ini%, %block%
	Loop, % maxNum {
   IniRead, name , %settings_ini%, %block% , %A_Index%
    if(name=="ERROR")
     continue
		if(name==""){
			IniDelete, %settings_ini%, %block% , %A_Index%
		}
	}
}

;==============================================

Edit_in_Scite(FilePath){
  Process, Exist, SciTE.exe
  PID := Errorlevel
  if !PID{
    Run , %Scite_path%
    WinWaitActive, ahk_class SciTEWindow
  }
  Run , "%Scite_path%" "%FilePath%"
}

Edit_in_Scite:
	FilePath:=get_path()
	Edit_in_Scite(FilePath)
return

Edit_in_Notepad2:
	FilePath:=get_path()
  Run , "%Notepad2_path%" "%FilePath%"
return

Edit_in_Notepad_plus:
	FilePath:=get_path()
  Run , "%Notepad_plus_path%" "%FilePath%"
return

Edit_in_DrozdRichEditor:
	FilePath:=get_path()
	selection:=get_selection()	
  Run , "%DrozdRichEditor_path%" "%FilePath%" "%selection%" "R"
  ;Run , "%DrozdRichEditor_path%" "%FilePath%"
return

open_folder:
	FilePath:=get_path()
	arr:=StrSplit(FilePath,"\") 
	FilePath:=StrReplace(FilePath, arr[arr.Length()], "")
	SlectFilePath:=arr[arr.Length()]
	Run, Explorer.exe "%FilePath%"
return

selectInWindow(hwnd){
  global SlectFilePath
	FileName:=SlectFilePath
  SlectFilePath:=""
	win := GetShellFolder(hwnd)
  fold_path:=win.Document.Folder.Self.Path 
	win.Document.SelectItem(win.Document.Folder.ParseName(FileName), 1|4|8)
}

GetShellFolder(Win_id){
  for win in ComObjCreate("Shell.Application").Windows  {
    if(win.hwnd == Win_id)
      return win
  }			
}
;==============================================

Open_ini:
Run, %settings_ini%
return


Options:
ParentID:=ParID:=DllCall("GetParent", "UInt",A_Gui) 
ContextMenuShow:
	;ControlGetPos x, y, , , %GuiButID%
	Menu, ContextMenu, Show, ;%x%, %y%
return

;==============================================

ContextMenuMake:
	Menu, ContextMenu, Add,
	Menu, ContextMenu, DeleteAll
	Menu, Settings, Add,
	Menu, Settings, DeleteAll
	
	Menu, Settings, Add, Manage items order ,GUI_sort_ini
 	Menu, Settings, Add,
	
	for index, val in ButtonSet {			
		menu_:=ButtonSet[index].iniBlock
		Menu, ContextMenu, Add, Add to "%menu_%" , add_to_List
		Menu, ContextMenu, Icon, Add to "%menu_%" , Shell32.dll, 69		
	 
		Menu, SortIniBlocks, Add, %menu_%, sort_INI_items
		Menu, SortIniBlocks, Icon,%menu_% , Shell32.dll, 72	
		
	}
	 
	Menu, Settings, Add,  Sort ini items , :SortIniBlocks
	
	
	for index, val in ButtonSet {			
		menu_:=ButtonSet[index].iniBlock
		Menu, AddSeparator, Add, "%menu_%" , add_separator
	}	
	Menu, Settings, Add, Add separator to... , :AddSeparator
	
	Menu, ContextMenu, Add,
	
	if FileExist(Notepad_plus_path){
		Menu, ContextMenu, Add, Open in Notepad++ , Edit_in_Notepad_plus
		Menu, ContextMenu, Icon , Open in Notepad++ , %Notepad_plus_path%
		}
	if FileExist(Scite_path){
		Menu, ContextMenu, Add , Edit in Scite , Edit_in_Scite	
		Menu, ContextMenu, Icon , Edit in Scite , %Scite_path%
	}
	if FileExist(Notepad2_path){
		Menu, ContextMenu, Add, Open in Notepad2 , Edit_in_Notepad2	
		Menu, ContextMenu, Icon , Open in Notepad2 , %Notepad2_path%
	}

	if FileExist(DrozdRichEditor_path){
		Menu, ContextMenu, Add, Open in DrozdRichEditor , Edit_in_DrozdRichEditor	
		Menu, ContextMenu, Icon , Open in DrozdRichEditor , shell32.dll,71 
	}	
	
	Menu, ContextMenu, Add,
	Menu, ContextMenu, Add, Open file's folder, open_folder
	Menu, ContextMenu, Icon, Open file's folder, Shell32.dll, 4

	Menu, ContextMenu, Add,

	;Menu, Settings, Add, Delete empty lines in ini file, delEmptyLines
	;Menu, Settings, Icon, Delete empty lines in ini file , Shell32.dll, 72
	Menu, Settings, Add,
	Menu, Settings, Add, Open settings file , Open_ini
	Menu, Settings, Icon, Open settings file , Shell32.dll, 70
	Menu, ContextMenu, Add, Misc, :Settings 

	Menu, ContextMenu, Add,
	;Menu, ContextMenu, Add, Open settings file , Open_ini
	;Menu, ContextMenu, Icon, Open settings file , Shell32.dll, 70
	Menu, ContextMenu, Add, Exit , Exit 
	Menu, ContextMenu, Icon, Exit , Shell32.dll, 132
return

;==============================================


add_to_List:
RegExMatch(A_ThisMenuItem,"i)Add to ""(.+)""", out) 

	for index, val in ButtonSet {	
		if(ButtonSet[index].iniBlock=out1){
				ind:=index
				break
		}
	}
	ButtonObj[ind].addToList()
return

add_separator:
	ini_list:=RegExReplace(A_ThisMenuItem,"""","") 
	for index, val in ButtonSet {	
		if(ButtonSet[index].iniBlock=ini_list){
				ind:=index
				break
		}
	}
	ButtonObj[ind].addToList("separator")
return



;==============================================


GUI_sort_ini:
for index, val in ButtonSet { 
	Menu, ScriptMenu, Add, % ButtonSet[index].iniBlock , ini_blocks_choose
	Menu, MenuBar, Add, INI blocks, :ScriptMenu 
	Gui,6: Menu, MenuBar
}

Gui,6: Default 
Gui,6: Margin, 0,0

Gui,6:Add, Button, x10 y3   gOpen_ini , Open
Gui,6:Add, Picture, x+20 y7 w18 h16  gRefresh BackgroundTrans Icon239 AltSubmit, shell32.dll 
Gui,6:Add, Button, x+40 y3   gSort vB1, Sort ; 
Gui,6:Add, Button, x+20 y3   gmove_to_row , Move to  # ; 
Gui,6:Add, Button, x+10 y3   gremove_item , Delete ; 
Gui,6:Add, Button, x+10 y3   gadd_separatorINI , Separator ; 


;Gui,6: +HWNDGuiHwnd_ ; +AlwaysOnTop
			
Gui,6:ListView, LV_1
Gui,6: Add, ListView,x0 y30 w520 h500  vLV_1 gClickListView +HWNDList_1Hwnd, Item|#
LV_ModifyCol(1,480)
LV_ModifyCol(2,36)
LV_ModifyCol(2,"Center")

Gui,6: Font, s8 w400 , MS Shell Dlg ;Consolas 
;Gui,6: Add, Text ,x140 y8 w40 c900000 vNum Center,
Gui,6: Add, StatusBar
Gui,6: Show, w520 h552 , Sort INI tool - Drozd

ini_block:= ButtonSet[1].iniBlock
makeList(ini_block)
SB_SetIcon("Shell32.dll", 70)
SB_SetParts(100,420),SB_SetText("  ini file block:",1,1)
SB_SetText(ini_block,2,0)
OnMessage(0x100, "WM_KEYDOWN")
OnMessage(0x404, "AHK_NOTIFYICON")


return

;==============================================


makeList(block){
	Gosub, ContextMenuMake
	Gui,6:ListView, LV_1
	LV_Delete()
	GuiControl,, Num ,
	
	ImgListID_3 := IL_Create(30)  
	LV_SetImageList(ImgListID_3)  
	;block:="AutoHotkey"
;	sortINI(block)	
	i:=1
	
	Loop, % maxNum  {
   IniRead, name , %settings_ini%, %block%, %A_Index%
		if(name=="ERROR" || name=="")
     continue
		LV_Add("" , name, A_Index) 
	 
	}
}

;====================================

Refresh:
	block:= ini_block
	sortINI(block)
	makeList(block)
return


;====================================

remove_item:
	block:= ini_block
	;sortINI(block)
	;makeList(block)
	row_now:=LV_GetNext(0) ;selected row number 
	LV_GetText(FilePath,row_now , 1)
	if row_now=0
		return
	IniRead, name_ , %settings_ini%, %block%, %row_now% 
	MsgBox, 0x00040003, , Remove this item? `n%name_%`nRow # %row_now% ;+100 "No" as default
		IfMsgBox, No
			return
		IfMsgBox Cancel
			return
	
	IniDelete, %settings_ini%, %block%, %row_now%
	
	sortINI(block)
	makeList(ini_block)
return

;====================================

Sort:
	block:= ini_block
	sortINI(block)
	makeList(block)
return


;====================================


add_separatorINI:
	;row_now:=LV_GetNext(0) ;selected row number 
	;LV_GetText(FilePath,row_now , 1)	

	block:= ini_block
	name_:="----------------------------------------------------------------------"
	;name_:="separator"
	Gui,6: +OwnDialogs
	InputBox, num, Separator , Row number,,160,120,,,,, % LV_GetCount()+1
		if ErrorLevel  ;CANCEL
			return
	if num is not Integer
		return
	if(num<=0)
		return

	insertINI(block,name_,num)
	sortINI(block)
	makeList(block)
return

;====================================


move_to_row:
	block:=ini_block
	row_now:=LV_GetNext(0) ;selected row number 
	if row_now=0
		return
	LV_GetText(FilePath,row_now , 1)	
	IniRead, name_ , %settings_ini%, %block%, %row_now% 

	Gui,6: +OwnDialogs
	InputBox, num, %name_% , Row number,,160,120,,,,, %row_now%
		if ErrorLevel  ;CANCEL
			return
	if num is not Integer
		return

	if(num<=0)
		return
	;sep:=0
	;if(InStr(name_,"------"))
		;sep:=row_now
	
	IniDelete, %settings_ini%, %block%, %row_now%
	sortINI(block)
	insertINI(ini_block,name_,num)
	
	makeList(ini_block)
return

;---------------------

insertINI(block,ins_1,row:=1){
	global row_now
	obj:=Object()
	
	;IniRead, read_ , %settings_ini%, %block%,	
	Loop, % maxNum {
   IniRead, name_ , %settings_ini%, %block%, %A_Index%
    if(name_=="ERROR" || name_=="")
			continue
		obj[A_Index]:=Trim(name_)	
	}	

	ins_1:=Trim(ins_1)
  
	block_2:=""

	index:=1
	for i, val in obj {
		;if(name_=="ERROR" || name_=="")
			;continue
		if(index=row){
			block_2:=block_2 index "=" ins_1 "`n" 
			index+=1
			block_2:=block_2 index "=" obj[A_Index] "`n" 
		}else{
			block_2:=block_2 index "=" obj[A_Index] "`n" 
		}		
		index+=1
	}
	if(row>=obj.Length()){ 
		block_2:=block_2 index "=" ins_1 "`n" 
		;block_2:=block_2 obj.Length() "=" ins_1 "`n" 
	}
		
	IniWrite, %block_2% , %settings_ini%, %block%
	
	sortINI(block)
}

updateDropdown:
	block:=ini_block
	for i, val in ButtonSet {	
		if(ButtonSet[i].iniBlock=block){
				index:=i
				break
		}
	}

			queries:=""			
			Loop, % maxNum {
			 IniRead, name , %settings_ini%, %block%, %A_Index%
				if(name=="ERROR" || name=="")
				 continue				
				queries:= queries "|" name 
				;queries:=RegExReplace(queries,"^\|","")
			}
		GuiControl, , % ButtonObj[index].ListHwnd, %queries%
return			
			
;=========================


ini_blocks_choose:
	Gosub,updateDropdown
	ini_block:=A_ThisMenuItem
	makeList(ini_block)
	SB_SetText(ini_block,2,0)
return


;==============================================

ClickListView:
if A_GuiEvent = DoubleClick
{
	if(A_GuiControl=="LV_2" || A_GuiControl=="LV_3"){
		LV_GetText(FilePath,A_EventInfo , 1)
	}else{
		LV_GetText(FilePath,A_EventInfo , 5)
	}
	FilePath:=RegExReplace(FilePath,"^(?:[A-Z]:\\)?.*?([A-Z]:\\.*?\.ahk)","$1")
	FilePath:=Trim(FilePath)
	if !FileExist(FilePath){
		MsgBox,,, % "File does not exist:"  "`n" FilePath , 3
		return
	}	
	Run, "%FilePath%"
}
return



;==============================================

ToolTip_(tekst,t:=2,screen:=0,which:=1){
	if(screen){
		CoordMode, ToolTip,Screen
		ToolTip, %tekst% ,600, 350 , which
	}else{
		CoordMode , ToolTip, Relative
		GuiControlGet, Pos, Pos, edit_1
		tipX:= PosX+ 4, tipY:=PosY +2
		ToolTip, %tekst% ,%tipX%, %tipY% , which
	}
	t:=t*1000
	Settimer, ToolTip_close , -%t%
}

ToolTip_close:
	Settimer, ToolTip_close , Off
	ToolTip
return


;==================


6GuiClose:
	Gui,6: Destroy
	Gosub, updateDropdown
return

Exit:
GuiClose:
Close:
;Esc:: 
ExitApp

