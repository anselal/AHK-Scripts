/* 
• Ctrl+G - start search in active Explorer window
• Escape - hide search windows
• Ctrl+Q - exit program ; or double click on tray icon
*/

; forum last update Jan10 2019

#SingleInstance force
;Menu, Tray, Icon, shell32.dll,  3 
Menu, Tray, Icon,  shell32.dll, 210
Menu, Tray, Add, Exit , Close 
Menu, Tray, Default, Exit ; double click tray icon to exit

SetWinDelay, -1
SetControlDelay, -1
;SetBatchLines, -1

 EVENT_OBJECT_CREATE:= 0x8000, EVENT_OBJECT_DESTROY:= 0x8001, EVENT_OBJECT_LOCATIONCHANGE:= 0x800B
 WINEVENT_SKIPOWNTHREAD:= 0x0001,WINEVENT_SKIPOWNPROCESS:= 0x0002, WINEVENT_OUTOFCONTEXT:= 0x0000

WorkingDir :=A_ScriptDir

global selfol, Win_ID, CB_ListID, List_id, win
global del_ico:=0 ; 0= text "X", 1= icon

global settings_ini := WorkingDir "\WinExpToolsDrozd.ini"
global MaxQueries:=10

  global rel_X:=188, rel_Y:=64
  if InStr(A_OSVersion,"WIN_8")
    rel_X:=188, rel_Y:=60
	
Gosub, ContextMenuMake

Gosub, searchList
OnMessage(0x100, "WM_KEYDOWN")
return


~^g::
	Gosub, showSearchDialog
	Gosub, Combo_WinEvent
return

showSearchDialog:
if !WinActive("ahk_class CabinetWClass")
	return
	stop_loop:=0
	WinGet, Win_ID,ID , A
	
	win := GetShellFolder(Win_ID)
	fold_path:=win.Document.Folder.Self.Path

	inputDrozd_(Win_ID,win)	

WINEVENT_OUTOFCONTEXT:= 0x0000, WINEVENT_SKIPOWNTHREAD:= 0x0001

idThread:=DllCall("GetWindowThreadProcessId", "Int", Win_ID, "UInt*", PID)	 ; LPDWORD
idThread:=0 ; set 0 anyway - for open new Explorer window and select file

EventHook:=DllCall("SetWinEventHook","UInt",0x8000,"UInt",0x800B,"Ptr",0,"Ptr",RegisterCallback("WinProcCallback"),"UInt", PID,"UInt",idThread,"UInt", WINEVENT_OUTOFCONTEXT | WINEVENT_SKIPOWNTHREAD) 	

OnExit(Func("UnhookWinEvent").Bind(EventHook))
	
;EventHook := DllCall( "SetWinEventHook", "UInt",0x8000, "UInt",0x800B, "Ptr",0,"Ptr",RegisterCallback("WinProcCallback"), "UInt", 0, "UInt",0, "UInt",0 ) 
return




searchList:
if WinExist("Drozd_searchList")
	return
GuiWidth:=700, GuiHeight:=400
Gui,1: -MaximizeBox -MinimizeBox 
Gui,1: +HWNDGui1_Id
Gui,1: +ToolWindow -border ;-Caption 
Gui,1:Color,  DCE8ED
Gui,1: Font, S9 w400, Tahoma
Gui,1: ListView , List__
Gui,1: Add, ListView, x0 y0 w%GuiWidth% h%GuiHeight% vList__ gClickListView , File Name|Date modified|Folder|Size
    LV_ModifyCol(1,580)
		LV_ModifyCol(2,80,"Size")
    LV_ModifyCol(3,120,"Date modified")
		LV_ModifyCol(4,500,"Folder") 
Gui,1: +Owner%Win_ID%
Gui,1: Show, Hide  w%GuiWidth% h%GuiHeight% , Drozd_searchList
;WinSet, Style, -0xC00000, Drozd_searchList 

return


WM_KEYDOWN(wParam, lParam){	
	ControlGetFocus , control, inputDrozd_Search
	if(control!="Edit1")
		return
	if(wParam = 13){ ; VK_ENTER := 13		
		List_Func_B(List_id, win)
	}else	if(wParam = 27){ ; Esc  ; del 46
	}
}


inputDrozd_(Win_ID, win){
	global List_id
	Gui,77: Destroy

	IniRead, read_, %settings_ini%, Search, query
  if(read_!="ERROR" && read_!=""){
		queries:= RegExReplace(read_,"im),","`n")
	}
	Gui,77: +Delimiter`n ; not | in ComboBox (for Regex)

	Gui,77: Margin, 0,0
	Gui,77: Color, EAF3FC 
	Gui,77:+ToolWindow -Caption -MinimizeBox -MaximizeBox 
	
	Gui,77: +HwndGuiInpID  
	Gui,77:Font, S9 Q5  , Segoe UI 
	Gui,77:Add, ComboBox, x8 y3  +HWNDList_id , %queries%
	Gui,77:Font, S8
	Gui,77:Add, Button, x+6 y+-23 h20  +HWNDBut_id, % Chr(9654) ;▶ ;Go
		fn := Func("List_Func_B").Bind(List_id, win)
		GuiControl, +g, % But_id, % fn		
		fn := Func("List_Func").Bind(List_id, win)
    GuiControl, +g, % List_id, % fn	

	WinGetPos, x1,y1,w1,h1, ahk_id %Win_ID%
	Gui,77: +Owner%Win_ID% 
	x:=x1+w1-rel_X, y:=y1+rel_Y
	Gui,77:Show,   x%x% y%y% w180 h28  NA , inputDrozd_Search
	ControlFocus, ComboBox1, inputDrozd_Search
	return	
	
	Cancel:
	Gui,77: Destroy
	return	
}



List_Func_B(hwnd, win){
	global Win_ID, Gui1_Id, List__
	WinGetPos, x1,y1,w1,h1, ahk_id %Win_ID%
	Gui,1: +Owner%Win_ID% 
	;x2:=x1+55, y2:=y1+95
	x2:=x1+8, y2:=y1+95,  w2:=w1-18, h2:=h1-110	
	Gui,1:Show,   x%x2% y%y2% w%w2% h%h2% NA , Drozd_searchList
	GuiControl,1: Move, List__, % "W"  w2 . " H" h2
	
	GuiControlGet, query, , % hwnd
	fold_path:=win.Document.Folder.Self.Path	
	search_folder(fold_path, query)
}

List_Func(hwnd, win){
	global Win_ID, Gui1_Id, List__
	
		del:=ComboDel(hwnd)		
			if(del==1)
				return
	ControlFocus ,%hwnd%, ahk_id %Win_ID%
/* 	WinGetPos, x1,y1,w1,h1, ahk_id %Win_ID%
	Gui,1: +Owner%Win_ID% 
	;x2:=x1+55, y2:=y1+95
	x2:=x1+8, y2:=y1+95,  w2:=w1-18, h2:=h1-110	
	Gui,1:Show,   x%x2% y%y2% w%w2% h%h2% NA , Drozd_searchList
	GuiControl,1: Move, List__, % "W"  w2 . " H" h2
	
	GuiControlGet, query, 77: , % hwnd
	fold_path:=win.Document.Folder.Self.Path
	search_folder(fold_path, query)	
	 */
}



	ComboDel(hwnd){
		VarSetCapacity(POINT,8,0)
		DllCall("GetCursorPos","Ptr",&POINT)
		DllCall("ScreenToClient","Ptr",hwnd,"Ptr",&POINT)
		x:=NumGet(POINT,0,"Int")
		y:=NumGet(POINT,4,"Int") 

		GuiControlGet, Pos, Pos, %hwnd%
		GuiControlGet, item_,,	%hwnd%
		
		if(PosW-x<20){
/* 			MsgBox, 0x00040003, , Do you want to delete this item? `n%item_% ;+100 "No" as default
				IfMsgBox, No
					return 1
				IfMsgBox Cancel
					return 1
				 */
		GuiControl, +AltSubmit, %hwnd%
		GuiControlGet, line_,, %hwnd%
		Control, Delete, %line_%,, ahk_id %hwnd%
		GuiControl, -AltSubmit, %hwnd%     
		;ToolTip_("Deleted item:" "`n" item_ , 1)
		;del_in_ini(item_)
				return 1	
		}else{
      CbAutoComplete()
    }
		
		return 0 
	}
;====================================================




WinProcCallback(hWinEventHook, event, hwnd, idObject, idChild, dwEventThread, dwmsEventTime){
  Critical
  global Win_ID, GuiInpID,Gui1_Id, ParID
  if !hwnd
    return
  event:=Format("0x{1:x}",event)
	
  if event not in 0x8000,0x8001,0x800B  
     return
 
  ;EVENT_OBJECT_CREATE:= 0x8000, EVENT_OBJECT_DESTROY:= 0x8001, EVENT_OBJECT_LOCATIONCHANGE:= 0x800B 
  
  hwnd:=Format("0x{1:x}",hwnd) 
	;WinGetClass, class_, ahk_id %hwnd% 
  
  ;WinGet, pname, ProcessName,ahk_id %hwnd%  	
  ;WinGetTitle, Title, ahk_id %hwnd%      
	
  if(event=0x800B){ ; move, re-size	
		 WinGetPos, x1,y1,w1,h1, ahk_id %Win_ID%  
			if(x1 && y1){
	      x:=x1+w1-rel_X, y:=y1+rel_Y
			}
   	WinMove, ahk_id %GuiInpID%,, %x%, %y%   
	
		x2:=x1+8, y2:=y1+95,  w2:=w1-18, h2:=h1-110
		WinMove , ahk_id %Gui1_Id%,, %x2%, %y2%,%w2%, ;%h2% ;Drozd_searchList
		GuiControl,1: Move, List__, % "W"  w2 . " H" h2

  }else if(event=0x8000 ){ ; new created
		WinGetClass, class_, ahk_id %hwnd% 
		;ToolTip, % event "  ,  " class_ "`n" 
		 if(class_=="ShellTabWindowClass"){
		 ParID:=DllCall("GetParent", "UInt",hwnd), ParID := !ParID ? hwnd : ParID 
		 ParID:=Format("0x{1:x}",ParID)
		  
			if(selfol==1){
				SetTimer,selectInWindow , -500
				;Gosub, selectInWindow
			}
		}
		
  }else if(event=0x8001 ){ ; window closed     
			if(hwnd==Win_ID)
         Gosub, close_search_list
  }
}

;==========================

WinProcCallback_2(hWinEventHook, event, hwnd, idObject, idChild, dwEventThread, dwmsEventTime){
  Critical  
  if !hwnd
    return
  event:=Format("0x{1:x}",event) ; decimal to hexadecimal
	hwnd:=Format("0x{1:x}",hwnd) 
	;EVENT_OBJECT_REORDER:= 0x8004, EVENT_OBJECT_FOCUS:= 0x8005, EVENT_OBJECT_SELECTION:= 0x8006
	if(event=0x8006){ ;EVENT_OBJECT_SELECTION
		del_icons(List_id,hwnd,del_ico)
		return 0
	}
}


UnhookWinEvent(hWinEventHook){
  DllCall("UnhookWinEvent", "Ptr",hWinEventHook)
  DllCall("CoUninitialize")
}


;====================================================



Combo_WinEvent:
EVENT_OBJECT_REORDER:= 0x8004, EVENT_OBJECT_FOCUS:= 0x8005, EVENT_OBJECT_SELECTION:= 0x8006

global CB_EditID , CB_ListID
	CtrlHwnd:=List_id
	VarSetCapacity(CB_info, 40 + (3 * A_PtrSize), 0)
	NumPut(40 + (3 * A_PtrSize), CB_info, 0, "UInt")
	DllCall("User32.dll\GetComboBoxInfo", "Ptr", CtrlHwnd, "Ptr", &CB_info)
	CB_EditID := NumGet(CB_info, 40 + A_PtrSize, "Ptr") ;48/44
	CB_ListID := NumGet(CB_info, 40 + (2 * A_PtrSize), "Ptr") ; 56/48
	
	CB_EditID:=Format("0x{1:x}",CB_EditID) , CB_ListID:=Format("0x{1:x}",CB_ListID) 
	
	GuiHwnd_:=CB_ListID
	ThreadId := DllCall("GetWindowThreadProcessId", "Int", GuiHwnd_, "UInt*", PID)	

	
EventHook_2:=DllCall("SetWinEventHook","UInt",0x8006,"UInt",0x8006,"Ptr",0,"Ptr"
					,RegisterCallback("WinProcCallback_2")	,"UInt", PID,"UInt", ThreadId,"UInt", 0)  

	OnExit(Func("UnhookWinEvent").Bind(EventHook_2))	
return


;====================================================



del_icons(List_id,CB_ListID,del_ico:=0){
	SendMessage,0x0146,0,0, ,% "ahk_id " List_id ;CB_GETCOUNT:= 0x0146
	len:=ErrorLevel
	WinGetPos, ,,, CB_height, ahk_id %CB_ListID% 
	row_height2:=CB_height/len
	SendMessage,0x0154,1,0, ,% "ahk_id " List_id ;CB_GETITEMHEIGHT:= 0x0154
	row_height:= ErrorLevel
	if(del_ico)
		iconOnWin(CB_ListID,len,row_height)
	else
		textOnWin(CB_ListID,len,row_height,"X")
}


textOnWin(hwnd, len,row_h,text_:="X"){
	hDC := DllCall("User32.dll\GetDC", "Ptr", hwnd)

	WinGetPos, x, y, W, H, ahk_id %hwnd% 
	x:=W-12,y:=0
	heightF:=12 , weight:=400,fontName:="Arial"  ;"Segoe Print"
	widthF:=6
	hFont:=DllCall("CreateFont", "Int", heightF,"Int",widthF, "Int",  0, "Int", 0,"Int",  weight, "Uint", 0,"Uint", 0,"uint", 0, "Uint", 0, "Uint", 0, "Uint", 0, "Uint", 0, "Uint", 0, "str", fontName)
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
			DllCall("SetBkMode","Ptr",hDC,"Int",1) ;TRANSPARENT := 1
			DllCall("TextOut", "uint",hDC, "int",x, "int",y, "str",text_, "int",StrLen(text_)) 		
		}else{	
	/* 		DllCall("SetTextColor", "UPtr", hDC, "UInt",colorG )
			DllCall("SetBkMode","Ptr",hDC,"Int",1) ;TRANSPARENT := 1
			DllCall("TextOut", "uint",hDC, "int",x, "int",y, "str",text_, "int",StrLen(text_)) 
			 */
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


~^d::
stop_loop:=1
return

search_folder(path,query){
	global List_, stop_loop
  add_to_ComboBox(query,"ComboBox1",MaxQueries)
  SetBatchLines, 5ms
	i:=0
	Gui,1:Show
	Gui,1:Default
	Gui,1:ListView , List__
	LV_Delete()
	LV_ModifyCol(1,,"Files found # " i "/" num_ " - """ query """")
  Loop, %path%\*.*, 0 , 1 
    {
/*       if !RegExMatch(A_LoopFileExt,"i)htm|mp3|mp4|wav|aac|jpg|jpeg|png|gif|webp|3gp")
        continue
    */
      if(stop_loop=1){
       MsgBox,,, Search stopped , 1
       stop_loop:=0
       break
      }
        if(Mod(A_Index, 100)==0) ; co 100
          ToolTip, % "#" i " / " A_Index , 480 , 6
        
      if(search_query(A_LoopFileName, query)){  
				i+= 1    
				FormatTime, FileTime, %A_LoopFileTimeModified% , yyyy/MM/dd HH:mm
				;FileTime:=A_LoopFileTimeModified	
				LV_Add("", A_LoopFileName, Size_format_file(A_LoopFileSize),FileTime,A_LoopFileDir) ; LoopFileSizeKB
      }
			num_:=A_Index
    }
    ToolTip
		LV_ModifyCol(1, "SortAsc")
		LV_ModifyCol(1,,"Files found # " i "/" num_ " - """ query """")
    GuiControl, +Redraw, List__  ; Re-enable redrawing
    SetBatchLines, 10ms
}



search_query(line, query){ 
  if(RegExMatch(query,"i)^""(.*)""$", q)){
    query:=q1
    if(RegExMatch(line,"i)" query))
      return true
  }else{
    array:=StrSplit(query," ")
    if(array.Length()>1){
      Loop, % array.Length(){
        if(array[A_Index]==""){
          continue
        }else if(!RegExMatch(line,"i)" array[A_Index])){
          return false
        }           
      }
        return true
    }else{   
      if(RegExMatch(line,"i)" query))        
        return true
    }
  }
  return false
}



add_to_ComboBox(new_val,box, max){ ;
	ControlGet, list_,List, ,%box%, inputDrozd_Search 
	list_array:=StrSplit(list_,"`n")
	if(list_array.Length()>=max){
		Control, Delete, % list_array.Length() , %box% ,  inputDrozd_Search
    ControlGet, list_,List, ,%box%, inputDrozd_Search 
    list_array:=StrSplit(list_,"`n")
  }
  index1:=array_contains(list_array, new_val)
	if(index1==0){
		new_box:= "`n" Trim(new_val) "`n" list_
		GuiControl,77:, %box%, %new_box% 
		;GuiControl,77:ChooseString, %box%, %new_val% ; select	
		GuiControl,77: Choose, %box%, 1
	}else{
		;GuiControl,77:ChooseString, %box%, %new_val% ; select	
		GuiControl,77: Choose, %box%, %index1%
	}
}



array_contains(haystack, needle){	
 if(!isObject(haystack))
  return false
 if(haystack.Length()==0)
  return false
 for k,v in haystack
	{
		v:=Trim(v), needle:=Trim(needle)
  if(v==needle)
   return k
	}
 return false
}

Size_format_file(bytes){
    size:=0
    if(bytes >= 1073741824){
        size :=Round(bytes/1073741824,2) " GB"
    }else if (bytes >= 1048576){
				size :=Round(bytes/1048576,1) " MB"				
    }else if (bytes >= 1024){
				size :=Round(bytes/1024) " kB"
		}else if (bytes == 0){
				size :=0				
    }else {
				size := bytes " B"               
    } 
			return size
 }


;===================================================

ClickListView:
if A_GuiEvent = DoubleClick
{
    LV_GetText(FileName, A_EventInfo)  
    LV_GetText(FolderPath, A_EventInfo, 4) 
    ;LV_GetText(date_mod, A_EventInfo, 3)
    FilePath:= FolderPath "\" FileName
    Run, %FilePath%
    
}
return

;===================================================

Open_folder:
  LV_GetText(FolderPath,row_now , 4)
	LV_GetText(FileName,row_now , 1)
	selfol:=1
	Run, %FolderPath% 
	;Run, C:\windows\explorer.exe %FolderPath% ,,, PID_
return 

Open_file:
  LV_GetText(FileName,row_now , 1)
  LV_GetText(FolderPath,row_now , 4)
  FilePath:= FolderPath "\" FileName
  Run, % FilePath
return


selectInWindow:
	win := GetShellFolder(ParID)
	win.Document.SelectItem(win.Document.Folder.ParseName(FileName), 1|4|8)
	selfol:=0	
return


copy_name:
  LV_GetText(name, row_now, 1)
  clipboard:=name
return

fileProperties:
  LV_GetText(FileName,row_now , 1)
  LV_GetText(FolderPath,row_now , 4)
  FilePath:= FolderPath "\" FileName
  Run Properties %FilePath%
return

copy_path:
  LV_GetText(FileName,row_now , 1)
  LV_GetText(FolderPath,row_now , 4)
  FilePath:= FolderPath "\" FileName
  clipboard:=FilePath
return

;===================================================

GuiContextMenu: 
if A_GuiControl != List__  
    return
  menu_control_now:=A_GuiControl
  row_now:=A_EventInfo 
  Menu, ContextMenu, Show, %A_GuiX%, %A_GuiY%
return

ContextMenuMake:
	Menu, ContextMenu, Add,
	Menu, ContextMenu, DeleteAll
	
	Menu, ContextMenu, Add , Open , Open_file
	Menu, ContextMenu, Add ,  Open in folder and select , Open_folder
	Menu, ContextMenu, Icon, Open, shell32.dll,  3 
	Menu, ContextMenu, Icon,  Open in folder and select, Shell32.dll, 111
	Menu, ContextMenu, Add   
	Menu, ContextMenu, Add , Copy name, copy_name 
	Menu, ContextMenu, Add , Copy path, copy_path
	Menu, ContextMenu, Add , Properties, fileProperties
	Menu, ContextMenu, Add   
	Menu, ContextMenu, Add,  Close search, close_search_list
	Menu, ContextMenu, Icon, Close search  , shell32.dll,132
return

;===================================================



test2:
gosub showSearchDialog
return



GetShellFolder(Win_id){
    for win in ComObjCreate("Shell.Application").Windows  {
			if(win.HWND == Win_id){
				return win
			}
		}			
}



~Esc::
GuiClose:
close_search_list:
	UnhookWinEvent(EventHook)
	UnhookWinEvent(EventHook_2)
	stop_loop:=1
  Gosub, saveQueries
	Gui,1: -Owner%WinS_ID% 
	Gui,77: -Owner%WinS_ID%
	;DllCall("AnimateWindow", "Int", Gui1_Id, "Int", 200, "Int", 0x00050008) ;0x00050008
	Gui,1: Hide
  DllCall("AnimateWindow", "Int", GuiInpID, "Int", 200, "Int", 0x00050001)  
	Gui,77: Destroy  
return

saveQueries:
  ControlGet, query_,List, ,ComboBox1, inputDrozd_Search
  query_:= RegExReplace(query_,"im)`n",",")	
	
	if(query_!="")
  IniWrite, %query_%, %settings_ini%, Search, query
return


~^q::
Gosub, close_search_list
Exit:
Close:
ExitApp
	

;=======================================================================================
CbAutoComplete(){	;autohotkey.com/boards/viewtopic.php?f=6&t=15002 Pulover
; CB_GETEDITSEL = 0x0140, CB_SETEDITSEL = 0x0142
	If ((GetKeyState("Delete", "P")) || (GetKeyState("Backspace", "P")))
		return
	GuiControlGet, lHwnd, Hwnd, %A_GuiControl%
	SendMessage, 0x0140, 0, 0,, ahk_id %lHwnd%
	MakeShort(ErrorLevel, Start, End)
	GuiControlGet, CurContent,, %lHwnd%
	GuiControl, ChooseString, %A_GuiControl%, %CurContent%
	If (ErrorLevel)	{
		ControlSetText,, %CurContent%, ahk_id %lHwnd%
		PostMessage, 0x0142, 0, MakeLong(Start, End),, ahk_id %lHwnd%
		return
	}
	GuiControlGet, CurContent,, %lHwnd%
	PostMessage, 0x0142, 0, MakeLong(Start, StrLen(CurContent)),, ahk_id %lHwnd%
}

MakeLong(LoWord, HiWord){
	return (HiWord << 16) | (LoWord & 0xffff)
}

MakeShort(Long, ByRef LoWord, ByRef HiWord){
	LoWord := Long & 0xffff,   HiWord := Long >> 16
} 

;=======================================================================================