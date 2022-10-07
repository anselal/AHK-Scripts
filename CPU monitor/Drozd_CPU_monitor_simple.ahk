#SingleInstance force
#NoEnv
;#NoTrayIcon

/*  
=== Drozd monitor
-- Date , time ; time up = time since last restart
-- CPU usage graph; CPU usage bar ; total RAM memory usage bar
-- top left circle = toggle always on top
-- click on the date to go to the saved position 
=== 
Gdip library must be included by tic;	https://autohotkey.com/board/topic/29449-gdi-standard-library-145-by-tic/
; https://github.com/tariqporter/Gdip/blob/master/Gdip.ahk
; used CPU and memory functions linked 
*/

;===============================
	bgrd_grad_black:="0xff0F0F0F|0xff222222|25"
	bgrd_grad_steel:="0xff222832|0xff323F4B|25" ;"0xff1A2333|0xff2C3B54|25" 
	bgrd_grad_blue:="0xff1A2333|0xff2C3B54|25" ;"0xff06213D|0xff133557|25" 
	bgrd_grad_green:="0xff00230A|0xff044016|25"  ;"0xff00290C|0xff1C4527|25"	

	bgrd_grad:=bgrd_grad_black

	; clock bgrd color
	clock_grad_black:="0xff383838|0xff0F0F0F|25"	
	clock_grad_steel:="0xff3E4E5C|0xff12151C|26" ;"0xff314464|0xff1A2333|25"  
	clock_grad_blue:="0xff314464|0xff1A2333|26" ;"0xff13365A|0xff012243|25" 
	clock_grad_green:="0xff044016|0xff00230A|25" ;"0xff1C4527|0xff00290C|30"

clock_bgrd_grad:=clock_grad_black 

	;memory bar colors
	grad_col_green_2 :="0xff004614|0xff04B235|6" ;
	grad_col_green:="0xff004614|0xaa01DC3F|6" ;"0xff084218|0xFF0B9530|6" 
 	grad_col_blue:="0xff143268|0xff215EC7|6" ;"0xff031661|0xff008FDC|6"  ,	grad_col_blue_2:="0xff012243|0xff008FDC|6"
	grad_col_steel:="0xff12304E|0xff356696|6" 
	grad_color:=grad_col_steel

	bgrd_style:=0

Menu, Tray, Icon, shell32.dll, 58 ;208  ; Win 8   
;Menu, Tray, Icon, shell32.dll, 47  ; 95 ;22 ;47 ;134
Menu, Tray, NoStandard
Menu, Tray, Add, Window Spy, WindowSpy 
Menu, Tray, Add
Menu, Tray, Add , Open settings file , Open_ini
Menu, Tray, Icon , Open settings file , Shell32.dll, 70
Menu, Tray, Add
Menu, Tray, Add , Edit Scite, Edit_Scite
Menu, Tray, Add , Edit Notepad, Edit_Notepad
Menu, Tray, Add
Menu, Tray, Add, Reload , Reload
Menu, Tray, Add, Exit , Exit 
Menu, Tray, Default, Exit ; double click tray icon to exit

Menu, ContextMenu, Add, On Top, OnTop
Menu, ContextMenu, Icon, On Top, Shell32.dll, 248
Menu, ContextMenu, Add, Save current position , save_position
Menu, ContextMenu, Icon, Save current position , Shell32.dll, 124
Menu, ContextMenu, Add,
Menu, Submenu1, Add, Black , set_bgrd_black
Menu, Submenu1, Add, Steel , set_bgrd_steel
Menu, Submenu1, Add, Blue , set_bgrd_blue  
Menu, Submenu1, Add, Green , set_bgrd_green
Menu, Submenu1, Add, 
Menu, Submenu1, Add,  Funny style: dots, set_bgrd_style_dots
Menu, Submenu1, Add, Funny style: bricks, set_bgrd_style_bricks 
Menu, Submenu1, Add, 
Menu, Submenu1, Add, Reset background, reset_bgrd
Menu, ContextMenu, Add, Background color (Restart), :Submenu1 
Menu, ContextMenu, Add, Open settings file , Open_ini
Menu, ContextMenu, Icon, Open settings file, Shell32.dll, 70
Menu, ContextMenu, Add,
Menu, ContextMenu, Add, Restart, Reload
Menu, ContextMenu, Add, Exit, Exit


SetWorkingDir %A_ScriptDir%
;SetBatchLines, -1

If !pToken := Gdip_Startup()
{
	MsgBox, 48, No Gdiplus 
	ExitApp
}

OnExit, Exit

global grid_h:=29 , grid_w:=120
global array_cpu := Object() 
Loop, 120 {
		array_cpu[A_Index]:=29
} 


;===============================

settings_ini := "Drozd_monitor.ini"

IniRead, GUI_bgrd, %settings_ini%, Window , GUI_background	

if(GUI_bgrd!="ERROR" && GUI_bgrd!=""){
			bgrd_grad:=GUI_bgrd
}else{
	IniWrite, %bgrd_grad%	, %settings_ini%, Window, GUI_background
}

IniRead, clock_GUI_bgrd, %settings_ini%, Window , GUI_background_clock	

if(GUI_bgrd!="ERROR" && GUI_bgrd!=""){
			clock_bgrd_grad:=clock_GUI_bgrd
}else{
	IniWrite, %clock_bgrd_grad%	, %settings_ini%, Window, GUI_background_clock
}

;===============================

SysGet, MonitorWorkArea, MonitorWorkArea, 1
pos_x:=A_ScreenWidth - 140
pos_y:= MonitorWorkAreaBottom -380


	IniRead, pos_x_saved, %settings_ini%, window position, x	
	IniRead, pos_y_saved, %settings_ini%, window position, y	

if(pos_x_saved!="ERROR" && pos_x_saved!="" && pos_y_saved!="ERROR" && pos_y_saved!=""){
	if(pos_x_saved<A_ScreenWidth-120 && pos_y_saved<A_ScreenHeight-140){
			pos_x:=pos_x_saved
			pos_y:=pos_y_saved
	}
}

;===============================



Gui,1: +ToolWindow -border  +HwndGuiHwnd  +AlwaysOnTop	
WonTop:=1
Gui,1:Color, 120F00
Gui, 1: -DPIScale

Gui, Add, Picture, x0 y0 h166 w135 vbgrd 0xE, 
GoSub, bgrd

Gui,1: Add, Picture, x0 y0 w134 h15 vramkaT 0xE, 
Gui,1: Font, S7 w700 cE1E1E1 , Segoe UI ; Tahoma 
Gui,1: Add, Text , x18 y1 w100  gDoubleClick  BackgroundTrans  Center, Drozd CPU Monitor  ; gGoToSavedPos

Gui,1: Font, S7 w700 cD0D0D0 , Segoe UI ;
Gui,1: Add, Text , x122 y1 w10 h10 cD0D0D0 gexit BackgroundTrans Center ,  X 

Gui,1: Font, S6 w700 c9C9C9C , Segoe UI
Gui,1: Add, Text , x3 y1  c676767 vonTop_off gonTop BackgroundTrans,  % Chr(9675) ; ○
Gui,1: Font, S9
Gui,1: Add, Text , x3 y+-13  c676767 vonTop_on gonTop BackgroundTrans, % Chr(9679) ;  ● 
GuiControl, Hide, onTop_off


/* Gui,1: Font, S7 w700 cE1E1E1 , Tahoma 
Gui,1: Add, Text , x17 y4 w100  gGoToSavedPos  BackgroundTrans  Center, Drozd Monitor
 */
Gui, 1: Add, Picture, x6 y22 w122 h31 0xE vGrid_img, 
Gui,1: Font, S6 w700 cD0D0D0 , Tahoma ;Arial

Gui,1: Add, Text , 		x9 y65 BackgroundTrans Center, CPU
Gui,1: Add, Text , 		x9 y85 BackgroundTrans Center, RAM
Gui,1: Add, Picture, x37 y62  w90 h14 0xE vProgressBar2
Gui,1: Add, Picture, x37 y83  w90 h12 0xE vProgressBar3

; ramka:
Gui, 1: Add, Picture, x22 y105 w92 h40 vramka BackgroundTrans 0xE,  
GoSub, ramka

Gui,1: Font, S8 w700 cE1E1E1 , Arial  ;Segoe UI ;
Gui,1: Add, Text , x25 y107 w88 cE6B375 vtime_d   BackgroundTrans Center,
;Gui,1: Font, S7 w700 cE1E1E1 , Arial    ;Segoe UI ;
;Gui,1: Add, Text , x27 y108 w84 cE6B375 vtime_d  BackgroundTrans  Center, ;cC11616

Gui,1: Font, S11 w700 cF4F4F4 , Segoe UI 
Gui,1: Add, Text , x28 y120 w50 cE1E1E1 vtime_t1  BackgroundTrans  Right, ;cCE0D0D
Gui,1: Font, S8 w700 cE1E1E1, Segoe UI 
Gui,1: Add, Text , x+2 y124 w22 cF4F4F4 vtime_t2  BackgroundTrans  Left, ;cC11010

;Gui,1: Font, S7 w700 cD0D0D0 , Arial
;Gui,1: Add, Text , x14 y149 w110 cA3A1BC vtime_on  BackgroundTrans  Center, 

Gui,1: Font, S7 w400 cA3A1BC , Segoe UI
Gui,1: Add, Text , x23 y148    BackgroundTrans  Center, up time:
Gui,1: Font, S7 w700 cA3A1BC , ;Arial
Gui,1: Add, Text , x61 y148 w80 vtime_on   BackgroundTrans Left, 

/* ;Gui, 1: Show, w128 h145  , Drozd_monitor
Gui, 1: Show,  x%pos_x% y%pos_y% w128 h160  , Drozd_monitor
WinSet, Style, -0xC00000, Drozd_monitor ; COMPLETELY remove window border
;Winset, Transparent,200, Drozd_monitor  

 */
Gui,1: -caption
Gui,1: Show, Hide x%pos_x% y%pos_y% w134 h166 , Drozd_monitor
DllCall( "AnimateWindow", "Int", GuiHwnd, "Int", 200, "Int", 0x00000004 )
;DllCall( "AnimateWindow", "Int", GuiHwnd, "Int", 300, "Int", 0x00000010 )



OnMessage(0x201, "WM_LBUTTONDOWN") ; movable borderless window   
OnMessage(0x404, "AHK_NOTIFYICON") ;click tray icon to show

GoSub, onTop
GoSub, time_on
GoSub, time_date
GoSub, CPU_use
GoSub, memory_all
GoSub, grid_CPU

	GoSub, start_timers
return


start_timers:
Settimer, time_date ,1000
Settimer, time_on ,30000

Settimer, CPU_use ,1000
Settimer, memory_all ,3000

Settimer, grid_CPU ,1000
return

WM_LBUTTONDOWN(){
	if (A_Gui=1){
	PostMessage, 0xA1, 2    ; movable borderless window 
	}
}

AHK_NOTIFYICON(wParam, lParam){ ;click tray icon to show
    if (lParam = 0x202) {       ; WM_LBUTTONUP
				Gui,1:Show  				
    }else if (lParam = 0x203){   ; WM_LBUTTONDBLCLK
		}
}
;======================================


CPU_use:
	CPU:=CPULoad() 

	CPU_draw:=grid_h - Round(grid_h*(CPU/100))
	CPU_draw:=CPU_draw-1

	array_cpu.InsertAt(1,CPU_draw )
	array_cpu.Pop()

	grad_col:="0xff8F4A00|0xffFF9A00|7"

	if(CPU>50){
		grad_col:="0xff4C2700|0xffFD1900|7"
	}else{
		grad_col:="0xff4C2700|0xffFD8300|7"
	}	 
	
CPU2:=manip(CPU)

Gdip_SetProgress(ProgressBar2, CPU2, grad_col, 0xff2C2C2C , CPU "`%","x0p y2p s76p Center cffEEEEEE r5 Bold")
; FD8300 ;FFBC00, pomar 
return

 manip(CPU){
	if(CPU<5 && CPU>0)
		CPU:=CPU + 5
	return CPU
 }
 
memory_all:
	GMSEx := GlobalMemoryStatusEx()
	GMSExM01 := Round(GMSEx[2] / 1024**2, 2)            ; Total Physical Memory in MB
	GMSExM02 := Round(GMSEx[3] / 1024**2, 2)            ; Available Physical Memory in MB
	GMSExM03 := Round(GMSExM01 - GMSExM02, 2)           ; Used Physical Memory in MB
	GMSExM04 := Round(GMSExM03 / GMSExM01 * 100)     ; Used Physical Memory in %
	
; Gdip_SetProgress(ProgressBar3, GMSExM04, "0xff004614|0xaa01DC3F|6", 0xff2C2C2C , GMSExM04 "`%","x0p y2p s78p Center cffEEEEEE r5 Bold")
 
/* 	grad_col_green :="0xff004614|0xaa01DC3F|6"
 	grad_col_blue:="0xff031661|0xff008FDC|6"  ,	grad_col_blue_2:="0xff012243|0xff008FDC|6"
	grad_col_steel:="0xff143268|0xff215EC7|6"
	grad_color:=grad_col_green 
	*/
	Gdip_SetProgress(ProgressBar3, GMSExM04, grad_color, 0xff2C2C2C , GMSExM04 "`%","x0p y2p s78p Center cffEEEEEE r5 Bold")
	
return

grid_CPU:
Gdip_Set_Grid(Grid_img, 0xffE36524, 0xFF131313) ;0xff2C2C2C
return

;======================================


Gdip_Set_Grid(ByRef Variable, Foreground=0xffE36524, Background=0xFF101010 ){
	GuiControlGet, Pos, Pos, Variable
	GuiControlGet, hwnd, hwnd, Variable  
	
	pBitmap := Gdip_CreateBitmap(Posw, Posh), G := Gdip_GraphicsFromImage(pBitmap), Gdip_SetSmoothingMode(G, 4)	

	pBrushBack := Gdip_BrushCreateSolid(Background)	
	Gdip_FillRectangle(G, pBrushBack, 0, 0, PosW-1, PosH-1)	


		;pBrushFront := Gdip_BrushCreateSolid(Foreground)
    ;Gdip_FillRectangle(G, pBrushFront, 0, 0, 50, Posh)
  
		;<==== Grid
		
    pPen:=Gdip_CreatePen(0xff2E5050, 1)
    w:=PosW -2 ,  h:=PosH-2    

	Loop, 4 {
    y:=A_Index*6
		Gdip_DrawLine(G, pPen, 1, y, w, y)
  } 

  Loop, 14 {
    x:=A_Index*8
		Gdip_DrawLine(G, pPen, x, 1, x, h)
  } 
  ;====> Grid
	
	;<==== plot

	;grid_h:=29, grid_w:=121
	points:="0,29|121,29|"	
  Loop, % array_cpu.Length() {
    x:=121 - A_Index

		y:=array_cpu[A_Index]
    points:= points  x "," y "|"
  } 	
	points:= points x ",29"
	
	
		pBrushFront := Gdip_BrushCreateSolid(Foreground)
    pPath := Gdip_CreatePath(0)
    Gdip_AddPathPolygon(pPath,points)  
    Gdip_FillPath(G,pBrushFront, pPath) 
		
	hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
	SetImage(hwnd, hBitmap)
	
	Gdip_DeleteBrush(pBrushFront), Gdip_DeleteBrush(pBrushBack), Gdip_DeletePen(pPen), Gdip_DeletePath(pPath)
	Gdip_DeleteGraphics(G), Gdip_DisposeImage(pBitmap), DeleteObject(hBitmap)
	Return, 0
}



Gdip_SetProgress(ByRef Variable, Percentage, Foreground, Background=0x00000000, Text="", TextOptions="x0p y10p s70p Center cffEEEEEE r5 Bold", Font="Arial"){
	GuiControlGet, Pos, Pos, Variable
	GuiControlGet, hwnd, hwnd, Variable  
	
	pBitmap := Gdip_CreateBitmap(Posw, Posh), G := Gdip_GraphicsFromImage(pBitmap), Gdip_SetSmoothingMode(G, 4)	

	pBrushBack := Gdip_BrushCreateSolid(Background)	
	;Gdip_FillRectangle(G, pBrushBack,0, 0, Posw, Posh)	
	Gdip_FillRectangle(G, pBrushBack,-1, -1, Posw+1, Posh+1)	
	
	Foreground_:=StrSplit(Foreground,"|")
	if(Foreground_.Length() >1){
		;=== with gradient =====
		grad_color_rim:=Foreground_[1]
		grad_color_mid:=Foreground_[2]
		size:=Foreground_[3]
		pBrushFront := Gdip_CreateLineBrushFromRect(0, 0, 1, size, grad_color_rim, grad_color_mid ,1) 
		;Gdip_FillRectangle(G, pBrushFront,0, 0,  Posw*(Percentage/100), Posh)
		Gdip_FillRectangle(G, pBrushFront,-1, -1,  Posw*(Percentage/100)+1, Posh+1)
	;========
	}else{
		pBrushFront := Gdip_BrushCreateSolid(Foreground)
		;Gdip_FillRectangle(G, pBrushFront, 0, 0, Posw*(Percentage/100), Posh)
		Gdip_FillRectangle(G, pBrushFront, -1, -1, Posw*(Percentage/100)+1, Posh+1)
	}

	Gdip_TextToGraphics(G, Text, TextOptions, Font, Posw, Posh)
	hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
	SetImage(hwnd, hBitmap)
	
	Gdip_DeleteBrush(pBrushFront), Gdip_DeleteBrush(pBrushBack)
	Gdip_DeleteGraphics(G), Gdip_DisposeImage(pBitmap), DeleteObject(hBitmap)
	Return, 0
}


;=============================


bgrd:
	IniRead, bgrd_style, %settings_ini%, Window , GUI_style	
	if(bgrd_style=="dots"){
		Gdip_Set_bgrd(bgrd, bgrd_grad,6) ; dots
	}else if(bgrd_style=="bricks"){
		Gdip_Set_bgrd(bgrd, bgrd_grad,39) ; bricks
	}else{
		Gdip_Set_bgrd(bgrd, bgrd_grad) 
	}

;Gdip_Set_bgrd(bgrd, "0xff0F0F0F|0xff222222|25" ) ;black
;Gdip_Set_bgrd(bgrd, "0xff2D3F5D|0xff1A2333|25" ) ; bl steel

;Gdip_Set_bgrd(bgrd, "0xff00290C|0xff1C4527|75" ) ; green
;Gdip_Set_bgrd(bgrd, "0xff012243|0xff13365A|75" ) ;blue
return



Gdip_Set_bgrd(ByRef Variable, Background=0x00000000,Hatch=0){
	GuiControlGet, Pos, Pos, Variable
	GuiControlGet, hwnd, hwnd, Variable  
	
	pBitmap := Gdip_CreateBitmap(Posw, Posh), G := Gdip_GraphicsFromImage(pBitmap), Gdip_SetSmoothingMode(G, 4)	
	
	Background_:=StrSplit(Background,"|")
	if(Background_.Length() >1){
		;=== with gradient =====
		;pBrushFront := Gdip_CreateLineBrushFromRect(0, 0, 1, 10, grad_color1, grad_color2 ,1) 
		grad_color_rim:=Background_[1]
		grad_color_mid:=Background_[2]
		size:=Background_[3]
    ;MsgBox,,, %  grad_color_mid "`n" grad_color_rim, 6  
		if(Hatch=0){
			pBrushFront := Gdip_CreateLineBrushFromRect(0, 0, 1, size, grad_color_rim, grad_color_mid ,1) 
		}else{
			pBrushFront :=Gdip_BrushCreateHatch(grad_color_rim, grad_color_mid, Hatch) ; kropki
		}
		Gdip_FillRectangle(G, pBrushFront,-1, -1,  PosW+1, Posh+1)
	;========
	}else{
		pBrushBack := Gdip_BrushCreateSolid(Background)
		Gdip_FillRectangle(G, pBrushBack, 0, 0, PosW, Posh)
	}

	
	hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
	SetImage(hwnd, hBitmap)
	
	Gdip_DeleteBrush(pBrushFront), Gdip_DeleteBrush(pBrushBack)
	Gdip_DeleteGraphics(G), Gdip_DisposeImage(pBitmap), DeleteObject(hBitmap)
	Return, 0
}
;=============================
ramka:
	;clock_bgrd_grad:="0xff383838|0xff0F0F0F|30"
	;Gdip_Set_ramka(ramka,clock_bgrd_grad)
	Gdip_Set_bgrd(ramka,clock_bgrd_grad)
	Gdip_Set_bgrd(ramkaT,"0xff383D46|0xff1E2126|8",0)
return




;==================================
CPULoad(){ ; By SKAN, 
  Static PIT, PKT, PUT                           ; http://ahkscript.org/boards/viewtopic.php?p=17166#p17166
  IfEqual, PIT,, Return 0, DllCall( "GetSystemTimes", "Int64P",PIT, "Int64P",PKT, "Int64P",PUT )

  DllCall( "GetSystemTimes", "Int64P",CIT, "Int64P",CKT, "Int64P",CUT )
, IdleTime := PIT - CIT,    KernelTime := PKT - CKT,    UserTime := PUT - CUT
, SystemTime := KernelTime + UserTime 

  Return ( ( SystemTime - IdleTime ) * 100 ) // SystemTime,    PIT := CIT,    PKT := CKT,    PUT := CUT 
}



GlobalMemoryStatusEx() { ; https://autohotkey.com/board/topic/116074-get-memory-info/
    static MEMORYSTATUSEX, init := VarSetCapacity(MEMORYSTATUSEX, 64, 0) && NumPut(64, MEMORYSTATUSEX, "UInt")
    if (DllCall("Kernel32.dll\GlobalMemoryStatusEx", "Ptr", &MEMORYSTATUSEX))
    {
        return { 2 : NumGet(MEMORYSTATUSEX, 8, "UInt64")
        , 3 : NumGet(MEMORYSTATUSEX, 16, "UInt64")
        , 4 : NumGet(MEMORYSTATUSEX, 24, "UInt64")
        , 5 : NumGet(MEMORYSTATUSEX, 32, "UInt64") }
    }
}
 
/* 
GMSEx := GlobalMemoryStatusEx()
GMSExM01 := Round(GMSEx[2] / 1024**2, 2)            ; Total Physical Memory in MB
GMSExM02 := Round(GMSEx[3] / 1024**2, 2)            ; Available Physical Memory in MB
GMSExM03 := Round(GMSExM01 - GMSExM02, 2)           ; Used Physical Memory in MB
GMSExM04 := Round(GMSExM03 / GMSExM01 * 100, 2)     ; Used Physical Memory in %
GMSExS01 := Round(GMSEx[4] / 1024**2, 2)            ; Total PageFile in MB
GMSExS02 := Round(GMSEx[5] / 1024**2, 2)            ; Available PageFile in MB
GMSExS03 := Round(GMSExS01 - GMSExS02, 2)           ; Used PageFile in MB
GMSExS04 := Round(GMSExS03 / GMSExS01 * 100, 2)     ; Used PageFile in %
MsgBox,,, % Round((GMSExM03/GMSExM01)*100) " %"
 */
 
 
    

time_from_sec(milisec){		
	sec:=milisec/1000
	h := Floor(sec/3600)
	m := sec>3600 ? Floor(mod(sec,3600)/60) : Floor(sec/60)
	day:=Floor(h/24)
	h1 := mod(h,24)
	;s := Floor(mod(sec,60))
   return day " day " h1 ":" dig(m) " h" ;" h " h ;":" s
}

dig(num){ ;to_two_digits
   num:= num<=9 ? "0" . num : num
   return num
}

time_on:
time_:=time_from_sec(A_TickCount)
GuiControl,, time_on, %time_%
;GuiControl,, time_on, up time: %time_%
return


/* time_date:
	FormatTime, Data,, d MMM, ddd  ;d MMM, yyyy, ddd HH:mm:ss
	;GuiControl,, time_d, %Data%
		if(Data != Data_old){
			GuiControl,, time_d, %Data%
			Data_old:=Data
	}
	FormatTime, time1,,  HH:mm:ss 
	
	GuiControl,, time_t, %time1%
return
 */
time_date:
	;FormatTime, Data,, d MMM, dddd 
	FormatTime, Data,, ddd, d MMM 
	;GuiControl,, time_d, %Data%
	if(Data != Data_old){
			GuiControl,, time_d, %Data%
			Data_old:=Data
	}
	
	FormatTime, time1,,  H:mm	
	;GuiControl,, time_t1, %time1%
	if(time1 != time1_old){
		GuiControl,, time_t1, %time1%
		time1_old:=time1
	}	

	FormatTime, time2,, ss 	
	GuiControl,, time_t2,  : %time2%	
return

GoToSavedPos: ; DoubleClick
	;if A_GuiControlEvent <> DoubleClick
	;	return
	IniRead, pos_x_saved, %settings_ini%, window position, x	
	IniRead, pos_y_saved, %settings_ini%, window position, y	
	if(pos_x_saved<A_ScreenWidth-120 && pos_y_saved<A_ScreenHeight-140)
		WinMove,  Drozd_monitor, ,pos_x_saved,pos_y_saved
return

DoubleClick:
	;if A_GuiControlEvent <> DoubleClick
	;	return
return

DisableWindowsFeature(){ ; prevent copy to  clipboard when double clicked ; by just me autohotkey.com/boards/viewtopic.php?t=3569
   Static Dummy1 := OnMessage(0x00A3, "DisableWindowsFeature") ; WM_NCLBUTTONDBLCLK
   Static Dummy2 := OnMessage(0x0203, "DisableWindowsFeature") ; WM_LBUTTONDBLCLK
   If (A_GuiControl) {
      GuiControlGet, HCTRL, Hwnd, %A_GuiControl%
      WinGetClass, Class, ahk_id %HCTRL%
      If (Class = "Static")
				if(A_GuiControl="Drozd CPU Monitor"){					
					Gosub, GoToSavedPos
				}			 
         Return 0
   }
}

;=========================================

set_bgrd_black:
IniWrite, %bgrd_grad_black%	, %settings_ini%, Window, GUI_background
clock_bgrd_grad:=clock_grad_black 
IniWrite, %clock_grad_black%	, %settings_ini%, Window, GUI_background_clock
return

set_bgrd_steel:
IniWrite, %bgrd_grad_steel%	, %settings_ini%, Window, GUI_background
clock_bgrd_grad:=clock_grad_steel 
IniWrite, %clock_grad_steel%	, %settings_ini%, Window, GUI_background_clock
return

set_bgrd_blue:
IniWrite, %bgrd_grad_blue%	, %settings_ini%, Window, GUI_background
clock_bgrd_grad:=clock_grad_blue 
IniWrite, %clock_grad_blue%	, %settings_ini%, Window, GUI_background_clock
return

set_bgrd_green:
IniWrite, %bgrd_grad_green%	, %settings_ini%, Window, GUI_background
clock_bgrd_grad:=clock_grad_green  
IniWrite, %clock_grad_green%	, %settings_ini%, Window, GUI_background_clock
return

set_bgrd_style_bricks:
bgrd_style:="bricks" 
IniWrite, %bgrd_style%	, %settings_ini%, Window, GUI_style
return

set_bgrd_style_dots:
bgrd_style:="dots"
IniWrite, %bgrd_style%	, %settings_ini%, Window, GUI_style
return

reset_bgrd:
bgrd_style:=""
IniDelete, %settings_ini%, Window,
return


;=========================================

save_position:
	WinGetPos, x1,y1,,, ahk_id %GuiHwnd%
	IniWrite, %x1%	, %settings_ini%, window position, x
	IniWrite, %y1%	, %settings_ini%, window position, y
return

Open_ini:
Run, %settings_ini%
return

;=========================================

onTop:        
		if (WonTop=1) {
			WinSet, AlwaysOnTop, off, Drozd_monitor
			GuiControl, Show, onTop_off
			GuiControl, Hide, onTop_on
			WonTop:=0	
		}else{
			WinSet, AlwaysOnTop, on, Drozd_monitor
			GuiControl, Show, onTop_on
			GuiControl, Hide, onTop_off	
			WonTop:=1			
		}	
return
 
 
;=========================================



Close:
;Esc:: 
GuiClose:
Exit:
Gdip_Shutdown(pToken)
DllCall( "AnimateWindow", "Int", GuiHwnd, "Int", 200, "Int", 0x00050008 )
ExitApp
Return







Reload:
Reload
return

GuiContextMenu:
Menu, ContextMenu, Show, %A_GuiX%, %A_GuiY%
Return

WindowSpy:
Run, "C:\Program Files\AutoHotkey\WindowSpy.ahk"
return

Edit_Notepad:
Run, "C:\Program Files\Misc\Notepad2\Notepad2.exe" "%A_ScriptFullPath%"
return

Edit_Scite:
Run, "C:\Program Files\AutoHotkey\SciTE\SciTE.exe"  "%A_ScriptFullPath%"
return




;===================== #Include Gdip.ahk library by tic OR directly functions below
;#Include Gdip.ahk
;https://autohotkey.com/boards/viewtopic.php?t=6517
; https://github.com/tariqporter/Gdip/blob/master/Gdip.ahk




Gdip_Startup()
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	
	if !DllCall("GetModuleHandle", "str", "gdiplus", Ptr)
		DllCall("LoadLibrary", "str", "gdiplus")
	VarSetCapacity(si, A_PtrSize = 8 ? 24 : 16, 0), si := Chr(1)
	DllCall("gdiplus\GdiplusStartup", A_PtrSize ? "UPtr*" : "uint*", pToken, Ptr, &si, Ptr, 0)
	return pToken
}

Gdip_Shutdown(pToken)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	
	DllCall("gdiplus\GdiplusShutdown", Ptr, pToken)
	if hModule := DllCall("GetModuleHandle", "str", "gdiplus", Ptr)
		DllCall("FreeLibrary", Ptr, hModule)
	return 0
}


UpdateLayeredWindow(hwnd, hdc, x="", y="", w="", h="", Alpha=255)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	
	if ((x != "") && (y != ""))
		VarSetCapacity(pt, 8), NumPut(x, pt, 0, "UInt"), NumPut(y, pt, 4, "UInt")

	if (w = "") ||(h = "")
		WinGetPos,,, w, h, ahk_id %hwnd%
   
	return DllCall("UpdateLayeredWindow"
					, Ptr, hwnd
					, Ptr, 0
					, Ptr, ((x = "") && (y = "")) ? 0 : &pt
					, "int64*", w|h<<32
					, Ptr, hdc
					, "int64*", 0
					, "uint", 0
					, "UInt*", Alpha<<16|1<<24
					, "uint", 2)
}


SetImage(hwnd, hBitmap)
{
	SendMessage, 0x172, 0x0, hBitmap,, ahk_id %hwnd%
	E := ErrorLevel
	DeleteObject(E)
	return E
}

Gdip_BitmapFromHWND(hwnd)
{
	WinGetPos,,, Width, Height, ahk_id %hwnd%
	hbm := CreateDIBSection(Width, Height), hdc := CreateCompatibleDC(), obm := SelectObject(hdc, hbm)
	PrintWindow(hwnd, hdc)
	pBitmap := Gdip_CreateBitmapFromHBITMAP(hbm)
	SelectObject(hdc, obm), DeleteObject(hbm), DeleteDC(hdc)
	return pBitmap
}

Gdip_CreateHBITMAPFromBitmap(pBitmap, Background=0xffffffff)
{
	DllCall("gdiplus\GdipCreateHBITMAPFromBitmap", A_PtrSize ? "UPtr" : "UInt", pBitmap, A_PtrSize ? "UPtr*" : "uint*", hbm, "int", Background)
	return hbm
}

CreateCompatibleDC(hdc=0)
{
   return DllCall("CreateCompatibleDC", A_PtrSize ? "UPtr" : "UInt", hdc)
}

SelectObject(hdc, hgdiobj)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	
	return DllCall("SelectObject", Ptr, hdc, Ptr, hgdiobj)
}

CreateDIBSection(w, h, hdc="", bpp=32, ByRef ppvBits=0)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	
	hdc2 := hdc ? hdc : GetDC()
	VarSetCapacity(bi, 40, 0)
	
	NumPut(w, bi, 4, "uint")
	, NumPut(h, bi, 8, "uint")
	, NumPut(40, bi, 0, "uint")
	, NumPut(1, bi, 12, "ushort")
	, NumPut(0, bi, 16, "uInt")
	, NumPut(bpp, bi, 14, "ushort")
	
	hbm := DllCall("CreateDIBSection"
					, Ptr, hdc2
					, Ptr, &bi
					, "uint", 0
					, A_PtrSize ? "UPtr*" : "uint*", ppvBits
					, Ptr, 0
					, "uint", 0, Ptr)

	if !hdc
		ReleaseDC(hdc2)
	return hbm
}

Gdip_SetSmoothingMode(pGraphics, SmoothingMode)
{
   return DllCall("gdiplus\GdipSetSmoothingMode", A_PtrSize ? "UPtr" : "UInt", pGraphics, "int", SmoothingMode)
}


Gdip_GraphicsFromHDC(hdc)
{
    DllCall("gdiplus\GdipCreateFromHDC", A_PtrSize ? "UPtr" : "UInt", hdc, A_PtrSize ? "UPtr*" : "UInt*", pGraphics)
    return pGraphics
}



Gdip_CreatePen(ARGB, w)
{
   DllCall("gdiplus\GdipCreatePen1", "UInt", ARGB, "float", w, "int", 2, A_PtrSize ? "UPtr*" : "UInt*", pPen)
   return pPen
}


Gdip_CloneBrush(pBrush)
{
	DllCall("gdiplus\GdipCloneBrush", A_PtrSize ? "UPtr" : "UInt", pBrush, A_PtrSize ? "UPtr*" : "UInt*", pBrushClone)
	return pBrushClone
}



Gdip_BrushCreateSolid(ARGB=0xff000000)
{
	DllCall("gdiplus\GdipCreateSolidFill", "int", ARGB, "uint*", pBrush)
	return pBrush
}


Gdip_CreateLineBrushFromRect(x, y, w, h, ARGB1, ARGB2, LinearGradientMode=1, WrapMode=1)
{
	CreateRectF(RectF, x, y, w, h)
	DllCall("gdiplus\GdipCreateLineBrushFromRect", "uint", &RectF, "int", ARGB1, "int", ARGB2, "int", LinearGradientMode, "int", WrapMode, "uint*", LGpBrush)
	return LGpBrush
}


Gdip_CreatePath(BrushMode=0)
{
	DllCall("gdiplus\GdipCreatePath", "int", BrushMode, "uint*", Path)
	return Path
}

Gdip_AddPathEllipse(Path, x, y, w, h)
{
	return DllCall("gdiplus\GdipAddPathEllipse", "uint", Path, "float", x, "float", y, "float", w, "float", h)
}

Gdip_AddPathPolygon(Path, Points)
{
	StringSplit, Points, Points, |
	VarSetCapacity(PointF, 8*Points0)   
	Loop, %Points0%
	{
		StringSplit, Coord, Points%A_Index%, `,
		NumPut(Coord1, PointF, 8*(A_Index-1), "float"), NumPut(Coord2, PointF, (8*(A_Index-1))+4, "float")
	}   

	return DllCall("gdiplus\GdipAddPathPolygon", "uint", Path, "uint", &PointF, "int", Points0)
}

Gdip_DeletePath(Path)
{
	return DllCall("gdiplus\GdipDeletePath", "uint", Path)
}


Gdip_FillPath(pGraphics, pBrush, Path)
{
	return DllCall("gdiplus\GdipFillPath", "uint", pGraphics, "uint", pBrush, "uint", Path)
}

PrintWindow(hwnd, hdc, Flags=0)
{
	return DllCall("PrintWindow", "uint", hwnd, "uint", hdc, "uint", Flags)
}


Gdip_CreateBitmapFromHBITMAP(hBitmap, Palette=0)
{
	DllCall("gdiplus\GdipCreateBitmapFromHBITMAP", "uint", hBitmap, "uint", Palette, "uint*", pBitmap)
	return pBitmap
}

Gdip_GetDC(pGraphics)
{
	DllCall("gdiplus\GdipGetDC", "uint", pGraphics, "uint*", hdc)
	return hdc
}
GetDC(hwnd=0)
{
	return DllCall("GetDC", "uint", hwnd)
}

DeleteObject(hObject)
{
   return DllCall("DeleteObject", A_PtrSize ? "UPtr" : "UInt", hObject)
}

DeleteDC(hdc)
{
   return DllCall("DeleteDC", "uint", hdc)
}

ReleaseDC(hdc, hwnd=0)
{
   return DllCall("ReleaseDC", "uint", hwnd, "uint", hdc)
}



CreateRectF(ByRef RectF, x, y, w, h)
{
   VarSetCapacity(RectF, 16)
   NumPut(x, RectF, 0, "float"), NumPut(y, RectF, 4, "float"), NumPut(w, RectF, 8, "float"), NumPut(h, RectF, 12, "float")
}


Gdip_DrawRectangle(pGraphics, pPen, x, y, w, h)
{
   return DllCall("gdiplus\GdipDrawRectangle", "uint", pGraphics, "uint", pPen, "float", x, "float", y, "float", w, "float", h)
}


Gdip_DrawEllipse(pGraphics, pPen, x, y, w, h)
{
   return DllCall("gdiplus\GdipDrawEllipse", "uint", pGraphics, "uint", pPen, "float", x, "float", y, "float", w, "float", h)
}

Gdip_FillRoundedRectangle(pGraphics, pBrush, x, y, w, h, r)
{
	Region := Gdip_GetClipRegion(pGraphics)
	Gdip_SetClipRect(pGraphics, x-r, y-r, 2*r, 2*r, 4)
	Gdip_SetClipRect(pGraphics, x+w-r, y-r, 2*r, 2*r, 4)
	Gdip_SetClipRect(pGraphics, x-r, y+h-r, 2*r, 2*r, 4)
	Gdip_SetClipRect(pGraphics, x+w-r, y+h-r, 2*r, 2*r, 4)
	E := Gdip_FillRectangle(pGraphics, pBrush, x, y, w, h)
	Gdip_SetClipRegion(pGraphics, Region, 0)
	Gdip_SetClipRect(pGraphics, x-(2*r), y+r, w+(4*r), h-(2*r), 4)
	Gdip_SetClipRect(pGraphics, x+r, y-(2*r), w-(2*r), h+(4*r), 4)
	Gdip_FillEllipse(pGraphics, pBrush, x, y, 2*r, 2*r)
	Gdip_FillEllipse(pGraphics, pBrush, x+w-(2*r), y, 2*r, 2*r)
	Gdip_FillEllipse(pGraphics, pBrush, x, y+h-(2*r), 2*r, 2*r)
	Gdip_FillEllipse(pGraphics, pBrush, x+w-(2*r), y+h-(2*r), 2*r, 2*r)
	Gdip_SetClipRegion(pGraphics, Region, 0)
	Gdip_DeleteRegion(Region)
	return E
}


Gdip_SetClipRect(pGraphics, x, y, w, h, CombineMode=0)
{
   return DllCall("gdiplus\GdipSetClipRect", "uint", pGraphics, "float", x, "float", y, "float", w, "float", h, "int", CombineMode)
}

Gdip_SetClipPath(pGraphics, Path, CombineMode=0)
{
   return DllCall("gdiplus\GdipSetClipPath", "uint", pGraphics, "uint", Path, "int", CombineMode)
}

Gdip_ResetClip(pGraphics)
{
   return DllCall("gdiplus\GdipResetClip", "uint", pGraphics)
}

Gdip_GetClipRegion(pGraphics)
{
	Region := Gdip_CreateRegion()
	DllCall("gdiplus\GdipGetClip", "uint" pGraphics, "uint*", Region)
	return Region
}

Gdip_SetClipRegion(pGraphics, Region, CombineMode=0)
{
	return DllCall("gdiplus\GdipSetClipRegion", "uint", pGraphics, "uint", Region, "int", CombineMode)
}

Gdip_CreateRegion()
{
	DllCall("gdiplus\GdipCreateRegion", "uint*", Region)
	return Region
}

Gdip_DeleteRegion(Region)
{
	return DllCall("gdiplus\GdipDeleteRegion", "uint", Region)
}


Gdip_FillRectangle(pGraphics, pBrush, x, y, w, h)
{
   return DllCall("gdiplus\GdipFillRectangle", "uint", pGraphics, "int", pBrush
   , "float", x, "float", y, "float", w, "float", h)
}

Gdip_FillEllipse(pGraphics, pBrush, x, y, w, h)
{
	return DllCall("gdiplus\GdipFillEllipse", "uint", pGraphics, "uint", pBrush, "float", x, "float", y, "float", w, "float", h)
}


Gdip_GraphicsFromImage(pBitmap)
{
    DllCall("gdiplus\GdipGetImageGraphicsContext", "uint", pBitmap, "uint*", pGraphics)
    return pGraphics
}

Gdip_CreateBitmap(Width, Height, Format=0x26200A)
{
    DllCall("gdiplus\GdipCreateBitmapFromScan0", "int", Width, "int", Height, "int", 0, "int", Format, "uint", 0, "uint*", pBitmap)
    Return pBitmap
}


Gdip_DrawLine(pGraphics, pPen, x1, y1, x2, y2)
{
   return DllCall("gdiplus\GdipDrawLine", "uint", pGraphics, "uint", pPen
   , "float", x1, "float", y1, "float", x2, "float", y2)
}


Gdip_DrawLines(pGraphics, pPen, Points)
{
   StringSplit, Points, Points, |
   VarSetCapacity(PointF, 8*Points0)   
   Loop, %Points0%
   {
      StringSplit, Coord, Points%A_Index%, `,
      NumPut(Coord1, PointF, 8*(A_Index-1), "float"), NumPut(Coord2, PointF, (8*(A_Index-1))+4, "float")
   }
   return DllCall("gdiplus\GdipDrawLines", "uint", pGraphics, "uint", pPen, "uint", &PointF, "int", Points0)
}



Gdip_TextToGraphics(pGraphics, Text, Options, Font="Arial", Width="", Height="", Measure=0)
{
	IWidth := Width, IHeight:= Height
	
	RegExMatch(Options, "i)X([\-\d\.]+)(p*)", xpos)
	RegExMatch(Options, "i)Y([\-\d\.]+)(p*)", ypos)
	RegExMatch(Options, "i)W([\-\d\.]+)(p*)", Width)
	RegExMatch(Options, "i)H([\-\d\.]+)(p*)", Height)
	RegExMatch(Options, "i)C(?!(entre|enter))([a-f\d]+)", Colour)
	RegExMatch(Options, "i)Top|Up|Bottom|Down|vCentre|vCenter", vPos)
	RegExMatch(Options, "i)NoWrap", NoWrap)
	RegExMatch(Options, "i)R(\d)", Rendering)
	RegExMatch(Options, "i)S(\d+)(p*)", Size)

	if !Gdip_DeleteBrush(Gdip_CloneBrush(Colour2))
		PassBrush := 1, pBrush := Colour2
	
	if !(IWidth && IHeight) && (xpos2 || ypos2 || Width2 || Height2 || Size2)
		return -1

	Style := 0, Styles := "Regular|Bold|Italic|BoldItalic|Underline|Strikeout"
	Loop, Parse, Styles, |
	{
		if RegExMatch(Options, "\b" A_loopField)
		Style |= (A_LoopField != "StrikeOut") ? (A_Index-1) : 8
	}
  
	Align := 0, Alignments := "Near|Left|Centre|Center|Far|Right"
	Loop, Parse, Alignments, |
	{
		if RegExMatch(Options, "\b" A_loopField)
			Align |= A_Index//2.1      ; 0|0|1|1|2|2
	}

	xpos := (xpos1 != "") ? xpos2 ? IWidth*(xpos1/100) : xpos1 : 0
	ypos := (ypos1 != "") ? ypos2 ? IHeight*(ypos1/100) : ypos1 : 0
	Width := Width1 ? Width2 ? IWidth*(Width1/100) : Width1 : IWidth
	Height := Height1 ? Height2 ? IHeight*(Height1/100) : Height1 : IHeight
	if !PassBrush
		Colour := "0x" (Colour2 ? Colour2 : "ff000000")
	Rendering := ((Rendering1 >= 0) && (Rendering1 <= 5)) ? Rendering1 : 4
	Size := (Size1 > 0) ? Size2 ? IHeight*(Size1/100) : Size1 : 12

	hFamily := Gdip_FontFamilyCreate(Font)
	hFont := Gdip_FontCreate(hFamily, Size, Style)
	FormatStyle := NoWrap ? 0x4000 | 0x1000 : 0x4000
	hFormat := Gdip_StringFormatCreate(FormatStyle)
	pBrush := PassBrush ? pBrush : Gdip_BrushCreateSolid(Colour)
	if !(hFamily && hFont && hFormat && pBrush && pGraphics)
		return !pGraphics ? -2 : !hFamily ? -3 : !hFont ? -4 : !hFormat ? -5 : !pBrush ? -6 : 0
   
	CreateRectF(RC, xpos, ypos, Width, Height)
	Gdip_SetStringFormatAlign(hFormat, Align)
	Gdip_SetTextRenderingHint(pGraphics, Rendering)
	ReturnRC := Gdip_MeasureString(pGraphics, Text, hFont, hFormat, RC)

	if vPos
	{
		StringSplit, ReturnRC, ReturnRC, |
		
		if (vPos = "vCentre") || (vPos = "vCenter")
			ypos += (Height-ReturnRC4)//2
		else if (vPos = "Top") || (vPos = "Up")
			ypos := 0
		else if (vPos = "Bottom") || (vPos = "Down")
			ypos := Height-ReturnRC4
		
		CreateRectF(RC, xpos, ypos, Width, ReturnRC4)
		ReturnRC := Gdip_MeasureString(pGraphics, Text, hFont, hFormat, RC)
	}

	if !Measure
		E := Gdip_DrawString(pGraphics, Text, hFont, hFormat, pBrush, RC)

	if !PassBrush
		Gdip_DeleteBrush(pBrush)
	Gdip_DeleteStringFormat(hFormat)   
	Gdip_DeleteFont(hFont)
	Gdip_DeleteFontFamily(hFamily)
	return E ? E : ReturnRC
}

Gdip_FontCreate(hFamily, Size, Style=0)
{
   DllCall("gdiplus\GdipCreateFont", "uint", hFamily, "float", Size, "int", Style, "int", 0, "uint*", hFont)
   return hFont
}


Gdip_FontFamilyCreate(Font)
{
	if !A_IsUnicode
	{
		nSize := DllCall("MultiByteToWideChar", "uint", 0, "uint", 0, "uint", &Font, "int", -1, "uint", 0, "int", 0)
		VarSetCapacity(wFont, nSize*2)
		DllCall("MultiByteToWideChar", "uint", 0, "uint", 0, "uint", &Font, "int", -1, "uint", &wFont, "int", nSize)
		DllCall("gdiplus\GdipCreateFontFamilyFromName", "uint", &wFont, "uint", 0, "uint*", hFamily)
	}
	else
		DllCall("gdiplus\GdipCreateFontFamilyFromName", "uint", &Font, "uint", 0, "uint*", hFamily)
	return hFamily
}

Gdip_StringFormatCreate(Format=0, Lang=0)
{
   DllCall("gdiplus\GdipCreateStringFormat", "int", Format, "int", Lang, "uint*", hFormat)
   return hFormat
}

Gdip_SetStringFormatAlign(hFormat, Align)
{
   return DllCall("gdiplus\GdipSetStringFormatAlign", "uint", hFormat, "int", Align)
}

Gdip_SetTextRenderingHint(pGraphics, RenderingHint)
{
	return DllCall("gdiplus\GdipSetTextRenderingHint", "uint", pGraphics, "int", RenderingHint)
}



Gdip_MeasureString(pGraphics, sString, hFont, hFormat, ByRef RectF)
{
	VarSetCapacity(RC, 16)
	if !A_IsUnicode
	{
		nSize := DllCall("MultiByteToWideChar", "uint", 0, "uint", 0, "uint", &sString, "int", -1, "uint", 0, "int", 0)
		VarSetCapacity(wString, nSize*2)   
		DllCall("MultiByteToWideChar", "uint", 0, "uint", 0, "uint", &sString, "int", -1, "uint", &wString, "int", nSize)
		DllCall("gdiplus\GdipMeasureString", "uint", pGraphics
		, "uint", &wString, "int", -1, "uint", hFont, "uint", &RectF, "uint", hFormat, "uint", &RC, "uint*", Chars, "uint*", Lines)
	}
	else
	{
		DllCall("gdiplus\GdipMeasureString", "uint", pGraphics
		, "uint", &sString, "int", -1, "uint", hFont, "uint", &RectF, "uint", hFormat, "uint", &RC, "uint*", Chars, "uint*", Lines)
	}
	return &RC ? NumGet(RC, 0, "float") "|" NumGet(RC, 4, "float") "|" NumGet(RC, 8, "float") "|" NumGet(RC, 12, "float") "|" Chars "|" Lines : 0
}

Gdip_DrawString(pGraphics, sString, hFont, hFormat, pBrush, ByRef RectF)
{
	if !A_IsUnicode
	{
		nSize := DllCall("MultiByteToWideChar", "uint", 0, "uint", 0, "uint", &sString, "int", -1, "uint", 0, "int", 0)
		VarSetCapacity(wString, nSize*2)
		DllCall("MultiByteToWideChar", "uint", 0, "uint", 0, "uint", &sString, "int", -1, "uint", &wString, "int", nSize)
		return DllCall("gdiplus\GdipDrawString", "uint", pGraphics
		, "uint", &wString, "int", -1, "uint", hFont, "uint", &RectF, "uint", hFormat, "uint", pBrush)
	}
	else
	{
		return DllCall("gdiplus\GdipDrawString", "uint", pGraphics
		, "uint", &sString, "int", -1, "uint", hFont, "uint", &RectF, "uint", hFormat, "uint", pBrush)
	}	
}

Gdip_ImageRotateFlip(pBitmap, RotateFlipType=1)
{
	return DllCall("gdiplus\GdipImageRotateFlip", "uint", pBitmap, "int", RotateFlipType)
}


Gdip_DeleteStringFormat(hFormat)
{
   return DllCall("gdiplus\GdipDeleteStringFormat", "uint", hFormat)
}


Gdip_DeleteFontFamily(hFamily)
{
   return DllCall("gdiplus\GdipDeleteFontFamily", "uint", hFamily)
}

Gdip_DeleteFont(hFont)
{
   return DllCall("gdiplus\GdipDeleteFont", "uint", hFont)
}


Gdip_DeletePen(pPen)
{
   return DllCall("gdiplus\GdipDeletePen", A_PtrSize ? "UPtr" : "UInt", pPen)
}

Gdip_DeleteBrush(pBrush)
{
   return DllCall("gdiplus\GdipDeleteBrush", A_PtrSize ? "UPtr" : "UInt", pBrush)
}

Gdip_DisposeImage(pBitmap)
{
   return DllCall("gdiplus\GdipDisposeImage", A_PtrSize ? "UPtr" : "UInt", pBitmap)
}

Gdip_DeleteGraphics(pGraphics)
{
   return DllCall("gdiplus\GdipDeleteGraphics", A_PtrSize ? "UPtr" : "UInt", pGraphics)
}


Gdip_BrushCreateHatch(ARGBfront, ARGBback, HatchStyle=0)
{
	DllCall("gdiplus\GdipCreateHatchBrush", "int", HatchStyle, "UInt", ARGBfront, "UInt", ARGBback, A_PtrSize ? "UPtr*" : "UInt*", pBrush)
	return pBrush
}