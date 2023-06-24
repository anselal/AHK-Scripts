#SingleInstance off 

/*  
=== Drozd Alarm_timer_auto
-- run from another program with line: Run, Alarm_timer_auto.ahk "minutes" "text" "no beep"
-- or Alarm_timer_auto.ahk 5 
-- 3 parameters: 1: minutes, 2: message 3: no beep
-- choose alarm sound:  alarm_sound:="C:\sound\alarm.mp3" 
-- tray icon shows 2 timers: countdown and time compare, and the difference (timer is not precise ==> so it's set to 998 not 1000 ms )
--  double click on tray icon = exit
*/

Menu, Tray,Tip , Alarm Timer
;Menu, Tray, Icon, wmploc.dll, 21
Menu, Tray, Icon, shell32.dll,266 
;Menu, Tray, Add , Edit Scite, Edit_Scite
;Menu, Tray, Add , Edit Notepad, Edit_Notepad
;Menu, Tray, Icon, C:\Program Files\Misc\AutoHotkey Scripts\icons\Alarm-clock.ico
Menu, Tray, Add, Exit Alarm Timer, Exit_Gui ; double click tray icon to exit
Menu, Tray, Default, Exit Alarm Timer 



;Run \Alarm_timer_auto.ahk "minutes" "text" ["no beep"]

alarm_sound:="C:\WINDOWS\Media\chimes.wav" ;"C:\Program Files\Misc\AutoHotkey Scripts\sound\Cuckoo4.wav"

text:=""
start_time:=1

param1= %1%   
param2= %2% 
param3= %3% 

if(param1){
   start_time=%param1%
}

if(!param2){    
   param2:=start_time " min"
}

if(param2){
   text=%param2%
}

if(param3){
   no_beep=true   
}


SysGet, MonitorWorkArea, MonitorWorkArea, 1

x:=A_ScreenWidth - 70 - 66
y:= MonitorWorkAreaBottom -172

CustomColor = 120F00
InvertedColor = EDF0FF 

;------------------- TIMER ----------------------------------------------------


Gui,submit,nohide
Gui,destroy
Gosub, show_time
#SingleInstance off
#persistent

TIME_min= %start_time%

;seconds:= StrLen(TIME)<4 ? TIME * 60 : SubStr(TIME, -1 ) * 60 +  SubStr(TIME, 1,2 ) * 3600
seconds:=TIME_min* 60
time_count= %seconds%  
start_time:=A_TickCount
SetTimer, count_time, 998  ;1000
SetTimer, compare_time, 1000
return

    
count_time:
time_count:=time_count-1
count_timeLeft_h := Floor(time_count/3600)
count_timeLeft_m := time_count>=3600 ? Floor(mod(time_count,3600)/60) : Floor(time_count/60)
count_timeLeft_s := Floor(mod(time_count,60))
   
count_time_left:=count_timeLeft_h >0 ? dig(count_timeLeft_h) ":" dig(count_timeLeft_m) ":" dig(count_timeLeft_s)  : "`    " dig(count_timeLeft_m) ":" dig(count_timeLeft_s) 
time_left_2:=count_timeLeft_m " : " dig(count_timeLeft_s) 
if(time_count<=0){
   SetTimer, count_time, Off
}
return


compare_time: 
time_compare := Round((A_TickCount - start_time)/1000)
;ToolTip, % time_compare_show
time_compare:=seconds-time_compare
compare_timeLeft_h := Floor(time_compare/3600)
compare_timeLeft_m := time_compare>3600 ? Floor(mod(time_compare,3600)/60) : Floor(time_compare/60)
compare_timeLeft_s := Floor(mod(time_compare,60))
;time_compare_show:= time_compare>3600 ? dig(h) " : " dig(m) " : " dig(s) :  dig(m) " : " dig(s)
time_compare_show:=compare_timeLeft_h >0 ? dig(compare_timeLeft_h) ":" dig(compare_timeLeft_m) ":" dig(compare_timeLeft_s)  : dig(compare_timeLeft_m) ":" dig(compare_timeLeft_s) 
tray_tip:="count:   " count_time_left "`n" "compare:  " time_compare_show "`ntime:          " TIME_min " min"
;diff:=
Menu, Tray,Tip , % tray_tip  ;"`ndiff:            " diff " " m_count " " d2 
GuiControl,3:, Show_timer, %time_compare_show%
if(time_compare<=0){
   SetTimer, compare_time, Off
   Gosub, alarm
}
return

dig(num){ ;to_two_digits
   num:= num<=9 ? "0" . num : num
   return num
}


alarm:

if(no_beep){
   SoundPlay *48
   SoundPlay, %alarm_sound%
   Msgbox,,, %text% ,30   
}else{
   SoundBeep,800,100
   SoundBeep,800,200
   SoundPlay *48
 
  SoundPlay,%alarm_sound%
   Msgbox,,, %text% ,3
}

exitapp

WM_LBUTTONDOWN(){
	PostMessage, 0xA1, 2    ; movable borderless window 
}



show_time:     
  Gui,3: +ToolWindow -border +AlwaysOnTop	  
  Gui,3:Color, %CustomColor%  ;120F00 
  Gui,3: Font, S8 W700 , Tahoma ;Segoe UI  Verdana
  Gui,3: Add, Text , x0 y4 w52  cFFFFFF vShow_timer Center, 
  Gui,3: Font, S6 cD0D0D0
  ;Gui,3: Add, Text , x69 y+-21 w60 gshow_time_exit  ,  x

  Gui,3:Show,  x%x% y%y%  w44 h16  NA, Show_timer - Drozd
  
  Winset, Transparent,200, Show_timer - Drozd
  WinSet, Style, -0xC00000,Show_timer - Drozd ; COMPLETELY remove window border
  OnMessage(0x201, "WM_LBUTTONDOWN") ; movable borderless window   
return

show_time_exit:
Gui,3: Destroy
return

Edit_Notepad:
Run, "C:\Program Files\Notepad2\Notepad2.exe" "%A_ScriptFullPath%"
return

Edit_Scite:
Run, "C:\Program Files\AutoHotkey\SciTE\SciTE.exe"  "%A_ScriptFullPath%"
return

Exit_Gui:
MsgBox,,, `            Exit Alarm Timer `n(after double click on tray icon) ,1
exitapp




