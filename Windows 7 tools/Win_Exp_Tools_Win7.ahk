#SingleInstance force
; no  #NoEnv
#NoTrayIcon
/* 
• Toolbar for "Windows Explorer" in Win7 (also works in Win8)
• on click --> go to folders: a, ❶, ❷, ❸, Music, Pics (paths pre-defined ; a= folderA, 1=folder1,...)
• on right click --> go to another set of folders (paths pre-defined ; a= folderA2, 1=folder1a,...)
• drag and drop to move files to those folders
• ↑ icon click --> up one level (or in another version • first empty icon -> window on top switch, right click )
• ↑ icon  right click --> pre-defined "Folder View" options for particular folders (or customize this subroutine "EmptyFirst2")
• empty icon after ❷ --> launch another window with the same path
• last icon --> ListBox :
  • click or double click ListBox items
  • folder size without subfolders (double click - with subfolders); new folder (right click - with name from clipboard)
  • folder size in separate file folder_size.ahk
• "Context menu" --> right click not on buttons 

• "showTipOnMouseover:=1" option shows folder paths 
*/

;Menu_; ListBox ListBox_Clicks:

Menu, ContextMenu, Add, Remove this, destroyGui
Menu, ContextMenu, Add, Show Folder Paths, showFolderPaths
Menu, ContextMenu, Add,
Menu, ContextMenu, Add, Restart, Reload
Menu, ContextMenu, Add, Exit DrozdTools, Exit 
Menu, ContextMenu, Icon, Exit DrozdTools, Shell32.dll, 132

SetWinDelay, -1
SetControlDelay, -1
SetBatchLines, -1


;scripts_path:="C:\Program Files\Misc\AutoHotkey Scripts"
scripts_path:="C:\AutoHotkey Scripts"
;scripts_path:=A_ScriptDir
icons_folder:= scripts_path "\icons\"

icoOnTop:=RegExMatch(A_OSVersion,"WIN_VISTA|WIN_7") ? 17 : 13 

bar:=""

showTipOnMouseover:=0



global G_color


/* if RegExMatch(A_OSVersion,"WIN_VISTA"){
  G_color:="286E83"
	bar=%icons_folder%Vista bar.png
 
}
 */
if RegExMatch(A_OSVersion,"WIN_7"){
  G_color:="EAF3FC"
  ;G_color:="DFE8F1"
  bar=%icons_folder%Win7 bar.png

}else{  
  G_color:="EAF3FC"
  ;G_color:="FFFFFF"
  G_color:="F5F6F7"
  bar=%icons_folder%Win7 bar.png
  ;bar:=""  

}






global folderA, folderA2, folder1, folder2, folder3

folderA:="C:\a\" , folderA2:="C:\b\"

/* 
folderA:="C:\a\" , folderA2:="C:\b\"
folder1:="C:\a\podcast" , folder1a:="C:\a\YT"
folder2:="C:\a\rec" , folder2a:="C:\AutoHotkey Scripts" 
 */


folderA:= "C:\"
folderA2:= A_MyDocuments
folder1= %HOMEDRIVE%%HOMEPATH%  ;A_MyDocuments
folder1a:= A_AppData ; roaming  %LOCALAPPDATA% ; %APPDATA%
folder2:= APPDATA
folder2a:= LOCALAPPDATA
folder3:= A_ProgramFiles 
folder3a:= A_WinDir   

Music:= HOMEDRIVE HOMEPATH "\Music"    ;"C:\Users\" A_UserName "\Music"
Pictures:= HOMEDRIVE HOMEPATH "\Pictures"  ; "C:\Users\" A_UserName "\Pictures"

folder_music_2:=""
folder_pics_2:= ""

button3:="Music"
button4:="Pics"


get_folder_size:=A_ScriptDir "\folder_size.ahk"

;==============




  Gosub, Start
  Gosub, add_List
  
  DllCall("RegisterShellHookWindow", UInt,A_ScriptHwnd )
  MsgNum := DllCall("RegisterWindowMessage", Str,"SHELLHOOK")
  OnMessage(MsgNum,"ShellMessage")
  
  OnMessage(0x204, "WM_RBUTTONDOWN")
  if(showTipOnMouseover)
    OnMessage(0x200, "WM_MOUSEMOVE")  
return


Start:
	WinGet, List_, List , ahk_class CabinetWClass
	Loop, %List_%  {
		id:=List_%A_Index%
		WinGet, pname, ProcessName,ahk_id %id%  
		WinGetClass, class_, ahk_id %id%  
		;WinGet, PID, PID , ahk_id %id%
    win := GetShellFolder(id)
    fold_path:=win.Document.Folder.Self.Path 
      if !InStr(fold_path,"::{")        
          make_Gui(id)
	}
return


ShellMessage(wParam,lParam){
	;Critical
  global lastExpId
	lParam:=Format("0x{1:x}", lParam) ; decimal to hexadecimal
	
	if(wParam=1 || wParam=2 || wParam=4 || wParam=32772){		
		id:=lParam
		if(wParam=1){   ;  HSHELL_WINDOWCREATED = 1  ; new program started
			WinGet, PID, PID , ahk_id %lParam%
			WinGet, pname, ProcessName,ahk_id %lParam%  
			WinGetClass, class_, ahk_id %lParam%  
			id:=lParam
			if(RegExMatch(class_,"i)CabinetWClass")){ 
        fn:=Func("make_Gui").Bind(id)
        SetTimer, %fn% , -500
        ;GuiHwnd:= make_Gui(id)
			}		

		}
/* 
  if(wParam=2){ ; HSHELL_WINDOWDESTROYED=2 ; program stopped
			;MsgBox,,, %  "HSHELL_WINDOWDESTROYED  " "wParam=" wParam  " | lParam=" lParam ", "  "`n" class_ , 2
  } 
		
  if(wParam=4 || wParam=32772){ 	;HSHELL_WINDOWACTIVATED=4, 
    
  }					
		 */
	}	
}

refresh(id){
  WinSet, Redraw,, ahk_id %id%
  PostMessage, 0xF, 0,,, ahk_id %id% ; 0xF = WM_PAINT   
  PostMessage 0x0232,,,, ahk_id %id% ;WM_EXITSIZEMOVE
  ToolTip_("refresh",1)
}

checkWin(id,GuiHwnd){  
  ;sleep 500
  win := GetShellFolder(id)
  fold_path:=win.Document.Folder.Self.Path 
  ;MsgBox,,, % fold_path  "`n" InStr(fold_path,"::{")
  static exclude:=["{21EC2020-3AEA-1069-A2DD-08002B30309D}","{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}","{645FF040-5081-101B-9F08-00AA002F954E","{20D04FE0-3AEA-1069-A2D8-08002B30309D","{9343812E-1C37-4A49-A12E-4B2D810D956B","{26EE0668-A00A-44D7-9371-BEB064C98683}"]
  ; if (InStr(fold_path,"{645FF040-5081-101B-9F08-00AA002F954E") || InStr(fold_path,"{20D04FE0-3AEA-1069-A2D8-08002B30309D") ||  InStr(fold_path,"{9343812E-1C37-4A49-A12E-4B2D810D956B") || InStr(fold_path,"{21EC2020-3AEA-1069-A2DD-08002B30309D}") || InStr(fold_path,"{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}"))  
  Loop, % exclude.Length(){
    ;MsgBox,,, % fold_path  "`n" exclude[A_Index] "`n" InStr(fold_path,exclude[A_Index]) ,3
    if(InStr(fold_path,exclude[A_Index])){
      Gui, %GuiHwnd%: Destroy
      break
    }
  }
  ; ::{645FF040-5081-101B-9F08-00AA002F954E} Recycle Bin 
  ; ::{20D04FE0-3AEA-1069-A2D8-08002B30309D} Computer
  ; ::{9343812E-1C37-4A49-A12E-4B2D810D956B} search 
  ; ::{21EC2020-3AEA-1069-A2DD-08002B30309D} Control Panel
  ; ::{F02C1A0D-BE21-4350-88B0-7367FC96EF3C} Network
  ; ::{26EE0668-A00A-44D7-9371-BEB064C98683} Control Panel
}

;===========================

 make_Gui(parentID){
  global icons_folder, bar, button3, button4, icoOnTop
  Gui, New, +ToolWindow -caption +AlwaysOnTop	+HwndGuiHwnd ;-border
  ;G_color:="286E83" ; blue
	;G_color:="8BAFBE"
  Gui, %GuiHwnd%:Color, %G_color% ;120F00   
  font_1:="000000" , font_2:="333333" , font_3:="0C6881" ,font_4:="004E64" ; Win7 
  font_2a:="0C3E4C"
  if(FileExist(bar)){
    Gui, %GuiHwnd%: Add, Picture, x0 y0 w332 h28   BackgroundTrans, %bar% 
  }else{    
    Gui, %GuiHwnd%: Add, Text , x-100 y-100  BackgroundTrans Center, ;dummy static 
  }
  

  if RegExMatch(A_OSVersion,"WIN_7"){
    Gui, %GuiHwnd%: Font, S9 W700 c%font_3% , Verdana   
  ; up
    Gui, %GuiHwnd%: Add, Text ,  x1 y8 w16 h16 gEmptyFirst BackgroundTrans Center , % Chr(8593) ;↑
  }else{
    Gui, %GuiHwnd%: Font, S12 W700 c%font_3% , Verdana   
    Gui, %GuiHwnd%: Add, Text ,  x1 y6 w18 h22 gEmptyFirst BackgroundTrans Center , % Chr(8593) ;↑    
  }
    
  ; onTop:
  ;Gui, %GuiHwnd%: Add, Picture,  x0 y6 w16 h16 +HwndonTopHwnd gonTop BackgroundTrans Icon30 AltSubmit, shell32.dll       

 
  ;switch=%icons_folder%switch1.png
  if(FileExist(switch)){
    Gui, %GuiHwnd%: Add, Picture, x246 y5 w18 h18   gshowList  BackgroundTrans , %switch%
  }else{ 
    Gui, %GuiHwnd%: Add, Picture, x246 y4 w18 h18   gshowList  BackgroundTrans Icon249 AltSubmit, shell32.dll
  } 
  

    font_1:="000000" , font_2:="333333" , font_3:="085B72" ,font_4:="004254", font_5:="800000" ; Win7 
    
    Gui, %GuiHwnd%: Font, S11 W700 c%font_3% , Segoe UI 
    Gui, %GuiHwnd%: Add, Text , x21 y3 w26 h18  ggo_a BackgroundTrans Center,  a
   ; Gui, %GuiHwnd%: Add, Text , x+4  y3 w26 h18 ggo_b BackgroundTrans Center, b
    Gui, %GuiHwnd%: Font, S8 W700 c%font_3% , Segoe UI  ;Verdana     
    Gui, %GuiHwnd%: Add, Text , x+4  y7 w26 h18  ggo_to_folder_1 BackgroundTrans Center,  ❶
    Gui, %GuiHwnd%: Add, Text , x+4  y7 w26 h18  ggo_to_folder_2 BackgroundTrans Center,  ❷
    Gui, %GuiHwnd%: Add, Text , x+4  y7 w26 h16  ggo_to_folder_3 BackgroundTrans Center,  ❸
    
    ;Gui, %GuiHwnd%: Font, S9 W700 c%font_1% , Verdana
    Gui, %GuiHwnd%: Add, Text , x138  y4 w20 h18  gEmpty_2 BackgroundTrans Center , ;↑ ;% Chr(11014) ;⤊⬆ Chr(10506) 
    Gui, %GuiHwnd%: Font, S8 W700 c%font_4% , Verdana
   ; Gui, %GuiHwnd%: Font, S8 W700 cFFFFFF , Tahoma
    Gui, %GuiHwnd%: Add, Text , x163 y7 w34 h16  gbutton3 BackgroundTrans  Center, %button3% 
    Gui, %GuiHwnd%: Add, Text , x205 y7 w32 h16  gbutton4 BackgroundTrans Center, %button4%        
      
      
      
  Gui, %GuiHwnd%: Add, Picture , x19 y3 w30 h23 BackgroundTrans Icon181 AltSubmit, imageres.dll
  Gui, %GuiHwnd%: Add, Picture , x+0 y3 w30 h23 BackgroundTrans Icon181 AltSubmit, imageres.dll
  Gui, %GuiHwnd%: Add, Picture , x+0 y3 w30 h23 BackgroundTrans Icon181 AltSubmit, imageres.dll
  Gui, %GuiHwnd%: Add, Picture , x+0 y3 w30 h23 BackgroundTrans Icon181 AltSubmit, imageres.dll  
  
  Gui, %GuiHwnd%: Add, Picture , x155 y4 w48 h20 BackgroundTrans Icon181 AltSubmit, imageres.dll    
  Gui, %GuiHwnd%: Add, Picture , x201 y4 w42 h20 BackgroundTrans Icon181 AltSubmit, imageres.dll    

  Gui, %GuiHwnd%: +Parent%parentID%


  if InStr(A_OSVersion,"WIN_7"){
    x:= 416 , y:= 36
    Gui, %GuiHwnd%:Show, x%x%  y%y% w322 h26 NoActivate, DrozdTools_Expl ;Win7    
  }else{
    Gui, %GuiHwnd%:Show, x486 y28 w322 h26 NoActivate, DrozdTools_Expl ;Win8   
  }
  

  WinSet, Region, 0-0 270-0 270-29 0-29, ahk_id %GuiHwnd% 
  
/*   if(FileExist(bar))
    WinSet, Region, 0-0  w268 h28  R10-10 , ahk_id %GuiHwnd%  ; rounded corners
   */
  ;if(Gui_transp)
   ; WinSet, TransColor, %G_color%, ahk_id %GuiHwnd% ; transparent Gui
  
  ;fn:=Func("refresh").Bind(parentID)
  ;SetTimer, %fn% , -500
  checkWin(parentID,GuiHwnd)
  ;WinSet, Redraw,, ahk_id %id%
}

~LButton::
  MouseGetPos,x,y,Win_id,	control
  if (Win_id != GuiDropDownHwnd)    
   Gui,3:Hide   
return

showList:
  MouseGetPos,x1,y1, Win_id, control
  last_Win_id:=Win_id
  WinGetPos, x2,y2,w2,h2, A
  ControlGet, CtrlHwnd, Hwnd,, %control%, ahk_id %Win_id%
  WinGetPos, x2,y2,w2,h2, ahk_id %CtrlHwnd%	
  Gui, 3: Show, % "x" x2-56 " y" y2-3
return

add_List:
  Gui, New, 
  Gui,3: +ToolWindow +AlwaysOnTop -caption   +HwndGuiDropDownHwnd  
  Gui,3: Margin, 0,0
  Gui,3: Font, S8 W700  , Segoe UI
  ;lista:="folder size|folder size*|-------|Documents|Windows|Pictures|Music|-------|new folder|new folder*"
  lista:="folder size|new folder|-------|Documents|Pictures|Music|-------|" A_ComputerName "|-------|Roaming|ProgramFiles|Windows"
  ;Gui,3: Add, ListBox, x0 y0 w80 r12 vListBox_1 gDropDown, %lista%
  arr1:=StrSplit(lista,"|"), len:=arr1.Length() 
  Gui,3: Add, ListBox, x0 y0 w80 r%len%  vListBox_1  +HWNDListBox_id , %lista%
  fn := Func("ListBox_Func_1").Bind(ListBox_id)
	GuiControl, +g, % ListBox_id, % fn
  Gui,3:Show, , win_Exp_List - Drozd  
  Gui,3:Hide
return


onTop:
  ;WinGet, Win_id, ID , A
	MouseGetPos,,, Gui_ID, control
	Win_id:=DllCall("GetParent", "UInt", Gui_ID), Win_id := !Win_id ? Gui_ID : Win_id 
  
  WinGet, ExStyle, ExStyle, ahk_id %Win_id%	
  WS_EX_TOPMOST := 0x00000008 ; Ex-style AlwaysOnTop
  
  if(ExStyle & WS_EX_TOPMOST){ 
		Winset, AlwaysOnTop, off, ahk_id %Win_id%
    GuiControl,%A_Gui%:, %control%  ,*Icon30 *w16 *h16 shell32.dll 
  }else{
    WinSet, AlwaysOnTop, on, ahk_id %Win_id%
    GuiControl,%A_Gui%:, %control%  ,*Icon%icoOnTop% *w16 *h16 wmploc.dll  ;  ontop
  }   
return
 
 

;==============


WM_RBUTTONDOWN(){
  global last_Gui
	if(A_Gui){
    last_Gui:=A_Gui
		Gosub, Menu_    
  }
}


Menu_:
MouseGetPos,,, Win_id, control

;Asc("❶")=10102 ; Asc("❷")=10103; Asc("❸")=10104 ; Asc("❹")=10105
if(A_GuiControl="a"){
  goToFolder(folderA2,Win_id) 
}else if(A_GuiControl="❶" || Asc(A_GuiControl)=10102){
  goToFolder(folder1a,Win_id) 
}else if(A_GuiControl="❷" || Asc(A_GuiControl)=10103){
  goToFolder(folder2a,Win_id) 
  
}else if(A_GuiControl="b" || A_GuiControl="❸" || Asc(A_GuiControl)=10104){
  goToFolder(folder3a,Win_id)  
  
  
}else if(A_GuiControl=button3){
  goToFolder(folder_music_2,Win_id)  
}else if(A_GuiControl=button4){
  goToFolder(folder_pics_2,Win_id) 
  
  
}else if(InStr(A_GuiControl,"icons\transp1.png") || control="Static2"){ ; upFolder ; Duplicate
  ;Gosub,  Duplicate ;upFolder
  Gosub, EmptyFirst2
}
return
;====================


go_a:
  goToFolder(folderA,Win_id) 
return

go_b:
  goToFolder(folder3,Win_id)  
return

button3:
  goToFolder(Music,Win_id) 
return


button4:
  goToFolder(Pictures,Win_id) 
return




go_to_folder_1:
  goToFolder(folder1,Win_id)
return

go_to_folder_2:
  goToFolder(folder2,Win_id) 
return

go_to_folder_3:
  goToFolder(folder3,Win_id) 
return


;==========================================


go_to_folder:
  goToFolder(folder_path,Win_id) 
return

;=======================



ListBox_Func_1(hwnd){ 
  global lastEvent, lastListBox, last_Win_id
	GuiControlGet, list_folder_expl,3: , % hwnd
  lastEvent:=A_GuiEvent
	lastListBox:=list_folder_expl

  SetTimer, ListBox_Clicks, % DllCall("GetDoubleClickTime")
}

ListBox_Clicks:
SetTimer, ListBox_Clicks, Off
;MsgBox,,, % lastEvent  "`n" lastListBox "`n" last_win
	if(lastEvent="DoubleClick"){    
    if(lastListBox=="folder big"){
      win := GetShellFolder(last_Win_id)
      fold_path:=win.Document.Folder.Self.Path
      Run, %get_folder_size% "%fold_path%" "1" "big" "700000" "give size"
    }else if(lastListBox=="folder size"){ 
      win := GetShellFolder(last_Win_id)
      fold_path:=win.Document.Folder.Self.Path      
      Run, %get_folder_size% "%fold_path%"      
      
    }else if(lastListBox=="new folder"){
      ;Gosub, newFolderClipName 
      new_name:=SubStr(Clipboard,1,150)
      win := GetShellFolder(last_Win_id)
      win.Document.Folder.NewFolder(new_name)  
      Sleep, 1500  
      win.Document.SelectItem(win.Document.Folder.ParseName(new_name), 3) ; 1, 3
 
    }else if(lastListBox=="Roaming"){ 
      goToFolder(LOCALAPPDATA,last_Win_id)
    }else if(lastListBox=="ProgramFiles"){ 
      goToFolder(A_ProgramFiles " (x86)",last_Win_id) 

    }else if(lastListBox=="Windows"){ 
      goToFolder(A_WinDir "\System32",last_Win_id)
    }else if(lastListBox==A_ComputerName){ 
      win:=GetShellFolder(last_Win_id)
      win.Navigate("\\" A_ComputerName) 
    }
    Gui,3: Hide
    
  }else if(lastEvent="Normal"){    
      Gosub, ListBox_go    
  }
return




;=======================

ListBox_go:
Gui,3:Submit, Nohide
  ;x:=A_GuiControl
    Gui,3:Hide 
    Sleep, 100
    WinGet, Win_id, ID , A
    list_folder_expl:=ListBox_1  
if(list_folder_expl=="Documents"){
    goToFolder(A_MyDocuments,Win_id)
  }else if(list_folder_expl=="Windows"){ 
    goToFolder(A_WinDir,Win_id)
  }else if(list_folder_expl=="Pictures"){
    goToFolder(Pictures,Win_id)  
  }else if(list_folder_expl=="Music"){
    goToFolder(Music,Win_id)

  }else if(lastListBox=="Roaming"){ 
      goToFolder(A_AppData,last_Win_id)
  }else if(lastListBox=="ProgramFiles"){ 
      goToFolder(A_ProgramFiles,last_Win_id)      
    
  }else if(lastListBox==A_ComputerName){ 
      win:=GetShellFolder(last_Win_id)
      win.Navigate("\\" A_ComputerName) 
      
  }else if(list_folder_expl=="folder size*"){ 
    Gosub, getFolder
    Run, %get_folder_size% "%fold_path%"
  }else if(list_folder_expl=="folder size"){ 
   	win := GetShellFolder(Win_id)
    fold_path:=win.Document.Folder.Self.Path  
    Run, %get_folder_size% "%fold_path%" "0" "" "" ""

  }else if(list_folder_expl=="new folder*"){
    Gosub, newFolderClipName    
  }else if(list_folder_expl=="new folder"){
    Gosub, newFolder
  }  
return



;==========================

goToFolder(folder_path,Win_id){
  global
 ; MsgBox,4096,, %  folder_path "`n" Win_id "`n" FileExist(folder_path), 3  
  if (!FileExist(folder_path) && !InStr(folder_path,"::{")){    
    MsgBox,4096,, %  "No folder:" "`n" folder_path , 3
    return
  }
    win := GetShellFolder(Win_id)
    win.Navigate(folder_path)  
}
;==========================

newFolder:
  win := GetShellFolder(Win_id)
  win.Document.Folder.NewFolder("_New Folder") 
  Sleep, 1500  
  win.Document.SelectItem(win.Document.Folder.ParseName("_New Folder"), 3) ; 1, 3
return

newFolderClipName:
  new_name:=SubStr(Clipboard,1,150)
  win := GetShellFolder(Win_id)
  win.Document.Folder.NewFolder(new_name)  
  Sleep, 1500  
  win.Document.SelectItem(win.Document.Folder.ParseName(new_name), 3) ; 1, 3
 ; win.Document.SelectItem(win.Document.Folder.ParseName(new_name), 3|4|8|16) 
return

upFolder:  
  win := GetShellFolder(Win_id)
  if FileExist(win.Document.Folder.ParentFolder.Self.Path)
    win.Navigate(win.Document.Folder.ParentFolder.Self.Path) 
return
;==========================

getFolder:
	win := GetShellFolder(Win_id)
  fold_path:=win.Document.Folder.Self.Path
;MsgBox,,, % Win_id "`n" win.Document.CurrentViewMode "`n" win.Document.Folder.Self.Path "`n" win.Document.Folder.Self.Parent.Self.Path
return

Duplicate:  
	win := GetShellFolder(Win_id)
  path:=win.Document.Folder.Self.Path
  Run,  explorer %path% 
return


EmptyFirst:
	;Gosub, Duplicate
  ;Gosub, onTop
  Gosub, upFolder
return

EmptyFirst2:
  folderList:=["C:\a","C:\b","C:\","D:\","E:\","D:\a","D:\b","E:\a","C:\","C:\b\x"]

  win := GetShellFolder(Win_id)  
  fold_path:=win.Document.Folder.Self.Path

  if array_contains(folderList,fold_path){
    win.Document.CurrentViewMode := 5
    win.Document.IconSize := 34
  }else if InStr(fold_path,"\Pictures\"){
    win.Document.CurrentViewMode := 5
    win.Document.IconSize := 48
  }else{    
    win.Document.CurrentViewMode := 3 
  }
  ;View modes: Icon= 1 ; List=3 ; Details=4 ; Icons=5 ; Tile=6 ;SmallIcon=2 Tile=6, =ThumbStrip=7
  ;MsgBox,,, % fold_path "`n" win.Document.CurrentViewMode "`n" win.Document.IconSize 
return

Empty_2:
Gosub, Duplicate 
;Gosub, upFolder
return



array_contains(haystack, needle){	
 if(!isObject(haystack))
  return false
 if(haystack.Length()==0)
  return false
 for k,v in haystack	{
	StringLower,v,v
	StringLower,needle,needle
		v:=Trim(v), needle:=Trim(needle)		
  if(v==needle)
   return true
	}
 return false
}


GetShellFolder(Win_id){
    for win in ComObjCreate("Shell.Application").Windows  {
			if(win.HWND && win.HWND == Win_id){
				return win
			}
		}			
}
  
  
destroyGui:
  ;MsgBox,,, %  A_Gui "`n" last_Gui, 3   
  Gui, %last_Gui%: Destroy
return


;======================================

GuiDropFiles:
	MouseGetPos,,,Win_id,control
	arr := StrSplit(A_GuiEvent,"`n") 
	file_path:=A_GuiEvent
	objShell:=ComObjCreate("Shell.Application")	


  if(control=="Static4"){ ; folder a
    folder:=folderA
		objFolder:=objShell.NameSpace(folder)
      MsgBox,4100,, % "Move to folder?`n" folder "`n`n" A_GuiEvent  
        IfMsgBox, Yes   
		Loop, parse, A_GuiEvent, `n 
		{
			objFolder.MoveHere(A_LoopField, 64) 
      ;objFolder.MoveHere(A_LoopField, 8|64) ;8-new name if exists ; 64-undo
		}
	}else	if(control=="Static5"){  ; folder  1
     folder:=folder1
		objFolder:=objShell.NameSpace(folder)
    MsgBox,4100,, % "Move to folder?`n" folder "`n`n" A_GuiEvent  
        IfMsgBox, Yes   
		Loop, parse, A_GuiEvent, `n 
		{
			objFolder.MoveHere(A_LoopField, 64) 
		}
  }else	if(control=="Static6"){  ; folder 2
     folder:=folder2
		objFolder:=objShell.NameSpace(folder)
    MsgBox,4100,, % "Move to folder?`n" folder "`n`n" A_GuiEvent  
        IfMsgBox, Yes   
		Loop, parse, A_GuiEvent, `n 
		{
			objFolder.MoveHere(A_LoopField, 64) 
		}
  }else	if(control=="Static7"){  ; folder 3
     folder:=folder3
		objFolder:=objShell.NameSpace(folder)
    MsgBox,4100,, % "Move to folder?`n" folder "`n`n" A_GuiEvent  
        IfMsgBox, Yes   
		Loop, parse, A_GuiEvent, `n 
		{
			objFolder.MoveHere(A_LoopField, 64) 
		}    


  }else	if(control=="Static9"){
    folder:=Music
		objFolder:=objShell.NameSpace(folder)
    
      MsgBox,4100,, % "Move to folder?`n" folder "`n`n" A_GuiEvent  
        IfMsgBox, Yes    
    {
      Loop, parse, A_GuiEvent, `n 
      {
        objFolder.MoveHere(A_LoopField, 64) 
      }  
    }    
  }else	if(control=="Static10"){
    folder:=Pictures
    folder:="D:\Users\Pepe\Pictures\"
		objFolder:=objShell.NameSpace(folder)
    
      MsgBox,4100,, % "Move to folder?`n" folder "`n`n" A_GuiEvent  
        IfMsgBox, Yes    
    {
      Loop, parse, A_GuiEvent, `n 
      {
        objFolder.MoveHere(A_LoopField, 64)         
      }  
    }    
    
	}

return

;======================================

showFolderPaths:
  showPaths:= "a`n" "folderA= " folderA "`n" "folderA2= " folderA2   "    (RClick)"
  . "`n`n" "❶`n" "folder1= " folder1 "`n" "folder1a= " folder1a "    (RClick)"
  . "`n`n" "❷`n" "folder2= " folder2 "`n" "folder2a= " folder2a "    (RClick)"
  . "`n`n" "❸`n" "folder3= " folder3 "`n" "folder3a= " folder3a "    (RClick)"
  . "`n`n"
  ;❶❷ ❸ ❹ ❺  Chr(10102) "`n" Chr(10103) "`n" Chr(10104) "`n" Chr(10105)
/*   showPaths:= "folderA= " folderA  "  (" folderA2  ") - RClick"
  . "`n" "folder1= " folder1  "  (" folder1a  ") - RClick"
  . "`n" "folder2= " folder2  "  (" folder2a  ") - RClick"
  . "`n" "folder3= " folder3  "  (" folder3a   ") - RClick"
   */
  ;MsgBox,4096,, %  showPaths "`n" 
  Progress, zh0 w350  M2 C0y ZX30 ZY10 CWFFFFFF FS8 FM12 WM700 WS700 , %showPaths%, Folder paths, Drozd Tools Win Explorer, Segoe UI Semibold
return

WM_MOUSEMOVE(){  
  global 
  Sleep, 200
	MouseGetPos,,,Win_id,control	
		;if (control="Static3")	{	
  if(A_Gui){	
      ;ToolTip_(A_Gui "`n" control ,t:=2)
    if(control=="Static4"){
      ToolTip_(folderA "`n" folderA2, 0.5)
    }else if(control=="Static5"){
      ToolTip_(folder1 "`n" folder1a, 0.5)        
    }else if(control=="Static6"){
      ToolTip_(folder2 "`n" folder2a, 0.5) 
    }else if(control=="Static7"){
      ToolTip_(folder3 "`n" folder3a, 0.5)
    
    }else if(control=="Static9"){
      ToolTip_(Music "`n" folder_music_2 , 0.5)    
    }else if(control=="Static10"){
      ToolTip_(Pictures "`n" folder_pics_2 , 0.5)    
    }
  }
}
;======================================




;~^g:: Gosub, test 

test:
		WinGet, Win_id , ID, A
		win := GetShellFolder(Win_id)
		MsgBox,,, %  win.Document.Folder.ParentFolder.Self.Path
return

;====================================
 
ToolTip_(tekst,t:=2){
	CoordMode,ToolTip,Screen
	ToolTip, %tekst% ,%tipX%, %tipY%
	t:=t*1000
	Settimer, ToolTip_close , -%t%
}

ToolTip_close:
Settimer, ToolTip_close , Off
ToolTip
;ToolTip,,,,3
return

;=================



GuiContextMenu:
  if(A_GuiControl=="a"  || A_GuiControl="b" || A_GuiControl=button3  || A_GuiControl=button4 || Asc(A_GuiControl)==10102 || Asc(A_GuiControl)==8593 || Asc(A_GuiControl)==10103 || Asc(A_GuiControl)==10104 || RegExMatch(A_GuiControl,"i)button_frame|icons\\transp1\.png|Shell32")) 
    return
  ;  Asc("❶")=10102 ; Asc("❷")=10103; Asc("❸")=10104 ; Asc("❹")=10105 ; Asc("↑")=8593
  MouseGetPos,x1,y1 
  Menu, ContextMenu, Show, %x1%, %y1%
Return


Reload:
Reload
return

Exit:
GuiClose:
ExitApp
;Esc:: ExitApp


