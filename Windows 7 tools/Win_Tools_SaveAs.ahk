#SingleInstance force
Menu, Tray, Icon, shell32.dll,  16 ;92 141 145
Menu, Tray, Add, Exit , GuiClose 
Menu, Tray, Default, Exit 
;#NoTrayIcon 

;Jun25 2018  remake; 02/Dec/2015


/* 
• Toolbar for Open, Save As dialogs
• on click go to folders: a, 1,2,3,4, Music, Pics (paths pre-defined ; a= folderA, 1=folder1,...)
• on right click go to another set of folders (paths pre-defined ; a= folderA2, 1=folder1a,...)
• drag and drop to move a file to those folders
• last icon opens ListBox -> list of folders and tasks: click or double click
  • double click on ListBox item "folder size" = size including subfolders 
  • click "folder size" -> size without subfolders
  • "open folder" -> open Window Explorer window with the same path

• Center/size dialog window timer
• folder size in separate file folder_size.ahk

*/

Menu, ContextMenu, Add, Show Folder Paths, showFolderPaths
Menu, ContextMenu, Add, Restart, Reload
Menu, ContextMenu, Add, Exit DrozdTools, Exit
Menu, ContextMenu, Icon, Exit DrozdTools, Shell32.dll, 132


SetWinDelay, -1
SetControlDelay, -1
SetBatchLines, -1

global title_list:="Save As,Save File,Save Image,Open,Open File,Open Files"
global title_list_open:="Open,Open File,Open Files"

global save__
global Gui2_Id, Gui1_Id , WinID
global win_to_stick_to ;"ahk_class #32770" ;"Save As|Open"

;AHK_path:="C:\AutoHotkey Scripts"
;icons_folder:=AHK_path "\icons\"

icons_folder:=A_ScriptDir "\icons\" 
folder_size:= A_ScriptDir "\folder_size.ahk"



global RelX:=220, RelY:=70 ; Win8


/* if RegExMatch(A_OSVersion,"WIN_VISTA"){
  bar=%icons_folder%Vista bar.png
   G_color:= "EAF3FC"
  global RelX:=270, RelY:=64 
}
 */
if RegExMatch(A_OSVersion,"WIN_7"){
  bar=%icons_folder%Win7 bar.png
   G_color:= "EAF3FC"
   ;G_color:="DFE8F1"
  global RelX:=270, RelY:=64 
}else{  
  ;G_color:="EAF3FC"
  G_color:="F5F6F7"
  bar=%icons_folder%Win7 bar.png 
   
  global RelX:=220, RelY:=70 ; Win8
}

button10:="Music"
button11:="Pics"

;==============
folderA:= "C:\a"
folderA2:= A_MyDocuments
folder1:= A_MyDocuments
folder1a:= A_AppData ; roaming 
folder2:= HOMEDRIVE HOMEPATH
folder2a:= A_AppData 
folder3:= A_AppData
folder3a:= LOCALAPPDATA   
folder4:=A_ProgramFiles
folder4a:=A_WinDir ;A_ProgramFiles " (x86)"


folder_music:= HOMEDRIVE HOMEPATH "\Music"    ;"C:\Users\" A_UserName "\Music"
folder_pics:= HOMEDRIVE HOMEPATH "\Pictures"  ; "C:\Users\" A_UserName "\Pictures"

folder_music_2:=""
folder_pics_2:= ""



folder_Documents:="D:\Users\Pepe\Documents"  ;A_MyDocuments 
folder_Roaming:= A_AppData ;%APPDATA% ; roaming  
folder_localData:=LOCALAPPDATA
folder_ProgramFiles:=A_ProgramFiles
folder_UserFolder:=HOMEDRIVE HOMEPATH
;folder_Windows:=A_WinDir "\System32"

;===================================

dialogs:=title_list ;"Save As,Save File,Save Image,Open,Open File"


Save_Open_Exist(){ 
  global win_to_stick_to
  ControlGet, not_old, Visible,, DirectUIHWND2, ahk_class #32770 ;%win_to_stick_to%     
  WinGetTitle,title, %win_to_stick_to%
  if(!WinExist("ahk_class #32770")){
    return false
  }else if(not_old!=1){ 
    return false
  }else if(title in %dialogs%){ 
    return true
  }    
}

Save_Open_active(){ 
  global win_to_stick_to
  ControlGet, not_old, Visible,, DirectUIHWND2, ahk_class #32770 ;%win_to_stick_to%
 ; ControlGet, right_window, Visible,,ToolbarWindow324,%win_to_stick_to%
  SetTitleMatchMode, Regex    
  WinGetTitle,title, %win_to_stick_to%
  if(!WinActive("ahk_class #32770")){
    return false
  }else if(not_old!=1){ 
    return false   
  }else if(title in %dialogs%){ 
    return true
  }    
}

;==============

  CustomColor = 0C6881
  CustomColor_2 = F0F0F0


  Gosub, make_Gui_1
  Gosub, add_List
  SetTimer, Center_Windows, 1000
 
  EventHook := EWinHook_SetWinEventHook("EVENT_OBJECT_DESTROY", "EVENT_OBJECT_LOCATIONCHANGE", 0, "WinProcCallback", 0, 0, "WINEVENT_OUTOFCONTEXT")    
	OnExit(Func("EWinHook_UnhookWinEvent").Bind(EventHook))
  

  OnMessage(0x204, "WM_RBUTTONDOWN")  
return

WM_RBUTTONDOWN(){
  global last_Gui
	if(A_Gui){
		Gosub, Menu_
    last_Gui:=A_Gui
  }
}


 
WinProcCallback(hWinEventHook, event, hwnd, idObject, idChild, dwEventThread, dwmsEventTime){
  Critical
  global WinID, Gui1_Id, Gui2_Id, title_list
  if !hwnd
    return
  hwnd:=Format("0x{1:x}",hwnd)
  event:=Format("0x{1:x}",event)
  if event not in 0x8001,0x8002,0x800B,0x8003  ;EVENT_OBJECT_CREATE:= 0x8000, EVENT_OBJECT_DESTROY:= 0x8001, EVENT_OBJECT_LOCATIONCHANGE:= 0x800B
     return
  ;EVENT_OBJECT_SHOW:= 0x8002, EVENT_OBJECT_HIDE:= 0x8003
      
  ;WinGet, pname, ProcessName,ahk_id %hwnd%  
  WinGetClass, class_, ahk_id %hwnd%  
  WinGetTitle, Title, ahk_id %hwnd%      

  if(class_!="#32770") 
    return

  if(event=0x8001 || event=0x8003){ ; window closed, hide
    ;if(InStr(title_list,Title)){
    if Title in %title_list% 
    {
      Gui,1: -Owner%WinID%
      Gui,1: Hide
    }
  }else if(event=0x8002){ ; window show

    if Title in %title_list% 
    {
      WinGet, pname, ProcessName,ahk_id %hwnd%  
      WinGetClass, class_, ahk_id %hwnd%  
      WinGetTitle, Title, ahk_id %hwnd% 
        
      WinID:=hwnd   
      win_to_stick_to:="ahk_id " WinID 
        ;tool_on:=1
        ;ShowTools()  
        SetTimer, ShowTools, -100              
    }
    
  }else if(event=0x800B){ ; move, re-size	 
    MoveTools()   
  } 
}

ShowTools(){
  global WinID, tool_on
  if (!WinID){
    WinGet, WinID, ID, A
  }
  Gui,1: +Owner%WinID%


  WinGetPos, x2,y2,,, ahk_id %WinID% ; ahk_class #32770
  if(x2 && y2){
    x:= x2 + RelX  
    y:=y2+RelY
  }
  Gui,1: Show, x%x% y%y%  ;NA ;NoActivate  

  tool_on:=1
  SetTimer, NoMsgFIX, 100
}

MoveTools(){
  global WinID, Gui1_Id, Gui2_Id
  WinGetPos, x2,y2,,, ahk_id %WinID% ;ahk_class #32770
    if(x2 && y2){
      x:= x2 + RelX
      y:=y2+RelY
    }
  ;WinMove, ahk_id %Gui1_Id%,, %x%, %y%
  WinMove, Drozd_win_tool_1,, %x%, %y%
}

NoMsgFIX:
  if(!Save_Open_Exist() && tool_on){
    Gui,1: -Owner%WinID%
    Gui,1: Hide
    tool_on:=0
    SetTimer, NoMsgFIX, Off
  }
return



;===========================

make_Gui_1:
  ;G_color= EAF3FC   ; G_color=0C6881
  ;❶❷ ❸ ❹ ❺  Chr(10102) "`n" Chr(10103) "`n" Chr(10104) "`n" Chr(10105)
  Gui, New, +ToolWindow -caption	+HwndGui1_Id ;-border
  Gui,1: Color, %G_color% ;120F00 
  
  if(FileExist(bar)){
    Gui,1: Add, Picture, x0 y0 w420 h28   BackgroundTrans, %bar% ; %icons_folder%Vista bar.png
  }else{
    Gui,1: Add, Text , x-100 y-100  BackgroundTrans Center,
  }
  
  Gui,1: +ToolWindow 
  Gui,1:Color, %G_color% 
 
 
  font_1:="000000" , font_2:="0C3E4C" , font_3:="0C6881" ,   font_5:="800000"  ; Win7
  font_2a:="333333" ,font_3a:="085B72",font_3b:="067898",font_4:="004254"
     
  Gui,1: Font, S11 W700 c%font_3% Q5,  Segoe UI ;Verdana
  Gui,1: Add, Text , x39 y2 w26 h16  vButA ggo_a BackgroundTrans  Center,  a
  
  
  Gui,1: Font, S8 W700 c%font_3% Q5, Segoe UI    
  Gui,1: Add, Text , x77 y6 w34 h16 vBut1 gfolder_1 BackgroundTrans Center, % Chr(10102)  ; ❶   
  Gui,1: Add, Text , x+8 w34 h16  vBut2 gfolder_2 BackgroundTrans Center, %  Chr(10103) ; ❷  
  Gui,1: Add, Text , x+8 w34 h16  vBut3 gfolder_3 BackgroundTrans Center,  %  Chr(10104) ;❸  
  Gui,1: Add, Text , x+8  w34 h16  vBut4 gfolder_4 BackgroundTrans   Center, % Chr(10105) ; ❹  
     

     
  Gui,1: Font, S8 W700 c%font_4% , Segoe UI
  Gui,1: Add, Text , x272 y6 w34 h16 vBut10 gMus BackgroundTrans Center ,  %button10% ; Music
  Gui,1: Add, Text , x+12 w34 h16 vBut11 gPics BackgroundTrans Center,  %button11% ; Pics   

  Gui,1: Add, Picture, x32 y4 w40 h20  ggo_a  BackgroundTrans Icon181 AltSubmit, imageres.dll
  
  Gui,1: Add, Picture, x74 y4 w40 h20 gfolder_1    BackgroundTrans Icon181 AltSubmit, imageres.dll
  Gui,1: Add, Picture, x+2  w40 h20  gfolder_2   BackgroundTrans Icon181 AltSubmit, imageres.dll
  Gui,1: Add, Picture, x+2  w40 h20 gfolder_3    BackgroundTrans Icon181 AltSubmit, imageres.dll
  Gui,1: Add, Picture, x+2  w40 h20  gfolder_4   BackgroundTrans Icon181 AltSubmit, imageres.dll
 
  Gui,1: Add, Picture, x266 y4 w46 h20  gMus   BackgroundTrans Icon181 AltSubmit, imageres.dll 
  Gui,1: Add, Picture, x+2     w46 h20 gPics    BackgroundTrans Icon181 AltSubmit, imageres.dll 
 


  ;Gui,1: Add, Picture, x370 y6 w16 h16  gshowList  BackgroundTrans Icon248 AltSubmit, shell32.dll ; 


  ;Gui,1: Add, Picture, x370 y4 w18 h18   gshowList  BackgroundTrans Icon249 AltSubmit, shell32.dll
  
  switch=%icons_folder%switch1.png

  if(FileExist(switch)){
    Gui,1: Add, Picture,  x370 y4 w18 h18  gshowList  BackgroundTrans , %switch% 
  }else{ 
    Gui,1: Add, Picture, x370 y4 w18 h18   gshowList  BackgroundTrans Icon249 AltSubmit, shell32.dll
  } 
  
  
   
  Gui,1: Font, S7 W400  , Segoe UI
  Gui,1: Add, Text , x238 y3 w28  h22  BackgroundTrans Center , ;aaa
  ;Gui,1: Add, Text , x2 y7  w80 h20 c900000 vadres1 gopen_folder BackgroundTrans Center ,  

   Gui,1:Show, Hide   w420 h25  NA , Drozd_win_tool_1

  WinSet, Style, -0xC00000, Drozd_win_tool_1 ; COMPLETELY remove window border
  WinSet, Region, 22-0 400-0 400-27 22-27 , Drozd_win_tool_1 ; ahk_id %Gui1_Id%   
  
/*   if(!FileExist(bar))
    WinSet, TransColor, %G_color%, Drozd_win_tool_1 ;ahk_id %Gui1_Id% ; transparent Gui
   */
  Gui,1:Hide,  
return


;==============


~LButton::
  MouseGetPos,,,Win_id, control 
  if (Win_id != GuiListHwnd)   
   Gui,5:Hide      
return



Menu_:
MouseGetPos,,, Win_id, control

  if(A_GuiControl="ButA"){ ; a
    Gosub, go_a2    
  }else if(A_GuiControl="But1"){
    Gosub, folder_1a
  }else if(A_GuiControl="But2"){ 
    Gosub, folder_2a

  }else if(A_GuiControl="But3"){ 
    Gosub, folder_3a ; goToFolder(folder_2a)
  }else if(A_GuiControl="But4"){ 
    Gosub, folder_4a ; goToFolder(folder_4a)
     
  }else if(A_GuiControl="But10"){ 
    goToFolder(folder_music_2)  
  }else if(A_GuiControl="But11"){ 
    goToFolder(folder_pics_2)    
  

  }

return




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
; https://autohotkey.com/boards/viewtopic.php?t=830 cyruz

EWinHook_UnhookWinEvent(hWinEventHook) {
    DllCall("UnhookWinEvent", "Ptr",hWinEventHook)
    DllCall("CoUninitialize")
}



;================================================



go_a:  
goToFolder(folderA)
return

go_a2: 
goToFolder(folderA2)
return


folder_1: 
goToFolder(folder1)
return

folder_1a: 
goToFolder(folder1a)
return

folder_2: 
goToFolder(folder2)
return

folder_2a: 
goToFolder(folder2a)
return

folder_3: 
goToFolder(folder3)
return

folder_3a: 
goToFolder(folder3a)
return


folder_4: 
goToFolder(folder4)
return


folder_4a: 
goToFolder(folder4a)
return


Mus: 
goToFolder(folder_music)
return

Pics: 
goToFolder(folder_pics)
return


;=============================


goToFolder(folder_path){
  global
  if (!FileExist(folder_path) && !InStr(folder_path,"::{")){    
    MsgBox,4096,, %  "No folder:" "`n" folder_path , 3
    ShowTools()
    return
  }
  ControlGet, Edit2_Vis, Visible,,Edit2, ahk_class #32770 ;%win_to_stick_to%
  if(Edit2_Vis=1){
   ControlClick,Edit1 , %win_to_stick_to%
   sleep, 200
   ;WinActivate,  ahk_class #32770
  }
  WinGetTitle,title, %win_to_stick_to%
  
  if RegExMatch(A_OSVersion,"WIN_7|WIN_VISTA"){
    control_:= InStr(title,"Open") ? "ToolbarWindow323" : "ToolbarWindow324"
    ControlGetPos , x1, y1, Width, Height, %control_% , %win_to_stick_to%
    x:= x1 - 10
    y:= y1 + 4
  }else{     
    control_:= InStr(title,"Open") ? "ToolbarWindow323" : "ToolbarWindow324"
    ControlGetPos , x1, y1, Width, Height, %control_% , ahk_class #32770
    x:= x1 + Width - 10
    y:= y1 + 6
  }  
  ControlClick, x%x% y%y% , %win_to_stick_to%
  Sleep 100    
  
  ControlSetText , Edit2, %folder_path%, %win_to_stick_to%

  Sleep 100
  ControlSend, Edit2,  {Enter}  , %win_to_stick_to%
  WinActivate,%win_to_stick_to%
  
  fn:=Func("ShowTools")
  SetTimer, %fn% , -100	
}

;=============================


showList:
  MouseGetPos,x1,y1, Win_id, control
  WinGet, last_Win_id , ID, A
  WinGetPos, x2,y2,w2,h2, A
  ControlGet, CtrlHwnd, Hwnd,, %control%, ahk_id %Win_id%
  WinGetPos, x2,y2,w2,h2, ahk_id %CtrlHwnd%	
  Gui,5: Show, % "x" x2-56 " y" y2-3
return

add_List:
  Gui,5: +ToolWindow +AlwaysOnTop -caption   +HwndGuiListHwnd  
  Gui,5: Margin, 0,0
  Gui,5: Font, S8 W700  , Segoe UI
  lista:=create_list()
  ;Gui,5: Add, ListBox, x0 y0 w80 r14 vListBox_1 gList, %lista%
  arr1:=StrSplit(lista,"|"), len:=arr1.Length() 
  Gui,5: Add, ListBox, x0 y0 w80 r%len% vListBox_1  +HWNDListBox_id_5 , %lista%
  fn := Func("ListBox_Func_1").Bind(ListBox_id_5)
	GuiControl, +g, % ListBox_id_5, % fn
   
  Gui,5:Show, Hide , win_add_List_1 - Drozd  
  Gui,5:Hide
return

;============================

create_list(){
  ;list:="open folder|-------|Documents|Windows|Pictures|Music|ProgramFiles|Roaming|-------|folder size|folder size*"
  list:="open folder|folder size|-------|" A_UserName "|Documents|Pictures|Music|-------|Windows|ProgramFiles|Roaming|-------|Network"
  return list
}

;============================


ListBox_Func_1(hwnd){ 
  global lastEvent, lastListBox
	GuiControlGet, list_folder,5: , % hwnd
  lastEvent:=A_GuiEvent
	lastListBox:=list_folder

  SetTimer, ListBox_Clicks, % DllCall("GetDoubleClickTime")
  ;Gui,5: Hide
}

ListBox_Clicks:
  SetTimer, ListBox_Clicks, Off
	if(lastEvent="DoubleClick"){    
    if(lastListBox=="folder size"){ 
      fold_path:=getFolderPath_SaveOpen()
      Run, %folder_size% "%fold_path%"

    }else if(lastListBox=="open folder"){
      Gosub, open_folder  
  
    }else if(lastListBox=="Windows"){ 
      goToFolder(A_WinDir "\System32")
    }else if(lastListBox=="Roaming"){ 
      goToFolder(LOCALAPPDATA)
    }else if(lastListBox=="ProgramFiles"){ 
      goToFolder(folder_ProgramFiles " (x86)")  


    }
    Gui,5: Hide

    fn:=Func("ShowTools")
    SetTimer, %fn% , -100	
  }else if(lastEvent="Normal"){    
      Gosub, List    
  }
return

;============================

List:
  Gui,5: Submit,Nohide
  ListBox_1:=lastListBox
  if(ListBox_1=="AHK"){ 
    goToFolder("C:\AutoHotkey Scripts")    
     
  }else if(ListBox_1=="sport"){
    goToFolder("C:\a\sport")

  }else if(ListBox_1=="podcast"){
    goToFolder("C:\a\podcast")     


  }else if(ListBox_1=="Profile"){ 
    goToFolder(folder_Profile)
  }else if(ListBox_1=="Documents"){ 
    goToFolder(folder_Documents)
  }else if(ListBox_1=="Windows"){ 
    goToFolder(A_WinDir)     
  }else if(ListBox_1==A_UserName){ 
    goToFolder(folder_UserFolder)   
  }else if(ListBox_1=="Roaming"){ 
    goToFolder(folder_Roaming)  
  }else if(ListBox_1=="ProgramFiles"){ 
      goToFolder(folder_ProgramFiles)  
  }else if(ListBox_1=="Network"){ 
      goToFolder("::{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}")   



  }else if(ListBox_1=="Pictures"){ 
    goToFolder(folder_pics)     
  }else if(ListBox_1=="Music"){ 
    goToFolder(folder_music)  

  }else if(ListBox_1=="open folder"){
    Gosub, open_folder  
    
  }else if(ListBox_1=="folder size"){
    fold_path:=getFolderPath_SaveOpen()
    Run, %folder_size% "%fold_path%" "0" "" "" "" 
    
  }else if(ListBox_1=="folder size*"){ 
    ControlGetText, fold_path, Edit2, ahk_id %WinID%
    Run, %folder_size% "%fold_path%"
  }
  Gui,5:Hide
  fn:=Func("ShowTools")
  SetTimer, %fn% , -100	
return


;=======================

open_folder:
/*    fold_path:=""
 ControlGetText, fold_path, Edit2, ahk_class #32770 ;%win_to_stick_to%
	if(!fold_path)
  ControlGetText, adr, ToolbarWindow323, ahk_class #32770
  fold_path:=RegExReplace(adr,"Address: ","")  
   */
  fold_path:=getFolderPath_SaveOpen()
  Run, explorer %fold_path%   
return




;==========================

getFolderPath_SaveOpen(){
  fold_path:=""
	win_dialog:= "ahk_class #32770" 
	ControlGet, vis_, Visible,, DirectUIHWND2, ahk_class #32770
	;if ! vis_
		;return	
     ; ControlGetText, fold_path, Edit2, %win_dialog%
     ; MsgBox,,, % fold_path
  ;if(!fold_path){
   ;ControlGetText, adr, ToolbarWindow323, ahk_class #32770  ;%win_dialog%
    WinGetTitle,title, %win_dialog%
    if RegExMatch(A_OSVersion,"WIN_7|WIN_VISTA"){
      control_:= InStr(title,"Open") ? "ToolbarWindow322" : "ToolbarWindow323"
    }else{
      control_:= InStr(title,"Open") ? "ToolbarWindow323" : "ToolbarWindow324"
    }    
    ControlGetText, adr,  %control_%, %win_dialog%  ; ahk_class #32770 
    fold_path:=RegExReplace(adr,"Address: ","") 
  ;}    
		;MsgBox,,, % fold_path  
    return fold_path
}		




;==========================


show_tip(tip,t:=500){ 
  Tooltip, %  tip
  SetTimer, off_tip, -%t%
}

off_tip:  
    Tooltip
return





;======================



GuiDropFiles:
	MouseGetPos,,,Win_id,control
	file_path:=A_GuiEvent

  if(control=="Static2"){ ; folder a
    folder:=folderA		
      MsgBox,4100,, % "Move to folder?`n`n" folder "`n`n" A_GuiEvent  
        IfMsgBox, Yes   
    FileMove, %file_path% , %folder%
	}else	if(control=="Static3"){  ; folder 1
    folder:=folder1	
      MsgBox,4100,, % "Move to folder?`n`n" folder "`n`n" A_GuiEvent  
          IfMsgBox, Yes   
    FileMove, %file_path% , %folder%
    
	}else	if(control=="Static4"){  ; folder 2
    folder:=folder2	
      MsgBox,4100,, % "Move to folder?`n`n" folder "`n`n" A_GuiEvent  
          IfMsgBox, Yes   
    FileMove, %file_path% , %folder%
        
	}else	if(control=="Static5"){  ; folder 3
    folder:=folder3	
      MsgBox,4100,, % "Move to folder?`n`n" folder "`n`n" A_GuiEvent  
          IfMsgBox, Yes   
    FileMove, %file_path% , %folder%    
    
	}else	if(control=="Static6"){  ; folder 4
    folder:=folder4	
      MsgBox,4100,, % "Move to folder?`n`n" folder "`n`n" A_GuiEvent  
          IfMsgBox, Yes   
    FileMove, %file_path% , %folder%   


	}else	if(control=="Static7"){  ; folder music
    folder:=folder_music	
      MsgBox,4100,, % "Move to folder?`n`n" folder "`n`n" A_GuiEvent  
          IfMsgBox, Yes   
    FileMove, %file_path% , %folder%     
	}else	if(control=="Static8"){  ; folder pics
    folder:=folder_pics	
      MsgBox,4100,, % "Move to folder?`n`n" folder "`n`n" A_GuiEvent  
          IfMsgBox, Yes   
    FileMove, %file_path% , %folder%   
    
  }
  ShowTools()
return

;======================

Center_Windows: 
  if Save_Open_active()
    WinMove, ahk_class #32770 ,,320,120,860,610  
return
;======================

GuiContextMenu:
  if RegExMatch(A_GuiControl,"ButA|But\d+|shell32.dll") ; |imageres.dll
      return  
  ;Menu, ContextMenu, Show, %A_GuiX%, %A_GuiY%
  MouseGetPos,x1,y1 
  Menu, ContextMenu, Show, %x1%, %y1%
Return

;======================================

showFolderPaths:
  showPaths:= "a`n" "folderA= " folderA "`n" "folderA2= " folderA2   "    (RClick)"
  . "`n`n" "❶`n" "folder1= " folder1 "`n" "folder1a= " folder1a "    (RClick)"
  . "`n`n" "❷`n" "folder2= " folder2 "`n" "folder2a= " folder2a "    (RClick)"
  . "`n`n" "❸`n" "folder3= " folder3 "`n" "folder3a= " folder3a "    (RClick)"
  . "`n`n" "❹`n" "folder4= " folder4 "`n" "folder3a= " folder4a "    (RClick)" 
  
  . "`n`n" "`n" "folder_music= " folder_music "`n" "folder_music_2= " folder_music_2 "    (RClick)" 
  . "`n`n" "`n" "folder_pics= " folder_pics "`n" "folder_pics_2= " folder_pics_2 "    (RClick)" 
  
  . "`n`n"
  ;MsgBox,4096,, %  showPaths "`n" 
  Progress, zh0 w350  M2 C0y ZX30 ZY10 CWFFFFFF FS8 FM12 WM700 WS700 , %showPaths%, Folder paths, Drozd Tools Win Explorer, Segoe UI Semibold
return

;======================================



Reload:
Reload
return

Exit:
GuiClose:
ExitApp
;Esc:: ExitApp

;#Include C:\AutoHotkey Scripts\functions.ahk
