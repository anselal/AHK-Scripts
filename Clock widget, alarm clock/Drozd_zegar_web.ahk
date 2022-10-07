#SingleInstance force
#NoEnv
ico:=RegExMatch(A_OSVersion,"i)WIN_VISTA|WIN_7") ? 21: 17
Menu, Tray, Icon, wmploc.dll , %ico%
;Menu, Tray, Icon, wmploc.dll, 21 ; Win Vista
;Menu, Tray, Icon, wmploc.dll, 17 ; Win8

Menu, Tray, NoStandard
Menu, Tray, Add, Window Spy, WindowSpy 
Menu, Tray, Add
Menu, Tray, Add, Set in saved position , GoToSavedPos
Menu, Tray, Add , Open settings file , Open_ini
Menu, Tray, Icon , Open settings file , Shell32.dll, 70
Menu, Tray, Add,
Menu, Tray, Add , Edit in Scite, Edit_Scite
Menu, Tray, Add , Edit in Notepad, Edit_Notepad
Menu, Tray, Add,
Menu, Tray, Add, Reload , Reload
Menu, Tray, Add, Exit , Exit 
Menu, Tray, Default, Set in saved position  ;; double click tray icon 


Menu, ContextMenu, Add, On Top, OnTop
Menu, ContextMenu, Icon, On Top, Shell32.dll, 248
Menu, ContextMenu, Add,
Menu, ContextMenu, Add, Save current position , save_position
Menu, ContextMenu, Icon, Save current position , Shell32.dll, 124
;Menu, ContextMenu, Add, Set in saved position , GoToSavedPos


Menu, ContextMenu, Add,
;Menu, ContextMenu, Add, Start timer , start_timer
Menu, Submenu3, Add,  Input, start_timer_input
Menu, Submenu3, Add,
Menu, Submenu3, Add,  1 min , start_timer_1m
Menu, Submenu3, Add,  5 min , start_timer_5m
Menu, Submenu3, Add,  10 min , start_timer_10m
Menu, Submenu3, Add,  15 min , start_timer_15m
Menu, Submenu3, Add,  30 min , start_timer_30m
Menu, Submenu3, Add,  60 min , start_timer_60m
Menu, Submenu3, Add,
Menu, Submenu3, Add, Stop timer, stop_timer
Menu, ContextMenu, Add, Start timer, :Submenu3
Menu, ContextMenu, Add,

Menu, Submenu1, Add, Transparent , BackgroundTransparent
Menu, Submenu1, Add, Half Transparent , BackgroundHalfTransparent
Menu, Submenu1, Add,
Menu, Submenu1, Add, Blue gradient   , BackgroundGradientB 
Menu, Submenu1, Add, Red gradient   , BackgroundGradientR
Menu, Submenu1, Add, Green gradient   , BackgroundGradientG
Menu, ContextMenu, Add, Background, :Submenu1 

Menu, Submenu2, Add, Set in saved position , GoToSavedPos
Menu, Submenu2, Icon, Set in saved position , Shell32.dll, 124
Menu, Submenu2, Add
Menu, Submenu2, Add, Show small date on/off   , Show_small_date
Menu, Submenu2, Check, Show small date on/off   
Menu, Submenu2, Add, Full hour flash  on/off , full_hour_flash
Menu, Submenu2, Check, Full hour flash  on/off 
Menu, Submenu2, Add
Menu, Submenu2, Add, Regulate loudness on/off  , Regulate_loudness
Menu, Submenu2, Check, Regulate loudness on/off  
;Menu, Submenu2, Icon, Regulate loudness on/off  , SndVol.exe
Menu, Submenu2, Add, Alarm loudness  , set_alarm_loudness
Menu, Submenu2, Icon, Alarm loudness  , SndVol.exe
Menu, Submenu2, Add
Menu, Submenu2, Add, Open settings file , Open_ini
Menu, Submenu2, Icon, Open settings file, Shell32.dll, 70
Menu, Submenu2, Add, Temp routine , temp_routine
Menu, ContextMenu, Add, more, :Submenu2 

;Menu, ContextMenu, Add,
;Menu, ContextMenu, Add, Open settings file , Open_ini
;Menu, ContextMenu, Icon, Open settings file, Shell32.dll, 70
Menu, ContextMenu, Add,
Menu, ContextMenu, Add, Help , show_help
Menu, ContextMenu, Icon, Help , shell32.dll, 24
Menu, ContextMenu, Add, Restart, Reload
Menu, ContextMenu, Add, Exit, Exit
Menu, ContextMenu, Icon, Exit, Shell32.dll, 132


help=
(
● on click = show full date and stop alarm
● on double click = set in saved position
● start alarm - click on small date or open options in the right click context menu

● more options in the right click context menu:   
   GUI color, transparency
   save position for next launch
   small date on/off Full hour flash  on/off 
   Regulate alarm loudness on/off , set alarm loudness
● F4 - show GUI , or click on tray icon


)


 If !pToken := Gdip_Startup(){
	MsgBox, No Gdiplus 
	ExitApp
}

OnExit, Exit


	small_date:=1, full_hour_flash:=1
	alarm_loudness:=20 
	regulate_loudness:=1
		
	PCspeaker:=0 ; 1: double , 2: short - timer 
	timesBlink_max:= 3  ; alarm blink ; 6 ~ 1 min
	
	sounds_folder:="F:\1.Music\alarm\"
	alarm_sound0:=sounds_folder "Hendrix-Watchtower.mp3"

	alarm_sound0:=A_WinDir "\Media\Alarm03.wav" 
	;alarm_sound0:= A_WinDir "\Media\notify.wav" ; A_WinDir "\Media\chimes.wav"
	Cuckoo:="F:\1.Music\alarm\Cuckoo.wav"
	
	;rim:=0xff444444 ; black
	rim:="" ; default
	;bgrd:="0x99120F00" 
	bgrd:="" ; default

;===========

show_date:=0, show_date2:=0


SysGet, MonitorWorkArea, MonitorWorkArea, 1
pos_x:=A_ScreenWidth - 140
;pos_y:= MonitorWorkAreaBottom -830 ;870
pos_y:= 10 
settings_ini := "Drozd zegar.ini"


	IniRead, pos_x_saved, %settings_ini%, window position, x	
	IniRead, pos_y_saved, %settings_ini%, window position, y	

if(pos_x_saved!="ERROR" && pos_x_saved!="" && pos_y_saved!="ERROR" && pos_y_saved!=""){
		if(pos_x_saved<A_ScreenWidth-120 && pos_y_saved<A_ScreenHeight-140){
			pos_x:=pos_x_saved
			pos_y:=pos_y_saved
		}
}

IniRead, bgrd_, %settings_ini%, window , Background
	if(bgrd_!="ERROR" && bgrd_!=""){
		bgrd:=bgrd_
	}
IniRead, x_, %settings_ini%, window , small date
	if(x_!="ERROR" && x_!=""){
			small_date:=x_
			Menu, Submenu2, % (small_date=1) ? "Check" : "UnCheck"  , Show small date on/off   
	}
IniRead, x_, %settings_ini%, window , full hour flash
	if(x_!="ERROR" && x_!=""){
			full_hour_flash:=x_
			Menu, Submenu2, % (full_hour_flash=1) ? "Check" : "UnCheck"  , Full hour flash  on/off 
	}	
	
IniRead, x_, %settings_ini%, Misc , regulate loudness
	if(x_!="ERROR" && x_!=""){
		regulate_loudness:=x_			
		Menu, Submenu2, % (regulate_loudness=1) ? "Check" : "UnCheck"  , Regulate loudness on/off		
	}else{
		IniWrite, 1 , %settings_ini%, Misc , regulate loudness
	}	
	

IniRead, x_, %settings_ini%, Misc , alarm loudness
	if(x_!="ERROR" && x_!=""){
		alarm_loudness:=x_			
	}else{
		IniWrite, %alarm_loudness% , %settings_ini%, Misc , alarm loudness
	}	
	
	
IniRead, x_, %settings_ini%, Misc , alarm sound
	if(x_!="ERROR" && x_!=""){
		alarm_sound0:=x_			
	}else{
		if FileExist(alarm_sound0)
			IniWrite, %alarm_sound0% , %settings_ini%, Misc , alarm sound
	}	
	
	
/* if (FileExist("C:\Windows\Fonts\ArialN.TTF")){
	FontArialNarrow:="Arial Narrow"
}
 */
;=================


GuiW := 134, GuiH := 152

Gui,1: +ToolWindow -Caption +E0x80000 +AlwaysOnTop	 +HwndGuiHwnd
WonTop:=1 
Gui,1:Color, 120F00
Gui,1: -DPIScale

OnMessage(0x201, "WM_LBUTTONDOWN") ; movable borderless window   
OnMessage(0x200, "WM_MOUSEMOVE")
OnMessage(0x404, "AHK_NOTIFYICON") ;click tray icon to show
OnMessage(0x0203, "WM_LBUTTONDBLCLK") ; 
Gui, 1: Show, x%pos_x% y%pos_y% w%GuiW% h%GuiH%  , Drozd_zegar

;Gosub, onTop

SetTimer,time_date, 1000

SetTimer,clear_memory, % 6*60*60*1000
return


AHK_NOTIFYICON(wParam, lParam){ ;click tray icon to show
    if (lParam = 0x202) {       ; WM_LBUTTONUP
				Gui,1:Show  				
    }else if (lParam = 0x203){   ; WM_LBUTTONDBLCLK
		}
}


WM_MOUSEMOVE(){
		global show_date,show_date2 ,angleM,angleH,rim,GuiHwnd,bgrd, alarm_on
		if(A_Gui=1 && show_date!=1 && !alarm_on){
			show_date:=1
			sleep 200
			Gdip_draw_Win(GuiHwnd,angleM,angleH,rim,bgrd)
			SetTimer, after_show_date, -3000
		}
}

WM_LBUTTONDOWN(){
	global loudness_start, alarm_on, GuiHwnd
	MouseGetPos,x,y,Win_id
	if (A_Gui=1){
		PostMessage, 0xA1, 2    ; movable borderless window 
		
		if(alarm_on)
		 Gosub, alarm_off

		global show_date,show_date2, angleM,angleH,rim,GuiHwnd,bgrd
			show_date:=1,show_date2:=1
			sleep 100
			Gdip_draw_Win(GuiHwnd,angleM,angleH,rim,bgrd)
			SetTimer, after_show_date2, -6000
			Gosub, GuiSize
	}

	if (A_Gui=3){
		PostMessage, 0xA1, 2    ; movable borderless window 	
		Gosub, GuiSize
	}
 
	;---- ListBox
	if(Win_id == GuiHwnd){
		if(x>44 && x<92 && y>77 && y<95){
			Gosub, show_alarm_list
		}else
			Gui,6: Destroy
	}	
}

~LButton::
MouseGetPos,x,y,Win_id,	
if (Win_id != GuiHwnd && Win_id != GuiListHwnd )
	Gui,6: Destroy
return

WM_LBUTTONDBLCLK(){
	Gosub, GoToSavedPos	
}

;==========

after_show_date:
	show_date:=0
	Gdip_draw_Win(GuiHwnd,angleM,angleH,rim,bgrd)
return

after_show_date2:
	show_date:=0, show_date2:=0
	Gdip_draw_Win(GuiHwnd,angleM,angleH,rim,bgrd)
return

;======================================


Gdip_draw_Win(ByRef GuiHwnd, angleM=0, angleH=0,rim="" ,Background=0x00000000, Foreground=0xff333333){
	global GuiW, GuiH, small_date, show_date,show_date2 ,FontArialNarrow
	global midX, midY,ramkaX,ramkaY,ramkaW,ramkaH ,r1
	global pBitmap_2
	
	w := GuiW, h := GuiH
	midX:= w/2 , midY:=h/2-7
	r1:=47, r2:=32, r3:=3.5
	;1 rad=0.0174533 * 1° 
	
	hbm := CreateDIBSection(w, h), hdc := CreateCompatibleDC(), obm := SelectObject(hdc, hbm)
	G := Gdip_GraphicsFromHDC(hdc) , Gdip_SetSmoothingMode(G, 4)

	pBrush1:= Gdip_BrushCreateSolid(Foreground)
	
	Background_:=StrSplit(Background,"|")
	if(Background_.Length() >1){
		;=== with gradient =====
		grad_color_rim:=Background_[1]
		grad_color_mid:=Background_[2]
		;size:=Background_[3]
		
		pBrushBG := Gdip_CreateLineBrushFromRect(0, 0, 1, 25, grad_color_rim, grad_color_mid ,1) 
		;Gdip_FillRectangle(G, pBrushBG, 0, 0, w, h)
		Gdip_FillRoundedRectangle(G,pBrushBG,0, 0, w, h,14)
	;========
	}else{
		pBrushBG := Gdip_BrushCreateSolid(Background)
		;Gdip_FillRectangle(G, pBrushBG, 0, 0, w, h)
		Gdip_FillRoundedRectangle(G, pBrushBG, 0, 0, w, h, 14)
	}	
	
	
	pBrush2 := Gdip_BrushCreateSolid(Foreground) ;0xaa2D2A1F
	Gdip_FillEllipse(G, pBrush2, midX-62, midY-62, 124,124)

	if(rim!=""){
		pBrush2 := Gdip_BrushCreateSolid(rim)
		Gdip_FillEllipse(G, pBrush2, midX-60, midY-60, 120, 120)	
	}else{
		pBrush2 := Gdip_CreateLineBrushFromRect(0, 0, 12, 28, 0xff1B1B1B, 0xff2A3649,3)
		Gdip_FillEllipse(G, pBrush2, midX-60, midY-60, 120, 120)
	}

	pBrush2 := Gdip_BrushCreateSolid(0xff222222)
	Gdip_FillEllipse(G, pBrush2, midX-52, midY-52, 104,104)		
	
	pBrushW:= Gdip_BrushCreateSolid(0xffF4F1E4) ; 0xffF4F1E4
	Gdip_FillEllipse(G, pBrushW, midX-50, midY-50, 100,100)

	Gdip_FillEllipse(G, pBrush1, midX-r3, midY-r3, 2*r3, 2*r3)

	;pBrushT := Gdip_BrushCreateSolid(0xff333333)

;================	

	ramkaX:= midX-23 ,ramkaY:=midY+11
	ramkaW:=48 , ramkaH:=12
		
	FormatTime , DayF,, ddd
	FormatTime , Day,,  d	
	months:=["I","II","III","IV","V","VI","VII","VIII","IX","X","XI","XII"]
	FormatTime, M,, M
	
/* 	Polish:=0x0415
	;Data:=GetDateFormat(A_Now,"d MMM',' ddd",Polish) 
	DayF:=GetDateFormat(A_Now,"ddd",Polish) 
	 */
	
	Date:= Day " " months[M]

	if(Day<10){
		if(M!=7 && M!=8 && M!=12){
			Date:= " " Day "  " months[M]
		}else
			Date:= " " Day " " months[M]
	}else{
		if(M==1 || M==2 || M==3 || M==5 || M== 10){
			Date:= " " Day " " months[M]
		}else
			Date:= Day " " months[M]
	}

	
	if !RegExMatch(DayF,"Wed|Mon")
			DayF:=" " DayF
	if InStr(DayF,"Fri")
			DayF:=" " DayF

	if(small_date==1){
		Gdip_small_date(G,DayF,Date)
	}
	
;================	

/* if(FontArialNarrow){
	Gdip_digits_ArialNarrow(G)
}else{
	Gdip_digits_Georgia(G)
}
 */
 
	Gdip_digits_Georgia(G)
	
;===============

	pPen2:=Gdip_CreatePen(0xff000000, 1)
	r4:=r1+2
 	angle:=0
	mark:=2
	Loop, 60 {
		;if(Mod(angle,5)==0)
			;continue
		rad:=(90-angle) * 0.0174533
		x:=midX + r4*Cos(rad)
		y:=midY - r4*Sin(rad)	
		Gdip_FillEllipse(G, pBrush1, x-1, y-1, 2,2)
		
/* 		x:=midX + r4*Cos(rad)
		y:=midY - r4*Sin(rad)	
		x2:=midX + (r4-mark)*Cos(rad)
		y2:=midY - (r4-mark)*Sin(rad)	
		Gdip_DrawLine(G, pPen2, x, y, x2, y2)		
 */
		angle:=angle+6
	}	
	 


	; minute
	radM:=(90-angleM) * 0.0174533 
	x:=midX + r1*Cos(radM)
	y:=midY - r1*Sin(radM)	

	x1:=midX - r3*Sin(radM)
	y1:=midY - r3*Cos(radM)	
	
	x2:=midX + r3*Sin(radM)
	y2:=midY + r3*Cos(radM)	
	
  ;pBrush3 := Gdip_BrushCreateSolid(0xffF5B547) ;0xffFFA200 ; 0xffF5B547;0xffFFBE4C ;
  pPathM := Gdip_CreatePath(0)
	pointsM:= x "," y "|" x1 "," y1 "|" x2 "," y2 "|" x "," y
  Gdip_AddPathPolygon(pPathM,pointsM )
  Gdip_FillPath(G,pBrush1, pPathM) 

	; hour
	radH:=(90-angleH) * 0.0174533 
	x:=midX + r2*Cos(radH)
	y:=midY - r2*Sin(radH)	

	x1:=midX - r3*Sin(radH)
	y1:=midY - r3*Cos(radH)	
	
	x2:=midX + r3*Sin(radH)
	y2:=midY + r3*Cos(radH)	
	
  
  pPathH := Gdip_CreatePath(0)
	pointsH:= x "," y "|" x1 "," y1 "|" x2 "," y2 "|" x "," y 
  Gdip_AddPathPolygon(pPathH,pointsH)
  Gdip_FillPath(G,pBrush1, pPathH) 

	pPen:=Gdip_CreatePen(0xffEEEEEE, 1) 
	Gdip_DrawEllipse(G, pPen,midX-1.5, midY-1.5, 3, 3)
	
;================	

	if(show_date==1 && small_date==1){
		Gdip_small_date_High(G,DayF,Date)
	}	

	if(show_date2==1){ 	
		Gdip_date(G)

	}

;================	
	
	Gdip_DisposeImage(pBitmap_2) 
	pBitmap_2 :=Gdip_CreateBitmapFromHBITMAP(hbm)		
	
	UpdateLayeredWindow(GuiHwnd, hdc, , , w, h)

	Gdip_DeleteBrush(pBrushBG), Gdip_DeleteBrush(pBrushT),Gdip_DeleteBrush(pBrushW),	Gdip_DeleteBrush(pBrushW2)
	Gdip_DeleteBrush(pBrush1), Gdip_DeleteBrush(pBrush2)
	Gdip_DeletePen(pPen), Gdip_DeletePen(pPen2), Gdip_DeletePen(pPen3), Gdip_DeletePath(pPath), Gdip_DeletePath(pPathM), Gdip_DeletePath(pPathH)
	SelectObject(hdc, obm), DeleteObject(hbm), DeleteDC(hdc), Gdip_DeleteGraphics(G)	
	return, 0
}

;==================================

/* 
Gdip_digits_ArialNarrow(ByRef G){
	global midX, midY,ramkaX,ramkaY,ramkaW,ramkaH,r1
	colorT:=0xff333333
	pPen2:=Gdip_CreatePen(0xff000000, 2)
	r4:=r1+3
	markB:=4
	angle:=0
	
	
	
	 	Loop, 12 {
		rad:=(90-angle) * 0.0174533
		x:=midX + r4*Cos(rad)
		y:=midY - r4*Sin(rad)	
		x2:=midX + (r4-markB)*Cos(rad)
		y2:=midY - (r4-markB)*Sin(rad)	
		Gdip_DrawLine(G, pPen2, x, y, x2, y2)		
		x:=midX + (r1-7)*Cos(rad)
		y:=midY - (r1-7)*Sin(rad)
		
 		if(A_Index==1){
			Gdip_TextToG(G, "12", colorT,x-8, y-7,14, 24, 24,"Arial Narrow")
		}else if(A_Index==2){	
			Gdip_TextToG(G, A_Index-1, colorT,x-7, y-7,14, 24, 24,"Arial Narrow")
		}else if(A_Index==3){
			Gdip_TextToG(G, A_Index-1, colorT,x-7, y-9,14, 24, 24,"Arial Narrow")			
		}else if(A_Index==4){
			Gdip_TextToG(G, A_Index-1, colorT,x-6, y-9,14, 24, 24,"Arial Narrow")
		}else if(A_Index==5){
			Gdip_TextToG(G, A_Index-1, colorT,x-7, y-11,14, 24, 24,"Arial Narrow")
		}else if(A_Index==6){
			Gdip_TextToG(G, A_Index-1, colorT,x-6, y-11,14, 24, 24,"Arial Narrow")		
		}else if(A_Index==7){
			Gdip_TextToG(G, A_Index-1, colorT,x-5, y-12,14, 24, 24,"Arial Narrow")
		}else if(A_Index==8){
			Gdip_TextToG(G, A_Index-1, colorT,x-4, y-10,14, 24, 24,"Arial Narrow")
		}else if(A_Index==9){
			Gdip_TextToG(G, A_Index-1, colorT,x-3, y-10,14, 24, 24,"Arial Narrow")
		}else if(A_Index==10){
			Gdip_TextToG(G, A_Index-1, colorT,x-3, y-9,14, 24, 24,"Arial Narrow")
		}else if(A_Index==11){
			Gdip_TextToG(G, A_Index-1, colorT,x-7, y-8,14, 24, 24,"Arial Narrow")
		}else if(A_Index==12){
			Gdip_TextToG(G, A_Index-1, colorT,x-8, y-7,14, 24, 24,"Arial Narrow")
		} 
		
		
		angle:=angle+30
	}
	 Gdip_DeletePen(pPen2)
	 return, 0
}
 */
 

Gdip_digits_Georgia(ByRef G){
	global midX, midY,ramkaX,ramkaY,ramkaW,ramkaH,r1
	colorT:=0xff333333
	pPen2:=Gdip_CreatePen(0xff000000, 2)
	r4:=r1+3
	markB:=4
	angle:=0
	
	size:=14,sizeN:=14
	;FontN:="Arial Narrow"
	FontN:=Font:="Georgia",	size:=13, sizeN:=13
	Loop, 12 {
		rad:=(90-angle) * 0.0174533
		x:=midX + r4*Cos(rad)
		y:=midY - r4*Sin(rad)	
		x2:=midX + (r4-markB)*Cos(rad)
		y2:=midY - (r4-markB)*Sin(rad)	
		Gdip_DrawLine(G, pPen2, x, y, x2, y2)		
		x:=midX + (r1-7)*Cos(rad)
		y:=midY - (r1-7)*Sin(rad)

	;  "Georgia" ; FontN:=Font:="Georgia",	size:=13, sizeN:=13
		if(A_Index==2){	
			Gdip_TextToG(G, A_Index-1, colorT,x-6, y-9, size+2, 24, 24,Font)
		}else if(A_Index==3){
			Gdip_TextToG(G, A_Index-1, colorT,x-9, y-11, size+2, 24, 24,Font)			
		}else if(A_Index==4){
			Gdip_TextToG(G, A_Index-1, colorT,x-7, y-11, size, 24, 24,Font)
		}else if(A_Index==5){
			Gdip_TextToG(G, A_Index-1, colorT,x-7, y-11, size-1, 24, 24,Font)
		}else if(A_Index==6){
			Gdip_TextToG(G, A_Index-1, colorT,x-6, y-14, size, 24, 24,Font)	
		}else if(A_Index==7){
			Gdip_TextToG(G, A_Index-1, colorT,x-6, y-11, size, 24, 24,Font)
		}else if(A_Index==8){
			Gdip_TextToG(G, A_Index-1, colorT,x-5, y-13, size, 24, 24,Font)
		}else if(A_Index==9){
			Gdip_TextToG(G, A_Index-1, colorT,x-5, y-10, size, 24, 24,Font)
		}else if(A_Index==10){
			Gdip_TextToG(G, A_Index-1, colorT,x-5, y-11, size, 24, 24,Font)
		}else if(A_Index==11){
			Gdip_TextToG(G, A_Index-1, colorT,x-8, y-8, sizeN, 24, 24,FontN) ;"Arial Narrow"
		}else if(A_Index==12){
			Gdip_TextToG(G, A_Index-1, colorT,x-10, y-8, sizeN+1, 24, 24,FontN) ;"Arial Narrow"
		}else if(A_Index==1){
			Gdip_TextToG(G, "12", colorT,x-10, y-9,sizeN+1, 24, 24,FontN) ;"Arial Narrow"
		}
		
		angle:=angle+30
	}		
	
	Gdip_DeletePen(pPen2)
	return, 0
}

;==================================

Gdip_TextToG(ByRef G, Text, color,x, y,size,Width, Height,Font:="Arial",Style=1,Align=0){
	;Style := 1 ;, Styles := "Regular|Bold|Italic|BoldItalic|Underline|Strikeout"
	;Align := 0 ;, Alignments := "Near|Left|Center|Far|Right"
	
	pBrushT := Gdip_BrushCreateSolid(color)	
	CreateRectF(RC, x, y, Width,Height )	
	hFamily := Gdip_FontFamilyCreate(Font)
	hFont := Gdip_FontCreate(hFamily, size, Style)
	FormatStyle := NoWrap ? 0x4000 | 0x1000 : 0x4000
	Rendering:=5
	
	hFormat := Gdip_StringFormatCreate(FormatStyle)		
	Gdip_SetStringFormatAlign(hFormat, Align)
	
	Gdip_SetTextRenderingHint(G, Rendering)
	ReturnRC := Gdip_MeasureString(G, Text, hFont, hFormat, RC) 

	E :=Gdip_DrawString(G, Text, hFont, hFormat, pBrushT, RC)
	
	Gdip_DeleteBrush(pBrushT)	
	Gdip_DeleteStringFormat(hFormat), Gdip_DeleteFont(hFont),	Gdip_DeleteFontFamily(hFamily)
	return E ? E : ReturnRC
}

;==================================

Gdip_small_date(ByRef G,DayF,Date){
	global GuiW, GuiH, midX, midY
	global ramkaX,ramkaY,ramkaW,ramkaH

	colorD:=0xff900000
	colorT2:=0xff555555
	;pPen:=Gdip_CreatePen(0xff888888, 1) 
	pPen:=Gdip_CreatePen(0xffD2C178, 1) 
	pPen3:=Gdip_CreatePen(0xff999999, 1)	 
	pBrushW:= Gdip_BrushCreateSolid(0xffF4F1E4)
	pBrushW2 := Gdip_CreateLineBrushFromRect(0, 0, 1, 5, 0xffDEDAC8,0xffFCF9EA , 1)  

	Gdip_DrawRoundedRectangle(G, pPen3,ramkaX, ramkaY, ramkaW, ramkaH,4)
	Gdip_FillRoundedRectangle(G,pBrushW2,ramkaX, ramkaY, ramkaW, ramkaH,4)	
	pPen:=Gdip_CreatePen(0xffD1C386, 1)
	Gdip_DrawLine(G, pPen, ramkaX+22,ramkaY,ramkaX+22,ramkaY+ramkaH)
	
	Gdip_TextToG(G, DayF, colorT2,ramkaX+2,ramkaY+2,8, 30, 12,"Arial",1) 
	Gdip_TextToG(G, Date, colorT2,ramkaX+24,ramkaY+2,8, 30, 12,"Arial",1)

	Gdip_DeleteBrush(pBrushW),	Gdip_DeleteBrush(pBrushW2) 
	Gdip_DeletePen(pPen), Gdip_DeletePen(pPen3)	
	return 0
}


Gdip_small_date_High(ByRef G,DayF,Date){
	global GuiW, GuiH, midX, midY
	global ramkaX,ramkaY,ramkaW,ramkaH

	pBrushW2 := Gdip_CreateLineBrushFromRect(0, 0, 1, 5, 0xffDEDAC8,0xffFCF9EA , 1)  
	pPen:=Gdip_CreatePen(0x55D2C178, 1) 

	Gdip_DrawRoundedRectangle(G, pPen,ramkaX, ramkaY, ramkaW, ramkaH,4)
	Gdip_FillRoundedRectangle(G,pBrushW2,ramkaX, ramkaY, ramkaW, ramkaH,4)	
	
	pPen2:=Gdip_CreatePen(0xffD1C386, 1) 
	Gdip_DrawLine(G, pPen2, ramkaX+22,ramkaY,ramkaX+22,ramkaY+ramkaH)
		
	colorD:=0xff900000
	colorT2:=0xff555555

	Gdip_TextToG(G, DayF, colorD,ramkaX+2,ramkaY+2,8, 30, 14,"Arial",1) 
	Gdip_TextToG(G, Date, colorD,ramkaX+24,ramkaY+2,8, 30, 14,"Arial",1)

	Gdip_DeleteBrush(pBrush2),Gdip_DeleteBrush(pBrushW2)
	Gdip_DeletePen(pPen),Gdip_DeletePen(pPen2)
	return 0
}


Gdip_date(ByRef G){
	global GuiW, GuiH, midX, midY
	;pBrush2:= Gdip_BrushCreateSolid("0xFF00165A")  
	pBrush2:= Gdip_BrushCreateSolid(0xcc120F00)
	;pBrush2:= Gdip_CreateLineBrushFromRect(0, 0, 1, 8, 0xEE120F00,0xcc120F00 , 1)  
	Gdip_FillRoundedRectangle(G, pBrush2,4, GuiH-19, 126, 16,4)
	;pPen:=Gdip_CreatePen(0xffF6F6F6, 1)
	;Gdip_DrawRoundedRectangle(G, pPen,7, GuiH-18, 120, 14,3)
	;colorD:=0xffD90000
	FormatTime , Date_full,, HH:mm ddd, d MMM, yyyy  ;HH:mm:ss
	colorD:=0xffF6F6F6 
	Gdip_TextToG(G, Date_full, colorD,4,GuiH-17,10, 124, 20,"Arial",1,2) 	
	;Gdip_TextToG(G, Date_full, colorD,10,GuiH-17,10, 130, 20,"Arial",1) 	

	Gdip_DeleteBrush(pBrush2)
	;Gdip_DeletePen(pPen)
	return, 0
}



;==================================

Gdip_flash(ByRef hwnd,ByRef pBitmap_2, color:=0x65120F00,r1:=0,r2:=0,grad:=0){ ; Apr5 2018
	global GuiW, GuiH, midX, midY	
	SetBatchLines, -1
	w:=GuiW , h:=GuiH
	hbm := CreateDIBSection(w,h), hdc := CreateCompatibleDC(), obm := SelectObject(hdc, hbm)
	G := Gdip_GraphicsFromHDC(hdc) , Gdip_SetSmoothingMode(G, 4)

;=============	anti	alias
/* 	pBitmapMask := Gdip_CreateBitmap(w, h), G2 := Gdip_GraphicsFromImage(pBitmapMask)
	Gdip_SetSmoothingMode(G2, 4)
	pBrush2 := Gdip_BrushCreateSolid(0xff000000)
	pPath := Gdip_CreatePath(G2)
	Gdip_AddPathEllipse(pPath,midX-62, midY-62, 124,124)
	Gdip_FillPath(G2, pBrush2, pPath)
	
	pBitmapNew := Gdip_AlphaMask(pBitmap_2, pBitmapMask, 0, 0)
	Gdip_DrawImage(G, pBitmapNew, 0,0,w,h)
	Gdip_DeleteGraphics(G2),Gdip_DisposeImage(pBitmapMask), Gdip_DisposeImage(pBitmapNew)
	 */
;=============	alias

 	Gdip_DrawImage(G, pBitmap_2, 0,0,w,h)
	
	;pBrush2 := Gdip_BrushCreateSolid(0xff000000)
	r5:=123
 	pPath2 := Gdip_CreatePath(0)

	Gdip_AddPathEllipse(pPath2,midX-r5/2, midY-r5/2, r5,r5)
	Gdip_PathGradientSetCenterPoint(pBrush2,GuiW/2, GuiH/2)
	Gdip_SetClipPath(G, pPath2, 4)
	Gdip_GraphicsClear(G) 	
	Gdip_ResetClip(G)
	
	;fix alias
	pPen2:=Gdip_CreatePen(0xff333333, 1)
	Gdip_DrawEllipse(G, pPen2, midX-r5/2, midY-r5/2, r5,r5)
	Gdip_DeletePath(pPath2),Gdip_DeletePen(pPen2)	
;=============	

	;pPen:=Gdip_CreatePen(color, 10)
	pBrush := Gdip_BrushCreateSolid(color)
	pBrushW:= Gdip_BrushCreateSolid(0x33F4F1E4)	
	
	if(grad=0){
		if(r2!=0){
			r1a:=20 ;
			r1a:=(100-r2)/2		
			pPen:=Gdip_CreatePen(color, r1a)
			
			r1:=r2+r1a
			Gdip_DrawEllipse(G, pPen, midX-r1/2, midY-r1/2, r1,r1)
			
			;pPen:=Gdip_CreatePen(0xFF000000, 1)
			;Gdip_DrawEllipse(G, pPen, midX-r2/2, midY-r2/2, r2,r2)
		}else{
			Gdip_FillEllipse(G, pBrush, midX-r1/2, midY-r1/2, r1,r1)
		
		}
		Gdip_DeleteBrush(pBrush), Gdip_DeletePen(pPen)
	}else{	
		max_R:=100

		if(r2!=0){			
			r1a:=(100-r2)/2		
			pPen:=Gdip_CreatePen(color, r1a)		
			r1:=r2+r1a		
			Gdip_DrawEllipse(G, pPen, midX-r1/2, midY-r1/2, r1,r1)			
		
			col2:=color
			col1:=0x00EEEEEE
			;ScaleX:=0.5 , ScaleY:=0.5
			r1:=r2
			ScaleX:=ScaleY:=r2/max_R

			pPath := Gdip_CreatePath(G)
			Gdip_AddPathEllipse(pPath,midX-r1/2, midY-r1/2, r1, r1)
			
			pBrush:=Gdip_PathGradientCreateFromPath(pPath)
			Gdip_PathGradientSetCenterPoint(pBrush,midX, midY)
			Gdip_PathGradientSetCenterColor(pBrush, col1)
			Gdip_PathGradientSetSurroundColors(pBrush, col2)
			Gdip_PathGradientSetFocusScales(pBrush, ScaleX, ScaleY)
			;Gdip_PathGradientSetSigmaBlend(pBrush, 0.3, 1)
			Gdip_FillPath(G, pBrush, pPath)
			Gdip_DeletePen(pPen), Gdip_DeletePath(pPath) , Gdip_DeleteBrush(pBrush)
			;pPen:=Gdip_CreatePen(0xFF000000, 1)
			;Gdip_DrawEllipse(G, pPen, midX-r2/2, midY-r2/2, r2,r2)
		}else{
			col1:=color
			col2:=0x00EEEEEE
			;ScaleX:=0.5 , ScaleY:=0.5
			ScaleX:=ScaleY:=r1/max_R
			
			pPath := Gdip_CreatePath(G)
			Gdip_AddPathEllipse(pPath,midX-r1/2, midY-r1/2, r1, r1)
			
			pBrush:=Gdip_PathGradientCreateFromPath(pPath)
			Gdip_PathGradientSetCenterPoint(pBrush,midX, midY)
			Gdip_PathGradientSetCenterColor(pBrush, col1)
			Gdip_PathGradientSetSurroundColors(pBrush, col2)
			Gdip_PathGradientSetFocusScales(pBrush, ScaleX, ScaleY)
			Gdip_FillPath(G, pBrush, pPath)
			Gdip_DeletePen(pPen), Gdip_DeletePath(pPath) , Gdip_DeleteBrush(pBrush)
		}		
	}
	
	
	;FormatTime, hh,, HH
	;Gdip_TextToG(G, hh ":00", colorT:=0xffB60000,midX-37, midY-15, 25, 96, 34)
	
	UpdateLayeredWindow(hwnd, hdc)
	
	Gdip_DeleteBrush(pBrush),Gdip_DeleteBrush(pBrush2), Gdip_DeleteBrush(pBrushW)
	Gdip_DeletePen(pPen),Gdip_DeletePen(pPen2), Gdip_DeletePath(pPath)	
	SelectObject(hdc, obm), DeleteObject(hbm), DeleteDC(hdc), Gdip_DeleteGraphics(G)
	Gdip_DeleteGraphics(G2) 
	
	;SetBatchLines, 10ms
	return, 0
}


Gdip_animate(ByRef hwnd,color:=0x65120F00,r1:=0,r2:=0,r3:=0){
	global GuiW, GuiH, midX, midY	
	global pBitmap_2
	w:=GuiW , h:=GuiH
	SetBatchLines,-1	
	
	hbm := CreateDIBSection(w,h), hdc := CreateCompatibleDC(), obm := SelectObject(hdc, hbm)
	G := Gdip_GraphicsFromHDC(hdc) , Gdip_SetSmoothingMode(G, 4)
	 
;=============	anti	alias
/* 	pBitmapMask := Gdip_CreateBitmap(w, h), G2 := Gdip_GraphicsFromImage(pBitmapMask)
	Gdip_SetSmoothingMode(G2, 4)
	pBrush2 := Gdip_BrushCreateSolid(0xff000000)
	pPath := Gdip_CreatePath(G2)
	Gdip_AddPathEllipse(pPath,midX-62, midY-62, 124,124)
	Gdip_FillPath(G2, pBrush2, pPath)
	
	pBitmapNew := Gdip_AlphaMask(pBitmap_2, pBitmapMask, 0, 0)
	Gdip_DrawImage(G, pBitmapNew, 0,0,w,h)
	
	Gdip_DeleteGraphics(G2), Gdip_DisposeImage(pBitmapMask), Gdip_DisposeImage(pBitmapNew)
 */
;=============	alias	

	Gdip_DrawImage(G, pBitmap_2, 0,0,w,h)
	r5:=123
 	pPath2 := Gdip_CreatePath(0)
	;Gdip_AddPathEllipse(pPath2,midX-62, midY-62, 124,124)
	Gdip_AddPathEllipse(pPath2,midX-r5/2, midY-r5/2, r5,r5)
	pBrush2 := Gdip_BrushCreateSolid(0xff000000) 
	Gdip_PathGradientSetCenterPoint(pBrush2,GuiW/2, GuiH/2)
	Gdip_SetClipPath(G, pPath2, 4)
	
	Gdip_GraphicsClear(G) 	
	Gdip_ResetClip(G)
	
	pPen2:=Gdip_CreatePen(0xff333333, 1)
	Gdip_DrawEllipse(G, pPen2, midX-r5/2, midY-r5/2, r5,r5)
;=============	
	
	
	pPen:=Gdip_CreatePen(color, 10)
	;Gdip_DrawEllipse(G, pPen, midX-r1/2, midY-r1/2, r1,r1)
	 
	;pBrush := Gdip_BrushCreateSolid(color)
	;Gdip_FillEllipse(G, pBrush, midX-r1/2, midY-r1/2, r1,r1)	
	
	Gdip_DrawEllipse(G, pPen, midX-r1/2, midY-r1/2, r1,r1)	
	Gdip_DrawEllipse(G, pPen, midX-r2/2, midY-r2/2, r2,r2)
	Gdip_DrawEllipse(G, pPen, midX-r3/2, midY-r3/2, r3,r3)


	UpdateLayeredWindow(hwnd, hdc)


	Gdip_DeleteBrush(pBrush), Gdip_DeleteBrush(pBrush2), Gdip_DeleteBrush(pBrushW)
	Gdip_DeletePen(pPen) ,	Gdip_DeletePen(pPen2), Gdip_DeletePath(pPath2)	
	SelectObject(hdc, obm), DeleteObject(hbm), DeleteDC(hdc), Gdip_DeleteGraphics(G)
	;SetBatchLines, 10ms
	return, 0
}


;==================================


time_date:
	FormatTime, Data,, H:m:s  
	FormatTime, h,, H
	FormatTime, m,, m
	FormatTime, s,, s
	
	if(m!=old_min){		
		angleM:=m*6
		angleH:=h*30+angleM/12
		if(!alarm_on){
			Gdip_draw_Win(GuiHwnd,angleM,angleH,rim,bgrd)
		}else{
			Gdip_draw_Win(GuiHwnd,angleM,angleH,rim)
		}
		old_min:=m
	}
	 

 
/* ;test
if(Mod(s,15)==0){	
		
	if(!alarm_on)
		Gosub start_flash		
	}   
*/


	if(m=0 && s=0){
		
		if(!alarm_on && full_hour_flash){
			SoundBeep,2000,40
			SoundPlay, %Cuckoo% 
			Gosub start_flash
		}
		
/* 		SoundGet, loudness_start
		if(regulate_loudness)
			SoundSet, %alarm_loudness%	
		 */

	/* 		
		oVoice := ComObjCreate("SAPI.SpVoice") 
		oVoice.Rate := 0	
		oVoice.Speak("koo, koo")
    oVoice.Rate := 2
		 */

	}
return
	

;==================================	



start_flash:
	f1:=0 , f2:=0, stepF:=3
	max_R:=100 
	pom:=0x55E4C57E 
	pom1:=0x77F3DAA1	
	red:=0x33E45050 ;red:=0x66D35050	;red:=0x77E47D7D
	viol:=0x33D0A8F3

	;color_flash:=pom ;viol ; red	
	color_flash:=red
	flash_grad:=1
	SetTimer,flash, 10
	flash_on:=1
return

flash:
SetBatchLines, -1
	if(f2>max_R){
		SetTimer, flash, Off
		Gdip_draw_Win(GuiHwnd,angleM,angleH,rim,bgrd)	
	}
	
 	if(f2==0){
		Gdip_flash(GuiHwnd, pBitmap_2, color_flash,f1,,flash_grad)
		f1:=f1+stepF
	}
	
	if(f1>max_R-0){
		f2:=f2+stepF 
		Gdip_flash(GuiHwnd, pBitmap_2, color_flash,f1,f2,flash_grad)
		if(f2>max_R){
			SetTimer, flash, Off
			f1:=0 , f2:=0

			Gdip_draw_Win(GuiHwnd,angleM,angleH,rim,bgrd)	
			SetBatchLines, 10ms
			flash_on:=0			
		}
	}
return


;============================================

start_blink:
if(flash_on){
	SetTimer,start_blink, -2000
	flash_on:=0	
	return
}
	;SoundPlay, *48
	max_R:=110 
	b1:=0, b2:=0, b3:=0, 	
	stepB:=3
	go:=1	, i:=0
	SetTimer,blink, 30
	go:=1	
return

blink:
if(flash_on)
	return
SetBatchLines, -1
	b3a:= (b3>max_R) ? 0 : b3
	Gdip_animate(GuiHwnd,0x99D35050,b1,b2,b3a)

	b1:= go ? b1+stepB : 0	
	b2:= b2 ? b2+stepB : 0
	b3:= b3 ? b3+stepB : 0

	if(b1>max_R){ 
		b1:=0
		go:=0
		i++
	}

 	if(b1>30 && !b2){
			b2:=b2+stepB
	} 
	
	if(b1>60 && !b3){
			b3:=b3+stepB
	} 		 

	if(b2>max_R){
			b2:=0
	} 		

	if(b3>max_R+30){ ; delay between
			b3:=0
			go:=1	
			;SoundPlay, *48
	}

if(i>=3) {	
		go:=0
		if(b3>max_R-10){
			SetTimer,blink, Off
			b1:=0, b2:=0, b3:=0
			timesBlink++
			Gdip_draw_Win(GuiHwnd,angleM,angleH,rim)
			SetBatchLines, 10ms		
			;Menu, Tray, Tip , %tray_tip%
			Menu, Tray, Tip , %tray_tip%`nblink %timesBlink% x ;times
		}
		
}

if(timesBlink>timesBlink_max){  ;  6 timesBlink ~= 1 min
		Gosub, alarm_off
		Gui,3: Destroy
		SetBatchLines, 10ms			
		;SoundPlay, *64 
		Menu, Tray, Tip , %tray_tip%
		;Menu, Tray, Tip , %tray_tip%`nblink %timesBlink% times
} 
	
return
;==================================

 
GetDateFormat(Date, Format := "dddd',' dd. MMMM yyyy",locale:=0x0409){ ; by jNizM  
	;Polish:=0x0415
	;locale:=0x0415
    VarSetCapacity(SYSTEMTIME, 16)
    , NumPut(SubStr(Date, 1, 4), SYSTEMTIME, 0, "UShort")
    , NumPut(SubStr(Date, 5, 2), SYSTEMTIME, 2, "UShort")
    , NumPut(SubStr(Date, 7, 2), SYSTEMTIME, 6, "UShort")
    size := DllCall("GetDateFormat", "UInt", locale, "UInt", 0, "Ptr", &SYSTEMTIME, "Ptr", &Format, "Ptr", 0, "Int", 0)
    VarSetCapacity(buf, size * (A_IsUnicode ? 2 : 1), 0)
    if !(DllCall("GetDateFormat", "UInt", locale, "UInt", 0, "Ptr", &SYSTEMTIME, "Ptr", &Format, "Str", buf, "Int", size))
        return "*" A_LastError
    return buf
}



;==================================		

show_alarm_list:
	Gui,6:+Owner1 
  Gui,6: +ToolWindow -Caption +AlwaysOnTop	+HwndGuiListHwnd   
  Gui,6:Font, S7 w800 CDefault , Segoe UI 
  Gui,6: Margin, 1,1
  Gui,6: Add, ListBox, w30 r8 vListBox_1 gListBox, 1m|2m|3m||5m|10m|15m|30m|Input
  Gui,6:Color, 900000 ;120F00 	
	
	WinGetPos, x1,y1,,, ahk_id %GuiHwnd%
	x2:=x1+52,y2:=y1+20
	Gui,6:Show, x%x2% y%y2% , alarm_list_Drozd
return

ListBox:
  Gui,6:Submit, Nohide
  if(A_ThisLabel=="ListBox"){
    if(ListBox_1=="Input"){
			Gosub, start_timer_input
			if ErrorLevel  ;CANCEL
        return
  }else
    RegExMatch(ListBox_1,"im)\d+", min_input)    
  }
	;Run C:\Program Files\Misc\AutoHotkey Scripts\Alarm_timer_auto.ahk %min% "" "no beep"
	start_time:=A_TickCount
	seconds:=min_input* 60
	if(seconds<1)
		return
	Gosub, show_time
	SetTimer, timer_compare, 1000
	FormatTime, timer_started_on,, HH:mm:ss 
	Gui,6: Destroy
return


stop_timer:
	Gui,3: Destroy
	Menu, Tray, Tip ,
	SetTimer, timer_compare, Off
	SetTimer, start_blink, Off
return

start_timer_input:
	Gui,6: Destroy
	Gui,1: +OwnDialogs
	InputBox, min_input,  Alarm timer, time in minutes, , 160, 120,,, , , 0.1
		if ErrorLevel  ;CANCEL
			return
		
	start_time:=A_TickCount
	seconds:=min_input* 60
		if(seconds<1)
		return
	Gosub, show_time
	SetTimer, timer_compare, 1000
	FormatTime, timer_started_on,, HH:mm:ss 
return

start_timer_1m:
start_timer_5m:
start_timer_10m:
start_timer_15m:
start_timer_30m:
start_timer_60m:
start_timer:
	Gui,3: Destroy
	RegExMatch(A_ThisLabel,"i)_(\d+)m", t)
	start_time:=A_TickCount
	TIME_min:= 0.2
	TIME_min:= t1
	seconds:=TIME_min* 60
	Gosub, show_time
	SetTimer, timer_compare, 1000
	FormatTime, timer_started_on,, HH:mm:ss 
return	
	
	
timer_compare: 
	time_compare := Round((A_TickCount - start_time)/1000)
	time_compare:=seconds-time_compare
	compare_timeLeft_h := Floor(time_compare/3600)
	compare_timeLeft_m := time_compare>3600 ? Floor(mod(time_compare,3600)/60) : Floor(time_compare/60)
	compare_timeLeft_s := Floor(mod(time_compare,60))
	time_compare_show:=compare_timeLeft_h >0 ? dig(compare_timeLeft_h) ":" dig(compare_timeLeft_m) ":" dig(compare_timeLeft_s)  : dig(compare_timeLeft_m) ":" dig(compare_timeLeft_s) 

tray_tip:="timer:          " min_input " min" "`ntime left:     " time_compare_show  "`nstarted on:  " timer_started_on
	Menu, Tray, Tip , % tray_tip   
	GuiControl,3:, Show_timer, %time_compare_show%
	if(time_compare<=0){
		 SetTimer, timer_compare, Off
		 Gosub, alarm		 
	}
return


alarm:
	Gui,3: Destroy
	;Menu, Tray, Tip ,
	alarm_on:=1
	SoundGet, loudness_start	
	;if(regulate_loudness)
		;SoundSet, %alarm_loudness%
	
	alarm_sound2=C:\WINDOWS\Media\chimes.wav
	alarm_sound=C:\WINDOWS\Media\notify.wav
	alarm_sound:=alarm_sound0
	;SoundPlay, %alarm_sound% ;, wait	
	play_music(alarm_sound)
		
	if(PCspeaker==1){
      ;SoundBeep,400,150  ;low
			;SoundBeep,520,50   ; high
      SoundBeep,700
      SoundBeep,520,400  ;SoundBeep,520,400  
  }
	
	if(PCspeaker==2){
      SoundBeep,2000,40 ; short  
  }	

	timesBlink:=0
	Gosub, start_blink
	SetTimer, repeat_alarm, 10000
return
			



play_music(sound:=""){
  global last_sound , alarm_loudness , regulate_loudness, loudness_start
	;SoundGet, loudness_start	
	sound:=sound ? sound : last_sound
  SoundPlay, %sound%
	;SoundSet, %alarm_loudness%	
	if(regulate_loudness)
		play_loudness(alarm_loudness)  
}


play_loudness(alarm_loudness){
 loop, 10 {
  SoundSet, % A_Index*alarm_loudness/10
  Sleep, 100
 }
}

play_music_Off(){
	global alarm_loudness, loudness_start
	global alarm_on:=0
	SoundGet, start
	start:= (start) ? start : alarm_loudness
	loop, 10 {
		sndLev:=(10-A_Index)*start/10
		SoundSet, % sndLev
		Sleep, 100
 } until (sndLev<5)
 SoundPlay, nic
 loudness_start:= (loudness_start>5) ? loudness_start : 10
 SoundSet, %loudness_start%
}



repeat_alarm:
	Gosub, start_blink
return

alarm_off:	
	alarm_on:=0
	SetTimer, blink, Off
	SetTimer, repeat_alarm, Off
	Gdip_draw_Win(GuiHwnd,angleM,angleH,rim,bgrd)
	
	if(regulate_loudness){
		play_music_Off()
	}else
		SoundPlay, nic
	;if(regulate_loudness && loudness_start)
			;SoundSet, %loudness_start%	
	;SoundPlay, nic
return

show_time:
	Gui,3: Destroy
	WinGetPos, x1,y1,,, ahk_id %GuiHwnd%
	x2:=x1+42,y2:=y1+134
  Gui,3: +ToolWindow -Caption +AlwaysOnTop	  
	Gui,3: +Owner1  
  Gui,3:Color, 120F00 
  Gui,3: Font, S8 W700 , Tahoma ;Segoe UI  Verdana
  Gui,3: Add, Text , x0 y2 w53  cFFFFFF vShow_timer Center, 
  Gui,3: Font, S6 cD0D0D0
	Gui,3:Show,  x%x2% y%y2%  w52 h18 NA, Drozd_show_timer
  Winset, Transparent,200, Drozd_show_timer
  OnMessage(0x201, "WM_LBUTTONDOWN") ; movable borderless window   
return


dig(num){ ;to_two_digits
   num:= num<=9 ? "0" . num : num
   return num
}
	
beep:
	;SoundPlay *48	
	SoundPlay, % A_WinDir "\Media\notify.wav" ; chimes.wav
return

beep_Off:
	SetTimer, beep, Off
return

GuiSize:  ; on window resize
	WinGetPos, x1,y1,,, ahk_id %GuiHwnd%
	x2:=x1+47,y2:=y1+134	
	WinMove , Drozd_show_timer ,,  x2 ,  y2
	WinGetPos, x1,y1,,, Drozd_show_timer
return
	
;==================================	

BackgroundTransparent:
	bgrd:="" ; default
	IniWrite, %bgrd%	, %settings_ini%, window , Background
	Gdip_draw_Win(GuiHwnd,angleM,angleH,rim,bgrd)
return

BackgroundHalfTransparent:
	bgrd:="0x99120F00" 
	;bgrd:="0x994E4A39"
	IniWrite, %bgrd%	, %settings_ini%, window , Background
	Gdip_draw_Win(GuiHwnd,angleM,angleH,rim,bgrd)
return

BackgroundGradientB:
	bgrd_Blue:="0xff2D3F5D|0xff1A2333"
	bgrd:=bgrd_Blue
	IniWrite, %bgrd%	, %settings_ini%, window , Background
	Gdip_draw_Win(GuiHwnd,angleM,angleH,rim,bgrd)
return

BackgroundGradientR:
	bgrd_Red:="0xff5C2C30|0xff311B1D"
	bgrd:=bgrd_Red
	IniWrite, %bgrd%	, %settings_ini%, window , Background
	Gdip_draw_Win(GuiHwnd,angleM,angleH,rim,bgrd)
return
BackgroundGradientG:
	bgrd_Green:="0xff26532E|0xff1E3322"
	bgrd:=bgrd_Green
	IniWrite, %bgrd%	, %settings_ini%, window , Background
	Gdip_draw_Win(GuiHwnd,angleM,angleH,rim,bgrd)
return

;====================

Show_small_date:
	if(small_date==1){
		small_date:=0
		IniWrite, 0	, %settings_ini%, window , small date
		Menu, Submenu2, UnCheck, Show small date on/off
	}else{
		small_date:=1
		IniWrite, 1 , %settings_ini%, window , small date
		Menu, Submenu2, Check, Show small date on/off
	}
	Gdip_draw_Win(GuiHwnd,angleM,angleH,rim,bgrd)
return

full_hour_flash:
	if(full_hour_flash==1){
		full_hour_flash:=0
		IniWrite, 0	, %settings_ini%, window , full hour flash
		Menu, Submenu2, UnCheck, Full hour flash  on/off
	}else{
		full_hour_flash:=1
		IniWrite, 1 , %settings_ini%, window , full hour flash
		Menu, Submenu2, Check, Full hour flash  on/off
	}
return

;====================

Regulate_loudness:
	if(regulate_loudness==1){
		regulate_loudness:=0
		IniWrite, 0	, %settings_ini%, Misc , regulate loudness
		Menu, Submenu2, UnCheck, Regulate loudness on/off  
	}else{
		regulate_loudness:=1
		IniWrite, 1 , %settings_ini%, Misc , regulate loudness
		Menu, Submenu2, Check, Regulate loudness on/off  
	}
return

set_alarm_loudness:
	InputBox, alarm_loudness,  Alarm timer, Alarm loudness: 0-100, , 160, 120,,, , , %alarm_loudness%
		if ErrorLevel  ;CANCEL
			return
		IniWrite, %alarm_loudness%	, %settings_ini%, Misc , alarm loudness
return

;=========================================

onTop:
		WonTop:=!WonTop             
		if WonTop {
			WinSet, AlwaysOnTop, on, Drozd_zegar
		}else{
			WinSet, AlwaysOnTop, off, Drozd_zegar
		}	
return


;=========================================
clear_memory:
	EmptyMem(PID)
return
;=========================================


GoToSavedPos: 
	IniRead, pos_x_saved, %settings_ini%, window position, x	
	IniRead, pos_y_saved, %settings_ini%, window position, y	
	if(pos_x_saved<A_ScreenWidth-120 && pos_y_saved<A_ScreenHeight-140)
		WinMove,  Drozd_zegar, ,pos_x_saved,pos_y_saved
return

save_position:
	WinGetPos, x1,y1,,, ahk_id %GuiHwnd%
	IniWrite, %x1%	, %settings_ini%, window position, x
	IniWrite, %y1%	, %settings_ini%, window position, y 
return

Open_ini:
Run, %settings_ini%
return



~$F4::
	Gui 1: Show
return

temp_routine:
str:="small_date= " small_date "`n"
		. "full_hour_flash= " full_hour_flash "`n"
		. "alarm_loudness= " alarm_loudness "`n"
		. "regulate_loudness= " regulate_loudness "`n"
		;. "flash_on= " flash_on "`n"
		; . "PCspeaker= " PCspeaker "`n"
		; . "timesBlink_max= " timesBlink_max "`n"
	MsgBox,,, % str
return

;============================================
 
;===test

~+^g::
if(full_hour_flash)
	gosub start_flash
return

~+^h::gosub start_blink



;============================================

GuiContextMenu:
Menu, ContextMenu, Show, %A_GuiX%, %A_GuiY%
Return

Reload:
Reload
return


WindowSpy:
Run, "C:\Program Files\AutoHotkey\AU3_Spy.exe" ;"C:\Program Files\AutoHotkey\WindowSpy.ahk"
WinWait, ahk_exe AU3_Spy.exe , , 3
WinMove, Active Window Info, , 1100
return



Edit_Notepad:
Run, "C:\Program Files\Misc\Notepad2\Notepad2.exe" "%A_ScriptFullPath%"
return

Edit_Scite:
Run, "C:\Program Files\AutoHotkey\SciTE\SciTE.exe"  "%A_ScriptFullPath%"
return


show_help:
Progress, zh0 w600 M2 C0y ZX20 ZY10 CWFFFFFF FS8 FM10 WM700 WS700 ,%help%, Drozd clock  , Drozd clock Help, Segoe UI Semibold
return

Close:
;Esc:: 
GuiClose:
Exit:
Gdip_Shutdown(pToken)
ExitApp


;======================================

EmptyMem(PID:=0){ ; https://autohotkey.com/board/topic/30042-run-ahk-scripts-with-less-half-or-even-less-memory-usage/
    PID:=(PID) ? PID : DllCall("GetCurrentProcessId") 
    h:=DllCall("OpenProcess", "UInt", 0x001F0FFF, "Int", 0, "Int", pid)
    DllCall("SetProcessWorkingSetSize", "UInt", h, "Int", -1, "Int", -1)
    DllCall("CloseHandle", "Int", h)
}

;======================================


;#Include C:\Program Files\Misc\AutoHotkey Scripts\AHK_Library\Gdip_All.ahk


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




Gdip_BrushCreateSolid(ARGB=0xff000000)
{
	DllCall("gdiplus\GdipCreateSolidFill", "UInt", ARGB, A_PtrSize ? "UPtr*" : "UInt*", pBrush)
	return pBrush
}


Gdip_CreateLineBrushFromRect(x, y, w, h, ARGB1, ARGB2, LinearGradientMode=1, WrapMode=1)
{
	CreateRectF(RectF, x, y, w, h)
	DllCall("gdiplus\GdipCreateLineBrushFromRect", A_PtrSize ? "UPtr" : "UInt", &RectF, "int", ARGB1, "int", ARGB2, "int", LinearGradientMode, "int", WrapMode, A_PtrSize ? "UPtr*" : "UInt*", LGpBrush)
	return LGpBrush
}

Gdip_CreatePath(BrushMode=0)
{
	DllCall("gdiplus\GdipCreatePath", "int", BrushMode, A_PtrSize ? "UPtr*" : "UInt*", Path)
	return Path
}

Gdip_DrawLine(pGraphics, pPen, x1, y1, x2, y2)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	
	return DllCall("gdiplus\GdipDrawLine"
					, Ptr, pGraphics
					, Ptr, pPen
					, "float", x1
					, "float", y1
					, "float", x2
					, "float", y2)
}

Gdip_DrawLines(pGraphics, pPen, Points)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	StringSplit, Points, Points, |
	VarSetCapacity(PointF, 8*Points0)   
	Loop, %Points0%
	{
		StringSplit, Coord, Points%A_Index%, `,
		NumPut(Coord1, PointF, 8*(A_Index-1), "float"), NumPut(Coord2, PointF, (8*(A_Index-1))+4, "float")
	}
	return DllCall("gdiplus\GdipDrawLines", Ptr, pGraphics, Ptr, pPen, Ptr, &PointF, "int", Points0)
}

Gdip_AddPathPolygon(Path, Points)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	
	StringSplit, Points, Points, |
	VarSetCapacity(PointF, 8*Points0)   
	Loop, %Points0%
	{
		StringSplit, Coord, Points%A_Index%, `,
		NumPut(Coord1, PointF, 8*(A_Index-1), "float"), NumPut(Coord2, PointF, (8*(A_Index-1))+4, "float")
	}   

	return DllCall("gdiplus\GdipAddPathPolygon", Ptr, Path, Ptr, &PointF, "int", Points0)
}


Gdip_FillEllipse(pGraphics, pBrush, x, y, w, h)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	
	return DllCall("gdiplus\GdipFillEllipse", Ptr, pGraphics, Ptr, pBrush, "float", x, "float", y, "float", w, "float", h)
}

Gdip_DrawEllipse(pGraphics, pPen, x, y, w, h)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	
	return DllCall("gdiplus\GdipDrawEllipse", Ptr, pGraphics, Ptr, pPen, "float", x, "float", y, "float", w, "float", h)
}



Gdip_FillRectangle(pGraphics, pBrush, x, y, w, h)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	
	return DllCall("gdiplus\GdipFillRectangle"
					, Ptr, pGraphics
					, Ptr, pBrush
					, "float", x
					, "float", y
					, "float", w
					, "float", h)
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

Gdip_DrawRoundedRectangle(pGraphics, pPen, x, y, w, h, r)
{
	Gdip_SetClipRect(pGraphics, x-r, y-r, 2*r, 2*r, 4)
	Gdip_SetClipRect(pGraphics, x+w-r, y-r, 2*r, 2*r, 4)
	Gdip_SetClipRect(pGraphics, x-r, y+h-r, 2*r, 2*r, 4)
	Gdip_SetClipRect(pGraphics, x+w-r, y+h-r, 2*r, 2*r, 4)
	E := Gdip_DrawRectangle(pGraphics, pPen, x, y, w, h)
	Gdip_ResetClip(pGraphics)
	Gdip_SetClipRect(pGraphics, x-(2*r), y+r, w+(4*r), h-(2*r), 4)
	Gdip_SetClipRect(pGraphics, x+r, y-(2*r), w-(2*r), h+(4*r), 4)
	Gdip_DrawEllipse(pGraphics, pPen, x, y, 2*r, 2*r)
	Gdip_DrawEllipse(pGraphics, pPen, x+w-(2*r), y, 2*r, 2*r)
	Gdip_DrawEllipse(pGraphics, pPen, x, y+h-(2*r), 2*r, 2*r)
	Gdip_DrawEllipse(pGraphics, pPen, x+w-(2*r), y+h-(2*r), 2*r, 2*r)
	Gdip_ResetClip(pGraphics)
	return E
}

Gdip_DrawRectangle(pGraphics, pPen, x, y, w, h)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	
	return DllCall("gdiplus\GdipDrawRectangle", Ptr, pGraphics, Ptr, pPen, "float", x, "float", y, "float", w, "float", h)
}

Gdip_SetClipPath(pGraphics, Path, CombineMode=0)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	return DllCall("gdiplus\GdipSetClipPath", Ptr, pGraphics, Ptr, Path, "int", CombineMode)
}

Gdip_GraphicsClear(pGraphics, ARGB=0x00ffffff)
{
    return DllCall("gdiplus\GdipGraphicsClear", A_PtrSize ? "UPtr" : "UInt", pGraphics, "int", ARGB)
}

Gdip_ResetClip(pGraphics)
{
   return DllCall("gdiplus\GdipResetClip", A_PtrSize ? "UPtr" : "UInt", pGraphics)
}

Gdip_GetClipRegion(pGraphics)
{
	Region := Gdip_CreateRegion()
	DllCall("gdiplus\GdipGetClip", A_PtrSize ? "UPtr" : "UInt", pGraphics, "UInt*", Region)
	return Region
}

Gdip_SetClipRect(pGraphics, x, y, w, h, CombineMode=0)
{
   return DllCall("gdiplus\GdipSetClipRect",  A_PtrSize ? "UPtr" : "UInt", pGraphics, "float", x, "float", y, "float", w, "float", h, "int", CombineMode)
}

Gdip_SetClipRegion(pGraphics, Region, CombineMode=0)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	
	return DllCall("gdiplus\GdipSetClipRegion", Ptr, pGraphics, Ptr, Region, "int", CombineMode)
}

Gdip_CreateRegion()
{
	DllCall("gdiplus\GdipCreateRegion", "UInt*", Region)
	return Region
}

Gdip_DeleteRegion(Region)
{
	return DllCall("gdiplus\GdipDeleteRegion", A_PtrSize ? "UPtr" : "UInt", Region)
}

Gdip_FontCreate(hFamily, Size, Style=0)
{
   DllCall("gdiplus\GdipCreateFont", A_PtrSize ? "UPtr" : "UInt", hFamily, "float", Size, "int", Style, "int", 0, A_PtrSize ? "UPtr*" : "UInt*", hFont)
   return hFont
}

Gdip_FontFamilyCreate(Font)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	
	if (!A_IsUnicode)
	{
		nSize := DllCall("MultiByteToWideChar", "uint", 0, "uint", 0, Ptr, &Font, "int", -1, "uint", 0, "int", 0)
		VarSetCapacity(wFont, nSize*2)
		DllCall("MultiByteToWideChar", "uint", 0, "uint", 0, Ptr, &Font, "int", -1, Ptr, &wFont, "int", nSize)
	}
	
	DllCall("gdiplus\GdipCreateFontFamilyFromName"
					, Ptr, A_IsUnicode ? &Font : &wFont
					, "uint", 0
					, A_PtrSize ? "UPtr*" : "UInt*", hFamily)
	
	return hFamily
}

Gdip_StringFormatCreate(Format=0, Lang=0)
{
   DllCall("gdiplus\GdipCreateStringFormat", "int", Format, "int", Lang, A_PtrSize ? "UPtr*" : "UInt*", hFormat)
   return hFormat
}

Gdip_SetStringFormatAlign(hFormat, Align)
{
   return DllCall("gdiplus\GdipSetStringFormatAlign", A_PtrSize ? "UPtr" : "UInt", hFormat, "int", Align)
}


Gdip_SetTextRenderingHint(pGraphics, RenderingHint)
{
	return DllCall("gdiplus\GdipSetTextRenderingHint", A_PtrSize ? "UPtr" : "UInt", pGraphics, "int", RenderingHint)
}

Gdip_MeasureString(pGraphics, sString, hFont, hFormat, ByRef RectF)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	
	VarSetCapacity(RC, 16)
	if !A_IsUnicode
	{
		nSize := DllCall("MultiByteToWideChar", "uint", 0, "uint", 0, Ptr, &sString, "int", -1, "uint", 0, "int", 0)
		VarSetCapacity(wString, nSize*2)   
		DllCall("MultiByteToWideChar", "uint", 0, "uint", 0, Ptr, &sString, "int", -1, Ptr, &wString, "int", nSize)
	}
	
	DllCall("gdiplus\GdipMeasureString"
					, Ptr, pGraphics
					, Ptr, A_IsUnicode ? &sString : &wString
					, "int", -1
					, Ptr, hFont
					, Ptr, &RectF
					, Ptr, hFormat
					, Ptr, &RC
					, "uint*", Chars
					, "uint*", Lines)
	
	return &RC ? NumGet(RC, 0, "float") "|" NumGet(RC, 4, "float") "|" NumGet(RC, 8, "float") "|" NumGet(RC, 12, "float") "|" Chars "|" Lines : 0
}

Gdip_DrawString(pGraphics, sString, hFont, hFormat, pBrush, ByRef RectF)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	
	if (!A_IsUnicode)
	{
		nSize := DllCall("MultiByteToWideChar", "uint", 0, "uint", 0, Ptr, &sString, "int", -1, Ptr, 0, "int", 0)
		VarSetCapacity(wString, nSize*2)
		DllCall("MultiByteToWideChar", "uint", 0, "uint", 0, Ptr, &sString, "int", -1, Ptr, &wString, "int", nSize)
	}
	
	return DllCall("gdiplus\GdipDrawString"
					, Ptr, pGraphics
					, Ptr, A_IsUnicode ? &sString : &wString
					, "int", -1
					, Ptr, hFont
					, Ptr, &RectF
					, Ptr, hFormat
					, Ptr, pBrush)
}


Gdip_CreateBitmapFromHBITMAP(hBitmap, Palette=0)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	
	DllCall("gdiplus\GdipCreateBitmapFromHBITMAP", Ptr, hBitmap, Ptr, Palette, A_PtrSize ? "UPtr*" : "uint*", pBitmap)
	return pBitmap
}

Gdip_CreateBitmap(Width, Height, Format=0x26200A)
{
    DllCall("gdiplus\GdipCreateBitmapFromScan0", "int", Width, "int", Height, "int", 0, "int", Format, A_PtrSize ? "UPtr" : "UInt", 0, A_PtrSize ? "UPtr*" : "uint*", pBitmap)
    Return pBitmap
}

Gdip_GraphicsFromImage(pBitmap)
{
	DllCall("gdiplus\GdipGetImageGraphicsContext", A_PtrSize ? "UPtr" : "UInt", pBitmap, A_PtrSize ? "UPtr*" : "UInt*", pGraphics)
	return pGraphics
}


Gdip_AddPathEllipse(Path, x, y, w, h)
{
	return DllCall("gdiplus\GdipAddPathEllipse", A_PtrSize ? "UPtr" : "UInt", Path, "float", x, "float", y, "float", w, "float", h)
}


GetDC(hwnd=0)
{
	return DllCall("GetDC", A_PtrSize ? "UPtr" : "UInt", hwnd)
}

ReleaseDC(hdc, hwnd=0)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	
	return DllCall("ReleaseDC", Ptr, hwnd, Ptr, hdc)
}


Gdip_DeletePath(Path)
{
	return DllCall("gdiplus\GdipDeletePath", A_PtrSize ? "UPtr" : "UInt", Path)
}


Gdip_FillPath(pGraphics, pBrush, Path)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	
	return DllCall("gdiplus\GdipFillPath", Ptr, pGraphics, Ptr, pBrush, Ptr, Path)
}

CreateRectF(ByRef RectF, x, y, w, h)
{
   VarSetCapacity(RectF, 16)
   NumPut(x, RectF, 0, "float"), NumPut(y, RectF, 4, "float"), NumPut(w, RectF, 8, "float"), NumPut(h, RectF, 12, "float")
}

CreateRect(ByRef Rect, x, y, w, h)
{
	VarSetCapacity(Rect, 16)
	NumPut(x, Rect, 0, "uint"), NumPut(y, Rect, 4, "uint"), NumPut(w, Rect, 8, "uint"), NumPut(h, Rect, 12, "uint")
}

DeleteObject(hObject)
{
   return DllCall("DeleteObject", A_PtrSize ? "UPtr" : "UInt", hObject)
}

DeleteDC(hdc)
{
   return DllCall("DeleteDC", A_PtrSize ? "UPtr" : "UInt", hdc)
}


Gdip_DeleteStringFormat(hFormat)
{
   return DllCall("gdiplus\GdipDeleteStringFormat", A_PtrSize ? "UPtr" : "UInt", hFormat)
}


Gdip_DeleteFontFamily(hFamily)
{
   return DllCall("gdiplus\GdipDeleteFontFamily", A_PtrSize ? "UPtr" : "UInt", hFamily)
}

Gdip_DeleteFont(hFont)
{
   return DllCall("gdiplus\GdipDeleteFont", A_PtrSize ? "UPtr" : "UInt", hFont)
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


Gdip_DrawImage(pGraphics, pBitmap, dx="", dy="", dw="", dh="", sx="", sy="", sw="", sh="", Matrix=1)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	
	if (Matrix&1 = "")
		ImageAttr := Gdip_SetImageAttributesColorMatrix(Matrix)
	else if (Matrix != 1)
		ImageAttr := Gdip_SetImageAttributesColorMatrix("1|0|0|0|0|0|1|0|0|0|0|0|1|0|0|0|0|0|" Matrix "|0|0|0|0|0|1")

	if (sx = "" && sy = "" && sw = "" && sh = "")
	{
		if (dx = "" && dy = "" && dw = "" && dh = "")
		{
			sx := dx := 0, sy := dy := 0
			sw := dw := Gdip_GetImageWidth(pBitmap)
			sh := dh := Gdip_GetImageHeight(pBitmap)
		}
		else
		{
			sx := sy := 0
			sw := Gdip_GetImageWidth(pBitmap)
			sh := Gdip_GetImageHeight(pBitmap)
		}
	}

	E := DllCall("gdiplus\GdipDrawImageRectRect"
				, Ptr, pGraphics
				, Ptr, pBitmap
				, "float", dx
				, "float", dy
				, "float", dw
				, "float", dh
				, "float", sx
				, "float", sy
				, "float", sw
				, "float", sh
				, "int", 2
				, Ptr, ImageAttr
				, Ptr, 0
				, Ptr, 0)
	if ImageAttr
		Gdip_DisposeImageAttributes(ImageAttr)
	return E
}


Gdip_SetImageAttributesColorMatrix(Matrix)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	
	VarSetCapacity(ColourMatrix, 100, 0)
	Matrix := RegExReplace(RegExReplace(Matrix, "^[^\d-\.]+([\d\.])", "$1", "", 1), "[^\d-\.]+", "|")
	StringSplit, Matrix, Matrix, |
	Loop, 25
	{
		Matrix := (Matrix%A_Index% != "") ? Matrix%A_Index% : Mod(A_Index-1, 6) ? 0 : 1
		NumPut(Matrix, ColourMatrix, (A_Index-1)*4, "float")
	}
	DllCall("gdiplus\GdipCreateImageAttributes", A_PtrSize ? "UPtr*" : "uint*", ImageAttr)
	DllCall("gdiplus\GdipSetImageAttributesColorMatrix", Ptr, ImageAttr, "int", 1, "int", 1, Ptr, &ColourMatrix, Ptr, 0, "int", 0)
	return ImageAttr
}



Gdip_GetImageWidth(pBitmap)
{
   DllCall("gdiplus\GdipGetImageWidth", A_PtrSize ? "UPtr" : "UInt", pBitmap, "uint*", Width)
   return Width
}

Gdip_GetImageHeight(pBitmap)
{
   DllCall("gdiplus\GdipGetImageHeight", A_PtrSize ? "UPtr" : "UInt", pBitmap, "uint*", Height)
   return Height
}


Gdip_DisposeImageAttributes(ImageAttr)
{
	return DllCall("gdiplus\GdipDisposeImageAttributes", A_PtrSize ? "UPtr" : "UInt", ImageAttr)
}

Gdip_GetDimensions(pBitmap, ByRef Width, ByRef Height)
{
	Gdip_GetImageDimensions(pBitmap, Width, Height)
}

Gdip_GetImageDimensions(pBitmap, ByRef Width, ByRef Height)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	DllCall("gdiplus\GdipGetImageWidth", Ptr, pBitmap, "uint*", Width)
	DllCall("gdiplus\GdipGetImageHeight", Ptr, pBitmap, "uint*", Height)
}

Gdip_LockBits(pBitmap, x, y, w, h, ByRef Stride, ByRef Scan0, ByRef BitmapData, LockMode = 3, PixelFormat = 0x26200a)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	
	CreateRect(Rect, x, y, w, h)
	VarSetCapacity(BitmapData, 16+2*(A_PtrSize ? A_PtrSize : 4), 0)
	E := DllCall("Gdiplus\GdipBitmapLockBits", Ptr, pBitmap, Ptr, &Rect, "uint", LockMode, "int", PixelFormat, Ptr, &BitmapData)
	Stride := NumGet(BitmapData, 8, "Int")
	Scan0 := NumGet(BitmapData, 16, Ptr)
	return E
}

Gdip_UnlockBits(pBitmap, ByRef BitmapData)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	
	return DllCall("Gdiplus\GdipBitmapUnlockBits", Ptr, pBitmap, Ptr, &BitmapData)
}

;===================================
;https://autohotkey.com/board/topic/103475-gdi-cutting-anti-aliasing/#post_id_638772
Gdip_AlphaMask(ByRef pBitmap, pBitmapMask, x, y, invert=0)
{
    static _AlphaMask
    if !_AlphaMask
    {
        MCode_AlphaMask := "518B4424249983E20303C28BC88B442428995383E20303C28B5424245556C1F902C1F802837C24400057757E85D20F8E0E01000"
        . "08B5C241C8B74242C03C003C0894424388D048D000000000FAF4C2440034C243C894424348B4424208D3C888954244485F67E2C8B5424182B5424208"
        . "BCF8BC38B2C0A332883C00481E5FFFFFF003368FC83C10483EE018969FC75E48B74242C037C2434035C2438836C24440175C15F5E5D33C05B59C385D"
        . "20F8E900000008B5C241C8B74242C03C003C0894424388D048D000000000FAF4C2440034C243C894424348B442420895C24448D3C888954241085F67"
        . "E428B5424182B5424208BC78BCBEB098DA424000000008BFF8B1981E3000000FFBD000000FF2BEB8B1C1081E3FFFFFF000BEB892883C10483C00483E"
        . "E0175D98B74242C8B5C2444035C2438037C2434836C241001895C244475A35F5E5D33C05B59C3"

        VarSetCapacity(_AlphaMask, StrLen(MCode_AlphaMask)//2)
        Loop % StrLen(MCode_AlphaMask)//2      ;%
            NumPut("0x" SubStr(MCode_AlphaMask, (2*A_Index)-1, 2), _AlphaMask, A_Index-1, "char")
    }
    Gdip_GetDimensions(pBitmap, w1, h1), Gdip_GetDimensions(pBitmapMask, w2, h2)
    pBitmapNew := Gdip_CreateBitmap(w1, h1)
    if !pBitmapNew
        return -1

    E1 := Gdip_LockBits(pBitmap, 0, 0, w1, h1, Stride1, Scan01, BitmapData1)
    E2 := Gdip_LockBits(pBitmapMask, 0, 0, w2, h2, Stride2, Scan02, BitmapData2)
    E3 := Gdip_LockBits(pBitmapNew, 0, 0, w1, h1, Stride3, Scan03, BitmapData3)
    if (E1 || E2 || E3)
        return -2

    E := DllCall(&_AlphaMask, "ptr", Scan01, "ptr", Scan02, "ptr", Scan03, "int", w1, "int", h1, "int", w2, "int", h2, "int", Stride1, "int", Stride2, "int", x, "int", y, "int", invert)
    
    Gdip_UnlockBits(pBitmap, BitmapData1), Gdip_UnlockBits(pBitmapMask, BitmapData2), Gdip_UnlockBits(pBitmapNew, BitmapData3)
    return (E = "") ? -3 : pBitmapNew
}

;===================================

;just me ; https://autohotkey.com/board/topic/29449-gdi-standard-library-145-by-tic/page-65#post_id_501189

; ----------------------------------------------------------------------------------------------------------------------
Gdip_PathGradientCreateFromPath(pPath) {
   ; Creates and returns a path gradient brush.
   ; pPath              path object returned from Gdip_CreatePath()
   DllCall("Gdiplus.dll\GdipCreatePathGradientFromPath", "Ptr", pPath, "PtrP", pBrush)
   Return pBrush
}
; ----------------------------------------------------------------------------------------------------------------------
Gdip_PathGradientSetCenterPoint(pBrush, X, Y) {
   ; Sets the center point of this path gradient brush.
   ; pBrush             Brush object returned from Gdip_PathGradientCreateFromPath().
   ; X                  X-position (pixel).
   ; Y                  Y-position (pixel).
   VarSetCapacity(POINTF, 8)
   NumPut(X, POINTF, 0, "Float")
   NumPut(Y, POINTF, 4, "Float")
   Return DllCall("Gdiplus.dll\GdipSetPathGradientCenterPoint", "Ptr", pBrush, "Ptr", &POINTF)
}
; ----------------------------------------------------------------------------------------------------------------------
Gdip_PathGradientSetCenterColor(pBrush, CenterColor) {
   ; Sets the center color of this path gradient brush.
   ; pBrush             Brush object returned from Gdip_PathGradientCreateFromPath().
   ; CenterColor        ARGB color value: A(lpha)R(ed)G(reen)B(lue).
   Return DllCall("Gdiplus.dll\GdipSetPathGradientCenterColor", "Ptr", pBrush, "UInt", CenterColor)   
}
; ----------------------------------------------------------------------------------------------------------------------
Gdip_PathGradientSetSurroundColors(pBrush, SurroundColors) {
   ; Sets the surround colors of this path gradient brush. 
   ; pBrush             Brush object returned from Gdip_PathGradientCreateFromPath().
   ; SurroundColours    One or more ARGB color values seperated by pipe (|)).
   StringSplit, Colors, SurroundColors, |
   VarSetCapacity(ColorArray, 4 * Colors0, 0)
   Loop, % Colors0 {
      NumPut(Colors%A_Index%, ColorArray, 4 * (A_Index - 1), "UInt")
   }
   Return DllCall("Gdiplus.dll\GdipSetPathGradientSurroundColorsWithCount", "Ptr", pBrush, "Ptr", &ColorArray
                , "IntP", Colors0)
}
; ----------------------------------------------------------------------------------------------------------------------
Gdip_PathGradientSetSigmaBlend(pBrush, Focus, Scale = 1) {
   ; Sets the blend shape of this path gradient brush to bell shape.
   ; pBrush             Brush object returned from Gdip_PathGradientCreateFromPath().
   ; Focus              Number that specifies where the center color will be at its highest intensity.
   ;                    Values: 1.0 (center) - 0.0 (border)
   ; Scale              Number that specifies the maximum intensity of center color that gets blended with 
   ;                    the boundary color.
   ;                    Values:  1.0 (100 %) - 0.0 (0 %)
   Return DllCall("Gdiplus.dll\GdipSetPathGradientSigmaBlend", "Ptr", pBrush, "Float", Focus, "Float", Scale)
}
; ----------------------------------------------------------------------------------------------------------------------
Gdip_PathGradientSetLinearBlend(pBrush, Focus, Scale = 1) {
   ; Sets the blend shape of this path gradient brush to triangular shape.
   ; pBrush             Brush object returned from Gdip_PathGradientCreateFromPath()
   ; Focus              Number that specifies where the center color will be at its highest intensity.
   ;                    Values: 1.0 (center) - 0.0 (border)
   ; Scale              Number that specifies the maximum intensity of center color that gets blended with 
   ;                    the boundary color.
   ;                    Values:  1.0 (100 %) - 0.0 (0 %)
   Return DllCall("Gdiplus.dll\GdipSetPathGradientLinearBlend", "Ptr", pBrush, "Float", Focus, "Float", Scale)
}
; ----------------------------------------------------------------------------------------------------------------------
Gdip_PathGradientSetFocusScales(pBrush, xScale, yScale) {
   ; Sets the focus scales of this path gradient brush.
   ; pBrush             Brush object returned from Gdip_PathGradientCreateFromPath().
   ; xScale             Number that specifies the x focus scale.
   ;                    Values: 0.0 (0 %) - 1.0 (100 %)
   ; yScale             Number that specifies the y focus scale.
   ;                    Values: 0.0 (0 %) - 1.0 (100 %)
   Return DllCall("Gdiplus.dll\GdipSetPathGradientFocusScales", "Ptr", pBrush, "Float", xScale, "Float", yScale)
}

