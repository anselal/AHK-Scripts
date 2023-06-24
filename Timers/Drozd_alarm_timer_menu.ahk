;#SingleInstance force

; shows time left on taskbar; movable window
; double click on tray icon = exit
ico:="C:\AutoHotkey Scripts\icons\Alarm-clock.ico"
;ico:="wmploc.dll`, 17"
Menu, Tray,Tip , Alarm Timer
;Menu, Tray, Icon, pifmgr.dll, 5
;Menu, Tray, Icon, wmploc.dll, 21
;Menu, Tray, Icon, shell32.dll,266 
;Menu, Tray, Icon, C:\AutoHotkey Scripts\icons\Alarm-clock.ico
;Menu, Tray, Icon, wmploc.dll, 21 ; Win Vista
;Menu, Tray, Icon, wmploc.dll, 17 ; Win8
ico1:=RegExMatch(A_OSVersion,"WIN_VISTA|WIN_7") ? 21: 17
Menu, Tray, Icon, wmploc.dll , %ico1%

Menu, Tray, Add, Exit Alarm Timer, Exit_Gui ; double click tray icon to exit
Menu, Tray, Default, Exit Alarm Timer ; double click tray icon to exit
Menu, Tray, Add, Hide/Show, hide_show 
;Menu, Tray, Default, Hide/Show  

Menu, ContextMenu, Add, Hide/Show, hide_show
Menu, ContextMenu, Add, Border, border_
Menu, ContextMenu, Add, Open settings file , Open_ini
Menu, ContextMenu, Icon, Open settings file, Shell32.dll, 70



param1= %1%   

start_time=5
if(param1){
   start_time=%param1%
}
SoundGet, loudness_start
alarm_texts_string:=""
;----

global settings_ini := "Drozd alarm timer.ini"

IfNotExist, %settings_ini%
{
  start_ini_text:="[Alarm timer]`r`nwin_sound=1`r`nloudness=5`r`nhide_show_time_key=1`r`nalarm_text1=Alarm`r`nalarm_text2=News`r`nalarm_text3=Mecz`r`nalarm_sound1=C:\WINDOWS\Media\chimes.wav`r`nalarm_sound2=C:\WINDOWS\Media\notify.wav`r`nalarm_sound3=C:\WINDOWS\Media\tada.wav`r`n" 
  FileAppend, % start_ini_text , %settings_ini%
}



;-----------

Menu, FileMenu, Add, Open settings file , Open_ini
Menu, FileMenu, Icon, Open settings file, Shell32.dll, 70
Menu, FileMenu, Add, Exit, Exit
Menu, FileMenu, Icon, Exit, shell32.dll,132 
Menu, MenuBar, Add, &File, :FileMenu



Loop, 10{		 
  IniRead, key, %settings_ini%, Alarm timer, alarm_sound%A_Index%
  if (key!="ERROR" && key!=""){
     ;sound_files=%sound_files%|%key%
      Menu, SoundMenu, Add, %key%, MenuHandler
      ;Menu, SoundMenu, Icon, %key%, shell32.dll,132     
  }else if (key=="ERROR"){
    break
  }
}

Menu, MenuBar, Add, &Sound File, :SoundMenu



Menu, AlarmsMenu, Add, 10 min., start_timer_10m
Menu, AlarmsMenu, Icon, 10 min., %ico%
Menu, AlarmsMenu, Add, 15 min., start_timer_15m
Menu, AlarmsMenu, Icon, 15 min., %ico%
Menu, AlarmsMenu, Add,
Menu, AlarmsMenu, Add, 20 min., start_timer_20m
Menu, AlarmsMenu, Icon, 20 min., %ico%
Menu, AlarmsMenu, Add, 30 min., start_timer_30m
Menu, AlarmsMenu, Add,
Menu, AlarmsMenu, Icon, 30 min., %ico%
Menu, AlarmsMenu, Add, 60 min., start_timer_60m
Menu, AlarmsMenu, Icon, 60 min., %ico%
Menu, MenuBar, Add, &Alarms, :AlarmsMenu


Menu MenuBar, Color, A4A4A4 , Single
Gui, Menu, MenuBar

;----

IniRead, key, %settings_ini%, Alarm timer, alarm_sound1
;alarm_sound0:="F:\Music\Jimi Hendrix\Jimi Hendrix - All Along The Watchtower.mp3" 
alarm_sound0:="C:\WINDOWS\Media\chimes.wav" 
alarm_sound:= (key!="ERROR") ? key : alarm_sound0

IniRead, win_sound, %settings_ini%, Alarm timer, win_sound
IniRead, loudness, %settings_ini%, Alarm timer, loudness
IniRead, hide_show_time_key, %settings_ini%, Alarm timer, hide_show_time_key



Loop, 10{	 
  IniRead, key_text, %settings_ini%, Alarm timer, alarm_text%A_Index%
  if(key_text!="ERROR" && key_text!=""){  
    alarm_texts_string:= alarm_texts_string  key_text "|"
  }else if (key_text=="ERROR"){
    break
  }
}

;----


SysGet, MonitorWorkArea, MonitorWorkArea, 1
x:=A_ScreenWidth - 70 - 16
;y:= MonitorWorkAreaBottom -30
y:= MonitorWorkAreaBottom -146



Gui,1: -border 
Gui,Color,83001A  ; 054258
;Gui,1:Color, 120F00
Gui,1:Color, 7D0019
Gui,Font,  S9 w700 CDefault , Segoe UI      

Gui,Add,Text,cA4A4A4  x15  y13  h30   Center ,`     min or hhmm

Gui, Add, Checkbox, x32  y73 w60 h20 cA4A4A4 vCheckbox1  Checked , ` beep

Gui,Font,  S10 w700 CDefault , Segoe UI    
Gui,Add,Edit,  x120   y10  h22  w100  vTIME Center , %start_time%
Gui, Add, UpDown, vUpDownHeight   Range0-60,%start_time%

Gui, Add,Text,cA4A4A4  x10    y42  h20  w100  Center  ,`   Alarm text
Gui,Font,  S9 w700 CDefault , Segoe UI    
Gui, Add, ComboBox, x120   y40    w100  vMESSAGE gCombo Limit Choose1, %alarm_texts_string%  ;Alarm|Mecz|News

Gui,Font,  S10 w700 CDefault , Segoe UI    
Gui,Add,Button, x120 y72    h24  w100  gTIMER Center      ,Start
Gui,1: Add, Picture, x238 y4 w16 h16  gexit  Icon132 AltSubmit, shell32.dll  ;  


;ControlFocus,Edit1, Alarm Timer - Drozd
;Send, ^a

OnMessage(0x100, "WM_KEYDOWN")
OnMessage(0x201, "WM_LBUTTONDOWN") ; movable borderless window
OnMessage(0x404, "AHK_NOTIFYICON") ;click tray icon to show
Gui,Show,  h106  w256 , Alarm Timer - Drozd

;Winset, Transparent, 230, Alarm Timer - Drozd
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

AHK_NOTIFYICON(wParam, lParam){ ;click tray icon to show
    if (lParam = 0x202) {       ; WM_LBUTTONUP
			Gosub, hide_show
    }else if (lParam = 0x203){   ; WM_LBUTTONDBLCLK
		;Gui,1: Show
	}
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

 
count_time:
;ToolTip, % time_count
time_count:=time_count-1
count_timeLeft_h := Floor(time_count/3600)
count_timeLeft_m := time_count>=3600 ? Floor(mod(time_count,3600)/60) : Floor(time_count/60)
count_timeLeft_s := Floor(mod(time_count,60))
   
;Menu, Tray,Tip , % count_time_left
count_time_left:=count_timeLeft_h >0 ? dig(count_timeLeft_h) " : " dig(count_timeLeft_m) " : " dig(count_timeLeft_s)  : "`    " dig(count_timeLeft_m) "  :  " dig(count_timeLeft_s) 
time_left_2:=count_timeLeft_m " : " dig(count_timeLeft_s) 
;GuiControl,3:, Show_timer, %count_time_left%
if(time_count<=0){
   SetTimer, count_time, Off
   ;SetTimer, compare_time, Off
   ;Gosub, alarm
}
return


compare_time:
time_compare := Round((A_TickCount - start_time)/1000)
;ToolTip, % time_compare_show
time_compare:=seconds-time_compare
compare_timeLeft_h := Floor(time_compare/3600)
compare_timeLeft_m := time_compare>=3600 ? Floor(mod(time_compare,3600)/60) : Floor(time_compare/60)
compare_timeLeft_s := Floor(mod(time_compare,60))
;time_compare_show:= time_compare>=3600 ? dig(h) " : " dig(m) " : " dig(s) :  dig(m) " : " dig(s)
time_compare_show:=compare_timeLeft_h >0 ? dig(compare_timeLeft_h) ":" dig(compare_timeLeft_m) ":" dig(compare_timeLeft_s)  : dig(compare_timeLeft_m) ":" dig(compare_timeLeft_s) 
count_time_left2:=RegExReplace(count_time_left,"\s+:\s+",":") 
tray_tip:="count:     " count_time_left2 "`n" "compare:    " time_compare_show "`ntime:            " TIME_min "  min" "`nstarted on:  " start_timer
;diff:=
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
   
  GuiControlGet, MESSAGE , , ComboBox
  alarm_time:= "" TIME " min." 
  alarm_text:= MESSAGE
   if(alarm_text=="Alarm")
      alarm_text:="• Timer •"
      
   Gosub, alarm_dialog_show  
return



/* show_time:      ;  bez ramki
  Gui,3: +ToolWindow -border AlwaysOnTop	  
  Gui,3:Color, 120F00  ;120F00 
  Gui,3: Font, S8 W700 , Tahoma ;Segoe UI  Verdana
  Gui,3: Add, Text , x8 y6 w60 cFFFFFF vShow_timer ,  ;01 : 12 : 04   
  Gui,3: Font, S6 cD0D0D0
  ;Gui,3: Add, Text , x69 y+-21 w60 gshow_time_exit  ,  x

  Gui,3:Show,  x%x% y%y%  w70 h20  , Show_timer - Drozd  
  
  Winset, Transcolor, %InvertedColor% 200, Show_timer - Drozd  ; Show_timer - Drozd
  WinSet, Style, -0xC00000,Show_timer - Drozd ; COMPLETELY remove window border
  ;WinSet, Region, 0-4 w70 h20 E, Show_timer - Drozd ; ellipse
  OnMessage(0x201, "WM_LBUTTONDOWN") ; movable borderless window   
return
 */

show_time:      ;  z ramką
  Gui,3: +ToolWindow -border AlwaysOnTop	  
  Gui,3:Color, 120F00  ;120F00 
  Gui,3: Font, S8 W700 , Tahoma ;Segoe UI  Verdana
  Gui,3: Add, Text , x6 y3 w60 cFFFFFF vShow_timer gDblClick ,  ;01 : 12 : 04   
  Gui,3: Font, S6 cD0D0D0
  ;Gui,3: Add, Text , x69 y+-21 w60 gshow_time_exit  ,  x

  Gui,3:Show,  x%x% y%y%  w70 h20  NA, Show_timer - Drozd  
 ;  WinSet, Style, -0xC00000,Show_timer - Drozd  
   Winset, Transparent,200, Show_timer - Drozd
  OnMessage(0x201, "WM_LBUTTONDOWN") ; movable borderless window   
return

~Pause:: Gosub, hide_show

hide_show:
  if (!hide_show_time_key)
    return
  hide_show_time:=!hide_show_time
  if(hide_show_time){
    Gui,3:Hide
  }else if(!hide_show_time){
    Gui,3:Show
  }
return

DblClick:
   if A_GuiControlEvent <> DoubleClick
     return
  gosub, border_
return


border_:
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
  diff:= Abs(time_count - time_compare)
  start_msg_timer:=diff

  ;SoundGetWaveVolume, loudness_start
  SoundGet, loudness_start
  ;play_music(5)
  SetTimer, flash, 1000
  if(win_sound==1){
    SetTimer, beep, 10000
  }
  
  Gui,2: +ToolWindow -border AlwaysOnTop	
  
  Gui,2:Color, 120F00 
  ;Gui,2: Add, Edit, x60 y4 w140 h20 0x100 vQuery_1 , ; Search 	
  Gui,2: Font, S8 W700 , Tahoma ;Segoe UI  Verdana
  Gui,2: Add, Text , x43 y6 w60 cFFFFFF vmsg_timer Center , ; 01 : 12 : 04 
  Gui,2:Add,Groupbox,cD0D0D0 x18 y24 w117 h96 vramka
  Gui,2: Font, S11 W700 , Comic Sans MS  ;Segoe UI ; Verdana
  Gui,2: Add, Text , x55 y37   cFFFFFF vtitle Center gplay_again , Alarm
  Gui,2: Font, S11 W700 , Tahoma ;Segoe UI  Verdana
  Gui,2: Add, Text , x26 y68 w100 h50 cFFFFFF vShow_alarm Center , %alarm_text%
  Gui,2: Font, S8 W700 , Segoe UI
  Gui,2: Add, Text , x36 y100 w80  cCCCCCC valarm_time Center , %alarm_time%	
  Gui,2: Font, S8 cD0D0D0
  Gui,2: Add, Text , x130 y1 w30 h20 gexit  , `   X      
  Gui,2: Font, S8 W400 cD0D0D0, Segoe UI
  ;Gui,2: Add, Text , x128 y128 w40 vt_left  ,  
  Gui,2: Add, Text , x100 y128 w20 vt_left Right ,  
  Gui,2: Add, Text , x122 y128 w30 c413700 vt_left0 , 
  Gui,2: Font, S10 W700 , Tahoma
  ;Gui,2: Add, Text , x61 y125 w30 cFFFFFF gexit , Close
  Gui,2: Add, Text , x68 y126 w30 cFFFFFF gexit , OK
  ;Gui,2:Add,Groupbox,cD0D0D0 x62 y119 w28 h26
  Gui,2: Hide

  Gui,2:Show,  w150 h150  NA, Show_alarm - Drozd 
  

  Winset, Transparent,200, Show_alarm - Drozd
  ;WinSet, Style, -0xC00000,Show_alarm - Drozd ; COMPLETELY remove window border
  
  SetTimer, time_date, 1000
  ;GuiControl,1:, t_left0, / %time_s%  
  play_music(loudness)
  
  OnMessage(0x203,"WM_LBUTTONDBLCLK")
  OnMessage(0x201, "WM_LBUTTONDOWN") ; movable borderless window     
  OnMessage(0x200, "WM_MOUSEMOVE")
return


play_music(level){
  global alarm_sound,  loudness_start
  ;SoundPlay, C:\AutoHotkey Scripts\sound\flute.mp3   
  ;SoundGetWaveVolume, loudness_start
  SoundGet, loudness_start
  SoundPlay, %alarm_sound%
  play_loudness(level)  
  ;SoundPlay, %sound_file%, Wait
}

play_loudness(n){
 loop, %n% {
  ;SoundSetWaveVolume,  % A_Index*5
  SoundSet, % A_Index*10
  Sleep, 200
   ;SoundSetWaveVolume,  % A_Index*2*5
   ;Sleep, 200
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
play_music(loudness)
Gui,2: -AlwaysOnTop	
return

MenuHandler:
  alarm_sound:= A_ThisMenuItem
  ;Gosub,TIMER
return

Combo:
GuiControlGet,tekst,1:, ComboBox1
;MsgBox,,, % tekst
if(tekst=="Mecz_timer"){
  GuiControl, , Checkbox1 , 0
  alarm_sound:="F:\1.Music\alarm\Iron Maiden-tomorrow.mp3"
  ;alarm_sound:="F:\1.Music\alarm\Metallica - Welcome Home.mp3"
  ;alarm_sound:="F:\1.Music\alarm\Metallica - Orion.mp3"

  Gosub, timer
}
return


MenuAlarms: 
start_timer_7m:
start_timer_10m:
start_timer_15m:
start_timer_20m:
start_timer_30m:
start_timer_60m:
	RegExMatch(A_ThisLabel,"i)_(\d+)m", t)
   TIME:=t1
     alarm_text:= "• Timer •`n" t1 " min."
  GuiControl,1:Text, ComboBox1, %alarm_text%
   Gui, Submit, Nohide
   Gui, Destroy
  Gosub, show_time
  #SingleInstance off
  
  TIME:=t1
  FormatTime, start_timer,, HH:mm:ss  
  seconds:= StrLen(TIME)<4 ? TIME * 60 : SubStr(TIME, -1 ) * 60 +  SubStr(TIME, 1,2 ) * 3600
  TIME_min:= StrLen(TIME)<4 ? TIME : SubStr(TIME, 1,2 ) "h " SubStr(TIME, -1 ) ""
  time_count= %seconds%  
  start_time:=A_TickCount
  SetTimer, count_time, 998  ;1000
  SetTimer, compare_time, 1000
return


3GuiContextMenu:
Menu, ContextMenu, Show, %A_GuiX%, %A_GuiY%
Return



Open_ini:
Run, %settings_ini%
return

guiclose:
exitapp

Exit_Gui:
;MsgBox,,, `            Exit Alarm Timer `n(after double click on tray icon) ,1
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


OnExit, exit
return

;Esc::
exit:
SoundSet, % loudness_start
ExitApp


