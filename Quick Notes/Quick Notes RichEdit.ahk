/*   
RichEdit version of Quick Notes by Drozdman
• Save file in Unicode.
• Notes with customizable names stored in separate files; plain text backup
• Borderless movable window. • Always on top button. • Switch small/bigger window. Resize 
• Letter and word count 
• No taskbar button. Press F4 or click on the script's tray icon to bring window to the front.

• 'Find in text' Ctrl+F; Windows 'Find in text' - Ctrl+Shift+F 
•  Find button: Find, Find previous, Find next, Mark All (from toolbar query)  
•  F3 - Find next from last selection, Shift + F3 - Find previous from last selection

• RichEdit options in context menu
• Plain text file as backup ; option:  saveBckupTxt:=1
• Settings: default fonts, colors
  In Settings: double click edit to choose colors from a palette
• Remembers window's size and position. To start with default window size, press "Escape" key for a second while starting the program

• Adapted to RichEdit version by using Class_RichEdit by "just me" (also majkinetor). 
	Use the library version included here, because some things were added (searchBkup_restore()), others were altered (like RichEditDlgs.FindText(RE), RichEdit.FindText_2(), RichEditDlgs.ChooseColor())

  If double-click is slowed down, the function OnStaticDoubleClick (DisableWindowsFeature) may be disabled. Though, when the static controls (like "Find", "Next") are double-clicked, their name will be copied to clipboard (such is the Windows "feature"). 
*/

;forum upd Jan10 2019

#SingleInstance force
#NoEnv
SetBatchLines, -1
SetWinDelay, -1
SetControlDelay, -1

Width_B:=765 , Height_B:=592
maxComboItems:=10
remember_size:=1
remember_position:=1

global saveBckupTxt:=1
Number_of_lettersOn:=1 
Number_of_wordsOn:=1
global OpenContexMenuOnDblClick:=1

;global Find_from_sel:=0

;=====  Default
DefaultFontName:="Segoe UI" ; "Times New Roman" 
DefaultFontSize:=10
DefaultFontColor:="000000"
DefaultBackgroundColor:="FFFFFF" ;FCFBF8 F3F1EA  E9E7DE 
;===== 

;===== search mark All
searchMarkAllColor:=0xA3F6A7 , searchMarkAllfont:=0x000000  ;0x70EC9E   ;green	 ;0x81BAF2 ;0x3399FF ;blue
;searchMarkAllColor:=0x368F73 , searchMarkAllfont:=0xF5F5F5 ; green/white
;===== 

	;=====  Time, date stamp
	stampCol:=0xFFFFFF, stampBkCol:=0x444444
	stampSize:=9, stampStyle:="B"
	stampName:="Courier New" ;"Tahoma" ;"Trebuchet MS" ;"Arial Black" 
	;=====




ColorRedFont:="DD0000" 
ColorBlueFont:="0000C5" 
ColorGreenFont:="009700" 
ColorSilverFont:="C1C1C1" 
ColorYellowFont:="FFF300"

ColorYellowHighlight:="FEFFB6" 
ColorRedHighlight:="FFDADA" 
ColorBeigeHighlight:="E7E2C4" 
ColorGreenHighlight:="CDEED0" 
ColorBlueHighlight:="81BAF2"

sizeBigBoldFont:=12


Menu, Tray, Icon, shell32.dll,71   
Menu, Tray, Add, Settings, GoSettings
Menu, Tray, Add, Show Notes, Show_Notes 
Menu, Tray, Default, Show Notes 
Menu, Tray, Default, Settings
Menu, Tray, NoStandard 
Menu, Tray, Add , Exit, Close 

Gosub, ContextMenuMake


;=======================================
  

;ico:=InStr(A_OSVersion,"WIN_VISTA") ? 25: 18
FileGetVersion, ver, wmploc.DLL ;C:\WINDOWS\System32\wmploc.DLL
RegExMatch(ver,"(\d+)\.\d+\.(\d+)", out) ;new 12.0.10240.16384 
new_wmploc:=(out1>=10 && out2>=8000) 
sett_ico:=new_wmploc ? 18 : 25
onTop_ico:=new_wmploc ? 13 : 17


;A_WorkingDir
WorkingDir :=A_ScriptDir
folder_path := WorkingDir . "\notes files\"

If !FileExist(WorkingDir "\notes files") 
	FileCreateDir  , % WorkingDir "\notes files"

global settings_ini := folder_path . "Quick_Notes_settings.ini"

global Curr_Index:=1, TabName
global this_id1, this_id2, this_id3, this_id4

global numOfNotes:=8 ; <=16
global Note1,Note2,Note3,Note4,Note5,Note6,Note7,Note8,Note9,Note10,Note11,Note12,Note13,Note14,Note15,Note16 

if(!FileExist(settings_ini)){
		;IniWrite, %folder_path% , %settings_ini%, WorkingDir, Folder
		Loop, %numOfNotes%  {
			IniWrite, Note%A_Index%, %settings_ini%, Note%A_Index%, Name
		}
			;IniWrite, 0, %settings_ini%, Misc, Search Option
   IniWrite, %numOfNotes%, %settings_ini%, Misc, Number of notes

  writeCustomColors()
}

IniRead, read_1 , %settings_ini%, Highlight colors
IniRead, read_2 , %settings_ini%, Highlight colors
if(read_1=="ERROR" || read_1=="" || read_2=="ERROR" || read_2=="")
   writeCustomColors()

writeCustomColors(){
   global
	IniWrite, %ColorYellowHighlight%, %settings_ini%, Highlight colors, Yellow
	IniWrite, %ColorRedHighlight%, %settings_ini%, Highlight colors, Red 
	IniWrite, %ColorBeigeHighlight%, %settings_ini%, Highlight colors, Beige 
	IniWrite, %ColorGreenHighlight%, %settings_ini%, Highlight colors, Green
	IniWrite, %ColorBlueHighlight%, %settings_ini%, Highlight colors, Blue


	IniWrite, %ColorRedFont%, %settings_ini%, Font colors, Red
	IniWrite, %ColorGreenFont%, %settings_ini%, Font colors, Green
	IniWrite, %ColorBlueFont%, %settings_ini%, Font colors, Blue
	IniWrite, %ColorYellowFont%, %settings_ini%, Font colors, Yellow
	IniWrite, %ColorSilverFont%, %settings_ini%, Font colors, Silver 	
	
	IniWrite, %sizeBigBoldFont%, %settings_ini%, Text big bold, size   

}


   IniRead, read_, %settings_ini%, Misc, Number of notes
   if read_ is integer
   {
      if(read_>0 && read_<=16){
         numOfNotes:=read_
      }else
         numOfNotes:=8
   }

	IniRead, read_3 , %settings_ini%, Misc, Context menu on double-click 
	if(read_3!=0 && read_3==1)
		IniWrite, %OpenContexMenuOnDblClick%, %settings_ini%, Misc, Context menu on double-click


IniRead, read_1, %settings_ini%, Misc, Default font name  
IniRead, read_2, %settings_ini%, Misc, Default font size 
IniRead, read_3, %settings_ini%, Misc, Default font color
IniRead, read_4, %settings_ini%, Misc, Default background color

if(read_1=="ERROR" || read_1=="" || read_2=="ERROR" || read_2=="" || read_3=="ERROR" || read_3=="" || read_4=="ERROR" || read_4==""){
   IniWrite, %DefaultFontName%, %settings_ini%, Misc, Default font name 
   IniWrite, %DefaultFontSize%, %settings_ini%, Misc, Default font size 
   IniWrite, %DefaultFontColor%, %settings_ini%, Misc, Default font color
   IniWrite, %DefaultBackgroundColor%, %settings_ini%, Misc, Default background color   
}





load_vars(){
   global   


   Loop, %numOfNotes%  {		 
      IniRead, n%A_Index%, %settings_ini%, Note%A_Index%, Name
      if(n%A_Index%=="ERROR")
          n%A_Index%:="Note" A_Index
   }
      ;IniRead, Find_from_sel, %settings_ini%, Misc, Search Option		
        
  IniRead, ColorRedFont, %settings_ini%, Font colors, Red
	IniRead, ColorGreenFont, %settings_ini%, Font colors, Green
	IniRead, ColorBlueFont, %settings_ini%, Font colors, Blue
	IniRead, ColorYellowFont, %settings_ini%, Font colors, Yellow
	IniRead, ColorSilverFont, %settings_ini%, Font colors, Silver 
	
	IniRead, ColorYellowHighlight , %settings_ini%, Highlight colors , Yellow
	IniRead, ColorRedHighlight , %settings_ini%, Highlight colors , Red
	IniRead, ColorBeigeHighlight , %settings_ini%, Highlight colors , Beige
	IniRead, ColorGreenHighlight , %settings_ini%, Highlight colors , Green
	IniRead, ColorBlueHighlight , %settings_ini%, Highlight colors , Blue
	
	IniRead, sizeBigBoldFont , %settings_ini%, Text big bold, size
  
  IniRead, OpenContexMenuOnDblClick , %settings_ini%, Misc, Context menu on double-click 
  
  IniRead, DefaultFontName, %settings_ini%, Misc, Default font name  
  IniRead, DefaultFontSize, %settings_ini%, Misc, Default font size  
  IniRead, DefaultFontColor, %settings_ini%, Misc, Default font color
  IniRead, DefaultBackgroundColor, %settings_ini%, Misc, Default background color
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

;Gui,1: Add, Picture, x210 y4 w16 h16 vonTop1  gonTop Icon%onTop_ico% AltSubmit, wmploc.dll
Gui,1: Add, Picture, x210 y4 w16 h16 vonTop1  gonTop Icon248 AltSubmit, shell32.dll ;
Gui,1: Add, Picture, x210 y4 w16 h16 vonTop2 gonTop Icon247 AltSubmit, shell32.dll ;

;Gui,1: Add, Picture, x286 y4 w16 h16 gBig Icon269 AltSubmit, shell32.dll ;
Gui,1: Add, Picture, x286 y4 w16 h16 gStartFind Icon269 AltSubmit, shell32.dll

Gui,1: Add, Picture, x313 y3 w16 h16  vBac gBackup Icon32 AltSubmit, shell32.dll ; Icon41
;Gui,1: Add, Picture, x-3000 y-3000 w16 h16  vBac gBackup Icon32 AltSubmit, shell32.dll ; dummy for "static" numbers


;Gui,1: Add, Picture, x335 y4 w16 h16  gGoSettings Icon25 AltSubmit, wmploc.dll ; ,imageres.dll,  64 109
;Gui,1: Add, Picture, x335 y4 w16 h16  gGoSettings Icon18 AltSubmit, wmploc.dll ; Win8

Gui,1: Add, Picture, x335 y4 w16 h16  gGoSettings Icon%sett_ico% AltSubmit, wmploc.dll

Gui,1: Add, Picture, x355 y4 w16 h16  gHelp_popup Icon24 AltSubmit, shell32.dll ;
Gui,1: Add, Picture, x381 y4 w16 h16  gClose  Icon132 AltSubmit, shell32.dll  ;  

Gui,1:Font, S8 W700 , Verdana ; Arial  
Gui,1: Add, Text, x90 y4 w40 cCE2640 vRESULT gNumber_of_letters , ; % Chr(9632)  ;■  
Gui,1:Font, S8 W400 , Verdana
Gui,1: Add, Text, x150 y4 w36 c5C7DE2 vRESULT2 gNumber_of_words , ; % Chr(9632)  ;■   

;Gui,1: Add, Picture, x410 y4 w16 h16  gOpen_folder Icon206 AltSubmit, shell32.dll ; x335 y4 ; Icon4
;Gui,1: Add, Text, x520 y4  cC8C8C8 gReverse , ツ  ;x220 y4 



GuiControl, Hide, Rec
GuiControl, Hide, Get
GuiControl, Hide, onTop1



;============= Tabs =======================

/*   ; change tabs names
n1:="Note1" ,n2:="Note2" ,n3:="Note3", n4:="Note4" , n5:="Note5", n6:="Note6", n7:="Note7", n8:="Note8", n9:="Note9", n10:="Note10", n10:="Note11", n10:="Note12"
 */

 Gui,1:Font, S8 , Segoe UI Bold   
 
;TCS_FIXEDWIDTH	0x400	 same width

w:=Width_B ,h:=Height_B

tabs_:=""
Loop, %numOfNotes%  {	
   tabs_.= n%A_Index%  "|"
}
Gui,1: Add, Tab2, x0 y25 w%Width_B% +Theme -Wrap -Background vTabName gChange , %tabs_%

	 Gui,1:Font, S9 w400 , Segoe UI 
 
;========================== RichEdit =================================

global RE:= Object() 
WordWrap := True
AutoURL := False

Loop, %numOfNotes%  {
   Gui,1: Tab, %A_Index%
   ;Options :=  "x0 y+0 w" w " h" h " vNOTE" A_Index ; Tab3
   Options :=  "x0 y45 w" w " h" h " vNOTE" A_Index  ; Tab2
   RE[A_Index]:= New RichEdit(1, Options)
   ;RE_SetOleCallback(RE[A_Index].HWND)
   RE[A_Index].WordWrap(WordWrap)
 
  ;========== Default Font
 
  Font := RE[A_Index].GetFont()
  Font.Size:=DefaultFontSize	
	Font.Name:=DefaultFontName
	Font.Color:="0x" DefaultFontColor  ;, Font.BkColor:=0xFFFFFF
	RE[A_Index].SetDefaultFont(Font)
   
  ;========== Background Color
    ;BackgroundColor:=0xE9E7DE ;0xE3E0D1
   BackgroundColor:="0x" DefaultBackgroundColor 
    
   RE[A_Index].SetBkgndColor(BackgroundColor)
     
}


 ;========================== RichEdit =================================
 
 	IniRead, pos_x, %settings_ini%, Misc, x	
	IniRead, pos_y, %settings_ini%, Misc, y	
	IniRead, size_w, %settings_ini%, Misc, w
	IniRead, size_h, %settings_ini%, Misc, h
	Sleep 100
	if(GetKeyState("Esc", "P")!=1 && valid_pos(pos_x) && valid_pos(pos_y)){
  if(remember_size && valid_pos(size_w) && valid_pos(size_h))
    Gui,1: Show, x%pos_x% y%pos_y% w%size_w% h%size_h% , Quick Notes RE - Drozd
    else
    Gui,1: Show, x%pos_x% y%pos_y%  , Quick Notes RE - Drozd 
	}else			
    Gui 1:Show, w%Width_B% h%Height_B% , Quick Notes RE - Drozd

Gosub, Load_All

OnMessage(0x404, "AHK_NOTIFYICON")
OnMessage(0x100, "WM_KEYDOWN")
OnMessage(0x0101, "WM_KEYUP") 
OnMessage(0x201, "WM_LBUTTONDOWN") 
OnMessage(0x03, "WM_MOVE")
OnMessage(0x203,"WM_LBUTTONDBLCLK")

Gosub, Find_toolbar
return


;=======================================


GuiContextMenu:
searchMarkAll_reset(Curr_Index)
Menu, ContextMenu, Show, %A_GuiX%, %A_GuiY%
Return

ContextMenuShow:
Menu, ContextMenu, Show 
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
	Gui,2:Show,  x%x1% y%y1%   h370  w170 , Help_popup RE - Drozd
	
	Gui,2: Add, Picture, x10 y6 w16 h16 BackgroundTrans Icon71 AltSubmit, shell32.dll ; 
	Gui,2: Add, Text, x50 y7 BackgroundTrans , Load note from file
	Gui,2: Add, Picture, x10 y31 w16 h16 BackgroundTrans Icon259 AltSubmit, shell32.dll ;
	Gui,2: Add, Text, x50 y33 BackgroundTrans , Save note to file
	Gui,2: Add, Picture, x10 y56 w16 h16  BackgroundTrans Icon269 AltSubmit, shell32.dll
	Gui,2: Add, Text, x50 y58 BackgroundTrans , Find in text  ; Window size switch
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
	Gui,2: Add, Text, x10 y216 BackgroundTrans , ` - Custom names for notes in settings
	Gui,2: Add, Text, x10 y+1 BackgroundTrans , ` - F1: previous tab, F2: next tab 
	Gui,2: Add, Text, x10 y+4 BackgroundTrans , ` - RichEdit options in context menu
	Gui,2: Add, Text, x10 y+2 BackgroundTrans , ` - Find in text - Ctrl+F. `n    Windows' Find - Ctrl+Shift+F
	Gui,2: Add, Text, x10 y+1 BackgroundTrans , ` - F3 - Find next. Shift+F3 - Find previous `n    (from last selection)
	Gui,2: Add, Text, x10 y+1 BackgroundTrans , ` - Find toolbar: Mark All, `n    Find: previous, next (from query)  
	Gui,2: Add, Text, x10 y+1 BackgroundTrans , ` - Left click + mouse wheel: `n    scroll Page Up/Down
	
	;Gui,2: Add, Text, x10 y245 gRev_but , ` - Reverse: Shift+Ctrl+Alt+R
 	
return

; =====================================================

 
Find_toolbar:
	Gui,3:+owner1 
	Gui,3: +ToolWindow -border
	Gui,3: +hwndthis_id3
	InvertedColor = EDF0FF 
	Gui,3:+Delimiter`n 
	Gui,3:Color, 120F00 
	
    Gui,3:Font, S11 W700 , Tahoma
	Gui,3: Add, Text, x340 y4 w20 h20 cFFFFFF gFind_Close Center, X	
	
	;Gui,3:Font, S8 W400 , Segoe UI Semibold ;Verdana ; Tahoma
  Gui,3:Font, S8 W700 , Segoe UI
	Gui,3: Add, ComboBox, x70 y4 w140  vQuery_1 +hwndList_id ,  ; Search 
   fn := Func("List_Func_2").Bind(List_id)
    GuiControl, +g, % List_id,  % fn	
    
	Gui,3: Font, S7 W700 , Tahoma ;   Verdana
	Gui,3: Add, Text , x224 y9  cFFFFFF gFind  , Find  ;w40 h24
	; Gui,3: Font, S12 W700 ,  Verdana
	
	Gui,3: Add, Text, x290 y9  cFFFFFF gFind_Next , Next  
	
	Gui,3: Font, S7 W700 , Segoe UI ;Tahoma 
	Gui,3: Add, Text, x258 y8  cFFFFFF gFind_Prev , Prev
	Gui,3:Font, S7 W700 Q5
	Gui,3: Add, Text , x0 y7 w70 cFFFFFF  vFindFromPos Center, 

	;Gui,3: Add, GroupBox,  x216 y4 w40 h20   
	;Gui,3: Add, GroupBox,  x268 y4 w40 h20  
	
	Gui,3: Add, Text, x334 y8 cFFFFFF vtextFind_All gsearchMarkAll  , All  	

	Gui,3: Font, S8
	Gui,3: Add, Checkbox, x370 y8 w13 h13 vFind_Regex ;Checked
	Gui,3: Font, S7
	Gui,3: Add, Text, x+8  cCCCCCC vtextFind_Regex gFind_RegexSwitch, RegEx 
  
	 
	
	t_pos:=toolbar_pos()
	; f_x1:= t_pos[1]
	f_y1 := t_pos[2]
	f_w := t_pos[3]
  Gui,3:Show, Hide
	;Gui,3:Show,  y%f_y1%  w494 h30  , Find toolbar RE - Drozd  
	;Gui,3:Show,  y%f_y1%  w%f_w% h30  , Find toolbar RE - Drozd
	
	; WinSet, Transparent, 200,  % "ahk_id " this_id3 ;Find toolbar RE - Drozd  	

  
  Gosub, Combo_WinEvent
return


Find_toolbar_show:
	t_pos:=toolbar_pos()
	f_x1:= t_pos[1]
	f_y1:= t_pos[2]
	f_w:= t_pos[3]
		Gui,3:Show, x%f_x1% y%f_y1%  w%f_w% h30  , Find toolbar RE - Drozd 
		;WinSet, Transparent, 200,  Find toolbar RE - Drozd 	  
		WinSet, Transparent, 200,  % "ahk_id " this_id3 
  queries:=""
  IniRead, read_, %settings_ini%, Search, query  ;saveQueries
  if(read_!="ERROR" && read_!=""){
   queries:= RegExReplace(read_,"im),","`n")
  }	
	
  GuiControl, 3:, Query_1, `n%queries%   
return


Find_RegexSwitch:
GuiControlGet, Find_Regex , 3: , Find_Regex	
GuiControl,3: ,Find_Regex , % !Find_Regex
return


;==========================================


AHK_NOTIFYICON(wParam, lParam){
    if (lParam = 0x202) {       ; WM_LBUTTONUP
		Gui, 1:Show  
    }else if (lParam = 0x203){   ; WM_LBUTTONDBLCLK
		Gui, 1: Show
	}
}


WM_KEYUP(){
	global Curr_Index, TabName
/* 	Loop %numOfNotes%  {
		if (TabName=n%A_Index%) {
			Curr_Index=%A_Index%
		}			
	}
	 */
	Gosub, Number_of_letters
	Gosub, Number_of_words
}


; =====================================================

help_pos(){
	WinGetPos, x, y, Width, Height, Quick Notes RE - Drozd
	x1 := x + Width
	y1 :=  y    
	return, object( 1, x1, 2, y1)
}

toolbar_pos(){
	WinGetPos, x, y, Width, Height, Quick Notes RE - Drozd
	f_x1 := x+5
	f_y1 :=  y + Height -40   
	f_w := (Width-16)
	return, object( 1, f_x1, 2, f_y1, 3 ,f_w )
}

WM_MOVE(){
   WinGetPos, x1,y1,w1,h1, Quick Notes RE - Drozd
   ;WinGetPos, x2,y2,w2,h2, Find toolbar RE - Drozd  
   if(A_Gui==1){
	  x := x1+5 
	  y :=  y1 + h1 -40   
	  w := (w1-10)
	  ; y :=  y1 + 50  ; top
		WinMove, Find toolbar RE - Drozd  ,, x, y, w	
		;WinMove, % "ahk_id " this_id3 ,, x, y, w	
	  WinMove, Help_popup RE - Drozd  ,,% x1+ w1, y1, 
   }
}

WM_KEYDOWN(wParam, lParam){
    if (A_Gui = 3 && wParam = 13){ ; VK_ENTER := 13
		Gosub, Find
    ;}else if (A_Gui=3 && wParam != 13 && wParam != 114) {
		; SendMessage, 0x00B1, %pos1%, %pos1%, Edit%Curr_Index% , Quick Notes RE - Drozd ; remove selection
	}	
}

~LButton::
	MouseGetPos,,, Win_id,control	
	if(Win_id != this_id2){  
		Gui, 2: Destroy
	}
return



WM_LBUTTONDOWN(){
	global this_id1
	if(A_Gui=1){
		PostMessage, 0xA1, 2    ; movable borderless window 
	}
	
	if(RE[Curr_Index].searchModif==1){
		MouseGetPos,,, Win_id, ctrlHWND, 3 ; hwnd		
		if(ctrlHWND==RE[Curr_Index].HWND)
			RE[Curr_Index].searchBkup_restore()
	}	
}


WM_LBUTTONDBLCLK(){
	if(A_Gui=1){
   if(OpenContexMenuOnDblClick!=1)
      return
		MouseGetPos,,, Win_id,control
		if InStr(control,"RICHEDIT50W")
			SetTimer, ContextMenuShow,-150 
	}else if(A_Gui=4){
		if RegExMatch(A_GuiControl,"i)Font(?!Size|Name|Big)|col|High"){
			GuiControlGet, col_,4: , %A_GuiControl%
      col := RichEditDlgs.ChooseColor(RE[1], "0x" col_)
      if(col!="Cancel"){
         col:=Format("{1:X}",col),col:=SubStr("000000" . col, -5) ; to 6 characters
         GuiControl,4:, %A_GuiControl% , %col%
      }
      WinActivate, Quick Notes Settings RE - Drozd
		}
	}
}

;==========================
;DisableWindowsFeature

OnStaticDoubleClick(W, L, M, H) { ; prevent copy to  clipboard when double clicked ; by just me autohotkey.com/boards/viewtopic.php?t=3569
   Static Dummy1 := OnMessage(0x00A2, "OnStaticDoubleClick") ; WM_NCLBUTTONUP
   Static Dummy2 := OnMessage(0x00A3, "OnStaticDoubleClick") ; WM_NCLBUTTONDBLCLK
   Static Dummy3 := OnMessage(0x0202, "OnStaticDoubleClick") ; WM_LBUTTONUP
   Static Dummy4 := OnMessage(0x0203, "OnStaticDoubleClick") ; WM_LBUTTONDBLCLK
   Static LBtnDblClicks := {0x00A3: 0x00A1, 0x0203: 0x0201}
   Global StaticDoubleClick := False

   If (A_GuiControl) && LBtnDblClicks.Haskey(M) {
      GuiControlGet, HCTRL, Hwnd, %A_GuiControl%
      WinGetClass, Class, ahk_id %HCTRL%
      If (Class = "Static") {
         StaticDoubleClick := True
         PostMessage, % LBtnDblClicks[M], %W%, %L%, , ahk_id %HCTRL%
         Return 0
      }else if(Class = "RICHEDIT50W"){
				StaticDoubleClick := True
				;PostMessage, % LBtnDblClicks[M] , %W%, %L%, ,  % "ahk_id " . RE[Curr_Index].HWND 				
				PostMessage, 0x0203, %W%, %L%, ,  % "ahk_id " . RE[Curr_Index].HWND ; WM_LBUTTONDBLCLK		
         if(OpenContexMenuOnDblClick==1){
					MouseGetPos,,, Win_id,control
					if(InStr(A_GuiControl,"Note") || InStr(control,"RICHEDIT50W"))
						SetTimer, ContextMenuShow,-150 		
         }
				return 0
			}
   }
}


;==========================

Change:
Gui, Submit, NoHide	
	 	Loop %numOfNotes%  {
		if (TabName=n%A_Index%) {
			Curr_Index=%A_Index%
			}	
		}
	Gosub, Number_of_letters
	Gosub, Number_of_words
return

getCurr_Index:
	 	Loop %numOfNotes%  {
		if (TabName=n%A_Index%) {
			Curr_Index=%A_Index%
			}	
		}
return

;====================
#IfWinActive, Quick Notes RE - Drozd
;~^h:: Gosub, Replace_RE  ; RichEditDlgs.ReplaceText() not fully working - no find next
~+^f:: Gosub, Find_RE 
#IfWinActive

Find_RE: 
	WinClose, % "ahk_id " ReplaceTextHWND
	if(!WinExist("ahk_id " FindTextHWND))
	FindTextHWND:=RichEditDlgs.FindText(RE[Curr_Index])
   ControlFocus, Edit1, % "ahk_id " this_id3
	;ControlFocus, Edit1, Find toolbar RE - Drozd
Return

Replace_RE:
	WinClose, % "ahk_id " FindTextHWND
	if(!WinExist("ahk_id " ReplaceTextHWND))
	ReplaceTextHWND:=RichEditDlgs.ReplaceText(RE[Curr_Index])
Return

#IfWinActive, Quick Notes RE - Drozd
~$F3:: Gosub, Find_Next_2
~+$F3:: Gosub, Find_Prev_2
#IfWinActive

Find_Next:
	Gosub, Find_Next_Regex
	;Gosub, Find_Next_1
return

Find_Prev: 
	Gosub, Find_Prev_Regex
	;Gosub, Find_Prev_1
return

Find_Next_2:
	if !WinActive("Quick Notes RE - Drozd") && !WinActive("Find toolbar RE - Drozd")
		return
	Gosub, getCurr_Index
	selText:=RE[Curr_Index].GetSelText()
	if(RegExMatch(selText,"^\s*$")){
		not_found_indic()
			return
	}	
	if(selText!=QueryMark)
		searchMarkAll_reset(Curr_Index)
	selText:=Trim(selText) ;, z:=",|;|:|-|\." , selText:=RegExReplace(selText, "^" z "|" z "$" , "")
	RE[Curr_Index].FindText(selText, ["Down"])
	;ControlFocus,, % "ahk_id " RE[Curr_Index].HWND

	sel:=RE[Curr_Index].GetSel()			
	lastFind_:=show_num_finds(selText,Curr_Index,sel["S"])
	if(lastFind_==1){
			not_found_indic()
		return
	}
	
 	SendMessage,0x00B7, 0, 0,  , % "ahk_id " RE[Curr_Index].HWND ;    EM_SCROLLCARET  Scroll caret into view	
	SendMessage, 0x00B6, 0, 5,  ,  % "ahk_id " RE[Curr_Index].HWND  ; EM_LINESCROLL=0x00B6 ;down 5 lines

return

Find_Prev_2:
	if !WinActive("Quick Notes RE - Drozd") && !WinActive("Find toolbar RE - Drozd")
		return
	Gosub, getCurr_Index
	selText:=RE[Curr_Index].GetSelText()
	if(RegExMatch(selText,"^\s*$")){
		not_found_indic()
			return
	}	
	if(selText!=QueryMark)
		searchMarkAll_reset(Curr_Index)
	selText:=Trim(selText) ;, z:=",|;|:|-|\." , selText:=RegExReplace(selText, "^" z "|" z "$" , "")
	;add_to_ComboBox_find("ComboBox1",selText, maxComboItems, true)
	RE[Curr_Index].FindText(selText, ["UP"]) 
	;ControlFocus,, % "ahk_id " RE[Curr_Index].HWND

	sel:=RE[Curr_Index].GetSel()			
	lastFind_:=show_num_finds(selText,Curr_Index,sel["S"])
	
	if(lastFind_==2){ ;first
		not_found_indic()
		return
	}
	
 	SendMessage,0x00B7, 0, 0,  , % "ahk_id " RE[Curr_Index].HWND ;    EM_SCROLLCARET  Scroll caret into view 	
	SendMessage, 0x00B6, 0, -5,  ,  % "ahk_id " RE[Curr_Index].HWND  ; EM_LINESCROLL=0x00B6 ;up 8 lines
return


Find_Next_1:
	Gosub, getCurr_Index
	;sel:=RE[Curr_Index].GetSelText()
	GuiControlGet, Query , 3: , Query_1	
	if(RegExMatch(Query,"^\s*$")){
		not_found_indic()
			return
	}	
	if(Query!=QueryMark)
	searchMarkAll_reset(Curr_Index)
	if(lastFind_==1)
		RE[Curr_Index].SetSel(0,0)
	;sel:=Trim(sel), z:=",|;|:|-|\." , Sel:=RegExReplace(Sel, "^" z "|" z "$" , "")
	RE[Curr_Index].FindText_2(Query, ["Down"])
	ControlFocus,, % "ahk_id " RE[Curr_Index].HWND

	sel:=RE[Curr_Index].GetSel()			
	lastFind_:=show_num_finds(Query,Curr_Index,sel["S"])
/* 	if(lastFind_==1){			
		not_found_indic()
		return
	}
	 */
	 
   scroll_find(RE[Curr_Index].HWND)
   ;SendMessage, 0x00B6, 0, 5,  ,  % "ahk_id " RE[Curr_Index].HWND  ; EM_LINESCROLL=0x00B6 ;down 5 lines
return

Find_Prev_1:	
	Gosub, getCurr_Index
	GuiControlGet, Query , 3: , Query_1
	if(RegExMatch(Query,"^\s*$")){
		not_found_indic()
			return
	}	
	if(Query!=QueryMark)
		searchMarkAll_reset(Curr_Index)

	if(lastFind_==2)
		RE[Curr_Index].SetSel(-1,-1)
	add_to_ComboBox_find("ComboBox1",Query, maxComboItems, true)
	RE[Curr_Index].FindText_2(Query, ["UP"]) 
	ControlFocus,, % "ahk_id " RE[Curr_Index].HWND

	sel:=RE[Curr_Index].GetSel()			
	lastFind_:=show_num_finds(Query,Curr_Index,sel["S"])
/* 	if(lastFind_==2){ ;first
		not_found_indic()
		return
	}	
	 */

   scroll_find(RE[Curr_Index].HWND)
	SendMessage,0x00B7, 0, 0,  , % "ahk_id " RE[Curr_Index].HWND ;    EM_SCROLLCARET  Scroll caret into view	
return


get_caret_pos:
	Loop 9 {
		if(TabName=n%A_Index%)
			Curr_Index=%A_Index%			
	}
	;get caret position , next find position on click
		VarSetCapacity(Pos1, 4, 0), VarSetCapacity(Pos2, 4, 0)
		SendMessage, 0x00B0, &Pos1, &Pos2,, % "ahk_id " RE[Curr_Index].HWND	; EM_GETSEL=0x00B0 
		Pos1 := NumGet(Pos1), 	Pos2 :=	NumGet(Pos2)	
		caret_pos:=Pos1
		caret_pos2:=Pos2
		pos:=Pos2
return


scroll_find(hwnd, num:=10){ ; set selection of found matches in the middle of control (10 lines from top)
  ControlGet, Line_Count, LineCount,,, % "ahk_id " hwnd	
	VarSetCapacity(Pos1, 4, 0), VarSetCapacity(Pos2, 4, 0)
	SendMessage, 0x00B0, &Pos1, &Pos2,,  % "ahk_id " hwnd 	; EM_GETSEL=0x00B0 
	Pos1 := NumGet(Pos1), Pos2 :=	NumGet(Pos2)
	SendMessage,0x00C9, Pos1 ,0 , ,  % "ahk_id " hwnd  ;EM_LINEFROMCHAR
	SelLineNum:=ErrorLevel+1
	SendMessage, 0x00CE, 0,0 , ,  % "ahk_id " hwnd ;M_GETFIRSTVISIBLELINE
	firstVisLineNum:=ErrorLevel+1
	scrolNum:=SelLineNum - firstVisLineNum
	scrolNum2:=(scrolNum<num) ?  -(num-scrolNum) : scrolNum-num
	SendMessage, 0x00B6, 0, %scrolNum2% ,  , % "ahk_id " hwnd  ; EM_LINESCROLL   
}


Find_Next_Regex:
	Gosub, getCurr_Index
	;sel:=RE[Curr_Index].GetSelText()
	GuiControlGet, Query , 3: , Query_1	
	GuiControlGet, Find_Regex , 3: , Find_Regex	
	
	if(RegExMatch(Query,"^\s*$")){
		not_found_indic()
			return
	}	

	;sel:=Trim(sel), z:=",|;|:|-|\." , Sel:=RegExReplace(Sel, "^" z "|" z "$" , "")
	Gosub, get_caret_pos
		
   Query_ := (Find_Regex=1) ? Query : "\Q" RegExReplace(Query,"i)\\Q|\\E","") "\E"
   add_to_ComboBox_find("ComboBox1",Query, maxComboItems, true)   
 	
	if(Query_!=QueryMark)
		searchMarkAll_reset(Curr_Index)
	
	Note_searched:=RE[Curr_Index].GetText()	
	
	Array:=Object()		
	pos_ := 1
		While pos_ {
			pos_:=RegExMatch(Note_searched, "im)" Query_, Output, pos_)
			if(pos_!=0){
				Array.Push(pos_-1)
			}
			pos_:=pos_+StrLen(Output)
      if (StrLen(Output)==0) ; empty break
				break
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
		
		show_num_finds_Regex(len,ind)	

		pos1:=RegExMatch(Note_searched,"im)" Query_, Output, from )-1
		pos2:=pos1 + StrLen(Output)		
		pos:= pos2
		caret_pos2:=pos2

		if(pos1<0){
			GuiControl,3:, FindFromPos, % Chr(10006)  ;  ✖  
			Gui,3:Font, s8 w700 cDD0000  
			GuiControl,3:Font, FindFromPos
			GuiControl,3: Show , FindFromPos
			SetTimer, hide_FindFromPos, 500
			return
		}
		
/* 	
			VarSetCapacity(sel_, 8, 0)
      NumPut(pos1,sel_, 0, "Int")
      NumPut(pos2,sel_, 4, "Int")
      SendMessage, 0x0437, 0, &sel_, , % "ahk_id " RE[Curr_Index].HWND  ; EM_EXSETSEL = 0x0437
			 */
			 

		;SendMessage, 0x00B1, %pos1%, %pos2%, RICHEDIT50W%Curr_Index% , Quick Notes RE - Drozd ; EM_SETSEL
		SendMessage, 0x00B1, %pos1%, %pos2%,  , % "ahk_id " RE[Curr_Index].HWND ; EM_SETSEL
		scroll_find(RE[Curr_Index].HWND)
	;	SendMessage,0x00B7, 0, 0,  , % "ahk_id " RE[Curr_Index].HWND  ;    EM_SCROLLCARET  Scroll caret into view
return

Find_Prev_Regex:	
	Gosub, getCurr_Index
	;sel:=RE[Curr_Index].GetSelText()
	GuiControlGet, Query , 3: , Query_1	
	GuiControlGet, Find_Regex , 3: , Find_Regex	
	
	if(RegExMatch(Query,"^\s*$")){
		not_found_indic()
			return
	}	

	;sel:=Trim(sel), z:=",|;|:|-|\." , Sel:=RegExReplace(Sel, "^" z "|" z "$" , "")
	Gosub, get_caret_pos
   Query_ := (Find_Regex=1) ? Query : "\Q" RegExReplace(Query,"i)\\Q|\\E","") "\E"
   add_to_ComboBox_find("ComboBox1",Query, maxComboItems, true)   
 	
	if(Query_!=QueryMark)
		searchMarkAll_reset(Curr_Index)
    
	Note_searched:=RE[Curr_Index].GetText()
	
		Array:=Object()		
		pos_ := 1

		While pos_ {
			pos_:=RegExMatch(Note_searched, "im)" Query_, Output, pos_)
			if(pos_!=0){
				Array.Push(pos_)
			}
			pos_:=pos_+StrLen(Output)
      if (StrLen(Output)==0) ; empty break
				break
		}
		len:=Array.Length()

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
		
		show_num_finds_Regex(len,ind)
		
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
		
/* 	
			VarSetCapacity(sel_, 8, 0)
      NumPut(pos1,sel_, 0, "Int")
      NumPut(pos2,sel_, 4, "Int")
      SendMessage, 0x0437, 0, &sel_, , % "ahk_id " RE[Curr_Index].HWND  ; EM_EXSETSEL = 0x0437
			 */
			 

		;SendMessage, 0x00B1, %pos1%, %pos2%, RICHEDIT50W%Curr_Index% , Quick Notes RE - Drozd ; EM_SETSEL
		SendMessage, 0x00B1, %pos1%, %pos2%,  , % "ahk_id " RE[Curr_Index].HWND ; EM_SETSEL
		scroll_find(RE[Curr_Index].HWND)

return



~^f:: Gosub, StartFind

StartFind:
	If !WinActive("Quick Notes RE - Drozd")
		return
	Gosub, Find_toolbar_show
		Gosub, getCurr_Index
		lastFind_:=0
		selText:=RE[Curr_Index].GetSelText()
		;if(!RegExMatch(selText,"^\s*$") && Find_from_sel=1){
			selText:=Trim(selText), z:=",|;|:|-|\." , selText:=RegExReplace(selText, "^" z "|" z "$" , "")
			add_to_ComboBox_find("ComboBox1",selText, maxComboItems, true)
		;}
		;RE[Curr_Index].SetSel(0, 0) ; start from begining	
	;Gosub Find		 
return

Find:
   ;Gosub,Find_toolbar_show
   Gui,3: Submit, Nohide
   Gosub, getCurr_Index
   searchMarkAll_reset(Curr_Index)
   GuiControlGet, Query , 3: , Query_1	
   GuiControlGet, Find_Regex , 3: , Find_Regex	
   if(Find_Regex){
      MsgBox,4096,, %  "Regex option works only with 'Find next' , 'Find previous' and 'All'" "`n" "Turn Regex off and try again", 10
      return
   }
   
		if(lastFind_==1)
			RE[Curr_Index].SetSel(0,0)
		
		selText:=RE[Curr_Index].GetSelText()
		sel:=RE[Curr_Index].GetSel()

/* 		if(SelText && Find_from_sel=1){
 			if(RegExMatch(selText,"^\s*$")){
				not_found_indic()
				return
			}	
      
			;SelText:=Trim(SelText), z:=",|;|:|-|\." , SelText:=RegExReplace(SelText, "^" z "|" z "$" , "")
			add_to_ComboBox_find("ComboBox1",SelText, maxComboItems, true)
			;RE[Curr_Index].FindText_2(SelText, ["Down"])
			RE[Curr_Index].FindText(SelText, ["Down"])
			sel:=RE[Curr_Index].GetSel()			
			lastFind_:=show_num_finds(SelText,Curr_Index,sel["S"])
       
		}else{
			if(RegExMatch(Query,"^\s*$")){
				not_found_indic()
				return
			}	
			add_to_ComboBox_find("ComboBox1",Query, maxComboItems, true)
			RE[Curr_Index].SetSel(0, 0) ; start from begining			
			;RE[Curr_Index].FindText_2(Query, ["Down"])
			RE[Curr_Index].FindText(Query, ["Down"])
			sel:=RE[Curr_Index].GetSel()	
			lastFind_:=show_num_finds(Query,Curr_Index,sel["S"])
		}  
    */

			if(RegExMatch(Query,"^\s*$")){
				not_found_indic()
				return
			}	
			add_to_ComboBox_find("ComboBox1",Query, maxComboItems, true)
			;RE[Curr_Index].SetSel(0, 0) ; start from begining			
			;RE[Curr_Index].FindText_2(Query, ["Down"])
			err:=RE[Curr_Index].FindText(Query, ["Down"])
			sel:=RE[Curr_Index].GetSel()	
			lastFind_:=show_num_finds(Query,Curr_Index,sel["S"])
  
      ControlFocus,, % "ahk_id " RE[Curr_Index].HWND
      scroll_find(RE[Curr_Index].HWND)
      
/* 		if(lastFind_==1){    
      Gosub, hide_FindFromPos
      SetTimer, hide_FindFromPos, Off 	
      GuiControl,3:, FindFromPos, last 
      GuiControl,3: Show , FindFromPos
      SetTimer, hide_FindFromPos, 2000 
			return
		}	 
    */
		    if (err==0)
         not_found_indic()
   
   ;SendMessage,0x00B7, 0, 0,  , % "ahk_id " RE[Curr_Index].HWND ;    EM_SCROLLCARET  Scroll caret into view		
   ;Query := RegExReplace(Query, "^\s*([\s\S]*?)\s*$", "$1")		
return

	
	
searchMarkAll:
	Gosub, getCurr_Index
	searchMarkAll_reset(Curr_Index)
  ModBefSearch:= (RE[Curr_Index].IsModified()==-1) ? 1 : 0
	RE[Curr_Index].ModBefSearch:=ModBefSearch 
	SendMessage, 0x00CE, 0,0 , ,  % "ahk_id " RE[Curr_Index].HWND ;M_GETFIRSTVISIBLELINE
      firstVisLineNum:=ErrorLevel
      
	GuiControlGet, Query , 3: , Query_1
  GuiControlGet, Find_Regex , 3: , Find_Regex	
	QueryMark:=Query
	add_to_ComboBox_find("ComboBox1",QueryMark, maxComboItems, true)
	Sel_ := RE[Curr_Index].GetSel()
  
	RE[Curr_Index].searchBkup:=RE[Curr_Index].GetRTF()
	RE[Curr_Index].searchModif:=1
	RE[Curr_Index].SetSel(0, 0) ; start from begining
		;searchMarkAllColor:=0x81BAF2 ;0x3399FF ;blue
    ;searchMarkAllColor:=0xA3F6A7 ;0x70EC9E   ;green	 ;0x81BAF2 ;0x3399FF ;blue
	QueryMark := (Find_Regex=1) ? QueryMark : "\Q" RegExReplace(QueryMark,"i)\\Q|\\E","") "\E"
	Note_searched:=RE[Curr_Index].GetText()	

	Array:=Object()		
	pos_ := 1
		While pos_ {
			pos_:=RegExMatch(Note_searched, "im)" QueryMark, Output, pos_)
			if(pos_!=0){
				Array.Push(pos_-1)
			}
			pos1:=pos_-1
			pos2:=pos1 + StrLen(Output)
			pos_:=pos_+StrLen(Output)
      if (StrLen(Output)==0) ; empty break
				break
      if(pos1!=-1 || pos2!=-1 ){   
         SendMessage, 0x00B1, %pos1%, %pos2%,  , % "ahk_id " RE[Curr_Index].HWND ; EM_SETSEL
         RE[Curr_Index].SetFont({BkColor: searchMarkAllColor})		
         RE[Curr_Index].SetFont({Color: searchMarkAllfont})
      }
		}
   scroll_find(RE[Curr_Index].HWND, 15)
   len:=Array.Length()	

		num:=len
		lastFind_:=1
		
		Gosub, hide_FindFromPos
		SetTimer, hide_FindFromPos, Off 
	
		GuiControl,3:, FindFromPos, %num% 
		GuiControl,3: Show , FindFromPos
		SetTimer, hide_FindFromPos, 8000 
		
   ControlFocus,, % "ahk_id " RE[Curr_Index].HWND
   SendMessage, 0x115, 6, 0, , % "ahk_id " . RE[Curr_Index].HWND  ;WM_VSCROLL  scroll to top
   SendMessage, 0x00B6, 0, %firstVisLineNum% ,  , % "ahk_id " RE[Curr_Index].HWND  ; EM_LINESCROLL
return


/* searchMarkAll0:
	Gosub, getCurr_Index
	searchMarkAll_reset(Curr_Index)
	GuiControlGet, Query , 3: , Query_1
	QueryMark:=Query
	add_to_ComboBox_find("ComboBox1",QueryMark, maxComboItems, true)
	Sel_ := RE[Curr_Index].GetSel()
		
	RE[Curr_Index].searchBkup:=RE[Curr_Index].GetRTF()
	RE[Curr_Index].searchModif:=1
	RE[Curr_Index].SetSel(0, 0) ; start from begining
	err:=1
		;NC:=0x81BAF2 ;0x3399FF ;blue
		NC:=0xA3F6A7 ;0x70EC9E   ;green	
	num:=-1
		while err!=0 {
			err:=RE[Curr_Index].FindText(QueryMark,["Down"])
			RE[Curr_Index].SetFont({BkColor: NC})		
			num++	
		}	
	lastFind_:=1
		
		Gosub, hide_FindFromPos
		SetTimer, hide_FindFromPos, Off 
	
		GuiControl,3:, FindFromPos, %num% 
		GuiControl,3: Show , FindFromPos
		SetTimer, hide_FindFromPos, 8000 
	ControlFocus,, % "ahk_id " RE[Curr_Index].HWND
	;RE[Curr_Index].SetSel(Sel_["S"],Sel_["E"])
return
 */
 
 
searchMarkAll_reset(which:="All"){
	if(which=="All"){
		Loop, %numOfNotes%  {
			if(RE[A_Index].searchModif==1){
					RE[A_Index].searchBkup_restore()
			}
		}
	}else{
			if(RE[which].searchModif==1)
					RE[which].searchBkup_restore()
	}
	
}

;====================

show_num_finds(Query_,Curr_Index,sel:=""){
		Note_searched:=RE[Curr_Index].GetText()
		Array:=Object()
		pos_ := 1 
		While pos_ {
			pos_:=RegExMatch(Note_searched, "im)" Query_, Output,pos_)
			if(pos_!=0){
				Array.Push(pos_)
			}		
      pos_:=pos_+StrLen(Output)	
			if (StrLen(Output)==0) ; empty break
				break      
		}
		len:=Array.Length()

		ind:=""
		Loop % len {
			if(sel == Array[A_Index]-1){		
				ind:=A_Index
				break
			}
		}
		x:= len " [" ind "]"

		Gosub, hide_FindFromPos
		SetTimer, hide_FindFromPos, Off 
	
		GuiControl,3:, FindFromPos, %x% 
		GuiControl,3: Show , FindFromPos
		SetTimer, hide_FindFromPos, 8000 
		if(ind=len){
			return 1 ; last
		}else if(ind=1){
			return 2 ; first
		}else{
			return 0
		}
}		

 
not_found_indic(){
	GuiControl,3:, FindFromPos, % Chr(10006)  ;  ✖  
	Gui,3:Font, s8 w700 cDD0000  
	GuiControl,3:Font, FindFromPos
	GuiControl,3: Show , FindFromPos
	SetTimer, hide_FindFromPos, 500
}

show_num_finds_Regex(num,ind:=""){
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

add_to_ComboBox_find(box,new_val,max,add_to_list:=false){
   if(new_val="")
		return
	;ControlGet,list_, List, ,%box%, % "ahk_id " this_id3 
	ControlGet,list_, List, ,%box%, Find toolbar RE - Drozd
	list_array:=StrSplit(list_,"`n")
  if(list_array.Length()>max){
    Control, Delete, % list_array.Length(), %box% , Find toolbar RE - Drozd
		}

if(!array_contains(list_array, new_val)){
		;ControlGet,list_, List, ,%box%, % "ahk_id " this_id3
		ControlGet, list_, List, ,%box%, Find toolbar RE - Drozd
		new_box:= "`n" new_val "`n" list_ 
    ;new_box:= new_val ? "`n" new_val "`n" list_ : "`n" list_			
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


Find_Close:
  Gosub, saveQueries
	searchMarkAll_reset("All")
	Gui,3: Hide
return

;=======================


Show_Notes:
	Gui, 1:Show
return


Save:
	Gui, Submit, NoHide
	
		Loop %numOfNotes%  {
				if (TabName=n%A_Index%){		
					searchMarkAll_reset(Curr_Index)
					FilePath:=folder_path "note" A_Index ".rtf"
					RE[A_Index].SaveFile(FilePath)
					RE[A_Index].SetModified() 

					if(saveBckupTxt==1){
						FilePath_bckup:=folder_path "note" A_Index ".txt"		
						text_:=RE[A_Index].GetText()
						FileObj := FileOpen(FilePath_bckup, "rw")
						FileObj.Encoding:="UTF-8" 						
							FileObj.Write(text_)
							FileObj.Close()
					}
					;SendMessage, 0xB9, % 0, 0, , % "ahk_id " . RE[A_Index].HWND ; Modified false
					Break
				}	
			}
	Gosub, Rec
Return


Load:
	Gui, Submit, NoHide

	Loop %numOfNotes%  {
		if (TabName=n%A_Index%) {
      SendMessage, 0x00CE, 0,0 , ,  % "ahk_id " RE[A_Index].HWND ;M_GETFIRSTVISIBLELINE
      firstVisLineNum:=ErrorLevel
			FilePath:=folder_path "note" A_Index ".rtf"
			RE[A_Index].LoadFile(FilePath)
			RE[A_Index].SetModified() ; clear modification flag
      RE[A_Index].searchBkup:=""
			RE[A_Index].searchModif:=0
			;GuiControl, Focus, % RE[A_Index].HWND

      SendMessage, 0x00B6, 0, %firstVisLineNum% ,  , % "ahk_id " RE[A_Index].HWND  ; EM_LINESCROLL
			;SendMessage, 0x115, 7, 0, RICHEDIT50W%A_Index%, Quick Notes RE - Drozd             ; scroll to bottom
			Break
		}
	}
	Gosub, Get	
	Gosub, Number_of_letters
	Gosub, Number_of_words
return
		
Load_All:
	Gui, Submit, NoHide
	Loop %numOfNotes%  {
		FilePath:=folder_path "note" A_Index ".rtf"
		RE[A_Index].LoadFile(FilePath)
		RE[A_Index].SetModified() ; clear modification flag
		RE[A_Index].searchBkup:=""
		RE[A_Index].searchModif:=0
	}	

	Loop %numOfNotes%  {
		;if (A_Index != 5){
		SendMessage, 0x115, 7, 0, RICHEDIT50W%A_Index%, Quick Notes RE - Drozd             ; scroll to bottom
		SendMessage, 0x00B1, -1, -1 , RICHEDIT50W%A_Index% , Quick Notes RE - Drozd   ; EM_SETSEL
		;}
	}

return


Backup:
	Gui, Submit, NoHide
	if(saveBckupTxt!=1){
   MsgBox, 4096,, %  "Plain text backup disabled" "`n"  "      (saveBckupTxt=0)" , 5
   return
  }
  
	Loop %numOfNotes%  {
		if (TabName=n%A_Index%) {
			MsgBox, 0x00040103, , Do you want to load plain text from backup? `nAll rich text formatting will be removed.`n 
			;0x00040003 +100 "No" as default
					IfMsgBox, No
						return
					IfMsgBox Cancel
						return
			FilePath:=folder_path "note" A_Index ".txt"
			FileObj :=FileOpen(FilePath, "r", "UTF-8")					 
			text_ := FileObj.Read()
			RE[A_Index].SetText(text_)
			FileObj.Close()
			text_:=""
			 
      SendMessage, 0xB9, 1, 0, , % "ahk_id " . RE[A_Index].HWND ; EM_SETMODIFY = 0xB9
			;RE[A_Index].SetModified() ;  modification flag
			break
		}	
	}
	
	Gosub, Get
	Gosub,Number_of_letters
Return

Save_All_and_Exit:
	Gui, Submit, NoHide		
	searchMarkAll_reset("All")
	Loop %numOfNotes%  {			
    
		if(RE[A_Index].IsModified()){
			FilePath:=folder_path "note" A_Index ".rtf"
			RE[A_Index].SaveFile(FilePath)
			RE[A_Index].SetModified()

			if(saveBckupTxt==1){
					FilePath_bckup:=folder_path "note" A_Index ".txt"		
					text_:=RE[A_Index].GetText()
					FileObj := FileOpen(FilePath_bckup, "w")
					FileObj.Encoding:="UTF-8" ; "UTF-16"
					FileObj.Write(text_)
					FileObj.Close()
			}
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
	Run  %folder_path%  ; %A_WorkingDir%
Return


; =====================================================


/* Big:
	 if(ShowBig=0){
			ShowBig:=1
			CenterWindowSize("Quick Notes RE - Drozd",Width_B, Height_B )	
			GuiControl,3: Show, textFind_Regex			
		}else{
			ShowBig:=0			
			; WinMove, Quick Notes RE - Drozd, , 580,270 , 415, 360
			CenterWindowSize("Quick Notes RE - Drozd",415, 360 )
			GuiControl,3: Hide, textFind_Regex
		}
return
 */


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
			WinSet, AlwaysOnTop, on, Quick Notes RE - Drozd 
			GuiControl, Hide , onTop2
			GuiControl, Show , onTop1
		}else{
			WinSet, AlwaysOnTop, off, Quick Notes RE - Drozd 
			GuiControl, Hide , onTop1
			GuiControl, Show , onTop2
		}	
return

; =====================================================


Number_of_letters:
	if Number_of_lettersOn==0
		return
	Gui, Submit, NoHide
	if(!Curr_Index){
		Loop %numOfNotes%  {
			if(TabName=n%A_Index%)
				Curr_Index=%A_Index%	
		}
	}
	num :=RE[Curr_Index].GetTextLen()
/* 	;GuiControlGet,NOTE_actv, ,Note%Curr_Index%
	NOTE_actv:=RE[Curr_Index].GetText()
	num := StrLen(NOTE_actv)
	 */
	GuiControl,, RESULT, %num% 
return

 
Number_of_words:
	if Number_of_wordsOn==0
		return
	Gui, Submit, NoHide
	if(!Curr_Index){
		Loop %numOfNotes%  {
			if(TabName=n%A_Index%)
				Curr_Index=%A_Index%	
		}
	}
	;GuiControlGet,NOTE_actv, ,Note%Curr_Index%
		NOTE_actv:=RE[Curr_Index].GetText()
	RegExReplace(NOTE_actv, "\w+", "", Count ) ; 
	GuiControl,, RESULT2, %Count% 	
 return

; =====================================================

; =====================================================

Notes_settings:
Gui,4:+owner1 
Gui,4: +ToolWindow 
Gui,4:+hwndthis_id4
Gui,4:Add, Button , x140 y340 w60 h22  gSaveSet , Save
Gui,4:Add, Button , x240 y340 w60 h22  gCancel_but , Cancel
Gui,4:Add, Tab, x10 y10 w430 h320  , Notes Names|Rich Edit colors|Default

Gui,4: Tab, 1 
Gui,4: Font, S8  , Segoe UI Bold ;
Gui,4:Add, Text,  x110 y36   , Custom Names for Notes

Gui,4: Font, S8 W400 , Tahoma 
Gui,4:Add, Text, x20 y64   , Note1
Gui,4:Add, Edit, x+20 y60 w140 vSet_Note1 , Note1

Loop % 7 {
	ind:=A_Index+1
	Gui,4:Add, Text, x20  y+12  , Note%ind% ;%A_Index%
	Gui,4:Add, Edit, x+20 y+-17 w140 vSet_Note%ind% , Note%ind%
}

Gui,4:Add, Text, x230  y64  , Note9  ` ; sic
Gui,4:Add, Edit, x+20 y60 w140 vSet_Note9 , Note9

;len:=7 
len:=numOfNotes- 9

Loop % len {
	ind:= 9 + A_Index

	Gui,4:Add, Text, x230  y+12  , Note%ind% ;%A_Index%
	Gui,4:Add, Edit, x+20 y+-17 w140 vSet_Note%ind% , Note%ind%
}

;Gui,4:Add, Text, x100  y306  , Restart the program for new settings to take effect
Gui,4:Add, Text, x120  y300, Number of notes (<=16)
Gui,4:Add, Edit, x+20 y+-17 w40 vNumNotes, 

Gui,4: Tab,2
Gui,4: Font, S8  , Segoe UI Bold ;
Gui,4:Add, Text,  x110 y38 , Custom colors for context menu


Gui,4: Font, S8 W400 , Tahoma 
Gui,4: Add, GroupBox,  x20 y60 w180 h170  , Font colors 

Gui,4:Add, Text, x40 y90  , Red
Gui,4:Add, Edit, x100 y+-17 w60 vFontRed  , ;DD0000
Gui,4:Add, Text, x40 y+10  , Blue
Gui,4:Add, Edit, x100 y+-17 w60 h20 vFontBlue , ;0000C5
Gui,4:Add, Text, x40 y+10  , Green
Gui,4:Add, Edit, x100 y+-17 w60 h20 vFontGreen , ;009700
Gui,4:Add, Text, x40 y+10  , Yellow
Gui,4:Add, Edit, x100 y+-17 w60 h20 vFontYellow , ;FFF300
Gui,4:Add, Text, x40 y+10  , Silver
Gui,4:Add, Edit, x100 y+-17 w60 h20 vFontSilver , ;C1C1C1

Gui,4: Add, GroupBox,  x220 y60 w180 h170  , Highlight colors 

Gui,4:Add, Text, x240 y90  , Yellow
Gui,4:Add, Edit, x300 y+-17 w60 vHighYellow  , ;FEFFB6
Gui,4:Add, Text, x240 y+10  , Red
Gui,4:Add, Edit, x300 y+-17 w60 h20 vHighRed , ;FFDADA
Gui,4:Add, Text, x240 y+10  , Beige
Gui,4:Add, Edit, x300 y+-17 w60 h20 vHighBeige , ;E7E2C4
Gui,4:Add, Text, x240 y+10  , Green
Gui,4:Add, Edit, x300 y+-17 w60 h20 vHighGreen , ;CDEED0
Gui,4:Add, Text, x240 y+10  , Blue
Gui,4:Add, Edit, x300 y+-17 w60 h20 vHighBlue  , ;81BAF2


Gui,4:Add, Text, x30 y250  , Text big bold size
Gui,4:Add, Edit, x130 y+-17 w60 vFontBig  , ;12

Gui,4: Tab, 3
Gui,4:Add, Text, x40 y270  , Open context menu on double-click 
Gui,4:Add, Checkbox, x240 y270 vContMenuOnDblClick  ,

Gui,4: Add, GroupBox,  x20 y60 w380 h170  , Font colors 

Gui,4:Add, Text, x40 y90  , Default font name 
Gui,4:Add, Edit, x200 y+-17 w130 vFontName  , 
Gui,4:Add, Text, x40 y+10  , Default font size 
Gui,4:Add, Edit, x200 y+-17 w130 h20  vFontSize, ;0000C5
Gui,4:Add, Text, x40 y+10  ,   Default  color
Gui,4:Add, Edit, x200 y+-17 w130 h20 vDefCol ,
Gui,4:Add, Text, x40 y+10  ,   Default background color
Gui,4:Add, Edit, x200 y+-17 w130 h20 vBgrCol ,

Gui,4:Show, w450 h370 , Quick Notes Settings RE - Drozd
Gosub, Load_Settings	

return


Load_Settings:
	;IniRead, Find_from_sel, %settings_ini%, Misc, Search Option
;	GuiControl,4:, Search_Op , %Find_from_sel%
   
   IniRead, read_, %settings_ini%, Misc, Number of notes
   GuiControl,4:, NumNotes , %read_%
   
	Loop, %numOfNotes%  {		 
		IniRead, n%A_Index%, %settings_ini%, Note%A_Index%, Name
      if(n%A_Index%=="ERROR")
          n%A_Index%:="Note" A_Index    
    GuiControl,4:, Set_Note%A_Index% , % n%A_Index% 
	}
  
	IniRead, read_, %settings_ini%, Font colors, Red
	GuiControl,4:, FontRed , %read_%
	IniRead, read_, %settings_ini%, Font colors, Green
	GuiControl,4:, FontGreen , %read_%
	IniRead, read_, %settings_ini%, Font colors, Blue
	GuiControl,4:, FontBlue , %read_%
	IniRead, read_, %settings_ini%, Font colors, Yellow
	GuiControl,4:, FontYellow , %read_%
	IniRead, read_, %settings_ini%, Font colors, Silver 
	GuiControl,4:, FontSilver , %read_%
	
	
	IniRead, read_ , %settings_ini%, Highlight colors , Yellow
	GuiControl,4:, HighYellow , %read_%
	IniRead, read_ , %settings_ini%, Highlight colors , Red
	GuiControl,4:, HighRed , %read_%
	IniRead, read_ , %settings_ini%, Highlight colors , Beige
	GuiControl,4:, HighBeige , %read_%
	IniRead, read_ , %settings_ini%, Highlight colors , Green
	GuiControl,4:, HighGreen , %read_%
	IniRead, read_ , %settings_ini%, Highlight colors , Blue
	GuiControl,4:, HighBlue , %read_%
	
	IniRead, read_ , %settings_ini%, Text big bold, size
	GuiControl,4:, FontBig , %read_%
 
	IniRead, read_3 , %settings_ini%, Misc, Context menu on double-click 
	GuiControl,4:, ContMenuOnDblClick , %read_3%	

	IniRead, DefaultFontName, %settings_ini%, Misc, Default font name  
	GuiControl,4:, FontName , %DefaultFontName%
	IniRead, DefaultFontSize, %settings_ini%, Misc, Default font size  
	GuiControl,4:, FontSize , %DefaultFontSize%
	IniRead, DefaultBackgroundColor, %settings_ini%, Misc, Default background color
	GuiControl,4:, BgrCol , %DefaultBackgroundColor%
	IniRead, DefaultFontColor, %settings_ini%, Misc, Default font color
	GuiControl,4:, DefCol , %DefaultFontColor%  

return


SaveSet:
		Gui,4: Submit, Nohide
	   ;IniRead, Find_from_sel, %settings_ini%, Misc, Search Option
		;IniWrite, %Search_Op%, %settings_ini%, Misc, Search Option
		
		Loop, %numOfNotes%  {		 
			IniWrite, % Set_Note%A_Index%, %settings_ini%, Note%A_Index%, Name
		}

	IniWrite, %FontRed%, %settings_ini%, Font colors, Red
	IniWrite, %FontGreen%, %settings_ini%, Font colors, Green
	IniWrite, %FontBlue%, %settings_ini%, Font colors, Blue
	IniWrite, %FontYellow%, %settings_ini%, Font colors, Yellow
	IniWrite, %FontSilver%, %settings_ini%, Font colors, Silver 
	
	IniWrite, %HighYellow%, %settings_ini%, Highlight colors, Yellow
	IniWrite, %HighRed%, %settings_ini%, Highlight colors, Red 
	IniWrite, %HighBeige%, %settings_ini%, Highlight colors, Beige 
	IniWrite, %HighGreen%, %settings_ini%, Highlight colors, Green
	IniWrite, %HighBlue%, %settings_ini%, Highlight colors, Blue

	IniWrite, %FontBig%, %settings_ini%, Text big bold, size
  
   if NumNotes is integer 
   {
      if(NumNotes>0 && NumNotes<=16)
         IniWrite, %NumNotes%, %settings_ini%, Misc, Number of notes
   }

   IniWrite, %ContMenuOnDblClick%, %settings_ini%, Misc, Context menu on double-click 
 
	IniWrite, %FontName%, %settings_ini%, Misc, Default font name 
	IniWrite, %FontSize%, %settings_ini%, Misc, Default font size 
	IniWrite, %BgrCol%, %settings_ini%, Misc, Default background color
	IniWrite, %DefCol%, %settings_ini%, Misc, Default font color

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

; =====================================================


#IfWinActive  Quick Notes RE - Drozd
	$F1:: Gosub, GoToPrevTab
	$F2:: Gosub, GoToNextTab
  ^+z:: Gosub, Redo
#IfWinActive  

#IfWinActive  Find toolbar RE - Drozd
	$F1:: Gosub, GoToPrevTab
	$F2:: Gosub, GoToNextTab
  ^+z:: Gosub, Redo
#IfWinActive  

GoToNextTab:
	Gosub, checkTabLast
	if(TabCurr=="TabLast"){
		SendMessage, 0x1330, 0,, SysTabControl321, ahk_id %this_id1%  ;   TCM_SETCURFOCUS=0x1330.
		Sleep 0  
		SendMessage, 0x130C, 0,, SysTabControl321, ahk_id %this_id1%  ; TCM_SETCURSEL=0x130C		
	}else
	Control, TabRight , 1, SysTabControl321, ahk_id %this_id1%
	Gosub, Change
return

GoToPrevTab:
	Gosub, checkTabLast
	if(TabCurr=="TabFirst"){
		lastTabNum:=numOfNotes-1
		SendMessage, 0x1330, %lastTabNum%,, SysTabControl321, ahk_id %this_id1%  ; TCM_SETCURFOCUS=0x1330.
		Sleep 0  
		SendMessage, 0x130C, %lastTabNum%,, SysTabControl321, ahk_id %this_id1%  ; TCM_SETCURSEL=0x130C	
	}else
	Control, TabLeft , 1, SysTabControl321, ahk_id %this_id1%
	Gosub, Change
return

checkTabLast:
	TabCurr:=""
	GuiControlGet, Tname , , TabName
	Tfirst:=n1,Tlast:=n%numOfNotes%
	
	if(Tname==Tfirst){
		TabCurr:="TabFirst"
	}else if(Tname==Tlast){
		TabCurr:="TabLast"
	}
	;MsgBox,4096,, % Tname "`n" TabCurr
return					 

; =====================================================

/* #IfWinActive Quick Notes RE - Drozd
WHEEL_DELTA := (120 << 16)
WheelUp::
	;PostMessage, 0xB6, 0, -3, ,  % "ahk_id " RE[Curr_Index].HWND ; EM_LINESCROLL:=0xB6 scroll up  3
	PostMessage, 0x20A, 7864320, (mY << 16) | mX,, % "ahk_id " RE[Curr_Index].HWND
	;Scroll(7864320)  
return

WheelDown::
	;PostMessage, 0xB6, 0, 3, ,  % "ahk_id " RE[Curr_Index].HWND ; EM_LINESCROLL:=0xB6 scroll down 3
	PostMessage, 0x20A, -7864320, (mY << 16) | mX,, % "ahk_id " RE[Curr_Index].HWND
	;Scroll(-7864320)
return
#IfWinActive 


Scroll(WHEEL_DELTA) {
 MouseGetPos, mX, mY, hWin, hCtrl, 2
 PostMessage, 0x20A, WHEEL_DELTA, (mY << 16) | mX,,% "ahk_id" (hCtrl ? hCtrl:hWin)
} 
 */


/* #IfWinActive Find toolbar RE - Drozd
WHEEL_DELTA := (120 << 16)
WheelUp::	
;MouseGetPos, , , Win_ID, ctrl, 2
;if(Win_ID==this_id1 || ctrl==RE[Curr_Index].HWND)
PostMessage, 0x20A, 7864320, (mY << 16) | mX,, % "ahk_id " RE[Curr_Index].HWND
return
WheelDown::
;MouseGetPos, , , Win_ID, ctrl, 2
;if(Win_ID==this_id1 || ctrl==RE[Curr_Index].HWND)
PostMessage, 0x20A, -7864320, (mY << 16) | mX,, % "ahk_id " RE[Curr_Index].HWND
return
#IfWinActive 

 */

 
#IfWinActive Quick Notes RE - Drozd
~LButton & WheelUp:: Gosub, PageUp  
~LButton & Wheeldown:: Gosub, PageDown
#IfWinActive 

PageDown:
  ;SendMessage, 0x115, 3, 0, RICHEDIT50W%Curr_Index% , Quick Notes RE - Drozd  ; scroll PageDown   WM_VSCROLL
	SendMessage, 0x115, 3, 0,  , % "ahk_id " RE[Curr_Index].HWND ; scroll PageDown   WM_VSCROLL
return

PageUp:
 ;SendMessage, 0x115, 2, 0, RICHEDIT50W%Curr_Index% , Quick Notes RE - Drozd ; scroll PageUp 
 SendMessage, 0x115, 2, 0, , % "ahk_id " RE[Curr_Index].HWND ; scroll PageUp 
return


~$F4::
	if (!WinActive("ahk_id " this_id1)) 
		WinActivate, % "ahk_id " this_id1 
		;Gui 1: Show
return

; =====================================================

GUIDropFiles:
	file_path:=A_GUIEvent
	 Gui, Submit, NoHide	
	 	Loop %numOfNotes%  {
		if (TabName=n%A_Index%) {
			Curr_Index=%A_Index%
			}	
		}
	if (RegExMatch(file_path,"i)\.rtf$")){
		 RE[Curr_Index].LoadFile(file_path)		
	}else{
			;FileRead, from_file, %file_path%
			;GuiControl,1:,  Note%Curr_Index% , %from_file%
			FileObj :=FileOpen(file_path, "r", "UTF-8")					 
			text_ := FileObj.Read()
			RE[Curr_Index].SetText(text_)
			FileObj.Close()
			text_:=""			 
      SendMessage, 0xB9, 1, 0, , % "ahk_id " . RE[Curr_Index].HWND ; EM_SETMODIFY = 0xB9
			;RE[Curr_Index].SetModified() ;  modification flag
	}
return

; =====================================================

GuiSize:  ; on window resize
		Loop %numOfNotes%  {		
			GuiControl Move, RICHEDIT50W%A_Index%, % "H" . (A_GuiHeight-28) . " W" . (A_GuiWidth)
		}	
		GuiControl Move, TabName, %  " W" . (A_GuiWidth) "H" . (A_GuiHeight)
		GuiControl Move, Static11, %  "x" . (A_GuiWidth-20)
		
		
		WinGetPos, x1,y1,w1,h1, Quick Notes RE - Drozd
		WinMove, Find toolbar RE - Drozd  ,,  % (x1+5) ,  (y1 + h1 - 40),(w1-10)
		;WinMove, % "ahk_id " this_id3  ,,  % (x1+5) ,  (y1 + h1 - 40),(w1-10)
return


3GuiSize:  
GuiControl Move, Static1, %  "x" . (A_GuiWidth-26)	
return 


GetModified(){
	global this_id1
	searchMarkAll_reset("All")
	str:=""
	Loop %numOfNotes%  {		
			if(RE[A_Index].IsModified()!=0)
				str.= "`t" n%A_Index% "`n" 
		}
	return str
}


Close:
GuiClose:
  Gosub, saveQueries
  Gosub, save_position_size
	searchMarkAll_reset("All")
	ismodified:= GetModified()
	if (ismodified==""){
		ExitApp
	}else{

		;MsgBox, 0x00040003, , Do you want to save before exiting? `nModified:`n%ismodified% 
		MsgBox, 0x00040103, , Do you want to save before exiting? `nModified:`n%ismodified% ;+100 "No" as default
		IfMsgBox, Yes
		 Gosub,Save_All_and_Exit
		IfMsgBox, No
			ExitApp
		IfMsgBox Cancel
			return
	}
return 


 
GuiEscape:
3GuiEscape:
	Gui 3: Hide
return



saveQueries:
  ControlGet, query_,List,,ComboBox1, Find toolbar RE - Drozd
  query_:= RegExReplace(query_,"im)`n",",")	
	query_:= RegExReplace(query_,"^,|,$","")	  
	if(query_!="")
  IniWrite, %query_%, %settings_ini%, Search, query
return


save_position_size:
	SysGet, MonitorWorkArea, MonitorWorkArea, 1
	ScreenW:=	MonitorWorkAreaRight  ;A_ScreenWidth A_ScreenHeight
	ScreenH:= MonitorWorkAreaBottom 	
	GuiHwnd:=this_id1
	WinGetPos, pos_x,pos_y,w,h, ahk_id %GuiHwnd%
	if(pos_x>=0 && pos_y>=0 && pos_x+w<=ScreenW && pos_y+h<=ScreenH ){
		IniWrite, %pos_x%	, %settings_ini%, Misc, x
		IniWrite, %pos_y%	, %settings_ini%, Misc, y
	}
	VarSetCapacity(RC, 16)
	DllCall("GetClientRect", "uint", GuiHwnd, "uint", &RC)
	w1 := NumGet(RC, 8, "int")
	h1 := NumGet(RC, 12, "int")
	if(w<=ScreenW && h<=ScreenH ){
		IniWrite, %w1%	, %settings_ini%, Misc, w
		IniWrite, %h1%	, %settings_ini%, Misc, h
	}
return

valid_pos(val){
	if(val!="ERROR" && val!=""){
		if val is integer
		return true
	}
	return false
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
   if(hwnd=CB_ListID)
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
global List_id
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


List_Func_2(hwnd, win){
	global Win_ID, Gui1_Id, List__
	
		del:=ComboDel(hwnd)		
			if(del==1)
				return
	ControlFocus ,%hwnd%, ahk_id %Win_ID%
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
    Gosub, saveQueries
				return 1	
		}else{
      CbAutoComplete()
    }
		return 0 
	}
  
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
	heightF:=12 , weight:=700,fontName:="Arial"  ;"Segoe Print"
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
	m:=0
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

; Esc:: exitapp


date_(){
	FormatTime, date_,, MMMd
	sendTimeStamp(date_)
}

Time_(){
	FormatTime, Time_,, HH:mm
	sendTimeStamp(Time_)
}
date_time(){
	FormatTime, DateTime_,, d MMM, yyyy HH:mm
	sendTimeStamp(DateTime_)
}

date_full(){
	FormatTime, date_full,, d MMM, yyyy
	sendTimeStamp(date_full)
}


sendTimeStamp(timeStamp){
	global
	Font := RE[Curr_Index].GetFont()
	FontBk := Font.Clone()
	Font.Name:=stampName, Font.Size:=stampSize,Font.Color:= stampCol , Font.BkColor:=stampBkCol, Font.Style:= stampStyle
	SendInput, % "`n"
	RE[Curr_Index].SetFont(Font)
	
	SendInput, % " " timeStamp " "
	RE[Curr_Index].SetFont(FontBk)	
	SendInput, % "`n" 
}	


Open_ini:
Run, %settings_ini%
return

;========================== RichEdit =================================




;==================================
ContextMenuMake:
	Menu, File, Add, &Open, FileOpen	
	Menu, File, Add, &Append, FileAppend
	Menu, File, Add, &Insert, FileInsert
	Menu, File, Add, Save &as, FileSaveAs
	Menu, File, Icon, Save &as, shell32.dll, 259
	Menu, File, Add
	Menu, File, Add, Settings, GoSettings
  Menu, File, Add , Open settings file , Open_ini
	Menu, File, Icon , Open settings file , Shell32.dll, 70
	Menu, File, Add, Open folder, Open_folder
	Menu, File, Add	
	Menu, File, Add, &Exit, GuiClose	
	
	
	Menu, Edit, Add, &Undo`tCtrl+Z, Undo
	Menu, Edit, Add, &Redo`tCtrl+Y, Redo
	Menu, Edit, Add
	Menu, Edit, Add, &Copy`tCtrl+C, Copy
	Menu, Edit, Add, &Paste`tCtrl+V, Paste
	Menu, Edit, Add
	Menu, Edit, Add, &Find`tCtrl+F, Find_RE
	Menu, Edit, Add, &Replace`tCtrl+H, Replace_RE

	Menu, Format, Add, Bold, SetFontStyle 
	Menu, Format, Add,
	Menu, Format, Add, Text color, MTextColor
	Menu, Format, Add, Text background color, MTextBkColor
	Menu, Format, Add,
	Menu, Format, Add, Font, ChooseFont		
	Menu, FontSize, Add, Choose font size, FontSize
	Menu, FontSize, Add, + Increase, ChangeSize
	Menu, FontSize, Add, - Decrease, ChangeSize
	Menu, Format, Add, Font Size, :FontSize	
	
	Menu, FontStyle, Add, Normal, SetFontStyle
	Menu, FontStyle, Add, Bold, SetFontStyle	
	Menu, FontStyle, Add, Italic, SetFontStyle
	Menu, FontStyle, Add, Underline, SetFontStyle		
	Menu, FontStyle, Add, Strikeout, SetFontStyle
	Menu, FontStyle, Add, Subscript, SetFontStyle		
	Menu, FontStyle, Add, Superschript, SetFontStyle

	
	
	Menu, Format, Add, Font Style, :FontStyle

	Menu, LineSpacing , Add, 1, LineSpacing	
	Menu, LineSpacing , Add, 1.2 , LineSpacing	
	Menu, LineSpacing , Add, 1.3 , LineSpacing		
	Menu, LineSpacing , Add, 1.5 , LineSpacing	
	Menu, LineSpacing , Add, 2 , LineSpacing	

	
	Menu, Format , Add, Line Spacing, :LineSpacing	
	
	Menu, Align , Add, Align Center, AlignCenter	
  Menu, Align , Add, Align Left, AlignLeft	
  Menu, Align , Add, Align Right , AlignRight	
  
	Menu, Format , Add, Align , :Align	  
  
  
	Menu, Format, Add,
	;Menu, Format, Add, Background Color, BackgroundColor
  ;Menu, Format, Add,  Default font, DefaultFont
	;Menu, Format, Add,
	Menu, Format, Add, &URL Detection, AutoURLDetection
  
	
	;Italic, U = Underline, S = Strikeout, L = Subscript, H = Superschript,  N = Normal
	Menu, Format, Add, 
	Menu, Format, Add, Reset style and color, ResetFormat
	
	Menu, Highlight, Add, Highlight custom,  Highlight_Custom			
	Menu, Highlight, Add, 	
	Menu, Highlight, Add, Highlight Yellow , Highlight_Yellow 
	Menu, Highlight, Add, Highlight Red,  Highlight_Red	
	Menu, Highlight, Add, Highlight Beige,  Highlight_Beige		
	Menu, Highlight, Add, Highlight Green,  Highlight_Green		
	Menu, Highlight, Add, Highlight Blue,  Highlight_Blue		
 


	Menu, Text color, Add, Color custom , Color_Custom	
	Menu, Text color, Add, Color Black , ColorBlack  
	Menu, Text color, Add,  
	Menu, Text color, Add, Color Red , ColorRed
	Menu, Text color, Add, Color Green,  ColorGreen 
	Menu, Text color, Add, Color Blue,  	ColorBlue	
  Menu, Text color, Add,
	Menu, Text color, Add, Color Yellow , ColorYellow
  Menu, Text color, Add, Color Silver , ColorSilver




	Menu, ContextMenu, Add, Format, :Format
	Menu, ContextMenu, Icon, Format, shell32.dll, 39
	
	Menu, ContextMenu, Add,
	Menu, ContextMenu, Add, Bold, SetFontStyle 
	Menu, ContextMenu, Add, Text big bold, BigBold
	Menu, ContextMenu, Add,   
	Menu, ContextMenu, Add, Red text, ColorRed
 
	Menu, ContextMenu, Icon, Red text, shell32.dll, 74
	;Menu, ContextMenu, Add, Silver text, ColorSilver	
	Menu, ContextMenu, Add, Highlight Yellow , Highlight_Yellow 
	;Menu, ContextMenu, Icon, Highlight Yellow, imageres.dll,4
	
	Menu, ContextMenu, Add,
  Menu, ContextMenu, Add, Text color, :Text color
  Menu, ContextMenu, Icon, Text color, shell32.dll,75
  
	Menu, ContextMenu, Add, Highlight, :Highlight
  
  if RegExMatch(A_OSVersion,"WIN_VISTA|WIN_7")
	Menu, ContextMenu, Icon, Highlight, wmploc.dll,57
  else
	Menu, ContextMenu, Icon, Highlight, shell32.dll, 241 ; 246 ; 306  ;wmploc.dll,67
  

  
	Menu, ContextMenu, Add, Font Size, :FontSize
  Menu, ContextMenu, Add, Font Family, FontFamily
	Menu, ContextMenu, Add,
	Menu, ContextMenu, Add, Reset style and color, ResetFormat

	Menu, Time_Date, Add,  Full date and time, date_time
	Menu, Time_Date, Add,  Full date , date_full 
	Menu, Time_Date, Add,  Date, date_
	Menu, Time_Date, Add,  Time, Time_
	Menu, ContextMenu, Add, 
	Menu, ContextMenu, Add, Time/Date, :Time_Date
  Menu, ContextMenu, Icon, Time/Date, shell32.dll,21
  
	Menu, ContextMenu, Add,	
	Menu, ContextMenu, Add, File, :File
	Menu, ContextMenu, Icon, File, shell32.dll,5
	Menu, ContextMenu, Add, Edit, :Edit	

	;Menu, ContextMenu, Add,
	;Menu, ContextMenu, Add, Exit, Close

/* 	Menu, ContextMenu, Add, Highlight Yellow , Highlight_Yellow 
	Menu, ContextMenu, Add, Highlight Red,  Highlight_Red	
	Menu, ContextMenu, Add, Highlight Beige,  Highlight_Beige		
	Menu, ContextMenu, Add, Highlight Green,  Highlight_Green		
	 */
return


Undo:
RE[Curr_Index].Undo()
GuiControl, Focus, % RE[Curr_Index].HWND
Return

Redo:
RE[Curr_Index].Redo()
GuiControl, Focus, % RE[Curr_Index].HWND
Return

Copy:
RE[Curr_Index].Copy()
GuiControl, Focus, % RE[Curr_Index].HWND
Return

Paste:
RE[Curr_Index].Paste()
GuiControl, Focus, % RE[Curr_Index].HWND
Return


;load:
FileAppend:
FileOpen:
FileInsert:
If (FilePath := RichEditDlgs.FileDlg(RE[Curr_Index], "O")) {
   RE[Curr_Index].LoadFile(FilePath, SubStr(A_ThisLabel, 5))
}
SendMessage, 0xB9, 1, 0, , % "ahk_id " . RE[Curr_Index].HWND ; EM_SETMODIFY = 0xB9
;RE[Curr_Index].SetModified()
GuiControl, Focus, % RE[Curr_Index].HWND
Return


FileSaveAs:
If (File := RichEditDlgs.FileDlg(RE[Curr_Index], "S")) {
   RE[Curr_Index].SaveFile(File)
}
GuiControl, Focus, % RE[Curr_Index].HWND
Return





;==================================

ChooseFont:
RichEditDlgs.ChooseFont(RE[Curr_Index])
Return

MTextColor:    
NC := RichEditDlgs.ChooseColor(RE[Curr_Index], "T")
if(NC!="Cancel")
   RE[Curr_Index].SetFont({Color: NC})

ControlFocus,, % "ahk_id " . RE[Curr_Index].HWND
Return

MTextBkColor:  
NC := RichEditDlgs.ChooseColor(RE[Curr_Index], "B")
if(NC!="Cancel")
   RE[Curr_Index].SetFont({BkColor: NC})
/* 	InputBox, col,  Font , hex color code, , 180, 130,,, , , FFFFFF
		if ErrorLevel  ;CANCEL
			return
	RE[Curr_Index].SetFont({BkColor: "0x" col})
	 */
ControlFocus,, % "ahk_id " . RE[Curr_Index].HWND
Return

BackgroundColor:
NC := RichEditDlgs.ChooseColor(RE[Curr_Index])
if(NC!="Cancel")
	RE[Curr_Index].SetBkgndColor(NC)
/* 	InputBox, col,  Font , hex color code, , 180, 130,,, , , E3E0D1
		if ErrorLevel  ;CANCEL
			return
		RE[Curr_Index].SetBkgndColor("0x" col)
		 */
	GuiControl, Focus, % RE[Curr_Index].HWND
Return


SetFontStyle:
;B = bold, I = Italic, U = Underline, S = Strikeout, L = Subscript, H = Superschript, P = Protected, N = Normal

	if(A_ThisMenuItem=="Bold"){
		FS:="B"
	}else if(A_ThisMenuItem=="Italic"){
			FS:="I"
	}else if(A_ThisMenuItem=="Underline"){
			FS:="U"		
	}else if(A_ThisMenuItem=="Strikeout"){
			FS:="S"		
	}else if(A_ThisMenuItem=="Subscript"){
			FS:="L"		
	}else if(A_ThisMenuItem=="Superschript"){
			FS:="H"				
		
	}else if(A_ThisMenuItem=="Normal"){
			FS:="N"	
	;}else if(A_ThisMenuItem=="Protected"){
			;FS:="P"				
			
	}
	RE[Curr_Index].ToggleFontStyle(FS)
	GuiControl, Focus, % RE[Curr_Index].HWND
Return


ChangeSize:
	if(A_ThisMenuItem=="+ Increase"){
		FS:=1
	}else if(A_ThisMenuItem=="- Decrease"){
		FS:=-1	
	}
	Size := RE[Curr_Index].ChangeFontSize(FS)
	GuiControl, Focus, % RE[Curr_Index].HWND
Return

;==================================

FontSize:
	Font := RE[Curr_Index].GetFont()
	InputBox, size_input,  Font , Font Size, , 180, 130,,, , , % Round(Font.Size) ;16
		if ErrorLevel  ;CANCEL
			return
	num:=size_input-Font.Size
	SendMessage, 0x04DF, %num% , 0, , % "ahk_id " . RE[Curr_Index].HWND 
	;SendMessage, 0x04DF, 1 , 0, , % "ahk_id " . RE[Curr_Index].HWND ; font size +1
return

DefaultFont:
	Font := RE[Curr_Index].GetFont()
	InputBox, font_Fam,  Font , Font family, , 180, 130,,, , , % Font.Name 
		if ErrorLevel  ;CANCEL
			return
	InputBox, font_size,  Font , Font size, , 180, 130,,, , , % Round(Font.Size) 
	InputBox, font_col,  Font , hex color code, , 180, 130,,, , , 000000
	
	Font.Size:=font_size	
	Font.Name:=font_Fam
	Font.Color:= "0x" font_col ;, Font.BkColor:=0xFFFFFF
	RE[Curr_Index].SetDefaultFont(Font)
return


/* FontFamily:
	Font := RE[Curr_Index].GetFont()
	InputBox, font_input,  Font , Font Family, , 180, 130,,, , , % Font.Name 
		if ErrorLevel  ;CANCEL
			return
   Font.Name:=font_input ;"Segoe UI" 
	 RE[Curr_Index].SetFont(Font)
return
 */

FontFamily:
  Font := RE[Curr_Index].GetFont()
	inputDrozd_(Font.Name "||" "Segoe UI|Tahoma|Microsoft Sans Serif|Arial|Arial Black|Segoe UI Semibold|Times New Roman|Georgia|Verdana|Courier New|Trebuchet MS|Lucida Console|Consolas|Segoe Print|Comic Sans MS|Century Gothic", Font.Name,"Font Family") 
  ;Aharoni;Segoe Script
return


List_Func(hwnd){
	global		
	GuiControlGet, list_, 77: , % hwnd
	Font := RE[Curr_Index].GetFont()
	Font.Name:=list_ 
	RE[Curr_Index].SetFont(Font)
	Gui,77: Destroy
	Gui,1: Show
}

inputDrozd_(choices:="",text:="input",title:="inputDrozd"){
	global List_id
	if(choices=="")
	choices:="Tahoma||Segoe UI|Arial|Arial Black|Times New Roman|Georgia|Verdana|Courier New|Trebuchet MS|Lucida Console|Consolas|Aharoni|Segoe Script|Segoe Print|Comic Sans MS|Century Gothic"
	Gui,77: Destroy
	Gui,77: +Owner1 +AlwaysOnTop +ToolWindow
	Gui,77: +HwndGuiHwnd -MinimizeBox -MaximizeBox 
	Gui,77:Font, S10 Q5, Segoe UI 
	Gui,77:Add, Text, x10 w150 , %text%
	Gui,77:Font, Default
	Gui,77:Add, ComboBox, x10 y36 +HWNDList_id, %choices%
	Gui,77:Add, Button, x24 h25 w51 Default +HWNDBut_id, OK
		fn := Func("List_Func").Bind(List_id)
		GuiControl, +g, % But_id, % fn		
	Gui,77:Add, Button,x+20 h25 w51 gCancel	,Cancel	

	Gui,77:Show,   , %title%	
	return
	
	Cancel:
	Gui,77: Destroy
	return
}




;==================================
;==================================

AutoURLDetection:
	RE[Curr_Index].AutoURL(AutoURL ^= True)
	Menu, %A_ThisMenu%, ToggleCheck, %A_ThisMenuItem%
	GuiControl, Focus, % RE[Curr_Index].HWND
Return

AlignLeft:
AlignCenter:
AlignRight:
AlignJustify:
RE[Curr_Index].AlignText({AlignLeft: 1, AlignRight: 2, AlignCenter: 3, AlignJustify: 4}[A_ThisLabel])
GuiControl, Focus, % RE2.HWND
Return

;==================================

Highlight_Yellow:  ;E3F6E6 FEFFCE
	;ColorYellowHighlight:="0xFEFFB6"
	NC:=0xFEFFB6 ;FEFFCE 
	RE[Curr_Index].SetFont({BkColor: "0x" ColorYellowHighlight})
	ControlFocus,, % "ahk_id " . RE[Curr_Index].HWND
return

Highlight_Red:  
	;ColorRedHighlight:="0xFFDADA"  
	NC:=0xFFDADA  ;NC:=0xFFDEDE
	RE[Curr_Index].SetFont({BkColor: "0x" ColorRedHighlight})
	ControlFocus,, % "ahk_id " . RE[Curr_Index].HWND
return


Highlight_Beige: 
	;ColorBeigeHighlight:="0xE7E2C4"
	;NC:=0xF2EED8 ; light
	NC:=0xE7E2C4 
	RE[Curr_Index].SetFont({BkColor: "0x" ColorBeigeHighlight})
	ControlFocus,, % "ahk_id " . RE[Curr_Index].HWND
return

Highlight_Green:  
	;ColorGreenHighlight:="0xCDEED0"
	;NC:=0xE3F6E6 ; light
	NC:=0xCDEED0 ;B4EEB9
	RE[Curr_Index].SetFont({BkColor: "0x" ColorGreenHighlight})
	ControlFocus,, % "ahk_id " . RE[Curr_Index].HWND
return

Highlight_Blue:  
	;ColorBlueHighlight:="0x81BAF2"
	NC:=0x81BAF2
	RE[Curr_Index].SetFont({BkColor: "0x" ColorBlueHighlight})
	ControlFocus,, % "ahk_id " . RE[Curr_Index].HWND
return



Highlight_Custom:  
	Font := RE[Curr_Index].GetFont() 
	col:=Font.BkColor
	if(col!="Auto"){ 
		col:=Format("{1:X}",col ), col:=SubStr("000000" . col, -5) ; to 6 characters
	}
	InputBox, color_input,  Highlight color, hex color code, , 180, 130,,, , , % col  ;  FFDADA
		if ErrorLevel  ;CANCEL
			return
	   NC:="0x" color_input
   RE[Curr_Index].SetFont({BkColor: NC})
   ControlFocus,, % "ahk_id " . RE[Curr_Index].HWND	
return

Color_Custom:  
   Font := RE[Curr_Index].GetFont() 
   col:=Format("{1:X}", Font.Color), col:=SubStr("000000" . col, -5) ; to 6 characters
   InputBox, color_input,  Font color, hex color code, , 180, 130,,, , , % col

	;InputBox, color_input,  Font color, hex color code, , 180, 130,,, , , FF0000
		if ErrorLevel  ;CANCEL
			return
		NC:="0x" color_input
		RE[Curr_Index].SetFont({Color: NC})
   ControlFocus,, % "ahk_id " . RE[Curr_Index].HWND	
return

ColorBlack:
   RE[Curr_Index].SetFont({Color: 0x000000})
   ControlFocus,, % "ahk_id " . RE[Curr_Index].HWND
return

ColorRed:
	;ColorRedFont:=0xDD0000
	;NC:=0xDD0000
	RE[Curr_Index].SetFont({Color: "0x" ColorRedFont})
	ControlFocus,, % "ahk_id " . RE[Curr_Index].HWND
return

ColorBlue:
	;ColorBlueFont:=0x0000C5
	NC:=0x0000C5
	RE[Curr_Index].SetFont({Color: "0x" ColorBlueFont})
	ControlFocus,, % "ahk_id " . RE[Curr_Index].HWND
return

ColorGreen:
	;ColorGreenFont:=0x009700
   ;NC:=0x009700
	RE[Curr_Index].SetFont({Color: "0x" ColorGreenFont})
	ControlFocus,, % "ahk_id " . RE[Curr_Index].HWND
return

ColorSilver:
	;ColorSilverFont:=0xC1C1C1
	;NC:=0xC1C1C1 ;0xCACACA
	RE[Curr_Index].SetFont({Color: "0x" ColorSilverFont})
	ControlFocus,, % "ahk_id " . RE[Curr_Index].HWND
return

ColorYellow:
	;ColorYellowFont:=0xFFF300
	;NC:=0xFFF300 ;D8CF28 
	RE[Curr_Index].SetFont({Color: "0x" ColorYellowFont})
	ControlFocus,, % "ahk_id " . RE[Curr_Index].HWND
return



BigBold:
	;sizeBigBoldFont:=12
	Font := RE[Curr_Index].GetFont()
	num:=sizeBigBoldFont-Font.Size
	SendMessage, 0x04DF, %num% , 0, , % "ahk_id " . RE[Curr_Index].HWND 
  FontBold(RE[Curr_Index])
return

FontBold(RE){	
	; bold =1 
	CF2 :=RE.GetCharFormat()
	CF2.Effects |= 1 ; on
	;CF2.Effects ^= 1 ;toggle	
  SendMessage, 0x0444, 1, % CF2.CF2, , % "ahk_id " . RE.HWND ; EM_SETCHARFORMAT = 0x0444
}

LineSpacing:
RE[Curr_Index].SetLineSpacing(A_ThisMenuItem)
return

;==================================

ResetFormat:
	RE[Curr_Index].ToggleFontStyle("N")
  Font := RE[Curr_Index].GetFont()
  Font.Size:= DefaultFontSize	
	Font.Name:= DefaultFontName
  Font.BkColor:= "0x" DefaultBackgroundColor
	Font.Color:="0x" DefaultFontColor  ;, Font.BkColor:=0xFFFFFF
  RE[Curr_Index].SetFont(Font)  
return



;~^g:: Gosub, test

test:
return


;========================== RichEdit =================================

;#Include C:\AutoHotkey Scripts\AHK_Library\Class_RichEdit.ahk
;#Include C:\AutoHotkey Scripts\AHK_Library\RichEdit OleCallback.ahk

; ======================================================================================================================
;github.com/AHK-just-me/Class_RichEdit/
; Scriptname:     Class_RichEdit.ahk
; Namespace:      RichEdit
; Author:         just me
; AHK Version:    1.1.14.03 U64
; OS Version:     Win 7 Pro x64
; Function:       The class provides some wrapper functions for rich edit controls (v4.1 Unicode).
; Credits:
;    corrupt for cRichEdit:
;       http://www.autohotkey.com/board/topic/17869-crichedit-standard-richedit-control-for-autohotkey-scripts/
;    jballi for HE_Print:
;       http://www.autohotkey.com/board/topic/45513-function-he-print-wysiwyg-print-for-the-hiedit-control/
;    majkinetor for Dlg:
;       http://www.autohotkey.com/board/topic/15836-module-dlg-501/
; ======================================================================================================================
Class RichEdit {
   ; ===================================================================================================================
   ; Class variables - do not change !!!
   ; ===================================================================================================================
   ; RichEdit v4.1 (Unicode)
   Static Class := "RICHEDIT50W"
   ; RichEdit v4.1 (Unicode)
   Static DLL := "Msftedit.dll"
   ; DLL handle
   Static Instance := DllCall("Kernel32.dll\LoadLibrary", "Str", RichEdit.DLL, "UPtr")
   ; Callback function handling RichEdit messages
   Static SubclassCB := 0
   ; Number of controls/instances
   Static Controls := 0
   ; ===================================================================================================================
   ; Instance variables - do not change !!!
   ; ===================================================================================================================
   GuiName := ""
   GuiHwnd := ""
   HWND := ""
   DefFont := ""
   ; ===================================================================================================================
   ; CONSTRUCTOR
   ; ===================================================================================================================
   __New(GuiName, Options, MultiLine := True) {
      Static WS_TABSTOP := 0x10000, WS_HSCROLL := 0x100000, WS_VSCROLL := 0x200000, WS_VISIBLE := 0x10000000
           , WS_CHILD := 0x40000000
           , WS_EX_CLIENTEDGE := 0x200, WS_EX_STATICEDGE := 0x20000
           , ES_MULTILINE := 0x0004, ES_AUTOVSCROLL := 0x40, ES_AUTOHSCROLL := 0x80, ES_NOHIDESEL := 0x0100
           , ES_WANTRETURN := 0x1000, ES_DISABLENOSCROLL := 0x2000, ES_SUNKEN := 0x4000, ES_SAVESEL := 0x8000
           , ES_SELECTIONBAR := 0x1000000
      ; Check for Unicode
      If !(SubStr(A_AhkVersion, 1, 1) > 1) && !(A_IsUnicode) {
         MsgBox, 16, % A_ThisFunc, % This.__Class . " requires a unicode version of AHK!"
         Return False
      }
      ; Do not instantiate instances of RichEdit
      If (This.Base.HWND)
         Return False
      ; Determine the HWND of the GUI
      Gui, %GuiName%:+LastFoundExist
      GuiHwnd := WinExist()
      If !(GuiHwnd) {
         ErrorLevel := "ERROR: Gui " . GuiName . " does not exist!"
         Return False
      }
      ; Load library if necessary
      If (This.Base.Instance = 0) {
         This.Base.Instance := DllCall("Kernel32.dll\LoadLibrary", "Str", This.Base.DLL, "UPtr")
         If (ErrorLevel) {
            ErrorLevel := "ERROR: Error loading " . This.Base.DLL . " - " . ErrorLevel
            Return False
         }
      }
      ; Specify default styles & exstyles
      Styles := WS_TABSTOP | WS_VISIBLE | WS_CHILD | ES_AUTOHSCROLL
      If (MultiLine)
         Styles |= WS_HSCROLL | WS_VSCROLL | ES_MULTILINE | ES_AUTOVSCROLL | ES_NOHIDESEL | ES_WANTRETURN
                 | ES_DISABLENOSCROLL | ES_SAVESEL ; | ES_SELECTIONBAR does not work properly
      ExStyles := WS_EX_STATICEDGE
      ; Create the control
      CtrlClass := This.Class
      Gui, %GuiName%:Add, Custom, Class%CtrlClass% %Options% hwndHWND +%Styles% +E%ExStyles%
      If (MultiLine) {
         ; Adjust the formatting rectangle for multiline controls to simulate a selection bar
         ; EM_GETRECT = 0xB2, EM_SETRECT = 0xB3
         VarSetCapacity(RECT, 16, 0)
         SendMessage, 0xB2, 0, &RECT, , ahk_id %HWND%
         NumPut(NumGet(RECT, 0, "Int") + 10, RECT, 0, "Int")
         NumPut(NumGet(RECT, 4, "Int") + 2,  RECT, 4, "Int")
         SendMessage, 0xB3, 0, &RECT, , ahk_id %HWND%
         ; Set advanced typographic options
         ; EM_SETTYPOGRAPHYOPTIONS = 0x04CA (WM_USER + 202)
         ; TO_ADVANCEDTYPOGRAPHY	= 1, TO_ADVANCEDLAYOUT = 8 ? not documented
         SendMessage, 0x04CA, 0x01, 0x01, , ahk_id %HWND%
      }
      ; Initialize control
      ; EM_SETLANGOPTIONS = 0x0478 (WM_USER + 120)
      ; IMF_AUTOKEYBOARD = 0x01, IMF_AUTOFONT = 0x02
      SendMessage, 0x0478, 0, 0x03, , ahk_id %HWND%
      ; Subclass the control to get Tab key and prevent Esc from sending a WM_CLOSE message to the parent window.
      ; One of majkinetor's splendid discoveries!
      ; Initialize SubclassCB
      If (This.Base.SubclassCB = 0)
         This.Base.SubclassCB := RegisterCallback("RichEdit.SubclassProc")
      DllCall("Comctl32.dll\SetWindowSubclass", "Ptr", HWND, "Ptr", This.Base.SubclassCB, "Ptr", HWND, "Ptr", 0)
      This.GuiName := GuiName
      This.GuiHwnd := GuiHwnd
      This.HWND := HWND
      This.DefFont := This.GetFont(1)
      This.DefFont.Default := 1
      ; Correct AHK font size setting, if necessary
      If (Round(This.DefFont.Size) <> This.DefFont.Size) {
         This.DefFont.Size := Round(This.DefFont.Size)
         This.SetDefaultFont()
      }
      This.Base.Controls += 1
      ; Initialize the print margins
      ;This.GetMargins()
      ; Initialize the text limit
      This.LimitText(2147483647)
   }
   ; ===================================================================================================================
   ; DESTRUCTOR
   ; ===================================================================================================================
   __Delete() {
      If (This.HWND) {
         DllCall("Comctl32.dll\RemoveWindowSubclass", "Ptr", This.HWND, "Ptr", This.Base.SubclassCB, "Ptr", 0)
         DllCall("User32.dll\DestroyWindow", "Ptr", This.HWND)
         This.HWND := 0
         This.Base.Controls -= 1
         If (This.Base.Controls = 0) {
            DllCall("Kernel32.dll\FreeLibrary", "Ptr", This.Base.Instance)
            This.Base.Instance := 0
         }
      }
   }
   ; ===================================================================================================================
   ; ===================================================================================================================
   ; INTERNAL CLASSES ==================================================================================================
   ; ===================================================================================================================
   ; ===================================================================================================================
   Class CF2 { ; CHARFORMAT2 structure -> http://msdn.microsoft.com/en-us/library/bb787883(v=vs.85).aspx
      __New() {
         Static CF2_Size := 116
         This.Insert(":", {Mask: {O: 4, T: "UInt"}, Effects: {O: 8, T: "UInt"}
                         , Height: {O: 12, T: "Int"}, Offset: {O: 16, T: "Int"}
                         , TextColor: {O: 20, T: "Int"}, CharSet: {O: 24, T: "UChar"}
                         , PitchAndFamily: {O: 25, T: "UChar"}, FaceName: {O: 26, T: "Str32"}
                         , Weight: {O: 90, T: "UShort"}, Spacing: {O: 92, T: "Short"}
                         , BackColor: {O: 96, T: "UInt"}, LCID: {O: 100, T: "UInt"}
                         , Cookie: {O: 104, T: "UInt"}, Style: {O: 108, T: "Short"}
                         , Kerning: {O: 110, T: "UShort"}, UnderlineType: {O: 112, T: "UChar"}
                         , Animation: {O: 113, T: "UChar"}, RevAuthor: {O: 114, T: "UChar"}
                         , UnderlineColor: {O: 115, T: "UChar"}})
         This.Insert(".")
         This.SetCapacity(".", CF2_Size)
         Addr :=  This.GetAddress(".")
         DllCall("Kernel32.dll\RtlZeroMemory", "Ptr", Addr, "Ptr", CF2_Size)
         NumPut(CF2_Size, Addr + 0, 0, "UInt")
      }
      __Get(Name) {
         Addr := This.GetAddress(".")
         If (Name = "CF2")
            Return Addr
         If !This[":"].HasKey(Name)
            Return ""
         Attr := This[":"][Name]
         If (Name <> "FaceName")
            Return NumGet(Addr + 0, Attr.O, Attr.T)
         Return StrGet(Addr + Attr.O, 32)
      }
      __Set(Name, Value) {
         Addr := This.GetAddress(".")
         If !This[":"].HasKey(Name)
            Return ""
         Attr := This[":"][Name]
         If (Name <> "FaceName")
            NumPut(Value, Addr + 0, Attr.O, Attr.T)
         Else
            StrPut(Value, Addr + Attr.O, 32)
         Return Value
      }
   }
   ; -------------------------------------------------------------------------------------------------------------------
   Class PF2 { ; PARAFORMAT2 structure -> http://msdn.microsoft.com/en-us/library/bb787942(v=vs.85).aspx
      __New() {
         Static PF2_Size := 188
         This.Insert(":", {Mask: {O: 4, T: "UInt"}, Numbering: {O: 8, T: "UShort"}
                         , StartIndent: {O: 12, T: "Int"}, RightIndent: {O: 16, T: "Int"}
                         , Offset: {O: 20, T: "Int"}, Alignment: {O: 24, T: "UShort"}
                         , TabCount: {O: 26, T: "UShort"}, Tabs: {O: 28, T: "UInt"}
                         , SpaceBefore: {O: 156, T: "Int"}, SpaceAfter: {O: 160, T: "Int"}
                         , LineSpacing: {O: 164, T: "Int"}, Style: {O: 168, T: "Short"}
                         , LineSpacingRule: {O: 170, T: "UChar"}, OutlineLevel: {O: 171, T: "UChar"}
                         , ShadingWeight: {O: 172, T: "UShort"}, ShadingStyle: {O: 174, T: "UShort"}
                         , NumberingStart: {O: 176, T: "UShort"}, NumberingStyle: {O: 178, T: "UShort"}
                         , NumberingTab: {O: 180, T: "UShort"}, BorderSpace: {O: 182, T: "UShort"}
                         , BorderWidth: {O: 184, T: "UShort"}, Borders: {O: 186, T: "UShort"}})
         This.Insert(".")
         This.SetCapacity(".", PF2_Size)
         Addr :=  This.GetAddress(".")
         DllCall("Kernel32.dll\RtlZeroMemory", "Ptr", Addr, "Ptr", PF2_Size)
         NumPut(PF2_Size, Addr + 0, 0, "UInt")
      }
      __Get(Name) {
         Addr := This.GetAddress(".")
         If (Name = "PF2")
            Return Addr
         If !This[":"].HasKey(Name)
            Return ""
         Attr := This[":"][Name]
         If (Name <> "Tabs")
            Return NumGet(Addr + 0, Attr.O, Attr.T)
         Tabs := []
         Offset := Attr.O - 4
         Loop, 32
            Tabs[A_Index] := NumGet(Addr + 0, Offset += 4, "UInt")
         Return Tabs
      }
      __Set(Name, Value) {
         Addr := This.GetAddress(".")
         If !This[":"].HasKey(Name)
            Return ""
         Attr := This[":"][Name]
         If (Name <> "Tabs") {
            NumPut(Value, Addr + 0, Attr.O, Attr.T)
            Return Value
         }
         If !IsObject(Value)
            Return ""
         Offset := Attr.O - 4
         For Each, Tab In Value
            NumPut(Tab, Addr + 0, Offset += 4, "UInt")
         Return Tabs
      }
   }
   ; ===================================================================================================================
   ; ===================================================================================================================
   ; PRIVATE METHODS ===================================================================================================
   ; ===================================================================================================================
   ; ===================================================================================================================
   GetBGR(RGB) { ; Get numeric BGR value from numeric RGB value or HTML color name
      Static HTML := {BLACK:  0x000000, SILVER: 0xC0C0C0, GRAY:   0x808080, WHITE:   0xFFFFFF
                    , MAROON: 0x000080, RED:    0x0000FF, PURPLE: 0x800080, FUCHSIA: 0xFF00FF
                    , GREEN:  0x008000, LIME:   0x00FF00, OLIVE:  0x008080, YELLOW:  0x00FFFF
                    , NAVY:   0x800000, BLUE:   0xFF0000, TEAL:   0x808000, AQUA:    0xFFFF00}
      If HTML.HasKey(RGB)
         Return HTML[RGB]
      Return ((RGB & 0xFF0000) >> 16) + (RGB & 0x00FF00) + ((RGB & 0x0000FF) << 16)
   }
   ; -------------------------------------------------------------------------------------------------------------------
   GetRGB(BGR) {  ; Get numeric RGB value from numeric BGR-Value
      Return ((BGR & 0xFF0000) >> 16) + (BGR & 0x00FF00) + ((BGR & 0x0000FF) << 16)
   }
   ; -------------------------------------------------------------------------------------------------------------------
   GetMeasurement() { ; Get locale measurement (metric / inch)
      ; LOCALE_USER_DEFAULT = 0x0400, LOCALE_IMEASURE = 0x0D, LOCALE_RETURN_NUMBER = 0x20000000
      Static Metric := 2.54  ; centimeters
           , Inches := 1.00  ; inches
           , Measurement := ""
           , Len := A_IsUnicode ? 2 : 4
      If (Measurement = "") {
         VarSetCapacity(LCD, 4, 0)
         DllCall("Kernel32.dll\GetLocaleInfo", "UInt", 0x400, "UInt", 0x2000000D, "Ptr", &LCD, "Int", Len)
         Measurement := NumGet(LCD, 0, "UInt") ? Inches : Metric
      }
      Return Measurement
   }
   ; -------------------------------------------------------------------------------------------------------------------
   SubclassProc(M, W, L, I, R) { ; RichEdit subclassproc
      ; Left out first parameter HWND, will be found in "This" when called by system
      ; See -> http://msdn.microsoft.com/en-us/library/bb776774%28VS.85%29.aspx
      If (M = 0x87) ; WM_GETDLGCODE
         Return 4   ; DLGC_WANTALLKEYS
      Return DllCall("Comctl32.dll\DefSubclassProc", "Ptr", This, "UInt", M, "Ptr", W, "Ptr", L)
   }
   ; ===================================================================================================================
   ; ===================================================================================================================
   ; PUBLIC METHODS ====================================================================================================
   ; ===================================================================================================================
   ; ===================================================================================================================
   ; -------------------------------------------------------------------------------------------------------------------
   ; Methods to be used by advanced users only
   ; -------------------------------------------------------------------------------------------------------------------
   GetCharFormat() { ; Retrieves the character formatting of the current selection.
      ; For details see http://msdn.microsoft.com/en-us/library/bb787883(v=vs.85).aspx.
      ; Returns a 'CF2' object containing the formatting settings.
      ; EM_GETCHARFORMAT = 0x043A
      CF2 := New This.CF2
      SendMessage, 0x043A, 1, % CF2.CF2, , % "ahk_id " . This.HWND
      Return (CF2.Mask ? CF2 : False)
   }
   ; -------------------------------------------------------------------------------------------------------------------
   SetCharFormat(CF2) { ; Sets character formatting of the current selection.
      ; For details see http://msdn.microsoft.com/en-us/library/bb787883(v=vs.85).aspx.
      ; CF2 : CF2 object like returned by GetCharFormat().
      ; EM_SETCHARFORMAT = 0x0444
      SendMessage, 0x0444, 1, % CF2.CF2, , % "ahk_id " . This.HWND
      Return ErrorLevel
   }
   ; -------------------------------------------------------------------------------------------------------------------
   GetParaFormat() { ; Retrieves the paragraph formatting of the current selection.
      ; For details see http://msdn.microsoft.com/en-us/library/bb787942(v=vs.85).aspx.
      ; Returns a 'PF2' object containing the formatting settings.
      ; EM_GETPARAFORMAT = 0x043D
      PF2 := New This.PF2
      SendMessage, 0x043D, 0, % PF2.PF2, , % "ahk_id " . This.HWND
      Return (PF2.Mask ? PF2 : False)
   }
   ; -------------------------------------------------------------------------------------------------------------------
   SetParaFormat(PF2) { ; Sets the  paragraph formatting for the current selection.
      ; For details see http://msdn.microsoft.com/en-us/library/bb787942(v=vs.85).aspx.
      ; PF2 : PF2 object like returned by GetParaFormat().
      ; EM_SETPARAFORMAT = 0x0447
      SendMessage, 0x0447, 0, % PF2.PF2, , % "ahk_id " . This.HWND
      Return ErrorLevel
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; Control specific
   ; -------------------------------------------------------------------------------------------------------------------
   IsModified() { ; Has the control been  modified?
      ; EM_GETMODIFY = 0xB8
      SendMessage, 0xB8, 0, 0, , % "ahk_id " . This.HWND
      Return ErrorLevel
   }
   ; -------------------------------------------------------------------------------------------------------------------
   SetModified(Modified := False) { ; Sets or clears the modification flag for an edit control.
      ; EM_SETMODIFY = 0xB9
      SendMessage, 0xB9, % !!Modified, 0, , % "ahk_id " . This.HWND
      Return ErrorLevel
   }
   ; -------------------------------------------------------------------------------------------------------------------
   SetEventMask(Events := "") { ; Set the events which shall send notification codes control's owner
      ; Events : Array containing one or more of the keys defined in 'ENM'.
      ; For details see http://msdn.microsoft.com/en-us/library/bb774238(v=vs.85).aspx
      ; EM_SETEVENTMASK	= 	0x0445
      Static ENM := {NONE: 0x00, CHANGE: 0x01, UPDATE: 0x02, SCROLL: 0x04, SCROLLEVENTS: 0x08, DRAGDROPDONE: 0x10
                   , PARAGRAPHEXPANDED: 0x20, PAGECHANGE: 0x40, KEYEVENTS: 0x010000, MOUSEEVENTS: 0x020000
                   , REQUESTRESIZE: 0x040000, SELCHANGE: 0x080000, DROPFILES: 0x100000, PROTECTED: 0x200000
                   , LINK: 0x04000000}
      If !IsObject(Events)
         Events := ["NONE"]
      Mask := 0
      For Each, Event In Events {
         If ENM.HasKey(Event)
            Mask |= ENM[Event]
         Else
            Return False
      }
      SendMessage, 0x0445, 0, %Mask%, , % "ahk_id " . This.HWND
      Return ErrorLevel
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; Loading and storing RTF format
   ; -------------------------------------------------------------------------------------------------------------------
   GetRTF(Selection := False) { ; Gets the whole content of the control as rich text.
      ; Selection = False : whole contents (default)
      ; Selection = True  : current selection
      ; EM_STREAMOUT = 0x044A
      ; SF_TEXT = 0x1, SF_RTF = 0x2, SF_RTFNOOBJS = 0x3, SF_UNICODE = 0x10, SF_USECODEPAGE =	0x0020
      ; SFF_PLAINRTF = 0x4000, SFF_SELECTION = 0x8000
      ; UTF-8 = 65001, UTF-16 = 1200
      Static GetRTFCB := 0
      Flags := 0x4022 | (1200 << 16) | (Selection ? 0x8000 : 0)
      GetRTFCB := RegisterCallback("RichEdit.GetRTFProc")
      VarSetCapacity(ES, (A_PtrSize * 2) + 4, 0) ; EDITSTREAM structure
      NumPut(This.HWND, ES, 0, "Ptr")            ; dwCookie
      NumPut(GetRTFCB, ES, A_PtrSize + 4, "Ptr") ; pfnCallback
      SendMessage, 0x044A, %Flags%, &ES, , % "ahk_id " . This.HWND
      DllCall("Kernel32.dll\GlobalFree", "Ptr", GetRTFCB)
      Return This.GetRTFProc("Get", 0, 0)
   }
   ; -------------------------------------------------------------------------------------------------------------------
   GetRTFProc(pbBuff, cb, pcb) { ; Callback procedure for GetRTF
      ; left out first parameter dwCookie, will be passed in "This" when called by system
      Static RTF := ""
      If (cb > 0) {
         RTF .= StrGet(pbBuff, cb, "CP0")
         Return 0
      }
      If (pbBuff = "Get") {
         Out := RTF
         VarSetCapacity(RTF, 0)
         Return Out
      }
      Return 1
   }
   ; -------------------------------------------------------------------------------------------------------------------
   LoadRTF(FilePath, Selection := False) { ; Loads RTF file into the control.
      ; FilePath = file path
      ; Selection = False : whole contents (default)
      ; Selection = True  : current selection
      ; EM_STREAMIN = 0x0449
      ; SF_TEXT = 0x1, SF_RTF = 0x2, SF_RTFNOOBJS = 0x3, SF_UNICODE = 0x10, SF_USECODEPAGE =	0x0020
      ; SFF_PLAINRTF = 0x4000, SFF_SELECTION = 0x8000
      ; UTF-16 = 1200
      Static LoadRTFCB := 0, PCB := 0
      Flags := 0x4002 | (Selection ? 0x8000 : 0) ; | (1200 << 16)
      This.LoadRTFProc(FilePath, 0, 0)
      LoadRTFCB := RegisterCallback("RichEdit.LoadRTFProc")
      VarSetCapacity(ES, (A_PtrSize * 2) + 4, 0)  ; EDITSTREAM structure
      NumPut(This.HWND, ES, 0, "Ptr")             ; dwCookie
      NumPut(LoadRTFCB, ES, A_PtrSize + 4, "Ptr") ; pfnCallback
      SendMessage, 0x0449, %Flags%, &ES, , % "ahk_id " . This.HWND
      Result := ErrorLevel
      DllCall("Kernel32.dll\GlobalFree", "Ptr", LoadRTFCB)
      Return Result
   }
   ; -------------------------------------------------------------------------------------------------------------------
   LoadRTFProc(pbBuff, cb, pcb) { ; Callback procedure for LoadRTF
      ; Left out first parameter dwCookie, will be passed in "This" when called by system
      Static File := ""
      If (cb > 0) {
         If !IsObject(File)
            Return 1
         If File.AtEOF {
            File.Close()
            File := ""
            NumPut(0, pcb + 0, 0, "UInt")
            Return 0
         }
         NumPut(File.RawRead(pbBuff + 0, cb), pcb + 0, "UInt")
         Return 0
      }
      If !(pbBuff + 0) { ; a non-integer value was passed, should be the file name
         If !IsObject(File := FileOpen(pbBuff, "r"))
            Return False
         Return True
      }
      Return 1
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; Scrolling
   ; -------------------------------------------------------------------------------------------------------------------
   GetScrollPos() { ; Obtains the current scroll position.
      ; Returns on object with keys 'X' and 'Y' containing the scroll position.
      ; EM_GETSCROLLPOS = 0x04DD
      VarSetCapacity(PT, 8, 0)
      SendMessage, 0x04DD, 0, &PT, , % "ahk_id " . This.HWND
      Return {X: NumGet(PT, 0, "Int"), Y: NumGet(PT, 4, "Int")}
   }
   ; -------------------------------------------------------------------------------------------------------------------
   SetScrollPos(X, Y) { ; Scrolls the contents of a rich edit control to the specified point.
      ; X : x-position to scroll to.
      ; Y : y-position to scroll to.
      ; EM_SETSCROLLPOS = 0x04DE
      VarSetCapacity(PT, 8, 0)
      NumPut(X, PT, 0, "Int")
      NumPut(Y, PT, 4, "Int")
      SendMessage, 0x04DE, 0, &PT, , % "ahk_id " . This.HWND
      Return ErrorLevel
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ScrollCaret() { ; Scrolls the caret into view.
      ; EM_SCROLLCARET = 0x00B7
      SendMessage, 0x00B7, 0, 0, , % "ahk_id " . This.HWND
      Return True
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ShowScrollBar(SB, Mode := True) { ; Shows or hides one of the scroll bars of a rich edit control.
      ; SB   : Identifies which scroll bar to display: horizontal or vertical.
      ;        This parameter must be 1 (SB_VERT) or 0 (SB_HORZ).
      ; Mode : Specify TRUE to show the scroll bar and FALSE to hide it.
      ; EM_SHOWSCROLLBAR = 0x0460 (WM_USER + 96)
      SendMessage, 0x0460, %SB%, %Mode%, , % "ahk_id " . This.HWND
      Return True
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; Text and selection
   ; -------------------------------------------------------------------------------------------------------------------
   FindText(Find, Mode := "") { ; Finds Unicode text within a rich edit control.
      ; Find : Text to search for.
      ; Mode : Optional array containing one or more of the keys specified in 'FR'.
      ;        For details see http://msdn.microsoft.com/en-us/library/bb788013(v=vs.85).aspx.
      ; Returns True if the text was found; otherwise false.
      ; EM_FINDTEXTEXW = 0x047C, EM_SCROLLCARET = 0x00B7
      Static FR:= {DOWN: 1, WHOLEWORD: 2, MATCHCASE: 4}
      Flags := 0
      For Each, Value In Mode
         If FR.HasKey(Value)
            Flags |= FR[Value]
      Sel := This.GetSel()
      Min := (Flags & FR.DOWN) ? Sel.E : Sel.S
      Max := (Flags & FR.DOWN) ? -1 : 0
      VarSetCapacity(FTX, 16 + A_PtrSize, 0)
      NumPut(Min, FTX, 0, "Int")
      NumPut(Max, FTX, 4, "Int")
      NumPut(&Find, FTX, 8, "Ptr")
      
      SendMessage, 0x047C, %Flags%, &FTX, , % "ahk_id " . This.HWND
      S := NumGet(FTX, 8 + A_PtrSize, "Int"), E := NumGet(FTX, 12 + A_PtrSize, "Int")
      If (S = -1) && (E = -1)
         Return False
      This.SetSel(S, E)
      This.ScrollCaret()       
      Return 1
   }
   
   FindText_2(Find, Mode := "") { ; changed by Drozdman -> to start over after last found 
      ; EM_FINDTEXTEXW = 0x047C, EM_SCROLLCARET = 0x00B7
      Static FR:= {DOWN: 1, WHOLEWORD: 2, MATCHCASE: 4}
      Flags := 0
      For Each, Value In Mode
         If FR.HasKey(Value)
            Flags |= FR[Value]
      Sel := This.GetSel()
      Min := (Flags & FR.DOWN) ? Sel.E : Sel.S
      Max := (Flags & FR.DOWN) ? -1 : 0
      VarSetCapacity(FTX, 16 + A_PtrSize, 0)
      NumPut(Min, FTX, 0, "Int")
      NumPut(Max, FTX, 4, "Int")
      NumPut(&Find, FTX, 8, "Ptr")
      
      SendMessage, 0x047C, %Flags%, &FTX, , % "ahk_id " . This.HWND
      S := NumGet(FTX, 8 + A_PtrSize, "Int"), E := NumGet(FTX, 12 + A_PtrSize, "Int")
     ;If (S = -1) && (E = -1){         
         ;Return False          
 
      This.SetSel(S, E)
      This.ScrollCaret()
      Return
   }
   ; -------------------------------------------------------------------------------------------------------------------
   FindWordBreak(CharPos, Mode := "Left") { ; Finds the next word break before or after the specified character position
                                            ; or retrieves information about the character at that position.
      ; CharPos : Character position.
      ; Mode    : Can be one of the keys specified in 'WB'.
      ; Returns the character index of the word break or other values depending on 'Mode'.
      ; For details see http://msdn.microsoft.com/en-us/library/bb788018(v=vs.85).aspx.
      ; EM_FINDWORDBREAK = 0x044C (WM_USER + 76)
      Static WB := {LEFT: 0, RIGHT: 1, ISDELIMITER: 2, CLASSIFY: 3, MOVEWORDLEFT: 4, MOVEWORDRIGHT: 5, LEFTBREAK: 6
                  , RIGHTBREAK: 7}
      Option := WB.HasKey(Mode) ? WB[Mode] : 0
      SendMessage, 0x044C, %Option%, %CharPos%, , % "ahk_id " . This.HWND
      Return ErrorLevel
   }
   ; -------------------------------------------------------------------------------------------------------------------
   GetSelText() { ; Retrieves the currently selected text as plain text.
      ; Returns selected text.
      ; EM_GETSELTEXT = 0x043E, EM_EXGETSEL = 0x0434
      VarSetCapacity(CR, 8, 0)
      SendMessage, 0x0434, 0, &CR, , % "ahk_id " . This.HWND
      L := NumGet(CR, 4, "Int") - NumGet(CR, 0, "Int") + 1
      If (L > 1) {
         VarSetCapacity(Text, L * 2, 0)
         SendMessage, 0x043E, 0, &Text, , % "ahk_id " . This.HWND
         VarSetCapacity(Text, -1)
      }
      Return Text
   }
   ; -------------------------------------------------------------------------------------------------------------------
   GetSel() { ; Retrieves the starting and ending character positions of the selection in a rich edit control.
      ; Returns an object containing the keys S (start of selection) and E (end of selection)).
      ; EM_EXGETSEL = 0x0434
      VarSetCapacity(CR, 8, 0)
      SendMessage, 0x0434, 0, &CR, , % "ahk_id " . This.HWND
      Return {S: NumGet(CR, 0, "Int"), E: NumGet(CR, 4, "Int")}
   }
   ; -------------------------------------------------------------------------------------------------------------------
   GetText() { ; Gets the whole content of the control as plain text.
      ; EM_GETTEXTEX = 0x045E
      Text := ""
      If (Length := This.GetTextLen() * 2) {
         VarSetCapacity(GTX, (4 * 4) + (A_PtrSize * 2), 0) ; GETTEXTEX structure
         NumPut(Length + 2, GTX, 0, "UInt") ; cb
         NumPut(1200, GTX, 8, "UInt")       ; codepage = Unicode
         VarSetCapacity(Text, Length + 2, 0)
         SendMessage, 0x045E, &GTX, &Text, , % "ahk_id " . This.HWND
         VarSetCapacity(Text, -1)
      }
      Return Text
   }
   ; -------------------------------------------------------------------------------------------------------------------
   GetTextLen() { ; Calculates text length in various ways.
      ; EM_GETTEXTLENGTHEX = 0x045F
      VarSetCapacity(GTL, 8, 0)     ; GETTEXTLENGTHEX structure
      NumPut(1200, GTL, 4, "UInt")  ; codepage = Unicode
      SendMessage, 0x045F, &GTL, 0, , % "ahk_id " . This.HWND
      Return ErrorLevel
   }
   ; -------------------------------------------------------------------------------------------------------------------
   GetTextRange(Min, Max) { ; Retrieves a specified range of characters from a rich edit control.
      ; Min : Character position index immediately preceding the first character in the range.
      ;       Integer value to store as cpMin in the CHARRANGE structure.
      ; Max : Character position immediately following the last character in the range.
      ;       Integer value to store as cpMax in the CHARRANGE structure.
      ; CHARRANGE -> http://msdn.microsoft.com/en-us/library/bb787885(v=vs.85).aspx
      ; EM_GETTEXTRANGE = 0x044B
      If (Max <= Min)
         Return ""
      VarSetCapacity(Text, (Max - Min) << !!A_IsUnicode, 0)
      VarSetCapacity(TEXTRANGE, 16, 0) ; TEXTRANGE Struktur
      NumPut(Min, TEXTRANGE, 0, "UInt")
      NumPut(Max, TEXTRANGE, 4, "UInt")
      NumPut(&Text, TEXTRANGE, 8, "UPtr")
      SendMessage, 0x044B, 0, % &TEXTRANGE, , % "ahk_id " . This.HWND
      VarSetCapacity(Text, -1) ; Länge des Zeichenspeichers korrigieren 
      Return Text
   }
   ; -------------------------------------------------------------------------------------------------------------------
   HideSelection(Mode) { ; Hides or shows the selection.
      ; Mode : True to hide or False to show the selection.
      ; EM_HIDESELECTION = 0x043F (WM_USER + 63)
      SendMessage, 0x043F, %Mode%, 0, , % "ahk_id " . This.HWND
      Return True
   }
   ; -------------------------------------------------------------------------------------------------------------------
   LimitText(Limit)  { ; Sets an upper limit to the amount of text the user can type or paste into a rich edit control.
      ; Limit : Specifies the maximum amount of text that can be entered.
      ;         If this parameter is zero, the default maximum is used, which is 64K characters.
      ; EM_EXLIMITTEXT =  0x435 (WM_USER + 53)
      SendMessage, 0x0435, 0, %Limit%, , % "ahk_id " . This.HWND
      Return True
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ReplaceSel(Text := "") { ; Replaces the selected text with the specified text.
      ; EM_REPLACESEL = 0xC2
      SendMessage, 0xC2, 1, &Text, , % "ahk_id " . This.HWND
      Return ErrorLevel
   }
   ; -------------------------------------------------------------------------------------------------------------------
   SetText(ByRef Text := "", Mode := "") { ; Replaces the selection or the whole content of the control.
      ; Mode : Option flags. It can be any reasonable combination of the keys defined in 'ST'.
      ; For details see http://msdn.microsoft.com/en-us/library/bb774284(v=vs.85).aspx.
      ; EM_SETTEXTEX = 0x0461, CP_UNICODE = 1200
      ; ST_DEFAULT = 0, ST_KEEPUNDO = 1, ST_SELECTION = 2, ST_NEWCHARS = 4 ???
      Static ST := {DEFAULT: 0, KEEPUNDO: 1, SELECTION: 2}
      Flags := 0
      For Each, Value In Mode
         If ST.HasKey(Value)
            Flags |= ST[Value]
      CP := 1200
      BufAddr := &Text
      ; RTF formatted text has to be passed as ANSI!!!
      If (SubStr(Text, 1, 5) = "{\rtf") || (SubStr(Text, 1, 5) = "{urtf") {
         Len := StrPut(Text, "CP0")
         VarSetCapacity(Buf, Len, 0)
         StrPut(Text, &Buf, "CP0")
         BufAddr := &Buf
         CP := 0
      }
      VarSetCapacity(STX, 8, 0)     ; SETTEXTEX structure
      NumPut(Flags, STX, 0, "UInt") ; flags
      NumPut(CP  ,  STX, 4, "UInt") ; codepage
      SendMessage, 0x0461, &STX, BufAddr, , % "ahk_id " . This.HWND
      Return ErrorLevel
   }
   ; -------------------------------------------------------------------------------------------------------------------
   SetSel(Start, End) { ; Selects a range of characters.
      ; Start : zero-based start index
      ; End   : zero-beased end index (-1 = end of text))
      ; EM_EXSETSEL = 0x0437
      VarSetCapacity(CR, 8, 0)
      NumPut(Start, CR, 0, "Int")
      NumPut(End,   CR, 4, "Int")
      SendMessage, 0x0437, 0, &CR, , % "ahk_id " . This.HWND
      Return ErrorLevel
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; Appearance, styles, and options
   ; -------------------------------------------------------------------------------------------------------------------
   AutoURL(On) { ; Turn AutoURLDetection on/off
      ; EM_AUTOURLDETECT = 0x45B
      SendMessage, 0x45B, % !!On, 0, , % "ahk_id " . This.HWND
      WinSet, Redraw, , % "ahk_id " . This.HWND
      Return ErrorLevel
   }
   ; -------------------------------------------------------------------------------------------------------------------
   GetOptions() { ; Retrieves rich edit control options.
      ; Returns an array of currently the set options as the keys defined in 'ECO'.
      ; For details see http://msdn.microsoft.com/en-us/library/bb774178(v=vs.85).aspx.
      ; EM_GETOPTIONS = 0x044E
      Static ECO := {AUTOWORDSELECTION: 0x01, AUTOVSCROLL: 0x40, AUTOHSCROLL: 0x80, NOHIDESEL: 0x100
                   , READONLY: 0x800, WANTRETURN: 0x1000, SAVESEL: 0x8000, SELECTIONBAR: 0x01000000
                   , VERTICAL: 0x400000}
      SendMessage, 0x044E, 0, 0, , % "ahk_id " . This.HWND
      O := ErrorLevel
      Options := []
      For Key, Value In ECO
         If (O & Value)
            Options.Insert(Key)
      Return Options
   }
   ; -------------------------------------------------------------------------------------------------------------------
   GetStyles() { ; Retrieves the current edit style flags.
      ; Returns an object containing keys as defined in 'SES'.
      ; For details see http://msdn.microsoft.com/en-us/library/bb788031(v=vs.85).aspx.
      ; EM_GETEDITSTYLE	= 0x04CD (WM_USER + 205)
      Static SES := {1: "EMULATESYSEDIT", 1: "BEEPONMAXTEXT", 4: "EXTENDBACKCOLOR", 32: "NOXLTSYMBOLRANGE", 64: "USEAIMM"
                   , 128: "NOIME", 256: "ALLOWBEEPS", 512: "UPPERCASE", 1024: "LOWERCASE", 2048: "NOINPUTSEQUENCECHK"
                   , 4096: "BIDI", 8192: "SCROLLONKILLFOCUS", 16384: "XLTCRCRLFTOCR", 32768: "DRAFTMODE"
                   , 0x0010000: "USECTF", 0x0020000: "HIDEGRIDLINES", 0x0040000: "USEATFONT", 0x0080000: "CUSTOMLOOK"
                   , 0x0100000: "LBSCROLLNOTIFY", 0x0200000: "CTFALLOWEMBED", 0x0400000: "CTFALLOWSMARTTAG"
                   , 0x0800000: "CTFALLOWPROOFING"}
      SendMessage, 0x04CD, 0, 0, , % "ahk_id " . This.HWND
      Result := ErrorLevel
      Styles := []
      For Key, Value In SES
         If (Result & Key)
            Styles.Insert(Value)
      Return Styles
   }
   ; -------------------------------------------------------------------------------------------------------------------
   GetZoom() { ; Gets the current zoom ratio.
      ; Returns the zoom ratio in percent.
      ; EM_GETZOOM = 0x04E0
      VarSetCapacity(N, 4, 0), VarSetCapacity(D, 4, 0)
      SendMessage, 0x04E0, &N, &D, , % "ahk_id " . This.HWND
      N := NumGet(N, 0, "Int"), D := NumGet(D, 0, "Int")
      Return (N = 0) && (D = 0) ? 100 : Round(N / D * 100)
   }
   ; -------------------------------------------------------------------------------------------------------------------
   SetBkgndColor(Color) { ; Sets the background color.
      ; Color : RGB integer value or HTML color name or
      ;         "Auto" to reset to system default color.
      ; Returns the prior background color.
      ; EM_SETBKGNDCOLOR = 0x0443
      If (Color = "Auto")
         System := True, Color := 0
      Else
         System := False, Color := This.GetBGR(Color)
      SendMessage, 0x0443, %System%, %Color%, , % "ahk_id " . This.HWND
      Return This.GetRGB(ErrorLevel)
   }
   ; -------------------------------------------------------------------------------------------------------------------
   SetOptions(Options, Mode := "SET") { ; Sets the options for a rich edit control.
      ; Options : Array of options as the keys defined in 'ECO'.
      ; Mode    : Settings mode: SET, OR, AND, XOR
      ; For details see http://msdn.microsoft.com/en-us/library/bb774254(v=vs.85).aspx.
      ; EM_SETOPTIONS = 0x044D
      Static ECO := {AUTOWORDSELECTION: 0x01, AUTOVSCROLL: 0x40, AUTOHSCROLL: 0x80, NOHIDESEL: 0x100, READONLY: 0x800
                   , WANTRETURN: 0x1000, SAVESEL: 0x8000, SELECTIONBAR: 0x01000000, VERTICAL: 0x400000}
           , ECOOP := {SET: 0x01, OR: 0x02, AND: 0x03, XOR: 0x04}
      If !ECOOP.HasKey(Mode)
         Return False
      O := 0
      For Each, Option In Options {
         If ECO.HasKey(Option)
            O |= ECO[Option]
         Else
            Return False
      }
      MsgBox,4096,, % ECOOP[Mode]  "`n" O
      SendMessage, 0x044D, % ECOOP[Mode], %O%, , % "ahk_id " . This.HWND
      Return ErrorLevel
   }
   ; -------------------------------------------------------------------------------------------------------------------
   SetStyles(Styles) { ; Sets the current edit style flags for a rich edit control.
      ; Styles : Object containing on or more of the keys defined in 'SES'.
      ;          If the value is 0 the style will be removed, otherwise it will be added.
      ; For details see http://msdn.microsoft.com/en-us/library/bb774236(v=vs.85).aspx.
      ; EM_SETEDITSTYLE	= 0x04CC (WM_USER + 204)
      Static SES = {EMULATESYSEDIT: 1, BEEPONMAXTEXT: 2, EXTENDBACKCOLOR: 4, NOXLTSYMBOLRANGE: 32, USEAIMM: 64
                  , NOIME: 128, ALLOWBEEPS: 256, UPPERCASE: 512, LOWERCASE: 1024, NOINPUTSEQUENCECHK: 2048
                  , BIDI: 4096, SCROLLONKILLFOCUS: 8192, XLTCRCRLFTOCR: 16384, DRAFTMODE: 32768
                  , USECTF: 0x0010000, HIDEGRIDLINES: 0x0020000, USEATFONT: 0x0040000, CUSTOMLOOK: 0x0080000
                  , LBSCROLLNOTIFY: 0x0100000, CTFALLOWEMBED: 0x0200000, CTFALLOWSMARTTAG: 0x0400000
                  , CTFALLOWPROOFING: 0x0800000}
      Flags := Mask := 0
      For Style, Value In Styles {
         If SES.HasKey(Style) {
            Mask |= SES[Style]
            If (Value <> 0)
               Flags |= SES[Style]
         }
      }
      If (Mask) {
         SendMessage, 0x04CC, %Flags%, %Mask%, ,, % "ahk_id " . This.HWND
         Return ErrorLevel
      }
      Return False
   }
   ; -------------------------------------------------------------------------------------------------------------------
   SetZoom(Ratio := "") { ; Sets the zoom ratio of a rich edit control.
      ; Ratio : Float value between 100/64 and 6400; a ratio of 0 turns zooming off.
      ; EM_SETZOOM = 0x4E1
      SendMessage, 0x4E1, % (Ratio > 0 ? Ratio : 100), 100, , % "ahk_id " . This.HWND
      Return ErrorLevel
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; Copy, paste, etc.
   ; -------------------------------------------------------------------------------------------------------------------
   CanRedo() { ; Determines whether there are any actions in the control redo queue.
      ; EM_CANREDO = 0x0455 (WM_USER + 85)
      SendMessage, 0x0455, 0, 0, , % "ahk_id " . This.HWND
      Return ErrorLevel
   }
   ; -------------------------------------------------------------------------------------------------------------------
   CanUndo() { ; Determines whether there are any actions in an edit control's undo queue.
      ; EM_CANUNDO = 0x00C6
      SendMessage, 0x00C6, 0, 0, , % "ahk_id " . This.HWND
      Return ErrorLevel
   }
   ; -------------------------------------------------------------------------------------------------------------------
   Clear() {
      ; WM_CLEAR = 0x303
      SendMessage, 0x303, 0, 0, , % "ahk_id " . This.HWND
      Return ErrorLevel
   }
   ; -------------------------------------------------------------------------------------------------------------------
   Copy() {
      ; WM_COPY = 0x301
      SendMessage, 0x301, 0, 0, , % "ahk_id " . This.HWND
      Return ErrorLevel
   }
   ; -------------------------------------------------------------------------------------------------------------------
   Cut() {
      ; WM_CUT = 0x300
      SendMessage, 0x300, 0, 0, , % "ahk_id " . This.HWND
      Return ErrorLevel
   }
   ; -------------------------------------------------------------------------------------------------------------------
   Paste() {
      ; WM_PASTE = 0x302
      SendMessage, 0x302, 0, 0, , % "ahk_id " . This.HWND
      Return ErrorLevel
   }
   ; -------------------------------------------------------------------------------------------------------------------
   Redo() {
      ; EM_REDO := 0x454
      SendMessage, 0x454, 0, 0, , % "ahk_id " . This.HWND
      Return ErrorLevel
   }
   ; -------------------------------------------------------------------------------------------------------------------
   Undo() {
      ; EM_UNDO = 0xC7
      SendMessage, 0xC7, 0, 0, , % "ahk_id " . This.HWND
      Return ErrorLevel
   }
   ; -------------------------------------------------------------------------------------------------------------------
   SelAll() {
      ; Select all
      Return This.SetSel(0, -1)
   }
   ; -------------------------------------------------------------------------------------------------------------------
   Deselect() {
      ; Deselect all
      Sel := This.GetSel()
      Return This.SetSel(Sel.S, Sel.S)
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; Font & colors
   ; -------------------------------------------------------------------------------------------------------------------
   ChangeFontSize(Diff) { ; Change font size
      ; Diff : any positive or negative integer, positive values are treated as +1, negative as -1.
      ; Returns new size.
      ; EM_SETFONTSIZE = 0x04DF
      ; Font size changes by 1 in the range 4 - 11 pt, by 2 for 12 - 28 pt, afterward to 36 pt, 48 pt, 72 pt, 80 pt,
      ; and by 10 for > 80 pt. The maximum value is 160 pt, the minimum is 4 pt
      Font := This.GetFont()
      If (Diff > 0 && Font.Size < 160) || (Diff < 0 && Font.Size > 4)
         SendMessage, 0x04DF, % (Diff > 0 ? 1 : -1), 0, , % "ahk_id " . This.HWND
      Else
         Return False
      Font := This.GetFont()
      Return Font.Size
   }
   ; -------------------------------------------------------------------------------------------------------------------
   GetFont(Default := False) { ; Get current font
      ; Set Default to True to get the default font.
      ; Returns an object containing current options (see SetFont())
      ; EM_GETCHARFORMAT = 0x043A
      ; BOLD_FONTTYPE = 0x0100, ITALIC_FONTTYPE = 0x0200
      ; CFM_BOLD = 1, CFM_ITALIC = 2, CFM_UNDERLINE = 4, CFM_STRIKEOUT = 8, CFM_PROTECTED = 16, CFM_SUBSCRIPT = 0x30000
      ; CFM_BACKCOLOR = 0x04000000, CFM_CHARSET := 0x08000000, CFM_FACE = 0x20000000, CFM_COLOR = 0x40000000
      ; CFM_SIZE = 0x80000000
      ; CFE_SUBSCRIPT = 0x10000, CFE_SUPERSCRIPT = 0x20000, CFE_AUTOBACKCOLOR = 0x04000000, CFE_AUTOCOLOR = 0x40000000
      ; SCF_SELECTION = 1
      Static Mask := 0xEC03001F
      Static Effects := 0xEC000000
      CF2 := New This.CF2
      CF2.Mask := Mask
      CF2.Effects := Effects
      SendMessage, 0x043A, % (Default ? 0 : 1), % CF2.CF2, , % "ahk_id " . This.HWND
      Font := {}
      Font.Name := CF2.FaceName
      Font.Size := CF2.Height / 20
      CFS := CF2.Effects
      Style := (CFS & 1 ? "B" : "") . (CFS & 2 ? "I" : "") . (CFS & 4 ? "U" : "") . (CFS & 8 ? "S" : "")
             . (CFS & 0x10000 ? "L" : "") . (CFS & 0x20000 ? "H" : "") . (CFS & 16 ? "P" : "")
      Font.Style := Style = "" ? "N" : Style
      Font.Color := This.GetRGB(CF2.TextColor)
      If (CF2.Effects & 0x04000000)
         Font.BkColor := "Auto"
      Else
         Font.BkColor := This.GetRGB(CF2.BackColor)
      Font.CharSet := CF2.CharSet
      Return Font
   }
   ; -------------------------------------------------------------------------------------------------------------------
   SetDefaultFont(Font := "") { ; Set default font
      ; Font : Optional object - see SetFont().
      If IsObject(Font) {
         For Key, Value In Font
            If This.DefFont.HasKey(Key)
               This.DefFont[Key] := Value
      }
      Return This.SetFont(This.DefFont)
   }
   ; -------------------------------------------------------------------------------------------------------------------
   SetFont(Font) { ; Set current/default font
      ; Font : Object containing the following keys
      ;        Name    : optional font name
      ;        Size    : optional font size in points
      ;        Style   : optional string of one or more of the following styles
      ;                  B = bold, I = italic, U = underline, S = strikeout, L = subscript
      ;                  H = superschript, P = protected, N = normal
      ;        Color   : optional text color as RGB integer value or HTML color name
      ;                  "Auto" for "automatic" (system's default) color
      ;        BkColor : optional text background color (see Color)
      ;                  "Auto" for "automatic" (system's default) background color
      ;        CharSet : optional font character set
      ;                  1 = DEFAULT_CHARSET, 2 = SYMBOL_CHARSET
      ;        Empty parameters preserve the corresponding properties
      ; EM_SETCHARFORMAT = 0x0444
      ; SCF_DEFAULT = 0, SCF_SELECTION = 1
      CF2 := New This.CF2
      Mask := Effects := 0
      If (Font.Name != "") {
         Mask |= 0x20000000, Effects |= 0x20000000 ; CFM_FACE, CFE_FACE
         CF2.FaceName := Font.Name
      }
      Size := Font.Size
      If (Size != "") {
         If (Size < 161)
            Size *= 20
         Mask |= 0x80000000, Effects |= 0x80000000 ; CFM_SIZE, CFE_SIZE
         CF2.Height := Size
      }
      If (Font.Style != "") {
         Mask |= 0x3001F           ; all font styles
         If InStr(Font.Style, "B")
            Effects |= 1           ; CFE_BOLD
         If InStr(Font.Style, "I")
            Effects |= 2           ; CFE_ITALIC
         If InStr(Font.Style, "U")
            Effects |= 4           ; CFE_UNDERLINE
         If InStr(Font.Style, "S")
            Effects |= 8           ; CFE_STRIKEOUT
         If InStr(Font.Style, "P")
            Effects |= 16          ; CFE_PROTECTED
         If InStr(Font.Style, "L")
            Effects |= 0x10000     ; CFE_SUBSCRIPT
         If InStr(Font.Style, "H")
            Effects |= 0x20000     ; CFE_SUPERSCRIPT
      }
      If (Font.Color != "") {
         Mask |= 0x40000000        ; CFM_COLOR
         If (Font.Color = "Auto")
            Effects |= 0x40000000  ; CFE_AUTOCOLOR
         Else
            CF2.TextColor := This.GetBGR(Font.Color)
      }
      If (Font.BkColor != "") {
         Mask |= 0x04000000        ; CFM_BACKCOLOR
         If (Font.BkColor = "Auto")
            Effects |= 0x04000000  ; CFE_AUTOBACKCOLOR
         Else
            CF2.BackColor := This.GetBGR(Font.BkColor)
      }
      If (Font.CharSet != "") {
         Mask |= 0x08000000, Effects |= 0x08000000 ; CFM_CHARSET, CFE_CHARSET
         CF2.CharSet := Font.CharSet = 2 ? 2 : 1 ; SYMBOL|DEFAULT
      }
      If (Mask != 0) {
         Mode := Font.Default ? 0 : 1
         CF2.Mask := Mask
         CF2.Effects := Effects
         SendMessage, 0x0444, %Mode%, % CF2.CF2, , % "ahk_id " . This.HWND
         Return ErrorLevel
      }
      Return False
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ToggleFontStyle(Style) { ; Toggle single font style
      ; Style : one of the following styles
      ;         B = bold, I = italic, U = underline, S = strikeout, L = subscript, H = superschript, P = protected,
      ;         N = normal (reset all other styles)
      ; EM_GETCHARFORMAT = 0x043A, EM_SETCHARFORMAT = 0x0444
      ; CFM_BOLD = 1, CFM_ITALIC = 2, CFM_UNDERLINE = 4, CFM_STRIKEOUT = 8, CFM_PROTECTED = 16, CFM_SUBSCRIPT = 0x30000
      ; CFE_SUBSCRIPT = 0x10000, CFE_SUPERSCRIPT = 0x20000, SCF_SELECTION = 1
      CF2 :=This.GetCharFormat()
      CF2.Mask := 0x3001F ; FontStyles
      If (Style = "N")
         CF2.Effects := 0
      Else
         CF2.Effects ^= Style = "B" ? 1 : Style = "I" ? 2 : Style = "U" ? 4 : Style = "S" ? 8
                      : Style = "H" ? 0x20000 : Style = "L" ? 0x10000 : 0
      SendMessage, 0x0444, 1, % CF2.CF2, , % "ahk_id " . This.HWND
      Return ErrorLevel
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; Paragraph formatting
   ; -------------------------------------------------------------------------------------------------------------------
   AlignText(Align := 1) { ; Set paragraph's alignment
      ; Note: Values greater 3 doesn't seem to work though they should as documented
      ; Align: may contain one of the following numbers:
      ;        PFA_LEFT             1
      ;        PFA_RIGHT            2
      ;        PFA_CENTER           3
      ;        PFA_JUSTIFY          4 // New paragraph-alignment option 2.0 (*)
      ;        PFA_FULL_INTERWORD   4 // These are supported in 3.0 with advanced
      ;        PFA_FULL_INTERLETTER 5 // typography enabled
      ;        PFA_FULL_SCALED      6
      ;        PFA_FULL_GLYPHS      7
      ;        PFA_SNAP_GRID        8
      ; EM_SETPARAFORMAT = 0x0447, PFM_ALIGNMENT = 0x08
      If (Align >= 1) && (ALign <= 8) {
         PF2 := New This.PF2    ; PARAFORMAT2 struct
         PF2.Mask := 0x08       ; dwMask
         PF2.Alignment := Align ; wAlignment
         SendMessage, 0x0447, 0, % PF2.PF2, , % "ahk_id " . This.HWND
         Return True
      }
      Return False
   }
   ; -------------------------------------------------------------------------------------------------------------------
   SetBorder(Widths, Styles) { ; Set paragraph's borders
      ; Borders are not displayed in RichEdit, so the call of this function has no visible result.
      ; Even WordPad distributed with Win7 does not show them, but e.g. Word 2007 does.
      ; Widths : Array of the 4 border widths in the range of 1 - 15 in order left, top, right, bottom; zero = no border
      ; Styles : Array of the 4 border styles in the range of 0 - 7 in order left, top, right, bottom (see remarks)
      ; Note:
      ; The description on MSDN at http://msdn.microsoft.com/en-us/library/bb787942(v=vs.85).aspx is wrong!
      ; To set borders you have to put the border width into the related nibble (4 Bits) of wBorderWidth
      ; (in order: left (0 - 3), top (4 - 7), right (8 - 11), and bottom (12 - 15). The values are interpreted as
      ; half points (i.e. 10 twips). Border styles are set in the related nibbles of wBorders.
      ; Valid styles seem to be:
      ;     0 : \brdrdash (dashes)
      ;     1 : \brdrdashsm (small dashes)
      ;     2 : \brdrdb (double line)
      ;     3 : \brdrdot (dotted line)
      ;     4 : \brdrhair (single/hair line)
      ;     5 : \brdrs ? looks like 3
      ;     6 : \brdrth ? looks like 3
      ;     7 : \brdrtriple (triple line)
      ; EM_SETPARAFORMAT = 0x0447, PFM_BORDER = 0x800
      If !IsObject(Widths)
         Return False
      W := S := 0
      For I, V In Widths {
         If (V)
            W |= V << ((A_Index - 1) * 4)
         If Styles[I]
            S |= Styles[I] << ((A_Index - 1) * 4)
      }
      PF2 := New This.PF2
      PF2.Mask := 0x800
      PF2.BorderWidth := W
      PF2.Borders := S
      SendMessage, 0x0447, 0, % PF2.PF2, , % "ahk_id " . This.HWND
      Return ErrorLevel
   }
   ; -------------------------------------------------------------------------------------------------------------------
   SetLineSpacing(Lines) { ; Sets paragraph's line spacing.
      ; Lines : number of lines as integer or float.
      ; SpacingRule = 5:
      ; The value of dyLineSpacing / 20 is the spacing, in lines, from one line to the next. Thus, setting
      ; dyLineSpacing to 20 produces single-spaced text, 40 is double spaced, 60 is triple spaced, and so on.
      ; EM_SETPARAFORMAT = 0x0447, PFM_LINESPACING = 0x100
      PF2 := New This.PF2
      PF2.Mask := 0x100
      PF2.LineSpacing := Abs(Lines) * 20
      PF2.LineSpacingRule := 5
      SendMessage, 0x0447, 0, % PF2.PF2, , % "ahk_id " . This.HWND
      Return ErrorLevel
   }
   ; -------------------------------------------------------------------------------------------------------------------
   SetParaIndent(Indent := "Reset") { ; Sets space left/right of the paragraph.
      ; Indent : Object containing up to three keys:
      ;          - Start  : Optional - Absolute indentation of the paragraph's first line.
      ;          - Right  : Optional - Indentation of the right side of the paragraph, relative to the right margin.
      ;          - Offset : Optional - Indentation of the second and subsequent lines, relative to the indentation
      ;                                of the first line.
      ;          Values are interpreted as centimeters/inches depending on the user's locale measurement settings.
      ;          Call without passing a parameter to reset indentation.
      ; EM_SETPARAFORMAT = 0x0447
      ; PFM_STARTINDENT  = 0x0001
      ; PFM_RIGHTINDENT  = 0x0002
      ; PFM_OFFSET       = 0x0004
      Static PFM := {STARTINDENT: 0x01, RIGHTINDENT: 0x02, OFFSET: 0x04}
      Measurement := This.GetMeasurement()
      PF2 := New This.PF2
      If (Indent = "Reset")
         PF2.Mask := 0x07 ; reset indentation
      If !IsObject(Indent)
         Return False
      Else {
         If (Indent.HasKey("STARTINDENT")) {
            PF2.Mask |= PFM.Start
            PF2.StartIndent := Round((Indent.Start / Measurement) * 1440)
         }
         If (Indent.HasKey("RIGHTINDENT")) {
            PF2.Mask |= PFM.Right
            PF2.RightIndent := Round((Indent.Right / Measurement) * 1440)
         }
         If (Indent.HasKey("OFFSET")) {
            PF2.Mask |= PFM.Offset
            PF2.Offset := Round((Indent.Offset / Measurement) * 1440)
         }
      }
      If (PF2.Mask) {
         SendMessage, 0x0447, 0, % PF2.PF2, , % "ahk_id " . This.HWND
         Return ErrorLevel
      }
      Return False
   }
   ; -------------------------------------------------------------------------------------------------------------------
   SetParaNumbering(Numbering := "Reset") {
      ; Numbering : Object containing up to four keys:
      ;             - Type  : Options used for bulleted or numbered paragraphs.
      ;             - Style : Optional - Numbering style used with numbered paragraphs.
      ;             - Tab   : Optional - Minimum space between a paragraph number and the paragraph text.
      ;             - Start : Optional - Sequence number used for numbered paragraphs (e.g. 3 for C or III)
      ;             Tab is interpreted as centimeters/inches depending on the user's locale measurement settings.
      ;             Call without passing a parameter to reset numbering.
      ; EM_SETPARAFORMAT = 0x0447
      ; PARAFORMAT numbering options
      ; PFN_BULLET   1 ; tomListBullet
      ; PFN_ARABIC   2 ; tomListNumberAsArabic:   0, 1, 2,	...
      ; PFN_LCLETTER 3 ; tomListNumberAsLCLetter: a, b, c,	...
      ; PFN_UCLETTER 4 ; tomListNumberAsUCLetter: A, B, C,	...
      ; PFN_LCROMAN  5 ; tomListNumberAsLCRoman:  i, ii, iii,	...
      ; PFN_UCROMAN  6 ; tomListNumberAsUCRoman:  I, II, III,	...
      ; PARAFORMAT2 wNumberingStyle options
      ; PFNS_PAREN     0x0000 ; default, e.g.,                 1)
      ; PFNS_PARENS    0x0100 ; tomListParentheses/256, e.g., (1)
      ; PFNS_PERIOD    0x0200 ; tomListPeriod/256, e.g.,       1.
      ; PFNS_PLAIN     0x0300 ; tomListPlain/256, e.g.,        1
      ; PFNS_NONUMBER  0x0400 ; used for continuation w/o number
      ; PFNS_NEWNUMBER 0x8000 ; start new number with wNumberingStart
      ; PFM_NUMBERING      0x0020
      ; PFM_NUMBERINGSTYLE 0x2000
      ; PFM_NUMBERINGTAB   0x4000
      ; PFM_NUMBERINGSTART 0x8000
      Static PFM := {Type: 0x0020, Style: 0x2000, Tab: 0x4000, Start: 0x8000}
      Static PFN := {Bullet: 1, Arabic: 2, LCLetter: 3, UCLetter: 4, LCRoman: 5, UCRoman: 6}
      Static PFNS := {Paren: 0x0000, Parens: 0x0100, Period: 0x0200, Plain: 0x0300, None: 0x0400, New: 0x8000}
      PF2 := New This.PF2
      If (Numbering = "Reset")
         PF2.Mask := 0xE020
      Else If !IsObject(Numbering)
         Return False
      Else {
         If (Numbering.HasKey("Type")) {
            PF2.Mask |= PFM.Type
            PF2.Numbering := PFN[Numbering.Type]
         }
         If (Numbering.HasKey("Style")) {
            PF2.Mask |= PFM.Style
            PF2.NumberingStyle := PFNS[Numbering.Style]
         }
         If (Numbering.HasKey("Tab")) {
            PF2.Mask |= PFM.Tab
            PF2.NumberingTab := Round((Numbering.Tab / This.GetMeasurement()) * 1440)
         }
         If (Numbering.HasKey("Start")) {
            PF2.Mask |= PFM.Start
            PF2.NumberingStart := Numbering.Start
         }
      }
      If (PF2.Mask) {
         SendMessage, 0x0447, 0, % PF2.PF2, , % "ahk_id " . This.HWND
         Return ErrorLevel
      }
      Return False
   }
   ; -------------------------------------------------------------------------------------------------------------------
   SetParaSpacing(Spacing := "Reset") { ; Set space before / after the paragraph
      ; Spacing : Object containing one or two keys:
      ;           - Before : additional space before the paragraph in points
      ;           - After  : additional space after the paragraph in points
      ;           Call without passing a parameter to reset spacing to zero.
      ; EM_SETPARAFORMAT = 0x0447
      ; PFM_SPACEBEFORE  = 0x0040
      ; PFM_SPACEAFTER   = 0x0080
      Static PFM := {Before: 0x40, After: 0x80}
      PF2 := New This.PF2
      If (Spacing = "Reset")
         PF2.Mask := 0xC0 ; reset spacing
      Else If !IsObject(Spacing)
         Return False
      Else {
         If (Spacing.Before >= 0) {
            PF2.Mask |= PFM.Before
            PF2.SpaceBefore := Round(Spacing.Before * 20)
         }
         If (Spacing.After >= 0) {
            PF2.Mask |= PFM.After
            PF2.SpaceAfter := Round(Spacing.After * 20)
         }
      }
      If (PF2.Mask) {
         SendMessage, 0x0447, 0, % PF2.PF2, , % "ahk_id " . This.HWND
         Return ErrorLevel
      }
      Return False
   }
   ; -------------------------------------------------------------------------------------------------------------------
   SetDefaultTabs(Distance) { ; Set default tabstops
      ; Distance will be interpreted as inches or centimeters depending on the current user's locale.
      ; EM_SETTABSTOPS = 0xCB
      Static DUI := 64      ; dialog units per inch
           , MinTab := 0.20 ; minimal tab distance
           , MaxTab := 3.00 ; maximal tab distance
      IM := This.GetMeasurement()
      StringReplace, Distance, Distance, `,, .
      Distance := Round(Distance / IM, 2)
      If (Distance < MinTab)
         Distance := MinTab
      If (Distance > MaxTab)
         Distance := MaxTab
      VarSetCapacity(TabStops, 4, 0)
      NumPut(Round(DUI * Distance), TabStops, "Int")
      SendMessage, 0xCB, 1, &TabStops, , % "ahk_id " . This.HWND
      Result := ErrorLevel
      DllCall("User32.dll\UpdateWindow", "Ptr", This.HWND)
      Return Result
   }
   ; -------------------------------------------------------------------------------------------------------------------
   SetTabStops(TabStops := "Reset") { ; Set paragraph's tabstobs
      ; TabStops is an object containing the integer position as hundredth of inches/centimeters as keys
      ; and the alignment ("L", "C", "R", or "D") as values.
      ; The position will be interpreted as hundredth of inches or centimeters depending on the current user's locale.
      ; Call without passing a  parameter to reset to default tabs.
      ; EM_SETPARAFORMAT = 0x0447, PFM_TABSTOPS = 0x10
      Static MinT := 30                ; minimal tabstop in hundredth of inches
      Static MaxT := 830               ; maximal tabstop in hundredth of inches
      Static Align := {L: 0x00000000   ; left aligned (default)
                     , C: 0x01000000   ; centered
                     , R: 0x02000000   ; right aligned
                     , D: 0x03000000}  ; decimal tabstop
      Static MAX_TAB_STOPS := 32
      IC := This.GetMeasurement()
      PF2 := New This.PF2
      PF2.Mask := 0x10
      If (TabStops = "Reset") {
         SendMessage, 0x0447, 0, % PF2.PF2, , % "ahk_id " . This.HWND
         Return !!(ErrorLevel)
      }
      If !IsObject(TabStops)
         Return False
      TabCount := 0
      Tabs  := []
      For Position, Alignment In TabStops {
         Position /= IC
         If (Position < MinT) Or (Position > MaxT)
         Or !Align.HasKey(Alignment) Or (A_Index > MAX_TAB_STOPS)
            Return False
         Tabs[A_Index] := (Align[Alignment] | Round((Position / 100) * 1440))
         TabCount := A_Index
      }
      If (TabCount) {
         PF2.TabCount := TabCount
         PF2.Tabs := Tabs
         SendMessage, 0x0447, 0, % PF2.PF2, , % "ahk_id " . This.HWND
         Return ErrorLevel
      }
      Return False
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; Line handling
   ; -------------------------------------------------------------------------------------------------------------------
   GetLineCount() { ; Get the total number of lines

      ; EM_GETLINECOUNT = 0xBA
      SendMessage, 0xBA, 0, 0, , % "ahk_id " . This.HWND
      Return ErrorLevel
   }
   ; -------------------------------------------------------------------------------------------------------------------
   GetCaretLine() { ; Get the line containing the caret
      ; EM_LINEINDEX = 0xBB, EM_EXLINEFROMCHAR = 0x0436
      SendMessage, 0xBB, -1, 0, , % "ahk_id " . This.HWND
      SendMessage, 0x0436, 0, %ErrorLevel%, , % "ahk_id " . This.HWND
      Return ErrorLevel + 1
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; Statistics
   ; -------------------------------------------------------------------------------------------------------------------
   GetStatistics() { ; Get some statistic values
      ; Get the line containing the caret, it's position in this line, the total amount of lines, the absulute caret
      ; position and the total amount of characters.
      ; EM_GETSEL = 0xB0, EM_LINEFROMCHAR = 0xC9, EM_LINEINDEX = 0xBB, EM_GETLINECOUNT = 0xBA
      Stats := {}
      VarSetCapacity(GTL, 8, 0)  ; GETTEXTLENGTHEX structure
      SB := 0
      SendMessage, 0xB0, &SB, 0, , % "ahk_id " . This.HWND
      SB := NumGet(SB, 0, "UInt") + 1
      SendMessage, 0xBB, -1, 0, , % "ahk_id " . This.HWND
      Stats.LinePos := SB - ErrorLevel
      SendMessage, 0xC9, -1, 0, , % "ahk_id " . This.HWND
      Stats.Line := ErrorLevel + 1
      SendMessage, 0xBA, 0, 0, , % "ahk_id " . This.HWND
      Stats.LineCount := ErrorLevel
      Stats.CharCount := This.GetTextLen()
      Return Stats
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; Layout
   ; -------------------------------------------------------------------------------------------------------------------
   WordWrap(On) { ; Turn wordwrapping on/off
      ; EM_SCROLLCARET = 0xB7, EM_SETTARGETDEVICE = 0x0448
      Sel := This.GetSel()
      SendMessage, 0x0448, 0, % (On ? 0 : -1), , % "ahk_id " . This.HWND
      This.SetSel(Sel.S, Sel.E)
      SendMessage, 0xB7, 0, 0,  % "ahk_id " . This.HWND
      Return On
   }
   ; -------------------------------------------------------------------------------------------------------------------
   WYSIWYG(On) { ; Show control as printed (WYSIWYG)
      ; Text measuring is based on the default printer's capacities, thus changing the printer may produce different
      ; results. See remarks/comments in Print() also.
      ; EM_SCROLLCARET = 0xB7, EM_SETTARGETDEVICE = 0x0448
      ; PD_RETURNDC = 0x0100, PD_RETURNDEFAULT = 0x0400
      Static PDC := 0
      Static PD_Size := (A_PtrSize = 4 ? 66 : 120)
      Static OffFlags := A_PtrSize * 5
      Sel := This.GetSel()
      If !(On) {
         DllCall("User32.dll\LockWindowUpdate", "Ptr", This.HWND)
         DllCall("Gdi32.dll\DeleteDC", "Ptr", PDC)
         SendMessage, 0x0448, 0, -1, , % "ahk_id " . This.HWND
         This.SetSel(Sel.S, Sel.E)
         SendMessage, 0xB7, 0, 0,  % "ahk_id " . This.HWND
         DllCall("User32.dll\LockWindowUpdate", "Ptr", 0)
         Return ErrorLevel
      }
      Numput(VarSetCapacity(PD, PD_Size, 0), PD)
      NumPut(0x0100 | 0x0400, PD, A_PtrSize * 5, "UInt") ; PD_RETURNDC | PD_RETURNDEFAULT
      If !DllCall("Comdlg32.dll\PrintDlg", "Ptr", &PD, "Int")
         Return
      DllCall("Kernel32.dll\GlobalFree", "Ptr", NumGet(PD, A_PtrSize * 2, "UPtr"))
      DllCall("Kernel32.dll\GlobalFree", "Ptr", NumGet(PD, A_PtrSize * 3, "UPtr"))
      PDC := NumGet(PD, A_PtrSize * 4, "UPtr")
      DllCall("User32.dll\LockWindowUpdate", "Ptr", This.HWND)
      Caps := This.GetPrinterCaps(PDC)
      ; Set up page size and margins in pixel
      UML := This.Margins.LT                   ; user margin left
      UMR := This.Margins.RT                   ; user margin right
      PML := Caps.POFX                         ; physical margin left
      PMR := Caps.PHYW - Caps.HRES - Caps.POFX ; physical margin right
      LPW := Caps.HRES                         ; logical page width
      ; Adjust margins
      UML := UML > PML ? (UML - PML) : 0
      UMR := UMR > PMR ? (UMR - PMR) : 0
      LineLen := LPW - UML - UMR
      SendMessage, 0x0448, %PDC%, %LineLen%, , % "ahk_id " . This.HWND
      This.SetSel(Sel.S, Sel.E)
      SendMessage, 0xB7, 0, 0,  % "ahk_id " . This.HWND
      DllCall("User32.dll\LockWindowUpdate", "Ptr", 0)
      Return ErrorLevel
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; File handling
   ; -------------------------------------------------------------------------------------------------------------------
   LoadFile(File, Mode = "Open") { ; Load file
      ; File : file name
      ; Mode : Open / Add / Insert
      ;        Open   : Replace control's content
      ;        Append : Append to conrol's content
      ;        Insert : Insert at / replace current selection
      If !FileExist(File)
         Return False
      SplitPath, File, , , Ext
      If (Ext = "rtf") {
         If (Mode = "Open") {
            Selection := False
         } Else If (Mode = "Insert") {
            Selection := True
         } Else If (Mode = "Append") {
            This.SetSel(-1, -2)
            Selection := True
         }
         This.LoadRTF(File, Selection)
      } Else {
         FileRead, Text, %File%
         If (Mode = "Open") {
            This.SetText(Text)
         } Else If (Mode = "Insert") {
            This.ReplaceSel(Text)
         } Else If (Mode = "Append") {
            This.SetSel(-1, -2)
            This.ReplaceSel(Text)
         }
      }
      Return True
   }
   ; -------------------------------------------------------------------------------------------------------------------
   SaveFile(File) { ; Save file
      ; File : file name
      ; Returns True on success, otherwise False.
      GuiName := This.GuiName
      Gui, %GuiName%:+OwnDialogs
      SplitPath, File, , , Ext
      Text := Ext = "rtf" ? This.GetRTF() : This.GetText()
      If IsObject(FileObj := FileOpen(File, "w")) {
         FileObj.Write(Text)
         FileObj.Close()
         Return True
      }
      Return False
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ; Printing
   ; THX jballi ->  http://www.autohotkey.com/board/topic/45513-function-he-print-wysiwyg-print-for-the-hiedit-control/
   ; -------------------------------------------------------------------------------------------------------------------
   Print() {
      ; ----------------------------------------------------------------------------------------------------------------
      ; Static variables
      Static PD_ALLPAGES := 0x00, PD_SELECTION := 0x01, PD_PAGENUMS := 0x02, PD_NOSELECTION := 0x04
           , PD_RETURNDC := 0x0100, PD_USEDEVMODECOPIES := 0x040000, PD_HIDEPRINTTOFILE := 0x100000
           , PD_NONETWORKBUTTON := 0x200000, PD_NOCURRENTPAGE := 0x800000
           , MM_TEXT := 0x1
           , EM_FORMATRANGE := 0x0439, EM_SETTARGETDEVICE := 0x0448
           , DocName := "AHKRichEdit"
           , PD_Size := (A_PtrSize = 8 ? (13 * A_PtrSize) + 16 : 66)
      ErrorMsg := ""
      ; ----------------------------------------------------------------------------------------------------------------
      ; Prepare to call PrintDlg
      ; Define/Populate the PRINTDLG structure
      VarSetCapacity(PD, PD_Size, 0)
      Numput(PD_Size, PD, 0, "UInt")  ; lStructSize
      Numput(This.GuiHwnd, PD, A_PtrSize, "UPtr") ; hwndOwner
      ; Collect Start/End select positions
      Sel := This.GetSel()
      ; Determine/Set Flags
      Flags := PD_ALLPAGES | PD_RETURNDC | PD_USEDEVMODECOPIES | PD_HIDEPRINTTOFILE | PD_NONETWORKBUTTON
             | PD_NOCURRENTPAGE
      If (Sel.S = Sel.E)
         Flags |= PD_NOSELECTION
      Else
         Flags |= PD_SELECTION
      Offset := A_PtrSize * 5
      NumPut(Flags, PD, Offset, "UInt")       ; Flags
      ; Page and copies
      NumPut( 1, PD, Offset += 4, "UShort")   ; nFromPage
      NumPut( 1, PD, Offset += 2, "UShort")   ; nToPage
      NumPut( 1, PD, Offset += 2, "UShort")   ; nMinPage
      NumPut(-1, PD, Offset += 2, "UShort")   ; nMaxPage
      NumPut( 1, PD, Offset += 2, "UShort")   ; nCopies
      ; Note: Use -1 to specify the maximum page number (65535).
      ; Programming note: The values that are loaded to these fields are critical. The Print dialog will not
      ; display (returns an error) if unexpected values are loaded to one or more of these fields.
      ; ----------------------------------------------------------------------------------------------------------------
      ; Print dialog box
      ; Open the Print dialog.  Bounce If the user cancels.
      If !DllCall("Comdlg32.dll\PrintDlg", "Ptr", &PD, "UInt") {
         ErrorLevel := "Function: " . A_ThisFunc . " - DLLCall of 'PrintDlg' failed."
         Return False
      }
      ; Get the printer device context.  Bounce If not defined.
      If !(PDC := NumGet(PD, A_PtrSize * 4, "UPtr")) { ; hDC
         ErrorLevel := "Function: " . A_ThisFunc . " - Couldn't get a printer's device context."
         Return False
      }
      ; Free global structures created by PrintDlg
      DllCall("Kernel32.dll\GlobalFree", "Ptr", NumGet(PD, A_PtrSize * 2, "UPtr"))
      DllCall("Kernel32.dll\GlobalFree", "Ptr", NumGet(PD, A_PtrSize * 3, "UPtr"))
      ; ----------------------------------------------------------------------------------------------------------------
      ; Prepare to print
      ; Collect Flags
      Offset := A_PtrSize * 5
      Flags := NumGet(PD, OffSet, "UInt")           ; Flags
      ; Determine From/To Page
      If (Flags & PD_PAGENUMS) {
         PageF := NumGet(PD, Offset += 4, "UShort") ; nFromPage (first page)
         PageL := NumGet(PD, Offset += 2, "UShort") ; nToPage (last page)
      } Else {
         PageF := 1
         PageL := 65535
      }
      ; Collect printer capacities
      Caps := This.GetPrinterCaps(PDC)
      ; Set up page size and margins in Twips (1/20 point or 1/1440 of an inch)
      UML := This.Margins.LT                   ; user margin left
      UMT := This.Margins.TT                   ; user margin top
      UMR := This.Margins.RT                   ; user margin right
      UMB := This.Margins.BT                   ; user margin bottom
      PML := Caps.POFX                         ; physical margin left
      PMT := Caps.POFY                         ; physical margin top
      PMR := Caps.PHYW - Caps.HRES - Caps.POFX ; physical margin right
      PMB := Caps.PHYH - Caps.VRES - Caps.POFY ; physical margin bottom
      LPW := Caps.HRES                         ; logical page width
      LPH := Caps.VRES                         ; logical page height
      ; Adjust margins
      UML := UML > PML ? (UML - PML) : 0
      UMT := UMT > PMT ? (UMT - PMT) : 0
      UMR := UMR > PMR ? (UMR - PMR) : 0
      UMB := UMB > PMB ? (UMB - PMB) : 0
      ; Define/Populate the FORMATRANGE structure
      VarSetCapacity(FR, (A_PtrSize * 2) + (4 * 10), 0)
      NumPut(PDC, FR, 0, "UPtr")         ; hdc
      NumPut(PDC, FR, A_PtrSize, "UPtr") ; hdcTarget
      ; Define FORMATRANGE.rc
      ; rc is the area to render to (rcPage - margins), measured in twips (1/20 point or 1/1440 of an inch).
      ; If the user-defined margins are smaller than the printer's margins (the unprintable areas at the edges of each
      ; page), the user margins are set to the printer's margins. In addition, the user-defined margins must be adjusted
      ; to account for the printer's margins.
      ; For example: If the user requests a 3/4 inch (19.05 mm) left margin but the printer's left margin is 1/4 inch
      ; (6.35 mm), rc.Left is set to 720 twips (1/2 inch or 12.7 mm).
      Offset := A_PtrSize * 2
      NumPut(UML, FR, Offset += 0, "Int")       ; rc.Left
      NumPut(UMT, FR, Offset += 4, "Int")       ; rc.Top
      NumPut(LPW - UMR, FR, Offset += 4, "Int") ; rc.Right
      NumPut(LPH - UMB, FR, Offset += 4, "Int") ; rc.Bottom
      ; Define FORMATRANGE.rcPage
      ; rcPage is the entire area of a page on the rendering device, measured in twips (1/20 point or 1/1440 of an inch)
      ; Note: rc defines the maximum printable area which does not include the printer's margins (the unprintable areas
      ; at the edges of the page). The unprintable areas are represented by PHYSICALOFFSETX and PHYSICALOFFSETY.
      NumPut(0, FR, Offset += 4, "Int")         ; rcPage.Left
      NumPut(0, FR, Offset += 4, "Int")         ; rcPage.Top
      NumPut(LPW, FR, Offset += 4, "Int")       ; rcPage.Right
      NumPut(LPH, FR, Offset += 4, "Int")       ; rcPage.Bottom
      ; Determine print range.
      ; If "Selection" option is chosen, use selected text, otherwise use the entire document.
      If (Flags & PD_SELECTION) {
         PrintS := Sel.S
         PrintE := Sel.E
      } Else {
         PrintS := 0
         PrintE := -1            ; (-1 = Select All)
      }
      Numput(PrintS, FR, Offset += 4, "Int")    ; cr.cpMin
      NumPut(PrintE, FR, Offset += 4, "Int")    ; cr.cpMax
      ; Define/Populate the DOCINFO structure
      VarSetCapacity(DI, A_PtrSize * 5, 0)
      NumPut(A_PtrSize * 5, DI, 0, "UInt")
      NumPut(&DocName, DI, A_PtrSize, "UPtr")     ; lpszDocName
      NumPut(0       , DI, A_PtrSize * 2, "UPtr") ; lpszOutput
      ; Programming note: All other DOCINFO fields intentionally left as null.
      ; Determine MaxPrintIndex
      If (Flags & PD_SELECTION) {
          PrintM := Sel.E
      } Else {
          PrintM := This.GetTextLen()
      }
      ; Be sure that the printer device context is in text mode
      DllCall("Gdi32.dll\SetMapMode", "Ptr", PDC, "Int", MM_TEXT)
      ; ----------------------------------------------------------------------------------------------------------------
      ; Print it!
      ; Start a print job.  Bounce If there is a problem.
      PrintJob := DllCall("Gdi32.dll\StartDoc", "Ptr", PDC, "Ptr", &DI, "Int")
      If (PrintJob <= 0) {
         ErrorLevel := "Function: " . A_ThisFunc . " - DLLCall of 'StartDoc' failed."
         Return False
      }
      ; Print page loop
      PageC  := 0 ; current page
      PrintC := 0 ; current print index
      While (PrintC < PrintM) {
         PageC++
         ; Are we done yet?
         If (PageC > PageL)
            Break
         If (PageC >= PageF) && (PageC <= PageL) {
            ; StartPage function.  Break If there is a problem.
            If (DllCall("Gdi32.dll\StartPage", "Ptr", PDC, "Int") <= 0) {
               ErrorMsg := "Function: " . A_ThisFunc . " - DLLCall of 'StartPage' failed."
               Break
            }
         }
         ; Format or measure page
         If (PageC >= PageF) && (PageC <= PageL)
            Render := True
         Else
            Render := False
         SendMessage, %EM_FORMATRANGE%, %Render%, &FR, , % "ahk_id " . This.HWND
         PrintC := ErrorLevel
         If (PageC >= PageF) && (PageC <= PageL) {
            ; EndPage function. Break If there is a problem.
            If (DllCall("Gdi32.dll\EndPage", "Ptr", PDC, "Int") <= 0) {
               ErrorMsg := "Function: " . A_ThisFunc . " - DLLCall of 'EndPage' failed."
               Break
            }
         }
         ; Update FR for the next page
         Offset := (A_PtrSize * 2) + (4 * 8)
         Numput(PrintC, FR, Offset += 0, "Int") ; cr.cpMin
         NumPut(PrintE, FR, Offset += 4, "Int") ; cr.cpMax
      }
      ; ----------------------------------------------------------------------------------------------------------------
      ; End the print job
      DllCall("Gdi32.dll\EndDoc", "Ptr", PDC)
      ; Delete the printer device context
      DllCall("Gdi32.dll\DeleteDC", "Ptr", PDC)
      ; Reset control (free cached information)
      SendMessage %EM_FORMATRANGE%, 0, 0, , % "ahk_id " . This.HWND
      ; Return to sender
      If (ErrorMsg) {
         ErrorLevel := ErrorMsg
         Return False
      }
      Return True
   }
   ; -------------------------------------------------------------------------------------------------------------------
   GetMargins() { ; Get the default print margins
      Static PSD_RETURNDEFAULT := 0x00000400, PSD_INTHOUSANDTHSOFINCHES := 0x00000004
           , I := 1000 ; thousandth of inches
           , M := 2540 ; hundredth of millimeters
           , PSD_Size := (4 * 10) + (A_PtrSize * 11)
           , PD_Size := (A_PtrSize = 8 ? (13 * A_PtrSize) + 16 : 66)
           , OffFlags := 4 * A_PtrSize
           , OffMargins := OffFlags + (4 * 7)
      If !This.HasKey("Margins") {
         VarSetCapacity(PSD, PSD_Size, 0) ; PAGESETUPDLG structure
         NumPut(PSD_Size, PSD, 0, "UInt")
         NumPut(PSD_RETURNDEFAULT, PSD, OffFlags, "UInt")
         If !DllCall("Comdlg32.dll\PageSetupDlg", "Ptr", &PSD, "UInt")
            Return false
         DllCall("Kernel32.dll\GobalFree", UInt, NumGet(PSD, 2 * A_PtrSize, "UPtr"))
         DllCall("Kernel32.dll\GobalFree", UInt, NumGet(PSD, 3 * A_PtrSize, "UPtr"))
         Flags := NumGet(PSD, OffFlags, "UInt")
         Metrics := (Flags & PSD_INTHOUSANDTHSOFINCHES) ? I : M
         Offset := OffMargins
         This.Margins := {}
         This.Margins.L := NumGet(PSD, Offset += 0, "Int")           ; Left
         This.Margins.T := NumGet(PSD, Offset += 4, "Int")           ; Top
         This.Margins.R := NumGet(PSD, Offset += 4, "Int")           ; Right
         This.Margins.B := NumGet(PSD, Offset += 4, "Int")           ; Bottom
         This.Margins.LT := Round((This.Margins.L / Metrics) * 1440) ; Left in twips
         This.Margins.TT := Round((This.Margins.T / Metrics) * 1440) ; Top in twips
         This.Margins.RT := Round((This.Margins.R / Metrics) * 1440) ; Right in twips
         This.Margins.BT := Round((This.Margins.B / Metrics) * 1440) ; Bottom in twips
      }
      Return True
   }
   ; -------------------------------------------------------------------------------------------------------------------
   GetPrinterCaps(DC) { ; Get printer's capacities
      Static HORZRES         := 0x08, VERTRES         := 0x0A
           , LOGPIXELSX      := 0x58, LOGPIXELSY      := 0x5A
           , PHYSICALWIDTH   := 0x6E, PHYSICALHEIGHT  := 0x6F
           , PHYSICALOFFSETX := 0x70, PHYSICALOFFSETY := 0x71
           , Caps := {}
      ; Number of pixels per logical inch along the page width and height
      LPXX := DllCall("Gdi32.dll\GetDeviceCaps", "Ptr", DC, "Int", LOGPIXELSX, "Int")
      LPXY := DllCall("Gdi32.dll\GetDeviceCaps", "Ptr", DC, "Int", LOGPIXELSY, "Int")
      ; The width and height of the physical page, in twips.
      Caps.PHYW := Round((DllCall("Gdi32.dll\GetDeviceCaps", "Ptr", DC, "Int", PHYSICALWIDTH, "Int") / LPXX) * 1440)
      Caps.PHYH := Round((DllCall("Gdi32.dll\GetDeviceCaps", "Ptr", DC, "Int", PHYSICALHEIGHT, "Int") / LPXY) * 1440)
      ; The distance from the left/right edge (PHYSICALOFFSETX) and the top/bottom edge (PHYSICALOFFSETY) of the
      ; physical page to the edge of the printable area, in twips.
      Caps.POFX := Round((DllCall("Gdi32.dll\GetDeviceCaps", "Ptr", DC, "Int", PHYSICALOFFSETX, "Int") / LPXX) * 1440)
      Caps.POFY := Round((DllCall("Gdi32.dll\GetDeviceCaps", "Ptr", DC, "Int", PHYSICALOFFSETY, "Int") / LPXY) * 1440)
      ; Width and height of the printable area of the page, in twips.
      Caps.HRES := Round((DllCall("Gdi32.dll\GetDeviceCaps", "Ptr", DC, "Int", HORZRES, "Int") / LPXX) * 1440)
      Caps.VRES := Round((DllCall("Gdi32.dll\GetDeviceCaps", "Ptr", DC, "Int", VERTRES, "Int") / LPXY) * 1440)
      Return Caps
   }
   
   
   searchBkup_restore(select:=0){ ; added by Drozdman
       ; backup for search highlight - go back to original
      SendMessage, 0x00CE, 0,0 , ,  % "ahk_id " this.HWND ;M_GETFIRSTVISIBLELINE
      firstVisLineNum:=ErrorLevel
      sel:=this.GetSel()
      this.SetText(this.searchBkup) 
      this.searchModif:=0
      ModBefSearch:=this.ModBefSearch      
      SendMessage, 0xB9, %ModBefSearch% , 0, , % "ahk_id " . this.HWND ; EM_SETMODIFY = 0xB9
      
     ; if(select)
         ;this.SetSel(sel["S"],sel["E"])
     
      SendMessage, 0x00B6, 0, %firstVisLineNum% ,  , % "ahk_id " this.HWND  ; EM_LINESCROLL     
   }


}












Class RichEditDlgs {
   ; ===================================================================================================================
   ; ===================================================================================================================
   ; RICHEDIT COMMON DIALOGS ===========================================================================================
   ; ===================================================================================================================
   ; ===================================================================================================================
   ; Most of the following methods are based on DLG 5.01 by majkinetor
   ; http://www.autohotkey.com/board/topic/15836-module-dlg-501/
   ; ===================================================================================================================
   ChooseColor(RE, Color := "") { ; Choose color dialog box
   ; ===================================================================================================================
      ; RE : RichEdit object
      Static CC_Size := A_PtrSize * 9, CCU := "Init"
      GuiHwnd := RE.GuiHwnd
      If (Color = "T")
         Font := RE.GetFont(), Color := Font.Color = "Auto" ? 0x0 : RE.GetBGR(Font.Color)
      Else If (Color = "B")
         Font := RE.GetFont(), Color := Font.BkColor = "Auto" ? 0x0 : RE.GetBGR(Font.BkColor)
      Else If (Color != "")
         Color := RE.GetBGR(Color)
      Else
         Color := 0x000000
      If (CCU = "Init")
         VarSetCapacity(CCU, 64, 0)
      VarSetCapacity(CC, CC_Size, 0)            ; CHOOSECOLOR structure
      NumPut(CC_Size, CC, 0, "UInt")            ; lStructSize
      NumPut(GuiHwnd, CC, A_PtrSize, "UPtr")    ; hwndOwner makes dialog modal
      NumPut(Color, CC, A_PtrSize * 3, "UInt")  ; rgbResult
      NumPut(&CCU, CC, A_PtrSize * 4, "UPtr")   ; COLORREF *lpCustColors (16)
      ;NumPut(0x0101, CC, A_PtrSize * 5, "UInt") ; Flags: CC_ANYCOLOR | CC_RGBINIT | ; CC_FULLOPEN
      
      NumPut(0x0103, CC, A_PtrSize * 5, "UInt") ; changed - CC_FULLOPEN =0x00000002
      
      R := DllCall("Comdlg32.dll\ChooseColor", "Ptr", &CC, "UInt")
      If (ErrorLevel <> 0) || (R = 0)
         Return "Cancel"  ; changed by Drozdman
         ;Return False
      Return RE.GetRGB(NumGet(CC, A_PtrSize * 3, "UInt"))
   }
   ; ===================================================================================================================
   ChooseFont(RE) { ; Choose font dialog box
   ; ===================================================================================================================
      ; RE : RichEdit object
      DC := DllCall("User32.dll\GetDC", "Ptr", RE.GuiHwnd, "Ptr")
      LP := DllCall("GetDeviceCaps", "Ptr", DC, "UInt", 90, "Int") ; LOGPIXELSY
      DllCall("User32.dll\ReleaseDC", "Ptr", RE.GuiHwnd, "Ptr", DC)
      ; Get current font
      Font := RE.GetFont()
      ; LF_FACENAME = 32
      VarSetCapacity(LF, 92, 0)             ; LOGFONT structure
      Size := -(Font.Size * LP / 72)
      NumPut(Size, LF, 0, "Int")            ; lfHeight
      If InStr(Font.Style, "B")
         NumPut(700, LF, 16, "Int")         ; lfWeight
      If InStr(Font.Style, "I")
         NumPut(1, LF, 20, "UChar")         ; lfItalic
      If InStr(Font.Style, "U")
         NumPut(1, LF, 21, "UChar")         ; lfUnderline
      If InStr(Font.Style, "S")
         NumPut(1, LF, 22, "UChar")         ; lfStrikeOut
      NumPut(Font.CharSet, LF, 23, "UChar") ; lfCharSet
      StrPut(Font.Name, &LF + 28, 32)
      ; CF_BOTH = 3, CF_INITTOLOGFONTSTRUCT = 0x40, CF_EFFECTS = 0x100, CF_SCRIPTSONLY = 0x400
      ; CF_NOVECTORFONTS = 0x800, CF_NOSIMULATIONS = 0x1000, CF_LIMITSIZE = 0x2000, CF_WYSIWYG = 0x8000
      ; CF_TTONLY = 0x40000, CF_FORCEFONTEXIST =0x10000, CF_SELECTSCRIPT = 0x400000
      ; CF_NOVERTFONTS =0x01000000
      Flags := 0x00002141 ; 0x01013940
      Color := RE.GetBGR(Font.Color)
      CF_Size := (A_PtrSize = 8 ? (A_PtrSize * 10) + (4 * 4) + A_PtrSize : (A_PtrSize * 14) + 4)
      VarSetCapacity(CF, CF_Size, 0)                     ; CHOOSEFONT structure
      NumPut(CF_Size, CF, "UInt")                        ; lStructSize
      NumPut(RE.GuiHwnd, CF, A_PtrSize, "UPtr")		      ; hwndOwner (makes dialog modal)
      NumPut(&LF, CF, A_PtrSize * 3, "UPtr")	            ; lpLogFont
      NumPut(Flags, CF, (A_PtrSize * 4) + 4, "UInt")     ; Flags
      NumPut(Color, CF, (A_PtrSize * 4) + 8, "UInt")     ; rgbColors
      OffSet := (A_PtrSize = 8 ? (A_PtrSize * 11) + 4 : (A_PtrSize * 12) + 4)
      NumPut(4, CF, Offset, "Int")                       ; nSizeMin
      NumPut(160, CF, OffSet + 4, "Int")                 ; nSizeMax
      ; Call ChooseFont Dialog
      If !DllCall("Comdlg32.dll\ChooseFont", "Ptr", &CF, "UInt")
         Return false
      ; Get name
      Font.Name := StrGet(&LF + 28, 32)
   	; Get size
   	Font.Size := NumGet(CF, A_PtrSize * 4, "Int") / 10
      ; Get styles
   	Font.Style := ""
   	If NumGet(LF, 16, "Int") >= 700
   	   Font.Style .= "B"
   	If NumGet(LF, 20, "UChar")
         Font.Style .= "I"
   	If NumGet(LF, 21, "UChar")
         Font.Style .= "U"
   	If NumGet(LF, 22, "UChar")
         Font.Style .= "S"
      OffSet := A_PtrSize * (A_PtrSize = 8 ? 11 : 12)
      FontType := NumGet(CF, Offset, "UShort")
      If (FontType & 0x0100) && !InStr(Font.Style, "B") ; BOLD_FONTTYPE
         Font.Style .= "B"
      If (FontType & 0x0200) && !InStr(Font.Style, "I") ; ITALIC_FONTTYPE
         Font.Style .= "I"
      If (Font.Style = "")
         Font.Style := "N"
      ; Get character set
      Font.CharSet := NumGet(LF, 23, "UChar")
      ; We don't use the limited colors of the font dialog
      ; Return selected values
      Return RE.SetFont(Font)
   }
   ; ===================================================================================================================
   FileDlg(RE, Mode, File := "") { ; Open and save as dialog box
   ; ===================================================================================================================
      ; RE   : RichEdit object
      ; Mode : O = Open, S = Save
      ; File : optional file name
   	Static OFN_ALLOWMULTISELECT := 0x200,    OFN_EXTENSIONDIFFERENT := 0x400, OFN_CREATEPROMPT := 0x2000
           , OFN_DONTADDTORECENT := 0x2000000, OFN_FILEMUSTEXIST := 0x1000,     OFN_FORCESHOWHIDDEN := 0x10000000
           , OFN_HIDEREADONLY := 0x4,          OFN_NOCHANGEDIR := 0x8,          OFN_NODEREFERENCELINKS := 0x100000
           , OFN_NOVALIDATE := 0x100,          OFN_OVERWRITEPROMPT := 0x2,      OFN_PATHMUSTEXIST := 0x800
           , OFN_READONLY := 0x1,              OFN_SHOWHELP := 0x10,            OFN_NOREADONLYRETURN := 0x8000
           , OFN_NOTESTFILECREATE := 0x10000,  OFN_ENABLEXPLORER := 0x80000
           , OFN_Size := (4 * 5) + (2 * 2) + (A_PtrSize * 16)
      Static FilterN1 := "RichText",   FilterP1 :=  "*.rtf"
           , FilterN2 := "Text",       FilterP2 := "*.txt"
           , FilterN3 := "AutoHotkey", FilterP3 := "*.ahk"
           , DefExt := "rtf", DefFilter := 1
   	SplitPath, File, Name, Dir
      Flags := OFN_ENABLEXPLORER
      Flags |= Mode = "O" ? OFN_FILEMUSTEXIST | OFN_PATHMUSTEXIST | OFN_HIDEREADONLY
                          : OFN_OVERWRITEPROMPT
   	VarSetCapacity(FileName, 1024, 0)
      FileName := Name
   	LenN1 := (StrLen(FilterN1) + 1) * 2, LenP1 := (StrLen(FilterP1) + 1) * 2
   	LenN2 := (StrLen(FilterN2) + 1) * 2, LenP2 := (StrLen(FilterP2) + 1) * 2
   	LenN3 := (StrLen(FilterN3) + 1) * 2, LenP3 := (StrLen(FilterP3) + 1) * 2
      VarSetCapacity(Filter, LenN1 + LenP1 + LenN2 + LenP2 + LenN3 + LenP3 + 4, 0)
      Adr := &Filter
      StrPut(FilterN1, Adr)
      StrPut(FilterP1, Adr += LenN1)
      StrPut(FilterN2, Adr += LenP1)
      StrPut(FilterP2, Adr += LenN2)
      StrPut(FilterN3, Adr += LenP2)
      StrPut(FilterP3, Adr += LenN3)
      VarSetCapacity(OFN , OFN_Size, 0)      ; OPENFILENAME Structure
   	NumPut(OFN_Size, OFN, 0, "UInt")
      Offset := A_PtrSize
   	NumPut(RE.GuiHwnd, OFN, Offset, "Ptr") ; HWND owner
      Offset += A_PtrSize * 2
   	NumPut(&Filter, OFN, OffSet, "Ptr")    ; Pointer to FilterStruc
      OffSet += (A_PtrSize * 2) + 4
      OffFilter := Offset
   	NumPut(DefFilter, OFN, Offset, "UInt") ; DefaultFilter Pair
      OffSet += 4
   	NumPut(&FileName, OFN, OffSet, "Ptr")  ; lpstrFile / InitialisationFileName
      Offset += A_PtrSize
   	NumPut(512, OFN, Offset, "UInt")       ; MaxFile / lpstrFile length
      OffSet += A_PtrSize * 3
   	NumPut(&Dir, OFN, Offset, "Ptr")       ; StartDir
      Offset += A_PtrSize * 2
   	NumPut(Flags, OFN, Offset, "UInt")     ; Flags
      Offset += 8
   	NumPut(&DefExt, OFN, Offset, "Ptr")    ; DefaultExt
      R := Mode = "S" ? DllCall("Comdlg32.dll\GetSaveFileNameW", "Ptr", &OFN, "UInt")
                      : DllCall("Comdlg32.dll\GetOpenFileNameW", "Ptr", &OFN, "UInt")
   	If !(R)
         Return ""
      DefFilter := NumGet(OFN, OffFilter, "UInt")
   	Return StrGet(&FileName)
   }
   ; ===================================================================================================================
   FindText(RE) { ; Find dialog box
   ; ===================================================================================================================
      ; RE : RichEdit object
   	Static FINDMSGSTRING := "commdlg_FindReplace"
   	     , FR_DOWN := 1, FR_MATCHCASE := 4, FR_WHOLEWORD := 2
   	     , Buf := "", FR := "", Len := 256
           , FR_Size := A_PtrSize * 10
      Text := RE.GetSelText()
      VarSetCapacity(FR, FR_Size, 0)
   	NumPut(FR_Size, FR, 0, "UInt")
      VarSetCapacity(Buf, Len, 0)
      ;If (Text && !RegExMatch(Text, "\W"))
      if Text
         Buf := Trim(Text)
      Offset := A_PtrSize
   	NumPut(RE.GuiHwnd, FR, Offset, "UPtr") ; hwndOwner
      OffSet += A_PtrSize * 2
   	NumPut(FR_DOWN, FR, Offset, "UInt")	   ; Flags
      OffSet += A_PtrSize
   	NumPut(&Buf, FR, Offset, "UPtr")	      ; lpstrFindWhat
      OffSet += A_PtrSize * 2
   	NumPut(Len,	FR, Offset, "Short")       ; wFindWhatLen
      This.FindTextProc("Init", RE.HWND, "")
   	OnMessage(DllCall("User32.dll\RegisterWindowMessage", "Str", FINDMSGSTRING), "RichEditDlgs.FindTextProc")
   	Return DllCall("Comdlg32.dll\FindTextW", "Ptr", &FR, "UPtr")
   }
   ; -------------------------------------------------------------------------------------------------------------------
   FindTextProc(L, M, H) { ; skipped wParam, can be found in "This" when called by system
      ; Find dialog callback procedure
      ; EM_FINDTEXTEXW = 0x047C, EM_EXGETSEL = 0x0434, EM_EXSETSEL = 0x0437, EM_SCROLLCARET = 0x00B7
      ; FR_DOWN = 1, FR_WHOLEWORD = 2, FR_MATCHCASE = 4,
   	Static FINDMSGSTRING := "commdlg_FindReplace"
   	     , FR_DOWN := 1, FR_MATCHCASE := 4, FR_WHOLEWORD := 2 , FR_FINDNEXT := 0x8, FR_DIALOGTERM := 0x40
           , HWND := 0
      If (L = "Init") {
         HWND := M
         Return True
      }
      Flags := NumGet(L + 0, A_PtrSize * 3, "UInt")
      If (Flags & FR_DIALOGTERM) {
         OnMessage(DllCall("User32.dll\RegisterWindowMessage", "Str", FINDMSGSTRING), "")
         ControlFocus, , ahk_id %HWND%
         HWND := 0
         Return
      }
      VarSetCapacity(CR, 8, 0)
      SendMessage, 0x0434, 0, &CR, , ahk_id %HWND%
      Min := (Flags & FR_DOWN) ? NumGet(CR, 4, "Int") : NumGet(CR, 0, "Int")
      Max := (Flags & FR_DOWN) ? -1 : 0
      OffSet := A_PtrSize * 4
      Find := StrGet(NumGet(L + Offset, 0, "UPtr"))
      VarSetCapacity(FTX, 16 + A_PtrSize, 0)
      NumPut(Min, FTX, 0, "Int")
      NumPut(Max, FTX, 4, "Int")
      NumPut(&Find, FTX, 8, "Ptr")
      SendMessage, 0x047C, %Flags%, &FTX, , ahk_id %HWND%
      S := NumGet(FTX, 8 + A_PtrSize, "Int"), E := NumGet(FTX, 12 + A_PtrSize, "Int")
      If (S = -1) && (E = -1)
         MsgBox, 262208, Find, No (further) occurence found!, 1
      Else {
         Min := (Flags & FR_DOWN) ? E : S
         SendMessage, 0x0437, 0, % (&FTX + 8 + A_PtrSize), , ahk_id %HWND%
         SendMessage, 0x00B7, 0, 0, , ahk_id %HWND%
      }
   }

   ; ===================================================================================================================
   ReplaceText(RE) { ; Replace dialog box
   ; ===================================================================================================================
      ; RE : RichEdit object
   	Static FINDMSGSTRING := "commdlg_FindReplace"
   	     , FR_DOWN := 1, FR_MATCHCASE := 4, FR_WHOLEWORD := 2
   	     , FBuf := "", RBuf := "", FR := "", Len := 256
           , FR_Size := A_PtrSize * 10
      Text := RE.GetSelText()
      VarSetCapacity(FBuf, Len, 0)
      VarSetCapacity(RBuf, Len, 0)
      VarSetCapacity(FR, FR_Size, 0)
   	NumPut(FR_Size, FR, 0, "UInt")
      ;If (Text && !RegExMatch(Text, "\W"))
      if Text
         FBuf := Trim(Text)
      Sleep, 0
      Offset := A_PtrSize
   	NumPut(RE.GuiHwnd, FR, Offset, "UPtr") ; hwndOwner
      OffSet += A_PtrSize * 2
   	NumPut(FR_DOWN, FR, Offset, "UInt")	   ; Flags
      OffSet += A_PtrSize
   	NumPut(&FBuf, FR, Offset, "UPtr")      ; lpstrFindWhat
      OffSet += A_PtrSize
   	NumPut(&RBuf, FR, Offset, "UPtr")      ; lpstrReplaceWith
      OffSet += A_PtrSize
   	NumPut(Len,	FR, Offset, "Short")       ; wFindWhatLen
   	NumPut(Len,	FR, Offset + 2, "Short")   ; wReplaceWithLen
      This.ReplaceTextProc("Init", RE.HWND, "")
   	OnMessage(DllCall("User32.dll\RegisterWindowMessage", "Str", FINDMSGSTRING), "RichEditDlgs.ReplaceTextProc")
   	Return DllCall("Comdlg32.dll\ReplaceText", "Ptr", &FR, "UPtr")
   }
   ; -------------------------------------------------------------------------------------------------------------------
   ReplaceTextProc(L, M, H) { ; skipped wParam, can be found in "This" when called by system
      ; Replace dialog callback procedure
      ; EM_FINDTEXTEXW = 0x047C, EM_EXGETSEL = 0x0434, EM_EXSETSEL = 0x0437
      ; EM_REPLACESEL = 0xC2, EM_SCROLLCARET = 0x00B7
      ; FR_DOWN = 1, FR_WHOLEWORD = 2, FR_MATCHCASE = 4,
   	Static FINDMSGSTRING := "commdlg_FindReplace"
   	     , FR_DOWN := 1, FR_MATCHCASE := 4, FR_WHOLEWORD := 2, FR_FINDNEXT := 0x8
           , FR_REPLACE := 0x10, FR_REPLACEALL=0x20, FR_DIALOGTERM := 0x40
           , HWND := 0, Min := "", Max := "", FS := "", FE := ""
           , OffFind := A_PtrSize * 4, OffRepl := A_PtrSize * 5
      If (L = "Init") {
         HWND := M, FS := "", FE := ""
         Return True
      }
      Flags := NumGet(L + 0, A_PtrSize * 3, "UInt")
      If (Flags & FR_DIALOGTERM) {
         OnMessage(DllCall("User32.dll\RegisterWindowMessage", "Str", FINDMSGSTRING), "")
         ControlFocus, , ahk_id %HWND%
         HWND := 0
         Return
      }
      If (Flags & FR_REPLACE) {
         IF (FS >= 0) && (FE >= 0) {
            SendMessage, 0xC2, 1, % NumGet(L + 0, OffRepl, "UPtr" ), , ahk_id %HWND%
            Flags |= FR_FINDNEXT
         } Else {
            Return
         }
      }
      If (Flags & FR_FINDNEXT) {
         VarSetCapacity(CR, 8, 0)
         SendMessage, 0x0434, 0, &CR, , ahk_id %HWND%
         Min := NumGet(CR, 4)
         FS := FE := ""
         Find := StrGet(NumGet(L + OffFind, 0, "UPtr"))
         VarSetCapacity(FTX, 16 + A_PtrSize, 0)
         NumPut(Min, FTX, 0, "Int")
         NumPut(-1, FTX, 4, "Int")
         NumPut(&Find, FTX, 8, "Ptr")
         SendMessage, 0x047C, %Flags%, &FTX, , ahk_id %HWND%
         S := NumGet(FTX, 8 + A_PtrSize, "Int"), E := NumGet(FTX, 12 + A_PtrSize, "Int")
         If (S = -1) && (E = -1)
            MsgBox, 262208, Replace, No (further) occurence found!
         Else {
            SendMessage, 0x0437, 0, % (&FTX + 8 + A_PtrSize), , ahk_id %HWND%
            SendMessage, 0x00B7, 0, 0, , ahk_id %HWND%
            FS := S, FE := E
         }
         Return
      }
      If (Flags & FR_REPLACEALL) {
         VarSetCapacity(CR, 8, 0)
         SendMessage, 0x0434, 0, &CR, , ahk_id %HWND%
         If (FS = "")
            FS := FE := 0
         DllCall("User32.dll\LockWindowUpdate", "Ptr", HWND)
         Find := StrGet(NumGet(L + OffFind, 0, "UPtr"))
         VarSetCapacity(FTX, 16 + A_PtrSize, 0)
         NumPut(FS, FTX, 0, "Int")
         NumPut(-1, FTX, 4, "Int")
         NumPut(&Find, FTX, 8, "Ptr")
         While (FS >= 0) && (FE >= 0) {
            SendMessage, 0x044F, %Flags%, &FTX, , ahk_id %HWND%
            FS := NumGet(FTX, A_PtrSize + 8, "Int"), FE := NumGet(FTX, A_PtrSize + 12, "Int")
            If (FS >= 0) && (FE >= 0) {
               SendMessage, 0x0437, 0, % (&FTX + 8 + A_PtrSize), , ahk_id %HWND%
               SendMessage, 0xC2, 1, % NumGet(L + 0, OffRepl, "UPtr" ), , ahk_id %HWND%
               NumPut(FE, FTX, 0, "Int")
            }
         }
         SendMessage, 0x0437, 0, &CR, , ahk_id %HWND%
         DllCall("User32.dll\LockWindowUpdate", "Ptr", 0)
         Return
      }
      
      
   }
   
      ; ===================================================================================================================
   PageSetup(RE) { ; Page setup dialog box
   ; ===================================================================================================================
      ; RE : RichEdit object
      ; http://msdn.microsoft.com/en-us/library/ms646842(v=vs.85).aspx
      Static PSD_DEFAULTMINMARGINS             := 0x00000000 ; default (printer's)
           , PSD_INWININIINTLMEASURE           := 0x00000000 ; 1st of 4 possible
           , PSD_MINMARGINS                    := 0x00000001 ; use caller's
           , PSD_MARGINS                       := 0x00000002 ; use caller's
           , PSD_INTHOUSANDTHSOFINCHES         := 0x00000004 ; 2nd of 4 possible
           , PSD_INHUNDREDTHSOFMILLIMETERS     := 0x00000008 ; 3rd of 4 possible
           , PSD_DISABLEMARGINS                := 0x00000010
           , PSD_DISABLEPRINTER                := 0x00000020
           , PSD_NOWARNING                     := 0x00000080 ; must be same as PD_*
           , PSD_DISABLEORIENTATION            := 0x00000100
           , PSD_RETURNDEFAULT                 := 0x00000400 ; must be same as PD_*
           , PSD_DISABLEPAPER                  := 0x00000200
           , PSD_SHOWHELP                      := 0x00000800 ; must be same as PD_*
           , PSD_ENABLEPAGESETUPHOOK           := 0x00002000 ; must be same as PD_*
           , PSD_ENABLEPAGESETUPTEMPLATE       := 0x00008000 ; must be same as PD_*
           , PSD_ENABLEPAGESETUPTEMPLATEHANDLE := 0x00020000 ; must be same as PD_*
           , PSD_ENABLEPAGEPAINTHOOK           := 0x00040000
           , PSD_DISABLEPAGEPAINTING           := 0x00080000
           , PSD_NONETWORKBUTTON               := 0x00200000 ; must be same as PD_*
           , I := 1000 ; thousandth of inches
           , M := 2540 ; hundredth of millimeters
           , Margins := {}
           , Metrics := ""
           , PSD_Size := (4 * 10) + (A_PtrSize * 11)
           , PD_Size := (A_PtrSize = 8 ? (13 * A_PtrSize) + 16 : 66)
           , OffFlags := 4 * A_PtrSize
           , OffMargins := OffFlags + (4 * 7)
      VarSetCapacity(PSD, PSD_Size, 0)              ; PAGESETUPDLG structure
      NumPut(PSD_Size, PSD, 0, "UInt")
      NumPut(RE.GuiHwnd, PSD, A_PtrSize, "UPtr")    ; hwndOwner
      Flags := PSD_MARGINS | PSD_DISABLEPRINTER | PSD_DISABLEORIENTATION | PSD_DISABLEPAPER
      NumPut(Flags, PSD, OffFlags, "Int")           ; Flags
      Offset := OffMargins
      NumPut(RE.Margins.L, PSD, Offset += 0, "Int") ; rtMargin left
      NumPut(RE.Margins.T, PSD, Offset += 4, "Int") ; rtMargin top
      NumPut(RE.Margins.R, PSD, Offset += 4, "Int") ; rtMargin right
      NumPut(RE.Margins.B, PSD, Offset += 4, "Int") ; rtMargin bottom
      If !DllCall("Comdlg32.dll\PageSetupDlg", "Ptr", &PSD, "UInt")
         Return False
      DllCall("Kernel32.dll\GobalFree", "Ptr", NumGet(PSD, 2 * A_PtrSize, "UPtr"))
      DllCall("Kernel32.dll\GobalFree", "Ptr", NumGet(PSD, 3 * A_PtrSize, "UPtr"))
      Flags := NumGet(PSD, OffFlags, "UInt")
      Metrics := (Flags & PSD_INTHOUSANDTHSOFINCHES) ? I : M
      Offset := OffMargins
      RE.Margins.L := NumGet(PSD, Offset += 0, "Int")
      RE.Margins.T := NumGet(PSD, Offset += 4, "Int")
      RE.Margins.R := NumGet(PSD, Offset += 4, "Int")
      RE.Margins.B := NumGet(PSD, Offset += 4, "Int")
      RE.Margins.LT := Round((RE.Margins.L / Metrics) * 1440) ; Left as twips
      RE.Margins.TT := Round((RE.Margins.T / Metrics) * 1440) ; Top as twips
      RE.Margins.RT := Round((RE.Margins.R / Metrics) * 1440) ; Right as twips
      RE.Margins.BT := Round((RE.Margins.B / Metrics) * 1440) ; Bottom as twips
      Return True
   }
}


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
