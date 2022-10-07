#SingleInstance force
#NoEnv

help=
(
● on click = show full date and stop alarm
● on double click = set in saved position
● start alarm - click on small date or open options in the right click context menu
click or double click on ListBox items: double click = alarm with dialog even if it's turned off in Settings
● double click on tray icon = go to settings - Periodic alarm, alarm on specific date

● more options in the right click context menu:   
   GUI color, transparency
   save position for next launch
   small date on/off Full hour flash on/off 
   Regulate alarm loudness on/off , set alarm loudness
● F4 - show GUI , or click on tray icon
● shows missed date alarm, if computer was off or in sleep mode at the time set (on the same day)



)


ico:=RegExMatch(A_OSVersion,"WIN_VISTA|WIN_7") ? 21: 17 
Menu, Tray, Icon, wmploc.dll , %ico%
;Menu, Tray, Icon, wmploc.dll, 21 ; Win Vista
;Menu, Tray, Icon, wmploc.dll, 17 ; Win8

Menu, Tray, NoStandard
Menu, Tray, Add, Window Spy, WindowSpy 
Menu, Tray, Add
Menu, Tray, Add, Periodic alarm settings , alarm_settings
Menu, Tray, Add,
Menu, Tray, Add, Set in saved position , GoToSavedPos
Menu, Tray, Add, Open settings file , Open_ini
Menu, Tray, Icon, Open settings file , Shell32.dll, 70
Menu, Tray, Add,
Menu, Tray, Add, Edit in Scite, Edit_Scite
Menu, Tray, Add, Edit in Notepad, Edit_Notepad
Menu, Tray, Add,
Menu, Tray, Add, Reload , Reload
Menu, Tray, Add, Exit , Exit 
;Menu, Tray, Default, Set in saved position  ; double click tray icon 
Menu, Tray, Default, Periodic alarm settings ; double click tray icon 

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
Menu, Submenu2, Add, Periodic timer on/off   , Periodic_timer_on 
Menu, Submenu2, Check, Periodic timer on/off  ; , wmploc.dll , %ico%
Menu, Submenu2, Add
Menu, Submenu2, Add, Regulate loudness on/off  , Regulate_loudness
Menu, Submenu2, Check, Regulate loudness on/off  

Menu, Submenu2, Add, Alarm loudness  , set_alarm_loudness
Menu, Submenu2, Icon, Alarm loudness  , SndVol.exe
Menu, Submenu2, Add
Menu, Submenu2, Add, Open settings file , Open_ini
Menu, Submenu2, Icon, Open settings file, Shell32.dll, 70
Menu, Submenu2, Add
Menu, Submenu2, Add, Temp routine , temp_routine
Menu, ContextMenu, Add, more, :Submenu2 

Menu, ContextMenu, Add,
Menu, ContextMenu, Add, Periodic alarm settings , alarm_settings
Menu, ContextMenu, Icon, Periodic alarm settings  , wmploc.dll , %ico%
Menu, ContextMenu, Add,
Menu, ContextMenu, Add, Help , show_help
Menu, ContextMenu, Icon, Help , shell32.dll, 24
;Menu, ContextMenu, Add,
;Menu, ContextMenu, Add, Open settings file , Open_ini
;Menu, ContextMenu, Icon, Open settings file, Shell32.dll, 70
Menu, ContextMenu, Add,
Menu, ContextMenu, Add, Restart, Reload
Menu, ContextMenu, Add, Exit, Exit
Menu, ContextMenu, Icon, Exit, Shell32.dll, 132

SetBatchLines, -1




 If !pToken := Gdip_Startup(){
	MsgBox, No Gdiplus 
	ExitApp
}

OnExit, Exit

FileEncoding, UTF-8
SetWorkingDir %A_ScriptDir%

;-----------
	;rim:=0xff444444 ; black
	rim:="" ; default
	;bgrd:="0x99120F00" 
	bgrd:="" ; default
;-----------		
	small_date:=1, full_hour_flash:=1 
	
	alarm_timer_on:=1
	numberOfalarms:=16
	numberOfDatealarms:=10
	alarm_loudness:=20 
	regulate_loudness:=1 ; for longer music
	
	PCspeaker:=1 ; 1: double , 2: short  - timer 
	timesBlink_max:= 3  ; alarm blink ; 6 ~ 1 min
	shortDialogtime:= 15 ; sec
;-----------	
	sounds_folder:=A_WinDir "\Media\"  ; "F:\1.Music\alarm\"
	;alarm_sound0:=sounds_folder "Hendrix-Watchtower.mp3" 
	alarm_sound0:=A_WinDir "\Media\Alarm03.wav" 

	;alarm_file:= A_WinDir "\Media\notify.wav"
	Cuckoo:=sounds_folder "Cuckoo.wav"
	alarm_files:=["notify.wav","chimes.wav","Alarm02.wav","Alarm03.wav","Alarm06.wav","Alarm09.wav"]
;-----------
	show_date:=0, show_date2:=0, alarm_on:=0
	week_days:=["Mon","Tue","Wed","Thu","Fri","Sat","Sun"]

	textToSpeech:="text-to-speech.ahk"
	RuntextToSpeech:=1
;===========

SysGet, MonitorWorkArea, MonitorWorkArea, 1
pos_x:=A_ScreenWidth - 140
;pos_y:= MonitorWorkAreaBottom -830 ;870
pos_y:= 20 
settings_ini := "Drozd alarm clock.ini"

IfNotExist, %settings_ini%
{
	first_run:=1	
}

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
	
IniRead, x_, %settings_ini%, Misc , alarm timer on
	if(x_!="ERROR" && x_!=""){
			alarm_timer_on:=x_
			Menu, Submenu2, % (alarm_timer_on=1) ? "Check" : "UnCheck"  , Periodic timer on/off
	}else{
		IniWrite, 1 , %settings_ini%, Misc , alarm timer on
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
	if FileExist(x_){
		alarm_sound0:=x_			
	}else{
		if FileExist(alarm_sound0)
			IniWrite, %alarm_sound0% , %settings_ini%, Misc , alarm sound
	}		
	
IniRead, x_, %settings_ini%, Misc , sounds folder
	if FileExist(x_){
		sounds_folder:=x_			
	}else{
		if FileExist(sounds_folder)
			IniWrite, %sounds_folder% , %settings_ini%, Misc , sounds folder
	}	
	
IniRead, x_, %settings_ini%, Misc , Timer alarm dialog
	if(x_!="ERROR" && x_!=""){
		show_alarm_dialog:=x_			
	}else{
		IniWrite, 0 , %settings_ini%, Misc , Timer alarm dialog
		show_alarm_dialog:=0
	}		


IniRead, x_, %settings_ini%, Misc , Text To Speech
	if(x_!="ERROR" && x_!=""){
		RuntextToSpeech:=x_			
	}else{
		IniWrite, 0 , %settings_ini%, Misc , Text To Speech
		RuntextToSpeech:=0
	}
	
	if !FileExist(textToSpeech)
		RuntextToSpeech:=0
	
	
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

		if(first_run)
			Gosub, alarm_settings
		
	Gosub, alarm_dialog_
	Gosub, get_alarm_list
	SetTimer,time_date, 500
	SetTimer,time, 1000
	
	SetTimer,clear_memory, % 4*60*60*1000
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
	MouseGetPos,x,y,Win_id,

	if(A_Gui=4)
		return
	
	if (A_Gui=1){
		PostMessage, 0xA1, 2    ; movable borderless window 
		
		if(alarm_on)
			Gosub, alarm_off

		global show_date,show_date2, angleM,angleH,rim,GuiHwnd,bgrd
			show_date:=1,show_date2:=1
			;sleep 100
			Gdip_draw_Win(GuiHwnd,angleM,angleH,rim,bgrd)
			SetTimer, after_show_date2, -6000
			Gosub, GuiSize
	}
	
 	if (A_Gui=2 || A_Gui=3 ){		
		PostMessage, 0xA1, 2    ; movable borderless window 	
	}
	
	if (A_Gui=3){
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
	if (A_Gui=1){
		Gosub, GoToSavedPos	
	}

	if(A_Gui=4){
		GuiControlGet, test_,4: , %A_GuiControl%
		RegExMatch(A_GuiControl,"i)[^\d]+", out)
		if(out=="Sound" || out=="DateSound"  || out=="SoundTimer"){		
			;play_music(test_)  
			SoundPlay, %test_% ;test_play
		}else if(out=="hora" || out=="Datehora"){			
			GuiControl,4:,  %A_GuiControl% , %A_Hour%
		}else if(out=="min" || out=="Datemin"){
			GuiControl,4:,  %A_GuiControl% , % (A_Min<59) ? A_Min + 1 : 00
		}else	if(out=="sec" || out=="Datesec"){
			;GuiControl,4:,  %A_GuiControl% , % (A_Sec<29) ? A_Sec + 30 : A_Sec -30
		}
	}
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
	;SetBatchLines, -1
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
	Gdip_DeletePath(pPath2)	
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
			;pPen:=Gdip_CreatePen(0xFF000000, 1)
			;Gdip_DrawEllipse(G, pPen, midX-r2/2, midY-r2/2, r2,r2)
			Gdip_DeletePath(pPath)
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
			Gdip_DeletePath(pPath)			
		}		
	}
	
	;FormatTime, hh,, HH
	;Gdip_TextToG(G, hh ":00", colorT:=0xffB60000,midX-37, midY-15, 25, 96, 34)
	
	UpdateLayeredWindow(hwnd, hdc)
	
	Gdip_DeleteBrush(pBrush),Gdip_DeleteBrush(pBrush2), Gdip_DeleteBrush(pBrushW)
	Gdip_DeletePen(pPen),Gdip_DeletePen(pPen2), Gdip_DeletePath(pPath), Gdip_DeletePath(pPath2)	
	SelectObject(hdc, obm), DeleteObject(hbm), DeleteDC(hdc), Gdip_DeleteGraphics(G)
	Gdip_DeleteGraphics(G2) 
	
	;SetBatchLines, 10ms
	return, 0
}


Gdip_animate(ByRef hwnd,color:=0x65120F00,r1:=0,r2:=0,r3:=0){
	global GuiW, GuiH, midX, midY	
	global pBitmap_2
	w:=GuiW , h:=GuiH
	;SetBatchLines,-1	
	
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

;==============

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
;==============	

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
	Gui,1: +OwnDialogs
	InputBox, alarm_loudness,  Alarm timer, Alarm loudness: 0-100, , 160, 120,,, , , %alarm_loudness%
		if ErrorLevel  ;CANCEL
			return
		IniWrite, %alarm_loudness%	, %settings_ini%, Misc ,alarm loudness
return

;==============	

Periodic_timer_on:
	if(alarm_timer_on==1){
		alarm_timer_on:=0
		IniWrite, 0 , %settings_ini%, Misc ,alarm timer on
		MsgBox,,, %  "Periodic timer is off" , 2
		Menu, Submenu2, UnCheck, Periodic timer on/off
	}else{
		alarm_timer_on:=1
		IniWrite, 1 , %settings_ini%, Misc ,alarm timer on
		MsgBox,,, %  "Periodic timer is on" , 2
		Menu, Submenu2, Check, Periodic timer on/off
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

	;color_flash:= pom	;viol ;red 
	color_flash:=red
	flash_grad:=1
	flash_on:=1	
	SetTimer,flash, 10
return

flash:
;SetBatchLines, -1
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
			;SetBatchLines, 10ms	
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
	;Gosub, beep 
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
;SetBatchLines, -1
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
			;SetBatchLines, 10ms		
			;Menu, Tray, Tip , %tray_tip%
			Menu, Tray, Tip , %tray_tip%`nblink %timesBlink% x ;times
		}
		
}

if(timesBlink>timesBlink_max){  ;  6 timesBlink ~= 1 min
		Gosub, alarm_off
		Gui,3: Destroy
		;SetBatchLines, 10ms			
		;SoundPlay, *64 
		Menu, Tray, Tip , %tray_tip%
		;Menu, Tray, Tip , %tray_tip%`nblink %timesBlink% times
} 
	
return



;==================================



time:
	;SetBatchLines, -1
	
	FormatTime, h,, HH
	FormatTime, m,, mm
	FormatTime, s,, ss
  FormatTime, weekD,, ddd
	;ToolTip, %  h ":" m ":" s "`n" 

	;if(m!=old_min || Mod(s,5)==0){	
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


	;if(s=0){
	if(m=0 && s=0){		
		if(!alarm_on && full_hour_flash){
			SoundBeep, 2000, 40
			Gosub start_flash
			
		}
		
/* 		SoundGet, loudness_start
		;SoundSet, %alarm_loudness%		
		if(regulate_loudness)
			SoundSet, %alarm_loudness%	
		 */
		if(h=12){
			SoundPlay, %Cuckoo% 
		}
		
/* 		if(regulate_loudness && loudness_start)
			SoundSet, %loudness_start%
		 */
	}
	 
return

;=====================

time_date:
	FormatTime, h,, HH
	FormatTime, m,, mm
	FormatTime, s,, ss
	
if(alarm_timer_on=1){
	
Loop, %numberOfalarms% {
	if(alarms_Object[A_Index].on==1){
		if(alarms_Object[A_Index][weekD]==1){
			if(alarms_Object[A_Index].hour==h && alarms_Object[A_Index].minute==m){
				if((alarms_Object[A_Index].second==s || alarms_Object[A_Index].second==s-1) && (A_TickCount - alarms_Object[A_Index].run >3000)){
						alarms_Object[A_Index].run:=A_TickCount
						if(alarm_on)
							Gosub, alarm_off_2
						alarm_on:=1
						alarm_time:=alarms_Object[A_Index].hour ":" alarms_Object[A_Index].minute ":" alarms_Object[A_Index].second ;h ":" m ":" s
						
						if(alarms_Object[A_Index].PC_speaker==1){
							beep_long() 
						}else if(alarms_Object[A_Index].PC_speaker==2){
							beep_short()
						}

						if(alarms_Object[A_Index].Message){
							alarm_text:= alarms_Object[A_Index].name 							
								if(alarms_Object[A_Index].Message=2)
									short:=1							
							Gosub, alarm_dialog_show
						}else{							
							timesBlink:=0
							Gosub, start_blink
							SetTimer, repeat_alarm, 10000
							SetTimer, alarm_off, -30000							
						}
						
						last_sound:=alarms_Object[A_Index].sound
						SoundGet, loudness_start	
						play_music()
						;SoundSet, %alarm_loudness%
						;SoundPlay, %last_sound%
						

						if(RuntextToSpeech && alarm_text!="")
							Run, %textToSpeech% " Periodic alarm. %alarm_text%" "-3" "100"
						
						tray_tip:="Alarm on " alarm_time "`n" alarms_Object[A_Index].name 	
						Menu, Tray, Tip , %tray_tip%
					}
					
			}
		}
	}
}

;==== every hour =====

	if(alarms_Object[0].on==1){
			if(alarms_Object[0].minute==m){
				if((alarms_Object[0].second==s || alarms_Object[0].second==s-1) && (A_TickCount - alarms_Object[0].run >3000)){
						alarms_Object[0].run:=A_TickCount	
						if(alarm_on)
							Gosub, alarm_off_2
					alarm_on:=1
					
					if(alarms_Object[0].PC_speaker==1){
						beep_short() ;beep_long() 
					}else if(alarms_Object[0].PC_speaker==2){
						beep_short_1()
					}

					last_sound:=alarms_Object[0].sound
					SoundGet, loudness_start	
					;play_music()
					;SoundSet, %alarm_loudness%
					
					
					;Gosub, start_flash
					;Gosub, start_blink	
					
					
					alarm_text:= alarms_Object[A_Index].name
					;if(alarms_Object[0].Message){
					if(RegExMatch(alarm_text,"\w+")){	
						;alarm_text:= alarms_Object[A_Index].name
						short:=1 						
						Gosub, alarm_dialog_show
						play_music()
					}else{
						SoundPlay, %last_sound%
						;timesBlink:=0
						;Gosub, start_blink
						;SetTimer, loudness_back,-10000
						;SetTimer, alarm_off, -10000
					}
					
	
					
						if(RuntextToSpeech && alarm_text!="")
							Run, %textToSpeech% " %alarm_text%" "-3" "100"					
					
						tray_tip:= alarms_Object[A_Index].name " " alarm_time "`n" 
						Menu, Tray, Tip , %tray_tip%
				}
			}
	}
;==== 


;==== date

	FormatTime, year,, yyyy
  FormatTime, month,, MM
  FormatTime, day,, d

Loop, %numberOfDatealarms% {	
	if(dates_alarms_Obj[A_Index].on==1){
		if(dates_alarms_Obj[A_Index].year==year && dates_alarms_Obj[A_Index].month==month && dates_alarms_Obj[A_Index].day==day){
				;MsgBox,,, % dates_alarms_Obj[A_Index].name "`nweekD: " weekD " = " dates_alarms_Obj[A_Index][weekD]
					;MsgBox,,, %  dates_alarms_Obj[A_Index].hour "`n" H
					;ToolTip, %  h ":" m ":" s "`n" dates_alarms_Obj[A_Index].name
			;if(dates_alarms_Obj[A_Index].run=0)
			if(dates_alarms_Obj[A_Index].hour==h && dates_alarms_Obj[A_Index].minute==m ){	;|| dates_alarms_Obj[A_Index].run!=1
				;if((dates_alarms_Obj[A_Index].second==s || dates_alarms_Obj[A_Index].second==s-1) && (A_TickCount - dates_alarms_Obj[A_Index].run>3000)){
				if((dates_alarms_Obj[A_Index].second==s || dates_alarms_Obj[A_Index].second==s-1) && dates_alarms_Obj[A_Index].run!=1){	
					dates_alarms_Obj[A_Index].run:=1
					IniWrite, 1, %settings_ini%, Date alarm%A_Index%, Run
					dates_alarms_Obj[A_Index].on:=0
					IniWrite, 0, %settings_ini%, Date alarm%A_Index%, alarm on
					
							dates_alarms_Obj[A_Index].run:=A_TickCount
							alarm_time:=day "/" month  "  " dates_alarms_Obj[A_Index].hour ":" dates_alarms_Obj[A_Index].minute 
									if(alarm_on)
										Gosub, alarm_off_2	
								alarm_on:=1
								
								if(dates_alarms_Obj[A_Index].PC_speaker==1){
									beep_long() 
								}else if(dates_alarms_Obj[A_Index].PC_speaker==2){
									beep_short()
								}					

								;alarm_time:=day "/" month  "  " h ":" m ;":" s
								alarm_text:= dates_alarms_Obj[A_Index].name 
								if(dates_alarms_Obj[A_Index].Message){
									;alarm_text:= dates_alarms_Obj[A_Index].name 							
											;if(alarm_text=="")									
									Gosub, alarm_dialog_show
								}else{
									alarm_on:=1
									timesBlink:=0
									Gosub, start_blink
									SetTimer, repeat_alarm, 10000
								}
								
								last_sound:=dates_alarms_Obj[A_Index].sound
								SoundGet, loudness_start	
								play_music()
								;SoundSet, %alarm_loudness%
								;SoundPlay, %last_sound%

								if(RuntextToSpeech && alarm_text!=""){
									FormatTime, date_, % dates_alarms_Obj[A_Index].Date, dddd. MMMM dd.																		
									date_speak:= " Date alarm. " alarm_text ". " date_  ;" " dates_alarms_Obj[A_Index].hour ":" dates_alarms_Obj[A_Index].minute  "."										
									Run, %textToSpeech% "%date_speak%" "-3" "100"
								}
								
								tray_tip:="Date alarm on " date_ "`n" alarm_time "`n" dates_alarms_Obj[A_Index].name 	
								Menu, Tray, Tip , %tray_tip%	
				}
			}else if(dates_alarms_Obj[A_Index].hour<h || (dates_alarms_Obj[A_Index].hour=h && dates_alarms_Obj[A_Index].minute<m)){ ;same day not run 
				if(dates_alarms_Obj[A_Index].run!=1){
					dates_alarms_Obj[A_Index].run:=1
					IniWrite, 1, %settings_ini%, Date alarm%A_Index%, Run
					dates_alarms_Obj[A_Index].on:=0
					IniWrite, 0, %settings_ini%, Date alarm%A_Index%, alarm on
					
					alarm_time:=day "/" month  "  " dates_alarms_Obj[A_Index].hour ":" dates_alarms_Obj[A_Index].minute
									if(alarm_on)
										Gosub, alarm_off_2	
								alarm_on:=1
								
								if(dates_alarms_Obj[A_Index].PC_speaker==1){
									beep_long() 
								}else if(dates_alarms_Obj[A_Index].PC_speaker==2){
									beep_short()
								}					

								;alarm_time:=day "/" month  "  " h ":" m ;":" s
								alarm_text:= "missed " dates_alarms_Obj[A_Index].name 
								alarm_text2:= dates_alarms_Obj[A_Index].name
								if(dates_alarms_Obj[A_Index].Message){
									;alarm_text:= dates_alarms_Obj[A_Index].name 							
											;if(alarm_text=="")									
									Gosub, alarm_dialog_show
								}else{
									alarm_on:=1
									timesBlink:=0
									Gosub, start_blink
									SetTimer, repeat_alarm, 10000
								}
								
								last_sound:=dates_alarms_Obj[A_Index].sound
								SoundGet, loudness_start	
								play_music()
								;SoundSet, %alarm_loudness%
								;SoundPlay, %last_sound%

								if(RuntextToSpeech && alarm_text!=""){
									FormatTime, date_, % dates_alarms_Obj[A_Index].Date, dddd. MMMM dd.																		
									date_speak:= " Missed alarm. " dates_alarms_Obj[A_Index].name  ". " date_  " " dates_alarms_Obj[A_Index].hour ":" dates_alarms_Obj[A_Index].minute "."										
									Run, %textToSpeech% "%date_speak%" "-3" "100"
								}		
								
								tray_tip:="missed alarm on " date_ "`n" alarm_time "`n" dates_alarms_Obj[A_Index].name "`n"	 tray_tip
								Menu, Tray, Tip , %tray_tip%	
				}		
			}
		}
	}
}

}
;alarms_Object:=[1:{"on":1,"name":"","hour":18,"minute":30,"second":00,"sound":"","PC_speaker":2,"Mon":1,"Tue":1,...}] 
;dates_alarms_Obj:=[1:{"on":1,"name":"","hour":18,"minute":30,"second":00,"sound":"","PC_speaker":2,"year":2017,"month":01,"day": 15}] 
	;SetBatchLines, 10ms	
return




get_alarm_list:
alarms_Object := Object() 

Loop, %numberOfalarms% {
	alarms_Object[A_Index]:= Object() 

	IniRead, x, %settings_ini%, alarm%A_Index%, alarm on , %A_Space%
	alarms_Object[A_Index].on:=x 
	IniRead, x , %settings_ini%, alarm%A_Index%, Name , %A_Space%
	alarms_Object[A_Index].name:=x

	IniRead, x , %settings_ini%, alarm%A_Index%, Hour , %A_Space%
	alarms_Object[A_Index].hour:=x
	IniRead, x, %settings_ini%, alarm%A_Index%, Minute , %A_Space%
	alarms_Object[A_Index].minute:=x
	IniRead, x , %settings_ini%, alarm%A_Index%, Second , %A_Space%
	alarms_Object[A_Index].second:=x
	
	
	IniRead, x , %settings_ini%, alarm%A_Index%, Message , %A_Space%
	alarms_Object[A_Index].Message:=x	
	
	IniRead, x , %settings_ini%, alarm%A_Index%, Sound file , %A_Space%
	alarms_Object[A_Index].sound:=x
	
	IniRead, x , %settings_ini%, alarm%A_Index%, PC speaker , %A_Space%
	alarms_Object[A_Index].PC_speaker:=x

		Name=A%A_Index%
		num=%A_Index%
		Loop, 7 {
			var=%Name%Day%A_Index%    
			day:=week_days[A_Index]
			IniRead, x , %settings_ini%, alarm%num%, %day% , %A_Space%
			alarms_Object[num][day]:=x
		}
	
	alarms_Object[A_Index].run:=0	
}

;==== every hour =====
	alarms_Object[0]:= Object() 
	IniRead, x, %settings_ini%, alarm0, alarm on , %A_Space%
	alarms_Object[0].on:=x 
	IniRead, x , %settings_ini%, alarm0, Name , %A_Space%
	alarms_Object[0].name:=x
	;IniRead, x , %settings_ini%, alarm0, Hour
	;alarms_Object[0].hour:=x
	IniRead, x, %settings_ini%, alarm0, Minute , %A_Space%
	alarms_Object[0].minute:=x
	IniRead, x , %settings_ini%,alarm0, Second , %A_Space%
	alarms_Object[0].second:=x
	
	IniRead, x , %settings_ini%, alarm0, Message , %A_Space%
	alarms_Object[0].Message:=x	
	
	IniRead, x , %settings_ini%, alarm0, Sound file , %A_Space%
	alarms_Object[0].sound:=x	
	IniRead, x , %settings_ini%, alarm0, PC speaker , %A_Space%
	alarms_Object[0].PC_speaker:=x
	
	alarms_Object[0].run:=0


;==== dates

dates_alarms_Obj := Object() 

Loop, %numberOfDatealarms% {
	dates_alarms_Obj[A_Index]:= Object() 

	IniRead, x, %settings_ini%, Date alarm%A_Index%, alarm on , %A_Space%
	dates_alarms_Obj[A_Index].on:=x 
	IniRead, x, %settings_ini%, Date alarm%A_Index%, Name , %A_Space%
	dates_alarms_Obj[A_Index].name:=x

	IniRead, x, %settings_ini%, Date alarm%A_Index%, Hour , %A_Space%
	dates_alarms_Obj[A_Index].hour:=x
	IniRead, x, %settings_ini%, Date alarm%A_Index%, Minute , %A_Space%
	dates_alarms_Obj[A_Index].minute:=x
	IniRead, x, %settings_ini%, Date alarm%A_Index%, Second , %A_Space%
	dates_alarms_Obj[A_Index].second:=x
	
	IniRead, x, %settings_ini%, Date alarm%A_Index%, Date , %A_Space%
	;dates_alarms_Obj[A_Index].second:=x	
	RegExMatch(x,"^(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})", d)
   ;year:=d1, month:=d2, day:=d3
	 dates_alarms_Obj[A_Index].year:=d1
	 dates_alarms_Obj[A_Index].month:=d2, 
	 dates_alarms_Obj[A_Index].day:=d3, 
	
	IniRead, x, %settings_ini%, Date alarm%A_Index%, Message , %A_Space%
	dates_alarms_Obj[A_Index].Message:=x	
	
	IniRead, x, %settings_ini%, Date alarm%A_Index%, Sound file , %A_Space%
	dates_alarms_Obj[A_Index].sound:=x
	
	IniRead, x, %settings_ini%, Date alarm%A_Index%, PC speaker , %A_Space%
	dates_alarms_Obj[A_Index].PC_speaker:=x
	 
	dates_alarms_Obj[A_Index].run:=0
}
return



;==================================		

show_alarm_list:
	Gui,6:+Owner1 
  Gui,6: +ToolWindow -Caption +AlwaysOnTop	+HwndGuiListHwnd 
  Gui,6:Font, S7 w800 CDefault , Segoe UI 
  Gui,6: Margin, 1,1
  ;Gui,6: Add, ListBox, w30 r8 vListBox_1 gListBox, 1m|2m|3m|5m|10m|15m|30m|Input||
	Gui,6: Add, ListBox, w30 r8 vListBox_1 vListBox_1  +HWNDListBox_id, 1m|5m|7m|10m|15m|20m|30m|Input|| ;2m|3m
  fn := Func("ListBox_Func_1").Bind(ListBox_id)
	GuiControl, +g, % ListBox_id, % fn
	
  Gui,6:Color, 900000 ;120F00 	
	
	WinGetPos, x1,y1,,, ahk_id %GuiHwnd%
	x2:=x1+52,y2:=y1+20
	Gui,6:Show, x%x2% y%y2% , alarm_list_Drozd
return

ListBox_Func_1(hwnd){ 
  global lastEvent, lastListBox, last_Win_id
	GuiControlGet, list_folder_expl,6: , % hwnd
  lastEvent:=A_GuiEvent
	lastListBox:=list_folder_expl

  SetTimer, ListBox_Clicks, % DllCall("GetDoubleClickTime")
}

ListBox_Clicks:
SetTimer, ListBox_Clicks, Off
	if(lastEvent="DoubleClick"){
		Gui,6:Submit, Nohide
		show_alarm_dialog:=1
		Gosub, ListBox
	}else if(lastEvent="Normal"){    
		Gosub, ListBox    
  }
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
		TIME_min:= min_input
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
		
	TIME_min:=min_input
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
	Gui,2: Hide  ;Gui,2: Destroy
	;Menu, Tray, Tip ,
	alarm_on:=1
	SoundGet, loudness_start	
	;if(regulate_loudness)
		;SoundSet, %alarm_loudness%
	;Msgbox,,, Clock timer`n%TIME_min% min ,30 
	if(show_alarm_dialog=1){
		alarm_time:= TIME_min " min"
		alarm_text:= "Clock Timer"
		Gosub, alarm_dialog_show
	}else if(show_alarm_dialog=2){
		MsgBox, 4356,Clock timer`n%TIME_min% min  , Turn off alarm?, 30
        IfMsgBox, Yes
          Gosub, alarm_off	
	}
	IniRead, x_, %settings_ini%, Misc , Timer alarm dialog  ; for double click start
		show_alarm_dialog:=x_
		
	alarm_sound2=C:\WINDOWS\Media\chimes.wav
	alarm_sound=C:\WINDOWS\Media\notify.wav
	alarm_sound:=alarm_sound0
	;SoundPlay, %alarm_sound%
	play_music(alarm_sound)
	last_sound:=alarm_sound
	
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
	
	alarm_text=%TIME_min% minutes passed.
	if(RuntextToSpeech && alarm_text!="")
		Run, %textToSpeech% " Timer. %alarm_text%" "-3" "100"
return
			

repeat_alarm:
	Gosub, start_blink
return

alarm_off:
	alarm_on:=0
	short_close:=0, short:=0
	SetTimer, alarm_off, Off
	SetTimer, blink, Off
	SetTimer, repeat_alarm, Off	
	SetTimer, close_dialog, Off
	SetTimer, loudness_back, Off
	Gdip_draw_Win(GuiHwnd,angleM,angleH,rim,bgrd)
	if(regulate_loudness){
		play_music_Off()
	}else
		SoundPlay, nic
	;if(regulate_loudness && loudness_start)
		;SoundSet, %loudness_start%
	;SoundPlay, nic
return

alarm_off_2:
	;alarm_on:=0
	short_close:=0
	Gui,2: Hide  ;Gui,2: Destroy
	SetTimer, alarm_off, Off
	SetTimer, blink, Off
	SetTimer, repeat_alarm, Off
	SetTimer, close_dialog, Off
	SetTimer, loudness_back, Off
	Gdip_draw_Win(GuiHwnd,angleM,angleH,rim,bgrd)
	SoundPlay, nic
	if(regulate_loudness && loudness_start)
		SoundSet, %loudness_start%
return

show_time:
	Gui,3: Destroy
	WinGetPos, x1,y1,,, ahk_id %GuiHwnd%
	x2:=x1+42,y2:=y1+134
  Gui,3: +ToolWindow -Caption +AlwaysOnTop	 
	Gui,3: +Owner1  
  Gui,3:Color, 120F00 
  Gui,3: Font, S8 W700 , Tahoma 
  Gui,3: Add, Text , x0 y2 w53  cFFFFFF vShow_timer Center, 
  Gui,3: Font, S6 cD0D0D0
	Gui,3:Show,  x%x2% y%y2%  w52 h18 	  NA, Drozd_show_timer
  Winset, Transparent,200, Drozd_show_timer
  OnMessage(0x201, "WM_LBUTTONDOWN") ; movable borderless window   
return

	
;======================

alarm_dialog_show:
	;Gui,2: Hide  ;Gui,2: Destroy
	;DllCall( "AnimateWindow", "Int", D_Hwnd, "Int", 300, "Int", 0x00010010 ) ; hide grow
	DllCall( "AnimateWindow", "Int", D_Hwnd, "Int", 200, "Int", 0x00010008 ) ; hide sweep
  start_msg_timer:=0
  ;SoundGet, loudness_start
  SetTimer, flash_, 1000
	SetTimer, beep, 10000
	SetTimer, beep_Off, -60000
	SetTimer, time_, 1000 
	SetTimer, close_dialog, Off
	
	GuiControl,2:, Show_alarm, %alarm_text%
	GuiControl,2:, alarm_time, %alarm_time%
	;Gui,2:Show
	
	DetectHiddenWindows, On
  if(short){
    SysGet, MonitorWorkArea, MonitorWorkArea, 1
    al_x:=A_ScreenWidth -160
    al_y:= MonitorWorkAreaBottom - 270
    short:=0
    ;Gui,2:Show, x%al_x% y%al_y% w150 h150  NA, Show_alarm_Drozd
		WinMove, ahk_id %D_Hwnd%,,al_x,al_y
		;DllCall( "AnimateWindow", "Int", D_Hwnd, "Int", 200, "Int", 0x00000010 )
		DllCall( "AnimateWindow", "Int", D_Hwnd, "Int", 300, "Int", 0x00000002 ) ; slide
		short_close:=1
		if(alarm_text=="Weather"){
			SetTimer, close_dialog, -5000
		}else{
			SetTimer, close_dialog, % -1000*shortDialogtime   ;-17000
		}
		SetTimer, alarm_off, Off ;-17000
		
	}else{
		short_close:=0
		WinMove, ahk_id %D_Hwnd%,,% (A_ScreenWidth-D_w)/2, % (A_ScreenHeight-D_h)/2, ;D_w, D_h
		;Gui,2:Show
		DllCall( "AnimateWindow", "Int", D_Hwnd, "Int", 400, "Int", 0x00000010 )
	}
	Winset, Transparent,200, Show_alarm_Drozd  
	DetectHiddenWindows, Off
return

alarm_dialog_:
	alarm_text_col:="F7EFBA"
	alarm_time_col:="F1F1F1"
	alarm_text_col_fl:="FFFFFF"
	
	D_w:=D_h:=150
	;alarm_text_col:="FFFFFF"
	;alarm_time_col:="F7EFBA"
	
  Gui,2: +ToolWindow -border +AlwaysOnTop	 +HwndD_Hwnd  
  Gui,2:Color, 120F00 
  Gui,2: Font, S8 W700 , Tahoma 
  Gui,2: Add, Text , x43 y6 w60 c%alarm_time_col% vmsg_timer Center , 
  Gui,2:Add,Groupbox,cD0D0D0 x18 y24 w117 h96 vramka
  Gui,2: Font, S11 W700 , Comic Sans MS  
  Gui,2: Add, Text , x55 y37   c%alarm_text_col_fl% vtitle Center gplay_again , Alarm
  Gui,2: Font, S11 W700 , Tahoma ;Segoe UI  Verdana
	Gui,2: Add, Text , x22 y66 w110  c%alarm_text_col% vShow_alarm Center , %alarm_text%
  Gui,2: Font, S8 W700 , Segoe UI
  Gui,2: Add, Text , x36 y100 w80  c%alarm_time_col% valarm_time Center , %alarm_time%	
  Gui,2: Font, S8 cD0D0D0
  Gui,2: Add, Text , x130 y1 w20 h20 gclose_dialog  , `   X      
  Gui,2: Font, S8 W400 cD0D0D0, Segoe UI
  ;Gui,2: Add, Text , x128 y128 w40 vt_left  ,  
  Gui,2: Add, Text , x100 y128 w20 vt_left Right ,  
  Gui,2: Add, Text , x122 y128 w20 c413700 vt_left0 , 
  Gui,2: Font, S10 W700 , Tahoma
  Gui,2: Add, Text , x68 y126 w20 cF1F1F1 gclose_dialog , OK
  ;Gui,2:Add,Groupbox,cD0D0D0 x62 y119 w28 h26
	Gui,2:Show,Hide x-3000 y-3000 w150 h150  NA, Show_alarm_Drozd
	Gui,2:Hide 
	Winset, Transparent,200, Show_alarm_Drozd   
  OnMessage(0x203,"WM_LBUTTONDBLCLK")
  OnMessage(0x201, "WM_LBUTTONDOWN") ; movable borderless window  
return


time_:
start_msg_timer+=1 
msg_timer_h := Floor(start_msg_timer/3600)
msg_timer_m := time_count>3600 ? Floor(mod(start_msg_timer,3600)/60) : Floor(start_msg_timer/60)
msg_timer_s := Floor(mod(start_msg_timer,60))
msg_timer_l:=msg_timer_h >0 ? dig(msg_timer_h) " : " dig(msg_timer_m) " : " dig(msg_timer_s)  : "`    " dig(msg_timer_m) "  :  " dig(msg_timer_s) 
GuiControl,2:, msg_timer, %msg_timer_l%
return


flash_:
    col:=!col          
  if(col){
    Gui,2: Font, S11 c%alarm_text_col_fl% W700 , Comic Sans MS
    GuiControl,2: Font, title  
  }else{
    Gui,2: Font, S11 cRed W700 , Comic Sans MS
    GuiControl,2: Font, title        
  }
return

beep:
	SoundPlay *48	
	;SoundPlay, % A_WinDir "\Media\notify.wav" ; chimes.wav
return

beep_Off:
	SetTimer, beep, Off
return

loudness_back:
	alarm_on:=0
	if(regulate_loudness)
		play_music_Off()
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
	;Run, SndVol.exe -f 57738758 
 loop, 10 {
  SoundSet, % A_Index*alarm_loudness/10
  Sleep, 100
 }
 ;WinClose, ahk_exe SndVol.exe
}

play_music_Off(){
	global alarm_loudness, loudness_start
	global alarm_on:=0
	SoundGet, start
	start:= (start) ? start : alarm_loudness
	;Run, SndVol.exe -f 57738758
	loop, 10 {
		sndLev:=(10-A_Index)*start/10
		SoundSet, % sndLev
		Sleep, 100
 } until (sndLev<5)
 ;WinClose, ahk_exe SndVol.exe
 SoundPlay, nic
 loudness_start:= (loudness_start>5) ? loudness_start : 10
 SoundSet, %loudness_start%
}

play_again:
	;play_music()
	SoundPlay, %last_sound%
	;Gui,2: -AlwaysOnTop	
return

close_dialog:
SetTimer, close_dialog, Off
2GuiClose:
if(short_close){
	DllCall( "AnimateWindow", "Int", D_Hwnd, "Int", 400, "Int", 0x00010001 ) ; hide R-L
	short_close:=0
}else
	DllCall( "AnimateWindow", "Int", D_Hwnd, "Int", 200, "Int", 0x00010008 ) ; hide sweep
	;DllCall( "AnimateWindow", "Int", D_Hwnd, "Int", 300, "Int", 0x00010010 ) ; hide grow
	;Gui,2: Hide  ;Gui,2: Destroy
	SetTimer, blink, Off
	SetTimer, repeat_alarm, Off
	SetTimer, flash_, Off
	SetTimer, time_, Off 
	Gdip_draw_Win(GuiHwnd,angleM,angleH,rim,bgrd)
	;if(regulate_loudness && loudness_start)
	;	SoundSet, %loudness_start%
	if(regulate_loudness){
		play_music_Off()
	}else
		SoundPlay, nic
	SetTimer, beep, Off
return


4GuiClose:
Gui,4: Destroy
return


;======================



beep_long(){
	SoundBeep,700
	SoundBeep,520,400 
}

beep_short(){
  SoundBeep,520,50 ; m-high
}
  
beep_short_1(){
  SoundBeep,720,20 ; high
}
  	
beep_short_2(){
  SoundBeep,400,150  ;low
}	



;======================

dig(num){ ;to_two_digits
   num:= (StrLen(num)=1) ? "0" . num : num
   return num
}


;=================================


alarm_settings:
if WinExist("Drozd alarm settings"){
	Gui,4: Show
	return
}

GuiW_4:=834 , GuiH_4:=570
SaveX:= GuiW_4/2 - 80, SaveY:= GuiH_4-40
CancelX:=GuiW_4/2 + 10, CancelY:=GuiH_4-40
;Gui,4:+Owner1 
Gui,4:+ToolWindow  

Gui,4:Color, 0B4761 ;blu 
;Gui,4:Color, 10524E  ;06615A ;0A615A

Gui,4:Margin, 0 
Gui,4:Font,  Q5, Segoe UI bold ;Tahoma
Gui,4:Add, Tab3, x2 y4 w826 h500  cF1F1F1  0x400 , ` Periodic alarm` |` On specific date` |` Every hour` | Settings

Gui,4: Tab, 
Gui,4:Add, Button , x%SaveX% y%SaveY% w60 h22  gSaveSet , Save
Gui,4:Add, Button , x%CancelX% y%CancelY% w60 h22  gCancel_but , Cancel


Gui,4: Font, S12 cF1F1F1 Q5, Segoe UI Bold ;
;Gui,4:Add, Text, x340  y10   , Periodic alarm

Gui,4: Tab, 1

	Gui,4: Font, S7 cF1F1F1 Q5
	Gui,4:Add, Text,  x42 y50 , Name:
	Gui,4: Font, S7 Q5
	Gui,4:Add, Text,  x7 y50 , Enable
	Gui,4:Add, Text,  x156 y50 , Hour
	Gui,4:Add, Text,  x188 y50 , Min.
	Gui,4:Add, Text,  x218 y50 , Sec.

	Gui,4:Add, Text,  x272 y50 , Mon
	Gui,4:Add, Text,  x+9 y50 , Tue 
	Gui,4:Add, Text,  x+10 y50 , Wed
	Gui,4:Add, Text,  x+9 y50 , Thu
	Gui,4:Add, Text,  x+13 y50 , Fri
	Gui,4:Add, Text,  x+15 y50 , Sat
	Gui,4:Add, Text,  x+12 y50 , Sun

	Gui,4:Add, Text,  x490 y50 , Sound file:

	;Gui,4:Add, Text,  x705 y50 , Msg.
	Gui,4:Add, Text,  x706 y37 , Msg. dialog
	
	Gui,4:Add, Text,  x772 y37 , PC speaker
	Gui,4: Font, S6 Q5 , Segoe UI 
	Gui,4:Add, Text,  x774 y51  , long
	Gui,4:Add, Text,  x+10 y51 , short
	
	Gui,4:Add, Text,  x711 y51  , long
	Gui,4:Add, Text,  x+6 y51 , short
 
Gui,4: Font, S8 cDefault W400 , Tahoma 


Loop, %numberOfalarms% {
	if(A_Index==1){
		Gui,4:Add, Checkbox, x12 y70 vNum%A_Index%  , 
	}else{
		Gui,4:Add, Checkbox, x12 y+14  vNum%A_Index%  , 
	}
		Gui,4:Add, Edit, x+0 y+-17 w110  vName%A_Index%, Name %A_Index%
		Gui,4:Add, Edit, x+5  w30 vhora%A_Index%, %A_Hour% 
		Gui,4:Add, Edit, x+0  w30 vmin%A_Index%, %A_Min%
		Gui,4:Add, Edit, x+0  w30 vsec%A_Index%, 00 ;%A_Sec%
		
 		Name=A%A_Index%
	Loop, 7 {	
		 var=%Name%Day%A_Index%      
	if(A_Index==1){
			Gui,4:Add, Checkbox, x+30 y+-18 w27 v%var% Checked 
		}else
			Gui,4:Add, Checkbox, x+0 w27 v%var% Checked  
	}			
}

len:=alarm_files.Length(), j:=1

Loop, %numberOfalarms% {
	if(A_Index==1){
			Gui,4:Add, Edit, x490 y66 w180 vSound%A_Index%  , % A_WinDir "\Media\" alarm_files[j] ; %alarm_file%   ;file path
			;Gui,4:Add, Checkbox, x+10 y70
			Gui,4:Add, Button, x+6 h20 w25 vFile%A_Index% gSelectFile, ..
	}else{
			Gui,4:Add, Edit, x490 y+6 w180 vSound%A_Index%  , % A_WinDir "\Media\" alarm_files[j] ;  %alarm_file%    ;file path
			Gui,4:Add, Button, x+6  h20 w25 vFile%A_Index% gSelectFile, ..
			;Gui,4:Add, Checkbox, x+10
	}
	j:=(j >= len) ? 1 : j+1
}	


 
	Loop, %numberOfalarms% {
		if(A_Index==1){
			Gui,4:Add, Checkbox, x714 y69 w24 vMsg%A_Index% Checked ,  
			Gui,4:Add, Checkbox, x+0 w24 vMsgSh%A_Index%  ,		
		}else{	
			Gui,4:Add, Checkbox, x714 y+13 w24 vMsg%A_Index% Checked ,
			Gui,4:Add, Checkbox,  x+0 w24 vMsgSh%A_Index%  ,
			
		}
	}

 Loop, %numberOfalarms% {
	if(A_Index==1){
		Gui,4:Add, Checkbox, x776 y69 vPC_l%A_Index% ,  ;PCspeaker
		Gui,4:Add, Checkbox, x+0 y69 vPC_s%A_Index% , 
	}else{	
		Gui,4:Add, Checkbox, x776 y+13 vPC_l%A_Index% 
		Gui,4:Add, Checkbox, x+0 vPC_s%A_Index% 
	}
}   


  Gui,4: Add, Text, x260 y66 w3 h410 0x5 ; Vertical Line
	Gui,4: Add, Text, x470 y66 w3 h410 0x5 ; Vertical Line
	Gui,4: Add, Text, x764 y66 w1 h410 0x5 ; Vertical Line
	
;==== every hour =====	
Gui,4: Tab, 3	

	Gui,4: Font, S12 cF1F1F1 Q5, Segoe UI Bold ;
	;Gui,4:Add, Text, x340  y10   , Periodic alarm
	Gui,4: Font, S7 cF1F1F1 Q5
	Gui,4:Add, Text,  x40 y50 , Name:
	Gui,4: Font, S7 Q5
	Gui,4:Add, Text,  x7 y50 , Enable
	;Gui,4:Add, Text,  x190 y50 , Hour
	Gui,4:Add, Text,  x225 y50 , Min.
	Gui,4:Add, Text,  x256 y50 , Sec.

	Gui,4:Add, Text,  x520 y50 , Sound file:

	Gui,4:Add, Text,  x735 y50 , Msg.

	Gui,4:Add, Text,  x772 y37 , PC speaker
	Gui,4: Font, S6 Q5 , Segoe UI 
	Gui,4:Add, Text,  x774 y51  , long
	Gui,4:Add, Text,  x+10 y51 , short
	
	
Gui,4: Font, S8 cDefault W400 , Tahoma 

	
	Gui,4:Add, Checkbox, x12 y70 w23 vNum0  , 
	Gui,4:Add, Edit, x+6 y+-17 w140  vName0, ;Every hour

	Gui,4:Add, Edit, x+10  w30 vhora0, %A_Hour% 
			GuiControl,4: Hide,hora0 
	Gui,4:Add, Edit, x+0  w30 vmin0,00 ;%A_Min%
	Gui,4:Add, Edit, x+0  w30 vsec0, 00 ; %A_Sec%
		
/*  		Name=A%0%
	Loop, 7 {
		 var=%Name%Day%A_Index%      
	if(A_Index==1){
			Gui,4:Add, Checkbox, x+33 y+-18 w27 v%var% Checked ;vDay%A_Index%
		}else
			Gui,4:Add, Checkbox, x+0 w27 v%var% Checked  ;vDay%A_Index%		
	}			
 */
	Gui,4:Add, Edit, x520 y66 w180 vSound0  , %alarm_file%
	Gui,4:Add, Button, x+6 h20 w25 vFile0 gSelectFile, ..
	
	Gui,4:Add, Checkbox, x740 y69 w24 vMsg0 Checked ,	
	Gui,4:Add, Checkbox, x776 y69 vPC_l0 ,  ;gPCspeaker
	Gui,4:Add, Checkbox, x+0 y69 vPC_s0
;==== 


;==== 
Gui,4:Tab,2

	Gui,4: Font, S7 w700 cF1F1F1 Q5, Segoe UI Bold
	Gui,4:Add, Text,  x40 y50 , Name:
	Gui,4:Add, Text,  x7 y50 , Enable
	Gui,4:Add, Text,  x193 y50 , Hour
	Gui,4:Add, Text,  x225 y50 , Min.
	Gui,4:Add, Text,  x255 y50 , Sec.

	Gui,4:Add, Text,  x520 y50 , Sound file:
	Gui,4:Add, Text,  x735 y50 , Msg.
	Gui,4:Add, Text,  x772 y37 , PC speaker
	Gui,4: Font, S6 Q5 , Segoe UI 
	Gui,4:Add, Text,  x774 y51  , long
	Gui,4:Add, Text,  x+10 y51 , short



Gui,4: Font, S8 cDefault W400 , Tahoma 

Loop, %numberOfDatealarms% {
	if(A_Index==1){
		Gui,4:Add, Checkbox, x12 y70 w23 vDateNum%A_Index%  , 
	}else{
		Gui,4:Add, Checkbox, x12 y+9 w23 vDateNum%A_Index%  , 
	}
		Gui,4:Add, Edit, x+6 y+-17 w140  vDateName%A_Index%, Date %A_Index%
		Gui,4:Add, Edit, x+10  w30 vDatehora%A_Index%, %A_Hour% 
		Gui,4:Add, Edit, x+0  w30 vDatemin%A_Index%, %A_Min%
		Gui,4:Add, Edit, x+0  w30 vDatesec%A_Index%, 00 ;%A_Sec%
}	
	
	Gui,4: Font, S8 W700

Loop, %numberOfDatealarms% {	
	if(A_Index==1){
		Gui,4:Add, DateTime, x+20 y65  w160 vDateTime%A_Index%  Choose%var% ;Range20170301, ;LongDate
	}else{
		Gui,4:Add, DateTime, y+5  w160 vDateTime%A_Index% , 
	}
}

;=== notify_texts
Gui,4: Font, S9 cD0CFCF W700 , Tahoma 

Loop, %numberOfDatealarms% {	
	if(A_Index==1){
		Gui,4:Add, Text, x+15 y68 w14 cD0CFCF Center vDateText%A_Index%, 
	}else{
		Gui,4:Add, Text, y+12 w14 cD0CFCF Center vDateText%A_Index%, 
	}
}


	Gui,4: Font, S8 cDefault W400 , Tahoma 
 len:=alarm_files.Length(), j:=1
Loop, %numberOfDatealarms% {
	
	if(A_Index==1){
			Gui,4:Add, Edit, x520 y66 w180 vDateSound%A_Index%  , % A_WinDir "\Media\" alarm_files[j] ;%alarm_file%   ;file path
			;Gui,4:Add, Checkbox, x+10 y70
			Gui,4:Add, Button, x+6 h20 w25 vDateFile%A_Index% gSelectFileDate, ..
	}else{
			Gui,4:Add, Edit, x520 y+6 w180 vDateSound%A_Index%  , % A_WinDir "\Media\" alarm_files[j]  ;%alarm_file%    ;file path
			Gui,4:Add, Button, x+6  h20 w25 vDateFile%A_Index% gSelectFileDate, ..
			;Gui,4:Add, Checkbox, x+10
	}
	;Gui,4:Add, Button, x+10 y13 h24 w30 gSelectFile, ...
	j:=(j >= len) ? 1 : j+1
}	
	
 
 Loop, %numberOfDatealarms% {
	if(A_Index==1){
		Gui,4:Add, Checkbox, x740 y69 w24 vDateMsg%A_Index% Checked ,   
	}else{	
		Gui,4:Add, Checkbox, x740 y+13 w24 vDateMsg%A_Index% Checked ,
		
	}
} 

 Loop, %numberOfDatealarms% {
	if(A_Index==1){
		Gui,4:Add, Checkbox, x776 y69 vDatePC_l%A_Index% ,  ;PCspeaker
		Gui,4:Add, Checkbox, x+0 y69 vDatePC_s%A_Index% , 
	}else{	
		Gui,4:Add, Checkbox, x776 y+13 vDatePC_l%A_Index% 
		Gui,4:Add, Checkbox, x+0 vDatePC_s%A_Index% 
	}
}   



;===== other settings

Gui,4:Tab,4
	
	Gui,4: Font, S8 cDefault W400 , Tahoma 
	Gui,4:Add, Edit, x180 y66 w180 vSoundTimer  , % A_WinDir "\Media\Alarm03.wav" ;%alarm_file%
	Gui,4:Add, Button, x+6 h20 w25  gSelectFileTimer, ..
	Gui,4:Add, Edit, x180 y+10 w180  vSoundsFolder , % A_WinDir "\Media\" 
	Gui,4:Add, Button, x+6 h20 w25  gSelectSoundsFolder, ..
	
	Gui,4: Font, S9 cF1F1F1 Q5, Segoe UI SemiBold  
	Gui,4:Add, Text,  x20 y69 , Timer alarm sound: 
	Gui,4:Add, Text,  x20 y+15 , Sounds folder: 
	
	


	Gui,4:Add, Checkbox, x440 y180 vRegulate_loudness Checked
	Gui,4:Add, Text,  x+10 vRegulate_loudnessCtrl gtextCtrl, Loudness control (gradual increase/decrease)
	Gui,4:Add, Button, x530 y230 gset_alarm_loudness, Set alarm loudness

	;Gui,4:Add, Text,  x+10, Alarm loudness:  ;set_alarm_loudness
	
	Gui,4:Add, Checkbox, x40  y180 vPeriodic_timer_on Checked
	Gui,4:Add, Text,  x+10  vPeriodic_timer_onCtrl gtextCtrl, Periodic timer on

	
	Gui,4:Add, Checkbox, x40 y+20 vShow_small_date Checked
	Gui,4:Add, Text,  x+10  vShow_small_dateCtrl gtextCtrl, Show small date
	Gui,4:Add, Checkbox, x40 y+20  vfull_hour_flash Checked   
	Gui,4:Add, Text,  x+10  vfull_hour_flashCtrl gtextCtrl, Full hour flash 
 	Gui,4:Add, Checkbox, x40 y+20  vTimerMsg Checked
	Gui,4:Add, Text,  x+10  vTimerMsgCtrl gtextCtrl, Timer alarm dialog 
	Gui,4:Add, Checkbox, x40 y+20  vTxtSpch Checked
	Gui,4:Add, Text,  x+10  vTxtSpchCtrl gtextCtrl, Text To Speech
	
	Gui,4:Tab		

	Gui, 4:Show, w%GuiW_4% h%GuiH_4%  , Drozd alarm settings
	
IfExist, %settings_ini% 
{
	IniRead, x, %settings_ini%, alarm1
	if(x!="ERROR" && x!=""){
		Gosub, Load_Settings
	}
}

return 




SelectFile:
	RegExMatch(A_GuiControl,"i)File(\d+)",out)	
	FileSelectFile, file_path, 1 , %sounds_folder% , Open, Files (*.wav; *.3gp; *.mp3; *.avi; *.wmv; *.aac; *.m4a)
	if(file_path)
		GuiControl,4:, Sound%out1%, %file_path%
return

SelectFileDate:
	RegExMatch(A_GuiControl,"i)DateFile(\d+)",out)	
	FileSelectFile, file_path, 1 , %sounds_folder% , Open, Files (*.wav; *.3gp; *.mp3; *.avi; *.wmv; *.aac; *.m4a)
	if(file_path)
		GuiControl,4:, DateSound%out1%, %file_path%
return

SelectFileTimer:
	FileSelectFile, file_path, 1 , %sounds_folder% , Open, Files (*.wav; *.3gp; *.mp3; *.avi; *.wmv; *.aac; *.m4a)
	if(file_path)
		GuiControl,4:, SoundTimer, %file_path%
return

SelectSoundsFolder:
	FileSelectFile, file_path , ,  %sounds_folder%\RootDir, Open ; "RootDir" - to open folder instead of file
	file_path:=RegExReplace(file_path,"RootDir$","")
	if(file_path)
		GuiControl,4:, SoundsFolder, %file_path%
return

textCtrl:
	RegExMatch(A_GuiControl,"i)File(\d+)",out)
	Ctrl:=RegExReplace(A_GuiControl,"i)Ctrl","")
	GuiControlGet, var,4: , %Ctrl%
	;MsgBox,,, % Ctrl "`n " test_	
	if(var=1){
		GuiControl,4: ,%Ctrl% , 0
	}else if(var=0){
		GuiControl,4: ,%Ctrl% , 1		
	}
return


Load_Settings:
 if !WinExist("Drozd alarm settings")
	Gosub, alarm_settings	
	
		Loop, %numberOfalarms% {
		IniRead, x, %settings_ini%, alarm%A_Index%, alarm on , %A_Space%
		GuiControl,4:, Num%A_Index% , %x%	 

		IniRead, x , %settings_ini%, alarm%A_Index%, Name , %A_Space%
		GuiControl,4:, Name%A_Index% , %x%	 
		IniRead, x , %settings_ini%, alarm%A_Index%, Hour , %A_Space%
		GuiControl,4:, hora%A_Index% , %x%
		IniRead, x, %settings_ini%, alarm%A_Index%, Minute , %A_Space%
		GuiControl,4:, min%A_Index% , %x%
		IniRead, x , %settings_ini%, alarm%A_Index%, Second	 , %A_Space%
		GuiControl,4:, sec%A_Index% , %x%
		 
		GuiControl,4:, Msg%A_Index% , 0
		IniRead, x , %settings_ini%, alarm%A_Index%, Message , %A_Space%  ; 1= long , 2= short, 0= none
		if(x=1)
			GuiControl,4:, Msg%A_Index% , 1
		if(x=2)	
			GuiControl,4:, MsgSh%A_Index% , 1	
		
		IniRead, x , %settings_ini%, alarm%A_Index%, Sound file , %A_Space%
		GuiControl,4:, Sound%A_Index% , %x%
		
	
		IniRead,x , %settings_ini%, alarm%A_Index%, PC speaker  , %A_Space% ; 1= long , 2= short, 0= none
		if(x==1)
			GuiControl,4:, PC_l%A_Index% , 1
		if(x==2)	
			GuiControl,4:, PC_s%A_Index% , 1

		
		Name=A%A_Index%
		num=%A_Index%
		Loop, 7 {
			var=%Name%Day%A_Index%    
			day:=week_days[A_Index]
			IniRead, x , %settings_ini%, alarm%num%, %day%  , %A_Space%
			GuiControl,4:, %var% , %x%			
		}
	}
		

;==== every hour =====
		IniRead, x, %settings_ini%, alarm0, alarm on , %A_Space%
		GuiControl,4:, Num0 , %x%	 

		IniRead, x , %settings_ini%, alarm0, Name
		GuiControl,4:, Name0 , %x%	 
		;IniRead, x , %settings_ini%, alarm0, Hour
		;GuiControl,4:, hora0 , %x%
		IniRead, x, %settings_ini%, alarm0, Minute , %A_Space%
		GuiControl,4:, min0 , %x%
		IniRead, x , %settings_ini%, alarm0, Second	 , %A_Space%
		GuiControl,4:, sec0 , %x%

		IniRead, x , %settings_ini%, alarm0, Message , %A_Space%
		GuiControl,4:, Msg0 , %x%
		
		IniRead, x , %settings_ini%, alarm0, Sound file , %A_Space%
		GuiControl,4:, Sound0 , %x%
		
	
		IniRead,x , %settings_ini%, alarm0, PC speaker  , %A_Space% ; 1= long , 2= short, 0= none
		if(x==1)
			GuiControl,4:, PC_l0 , 1
		if(x==2)	
			GuiControl,4:, PC_s0 , 1
	
;==== 

;==== 

		Loop, %numberOfDatealarms% {
		IniRead, x, %settings_ini%, Date alarm%A_Index%, alarm on , %A_Space%
		GuiControl,4:, DateNum%A_Index% , %x%	 

		IniRead, x , %settings_ini%, Date alarm%A_Index%, Name , %A_Space%
		GuiControl,4:, DateName%A_Index% , %x%	 
		IniRead, x , %settings_ini%, Date alarm%A_Index%, Hour , %A_Space%
		GuiControl,4:, Datehora%A_Index% , %x%
		IniRead, x, %settings_ini%, Date alarm%A_Index%, Minute , %A_Space%
		GuiControl,4:, Datemin%A_Index% , %x%
		IniRead, x , %settings_ini%, Date alarm%A_Index%, Second	 , %A_Space%
		GuiControl,4:, Datesec%A_Index% , %x%
		
		IniRead, x , %settings_ini%, Date alarm%A_Index%, Date , %A_Space%
		GuiControl,4:, DateTime%A_Index% , %x%	
	
		
		IniRead, x , %settings_ini%, Date alarm%A_Index%, Message , %A_Space%
		GuiControl,4:, DateMsg%A_Index% , %x%
		
		IniRead, x , %settings_ini%, Date alarm%A_Index%, Sound file , %A_Space%
		GuiControl,4:, DateSound%A_Index% , %x%
		
	
		IniRead,x , %settings_ini%, Date alarm%A_Index%, PC speaker  , %A_Space% ; 1= long , 2= short, 0= none
		if(x==1)
			GuiControl,4:, DatePC_l%A_Index% , 1
		if(x==2)	
			GuiControl,4:, DatePC_s%A_Index% , 1
 
	}
	
;=== notify_texts
		FormatTime, year,, yyyy
		FormatTime, month,, MM
		FormatTime, day,, d
					
	Loop, %numberOfDatealarms% {
		IniRead, dat , %settings_ini%, Date alarm%A_Index%, Date , %A_Space%
			FormatTime, datY,%dat%, yyyy
			FormatTime, datM,%dat%, MM
			FormatTime, datD,%dat%, d		
			
		if(datY<year || (datY=year && datM<month)){
				GuiControl,4:, DateText%A_Index% ,✖ 
				Gui,4: Font , S9 cA00000
				GuiControl,4: Font, DateText%A_Index% 
		}else if(year=datY && month=datM){
				if(datD<day){
					GuiControl,4:, DateText%A_Index% ,✖ 
					Gui,4: Font , S9 cA00000 Q5, Tahoma 
					GuiControl,4: Font, DateText%A_Index% 
				}else if(datD=day){
					GuiControl,4:, DateText%A_Index% , ♫ ;◯ ;○  
					Gui,4: Font, s10 c2AB400 Q5, Tahoma 
					GuiControl,4: Font, DateText%A_Index% 
				}else if(datD=day+1){
					GuiControl,4:, DateText%A_Index% , ● ;• 
					Gui,4: Font ,S9  c2AB400 Q5, Tahoma 
					GuiControl,4: Font, DateText%A_Index% 	
				}else if(datD=day+2){
					GuiControl,4:, DateText%A_Index% , ● ;• 
					Gui,4: Font ,S9  cD0CFCF Q5, Tahoma 
					GuiControl,4: Font, DateText%A_Index% 					
				}		
		}else{
				/* 	GuiControl,4:, DateText%A_Index% ,● ; •  
					Gui,4: Font ,S9 cD0CFCF Q5 , Tahoma 
					GuiControl,4: Font, DateText%A_Index% 
					 */
		}
	}
	
;===== other settings

	IniRead, alarm_sound0, %settings_ini%, Misc , alarm sound
		if(FileExist(alarm_sound0))
			GuiControl,4:, SoundTimer, %alarm_sound0%

	IniRead, sounds_folder, %settings_ini%, Misc , sounds folder
		if(FileExist(sounds_folder))
			GuiControl,4:, SoundsFolder, %sounds_folder%
		
	IniRead, alarm_timer_on, %settings_ini%, Misc , alarm timer on
		if(alarm_timer_on!="ERROR")
			GuiControl,4:, Periodic_timer_on, %alarm_timer_on%
	IniRead, regulate_loudness, %settings_ini%, Misc , regulate loudness
		if(regulate_loudness!="ERROR")
			GuiControl,4:, Regulate_loudness, %regulate_loudness%		
		
	IniRead, full_hour_flash, %settings_ini%, window , full hour flash
		if(full_hour_flash!="ERROR")
			GuiControl,4:, full_hour_flash, %full_hour_flash%
	IniRead, small_date, %settings_ini%, window , small date
		if(small_date!="ERROR")
			GuiControl,4:, Show_small_date, %small_date%		

	IniRead, TimerMsg, %settings_ini%, Misc , Timer alarm dialog
		if(TimerMsg!="ERROR")
			GuiControl,4:, TimerMsg, %TimerMsg%	

	IniRead, TxtSpch, %settings_ini%, Misc , Text To Speech
		if(TxtSpch!="ERROR")
			GuiControl,4:, TxtSpch, %TxtSpch%		
		
return

SaveSet:
	Gui,4: Submit, Nohide	

;==== every hour =====
		IniWrite, % Num0 , %settings_ini%, alarm0, alarm on
		IniWrite, % Name0 , %settings_ini%, alarm0, Name
		
		;IniWrite, % hora0 , %settings_ini%, alarm0, Hour
		IniWrite, % dig(min0) , %settings_ini%, alarm0, Minute
		IniWrite, % dig(sec0) , %settings_ini%, alarm0, Second		

		IniWrite, % Msg0 , %settings_ini%, alarm0,	Message
		IniWrite, % Sound0 , %settings_ini%, alarm0, Sound file
		
		PC_l:=PC_l0 , PC_s:=PC_s0
		PCspeaker:= (PC_l==1) ? 1 : (PC_s==1) ?  2 : 0 ; 1= long , 2= short, 0= none
		IniWrite, %PCspeaker% , %settings_ini%, alarm0, PC speaker
;==== 


	Loop, %numberOfalarms% {
		IniWrite, % Num%A_Index% , %settings_ini%, alarm%A_Index%, alarm on
		IniWrite, % Name%A_Index% , %settings_ini%, alarm%A_Index%, Name
		
		IniWrite, % dig(hora%A_Index%) , %settings_ini%, alarm%A_Index%, Hour
		IniWrite, % dig(min%A_Index%) , %settings_ini%, alarm%A_Index%, Minute
		IniWrite, % dig(sec%A_Index%) , %settings_ini%, alarm%A_Index%, Second		

		i:=A_Index 
		Loop, 7 {
			IniWrite, % A%i%Day%A_Index% , %settings_ini%, alarm%i%, % week_days[A_Index]
		}


		IniWrite, % Sound%A_Index% , %settings_ini%, alarm%A_Index%, Sound file

		Msg:=Msg%A_Index% , MsgSh:=MsgSh%A_Index%
		Message:= (Msg==1) ? 1 : (MsgSh==1) ?  2 : 0 ; 1= long , 2= short, 0= none
		IniWrite, %Message% , %settings_ini%, alarm%A_Index%,	Message
		
		
		PC_l:=PC_l%A_Index% , PC_s:=PC_s%A_Index%
		PCspeaker:= (PC_l==1) ? 1 : (PC_s==1) ?  2 : 0 ; 1= long , 2= short, 0= none
		IniWrite, %PCspeaker% , %settings_ini%, alarm%A_Index%, PC speaker

	}


;==============
	Loop, %numberOfDatealarms% {
		IniWrite, % DateNum%A_Index% , %settings_ini%, Date alarm%A_Index%, alarm on
		IniWrite, % DateName%A_Index% , %settings_ini%, Date alarm%A_Index%, Name
		
		IniWrite, % dig(Datehora%A_Index%) , %settings_ini%, Date alarm%A_Index%, Hour
		IniWrite, % dig(Datemin%A_Index%) , %settings_ini%, Date alarm%A_Index%, Minute
		IniWrite, % dig(Datesec%A_Index%) , %settings_ini%, Date alarm%A_Index%, Second		

		IniWrite, % DateTime%A_Index% , %settings_ini%, Date alarm%A_Index%, Date

		IniWrite, % DateMsg%A_Index% , %settings_ini%, Date alarm%A_Index%,	Message
		IniWrite, % DateSound%A_Index% , %settings_ini%, Date alarm%A_Index%, Sound file
		
		PC_l:=DatePC_l%A_Index% , PC_s:=DatePC_s%A_Index%
		PCspeaker:= (PC_l==1) ? 1 : (PC_s==1) ?  2 : 0 ; 1= long , 2= short, 0= none
		IniWrite, %PCspeaker% , %settings_ini%, Date alarm%A_Index%, PC speaker


}

;===== other settings

	if FileExist(SoundTimer){
		IniWrite, %SoundTimer% , %settings_ini%, Misc, alarm sound
		alarm_sound0:=SoundTimer
	}
	if FileExist(SoundsFolder){
		IniWrite, %SoundsFolder% , %settings_ini%, Misc, sounds folder
		sounds_folder:=SoundsFolder
	}
	IniWrite, %Periodic_timer_on% , %settings_ini%, Misc, alarm timer on
	IniWrite, %Regulate_loudness% , %settings_ini%, Misc , regulate loudness
	IniWrite, %full_hour_flash% , %settings_ini%, window , full hour flash
	IniWrite, %Show_small_date% , %settings_ini%, window , small date			
	IniWrite, %TimerMsg% , %settings_ini%, Misc , Timer alarm dialog	
	
		small_date:=Show_small_date
		alarm_timer_on:=Periodic_timer_on
		show_alarm_dialog:=TimerMsg
		RuntextToSpeech:=TxtSpch

	if FileExist(textToSpeech){		
		IniWrite, %TxtSpch%, %settings_ini%, Misc , Text To Speech
		RuntextToSpeech:=TxtSpch
	}else{
		IniWrite,0, %settings_ini%, Misc , Text To Speech
		RuntextToSpeech:=0
		MsgBox,,, % "No file:`n" textToSpeech , 3
	}
	
	Menu, Submenu2, % (small_date=1) ? "Check" : "UnCheck"  , Show small date on/off 
	Menu, Submenu2, % (full_hour_flash=1) ? "Check" : "UnCheck"  , Full hour flash  on/off 
	Menu, Submenu2, % (alarm_timer_on=1) ? "Check" : "UnCheck"  , Periodic timer on/off 
	Menu, Submenu2, % (regulate_loudness=1) ? "Check" : "UnCheck"  , Regulate loudness on/off
	
	
	Gosub, get_alarm_list
	Gui,4: Destroy
	
	Gdip_draw_Win(GuiHwnd,angleM,angleH,rim,bgrd)
	SoundPlay, nic
return

Cancel_but:
	Gui,4: Destroy
	SoundPlay, nic
return


;==================================
;https://msdn.microsoft.com/en-us/library/windows/desktop/dd318693(v=vs.85).aspx
;https://autohotkey.com/boards/viewtopic.php?f=5&t=8992&p=49935#p49935
;LANG_ENGLISH:=0x0C09 ;  LANG_SPANISH :=0x0C0A ; LANG_GERMAN:=0x0C07 ; LANG_RUSSIAN:=0x0419
GetDateFormat(Date, Format := "dddd',' dd. MMMM yyyy",locale:=0x0C09){
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

;==============================

GuiSize:  ; on window resize
	WinGetPos, x1,y1,,, ahk_id %GuiHwnd%
	;WinGetPos, x1,y1,,, Drozd_zegar
	x2:=x1+42,y2:=y1+134
	WinMove , Drozd_show_timer ,,  x2 ,  y2
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



;============================================
 
temp_routine:
str:="small_date= " small_date "`n"
		. "full_hour_flash= " full_hour_flash "`n"
		. "Periodic alarm_timer_on= " alarm_timer_on "`n"
		. "alarm_loudness= " alarm_loudness "`n"
		. "regulate_loudness= " regulate_loudness "`n"
		; . "alarm_on= " alarm_on "`n"
		; . "flash_on= " flash_on "`n"
		; . "PCspeaker= " PCspeaker "`n"
		; . "timesBlink_max= " timesBlink_max "`n"

	MsgBox,,, % str
return


;===test



~+^g::
if(!alarm_on && full_hour_flash)
	gosub start_flash
return

~+^h::
gosub start_blink
return



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

