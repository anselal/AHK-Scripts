; Quick Notes by Drozdman
; save file in Unicode

/*  
• Script for AutoHotkey_L. Save file in Unicode.
• Eight notes/tabs with customizable names stored in separate files with backup.
• Borderless movable window. 
• Always on top button.
• F1 - previous tab, F2 - next tab
• Switch small/bigger window. 
• Letter and word count on any key press or button press (plus reverse text).
• No taskbar button. Press F4 or click on the script's tray icon to bring window to the front.
• save on exit
• 'Find in text' with RegEx switch on/off
• Help - help button
*/
SetBatchLines, -1
SetWinDelay, -1
SetControlDelay, -1

Width_B:=765 , Height_B:=592

#SingleInstance force

Menu, Tray, Icon, shell32.dll,71   
;Menu, Tray, Icon, C:\Program Files\Misc\AutoHotkey Scripts\icons\Documents-icon.ico
Menu, Tray, Add, Settings, GoSettings
Menu, Tray, Add, Show Notes, Show_Notes ; double click tray icon to show
Menu, Tray, Default, Show Notes 
Menu, Tray, Default, Settings
Menu, ContextMenu, Add, Settings, GoSettings
Menu, ContextMenu, Add, Open folder, Open_folder
Menu, ContextMenu, Add, Exit, Close

Menu, Tray, NoStandard 
Menu, Tray, Add , E&xit, Close 

;=======================================
FileEncoding, UTF-8
  

;ico:=InStr(A_OSVersion,"WIN_VISTA") ? 25: 18
FileGetVersion, ver, wmploc.DLL ;C:\WINDOWS\System32\wmploc.DLL
RegExMatch(ver,"(\d+)\.\d+\.(\d+)", out) ;new 12.0.10240.16384 
new_wmploc:=(out1>=10 && out2>=8000) 
sett_ico:=new_wmploc ? 18 : 25
onTop_ico:=new_wmploc ? 13 : 17


;A_WorkingDir
WorkingDir :=A_ScriptDir
folder_path := WorkingDir . "\notes_files\"

If !FileExist(WorkingDir "\notes_files") 
	FileCreateDir  , % WorkingDir "\notes_files"

global settings_ini := folder_path . "Quick_Notes_settings.ini"
global Find_from_sel
IfNotExist, %settings_ini%
{
		IniWrite, %folder_path% , %settings_ini%, WorkingDir, Folder
		Loop, 8 {
			if (A_Index < 2 ){
			IniWrite, Note%A_Index%, %settings_ini%, Note%A_Index%, Name
			IniWrite, Segoe UI, %settings_ini%, Note%A_Index%, Font
			IniWrite, 10, %settings_ini%, Note%A_Index%, Size
			IniWrite, Default, %settings_ini%, Note%A_Index%, Color	
			IniWrite, Segoe UI, %settings_ini%, Note%A_Index%, Font_Big
			IniWrite, 11, %settings_ini%, Note%A_Index%, Size_Big	
			}else if (A_Index = 2 ) {	
			IniWrite, Note%A_Index%, %settings_ini%, Note%A_Index%, Name
			IniWrite, Segoe UI Semibold, %settings_ini%, Note%A_Index%, Font
			IniWrite, 9, %settings_ini%, Note%A_Index%, Size
			IniWrite, 900000, %settings_ini%, Note%A_Index%, Color	
			IniWrite, Segoe UI Semibold, %settings_ini%, Note%A_Index%, Font_Big
			IniWrite, 10, %settings_ini%, Note%A_Index%, Size_Big				
			}else if (A_Index = 3 ) {	
			IniWrite, Note%A_Index%, %settings_ini%, Note%A_Index%, Name
			IniWrite, Lucida Console , %settings_ini%, Note%A_Index%, Font
			IniWrite, 9, %settings_ini%, Note%A_Index%, Size
			IniWrite, 009000, %settings_ini%, Note%A_Index%, Color	
			IniWrite, Lucida Console , %settings_ini%, Note%A_Index%, Font_Big
			IniWrite, 10, %settings_ini%, Note%A_Index%, Size_Big	
			}else if (A_Index = 4 ) {	
			IniWrite, Note%A_Index%, %settings_ini%, Note%A_Index%, Name
			IniWrite, Tahoma , %settings_ini%, Note%A_Index%, Font
			IniWrite, 10, %settings_ini%, Note%A_Index%, Size
			IniWrite, 000090, %settings_ini%, Note%A_Index%, Color	
			IniWrite, Tahoma , %settings_ini%, Note%A_Index%, Font_Big
			IniWrite, 11, %settings_ini%, Note%A_Index%, Size_Big					
			}else if (A_Index <= 6 ) {
			IniWrite, Note%A_Index%, %settings_ini%, Note%A_Index%, Name
			IniWrite, Times New Roman, %settings_ini%, Note%A_Index%, Font
			IniWrite, 10, %settings_ini%, Note%A_Index%, Size
			IniWrite, Default, %settings_ini%, Note%A_Index%, Color
			IniWrite, Times New Roman, %settings_ini%, Note%A_Index%, Font_Big
			IniWrite, 11, %settings_ini%, Note%A_Index%, Size_Big					
			}else if (A_Index = 7 ) {
			IniWrite, Note%A_Index%, %settings_ini%, Note%A_Index%, Name
			IniWrite, Segoe UI Semibold, %settings_ini%, Note%A_Index%, Font
			IniWrite, 9, %settings_ini%, Note%A_Index%, Size
			IniWrite, Default, %settings_ini%, Note%A_Index%, Color	
			IniWrite, Segoe UI Semibold, %settings_ini%, Note%A_Index%, Font_Big
			IniWrite, 10, %settings_ini%, Note%A_Index%, Size_Big				
			}else{
			IniWrite, Note%A_Index%, %settings_ini%, Note%A_Index%, Name
			IniWrite, Segoe Print, %settings_ini%, Note%A_Index%, Font
			IniWrite, 9, %settings_ini%, Note%A_Index%, Size
			IniWrite, Default, %settings_ini%, Note%A_Index%, Color	
			IniWrite, Segoe Print, %settings_ini%, Note%A_Index%, Font_Big
			IniWrite, 10, %settings_ini%, Note%A_Index%, Size_Big	
			}
		}
			IniWrite, 0, %settings_ini%, Misc, Search Option
}
Sleep 60



load_vars(){
		global
		Loop, 8 {		 
				IniRead, n%A_Index%, %settings_ini%, Note%A_Index%, Name
				IniRead, font_%A_Index%, %settings_ini%, Note%A_Index%, Font
				IniRead, f_size_%A_Index%, %settings_ini%, Note%A_Index%, Size
				IniRead, font_B_%A_Index%, %settings_ini%, Note%A_Index%, Font_Big
				IniRead, f_size_B_%A_Index%, %settings_ini%, Note%A_Index%, Size_Big
				IniRead, font_color_%A_Index%, %settings_ini%, Note%A_Index%, Color
				
		}
		IniRead, Find_from_sel, %settings_ini%, Misc, Search Option
}

	load_vars()
	
	
;=======================================

Gui,1: +ToolWindow     
Gui,1: -border +Resize  +Minsize400x330 
Gui,1: +hwndthis_id1
Gui,1:Color, 0B4761        ; DCE8ED    ; 78BBE5   ;  dark   8BAFBE 6B8590
Gui,1:Font,  S10 CDefault , Segoe UI  
Gui,1: Add, Picture, x10 y4 w16 h16 gLoad Icon71 AltSubmit, shell32.dll ; 
Gui,1: Add, Picture, x35 y4 w16 h16 gSave Icon259 AltSubmit, shell32.dll ;

Gui,1: Add, Picture, x62 y4 w16 h16  vRec Icon28 AltSubmit, shell32.dll ;  Icon145 Icon28
Gui,1: Add, Picture, x60 y4 w16 h16  vGet  Icon147 AltSubmit, shell32.dll ;  Icon44 

Gui,1: Add, Picture, x210 y4 w16 h16 vonTop1  gonTop Icon%onTop_ico% AltSubmit, wmploc.dll
;Gui,1: Add, Picture, x240 y4 w16 h16 vonTop1  gonTop Icon248 AltSubmit, shell32.dll ;
Gui,1: Add, Picture, x210 y4 w16 h16 vonTop2 gonTop Icon247 AltSubmit, shell32.dll ;

Gui,1: Add, Picture, x286 y4 w16 h16 gBig Icon269 AltSubmit, shell32.dll ;
Gui,1: Add, Picture, x313 y3 w16 h16  vBac gBackup Icon32 AltSubmit, shell32.dll ; Icon41
;Gui,1: Add, Picture, x335 y4 w16 h16  gGoSettings Icon25 AltSubmit, wmploc.dll ; ,imageres.dll,  64 109
;Gui,1: Add, Picture, x335 y4 w16 h16  gGoSettings Icon18 AltSubmit, wmploc.dll ; Win8

Gui,1: Add, Picture, x335 y4 w16 h16  gGoSettings Icon%sett_ico% AltSubmit, wmploc.dll

Gui,1: Add, Picture, x355 y4 w16 h16  gHelp_popup Icon24 AltSubmit, shell32.dll ;
Gui,1: Add, Picture, x381 y4 w16 h16  gClose  Icon132 AltSubmit, shell32.dll  ;  

Gui,1:Font, S8 W700 , Verdana ; Arial  
Gui,1: Add, Text, x90 y4 w40 cCE2640 vRESULT gNumber_of_letters , % Chr(9632)  ;■  ; x120 y4 
Gui,1:Font, S8 W400 , Verdana
Gui,1: Add, Text, x150 y4 w36 c5C7DE2 vRESULT2 gNumber_of_words , % Chr(9632)  ;■   ; x185 y4

;Gui,1: Add, Picture, x410 y4 w16 h16  gOpen_folder Icon206 AltSubmit, shell32.dll ; x335 y4 ; Icon4
;Gui,1: Add, Text, x520 y4  cC8C8C8 gReverse , ツ  ;x220 y4 
;Gui,1: Add, Text, x335 y4  cC8C8C8 gReverse , ツ  ;x220 y4 


GuiControl, Hide, Rec
GuiControl, Hide, Get
GuiControl, Hide, onTop1



;============= Tabs =======================

/* 
      ; change tabs names
n1:="Note1" ,n2:="Note2" ,n3:="Note3", n4:="Note4" , n5:="Note5", n6:="Note6", n7:="Note7", n8:="Note8"
 */
 ;n1:="Note Note Note1" ,n2:="Note Note Note2" ,n3:="Note Note Note3", n4:="Note Note Note4" , n5:="Note Note Note5", n6:="Note Note Note6", n7:="Note Note Note7", n8:="Note Note Note8"
 ;GuiSize:
 Gui,1:Font, S8 , Segoe UI Bold   
 
 
/*  ; new Tab3
;Gui,1: Add, Tab3, x0 y25  -Wrap   -Background vTabName gChange , %n1%|%n2%|%n3%|%n4%|%n5%|%n6%|%n7%|%n8%
Gui,1: Add, Tab3, x0 y25   -Background vTabName gChange , %n1%|%n2%|%n3%|%n4%|%n5%|%n6%|%n7%|%n8%
w:=Width_B ,h:=Height_B

loop 8 {
	Gui,1: Tab, %A_Index%
	f_size:=f_size_%A_Index%, font_color:=font_color_%A_Index% , font_:=font_%A_Index%
	Gui,1: Font ,  S%f_size% c%font_color% , %font_%    
		Gui,1: Add, Edit,  x0 y+0  w%w% h%h% 0x100 vNOTE%A_Index%  , %text%     ; 0x100 for ES_NOHIDESEL style ; set selection without focus
} 
*/

 ;  old Tab2
 
 Gui,1: Add, Tab2, x0 y25 w403  -wrap +Theme -Background vTabName gChange , %n1%|%n2%|%n3%|%n4%|%n5%|%n6%|%n7%|%n8%

loop 8 {
	Gui,1: Tab, %A_Index%
	f_size:=f_size_%A_Index%, font_color:=font_color_%A_Index% , font_:=font_%A_Index%
	Gui,1: Font ,  S%f_size% c%font_color% , %font_%    
	Gui,1: Add, Edit,  x0 y45 w400 h290 0x100 vNOTE%A_Index%  , %text%     ; 0x100 for ES_NOHIDESEL style ; set selection without focus
}


;=======================================

ShowBig:=0
Gui 1:Show, w400 h330 , Quick Notes - Drozd

/* ShowBig:=1
Gui 1:Show, w%Width_B% h%Height_B% , Quick Notes - Drozd
 */
Gosub, Load_All

Gosub,Big
ShowBig:=1

OnMessage(0x404, "AHK_NOTIFYICON")
OnMessage(0x100, "WM_KEYDOWN")
OnMessage(0x0101, "WM_KEYUP")  ; WM_KEYUP
OnMessage(0x201, "WM_LBUTTONDOWN") 
OnMessage(0x03, "WM_MOVE")

Gosub, Find_toolbar
return


;=======================================


GuiContextMenu:
Menu, ContextMenu, Show, %A_GuiX%, %A_GuiY%
Return

Help_popup:
	Gui,2: +ToolWindow
	; Gui,2:Color,AAB9C3 
	Gui,2: +hwndthis_id2
	Gui,2: Margin, 10, 10
	Gui,2:Font,  S7 w700 CDefault , Segoe UI  
	Gui,2:-border
	h_pos:=help_pos()
	x1:= h_pos[1]
	y1:= h_pos[2]
	Gui,2:Show,  x%x1% y%y1%   h285  w170 , Help_popup - Drozd
	
	Gui,2: Add, Picture, x10 y6 w16 h16 BackgroundTrans Icon71 AltSubmit, shell32.dll ; 
	Gui,2: Add, Text, x50 y7 BackgroundTrans , Load note from file
	Gui,2: Add, Picture, x10 y31 w16 h16 BackgroundTrans Icon259 AltSubmit, shell32.dll ;
	Gui,2: Add, Text, x50 y33 BackgroundTrans , Save note to file
	Gui,2: Add, Picture, x10 y56 w16 h16  BackgroundTrans Icon269 AltSubmit, shell32.dll
	Gui,2: Add, Text, x50 y58 BackgroundTrans ,  Window size
	;Gui,2: Add, Picture, x10 y81 w16 h16   Icon206 AltSubmit, shell32.dll ;  Icon4
	;Gui,2: Add, Text, x50 y81 BackgroundTrans ,  Open folder with files
	Gui,2: Add, Picture, x10 y81 w16 h16  Icon%sett_ico% AltSubmit, wmploc.dll   
	Gui,2: Add, Text, x50 y81 BackgroundTrans ,  Settings
	Gui,2: Add, Picture, x10 y104 w16 h16   Icon32 AltSubmit, shell32.dll ; Icon41
	Gui,2: Add, Text, x50 y104 BackgroundTrans ,  Load from backup file
	Gui,2: Add, Picture, x10 y128 w16 h16  Icon247 AltSubmit, shell32.dll 
	Gui,2: Add, Text, x50 y128 BackgroundTrans ,  AlwaysOnTop toggle
	
	Gui,2: Add, Text, x0 y152 w170 0x10  ;  separator
	Gui,2:Font, w400 
	Gui,2: Add, Text, x10 y160 BackgroundTrans , ` - Click on tray icon or press F4 `n    to bring window to the front
	Gui,2: Add, Text, x10 y188 BackgroundTrans , ` - Number of characters shown in red,  `n    number of words shown in blue
	;Gui,2: Add, Text, x10 y216 BackgroundTrans , ` - Choose custom names for tabs  `n    inside the script
	Gui,2: Add, Text, x10 y216 BackgroundTrans , ` - Find in text Ctrl+F , find next F3  `n 
	Gui,2: Add, Text, x10 y230 BackgroundTrans , ` - F1: previous tab, F2: next tab  `n 
	Gui,2: Add, Text, x10 y245 BackgroundTrans , ` - Click + mouse wheel = Page up/down  `n 
	Gui,2: Add, Text, x10 y260 gRev_but , ` - Reverse: Shift+Ctrl+Alt+R
	
	;Gui,2: Add, Text, x10 y244  , 	
return

; =====================================================

;==========================
;DisableWindowsFeature

OnStaticDoubleClick(W, L, M, H) { ; prevent copy to  clipboard when double clicked ; by just me autohotkey.com/boards/viewtopic.php?t=3569
   Static Dummy1 := OnMessage(0x00A2, "OnStaticDoubleClick") ; WM_NCLBUTTONUP
   Static Dummy2 := OnMessage(0x00A3, "OnStaticDoubleClick") ; WM_NCLBUTTONDBLCLK
   Static Dummy3 := OnMessage(0x0202, "OnStaticDoubleClick") ; WM_LBUTTONUP
   Static Dummy4 := OnMessage(0x0203, "OnStaticDoubleClick") ; WM_LBUTTONDBLCLK
   Static LBtnDblClicks := {0x00A3: 0x00A1, 0x0203: 0x0201}
   Global StaticDoubleClick := False
	 ;ToolTip_("--- " A_GuiControl "`n" A_GuiEvent,3,1)
   If (A_GuiControl) && LBtnDblClicks.Haskey(M) {
      GuiControlGet, HCTRL, Hwnd, %A_GuiControl%
      WinGetClass, Class, ahk_id %HCTRL%
      If (Class = "Static") {
         StaticDoubleClick := True
         PostMessage, % LBtnDblClicks[M], %W%, %L%, , ahk_id %HCTRL%
         Return 0
			}
   }
}
;==========================


AHK_NOTIFYICON(wParam, lParam){
    if (lParam = 0x202) {       ; WM_LBUTTONUP
		Gui, 1:Show  
    }else if (lParam = 0x203){   ; WM_LBUTTONDBLCLK
		Gui, 1: Show
	}
}


WM_KEYUP(){
	global Curr_Index, TabName
/* 	Loop 8 {
		if (TabName=n%A_Index%) {
			Curr_Index=%A_Index%
		}			
	}
	 */
	Gosub, Number_of_letters
	Gosub, Number_of_words
}


WM_LBUTTONDOWN(){
	global 
	if(A_Gui=1){
		PostMessage, 0xA1, 2    ; movable borderless window 
	}
}

get_caret_pos:
	Loop 9 {
		if(TabName=n%A_Index%)
			Curr_Index=%A_Index%			
	}
	;get caret position , next find position on click
		VarSetCapacity(Pos1, 4, 0)
		VarSetCapacity(Pos2, 4, 0)
		SendMessage, 0x00B0, &Pos1, &Pos2,Edit%Curr_Index%, Quick Notes - Drozd	; EM_GETSEL=0x00B0 
		Pos1 := NumGet(Pos1)
		Pos2 :=	NumGet(Pos2)	
		caret_pos:=Pos1
		caret_pos2:=Pos2
		pos:=Pos2
return

scroll_find(hwnd){ ; set in the middle of control (10 lines from top)
	VarSetCapacity(Pos1, 4, 0), VarSetCapacity(Pos2, 4, 0)
	SendMessage, 0x00B0, &Pos1, &Pos2,,  % "ahk_id " hwnd 	; EM_GETSEL=0x00B0 
	Pos1 := NumGet(Pos1), Pos2 :=	NumGet(Pos2)
	SendMessage,0x00C9, Pos1 ,0 , ,  % "ahk_id " hwnd  ;EM_LINEFROMCHAR
	SelLineNum:=ErrorLevel+1
	SendMessage, 0x00CE, 0,0 , ,  % "ahk_id " hwnd ;M_GETFIRSTVISIBLELINE
	firstVisLineNum:=ErrorLevel+1
	scrolNum:=SelLineNum - firstVisLineNum
	scrolNum2:=(scrolNum<10) ?  -(10-scrolNum) : scrolNum-10
	SendMessage, 0x00B6, 0, %scrolNum2% ,  , % "ahk_id " hwnd  ; EM_LINESCROLL
	;return (SelLineNum - firstVisLineNum)
}

; =====================================================

help_pos(){
	WinGetPos, x, y, Width, Height, Quick Notes - Drozd
	x1 := x + Width
	y1 :=  y    ; Abs() 
	; return, object( 1, x, 2, y, 3, Width, 4,Height )
	return, object( 1, x1, 2, y1)
}

toolbar_pos(){
	WinGetPos, x, y, Width, Height, Quick Notes - Drozd
	f_x1 := x+5
	f_y1 :=  y + Height -40   
	f_w := (Width-16)
	;f_y1 :=  y + 50 ;top
	return, object( 1, f_x1, 2, f_y1, 3 ,f_w )
}

WM_MOVE(){
   WinGetPos, x1,y1,w1,h1, Quick Notes - Drozd
   ;WinGetPos, x2,y2,w2,h2, Find toolbar - Drozd  
   If (A_Gui=1) {
	  x := x1+5 
	  y :=  y1 + h1 -40   
	  w := (w1-10)
	  ; y :=  y1 + 50  ; top
      WinMove, Find toolbar - Drozd  ,, x, y, w
	  WinMove, Help_popup - Drozd  ,,% x1+ w1, y1, 
   }
}

WM_KEYDOWN(wParam, lParam){
    if (A_Gui = 3 && wParam = 13){ ; VK_ENTER := 13
		Gosub, Find
    }else if (A_Gui=3 && wParam != 13 && wParam != 114) {
		 SendMessage, 0x00B1, %pos1%, %pos1%, Edit%Curr_Index% , Quick Notes - Drozd ; remove selection
	}	
}


Change:
Gui, Submit, NoHide	
	 	Loop 8 {
		if (TabName=n%A_Index%) {
			Curr_Index=%A_Index%
			}	
		}
	Gosub, Number_of_letters
	Gosub, Number_of_words
return


Find_toolbar:
	Gui,3:+owner1 
	Gui,3: +ToolWindow -border
	Gui,2: +hwndthis_id3
	InvertedColor = EDF0FF 
	Gui,3:+Delimiter`n 
	Gui,3:Color, 120F00 
	Gui,3:Font, S8 W600 , Verdana ; Tahoma
	;Gui,3: Add, Edit, x70 y4 w140 h20 vQuery_1 , ;Search 
	Gui,3: Add, ComboBox, x70 y4 w140  0x100 vQuery_1 , ; Search 
	
	Gui,3: Font, S7 W700 , Tahoma ; Tahoma  Verdana
	Gui,3: Add, Text , x224 y9  cFFFFFF gFind  , Find  ;w40 h24
	; Gui,3: Font, S12 W700 ,  Verdana
	
	Gui,3: Add, Text, x290 y9  cFFFFFF gFind_Next , Next  
	;Gui,3: Add, Text, x286 y9  cFFFFFF gFind_Next , Next  ;w40 h24
    Gui,3:Font, S11
	Gui,3: Add, Text, x340 y4 w60 h40 cFFFFFF gFind_Close , X
	
	Gui,3: Font, S7 W700 , Segoe UI ;Tahoma 
	Gui,3: Add, Text, x258 y8  cFFFFFF gFind_Prev , Prev
	Gui,3:Font, S7 W700 Q5
	Gui,3: Add, Text , x0 y7 w70 cFFFFFF  vFindFromPos Center, 
	Gui,3: Font, S1
	;Gui,3: Add, GroupBox,  x216 y4 w40 h20   
	;Gui,3: Add, GroupBox,  x268 y4 w40 h20  
	
	Gui,3: Font, S8
	Gui,3: Add, Checkbox, x340 y8 w13 h13 vFind_Regex
	Gui,3: Font, S7
	Gui,3: Add, Text, x+8  cCCCCCC vtextFind_Regex gFind_RegexSwitch , RegEx 
	
	
	t_pos:=toolbar_pos()
	; f_x1:= toolbar_pos()[1]
	f_y1 := toolbar_pos()[2]
	f_w := toolbar_pos()[3]
	;Gui,3:Show,  y%f_y1%  w494 h30  , Find toolbar - Drozd  
	;Gui,3:Show,  y%f_y1%  w%f_w% h30  , Find toolbar - Drozd
	
	; WinSet, Transparent, 200,  Find toolbar - Drozd  	
	Gui,3: Hide
return

Find_RegexSwitch:
GuiControlGet, Find_Regex , 3: , Find_Regex	
GuiControl,3: ,Find_Regex , % !Find_Regex
return

Find_toolbar_show:
	t_pos:=toolbar_pos()
	f_x1:= toolbar_pos()[1]
	f_y1:= toolbar_pos()[2]
	f_w:= toolbar_pos()[3]
		Gui,3:Show, x%f_x1% y%f_y1%  w%f_w% h30  , Find toolbar - Drozd  ;w494 h30  
		WinSet, Transparent, 200,  Find toolbar - Drozd 	  
return


;====================

add_to_ComboBox_find(box,new_val,max,add_to_list:=false){
	ControlGet,list_, List, ,%box%, Find toolbar - Drozd
	list_array:=StrSplit(list_,"`n")
  if(list_array.Length()>max){
    Control, Delete, % list_array.Length(), %box% , Find toolbar - Drozd
		}

if(!array_contains(list_array, new_val)){
		;ControlGet, list_,3:List, ,%box%, Find toolbar - Drozd
		new_box:= "`n" new_val "`n" list_ 		
		GuiControl,3:, %box%, %new_box% 
		GuiControl,3:ChooseString, %box%, %new_val% ; select	
	}else{
		GuiControl,3:ChooseString, %box%, %new_val% ; select	
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


;====================

~^f:: 
	IfWinNotActive, Quick Notes - Drozd
		return
		;Gosub, Find
		;Gosub,Find_toolbar_show

	Gui, Submit, NoHide	
 	Loop 9 {
		if (TabName=n%A_Index%) {
			global Curr_Index
			Curr_Index=%A_Index%
		}	
	}
	 
		ControlGet, Sel,Selected,, Edit%Curr_Index%, Quick Notes - Drozd  ; get selected text for search
			Sel:=Trim(Sel)
			Sel:=RegExReplace(Sel, ",|;|:|-|\.", "")
			Query := (Sel && Find_from_sel=1) ? Sel : Query_1
	 if(Sel && Find_from_sel=1){
			add_to_ComboBox_find("ComboBox1",Query, 8, true)
			;GuiControlGet, Edit1_, , Edit1
			
			SendMessage, 0x00B1, 0, StrLen(Query) , Edit1 , Find toolbar - Drozd ; EM_SETSEL ;select query
	 }	
	Gosub,Find_toolbar_show	 
return

Find:
		Gosub,Find_toolbar_show
		Gui,3: Submit, Nohide

		GuiControlGet, Query ,3: , Query_1
		add_to_ComboBox_find("ComboBox1",Query, 8, true)
		Query_ := (Find_Regex=1) ? Query : "\Q" RegExReplace(Query,"i)\\Q|\\E","") "\E"
		Note_searched := RegExReplace(Note%Curr_Index%, "`n", "`r`n") ; necessary fix - `r automatically changed to `r`n 
		
		;Query := RegExReplace(Query, "^\s*([\s\S]*?)\s*$", "$1")		
	
		pos1:=RegExMatch(Note_searched,"im)" Query_, Output)-1	
		pos2:=pos1 + StrLen(Query)		
		pos:= pos2
		
		if(pos1<0){
			;MsgBox,4096,, %   "Nope", 1 
			GuiControl,3:, FindFromPos, % Chr(10006)  ;  ✖  
			Gui,3:Font, s8 w700 cDD0000  
			GuiControl,3:Font, FindFromPos
			GuiControl,3: Show , FindFromPos
			SetTimer, hide_FindFromPos, 1000
			return
		}
		 
		SendMessage, 0x00B1, %pos1%, %pos2%, Edit%Curr_Index% , Quick Notes - Drozd ; EM_SETSEL
		SendMessage,0x00B7, 0, 0, Edit%Curr_Index% , Quick Notes - Drozd ;    EM_SCROLLCARET  Scroll caret into view
		
		ControlGet, ControlHWND, Hwnd,, Edit%Curr_Index%, Quick Notes - Drozd  
		ScrollPos:=DllCall("GetScrollPos", "UInt", ControlHWND, "Int", 1) 
		
		ControlGet, Curr_Line, CurrentLine,,Edit%Curr_Index%, Quick Notes - Drozd 
				x:= Curr_Line - ScrollPos -8
		SendMessage, 0x00B6, 0, %x% , Edit%Curr_Index% , Quick Notes - Drozd ; EM_LINESCROLL
				
return



~$F3:: 
	If WinActive("Quick Notes - Drozd") || WinActive("Find toolbar - Drozd")
		Gosub, Find_Next
return


Find_Next:
		Gui,3: Submit, Nohide
		GuiControlGet, Query ,3: , Query_1
		Query_ := (Find_Regex=1) ? Query : "\Q" RegExReplace(Query,"i)\\Q|\\E","") "\E"
		Gosub, get_caret_pos
		add_to_ComboBox_find("ComboBox1",Query, 8, true)
		Note_searched := RegExReplace(Note%Curr_Index%, "`n", "`r`n") ; necessary fix - `r automatically changed to `r`n 
		Array:=Object()		
		pos_ := 1
		While pos_ {
			pos_:=RegExMatch(Note_searched, "im)" Query_, Output, pos_)
			if(pos_!=0){
				Array.Push(pos_)
			}
			pos_:=pos_+StrLen(Output)
		}
		len:=Array.Length()
	
  Loop % Array.Length()
  {
			if(caret_pos2>Array[len]){	
					from:=1
					ind:=1
					break
			}else if(Array[A_Index] <= caret_pos2){	
					continue
			}else if(Array[A_Index] > caret_pos2){
					ind:=A_Index
					ind:= (ind>len) ? 1 : ind
					from:=Array[ind]	
					break
			}				
  }
		
		show_num_finds(len,ind)

		pos1:=RegExMatch(Note_searched,"im)" Query_, Output, from ) -1
		pos2:=pos1 + StrLen(Output)
		pos:= pos2
		caret_pos2:=pos2

		if(pos1<0){
			GuiControl,3:, FindFromPos, % Chr(10006)  ;  ✖  
			Gui,3:Font, s8 w700 cDD0000  
			GuiControl,3:Font, FindFromPos
			GuiControl,3: Show , FindFromPos
			SetTimer, hide_FindFromPos, 1000
			return
		}

		SendMessage, 0x00B1, %pos1%, %pos2%, Edit%Curr_Index% , Quick Notes - Drozd ; EM_SETSEL
		SendMessage,0x00B7, 0, 0, Edit%Curr_Index% , Quick Notes - Drozd ;    EM_SCROLLCARET  Scroll caret into view
		
		ControlGet, ControlHWND, Hwnd,, Edit%Curr_Index%, Quick Notes - Drozd  
		ScrollPos:=DllCall("GetScrollPos", "UInt", ControlHWND, "Int", 1) 
		
		ControlGet, Curr_Line, CurrentLine,,Edit%Curr_Index%, Quick Notes - Drozd 
				x:= Curr_Line - ScrollPos -8
				
		SendMessage, 0x00B6, 0, %x% , Edit%Curr_Index% , Quick Notes - Drozd ; EM_LINESCROLL
return


 
Find_Prev: 
		Gui,3: Submit, Nohide
		GuiControlGet, Query ,3: , Query_1
		Query_ := (Find_Regex=1) ? Query : "\Q" RegExReplace(Query,"i)\\Q|\\E","") "\E"
		add_to_ComboBox_find("ComboBox1",Query, 8, true)
	;	ControlSend, Edit1,  ^a  , Find toolbar - Drozd ; select query	
		Gosub, get_caret_pos
		Note_searched := RegExReplace(Note%Curr_Index%, "`n", "`r`n") ; necessary fix - `r automatically changed to `r`n 

		Array:=Object()		
		pos_ := 1
		While pos_ {
			pos_:=RegExMatch(Note_searched, "im)" Query_, Output, pos_)
			if(pos_!=0){
				Array.Push(pos_)
			}		
			pos_:=pos_+StrLen(Output)
		}
		len:=Array.Length()
		;show_num_finds(len)
	
		from:=len
  Loop % Array.Length()
  {
			if(caret_pos<=Array[1] || caret_pos>Array[len]){	
				from:=Array[len]
				ind:= len 
			}else if(Array[A_Index] < caret_pos){		
					continue
			}else if(Array[A_Index] >= caret_pos){	
					from:=Array[A_Index-1]			
					ind:=A_Index-1					
					break
			}				
  }
		
		show_num_finds(len,ind)
		
		pos1:=RegExMatch(Note_searched,"im)" Query_, Output, from )-1
		pos2:=pos1 + StrLen(Output)		
		pos:= pos2
		caret_pos:=pos1

		if(pos1<0){
			GuiControl,3:, FindFromPos, % Chr(10006)  ;  ✖  
			Gui,3:Font, s8 w700 cDD0000  
			GuiControl,3:Font, FindFromPos
			GuiControl,3: Show , FindFromPos
			SetTimer, hide_FindFromPos, 1000
			return
		}
		
		SendMessage, 0x00B1, %pos1%, %pos2%, Edit%Curr_Index% , Quick Notes - Drozd ; EM_SETSEL
		SendMessage, 0x00B7, 0, 0, Edit%Curr_Index% , Quick Notes - Drozd ;    EM_SCROLLCARET  Scroll caret into view
		
		ControlGet, ControlHWND, Hwnd,, Edit%Curr_Index%, Quick Notes - Drozd  
		ScrollPos:=DllCall("GetScrollPos", "UInt", ControlHWND, "Int", 1) 
		
		ControlGet, Curr_Line, CurrentLine,,Edit%Curr_Index%, Quick Notes - Drozd 
				x:= Curr_Line - ScrollPos -8
				
		SendMessage, 0x00B6, 0, %x% , Edit%Curr_Index% , Quick Notes - Drozd ; EM_LINESCROLL
return

show_num_finds(num,ind:=""){
		x:= num " [" ind "]"
		GuiControl,3:, FindFromPos, %x% 
		GuiControl,3: Show , FindFromPos
		SetTimer, hide_FindFromPos, 4000 
}

hide_FindFromPos:
	SetTimer, hide_FindFromPos, Off 
	GuiControl,3: Hide , FindFromPos
	GuiControl,3:, FindFromPos, From pos
	Gui,3:Font, S7 W700 cFFFFFF 
	GuiControl,3:Font, FindFromPos
return


Find_Close:
	Gui,3: Hide
return



Show_Notes:
	Gui, 1:Show
return


~LButton::
	MouseGetPos,,, Win_id,control
	
	if(Win_id != this_id2){  
		Gui, 2: Destroy
	}

return




Save:
	Gui, Submit, NoHide
		Loop 8 {
				if (TabName=n%A_Index%) {					
					FileDelete, %folder_path%note%A_Index%_backup.txt
					FileCopy, %folder_path%note%A_Index%.txt, %folder_path%note%A_Index%_backup.txt
					FileDelete, %folder_path%note%A_Index%.txt
					GuiControlGet,NOTE_actv, ,Note%A_Index%
					FileAppend, %NOTE_actv% , %folder_path%note%A_Index%.txt
					
					ControlGet, controlHWND, Hwnd,, Edit%A_Index% , ahk_id %this_id1% 
					SendMessage, 0xB9, 0, 0,  , % "ahk_id " controlHWND  ; EM_SETMODIFY = 0xB9  ;clear 'modified'
					Break
				}	
			}
	Gosub, Rec
Return


Load:
	Gui, Submit, NoHide

	Loop 8 {
		if (TabName=n%A_Index%) {
		FileRead, from_file, %folder_path%note%A_Index%.txt
		GuiControl,, Note%A_Index% , %from_file%
		
		;SendMessage, 0x115, 7, 0, Edit%A_Index%, Quick Notes - Drozd             ; scroll to bottom
		;SendMessage, 0x00B1, -2, -1, Edit%A_Index% ,  Quick Notes - Drozd ; EM_SETSEL
		
		Break
		}	
	}
	Gosub, Get	
	Gosub,Number_of_letters
	Gosub, Number_of_words
return

Load_All:
		Gui, Submit, NoHide
		Loop 8 {
			FileRead, from_file, %folder_path%note%A_Index%.txt
			GuiControl,, Note%A_Index% , %from_file%		
		}	
	
		Loop 8 {
			;if (A_Index != 5){
			SendMessage, 0x115, 7, 0, Edit%A_Index%, Quick Notes - Drozd             ; scroll to bottom
			SendMessage, 0x00B1, -2, -1, Edit%A_Index% ,  Quick Notes - Drozd ; EM_SETSEL
			SendMessage,0x00B7, 0, 0, Edit%A_Index% , Quick Notes - Drozd ;    EM_SCROLLCARET  Scroll caret into view
			;}			
		}

return


Backup:
	Gui, Submit, NoHide
	
	Loop 8 {
		if (TabName=n%A_Index%) {
		FileRead, from_file, %folder_path%note%A_Index%_backup.txt
		GuiControl,, Note%A_Index% , %from_file%
		Break
		}	
	}
	
	Gosub, Get
	Gosub,Number_of_letters
Return

Save_All_and_Exit:
		Gui, Submit, NoHide		
		Loop 8 {			
			ControlGet, controlHWND, Hwnd,, Edit%A_Index% , ahk_id %this_id1% 
      SendMessage, 0xB8, 0, 0, , % "ahk_id " controlHWND  ; EM_GETMODIFY = 0xB8
			if(ErrorLevel==1){
				FileDelete, %folder_path%note%A_Index%_backup.txt
				FileCopy, %folder_path%note%A_Index%.txt, %folder_path%note%A_Index%_backup.txt
				FileDelete, %folder_path%note%A_Index%.txt
				GuiControlGet,NOTE_actv, ,Note%A_Index%
				FileAppend, %NOTE_actv% , %folder_path%note%A_Index%.txt
			}
		}	
		ExitApp
return


Rec:
   GuiControl, Show, Rec
   SetTimer, Hide_rec_get, 900
Return

Get:
	GuiControl, Show, Get
	SetTimer, Hide_rec_get, 900
Return

Hide_rec_get:
	GuiControl, Hide, Rec
	GuiControl, Hide, Get
	SetTimer, Hide_rec_get, off
Return

Open_folder:
	run  %A_WorkingDir%
Return


; =====================================================

Big:
	 if(ShowBig=0){
			ShowBig:=1
			
/* 			ControlMove, Static11, 735,12
			ControlMove, Static10, 705,12
			ControlMove, Static9, 680,13
			ControlMove, Static8, 650,12	
			ControlMove, Static7, 600,14
			ControlMove, Static6, 450,14
			ControlMove, Static5, 450,14
			 */
			; WinMove, Quick Notes - Drozd, , 400,180 , 765, 592
			;CenterWindowSize("Quick Notes - Drozd",765, 592 )
			;Width_B:=765 , Height_B:=592
			CenterWindowSize("Quick Notes - Drozd",Width_B, Height_B )

		Loop 8 {
			NOTE_actv := "NOTE" A_Index
			;GuiControl, Move, %NOTE_actv%,  w750 h530
			GuiControl, Move, %NOTE_actv%, % "w" Width_B -15 "h" Height_B -62
			;Gui, Font ,  S%font_B_%%A_Index% c%font_color_%%A_Index% , %font_%%A_Index%  
			;Gui, Font,  S12  , Times New Roman 	
			f_size_cur:=f_size_B_%A_Index% " c" font_color_%A_Index%
			f_cur:=font_B_%A_Index%
			Gui, Font , s%f_size_cur% ,  %f_cur%
			GuiControl, Font, NOTE%A_Index%		   
		}	

			GuiControl,3: Show, textFind_Regex 
		}else{
			ShowBig:=0
			GuiControl,3: Hide, textFind_Regex
			; WinMove, Quick Notes - Drozd, , 580,270 , 415, 360
			CenterWindowSize("Quick Notes - Drozd",415, 360 )
			
/* 			ControlMove, Static11, 388, 12
			ControlMove, Static10, 355, 12
			ControlMove, Static9, 335, 13
			ControlMove, Static8, 313, 12	
			ControlMove, Static7, 278, 14
			ControlMove, Static6, 240,12
			ControlMove, Static5, 240,12
			 */
		Loop 8 {
			NOTE_actv := "NOTE" A_Index
			GuiControl, Move, %NOTE_actv%, w400 h300
			;Gui, Font, S10 CDefault , Segoe UI  
			f_size_cur:=f_size_%A_Index% " c" font_color_%A_Index%
			f_cur:=font_%A_Index%
			Gui, Font , s%f_size_cur% ,  %f_cur%
			GuiControl, Font, NOTE%A_Index%					   
			}			 			
		}
return



CenterWindow(WinTitle){
    WinGetPos,,, Width, Height, %WinTitle%
    WinMove, %WinTitle%,, % (A_ScreenWidth/2)-(Width/2), % (A_ScreenHeight/2)-(Height/2)
}

CenterWindowSize(WinTitle, Width, Height ){
    WinMove, %WinTitle%,, % (A_ScreenWidth/2)-(Width/2), % (A_ScreenHeight/2)-(Height/2), % Width, % Height
}



onTop:

		WonTop:=!WonTop             
		if WonTop {
		WinSet, AlwaysOnTop, on, Quick Notes - Drozd ; ahk_class AutoHotkeyGUI,
		GuiControl, Hide , onTop2
		GuiControl, Show , onTop1
		}else{
		WinSet, AlwaysOnTop, off, Quick Notes - Drozd 
		GuiControl, Hide , onTop1
		GuiControl, Show , onTop2
		}	
return

; =====================================================


Number_of_letters:
	Gui, Submit, NoHide
	if(!Curr_Index){
		Loop 8 {
			if(TabName=n%A_Index%)
				Curr_Index=%A_Index%	
		}
	}
	GuiControlGet,NOTE_actv, ,Note%Curr_Index%
	num := StrLen(NOTE_actv)
	GuiControl,, RESULT, %num% 
return

 
Number_of_words:
	Gui, Submit, NoHide
	if(!Curr_Index){
		Loop 8 {
			if(TabName=n%A_Index%)
				Curr_Index=%A_Index%	
		}
	}
	GuiControlGet,NOTE_actv, ,Note%Curr_Index%
	RegExReplace( NOTE_actv, "\w+", "", Count ) ; 
	GuiControl,, RESULT2, %Count% 	
 return

; =====================================================
2Reverse:
 Reverse:
 	 Gui, Submit, NoHide
	Loop 8 {
		if (TabName=n%A_Index%) {
			GuiControlGet,NOTE_actv, ,Note%A_Index%
			rev:=Flip(NOTE_actv)
			; GuiControl,, NOTE_actv , %rev%
			GuiControl,, Note%A_Index% , %rev%
			; msgbox,,, Reverse: %rev%,4
			Break
		}	
	}
	  Flip(Str) {
		AutoTrim, Off
	  ;Str:=RegExReplace(Str, " ","|")
	  Loop, Parse, Str,
	  res=%A_LoopField%%res%
	  ;res:=RegExReplace(res, "\|"," ")
	  AutoTrim, On
	  return res
	  }
 return
 
~$F4::
	Gui 1: Show
return

~+!^r:: 
	If WinActive("Quick Notes - Drozd") || WinActive("Help_popup - Drozd")
	Gosub, Reverse	
return

Rev_but:
	;Gosub, Reverse
	Send, +!^r
return

; =====================================================

Notes_settings:
Gui,4:+owner1 
Gui,4: +ToolWindow 
Gui,4:Add, Button , x140 y340 w60 h22  gSaveSet , Save
Gui,4:Add, Button , x240 y340 w60 h22  gCancel_but , Cancel
Gui,4:Add, Tab, x10 y10 w430 h320  , Notes Names|Fonts|Fonts Big|Misc

Gui,4: Tab, 1 
Gui,4: Font, S8  , Segoe UI Bold ;
Gui,4:Add, Text,  x110 y36   , Custom Names for Notes

Gui,4: Font, S8 W400 , Tahoma 
Gui,4:Add, Text, x40 y64   , Note1
Gui,4:Add, Edit, x+40 y60 w140 vSet_Note1 , Note1
Gui,4:Add, Text, x40  y94   , Note2
Gui,4:Add, Edit, x+40 y90 w140 vSet_Note2 , Note2
Gui,4:Add, Text, x40  y124  , Note3
Gui,4:Add, Edit, x+40 y120 w140 vSet_Note3 , Note3
Gui,4:Add, Text, x40  y154  , Note4
Gui,4:Add, Edit, x+40 y150 w140 vSet_Note4 , Note4
Gui,4:Add, Text, x40  y184  , Note5
Gui,4:Add, Edit, x+40 y180 w140 vSet_Note5 , Note5
Gui,4:Add, Text, x40  y214  , Note6
Gui,4:Add, Edit, x+40 y210 w140 vSet_Note6 , Note6
Gui,4:Add, Text, x40  y244  , Note7
Gui,4:Add, Edit, x+40 y240 w140 vSet_Note7 , Note7
Gui,4:Add, Text, x40  y274  , Note8
Gui,4:Add, Edit, x+40 y270 w140 vSet_Note8 , Note8

Gui,4:Add, Text, x100  y306  , Restart the program for new settings to take effect

Gui,4: Tab,2

Gui,4: Font, S8  , Segoe UI Bold ;
Gui,4:Add, Text,  x140 y40   , Font Family
Gui,4:Add, Text,  x306 y40   , Size
Gui,4:Add, Text,  x370 y40   , Color


Gui,4: Font, S8 W400 , Tahoma 
Gui,4:Add, Text, x40 y64   , Note1
Gui,4:Add, Edit, x+40 y60 w140 vSet_f_Note1 , Times New Roman Bold
Gui,4:Add, Edit, x+50 y60 w40 vSet_s_Note1 , 11
Gui,4:Add, Edit, x+20 y60 w60 vSet_c_Note1 , 000000
Gui,4:Add, Text, x40  y94   , Note2
Gui,4:Add, Edit, x+40 y90 w140  vSet_f_Note2 , Font
Gui,4:Add, Edit, x+50 y90 w40 vSet_s_Note2  , 11
Gui,4:Add, Edit, x+20 y90 w60 vSet_c_Note2  , 000000
Gui,4:Add, Text, x40  y124  , Note3
Gui,4:Add, Edit, x+40 y120 w140  vSet_f_Note3 , Font
Gui,4:Add, Edit, x+50 y120 w40 vSet_s_Note3  , 11
Gui,4:Add, Edit, x+20 y120 w60 vSet_c_Note3  , 000000
Gui,4:Add, Text, x40  y154  , Note4
Gui,4:Add, Edit, x+40 y150 w140 vSet_f_Note4 , Font
Gui,4:Add, Edit, x+50 y150 w40 vSet_s_Note4  , 11
Gui,4:Add, Edit, x+20 y150 w60 vSet_c_Note4  , 000000
Gui,4:Add, Text, x40  y184  , Note5
Gui,4:Add, Edit, x+40 y180 w140 vSet_f_Note5 , Font
Gui,4:Add, Edit, x+50 y180 w40 vSet_s_Note5  , 11
Gui,4:Add, Edit, x+20 y180 w60 vSet_c_Note5 , 000000
Gui,4:Add, Text, x40  y214  , Note6
Gui,4:Add, Edit, x+40 y210 w140 vSet_f_Note6 , Font
Gui,4:Add, Edit, x+50 y210 w40 vSet_s_Note6  , 11
Gui,4:Add, Edit, x+20 y210 w60 vSet_c_Note6  , 000000
Gui,4:Add, Text, x40  y244  , Note7
Gui,4:Add, Edit, x+40 y240 w140 vSet_f_Note7 , Font
Gui,4:Add, Edit, x+50 y240 w40 vSet_s_Note7  , 11
Gui,4:Add, Edit, x+20 y240 w60 vSet_c_Note7  , 000000
Gui,4:Add, Text, x40  y274  , Note8
Gui,4:Add, Edit, x+40 y270 w140 vSet_f_Note8 , Font
Gui,4:Add, Edit, x+50 y270 w40 vSet_s_Note8  , 11
Gui,4:Add, Edit, x+20 y270 w60 vSet_c_Note8  , 000000


Gui,4: Tab,3

Gui,4: Font, S8  , Segoe UI Bold ;
Gui,4:Add, Text,  x140 y40   , Font Family
Gui,4:Add, Text,  x306 y40   , Size
;Gui,4:Add, Text,  x370 y40   , Color


Gui,4: Font, S8 W400 , Tahoma 
Gui,4:Add, Text, x40 y64   , Note1
Gui,4:Add, Edit, x+40 y60 w140 vSet_f_B_Note1 , Times New Roman Bold
Gui,4:Add, Edit, x+50 y60 w40 vSet_s_B_Note1  , 11
;Gui,4:Add, Edit, x+20 y60 w60 vSet_c_B_Note1 , 000000
Gui,4:Add, Text, x40  y94   , Note2
Gui,4:Add, Edit, x+40 y90 w140  vSet_f_B_Note2 , Font
Gui,4:Add, Edit, x+50 y90 w40 vSet_s_B_Note2  , 11
;Gui,4:Add, Edit, x+20 y90 w60 vSet_c_B_Note2  , 000000
Gui,4:Add, Text, x40  y124  , Note3
Gui,4:Add, Edit, x+40 y120 w140  vSet_f_B_Note3 , Font
Gui,4:Add, Edit, x+50 y120 w40 vSet_s_B_Note3  , 11
;Gui,4:Add, Edit, x+20 y120 w60 vSet_c_B_Note3  , 000000
Gui,4:Add, Text, x40  y154  , Note4
Gui,4:Add, Edit, x+40 y150 w140 vSet_f_B_Note4 , Font
Gui,4:Add, Edit, x+50 y150 w40 vSet_s_B_Note4  , 11
;Gui,4:Add, Edit, x+20 y150 w60 vSet_c_B_Note4  , 000000
Gui,4:Add, Text, x40  y184  , Note5
Gui,4:Add, Edit, x+40 y180 w140 vSet_f_B_Note5 , Font
Gui,4:Add, Edit, x+50 y180 w40 vSet_s_B_Note5  , 11
;Gui,4:Add, Edit, x+20 y180 w60 vSet_c_B_Note5  , 000000
Gui,4:Add, Text, x40  y214  , Note6
Gui,4:Add, Edit, x+40 y210 w140 vSet_f_B_Note6 , Font
Gui,4:Add, Edit, x+50 y210 w40 vSet_s_B_Note6  , 11
;Gui,4:Add, Edit, x+20 y210 w60 vSet_c_B_Note6  , 000000
Gui,4:Add, Text, x40  y244  , Note7
Gui,4:Add, Edit, x+40 y240 w140 vSet_f_B_Note7 , Font
Gui,4:Add, Edit, x+50 y240 w40 vSet_s_B_Note7  , 11
;Gui,4:Add, Edit, x+20 y240 w60 vSet_c_B_Note7  , 000000
Gui,4:Add, Text, x40  y274  , Note8
Gui,4:Add, Edit, x+40 y270 w140 vSet_f_B_Note8 , Font
Gui,4:Add, Edit, x+50 y270 w40 vSet_s_B_Note8  , 11
;Gui,4:Add, Edit, x+20 y270 w60 vSet_c_B_Note8  , 000000

Gui,4: Tab,4
Gui,4: Font, S8  , Segoe UI Bold ;
Gui,4:Add, Text,  x140 y40   , 


Gui,4: Font, S8 W400 , Tahoma 
Gui,4: Add, GroupBox,  x30 y50 w220 h100  , Search Options  
Gui,4:Add, Text, x50 y84   , Query from selection
Gui,4:Add, Edit, x+30 y80 w30 vSearch_Op , 0
Gui,4: Add, GroupBox,  x260 y50 w160 h100  , Help
Gui,4:Add, Text, x270 y70    , 0: Default `n`n1: Selected text in the note `n    is automatically used `n    as the search query

;Gui,4:Add, Radio, vMyRadioGroup,Search Option
;Gui,4: Add, GroupBox,  x16 y20 w40 h20  

font_list1=
(
Times New Roman 
Segoe UI
Lucida Console
Verdana
Arial 
Arial Black
Tahoma 
Courier New
Georgia
)
font_list2=
(
Segoe UI Bold
Segoe UI Semibold
Aharoni
Segoe Script
Segoe Print
Comic Sans MS 
Comic Sans MS Bold
Gotham Rounded A
)
Gui,4: Font, S8  , Segoe UI ;
Gui,4:Add, Edit, x30 y160 w120 h150 -Vscroll ReadOnly, %font_list1%
Gui,4:Add, Edit, x170 y160 w120 h150 -Vscroll ReadOnly, %font_list2%

Gui,4:Show, w450 h370 , Quick Notes Settings - Drozd
Gosub, Load_Settings	

return




Load_Settings:

		IniRead, Find_from_sel, %settings_ini%, Misc, Search Option
		GuiControl,4:, Search_Op , %Find_from_sel%
		
		Loop, 8 {		 
		IniRead, n%A_Index%, %settings_ini%, Note%A_Index%, Name
		IniRead, font_%A_Index%, %settings_ini%, Note%A_Index%, Font
		IniRead, f_size_%A_Index%, %settings_ini%, Note%A_Index%, Size
		IniRead, font_B_%A_Index%, %settings_ini%, Note%A_Index%, Font_Big
		IniRead, f_size_B_%A_Index%, %settings_ini%, Note%A_Index%, Size_Big
		IniRead, font_color_%A_Index%, %settings_ini%, Note%A_Index%, Color
		
}

		Loop, 8 {						
			GuiControl,4:, Set_Note%A_Index% , % n%A_Index%
		
			GuiControl,4:, font_%A_Index% , % font_%A_Index%
			GuiControl,4:, Set_f_Note%A_Index% , % font_%A_Index%
			GuiControl,4:, Set_s_Note%A_Index% , % f_size_%A_Index%		
			GuiControl,4:, Set_c_Note%A_Index% , % font_color_%A_Index%	
			
			GuiControl,4:, Set_f_B_Note%A_Index% , % font_B_%A_Index%
			GuiControl,4:, Set_s_B_Note%A_Index% , % f_size_B_%A_Index%		
			;GuiControl,4:, Set_c_B_Note%A_Index% , % font_color_%A_Index%		
		}
return




SaveSet:
		Gui, Submit, NoHide
	   ;IniRead, Find_from_sel, %settings_ini%, Misc, Search Option
		IniWrite, %Search_Op%, %settings_ini%, Misc, Search Option
		
		Loop, 8 {		 
		IniWrite, % Set_Note%A_Index%, %settings_ini%, Note%A_Index%, Name
		IniWrite, % Set_f_Note%A_Index%, %settings_ini%, Note%A_Index%, Font
		IniWrite, % Set_s_Note%A_Index%, %settings_ini%, Note%A_Index%, Size
		IniWrite, % Set_f_B_Note%A_Index%, %settings_ini%, Note%A_Index%, Font_Big
		IniWrite, % Set_s_B_Note%A_Index%, %settings_ini%, Note%A_Index%, Size_Big
		IniWrite, % Set_c_Note%A_Index%, %settings_ini%, Note%A_Index%, Color
		
		}
		
		load_vars()

		Gosub, Cancel_but	
return



Cancel_but:
	Gui,4: Destroy
	Gui,1:-Disabled
	Gui,1: Show
return


GoSettings:
	Gui,1: +Disabled
	Gosub, Notes_settings
return

4GuiClose:
	Gui 4: Destroy 
 	Gui,1:-Disabled
	Gui,1: Show
return



#IfWinActive  Quick Notes - Drozd
	$F1:: Gosub, GoToPrevTab
	$F2:: Gosub, GoToNextTab
#IfWinActive  

#IfWinActive  Find toolbar - Drozd
	$F1:: Gosub, GoToPrevTab
	$F2:: Gosub, GoToNextTab
#IfWinActive  

GoToNextTab:
	Gosub, checkTabLast
	if(TabCurr=="TabLast"){
		SendMessage, 0x1330, 0,, SysTabControl321, ahk_id %this_id1%  ; 0x1330 is TCM_SETCURFOCUS.
		SendMessage, 0x130C, 0,, SysTabControl321, ahk_id %this_id1%  ; 0x130C is TCM_SETCURSEL.		
	}else
	Control, TabRight , 1, SysTabControl321, ahk_id %this_id1%
	Gosub, Change
return

GoToPrevTab:
	Gosub, checkTabLast
	if(TabCurr=="TabFirst"){
		SendMessage, 0x1330, 7,, SysTabControl321, ahk_id %this_id1%  ; 0x1330 is TCM_SETCURFOCUS.
		SendMessage, 0x130C, 7,, SysTabControl321, ahk_id %this_id1%  ; 0x130C is TCM_SETCURSEL.
	}else
	Control, TabLeft , 1, SysTabControl321, ahk_id %this_id1%
	Gosub, Change
return

checkTabLast:
	TabCurr:=""
	GuiControlGet, Tname , , TabName
	Tfirst:=n1,Tlast:=n8
	
	if(Tname==Tfirst){
		TabCurr:="TabFirst"
	}else if(Tname==Tlast){
		TabCurr:="TabLast"
	}
	;MsgBox,4096,, % Tname "`n" TabCurr
return			 

; =====================================================

/* #IfWinActive Quick Notes - Drozd
WHEEL_DELTA := (120 << 16)
WheelUp::
	SendMessage, 0x00B6, 0, -3, EDIT%Curr_Index% ,  % "ahk_id " this_id1 ; EM_LINESCROLL scroll up  3
	;PostMessage, 0x20A, 7864320, (mY << 16) | mX,, % "ahk_id " this_id1
	;Scroll(7864320)  
return

WheelDown::
	SendMessage, 0x00B6, 0, 3,EDIT%Curr_Index% ,   % "ahk_id " this_id1 ; EM_LINESCROLL scroll   3
	;PostMessage, 0x20A, -7864320, (mY << 16) | mX,, % "ahk_id " this_id1
	;Scroll(-7864320)
return
#IfWinActive 

Scroll(WHEEL_DELTA) {
 MouseGetPos, mX, mY, hWin, hCtrl, 2
 PostMessage, 0x20A, WHEEL_DELTA, (mY << 16) | mX,,% "ahk_id" (hCtrl ? hCtrl:hWin)
} 
 */

 
#IfWinActive Quick Notes - Drozd
~LButton & WheelUp:: Gosub, PageUp  
~LButton & Wheeldown:: Gosub, PageDown
#IfWinActive 

PageDown:
	SendMessage, 0x115, 3, 0,  EDIT%Curr_Index%, % "ahk_id " this_id1 ; scroll PageDown   WM_VSCROLL
return

PageUp:
  SendMessage, 0x115, 2, 0, EDIT%Curr_Index% , % "ahk_id " this_id1 ; scroll PageUp 
return

; =====================================================

GUIDropFiles:
	file_path:=A_GUIEvent
	ControlGetFocus, ctrl_foc , Quick Notes - Drozd
	if(file_path){
			FileRead, from_file, %file_path%
			from_file := RegExReplace(from_file, "`n", "`r`n")
			GuiControl,1:,  %ctrl_foc% , %from_file%
	}
return

; =====================================================

GuiSize:  ; on window resize
		Loop 8 {		
			;GuiControl Move, Edit%A_Index%, % "H" . (A_GuiHeight-44) . " W" . (A_GuiWidth)
			GuiControl Move, Edit%A_Index%, % "H" . (A_GuiHeight-46) . " W" . (A_GuiWidth)
		}	
		GuiControl Move, TabName, %  " W" . (A_GuiWidth+2)  "H" (A_GuiHeight) 
		GuiControl Move, Static11, %  "x" . (A_GuiWidth-20)
		
		
		WinGetPos, x1,y1,w1,h1, Quick Notes - Drozd
		;WinMove, Find toolbar - Drozd  ,,  % (x1+5) ,  (y1 + 50),  (w1-10)  ; top
		WinMove, Find toolbar - Drozd  ,,  % (x1+5) ,  (y1 + h1 - 40),(w1-10)
return


3GuiSize:  
GuiControl Move, Static3, %  "x" . (A_GuiWidth-30)	
return 


GetModified(){
	global this_id1
	str:=""
	Loop 8 {		
			ControlGet, controlHWND, Hwnd,, Edit%A_Index% , ahk_id %this_id1% 
      SendMessage, 0xB8, 0, 0, , % "ahk_id " controlHWND  ; EM_GETMODIFY = 0xB8
			if(ErrorLevel==1)
				str.= "`t" n%A_Index% "`n"
		}
	return str
}


Close:
GuiClose:
	ismodified:=GetModified()
	if (ismodified==""){
		ExitApp
	}else{

		MsgBox, 0x00040003, , Do you want to save before exiting? `nModified:`n%ismodified%
		IfMsgBox, Yes
		 Gosub,Save_All_and_Exit
		IfMsgBox, No
			ExitApp
		IfMsgBox Cancel
			return
	}
return 



/* Close:
GuiClose:
MsgBox, 4100, Confirm exit, Do you want to save before exiting Quick Notes?
IfMsgBox, Yes
 Gosub,Save_All_and_Exit
IfMsgBox, No
  ExitApp
return  */


/* Close:
GuiClose:
MsgBox, 4100, Confirm exit, Do you want to exit Quick Notes?
  IfMsgBox, No
      Return
  ExitApp
return
 */
 


GuiEscape:
3GuiEscape:
	Gui 3: Hide
return

/* 
Close:
ExitApp
return

GuiClose:
ExitApp

 */
 
; Esc:: exitapp