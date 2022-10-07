#SingleInstance force
#NoEnv
;#NoTrayIcon
SetBatchLines, -1
;forum upd Oct12 2018
/*  
=== Drozd monitor
-- Date , time ; time up = time since last restart
-- CPU usage graph; CPU usage bar ; total RAM memory usage bar
-- top left circle = toggle always on top
--
=== Extended
-- arrow= toggle between extended and simple GUI
-- 
-- CPU usage bars for 2 chosen programs 
-- click on bars to enter name or PID then press Enter
-- memory usage bar of third process ; click on bar to enter name or PID then press Enter
-- 
-- bottom right: time idle counter , time left from last keyboard, mouse input (if bigger than 60sec - last time idle is shown below)
-- 
-- bottom squares: left on/off CPU monitoring of 2 processes ; right: on/off time idle counter
=== 
Gdip library must be included by tic;	https://autohotkey.com/board/topic/29449-gdi-standard-library-145-by-tic/
; https://github.com/tariqporter/Gdip/blob/master/Gdip.ahk
; used CPU functions linked (by SKAN) ; NVIDIA GPU temperature by jNizM
*/

help=
(
● CPU usage bars for 2 chosen programs 
● click on bars to enter name or PID then press Enter
● memory usage bar of third chosen process ; click on bar to enter name or PID then press Enter

● by default the first extra bar shows processes with highest CPU use from a test list (created in .ini file) or from all processes (context menu option)
● mouse over bars shows the full name

● time up - time since last restart
● top left circle - toggle always on top
● arrow - toggle between extended and simple GUI
● bottom squares - left on/off CPU monitoring of 2 processes ; right: on/off time idle counter
● bottom right - time idle counter , time left from last keyboard, mouse input (if bigger than 60sec - last time idle is shown below)
● F4 - show GUI , or click on tray icon

● more options in the right click context menu:  GUI color; save position for next launch
● click on the date to go to the saved position  

● click on text control above small bars: GPU temperature (for NVIDIA)


)


prog_choice_1:= "explorer.exe" 
prog_choice_2:="opera.exe" 
prog_choice_3:="opera.exe" 

global progr_1:= prog_choice_1
global progr_2:= prog_choice_2
global progr_3_mem:= prog_choice_3
global multi_prog:=1  ;0 - progr_2 , 2 - from list; 1 - from all
global proc_list:= Object()			

global progr_1_PID, progr_2_PID, progr_1_n, progr_2_n
global toggle_big:=1 , bars_on:=0 , toggle_idle:=0


;===============================
progr_1_n:=get_prog_name(progr_1) 
progr_2_n:=get_prog_name(progr_2) 

global set_progr_1:=0 , set_progr_2:=0 , set_prog_3:=0

get_prog_name(progr,len:=5){
	progr:=RegExReplace(progr,"i)\.exe","")
	progr:=SubStr(progr,1,len) ; "."
	return progr
}

;===============================
global grid_h:=29 , grid_w:=121
global array_cpu := Object() 

Loop, 120 {
		array_cpu[A_Index]:=29
} 
;===============================


;MsgBox,4096,, %  A_IsCompiled "`n"  A_ScriptFullPath

Menu, Tray, Icon, shell32.dll, 58 ;208  ; Win 8   
;Menu, Tray, Icon, shell32.dll, 47   ; 95 ;22  ;134
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
;Menu, Tray, Default, Exit ; double click tray icon to exit

Menu, ContextMenu, Add, On Top, OnTop
Menu, ContextMenu, Icon, On Top, Shell32.dll, 248
Menu, ContextMenu, Add, Save current position , save_position
Menu, ContextMenu, Icon, Save current position , Shell32.dll, 124
Menu, ContextMenu, Add,
/* Menu, ContextMenu, Add, Extended On/Off  ,bigger
Menu, ContextMenu, Add, Extra bars On/Off  ,bars_extra_on
Menu, ContextMenu, Add, Idle times On/Off, idle_on 
*/

Menu, Submenu2, Add, Extended On/Off  ,bigger
Menu, Submenu2, Add,
Menu, ContextMenu, Add, Save current position , save_position
Menu, ContextMenu, Icon, Save current position , Shell32.dll, 124

Menu, Submenu2, Add, Extra bars On/Off  ,bars_extra_on
Menu, Submenu2, Add, Idle times On/Off, idle_on
Menu, ContextMenu, Add, Extended, :Submenu2
Menu, Submenu3, Add, From all processes , high_CPU_all
Menu, Submenu3, Add, From a list , high_CPU_list
Menu, ContextMenu, Add, Show highest CPU use , :Submenu3 

Menu, Submenu4, Add, Open settings file , Open_ini
Menu, Submenu4, Icon, Open settings file, Shell32.dll, 70
Menu, Submenu4, Add, List of processes , show_proc_list_
;Menu, Submenu4, Add,
;Menu, Submenu4, Add, Help , show_help
;Menu, Submenu4, Icon, Help , shell32.dll, 24
Menu, ContextMenu, Add, more, :Submenu4
Menu, ContextMenu, Add,
Menu, Submenu1, Add, Black , set_bgrd_black
Menu, Submenu1, Add, Steel , set_bgrd_steel
Menu, Submenu1, Add, Blue , set_bgrd_blue  
Menu, Submenu1, Add, Green , set_bgrd_green
Menu, Submenu1, Add, 
Menu, Submenu1, Add, Funny style: dots, set_bgrd_style_dots
Menu, Submenu1, Add, Funny style: dots 2, set_bgrd_style_dots2
Menu, Submenu1, Add, Funny style: bricks, set_bgrd_style_bricks 
Menu, Submenu1, Add, 
Menu, Submenu1, Add, Reset background, reset_bgrd
Menu, ContextMenu, Add, Background color (Restart), :Submenu1 
;Menu, ContextMenu, Icon, Background color (Restart), imageres.dll,181 

;Menu, ContextMenu, Add, Open settings file , Open_ini
;Menu, ContextMenu, Icon, Open settings file, Shell32.dll, 70
Menu, ContextMenu, Add,
Menu, ContextMenu, Add, Help , show_help
Menu, ContextMenu, Icon, Help , shell32.dll, 24
Menu, ContextMenu, Add, Restart, Reload
Menu, ContextMenu, Add, Exit, Exit


SetWorkingDir %A_ScriptDir%


If !pToken := Gdip_Startup()
{
	MsgBox, No Gdiplus 
	ExitApp
}

OnExit, Exit



	bgrd_grad_black:="0xff0F0F0F|0xff222222|25"
	bgrd_grad_steel:="0xff222832|0xff323F4B|25"  ;"0xff1A2333|0xff2C3B54|25" 
	bgrd_grad_blue:="0xff1A2333|0xff2C3B54|25" ;"0xff012243|0xff13365A|25" 	
	bgrd_grad_green:="0xff00290C|0xff1C4527|25" ;"0xff002D0D|0xff033A13|25"
	bgrd_grad:=bgrd_grad_black
	
	; clock bgrd color
	clock_grad_black:="0xff383838|0xff0F0F0F|30"
	clock_grad_steel:="0xff3E4E5C|0xff12151C|26" ;"0xff314464|0xff1A2333|30"  
	clock_grad_blue:="0xff314464|0xff1A2333|26" ;"0xff13365A|0xff012243|20" 
	clock_grad_green:="0xff044016|0xff00230A|40" ;"0xff1C4527|0xff00290C|30"
	
	clock_bgrd_grad:=clock_grad_black 



	;memory bar colors
	grad_col_blue:="0xff031661|0xff008FDC|6"  ,	grad_col_blue_2:="0xff012243|0xff008FDC|6"
	grad_col_steel:="0xff12304E|0xff356696|6" , grad_col_steel_2:="0xff143268|0xff215EC7|6" ;"0xff294372|0xff356C96|6"
	grad_col_green:="0xff004614|0xaa01DC3F|6"
	mem_grad_col:=grad_col_steel

;===============================

settings_ini := "Drozd monitor.ini"

test_list := Object() 

IfNotExist, %settings_ini%
{
		test_list:=["AutoHotkey.exe","explorer.exe", "opera.exe","palemoon.exe","firefox.exe","vlc.exe","mplayerc.exe","sidebar.exe"]	
		Loop, % test_list.Length() {
			IniWrite, % test_list[A_Index]	, %settings_ini%, Monitor, program%A_Index%
    }
}


IniRead, ask, %settings_ini%, Window , asked for startup
if(!ask || ask="ERROR"){	
	MsgBox, 4100, , Run "CPU monitor" when computer starts?`n`n`n(link will be created in:`n%A_AppDataCommon%\Microsoft\Windows\Start Menu\Programs\Startup)
	IfMsgBox, Yes
	{	
		;start_up_link:="C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\" A_ScriptFullPath
		start_up_link:=A_AppDataCommon "\Microsoft\Windows\Start Menu\Programs\Startup\" "Drozd_CPU_monitor_ext.lnk"
		FileCreateShortcut, %A_ScriptFullPath%, %start_up_link%, %A_WorkingDir%, , , %A_AhkPath%, ,2
		IniWrite, 1	, %settings_ini%, Window, asked for startup
	}else{
		IniWrite, 1	, %settings_ini%, Window, asked for startup
	}
}	

IniRead, bigger, %settings_ini%, Window , bigger   ;bigger:
if(bigger!="ERROR"){
	if(bigger=1 || bigger=0)
		toggle_big:=bigger
}


		Loop, 10 {
			IniRead, key	, %settings_ini%, Monitor, program%A_Index%
       if (key!="ERROR" && key!="")
            test_list[A_Index]:=key
    }
		
		
program_list:="name or PID|"

Loop, 20 {		  
  IniRead, key, %settings_ini%, Monitor, program%A_Index%
  if (key!="ERROR" && key!=""){
	 program_list:=program_list "|" key 	 
  }  
}
program_list:=RegExReplace(program_list,"i)\|$","")



global programs_query:=""
	Loop, % test_list.Length(){		
		if(A_Index==1)
			programs_query:= "Name='" test_list[A_Index] "'"
			else
			programs_query:= programs_query " OR Name='" test_list[A_Index] "'" 	 
  }  

;=================

IniRead, GUI_bgrd, %settings_ini%, Window, GUI_background	

if(GUI_bgrd!="ERROR" && GUI_bgrd!=""){
			bgrd_grad:=GUI_bgrd
}else{
	IniWrite, %bgrd_grad%	, %settings_ini%, Window, GUI_background
}

IniRead, clock_GUI_bgrd, %settings_ini%, Window , GUI_background_clock	

if(clock_GUI_bgrd!="ERROR" && clock_GUI_bgrd!=""){
			clock_bgrd_grad:=clock_GUI_bgrd
}else{
	IniWrite, %clock_bgrd_grad%	, %settings_ini%, Window, GUI_background_clock
}

;===============================

SysGet, MonitorWorkArea, MonitorWorkArea, 1
pos_x:=A_ScreenWidth - 140
pos_y:= MonitorWorkAreaBottom -420


	IniRead, pos_x_saved, %settings_ini%, window position, x	
	IniRead, pos_y_saved, %settings_ini%, window position, y	

if(pos_x_saved!="ERROR" && pos_x_saved!="" && pos_y_saved!="ERROR" && pos_y_saved!=""){
		if(pos_x_saved<A_ScreenWidth-120 && pos_y_saved<A_ScreenHeight-140){
			pos_x:=pos_x_saved
			pos_y:=pos_y_saved
		}
}


;===============================

	
Gui,1: +ToolWindow -border  +HwndGuiHwnd
Gui,1: +AlwaysOnTop	
WonTop:=1 
Gui,1: -DPIScale
Gui,1:Color, 120F00

Gui, Add, Picture, x0 y0 h224 w135 vbgrd 0xE, 
GoSub, bgrd

Gui, 1: Add, Picture, x0 y0 w134 h15 vramkaT 0xE, 
Gui,1: Font, S7 w700 cE1E1E1 , Segoe UI ; Tahoma 
Gui,1: Add, Text , x18 y1 w100 gDoubleClick  BackgroundTrans  Center, Drozd CPU Monitor  ;gGoToSavedPos

Gui,1: Font, S7 w700 cD0D0D0 , Segoe UI ;
Gui,1: Add, Text , x122 y1 w10 h10 cD0D0D0 gexit BackgroundTrans Center ,  X 

Gui,1: Font, S6 w700 c9C9C9C , Segoe UI
Gui,1: Add, Text , x3 y0  c676767 vonTop_off gonTop BackgroundTrans,% Chr(9675) ; ○ 
Gui,1: Font, S9
Gui,1: Add, Text , x3 y+-13  c676767 vonTop_on gonTop BackgroundTrans, % Chr(9679) ; ● 
GuiControl, Hide, onTop_off

Gui, 1: Add, Picture, x6 y22 w122 h31 0xE vGrid_img, 
Gui,1: Font, S6 w700 cD0D0D0 , Tahoma ;Arial

Gui,1: Add, Text , 		x9 y65 BackgroundTrans Center, CPU
Gui,1: Add, Text , 		x9 y85 BackgroundTrans Center, RAM
Gui,1: Add, Picture, x37 y62  w90 h14 0xE vProgressBar2
Gui,1: Add, Picture, x37 y83  w90 h12 0xE vProgressBar3

Gui, 1: Add, Picture, x22 y105 w94 h42 vramka BackgroundTrans 0xE,  
GoSub, ramka

Gui,1: Font, S8 w700 cE1E1E1 , Arial  ;Segoe UI ;
Gui,1: Add, Text , x25 y107 w88 cE6B375 vtime_d  BackgroundTrans  Center,
;Gui,1: Font, S7 w700 cE1E1E1 , Arial  ;Segoe UI ;
;Gui,1: Add, Text , x25 y108 w86 cE6B375 vtime_d  BackgroundTrans  Center, 
Gui,1: Font, S11 w700 cF4F4F4 , Segoe UI 
Gui,1: Add, Text , x28 y121 w50 cE1E1E1 vtime_t1  BackgroundTrans  Right, 
Gui,1: Font, S8 w700 cE1E1E1, Segoe UI 
Gui,1: Add, Text , x+2 y125 w22 cF4F4F4 vtime_t2  BackgroundTrans  Left, 
 

;Gui,1: Add, Picture, x117 y148 w16 h16 vbig_ gbigger BackgroundTrans Icon249 AltSubmit, shell32.dll ;
Gui, 1: Add, Picture, x117 y149  w14 h14 vbig_switch gbigger BackgroundTrans 0xE ,
Gdip_icon_switch(big_switch)


Gui,1: Font, S7 w700 cD0D0D0 , Arial
Gui,1: Add, Text , x43 y151 w74 cA3A1BC vtime_on   BackgroundTrans Left, 
Gui,1: Font, S6 w700 cD0D0D0 , Arial
Gui,1: Add, Text , x8 y152  cA3A1BC vup_t BackgroundTrans  Center, up time:  ;time_on:
GuiControl, Hide, up_t


;Gui,1: Font, S7 w700 cD0D0D0 , Arial
;Gui,1: Add, Text , x4 y149 w110 cA3A1BC vtime_on  BackgroundTrans  Center, 

Gui,1: Font, S7 w400 cE9C45D , Arial  ; Segoe UI  cE1E1E1 c7F869F
Gui,1: Add, Text , x4 y162 w128   vproc_info gshow_info BackgroundTrans , 

;bigger:

Gui, 1: Add, Picture, x5 y175 w70 h12 vstat20 gshow_Edit 0xE , 
Gui, 1: Add, Picture, x5 y189 w70 h12 vstat21 gshow_Edit 0xE , 
Gui,1: Font, S7 w700 cD0D0D0 ,Segoe UI
Gui,1: Add, Text , x31 y205 w44 Right vprogr_3_mem gshow_Edit BackgroundTrans , 


Gui,1: Font, S8 w400 c000000 ,Segoe UI
Gui, Add, ComboBox,x20 y202 w98  vedit_1 , %program_list%
GuiControl, Hide, edit_1


Gui,1: Font, S8 w700 cD0D0D0 , Tahoma
Gui,1: Add, Text , x91 y174 w30 vresult BackgroundTrans Center, 
Gui,1: Add, Text , x91 y188 w30 vresult2 BackgroundTrans Center, 


Gui,1: Font, S5 w700 c7F869F , Segoe UI  
Gui,1: Add, Text , x7 y209 vSwitch_bars_on gbars_extra_on BackgroundTrans, % Chr(9609) ;▉ 
Gui,1: Font, S6 
Gui,1: Add, Text , x6 y207 vSwitch_bars_off gbars_extra_on BackgroundTrans, % Chr(9744) ;☐ 

Gui,1: Font, S6 w700 c7F869F , Segoe UI  
Gui,1: Add, Text , x120 y207 vSwitch_idle_off gidle_on BackgroundTrans, % Chr(9744) ;☐ 
Gui,1: Font, S5 
Gui,1: Add, Text , x121 y209 vSwitch_idle_on gidle_on BackgroundTrans,% Chr(9609) ; ▉ 


GuiControl, Hide, Switch_bars_off
GuiControl, Hide, Switch_idle_off



/* Gui, 1: Show, x%pos_x% y%pos_y% w128 h160  , Drozd_monitor_ext
WinSet, Style, -0xC00000, Drozd_monitor_ext ; COMPLETELY remove window border
;Winset, Transparent,200, Drozd_monitor_ext  
 */
;Gui,1: -0xC00000 
Gui,1: -caption
Gui,1: Show, Hide x%pos_x% y%pos_y% w134 h166  , Drozd_monitor_ext
DllCall( "AnimateWindow", "Int", GuiHwnd, "Int", 200, "Int", 0x00000004 )
;DllCall( "AnimateWindow", "Int", GuiHwnd, "Int", 300, "Int", 0x00000010 )


OnMessage(0x201, "WM_LBUTTONDOWN") ; movable borderless window   
OnMessage(0x404, "AHK_NOTIFYICON") ;click tray icon to show
OnMessage(0x100, "WM_KEYDOWN")
OnMessage(0x200, "WM_MOUSEMOVE") 

DllCall("RegisterShellHookWindow", UInt,A_ScriptHwnd )
MsgNum := DllCall("RegisterWindowMessage", Str,"SHELLHOOK")
OnMessage(MsgNum,"ShellMessage")

;if(toggle_big=1) 
	GoSub, bigger	

	GoSub, memory_all
	GoSub, time_on
	GoSub, time_date
	GoSub, CPU_use
	
	GoSub, grid_CPU
	
	GoSub, start_timers
	
	
	;===== off at start
	GoSub, onTop ;off
	GoSub, idle_on ;off

return


start_timers:
	Settimer, time_date ,1000
	Settimer, time_on ,30000

	Settimer, CPU_use ,1000
	Settimer, memory_all ,3000

	Settimer, grid_CPU ,1000
return

ShowExtraBars_timer:  ; ShowExtraBars:
	Settimer, ShowExtraBars ,Off		
	Settimer, ShowExtraBars ,1000		
return


;=============================



WM_LBUTTONDOWN(){
	if (A_Gui=1){
	PostMessage, 0xA1, 2    ; movable borderless window 
	}
}

AHK_NOTIFYICON(wParam, lParam){ ;click tray icon to show
    if (lParam = 0x202) {       ; WM_LBUTTONUP
				Gui,1:Show  				
    }
}

WM_KEYDOWN(wParam, lParam){	
    if(A_Gui = 1 && wParam = 13){ ; VK_ENTER := 13
			Gosub, Edit_input
    }else	if(A_Gui = 1 && wParam = 27){ ; Esc
			GuiControl, Hide, edit_1
			GuiControl, Show, progr_3_mem
		}
}


ShellMessage(wParam,lParam){
	Critical
  global proc_list, test_list

	if(wParam=1){   ;  HSHELL_WINDOWCREATED = 1  ; new program started
    WinGet, PID, PID , ahk_id %lParam%
    WinGet, pname, ProcessName,ahk_id %lParam%  
		id:=lParam
			if(multi_prog==1){			;"all"
				win:=show_proc_info(PID)
				pname:=win[1], cmd_l:=win[2]
				proc_list[PID]:= [pname,cmd_l,id] 
			}else if (multi_prog==2 && array_contains(test_list, pname) ){ ; list
				win:=show_proc_info(PID)
				pname:=win[1], cmd_l:=win[2]
				proc_list[PID]:= [pname,cmd_l,id] 
			}
  }
	
  if(wParam=2){ ; HSHELL_WINDOWDESTROYED=2 ; program stopped
    WinGet, PID, PID , ahk_id %lParam%
    WinGet, pname, ProcessName,ahk_id %lParam%
		if(!array_contains(test_list, pname)){
			;proc_list.Delete(PID)
		}
  } 
}

;======================================

WM_MOUSEMOVE(){
		global GuiHwnd , mouse_over_show 
		global last_biggest, last_big_param  , progr_1_param, progr_2_param , progr_3_param
		global progr_3_mem, progr_2, progr_1
		MouseGetPos,, ,winID,control 
		if(multi_prog!=1 && multi_prog!=2){
			if(winID==GuiHwnd && control=="Static20"){	
				if(InStr(progr_1,"autohotkey.exe") || InStr(progr_1,"opera.exe") && progr_1_param){
					tekst:=progr_1_param
					GuiControl,, proc_info,` %tekst%
				}else
				GuiControl,, proc_info, `  %progr_1%
			}
		}else{
			if(winID==GuiHwnd && control=="Static20"){			
				mouse_over_show:=1
			}else{
				mouse_over_show:=0
			}
		}
		
		
		if(winID==GuiHwnd && control=="Static21"){		
			if((InStr(progr_2,"autohotkey.exe") || InStr(progr_2,"opera.exe")) && progr_2_param){
				tekst:=progr_2_param
				GuiControl,, proc_info,` %tekst%
			}else
			GuiControl,, proc_info, `  %progr_2%
		}

		if(winID==GuiHwnd && control=="Static22"){
			if(InStr(progr_3_mem,"autohotkey.exe") || InStr(progr_3_mem,"opera.exe") && progr_3_param){
				tekst:=progr_3_param
				GuiControl,, proc_info, mem: %tekst%				
			}else			
			GuiControl,, proc_info, mem: %progr_3_mem%
		}

		if(control!="Static20" && control!="Static21" && control!="Static22" && control!="Static19"){
			GuiControl,, proc_info, 
		}
		if(winID!=GuiHwnd){
			mouse_over_show:=0
			GuiControl,, proc_info, 
		}		

		if(winID==GuiHwnd && control=="Static17"){
			GuiControl, Show, up_t
		}else{
			GuiControl, Hide, up_t
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

	Gdip_SetProgress(ProgressBar2, CPU2 ,grad_col , 0xff2C2C2C , CPU "`%","x0p y2p s76p Center cffEEEEEE r5 Bold")
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
	
	Gdip_SetProgress(ProgressBar3, GMSExM04, mem_grad_col, 0xff2C2C2C , GMSExM04 "`%","x0p y2p s78p Center cffEEEEEE r5 Bold")
/*  	if(CPU>60){
		grad_col_m:=grad_col_blue
	}else{
		grad_col_m:=grad_col_steel
	}	
	Gdip_SetProgress(ProgressBar3, GMSExM04, grad_col_m, 0xff2C2C2C , GMSExM04 "`%","x0p y2p s78p Center cffEEEEEE r5 Bold")
	  */
return

memory_progr_3_mem:
	if(set_prog_3==0){
		Process, Exist, %progr_3_mem%
		prog_3_PID := Errorlevel
		
		if(prog_3_PID){
			mem_3:=GetProcessMemoryInfo(prog_3_PID,"M")				
			GuiControl ,1:, progr_3_mem,  %mem_3% 
		}else{
			GuiControl ,1:, progr_3_mem, ;Ø
		}				
	}else{
		mem_3:=GetProcessMemoryInfo(prog_3_PID,"M")	
		GuiControl ,1:, progr_3_mem,  %mem_3% 
	}
return


grid_CPU:
Gdip_Set_Grid(Grid_img, 0xffE36524, 0xFF131313) ;0xff2C2C2C
return



;============================================ 
 
ShowExtraBars:
	if(set_progr_2==0){
		Process, Exist, %progr_2% 
		progr_2_PID := errorLevel 
	}
		
 	if(!progr_2_PID){
		Gdip_SetProgress(stat21,0, "0xff4C2700|0xffFD8300|6", 0xff2C2C2C , " Ø " ,"x0p y2p s80p Center cffEEEEEE r5 Bold","Arial") 
	}else{		
		progr_2_CPU := GetProcessTimes(progr_2_PID)
		progr_2_CPU:=(progr_2_CPU<0) ? 0 : Round(progr_2_CPU,0)
		progr_2_CPU_2 :=manip(progr_2_CPU)

		if(progr_2_CPU>50){
			grad_col:="0xff4C2700|0xffFD1900|6"
		}else{
			grad_col:="0xff4C2700|0xffFD8300|6"
		}
		
		Gdip_SetProgress(stat21, progr_2_CPU_2, grad_col, 0xff2C2C2C , progr_2_n " " progr_2_CPU "`%","x19p y3p s72p Left cffEEEEEE r5 Bold","Arial") 

	}		
		
	if(multi_prog==1 || multi_prog==2){
		arr:=highest_CPU()		
		high_CPU:=arr[2]
		high_CPU:=(high_CPU<0) ? 0 : Round(high_CPU,0)
		high_CPU_2 :=manip(high_CPU)
		high_CPU_name:=get_prog_name(arr[1],5)
			if(high_CPU_name=="")
				high_CPU:=0

			if(high_CPU>=50){
				grad_col:="0xff4C2700|0xffFD1900|6"
			}else{
				grad_col:="0xff4C2700|0xffFD8300|6"
			}	
			
			Gdip_SetProgress(stat20, high_CPU_2, grad_col, 0xff2C2C2C , high_CPU_name " " high_CPU "`%","x4p y3p s72p Center cffEEEEEE r5 Bold","Arial")
			
	}else{
			if(set_progr_1==0){
				Process, Exist, %progr_1% 
				progr_1_PID := errorLevel 
			}
			
			if(!progr_1_PID){
			Gdip_SetProgress(stat20, 0, "0xff4C2700|0xffFD8300|6", 0xff2C2C2C , " Ø " ,"x0p y2p s80p Center cffEEEEEE r5 Bold","Arial")
			}else{
				progr_1_CPU := GetProcessTimes(progr_1_PID)
				progr_1_CPU:=(progr_1_CPU<0) ? 0 : Round(progr_1_CPU,0)	
				progr_1_CPU_2 :=manip(progr_1_CPU)
	
				if(progr_1_CPU>50){
					grad_col:="0xff4C2700|0xffFD1900|6"
				}else{
					grad_col:="0xff4C2700|0xffFD8300|6"
				}
				
				Gdip_SetProgress(stat20, progr_1_CPU_2, grad_col, 0xff2C2C2C , progr_1_n " " progr_1_CPU "`%","x19p y3p s72p Left cffEEEEEE r5 Bold","Arial")
			}
	}
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
	
	Gdip_DeleteBrush(pBrushFront), Gdip_DeleteBrush(pBrushBack) , Gdip_DeletePen(pPen) , Gdip_DeletePath(pPath)
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
		Gdip_FillRectangle(G, pBrushFront,-1, -1,  Posw*(Percentage/100)+1, Posh+1)
	;========
	}else{
		pBrushFront := Gdip_BrushCreateSolid(Foreground)
		Gdip_FillRectangle(G, pBrushFront, 0, 0, Posw*(Percentage/100), Posh)
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
	}else if(bgrd_style=="dots2"){	
		Gdip_Set_bgrd(bgrd, bgrd_grad,35) ; dots
	}else if(bgrd_style=="bricks"){
		Gdip_Set_bgrd(bgrd, bgrd_grad,39) ; bricks
	}else{
		Gdip_Set_bgrd(bgrd, bgrd_grad) 
	}
return


ramka:	
	Gdip_Set_bgrd(ramkaT,"0xff383D46|0xff1E2126|8",0)
	Gdip_Set_bgrd(ramka,clock_bgrd_grad)
return

;=============================


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


Gdip_Set_ramka(ByRef Variable, Background=0x00000000,Hatch=0){
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

		if(Hatch=0){
			pBrushFront := Gdip_CreateLineBrushFromRect(0, 0, 1, size, grad_color_rim, grad_color_mid ,1) 
		}else{
			pBrushFront :=Gdip_BrushCreateHatch(grad_color_rim, grad_color_mid, Hatch) 
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


Gdip_icon_switch(ByRef Variable, col1:=0xff7C95EF,col2:=0xff52639F,col3:=0xff3A4672,flip:=0,Background:=0xFF131313){
	GuiControlGet, Pos, Pos, Variable
	GuiControlGet, hwnd, hwnd, Variable  
	
	pBitmap := Gdip_CreateBitmap(PosW, PosH), G := Gdip_GraphicsFromImage(pBitmap), Gdip_SetSmoothingMode(G, 4)		
	
		;pBrushBack := Gdip_BrushCreateSolid(Background)	
		;Gdip_FillRectangle(G, pBrushBack,-1, -1, Posw+1, Posh+1)	
	pPen1:=Gdip_CreatePen(col1, 1), pPen2:=Gdip_CreatePen(col2, 1), pPen3:=Gdip_CreatePen(col3, 1)

	Gdip_DrawLine(G, pPen1, Round(PosW*0.15) ,Round(PosH*0.33) , Round(PosW*0.86) ,Round(PosH*0.33))
	Gdip_DrawLine(G, pPen2, Round(PosW*0.25) ,Round(PosH*0.5) , Round(PosW*0.75) ,Round(PosH*0.5))
	Gdip_DrawLine(G, pPen3, Round(PosW*0.40) ,Round(PosH*0.67) , Round(PosW*0.63),Round(PosH*0.67))
	
	Gdip_ImageRotateFlip(pBitmap,flip)
	hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
	SetImage(hwnd, hBitmap)
	
	Gdip_DeletePen(pPen1), Gdip_DeletePen(pPen2), Gdip_DeletePen(pPen3)
	Gdip_DeleteGraphics(G), Gdip_DisposeImage(pBitmap), DeleteObject(hBitmap)
	Return, 0
}



;==================================

GetProcessMemoryInfo(PID,Units:="M") {
	size := (A_PtrSize=8 ? 80 : 44)
	VarSetCapacity(mem,size,0)
	memory := 0	
	hProcess := DllCall("OpenProcess", UInt,0x400|0x0010,Int,0,Ptr,PID, Ptr)
	if (hProcess){
		if (DllCall("psapi.dll\GetProcessMemoryInfo", Ptr, hProcess, Ptr, &mem, UInt,size))
			memory := Round(NumGet(mem, (A_PtrSize=8 ? 16 : 12), "Ptr")) 
		DllCall("CloseHandle", Ptr, hProcess)
    
    if(Units == "B"){
        memory := memory  " B"
    }else if(Units == "K"){
        memory := Round(memory/1024)  " KB" 
    }else if(Units == "M"){
        memory := Round(memory / 1024 / 1024)	 " MB"	
    }
	}         
	return % memory
}


CPULoad(){ ; By SKAN, CD:22-Apr-2014  ; http://ahkscript.org/boards/viewtopic.php?p=17166#p17166
  Static PIT, PKT, PUT                          
  IfEqual, PIT,, Return 0, DllCall( "GetSystemTimes", "Int64P",PIT, "Int64P",PKT, "Int64P",PUT )

  DllCall( "GetSystemTimes", "Int64P",CIT, "Int64P",CKT, "Int64P",CUT )
, IdleTime := PIT - CIT,    KernelTime := PKT - CKT,    UserTime := PUT - CUT
, SystemTime := KernelTime + UserTime 

  Return ( ( SystemTime - IdleTime ) * 100 ) // SystemTime,    PIT := CIT,    PKT := CKT,    PUT := CUT 
}



GlobalMemoryStatusEx() { ;https://autohotkey.com/board/topic/116074-get-memory-info/ by jNizM
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
 
 
;========================================= 


getProcessTimes(PID=0){  ; CPU usage of single process
	;https://autohotkey.com/board/topic/113942-solved-get-cpu-usage-in/
    static aPIDs := [], hasSetDebug
    ; If called too frequently, will get mostly 0%, so it's better to just return the previous usage 
    if aPIDs.HasKey(PID) && A_TickCount - aPIDs[PID, "tickPrior"] < 250
        return aPIDs[PID, "usagePrior"] 
   	; Open a handle with progr_QUERY_LIMITED_INFORMATION access
    if !hProc := DllCall("OpenProcess", "UInt", 0x1000, "Int", 0, "Ptr", pid, "Ptr")
        return -2, aPIDs.HasKey(PID) ? aPIDs.Remove(PID, "") : "" ; Process doesn't exist anymore or don't have access to it.
         
    DllCall("GetProcessTimes", "Ptr", hProc, "Int64*", lpCreationTime, "Int64*", lpExitTime, "Int64*", lpKernelTimeProcess, "Int64*", lpUserTimeProcess)
    DllCall("CloseHandle", "Ptr", hProc)
    DllCall("GetSystemTimes", "Int64*", lpIdleTimeSystem, "Int64*", lpKernelTimeSystem, "Int64*", lpUserTimeSystem)
   
    if aPIDs.HasKey(PID) ; check if previously run
    {
        ; find the total system run time delta between the two calls
        systemKernelDelta := lpKernelTimeSystem - aPIDs[PID, "lpKernelTimeSystem"] ;lpKernelTimeSystemOld
        systemUserDelta := lpUserTimeSystem - aPIDs[PID, "lpUserTimeSystem"] ; lpUserTimeSystemOld
        ; get the total process run time delta between the two calls 
        procKernalDelta := lpKernelTimeProcess - aPIDs[PID, "lpKernelTimeProcess"] ; lpKernelTimeProcessOld
        procUserDelta := lpUserTimeProcess - aPIDs[PID, "lpUserTimeProcess"] ;lpUserTimeProcessOld
        ; sum the kernal + user time
        totalSystem :=  systemKernelDelta + systemUserDelta
        totalProcess := procKernalDelta + procUserDelta
        ; The result is simply the process delta run time as a percent of system delta run time
        result := 100 * totalProcess / totalSystem
    }
    else result := -1

    aPIDs[PID, "lpKernelTimeSystem"] := lpKernelTimeSystem
    aPIDs[PID, "lpKernelTimeSystem"] := lpKernelTimeSystem
    aPIDs[PID, "lpUserTimeSystem"] := lpUserTimeSystem
    aPIDs[PID, "lpKernelTimeProcess"] := lpKernelTimeProcess
    aPIDs[PID, "lpUserTimeProcess"] := lpUserTimeProcess
    aPIDs[PID, "tickPrior"] := A_TickCount
    return aPIDs[PID, "usagePrior"] := result 
}

 
;============================================ 


high_CPU_all:  ; proc_list_all
	if(toggle_big==0)
		Gosub, bigger
	multi_prog:=1
	proc_list("all")
	Settimer, proc_list_clear ,Off
	Settimer, proc_list_clear , 120000
	
	Settimer, check_proc_list_All , % 10*60*1000
	Settimer, check_proc_list, Off
return

high_CPU_list:  ;proc_list
	if(toggle_big==0)
		Gosub, bigger
	multi_prog:=2
	proc_list(programs_query)
	Settimer, proc_list_clear ,Off
	Settimer, proc_list_clear ,120000
	
	Settimer, check_proc_list , % 10*60*1000
	Settimer, check_proc_list_All, Off
return

check_proc_list_All:
proc_list("all")
return

check_proc_list:
proc_list(programs_query)
return
;--------

proc_list(list:="all"){
	global proc_list :=Object()
	global i_p:=0
	WMI:=ComObjGet("winmgmts:")
;queryEnum := WMI.ExecQuery("SELECT * FROM Win32_Process WHERE Name = 'explorer.exe' OR Name ='AutoHotkey.exe'")._NewEnum

if(list=="all"){
	queryEnum := WMI.ExecQuery("Select * from Win32_Process")._NewEnum 
}else{
	queryEnum := WMI.ExecQuery("SELECT * FROM Win32_Process WHERE " programs_query )._NewEnum 
}
str:="", str2:="", j:=0
	While queryEnum[process] {
		WinGet, id, ID , % "ahk_pid " process.processId
	
		PID:=process.processId
		names:=proc_names(process.Name,process.CommandLine,process.ExecutablePath)
    proc_list[process.processId]:=[names[1], names[2],id ] 		
			i_p+=1	
	}
}

proc_list_clear:
	DetectHiddenWindows, On
	for PID in proc_list {
		Process, Exist , %PID%
		if(!ErrorLevel) {
			proc_list.Delete(PID)
		}	
	}
	DetectHiddenWindows, Off
return


highest_CPU(){
	global proc_list 
	global mouse_over_show, last_biggest, l_big_PID, last_big_param, last_biggestCPU
  global CPU_Array:= Object()
  global i_c:=0
		
	for PID in proc_list {
				if(proc_list[PID][2]=="nope"){ ; InStr(proc_list[PID][1],"opera.exe")  
					continue
				}		
				
      CPU:=Round(GetProcessTimes(PID),2)  				
				if(CPU<=0){ ; CPU:=0
					continue
				}
				
			CPU_Array[CPU]:=proc_list[PID] ; {1:pname,2:cmd_l,3:id}			
	}
	
	for CPU in CPU_Array    ;sort 
	{
		last_biggestCPU:=CPU, last_biggest_prog:=CPU_Array[CPU][1], last_big_param:=CPU_Array[CPU][2]
		i_c+=1
	}  
	
  last_biggest:=last_biggest_prog  

	if(last_biggest_prog=="")
			return ""
			
	if(mouse_over_show==1){
			if(InStr(last_biggest,"autohotkey.exe") || InStr(last_biggest,"opera.exe")){
				tekst:=last_big_param
				GuiControl,, proc_info,`  %tekst% 
			}else{
				tekst:=last_biggest		
				GuiControl,, proc_info,`  %tekst% 
			}		
	}
  return object(1,last_biggest_prog, 2, last_biggestCPU)    
}	


show_proc_info(PID){
    WMI := ComObjGet("winmgmts:")
    queryEnum := WMI.ExecQuery("Select * from Win32_Process where ProcessId=" PID)._NewEnum
    if queryEnum[process] {
 			cmd_l:=StrReplace(process.CommandLine, process.ExecutablePath, ""), cmd_l:=StrReplace(cmd_l, """", "")

    names:=proc_names(process.Name,process.CommandLine,process.ExecutablePath)
        return Object(1,names[1], 2, names[2])
        ;return Object(1,process.Name, 2, cmd_l) 
    }else
        return 0    
}


proc_names(pname,cmd_l,exe_l){

    if(InStr(pname,"autohotkey")){
        cmd_l:=StrReplace(cmd_l, exe_l, "") 
        cmd_l:=RegExReplace(cmd_l,"""","")
				arr:=StrSplit(cmd_l,"\") 
				cmd_l:=StrReplace(arr[arr.Length()],"""","")
        cmd_l:=StrReplace(cmd_l, ".ahk", "") 
        cmd_l:=Trim(cmd_l)

		}else	if(InStr(pname,"opera")){ ; Opera profile
        cmd_l:=StrReplace(cmd_l, exe_l, "") 
        cmd_l:=RegExReplace(cmd_l,"""",""), cmd_l:=Trim(cmd_l)
				cmd_l:=RegExReplace(cmd_l,"Opera_profile","Opera profile")
        if(cmd_l!=""){
          arr:=StrSplit(cmd_l,"\") 
          cmd_l:=StrReplace(arr[arr.Length()],"""","")
        }else {
					arr:=StrSplit(exe_l,"\") 
					cmd_l:=StrReplace(arr[arr.Length()-1],"""","")
					RegExMatch(cmd_l,"i)Opera(.+)", Op)
					cmd_l:= (Op) ? "Opera " Op1: "Opera.exe"
					
					if(!Op)
						cmd_l:=	"nope"
        }
 
        cmd_l:=RegExReplace(cmd_l,"""","")		
		}else	if(InStr(pname,"vlc")){
        ;cmd_l:=StrReplace(cmd_l, exe_l, "") 
        ;cmd_l:=RegExReplace(cmd_l,"""","")
				cmd_l:=""
		}else{
				cmd_l:=""
		} 
		cmd_l:=SubStr(cmd_l,1,21)
    return Object(1,pname, 2, cmd_l)
}
 
;============================================
 
bigger(){
	WinMove,  Drozd_monitor_ext, ,,,,222
	bars_extra_start()
	SetTimer, when_idle,3000	
	toggle_idle:=1	
	;OnMessage(0x200, "WM_MOUSEMOVE") 
}


smaller(){
	bars_extra_stop()
	SetTimer, when_idle,Off
	toggle_idle:=0, tim:=0
	Sleep 100
	WinMove,  Drozd_monitor_ext, ,,,,166	
	;OnMessage(0x200, "")  ; "WM_MOUSEMOVE" remove
}
 
bigger: 
	if(toggle_big=0){
		progr_1:= prog_choice_1
		progr_2:= prog_choice_2
		progr_1_n:=get_prog_name(progr_1) 
		progr_2_n:=get_prog_name(progr_2) 
		progr_1_n:= InStr(progr_1,"explorer")  ? "Expl." : progr_1_n
		progr_2_n:= InStr(progr_2,"Opera")  ? "Opera" : progr_2_n
		
		toggle_big:=1
		bigger()
		;IniWrite, 1, %settings_ini%, Window , bigger
	}else if(toggle_big=1){
		toggle_big:=0
		smaller()	
		;IniWrite, 0, %settings_ini%, Window , bigger		
	}
	tim:=0 
return


bars_extra_on:
	if (bars_on=1){		
		bars_extra_stop()
	}else if (bars_on=0){ 
		set_progr_1:=0 , set_progr_2:=0 , set_prog_3:=0
		progr_1:= prog_choice_1
		progr_2:= prog_choice_2
		progr_3_mem:= prog_choice_3
		progr_1_n:=get_prog_name(progr_1) 
		progr_2_n:=get_prog_name(progr_2) 

		bars_extra_start()		
	}
return

bars_extra_stop(){
		Settimer, ShowExtraBars ,Off
		Settimer, memory_progr_3_mem ,Off
		GuiControl ,1:, progr_3_mem, Ø
		Settimer, proc_list_clear ,Off
		global proc_list :=""
		global progr_1_param:="" , progr_2_param:= "", progr_3_param:=""
		
		GuiControl, Show, Switch_bars_off
		GuiControl, Hide, Switch_bars_on
		Gosub, freeze_bars_extra
		global bars_on:=0
}

bars_extra_start(){
		global bars_on:=1
		GuiControl, Show, stat20
		GuiControl, Show, stat21	
		
		if(multi_prog==2)
			Gosub, high_CPU_list
		if(multi_prog==1)
			Gosub, high_CPU_all
		 
		Gosub, ShowExtraBars_timer
		;Settimer, ShowExtraBars ,1000		
		Settimer, memory_progr_3_mem ,3000
		
		GuiControl, Hide, Switch_bars_off
		GuiControl, Show, Switch_bars_on

}

freeze_bars_extra:
		Gdip_SetProgress(stat20, 2, "0xff4C2700|0xffFD8300|6", 0xff2C2C2C , " Ø " ,"x0p y2p s80p Center cffEEEEEE r5 Bold","Arial")
		Gdip_SetProgress(stat21, 2, "0xff4C2700|0xffFD8300|6", 0xff2C2C2C , " Ø " ,"x0p y2p s80p Center cffEEEEEE r5 Bold","Arial") 
		Settimer, freeze_bars_extra_clear ,-100
return

freeze_bars_extra_clear:
	Settimer, freeze_bars_extra_clear ,Off
	GuiControl ,1:, progr_3_mem, 
	GuiControl, Hide, stat20
	GuiControl, Hide, stat21
	bars_on:=0	
return



idle_on:
	if(toggle_idle==1){
		toggle_idle:=0
		GuiControl, Show, Switch_idle_off
		GuiControl, Hide, Switch_idle_on
		
		SetTimer, when_idle, Off
		GuiControl ,1:, result, 
		GuiControl ,1:, result2,
		last:=""
	}else if(toggle_idle==0){
		toggle_idle:=1
		GuiControl, Hide, Switch_idle_off
		GuiControl, Show, Switch_idle_on	
		SetTimer, when_idle,3000			
	}
return

;============================================



show_Edit:
	Gui, Submit, NoHide
	GuiControl, Show, edit_1
	GuiControl, Hide, progr_3_mem
	
	GuiControl, Focus, edit_1
	SendMessage, 0x00B1, 0, % StrLen(edit_1), Edit1 , Drozd_monitor_ext ; EM_SETSEL ; select all

	Settimer, edit_hide , -11000
	enter_from:= A_GuiControl
return





Edit_input:
	Gui, Submit, Nohide	
	ControlGet, vis_, Visible,,Edit1, Drozd_monitor_ext
		if(vis_==0)
				return				

	if edit_1 is integer 
	{
		PID := edit_1
		;id:=WinExist("ahk_pid" PID)
		win:=show_proc_info(PID)
		pname:=win[1], cmd_l:=win[2]
		DetectHiddenWindows, On		
		id:=WinExist("ahk_exe " pname)
		DetectHiddenWindows, Off
		if(!id){
			ToolTip_("not found" , 2)
		}else{
			;WinGet, pname, ProcessName, ahk_pid %PID%			
			if(enter_from=="stat20"){
				multi_prog:=0
				;progr_1:=edit_1
				progr_1:=pname
				;progr_1_PID := PID	
				progr_1_n:=get_prog_name(pname) 	
				;StringLower, progr_1_n, progr_1_n
				progr_1_param:=	cmd_l	
				Gosub, ShowExtraBars_timer
			}else if(enter_from=="stat21"){
				progr_2:=edit_1
				progr_2:=pname
				;progr_2_PID := PID					
				progr_2_n:=get_prog_name(pname) 	
				;StringLower, progr_2_n, progr_2_n
				progr_2_param:=	cmd_l					
				Gosub, ShowExtraBars_timer		
			}else if(enter_from=="progr_3_mem"){
				;progr_3_mem:=edit_1
				progr_3_mem:=pname
				prog_3_PID :=PID	
				set_prog_3:=1
				progr_3_param:=	SubStr(cmd_l,1,17)
				SetTimer, memory_progr_3_mem ,Off					
				Gosub,memory_progr_3_mem
				Settimer, memory_progr_3_mem ,3000 				
			}				 	
		}
		GuiControl, Hide, edit_1
		GuiControl, Show, progr_3_mem
	}else{
		name:=edit_1
		global i_:=find_num_windows(name)
		cmd_l:=""
		if(i_==0){
			ToolTip_("not found" , 2)
			GuiControl, Hide, edit_1
			GuiControl, Show, progr_3_mem
			return			
		}else if(i_>1){	
			;PID :=find_windows(name)
			win:=find_windows_ComObj(name)
			PID :=win[2]
			name:=win[1] 
			cmd_l:=win[3] ; name from AHK parameter
		}else if(i_==1){
			Process, Exist, %edit_1%
			PID := Errorlevel
			name:=RegExReplace(edit_1,"i)\.exe","")
		}		

		if(!PID){
			ToolTip_("not found" , 2)
			GuiControl, Hide, edit_1
			GuiControl, Show, progr_3_mem
			return
		}else{
			if(enter_from=="stat20"){
				multi_prog:=0
				;progr_1:=edit_1
				progr_1:=name
				progr_1_PID := PID	
				progr_1_n:=get_prog_name(name) 	
				;StringLower, progr_1_n, progr_1_n	
				set_progr_1:=1 		
				progr_1_param:=	cmd_l
				Gosub, ShowExtraBars_timer
				;SetTimer, ShowExtraBars ,1000				
			}else if(enter_from=="stat21"){
				;progr_2:=edit_1
				progr_2:=name
				progr_2_PID := PID					
				progr_2_n:=get_prog_name(name) 	
				;StringLower, progr_2_n, progr_2_n	
				set_progr_2:=1 
				progr_2_param:=	cmd_l
				Gosub, ShowExtraBars_timer
				;SetTimer, ShowExtraBars ,1000				
			}else if(enter_from=="progr_3_mem"){
				;progr_3_mem:=edit_1
				progr_3_mem:=edit_1
				prog_3_PID := PID	
				set_prog_3:=1
				progr_3_param:=	SubStr(cmd_l,1,17)
				SetTimer, memory_progr_3_mem ,Off	
				Gosub, memory_progr_3_mem
				;Settimer, memory_progr_3_mem ,3000 				
			}				 	
		}
			GuiControl, Hide, edit_1		
			GuiControl, Show, progr_3_mem
	}
return




ToolTip_(tekst,t:=2){
	GuiControlGet, Pos, Pos, edit_1
	tipX:= PosX+ 4, tipY:=PosY +2
	ToolTip, %tekst% ,%tipX%, %tipY%
	t:=t*1000
	Settimer, ToolTip_close , -%t%
}

ToolTip_close:
	Settimer, ToolTip_close , Off
	ToolTip
return

edit_hide:
	Settimer, edit_hide , Off
	GuiControl, Hide, edit_1
	GuiControl, Show, progr_3_mem
ToolTip
return
  
	
find_windows_ComObj(name){
	global i_
		WMI:=ComObjGet("winmgmts:")
		queryEnum := ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Process where Name ='" name "'")._NewEnum
		While queryEnum[process] {
		WinGetTitle, this_title, % "ahk_pid" process.processId
			cmd_l:=process.CommandLine
			proc_n:=proc_names(process.Name,cmd_l,process.ExecutablePath)
			pname:=proc_n[1], cmd_l:=proc_n[2]
			
			PID:=process.processId  
			if InStr(process.Name, name){
				message:= "Found " i_ " processes. Choose this one?`n`n" "Process name:  `n" process.Name " (PID: " PID ")?`n`n" "Window title:`n" this_title 
				confirm:=DllCall("MessageBox","Uint",0,"Str",message,"Str","Choose process","Uint","0x00040004L")
				if(confirm==6)
					return object(1,pname, 2, PID, 3,cmd_l) 			
			}	
		}
}
	
	
/* find_windows(name){
	global i_
	DetectHiddenWindows, On
	WinGet, id, list,,, Program Manager ;  get all windows 
	Loop, %id%
	{
			this_id := id%A_Index%
			WinGet, PID, PID,ahk_id %this_id%,, 
			WinGetTitle, this_title, ahk_id %this_id%
			WinGet, pname, ProcessName,ahk_id %this_id%,
			if InStr(pname, name){
				message:= "Found " i_ " processes. Choose this one?`n`n" "Process name:  `n" pname " (PID: " PID ")?`n`n" "Window title:`n" this_title 
				confirm:=DllCall("MessageBox","Uint",0,"Str",message,"Str","Choose process","Uint","0x00040004L")
				if(confirm==6)
					return PID			
			}			
	}
	DetectHiddenWindows, Off
}
 */
 
 
find_num_windows(name){
	i:=0 , arr:= Object()
	DetectHiddenWindows, On
	WinGet, id, list,,, Program Manager ;  all windows 
		Loop, %id%
		{
			this_id := id%A_Index%
			WinGet, pname, ProcessName,ahk_id %this_id%,
			WinGet, PID, PID,ahk_id %this_id%,, 
			if InStr(pname, name){
        if(array_contains(arr,PID)){
					continue
				}					
					i+=1  
				arr.Push(PID) 
			}
		}
	DetectHiddenWindows, Off
  return i	
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
   return true
	}
 return false
}

;============================================

show_info:
	Gosub, GPU_info
	Settimer, show_info_clear , -3000
return

show_info_clear:
	Settimer, show_info_clear , Off
	GuiControl,, proc_info,
return

GPU_info:
	global DllFile := (A_PtrSize = 8) ? "nvapi64.dll" : "nvapi.dll"           
	global NVAPI_MAX_PHYSICAL_GPUS :=64
	global NVAPI_SHORT_STRING_MAX :=64
 show_:= GPU_GetFullName() 
 show_:=SubStr(show_,1,12)
 
/*  	mem_all:=Round(GPU_GetMemoryInfo().dedicatedVideoMemory / 1024)
	mem_free:=Round(GPU_GetMemoryInfo().curAvailableDedicatedVideoMemory / 1024)
	mem_used:=mem_all - mem_free

	mem_shared:=Round(GPU_GetMemoryInfo().sharedSystemMemory / 1024)
	mem_sys:=Round(GPU_GetMemoryInfo().systemVideoMemory / 1024)	
	show_:=mem_used "MB" " / " mem_all "MB"
	 */
	show_:= "GPU: " GPU_GetThermalSettings().1.currentTemp Chr(176) "C"  " | " show_ ;"°C"
	GuiControl,, proc_info, %show_%
return



;============================================

when_idle:
	;If (A_TimeIdlePhysical<3000){
	if(A_TimeIdle<3000){
		if(tim>60){
			FormatTime, time_,, HH:mm
			last2:=last1
			last1:=last			
			last:=tim2 " (" time_ ")"
			tray_tip:="Idle time`n" "last`n" last "`n" last1 "`n" last2 ;"`n===`nExp CPU: " Round(GetProcessTimes(exp_PID),2) "`n"			
			Menu, Tray,Tip , % tray_tip 
			
		}
	}
	;tim:=Floor(A_TimeIdlePhysical/1000)
	tim:=Floor(A_TimeIdle/1000)
	tim2:=czas_format(tim)
	GuiControl ,1:, result, %tim2%
	GuiControl ,1:, result2, %last%
return

times_idle_show:
	show:="Idle time`n" "last: `n" last "`n" last1 "`n" last2
	MsgBox,,, % show  "`n", 8  
return
  
;============================================


 time_date:
	;FormatTime, Data,, d MMM, dddd  
	FormatTime, Data,, ddd, d MMM 
	;GuiControl,, time_d, %Data%
	if(Data != Data_old){
			GuiControl,, time_d, %Data%
			Data_old:=Data
	}
	
	FormatTime, time1,, H:mm	
	;GuiControl,, time_t1, %time1%
	if(time1 != time1_old){
		GuiControl,, time_t1, %time1%
		time1_old:=time1
	}	
	
	
	FormatTime, time2,, ss 	
	GuiControl,, time_t2,  : %time2%	
	;FormatTime, time1,,  H:mm:ss 	
	;GuiControl,, time_t, %time1%
return
 
time_on:
	time_on_:=time_from_sec(A_TickCount)

	if(time_on_ != time_on_old){
			;GuiControl,, time_on, up time: %time_on_%	
			GuiControl,, time_on, %time_on_%	
			time_on_old:=time_on_
	}
	;GuiControl,, time_on, %time_%
return


GoToSavedPos:
	;if A_GuiControlEvent <> DoubleClick
	;	return
	IniRead, pos_x_saved, %settings_ini%, window position, x	
	IniRead, pos_y_saved, %settings_ini%, window position, y	
	if(pos_x_saved<A_ScreenWidth-120 && pos_y_saved<A_ScreenHeight-140)
		WinMove,  Drozd_monitor_ext, ,pos_x_saved,pos_y_saved
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

czas_format(time_sec){
	sec:=mod(time_sec,60)
	min:=time_sec>3600 ? Floor(mod(time_sec,3600)/60) : Floor(time_sec/60) 	
	return dig(min) ":" dig(sec) 
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

set_bgrd_style_dots2:
bgrd_style:="dots2"
IniWrite, %bgrd_style%	, %settings_ini%, Window, GUI_style
return

reset_bgrd:
bgrd_style:=""
IniDelete, %settings_ini%, Window,
IniWrite, %bgrd_grad_black%	, %settings_ini%, Window, GUI_background
IniWrite, %clock_grad_black%	, %settings_ini%, Window, GUI_background_clock
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



~$F4::
	Gui 1: Show
return
;=========================================

onTop:        
		if WonTop {
			WinSet, AlwaysOnTop, off, Drozd_monitor_ext
			GuiControl, Show, onTop_off
			GuiControl, Hide, onTop_on
			WonTop:=0	
		}else{
			WinSet, AlwaysOnTop, on, Drozd_monitor_ext
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
num:=!toggle_big
IniWrite, %num%, %settings_ini%, Window , bigger	
Gdip_Shutdown(pToken)
DllCall( "AnimateWindow", "Int", GuiHwnd, "Int", 200, "Int", 0x00050008 )
ExitApp



Reload:
Reload
return

GuiContextMenu:
Menu, ContextMenu, Show, %A_GuiX%, %A_GuiY%
Return

WindowSpy:
;Run, "C:\Program Files\AutoHotkey\AU3_Spy.exe" 
Run, "C:\Program Files\AutoHotkey\WindowSpy.ahk"
return

Edit_Notepad:
Run, "C:\Program Files\Notepad2\Notepad2.exe" "%A_ScriptFullPath%"
return

Edit_Scite:
Run, "C:\Program Files\AutoHotkey\SciTE\SciTE.exe"  "%A_ScriptFullPath%"
return

show_help:
Progress, zh0 w600 M2 C0y ZX20 ZY10 CWFFFFFF FS8 FM10 WM700 WS700 ,%help%, Drozd CPU monitor , Drozd monitor Help, Segoe UI Semibold
return


show_ListView:
Gui,3: Default 
Gui,3:ListView , LV
Gui,3: Add, ListView, w450 h430  vLV, Name|PID|Parameter
LV_ModifyCol(1,150)
LV_ModifyCol(2,50)
LV_ModifyCol(3,220)
;LV_ModifyCol(3,50)
;LV_ModifyCol(4,300)
for PID in proc_list {
		LV_Add("",  proc_list[PID][1], PID, proc_list[PID][2] )
		j:= A_Index
	}
LV_ModifyCol(1, "SortAsc")
Gui,3: Show, w470 h450 , Drozd monitor process list # %j%
return

3GuiClose:
Gui, 3: Destroy
return

show_proc_list_:
Gosub, show_ListView
;show_proc_list(proc_list)
return

; ======= Send mouse scrolls to ComboBox

WHEEL_DELTA := (120 << 16)

~WheelUp::
	if !WinActive("Drozd_monitor_ext")
		return
	Scroll(7864320)  
return

~WheelDown::
	if !WinActive("Drozd_monitor_ext")
		return
	Scroll(-7864320)
return

Scroll(WHEEL_DELTA) {
 MouseGetPos, mX, mY, hWin, hCtrl, 2
 PostMessage, 0x20A, WHEEL_DELTA, (mY << 16) | mX,,% "ahk_id" (hCtrl ? hCtrl:hWin)
} 


; =======

;#Include ..\functions_Gdip.ahk
;#Include C:\Program Files\Misc\AutoHotkey Scripts\functions_Gdip.ahk
;#Include C:\Program Files\Misc\AutoHotkey Scripts\AHK_Library\Gdip.ahk


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

; ==================== GPU temperature
;jNizM https://autohotkey.com/boards/viewtopic.php?t=5508



	EnumPhysicalGPUs(){
        global DllFile
        ;MsgBox, % DllFile
       DllCall("LoadLibrary", "Str", DllFile, "UPtr")
        DllCall(DllCall(DllFile "\nvapi_QueryInterface", "UInt", 0x0150E828, "CDECL UPtr"), "CDECL")
        ;DllCall("LoadLibrary", "Str", DllFile, "UPtr")
       ; DllCall(DllCall(DllFile "\nvapi_QueryInterface", "UInt", 0x0150E828, "CDECL UPtr"), "CDECL")

        EnumPhysicalGPUs := DllCall(DllFile "\nvapi_QueryInterface", "UInt", 0xE5AC921F, "CDECL UPtr")
        VarSetCapacity(nvGPUHandle, 4 * 64, 0)
				DllCall(EnumPhysicalGPUs, "Ptr", &nvGPUHandle, "UInt*", pGpuCount, "CDECL")
        
        ;VarSetCapacity(nvGPUHandle, 4 * NVAPI_MAX_PHYSICAL_GPUS, 0)
        ;VarSetCapacity(nvGPUHandle, 4 * 64, 0)
        ;MsgBox, % "NvStatus  " DllCall(EnumPhysicalGPUs, "Ptr", &nvGPUHandle, "UInt*", pGpuCount, "CDECL")
        if !(NvStatus := DllCall(EnumPhysicalGPUs, "Ptr", &nvGPUHandle, "UInt*", pGpuCount, "CDECL"))
        {            
            GPUH := []
            loop % pGpuCount {
                GPUH[A_Index] := NumGet(nvGPUHandle, 4 * (A_Index - 1), "Int")
            }
            ;MsgBox,,, % "pGpuCount " pGpuCount
            ;MsgBox, % "GPUH  " Object_to_string(GPUH)
            return GPUH
        }
        
        return "err" ;GetErrorMessage(NvStatus)
	} 

    GPU_GetThermalSettings(hPhysicalGpu := 0){
        global DllFile, 
         GPU_GetThermalSettings := DllCall(DllFile "\nvapi_QueryInterface", "UInt", 0xE3640A56, "CDECL UPtr")
         NVAPI_MAX_THERMAL_SENSORS_PER_GPU := 3
         NV_GPU_THERMAL_SETTINGS := 8 + (20 * NVAPI_MAX_THERMAL_SENSORS_PER_GPU)
         NV_THERMAL_CONTROLLER := {-1: "UNKNOWN", 0: "NONE", 1: "GPU_INTERNAL", 2: "ADM1032", 3: "MAX6649"
                                        , 4: "MAX1617", 5: "LM99", 6: "LM89", 7: "LM64", 8: "ADT7473", 9: "SBMAX6649"
                                        ,10: "VBIOSEVT", 11: "OS"}
         NV_THERMAL_TARGET := {-1: "UNKNOWN", 0: "NONE", 1: "GPU", 2: "MEMORY", 4: "POWERSUPPLY", 8: "BOARD"
                                    , 9: "VCD_BOARD", 10: "VCD_INLET", 11: "VCD_OUTLET", 15: "ALL"}
        if !(hPhysicalGpu)
            hPhysicalGpu := EnumPhysicalGPUs()[1]
        ;MsgBox, %   hPhysicalGpu " | " EnumPhysicalGPUs()[1]
       
        VarSetCapacity(pThermalSettings, NV_GPU_THERMAL_SETTINGS, 0), NumPut(NV_GPU_THERMAL_SETTINGS | 0x20000, pThermalSettings, 0, "UInt")
        if !(NvStatus := DllCall(GPU_GetThermalSettings, "Ptr", hPhysicalGpu, "UInt", 15, "Ptr", &pThermalSettings, "CDECL"))
        {
            TS := {}
            TS.version := NumGet(pThermalSettings, 0, "UInt")
            TS.count   := NumGet(pThermalSettings, 4, "UInt")
            OffSet := 8
            loop % NVAPI_MAX_THERMAL_SENSORS_PER_GPU
            {
                TS[A_Index, "controller"]     := (C := NV_THERMAL_CONTROLLER[NumGet(pThermalSettings, Offset, "UInt")]) ? C : "UNKNOWN"
                TS[A_Index, "defaultMinTemp"] := NumGet(pThermalSettings, Offset +  4, "Int")
                TS[A_Index, "defaultMaxTemp"] := NumGet(pThermalSettings, Offset +  8, "Int")
                TS[A_Index, "currentTemp"]    := NumGet(pThermalSettings, Offset + 12, "Int")
                TS[A_Index, "target"]         := (T := NV_THERMAL_TARGET[NumGet(pThermalSettings, Offset + 16, "UInt")]) ? T : "UNKNOWN"
                OffSet += 20
            }
            return TS
        }
        return "err" ;  GetErrorMessage(NvStatus)
    }
    
    GetErrorMessage(ErrorCode){
        global DllFile
        static GetErrorMessage := DllCall(DllFile "\nvapi_QueryInterface", "UInt", 0x6C2D048C, "CDECL UPtr")
        ;VarSetCapacity(szDesc, NVAPI_SHORT_STRING_MAX, 0)
        VarSetCapacity(szDesc, 64, 0)
        if !(NvStatus := DllCall(GetErrorMessage, "Ptr", ErrorCode, "WStr", szDesc, "CDECL"))
            return ErrorMessage ? "Error: " StrGet(&szDesc, "CP0") : "*" ErrorCode
        return NvStatus
    }



    GPU_GetMemoryInfo(hPhysicalGpu := 0){
        global DllFile
        GPU_GetMemoryInfo := DllCall(DllFile "\nvapi_QueryInterface", "UInt", 0x07F9B368, "CDECL UPtr")
        NV_DISPLAY_DRIVER_MEMORY_INFO := 24
        if !(hPhysicalGpu)
            hPhysicalGpu := EnumPhysicalGPUs()[1]
        VarSetCapacity(pMemoryInfo, NV_DISPLAY_DRIVER_MEMORY_INFO, 0), NumPut(NV_DISPLAY_DRIVER_MEMORY_INFO | 0x20000, pMemoryInfo, 0, "UInt")
        if !(NvStatus := DllCall(GPU_GetMemoryInfo, "Ptr", hPhysicalGpu, "Ptr", &pMemoryInfo, "CDECL"))
        {
            MI := {}
            MI.version                          := NumGet(pMemoryInfo,  0, "UInt")
            MI.dedicatedVideoMemory             := NumGet(pMemoryInfo,  4, "UInt")
            MI.availableDedicatedVideoMemory    := NumGet(pMemoryInfo,  8, "UInt")
            MI.systemVideoMemory                := NumGet(pMemoryInfo, 12, "UInt")
            MI.sharedSystemMemory               := NumGet(pMemoryInfo, 16, "UInt")
            MI.curAvailableDedicatedVideoMemory := NumGet(pMemoryInfo, 20, "UInt")
            return MI
        }
        return "err" ;GetErrorMessage(NvStatus)
    }
    
    GPU_GetFullName(hPhysicalGpu := 0){
        global DllFile
        global GPU_GetFullName := DllCall(DllFile "\nvapi_QueryInterface", "UInt", 0xCEEE8E9F, "CDECL UPtr")
        if !(hPhysicalGpu)
            hPhysicalGpu := EnumPhysicalGPUs()[1]
        ;VarSetCapacity(szName, NVAPI_SHORT_STRING_MAX, 0)
        VarSetCapacity(szName, 64, 0)
        if !(NvStatus := DllCall(GPU_GetFullName, "Ptr", hPhysicalGpu, "Ptr", &szName, "CDECL"))
            return StrGet(&szName, "CP0")
        return GetErrorMessage(NvStatus)
    }



