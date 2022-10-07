#SingleInstance off 

/*  
=== Drozd alarm timer
-- 
-- tray icon shows 2 timers: countdown and time compare, and the difference (timer is not precise ==> so it's set to 998 not 1000 ms )
-- choose alarm sound:  alarm_sound:="C:\sound\alarm.mp3" 
--
--  double click on tray icon = exit
*/


Menu, Tray,Tip , Alarm Timer
Menu, Tray, Icon, wmploc.dll, 21
Menu, Tray, Icon, shell32.dll,266 
Menu, Tray, NoStandard
;Menu, Tray, Icon, C:\Program Files\Misc\AutoHotkey Scripts\icons\Alarm-clock.ico
Menu, Tray, Add, Exit Alarm Timer, Exit_Gui ; double click tray icon to exit
Menu, Tray, Default, Exit Alarm Timer 


param1= %1%   

start_time=5
if(param1){
   start_time=%param1%
}



alarm_sound:="F:\1.Music\Rock\Jimi Hendrix\Jimi Hendrix - All Along The Watchtower.mp3" 



SysGet, MonitorWorkArea, MonitorWorkArea, 1
x:=A_ScreenWidth - 70 - 16
;y:= MonitorWorkAreaBottom -30
y:= MonitorWorkAreaBottom -146

 

Gui,1: +ToolWindow  
Gui,Color, 7D0019 ;83001A ; 054258
Gui,Font,  S10 w700 CDefault , Segoe UI      

Gui,Add,Text,cA4A4A4  x5  y10  h30   ,`     min or hhmm
Gui,Add,Edit,  x120   y10  h22  w100  vTIME Center , %start_time%
Gui, Add, UpDown, vUpDownHeight   Range0-60,%start_time%
Gui, Add, Checkbox, x24  y73 w60 h20 cA4A4A4 vCheckbox1  Checked , beep

Gui,Add,Text,cA4A4A4  x5    y40  h20  w100    ,`     MESSAGE
Gui,Add,Edit,c3F3F3F  x120   y40  h20  w100  vMESSAGE Center  , Alarm
Gui,Add,Button, x120 y70    h20  w100  gTIMER Center      ,START


ControlFocus,Edit1, Alarm Timer - Drozd
;Send, ^a

OnMessage(0x100, "WM_KEYDOWN")
Gui,Show, h106  w250 , Alarm Timer - Drozd

return



WM_KEYDOWN(wParam, lParam){  
   ControlGetFocus, control , Alarm Timer - Drozd
    if (A_Gui = 1 &&  wParam = 13 && control=="Edit1" ){ ; VK_ENTER := 13
      Gosub, timer
    }
}

WM_LBUTTONDOWN(){
	PostMessage, 0xA1, 2    ; movable borderless window 
}

/* ~LButton::
    tray_id:=WinExist("ahk_class Shell_TrayWnd")
	MouseGetPos,,,Win_id,control	
	if(Win_id == tray_id){ 
      sleep 200
      Gui,3:Show
    }
return
 */
timer:
Gui, Submit, Nohide
Gui, Destroy
Gosub, show_time
#SingleInstance off
#persistent

GuiControlGet, Checkbox1, , Checkbox1

FormatTime, start_timer,, HH:mm:ss 

seconds:= StrLen(TIME)<4 ? TIME * 60 : SubStr(TIME, -1 ) * 60 +  SubStr(TIME, 1,2 ) * 3600
TIME_min:= StrLen(TIME)<4 ? TIME : SubStr(TIME, 1,2 ) "h " SubStr(TIME, -1 ) ""
time_count= %seconds%  
start_time:=A_TickCount
SetTimer, count_time, 998  ;1000
SetTimer, compare_time, 1000

return

count_time:
time_count:=time_count-1
count_timeLeft_h := Floor(time_count/3600)
count_timeLeft_m := time_count>3600 ? Floor(mod(time_count,3600)/60) : Floor(time_count/60)
count_timeLeft_s := Floor(mod(time_count,60))
   
count_time_left:=count_timeLeft_h >0 ? dig(count_timeLeft_h) " : " dig(count_timeLeft_m) " : " dig(count_timeLeft_s)  : "`    " dig(count_timeLeft_m) "  :  " dig(count_timeLeft_s) 
time_left_2:=count_timeLeft_m " : " dig(count_timeLeft_s) 

if(time_count<=0){
   SetTimer, count_time, Off   
}
return



compare_time: 
  time_compare := Round((A_TickCount - start_time)/1000)
  time_compare:=seconds-time_compare
  compare_timeLeft_h := Floor(time_compare/3600)
  compare_timeLeft_m := time_compare>3600 ? Floor(mod(time_compare,3600)/60) : Floor(time_compare/60)
  compare_timeLeft_s := Floor(mod(time_compare,60))
  ;time_compare_show:= time_compare>3600 ? dig(h) " : " dig(m) " : " dig(s) :  dig(m) " : " dig(s)
  time_compare_show:=compare_timeLeft_h >0 ? dig(compare_timeLeft_h) ":" dig(compare_timeLeft_m) ":" dig(compare_timeLeft_s)  : dig(compare_timeLeft_m) ":" dig(compare_timeLeft_s) 
  count_time_left2:=RegExReplace(count_time_left,"\s+:\s+",":") 
  tray_tip:="count:     " count_time_left2 "`n" "compare:    " time_compare_show "`ntime:            " TIME_min "  min" "`nstarted on:  " start_timer

  time_compare_left:=compare_timeLeft_h >0 ? dig(compare_timeLeft_h) " : " dig(compare_timeLeft_m) " : " dig(compare_timeLeft_s)  : "`    " dig(compare_timeLeft_m) "  :  " dig(compare_timeLeft_s) 
  GuiControl,3:, Show_timer, %time_compare_left%
  Menu, Tray,Tip , % tray_tip  ;"`ndiff:            " diff " " m_count " " d2 
  if(time_compare<=0){
     SetTimer, compare_time, Off
     SetTimer, count_time, Off
     Gosub, alarm
  }
return

dig(num){ ;to_two_digits
   num:= num<=9 ? "0" . num : num
   return num
}
    
    
    
alarm:
   if(Checkbox1==1){
      SoundBeep,700
      SoundBeep,,400 
      SoundPlay *48
   }

  ;SoundPlay, C:\sound\flute.mp3 
   
   alarm_text:= MESSAGE
   if(alarm_text=="Alarm")
      alarm_text:="Now"
   Gosub, alarm_dialog_show  
return



/* show_time:      ; bez ramki
  Gui,3: +ToolWindow -border AlwaysOnTop	  
  Gui,3:Color, %CustomColor%  ;120F00 
  Gui,3: Font, S8 W700 , Tahoma ;Segoe UI  Verdana
  Gui,3: Add, Text , x8 y6 w60 cFFFFFF vShow_timer ,  ;01 : 12 : 04   
  Gui,3: Font, S6 cD0D0D0
  ;Gui,3: Add, Text , x69 y+-21 w60 gshow_time_exit  ,  x

  Gui,3:Show,  x%x% y%y%  w70 h20  , Show_timer - Drozd  
  
  Winset, Transparent,200, Show_timer - Drozd
  WinSet, Style, -0xC00000,Show_timer - Drozd ; COMPLETELY remove window border
  ;WinSet, Region, 0-4 w70 h20 E, Show_timer - Drozd ; ellipse
  OnMessage(0x201, "WM_LBUTTONDOWN") ; movable borderless window   
return
 */

show_time:       ; z ramką
  Gui,3: +ToolWindow -border AlwaysOnTop	  
  Gui,3:Color, %CustomColor%  ;120F00 
  Gui,3: Font, S8 W700 , Tahoma ;Segoe UI  Verdana
  Gui,3: Add, Text , x6 y3 w60 cFFFFFF vShow_timer gDblClick ,  ;01 : 12 : 04   
  Gui,3: Font, S6 cD0D0D0
  ;Gui,3: Add, Text , x69 y+-21 w60 gshow_time_exit  ,  x

  Gui,3:Show,  x%x% y%y%  w70 h20  NA, Show_timer - Drozd  
 ;  WinSet, Style, -0xC00000,Show_timer - Drozd  
  Winset, Transparent,200, Show_timer - Drozd
  OnMessage(0x201, "WM_LBUTTONDOWN") ; movable borderless window   
return

DblClick:
   if A_GuiControlEvent <> DoubleClick
     return
   win_bord:=!win_bord
   if(!win_bord){  
      WinSet, Style, +0xC00000,Show_timer - Drozd
      Gui,3: +ToolWindow -border
      ControlMove, Static1 , , 6 ,,,  Show_timer - Drozd
   }else{
      WinSet, Style, -0xC00000,Show_timer - Drozd
      Gui,3: +ToolWindow -border
      ControlMove, Static1 , ,6 ,,,  Show_timer - Drozd     
   }

return

show_time_exit:
Gui,3: Destroy
return


alarm_dialog_show: 
  start_msg_timer:=0

  SoundGetWaveVolume, głosnosc
  ;play_music(5)
  SetTimer, flash, 1000
  SetTimer, beep, 10000
  
  Gui,2: +ToolWindow -border AlwaysOnTop	
  
  Gui,2:Color, 120F00 
  Gui,2: Font, S8 W700 , Tahoma 
  Gui,2: Add, Text , x43 y6 w60 cFFFFFF vmsg_timer Center , 
  Gui,2:Add,Groupbox,cD0D0D0 x18 y24 w117 h96 vramka
  Gui,2: Font, S11 W700 , Comic Sans MS  
  Gui,2: Add, Text , x55 y37   cFFFFFF vtitle Center gplay_again , Alarm
  Gui,2: Font, S11 W700 , Tahoma ;
  Gui,2: Add, Text , x26 y68 w100 h50 cFFFFFF vShow_alarm Center , %alarm_text%
  Gui,2: Font, S8 cD0D0D0
  Gui,2: Add, Text , x130 y1 w30 h20 gexit  , `   X      
  Gui,2: Font, S8 W400 cD0D0D0, Segoe UI   
  Gui,2: Add, Text , x100 y128 w20 vt_left Right ,  
  Gui,2: Add, Text , x122 y128 w30 c413700 vt_left0 , 
  Gui,2: Hide

  Gui,2:Show,  w150 h150  NA, Show_alarm - Drozd 

  Winset, Transparent,200, Show_alarm - Drozd
  ;WinSet, Style, -0xC00000,Show_alarm - Drozd ; COMPLETELY remove window border
  
  SetTimer, time_date, 1000

  play_music(5)
  
  OnMessage(0x203,"WM_LBUTTONDBLCLK")
  OnMessage(0x201, "WM_LBUTTONDOWN") ; movable borderless window     
  OnMessage(0x200, "WM_MOUSEMOVE")
return


play_music(level){
  global alarm_sound  
  SoundPlay, %alarm_sound%
  SoundGetWaveVolume, głosnosc
  play_głosnosc(level)  
}

play_głosnosc(n){
 loop, %n% {
   SoundSetWaveVolume,  % A_Index*5
   Sleep, 100
   SoundSetWaveVolume,  % A_Index*5
   Sleep, 100
 }
}


beep:
	SoundPlay *48
return



time_date:
start_msg_timer+=1 
msg_timer_h := Floor(start_msg_timer/3600)
msg_timer_m := time_count>3600 ? Floor(mod(start_msg_timer,3600)/60) : Floor(start_msg_timer/60)
msg_timer_s := Floor(mod(start_msg_timer,60))

msg_timer_l:=msg_timer_h >0 ? dig(msg_timer_h) " : " dig(msg_timer_m) " : " dig(msg_timer_s)  : "`    " dig(msg_timer_m) "  :  " dig(msg_timer_s) 
GuiControl,2:, msg_timer, %msg_timer_l%
return


flash:
    col:=!col          
  if(col){
    Gui,2: Font, S11 cFFFFFF W700 , Comic Sans MS
    GuiControl,2: Font, title  
  }else{
    Gui,2: Font, S11 cRed W700 , Comic Sans MS
    GuiControl,2: Font, title        
  }
return


play_again:
play_music(5)
return




Exit_Gui:
MsgBox, 4,, `   Stop Exit of Alarm Timer in 3 sec.?, 3
    IfMsgBox, No
      exitapp
    IfMsgBox, Yes
    {
      return
    }else{
      exitapp
    }
return


guiclose:
exit:
ExitApp


