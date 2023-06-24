#SingleInstance off 
;#NoTrayIcon

/*  
=== Drozd stopper
-- top left circle =  reset
-- double click = pause
-- tray icon shows 2 timers: countdown and time compare, and the difference (timer is not precise ==> so it's set to 998 not 1000 ms )
-- the difference is caused also by standby mode
*/

Menu, Tray, Icon, imageres.dll,181  ;shell32.dll,  3 

;Menu, Tray, Add , Edit Scite, Edit_Scite
;Menu, Tray, Add , Edit Notepad, Edit_Notepad
Menu, Tray, Add , diff_zero, diff_zero
Menu, Tray, Add
Menu, Tray, Add, Reload , Reload
Menu, Tray, Add, Exit , exit ; double click tray icon to exit
Menu, Tray, Default, Exit 


Menu, ContextMenu, Add, On Top, OnTop
Menu, ContextMenu, Icon, On Top, Shell32.dll, 248 
Menu, ContextMenu, Add,
Menu, ContextMenu, Add, Reset, reset
Menu, ContextMenu, Add, Pause, pause
Menu, ContextMenu, Add
Menu, ContextMenu, Add, Reload , Reload
Menu, ContextMenu, Add, Exit , Exit
Menu, ContextMenu, Icon, Exit, shell32.dll, 132

SysGet, MonitorWorkArea, MonitorWorkArea, 1
x:=A_ScreenWidth - 90 - 16
y:= MonitorWorkAreaBottom -175

time_count:=0 
global started:=true

old_diff:=""

Gui,1: +ToolWindow -border  +AlwaysOnTop	+HwndGuiHwnd
WonTop:=1
Gui,1:Color, 120F00 
Gui,1: Font, S8 cD0D0D0
Gui,1: Add, Text , x2 y+-2 w13 h13 greset , % Chr(9679) ; ● 
Gui,1: Font, S6 w700 cD0D0D0,Tahoma
Gui,1: Add, Text , x88 y1 w8 h8 gexit Center ,  X 
;Gui,1: Font, S6 cD0D0D0
;Gui,1: Add, Text , x+2 y2  gpause , ▮▮ 
Gui,1: Font, S8 cD0D0D0 w700, Tahoma ;
Gui,1: Add, Text , x18 y8 w60 cFFFFFF vShow_timer Center, 



OnMessage(0x201, "WM_LBUTTONDOWN") ; movable borderless window   
OnMessage(0x203,"WM_LBUTTONDBLCLK")

Gui,1:Show,  x%x% y%y%  w90 h24  , Drozd_stoper

Winset, Transparent,200, Drozd_stoper  
WinSet, Style, -0xC00000, Drozd_stoper ; COMPLETELY remove window border


SetTimer, count_time, 998 
;SetTimer, count_time, 1000
Sleep,200
SetTimer, compare_time, 1000

Gosub, start_time
return


WM_LBUTTONDOWN(){
	if (A_Gui=1){
	PostMessage, 0xA1, 2    ; movable borderless window 
	}
}

WM_LBUTTONDBLCLK(){
		Gosub, pause
}

reset:
time_count:=0
;old_diff:=""
Gosub, start_time
GuiControl, , Show_timer , % "00:00"
return

count_time:
time_count:=time_count+1
;time_count_show:= (time_count>=60) ? Floor(time_count/60) "m " mod(time_count,60) "s" : time_count "s"
s_count:=mod(time_count,60)
m_count:=time_count>=3600 ? Floor(mod(time_count,3600)/60) : Floor(time_count/60) 
h_count:=Floor(time_count/3600)

if(mod(time_count,60)==0){
	;Gosub, Col_red
}

time_count_show:= time_count>=3600 ? dig(h_count) ":" dig(m_count) ":" dig(s_count) :  dig(m_count) ":" dig(s_count)
GuiControl, , Show_timer , % time_count_show
;Menu, Tray,Tip , % "count: " time_count_show "`nstart: " h0 ":" m0 ":" s0
return


compare_time: 
;-----------------------------
time_compare_2 := Round((A_TickCount - start_time_TickCount)/1000)

compare_timeLeft_h := Floor(time_compare_2/3600)
compare_timeLeft_m := time_compare_2>3600 ? Floor(mod(time_compare_2,3600)/60) : Floor(time_compare_2/60)
compare_timeLeft_s := Floor(mod(time_compare_2,60))
;time_compare_show:= time_compare>3600 ? dig(h) " : " dig(m) " : " dig(s) :  dig(m) " : " dig(s)
time_compare_2_show:=compare_timeLeft_h >0 ? dig(compare_timeLeft_h) ":" dig(compare_timeLeft_m) ":" dig(compare_timeLeft_s)  : dig(compare_timeLeft_m) ":" dig(compare_timeLeft_s) 
;-----------------------------

diff:= Abs(time_count - time_compare_2) 
 
tray_tip:="count:        " time_count_show "`n" "compare:   " time_compare_2_show "`nstart time:  " h0 ":" m0 ":" s0 "`ndifference: " format_sec(diff) 
Menu, Tray,Tip , % tray_tip 
return



start_time:
RegExMatch(A_Now,"(\d\d)(\d\d)(\d\d)$", d)
h0:=d1, m0:=d2, s0:= d3
start_time_TickCount:=A_TickCount
return


dig(num){ ;to_two_digits
   num:= num<=9 ? "0" . num : num
   return num
}

format_sec(seconds){ ;
	h := Floor(seconds/3600)
	m := seconds>3600 ? Floor(mod(seconds,3600)/60) : Floor(seconds/60)
	s := Floor(mod(seconds,60))
	show:=h >0 ? dig(h) ":" dig(m) ":" dig(s)  : dig(m) ":" dig(s) 
   return show
}


pause:
	if(started){
		started:=false
		SetTimer, count_time, Off
	}else if(!started){
		started:=true
		SetTimer, count_time, 1000
	}	
return

Col_red:
CustomColor2 = 7A0218
Gui, Color, c%CustomColor2%
Winset, Transcolor, %InvertedColor% 200, Drozd_stoper 
SetTimer, col_reset, 400
return

col_reset:
SetTimer, col_reset, Off
Gui, Color, c%CustomColor%
Winset, Transcolor, %InvertedColor% 200, Drozd_stoper 
return


diff_zero:
if(diff>60){	
	old_diff:=old_diff " | " format_sec(diff)
}
time_count := time_compare_2
return




Edit_Notepad:
Run, "C:\Program Files\Notepad2\Notepad2.exe" "%A_ScriptFullPath%"
return

Edit_Scite:
Run, "C:\Program Files\AutoHotkey\SciTE\SciTE.exe"  "%A_ScriptFullPath%"
return


;^d:: Gosub, pause

onTop:        
		if WonTop {
			WinSet, AlwaysOnTop, off, Drozd_stoper
			GuiControl, Show, onTop_off
			GuiControl, Hide, onTop_on
			WonTop:=0	
		}else{
			WinSet, AlwaysOnTop, on, Drozd_stoper
			GuiControl, Show, onTop_on
			GuiControl, Hide, onTop_off	
			WonTop:=1			
		}	
DllCall( "AnimateWindow", "Int", GuiHwnd, "Int", 300, "Int", 0x00010010 ) 
DllCall( "AnimateWindow", "Int", GuiHwnd, "Int", 300, "Int", 0x00000010 ) 
return


Reload:
Reload
return

GuiContextMenu:
Menu, ContextMenu, Show, %A_GuiX%, %A_GuiY%
Return


exit:
GuiClose:
ExitApp

;Esc:: ExitApp

