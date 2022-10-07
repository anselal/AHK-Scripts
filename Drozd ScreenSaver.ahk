#SingleInstance force
Menu, Tray, Icon, shell32.dll,  208 ;35 

SetBatchLines, -1
FileEncoding, UTF-8

help= ;show_help
(
● This program displays randomly chosen pictures from created lists (.ini files): 
	first a list is randomly chosen, then a picture is randomly chosen from the list
	
● When program starts it ask for a folder path and creates a single list file.
● In context menu: 
	• to add another folder (one list) choose: "Add folder to make pictures list" 
	• to add multiple lists for each subfolder from a chosen folder: "Add picture lists from subfolders"
● Force start: double click on tray icon or "Start" in tray menu

● Options in tray menu (icon), Context menu on right click 
● "Add folder to make pictures list" - make/refresh a list of all pictures in folder
● "Picture list from subfolders" - make a list of all pictures for each subfolder (one level deep)
● Settings - lists(folders) on/off

  Shortcut keys: (work when window active - click on picture if inactivated)
● ctrl + d = start "Screen Saver" , Ctrl+h - pause making a list
● next picture - 2 or F2 or Right or Numpad8  
● previous picture - 1 or F1 or Left or Numpad7 
● Numpad1,3 - previous, next picture in the list (folder) ; 
  Shift+Numpad1,3 - step=10 ; Alt+Numpad1,3 - step=100
● pause for 60 sec. - 3 or F3 or Numpad3
● full size - Numpad5 (or double click) ; Shift+ Numpad5 - full size with focus on mouse pointer
	• in full size mode: Numpad4,6 - move left, righ ; Numpad2,8 - move down, up
	• mouse drag to move	
● zoom - NumpadAdd (+), NumpadSub(-) or mouse wheel 
	mouse wheel (or Shift + NumpadAdd) - zoom around mouse pointer
● 4 - Show picture path on/off 
● double click - "fit" or "original size" 

● Hide - press Esc or other keys not mentioned above
● time to automatically close Screen Saver (choose the same as the time of monitor off) - closeAfter := 20*60*1000 (20 min)

¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 Numpad:
	
	(7)----------------------------(8)----------------------------(9)-----------------------(Minus)
   (prev random)                     (move up)                   (next random)                         (zoom-)
	(4)----------------------------(5)----------------------------(6)----------------------------
     (move left)                     (original size)                   (move right)
	(1)----------------------------(2)----------------------------(3)--------------------------(Plus)
   (prev in folder)                (move down)                     (next in folder)	      (zoom+)
	(0)
	(pause)

If folder contents change, there are context menu options
● "Refresh INI files list"  - refresh list INI files (picture lists) im main INI file
● "Refresh all lists of pictures" - refresh all picture lists for all previously chosen folders
● Ctrl+h - stop refreshing lists

● drag_delay time may be lowered to smoothen the mouse drag
)


WorkingDir :=A_ScriptDir "\Lists"
if !FileExist(WorkingDir)
FileCreateDir, %WorkingDir%

global settings_ini := WorkingDir "\Drozd Screen Saver.ini"
folderLists:=WorkingDir 

folderPath:=HOMEDRIVE HOMEPATH "\Pictures"


global time_interval:=5000
global timeToStart:=3*60*1000
global move_step:=100
global showPath:=1 
global zoom_step:=0.20 
global drag_delay:=10
global closeAfter:= 20*60*1000 ; 20 min 
global inBackground:=0  ; making pictures list - slower in background
global pic_list_Len:=30

global smallToFullSize:=1 , smallToFullSize_toggle:=0
global obj_INIs:= Object()


global ext_list:="jpg,jpeg,png,webp,gif,bmp"
key_exempt_list:="Left,Right,1,2,3,4,RButton,F1,F2,F3,Numpad5,NumpadClear,Numpad0,NumpadIns,Numpad4,Numpad6,Numpad2,Numpad3,Numpad8,Numpad7,Numpad9,Numpad1,NumpadClear,NumpadLeft,NumpadRight,NumpadDown,NumpadUp,NumpadHome,NumpadPgUp,NumpadEnd,NumpadPgDn,NumpadAdd,NumpadSub,WheelDown,WheelUp,LButton,LShift,LAlt,WheelLeft,WheelRight,XButton1,XButton2"  


SysGet, MonitorWorkArea, MonitorWorkArea, 1
Gosub, ContextMenuMake

IniRead, read_, %settings_ini%, ini files list ,  number of files 

if(!FileExist(settings_ini) || read_="" || read_="ERROR" || read_=0){
	IniWrite, %timeToStart%  , %settings_ini%, Screen Saver , start after
	IniWrite, %time_interval%  , %settings_ini%, Screen Saver , time interval 
	IniWrite, %showPath%  , %settings_ini%, Screen Saver ,show picture path
	Gosub, AddFileList ;createFileList
	Gosub, MakeINIfilesList
}


IniRead, read_ , %settings_ini%, Screen Saver , start after

	if(read_!="ERROR" && read_!=""){
		timeToStart:=read_
	}else{
		IniWrite, %timeToStart%  , %settings_ini%, Screen Saver , start after
	}
IniRead, read_ , %settings_ini%, Screen Saver , time interval 
	if(read_!="ERROR" && read_!=""){
		time_interval:=read_
	}else{
		IniWrite, %time_interval%  , %settings_ini%, Screen Saver , time interval 
	}

IniRead, read_ , %settings_ini%, Screen Saver , show picture path

	if(read_!="ERROR" && read_!=""){
		showPath:=read_
		if(showPath=0){
			Menu, Submenu4, UnCheck, Show picture path on/off  
			Menu, Submenu3, UnCheck, Show picture path on/off 
		}else{
			Menu, Submenu4, Check, Show picture path on/off  
			Menu, Submenu3, Check, Show picture path on/off  
		} 		
	}else{
		IniWrite, %showPath%  , %settings_ini%, Screen Saver ,show picture path
	}


Gosub, TrayTip


global ScreenH:=A_ScreenHeight, ScreenW:=A_ScreenWidth
global captionY:=ScreenH-20
global pic_list:= Object(), pic_list_n:= Object()
global zoom_start:=0, toggle_size:=0 ,ScrSaverOn:=0, dragStart:=0, Menu_on:=0, StandbyOn:=0, full_size_pointer:=0



IniRead, Number , %settings_ini%, File list , LastNumber

OnExit, Close

Gosub,  getfileLists
SetTimer,Set_main_timer,-2000


If !pToken := Gdip_Startup(){
	MsgBox, 48, gdiplus error!
	ExitApp
}


Gui,1: +E0x80000 +HwndGuiHwnd +AlwaysOnTop +ToolWindow +OwnDialogs ; layered window 
Gui,1:-DPIScale
Gui,1:Color, 2D3F5D
Gui,1:Show, Hide  w%ScreenW% h%ScreenH% , Drozd Screen Saver


OnMessage(0x218, "WM_POWERBROADCAST") ; standby
OnMessage(0x203,"WM_LBUTTONDBLCLK")
OnMessage(0x0202,"WM_LBUTTONUP") 
OnMessage(0x201, "WM_LBUTTONDOWN")
;OnMessage(0x404, "AHK_NOTIFYICON")

DllCall("RegisterShellHookWindow", "UInt",A_ScriptHwnd)
MsgNum := DllCall("RegisterWindowMessage", "Str","SHELLHOOK")
OnMessage(MsgNum,"ShellMessage")
return



ShellMessage(wParam,lParam){
	if(wParam=1){   ;  HSHELL_WINDOWCREATED = 1  ; new program started
    ;WinGet, pname, ProcessName,ahk_id %lParam%  
		WinGetClass, class_, ahk_id %lParam%  
		id:=Format("0x{1:x}", lParam) ; decimal to hexadecimal
		if(RegExMatch(class_,"i)CabinetWClass")){ 
				fn:=Func("selectInWindow").Bind(id)
				SetTimer, %fn% , -800       
		}
  }

  if(wParam=2){ ; HSHELL_WINDOWDESTROYED=2 ; program stopped
  } 
}

selectInWindow(hwnd){
  global SelectFilePath	
	FileName:=SelectFilePath
  SelectFilePath:=""
	win := GetShellFolder(hwnd)
  fold_path:=win.Document.Folder.Self.Path 
	win.Document.SelectItem(win.Document.Folder.ParseName(FileName), 1|4|8)
}

GetShellFolder(Win_id){
  for win in ComObjCreate("Shell.Application").Windows  {
    if(win.hwnd == Win_id)
      return win
  }			
}

AHK_NOTIFYICON(wParam, lParam){ ; click tray icon 
    if(lParam = 0x202){      ; WM_LBUTTONUP	
			SetTimer, forceStart,-500				
    }else if (lParam = 0x203){   ; WM_LBUTTONDBLCLK
		}
}
 


WM_POWERBROADCAST(wParam, lParam){  ; standby ;PBT_APMSUSPEND = 0x0004; PBT_APMRESUMESUSPEND=0x0007	
	if(wParam=4 || wParam=7){ ; standby ;4= to standby, 7 from;
		SetTimer, main_timer, Off
		Gosub, stopScrSaver
	}
	if(wParam=7){
		StandbyOn:=1
		SetTimer,ClearStandbyOn,-5000
		SetTimer,Set_main_timer, -5000	
	}else	if(wParam=4){
		StandbyOn:=1
	}	
}		

ClearStandbyOn:
StandbyOn:=0
Send,{Shift down}{Shift up} ;clear A_TimeIdle 
return



Gdip_draw_Win(hwnd,imagePath,show_full:=0,move:=0,zoom:=0,mouseZoom:=0,drag*){
	static x_move, y_move, w_zoom, h_zoom, relXd, relYd, lastPath
	
	if(show_full=0 && move=0 && zoom=0 && mouseZoom=1 ){  ;&& !full_size_pointer
		x_move:=0, y_move:=0
	}
	if(imagePath!=lastPath){
		zoom_start:=0
	}
	lastPath:=imagePath
	
	pBitmap := Gdip_CreateBitmapFromFile(imagePath)
	If (!pBitmap){
		return
	}
	Width := Gdip_GetImageWidth(pBitmap), Height := Gdip_GetImageHeight(pBitmap)
	rel:=Width/Height

	if(zoom!=0 || move){
		if(!zoom_start){ ;zoom
			zoom_start:=1
			w_zoom:=Width, h_zoom:=Height			
			if(!move){
				if(h_zoom>ScreenH){
					h_zoom:=ScreenH,
					w_zoom:=ScreenH*rel	
					x_move:=Abs((ScreenW-w_zoom)/2) ,y:=Abs((ScreenH-h_zoom)/2)
					y_move:= (h_zoom< ScreenH) ? y_move : 0			
				}else if(w_zoom>ScreenW && h_zoom<=ScreenH ){
					w_zoom:=ScreenW
					h_zoom:=ScreenW/rel				
					x_move:=Abs((ScreenW-w_zoom)/2) , y_move:=Abs((ScreenH-h_zoom)/2)	
					x_move:= (w_zoom< ScreenW) ? x_move : 0
				}else{
					h_zoom:=h_zoom,w_zoom:=w_zoom
					x_move:=Abs((ScreenW-w_zoom)/2) ,y_move:=Abs((ScreenH-h_zoom)/2)
					y_move:= (Height<ScreenH) ? y_move : 0				
				}
			}	
		}	
		w_zoom0:=w_zoom, h_zoom0:=h_zoom
		if(zoom=1){
			h_zoom:=h_zoom+ Round(zoom_step*h_zoom), w_zoom:=Round(h_zoom*rel)
		}
		if(zoom=2){
			h_zoom:=h_zoom- Round(zoom_step*h_zoom), w_zoom:=Round(h_zoom*rel)	
		}		
		h:=h_zoom,w:=w_zoom

	 	fitCheck:=h_zoom<=ScreenH && w_zoom<=ScreenW
		
		if(move="L" && !fitCheck){
			x_move:=(x_move+ move_step<=0) ? x_move + move_step : 0
			x:=x_move, y:=y_move
		}else if(move="R" && !fitCheck){
			x_move:=(w_zoom-Abs(x_move-move_step)>=ScreenW) ? x_move - move_step : ScreenW-w_zoom
			x:=x_move	, y:=y_move
		}else if(move="D" && !fitCheck){	
			y_move:= (h_zoom-Abs(y_move-move_step)>=ScreenH) ? y_move - move_step : ScreenH-h_zoom
			y:=y_move, x:=x_move						
		}else if(move="U" && !fitCheck){	
			y_move:= (y_move + move_step<=0) ? y_move + move_step : 0	
			y:=y_move	, x:=x_move	
		}else if(move="U" && !fitCheck){	
			y_move:= (y_move + move_step<=0) ? y_move + move_step : 0	
			y:=y_move	, x:=x_move			
	
		;=========drag
		}else if(move="Drag" && !fitCheck){	 ;drag
			Mx0:=drag[1], My0:=drag[2]
			CoordMode, Mouse, Screen
			if(!dragStart){
				dragStart:=1
				relXd:=(Mx0-x_move)/w_zoom , relYd:=(My0-y_move)/h_zoom		 
			}
			
			MouseGetPos, Mx,My 		
			x:= Mx-(relXd*w_zoom)
			y:= My-(relYd*h_zoom)
			
			if(x>0)
				x:=0
			if(y>0)
				y:= 0
			if(Abs(x)>w_zoom-ScreenW){
				if(w_zoom<ScreenW)
					x:=(ScreenW-w)/2
				else
				x:=	-(w_zoom-ScreenW)
			}			
			if(Abs(y)>h_zoom-ScreenH){				
				y:=	-(h_zoom-ScreenH)
				
				if(h_zoom<ScreenH)
					y:=(ScreenH-h_zoom)/2	
			}			

			x_move:=x,y_move:=y
		;=========drag

		}else if(zoom && !fitCheck){ ; zoom in , magnify

			if(mouseZoom){
				MouseGetPos, Mx,My 
				y1:=Abs(y_move) + My,		x1:=Abs(x_move) + Mx
			}else{
				y1:=Abs(y_move) + ScreenH/2,		x1:=Abs(x_move) + ScreenW/2
			}
			
			relX1:=x1/w_zoom0 , relY1:=y1/h_zoom0

			if(mouseZoom){
				x:= -(relX1*w_zoom - Mx)
				y:= -(relY1*h_zoom - My)
			}else{
				x:= -(relX1*w_zoom - ScreenW/2)
				y:= -(relY1*h_zoom - ScreenH/2)
			}
			
			if(Abs(x)>w_zoom-ScreenW){
				if(w_zoom<ScreenW)
					x:=(ScreenW-w)/2
				else
				x:=	-(w_zoom-ScreenW)
			}
			
			if(Abs(y)>h_zoom-ScreenH){				
				y:=	-(h_zoom-ScreenH)
				if(h_zoom<ScreenH)
					y:=(ScreenH-h_zoom)/2	
			}			
	
			if(x>0 && w_zoom>=ScreenW){
				x:=0
			}
			if(y>0 && h_zoom>=ScreenH){
				y:=0
			}				
			 
			x_move:=x,y_move:=y

		}else if(zoom && (h_zoom<ScreenH || w_zoom<ScreenW)){
			y1:=Abs(y_move) + ScreenH/2, x1:=Abs(x_move) + ScreenW/2
			relX1:=x1/w_zoom0 , relY1:=y1/h_zoom0
			if(w_zoom>=ScreenW){
				x:= -(relX1*w_zoom - ScreenW/2)
			}else{
				x:= (ScreenW-w_zoom)/2
			} 
			if(h_zoom>=ScreenH){
				x:= -(relY1*h_zoom - ScreenH/2)
			}else{
				x:= (ScreenH-h_zoom)/2	
			} 					
			
			if(w_zoom<ScreenW){
				x:=	(ScreenW-w_zoom)/2
			}
			if(hzoom<ScreenH){
				y:=	(ScreenH-h_zoom)/2
			}	
		
			y_move:=y, x_move:=x		
			
		}else{
			x:=(ScreenW-w)/2 ,y:=(ScreenH-h)/2	
			y_move:=y, x_move:=x		
		}
		;========= zoom ============

	}else if(show_full){
		h:=Height,w:=Width
		x:=(ScreenW-w)/2 ,y:=(ScreenH-h)/2
		
		if(full_size_pointer && (Height>ScreenH || Width>ScreenW) ){
			h0:=h, w0:=w
			if(Height>ScreenH){
				h:=ScreenH,
				w:=ScreenH*rel	
				x:=Abs((ScreenW-w)/2) ,y:=Abs((ScreenH-h)/2)
				y:=(Height< ScreenH) ? y : 0			
			}else if(Width>ScreenW && Height<=ScreenH ){
				w:=ScreenW
				h:=ScreenW/rel				
				x:=Abs((ScreenW-w)/2) ,y:=Abs((ScreenH-h)/2)	
				x:=(Width<ScreenW) ? x : 0
			}else{
				h:=Height,w:=Width
				x:=Abs((ScreenW-w)/2) ,y:=Abs((ScreenH-h)/2)
				y:=(Height< ScreenH) ? y : 0				
			}
				w_zoom:=Width, h_zoom:=Height
				MouseGetPos, Mx,My 
				
				x1:=Mx-Abs(x), y1:=My
				relX1:=x1/w , relY1:=y1/h
				x:= -(relX1*w_zoom - Mx)
				y:= -(relY1*h_zoom - My)				
				h:=Height,w:=Width
				
				
				
				if(Abs(x)>w_zoom-ScreenW){
					if(w_zoom<ScreenW)
						x:=(ScreenW-w)/2
					else
					x:=	-(w_zoom-ScreenW)
				}
					
				if(Abs(y)>h_zoom-ScreenH){				
					y:=	-(h_zoom-ScreenH)
					if(h_zoom<ScreenH)
						y:=(ScreenH-h_zoom)/2	
				}
		 
				if(x>0 && w_zoom>=ScreenW)
					x:=0
				if(y>0 && h_zoom>=ScreenH)
					y:=0
			
				x_move:=x,y_move:=y
		}else if(Height<ScreenH){
			h:=ScreenH,
			w:=ScreenH*rel	
			x:=Abs((ScreenW-w)/2) ,y:=Abs((ScreenH-h)/2)
			y:=(Height< ScreenH) ? y : 0			
		}
		
		if(move="L"){
			x_move:=(x_move+ move_step<=0) ? x_move + move_step : 0
			x:=x_move, y:=y_move
		}else if(move="R"){
			x_move:=(Width-Abs(x_move-move_step)>=ScreenW) ? x_move - move_step : ScreenW-Width
			x:=x_move	, y:=y_move
		}else if(move="D"){	
			y_move:= (Height-Abs(y_move-move_step)>=ScreenH) ? y_move - move_step : ScreenH-Height
			y:=y_move, x:=x_move						
		}else if(move="U"){	
			y_move:= (y_move + move_step<=0) ? y_move + move_step : 0		
			y:=y_move	, x:=x_move					
		}
		w_zoom:=w, h_zoom:=h
		w_zoom0:=w_zoom, h_zoom0:=h_zoom
		zoom_start:=1
		;========= show_full ============

	}else{
		if(Height>ScreenH){
			h:=ScreenH,
			w:=ScreenH*rel	
			x:=Abs((ScreenW-w)/2) ,y:=Abs((ScreenH-h)/2)
			y:=(Height< ScreenH) ? y : 0			
		}else if(Width>ScreenW && Height<=ScreenH ){
			w:=ScreenW
			h:=ScreenW/rel				
			x:=Abs((ScreenW-w)/2) ,y:=Abs((ScreenH-h)/2)	
			x:=(Width<ScreenW) ? x : 0
			
		}else if(smallToFullSize=1 && smallToFullSize_toggle=0){	  ;full_size
			smallToFullSize_toggle:=1
			;toggle_size:=1
			h:=Height,w:=Width		
			h:=ScreenH,
			w:=ScreenH*rel	
			x:=Abs((ScreenW-w)/2) ,y:=Abs((ScreenH-h)/2)
			y:=(Height< ScreenH) ? y : 0	
			
		}else{
			h:=Height,w:=Width
			x:=Abs((ScreenW-w)/2) ,y:=Abs((ScreenH-h)/2)
			y:=(Height< ScreenH) ? y : 0				
		}
	}
	
 	if(show_full=1 && move=0 && zoom=0){
		x_move:=x, y_move:=y
	}
	
	hbm := CreateDIBSection(ScreenW, ScreenH)
	hdc := CreateCompatibleDC(), obm := SelectObject(hdc, hbm), G := Gdip_GraphicsFromHDC(hdc)

	pBrushBack := Gdip_BrushCreateSolid(0xFF000000)	
	Gdip_FillRectangle(G, pBrushBack,0, 0, ScreenW,ScreenH)	
		

	Gdip_SetInterpolationMode(G, 7)	; Interpolation HighQualityBicubic = 7
	Gdip_DrawImage(G, pBitmap, x, y, w, h, 0, 0, Width, Height)

	if(showPath=1 && show_full=0)
	Gdip_TextToG(G, imagePath, 0xffDDDDDD,10,captionY,13, 1300, 20,"Comic Sans MS") 

	UpdateLayeredWindow(hwnd, hdc, 0, 0, ScreenW, ScreenH)


	SelectObject(hdc, obm) 
	DeleteObject(hbm),DeleteDC(hdc), Gdip_DeleteGraphics(G), Gdip_DisposeImage(pBitmap)
	Gdip_DeleteBrush(pBrushBack)
 
}


Gdip_TextToG(ByRef G, Text, color,x, y,size,Width, Height,Font:="Arial",Style=0,Align=0){
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

	meas:=Gdip_MeasureString(G, Text, hFont, hFormat, RC) 
	arr:=StrSplit(meas,"|"), 	w_:= arr[3]	
	pBrushBack := Gdip_BrushCreateSolid(0x99333333)	
	Gdip_FillRectangle(G, pBrushBack, x-6, y-2, w_+8, Height+2)

	E :=Gdip_DrawString(G, Text, hFont, hFormat, pBrushT, RC)
	
	Gdip_DeleteBrush(pBrushT),	Gdip_DeleteBrush(pBrushBack)
	Gdip_DeleteStringFormat(hFormat), Gdip_DeleteFont(hFont),	Gdip_DeleteFontFamily(hFamily)
	return E ? E : ReturnRC
}



;============================================


getLineFromFile(path,number){ ; too big for INI  	
	LastNum:=LastNum_Get_FromFile(path)
	FileRead, Contents, %path%
	Loop, parse, Contents, `n
	{
		if(A_Index-1=number){
			RegExMatch(A_LoopField,"i)(\d+)=",num)		
			imgPath:=RegExReplace(A_LoopField,"i)(\d+)=","") 
			imgPath:=RegExReplace(imgPath,"im)\n\r|\n|\r","")
			return imgPath
		}		
		if(A_Index>LastNum)
		return 	"ERROR no"	
	} 
		return filePath
}

LastNum_Get_FromFile(path){  
	FileReadLine, line, %path%, 1
	line:=RegExReplace(line,"i)LastNumber=","") 
	line:=RegExReplace(line,"im)\n\r|\n|\r","")
	LastNum:=Format("{1:d}",line)
	return LastNum
}

loadObjINIs:
	obj_INIs:= Object()
	Loop, % fileLists.Length() {
		obj_INIs[A_Index]:= Object()
		obj_INIs[A_Index].file:=fileLists[A_Index].file		
		obj_INIs[A_Index].num:=fileLists[A_Index].num
		obj_INIs[A_Index].imgs:= Object()
		Index:=A_Index
		FileRead, Contents, % obj_INIs[Index].file
		Loop, parse, Contents, `n
		{
			if(A_Index=1){
				if !InStr(A_LoopField,"LastNumber") 
					MsgBox,4096,, %  "No LastNumber @ line #1" "`n"  obj_INIs[Index].file
				LastNum:=RegExReplace(A_LoopField,"i)LastNumber=","") 
				LastNum:=RegExReplace(LastNum,"im)\n\r|\n|\r","")
				obj_INIs[Index].num:=LastNum
			}else{
				imgPath:=RegExReplace(A_LoopField,"i)(\d+)=","") 
				imgPath:=RegExReplace(imgPath,"im)\n\r|\n|\r","")
				obj_INIs[Index].imgs[A_Index-1]:=imgPath
			}
		}		
	}
return

clearObjINIs:
	;obj_INIs:= Object()
return

;============================================

ShowImage:
	if(back_on){
		i+=1	
		if(i=pic_list.Length())
			back_on:=0
		Gdip_draw_Win(GuiHwnd,pic_list[i])
		return
	}	
	Random, j , 1, % fileLists.Length()
	ini_file_list:=fileLists[j].file, Number:=fileLists[j].num, 

	loop, 100 {
		Random, num , 1, %Number%		
		;IniRead, imagePath , %ini_file_list%, File list , %num%
		imagePath:=obj_INIs[j].imgs[num]
		if(FileExist(imagePath) && !array_contains(pic_list, imagePath))
			break
	}

	if(!FileExist(imagePath)){
		;ToolTip_("no file:`n" imagePath "`n" ini_file_list "`n" Number "`n" A_PriorHotkey,5,1)
		;FileAppend, %  "`n"  "Drozd ScreenSaver. No file "  imagePath  " | " ini_file_list  , %log_file%	
	}
	
	lastImagePath:=imagePath
	last_file_list:=ini_file_list
	pic_list.Push(imagePath), 
	pic_list_n[imagePath]:={lastNum:num,last_file_list:ini_file_list,Number:Number}
	
	if(pic_list.Length()>pic_list_Len){
		pic_list.RemoveAt(1)
	} 
	smallToFullSize_toggle:=0
	
	Gdip_draw_Win(GuiHwnd,imagePath)
	if(smallToFullSize=0)
		toggle_size:=0	
	
	FormatTime, Time_,, MMMd HH:mm:ss
	timeToS:=Round((timeToStart/1000)/60), time_in:=Round(time_interval/1000)
	str:="time to start= " timeToS " min." "`ntime interval= " time_in " sec." "`nshow path= " showPath ;"`n" imagePath "`nini= " ini_file_list "`nTime= " Time_
	Menu, Tray, Tip, % str
	;SetTimer, ShowImage, %time_interval%
return




stopScrSaver:
	WinHide, % "ahk_id "  GuiHwnd  ;Drozd Screen Saver
	SetTimer, ShowImage, Off
	ScrSaverOn:=0
	WinShow, ahk_class Shell_TrayWnd
	Gosub, clearObjINIs
return

startScrSaver:	
	Sleep 300
	Gosub, loadObjINIs
	;pic_list:= Object(),pic_list_n:= Object(), i:=0, 
	back_on:=0
	Gosub, ShowImage
	SetTimer, ShowImage, %time_interval%
	WinShow, % "ahk_id "  GuiHwnd  ;Drozd Screen Saver
	WinActivate, % "ahk_id "  GuiHwnd
	ScrSaverOn:=1
	;WinHide, ahk_class Shell_TrayWnd	
return

forceStart:
	forceStart:=1, StandbyOn:=0
	Gosub, startScrSaver	
	SetTimer, forceStartClear, -2000
return

forceStartClear:
	forceStart:=0
return


~^d::
	Gosub, forceStart
return

#IfWinActive, ahk_class CabinetWClass
^d::
Gosub, forceStart
return
#IfWinActive


#IfWinActive, ahk_class Progman
^d::
Gosub, forceStart
return
#IfWinActive



active:
	if !DllCall("IsWindowVisible", "UInt", GuiHwnd)
		return
	if !ScrSaverOn	
		return
return

;=======================


~Esc:: Gosub, stopScrSaver

#IfWinActive, Drozd Screen Saver

~Numpad1::  ; show prev in folder
~NumpadEnd::
	zoom_start:=0 
	Gosub, active
	Gosub, DelayTimer
	if(!foldViewOn){
		lastNum:=pic_list_n[lastImagePath].lastNum, Number:=pic_list_n[lastImagePath].Number
		last_file_list:=pic_list_n[lastImagePath].last_file_list
	}
	if(!lastNum)
		return	
	foldViewOn:=1
	
	if(GetKeyState("LShift", "P")==1){ 
    lastNum:=(lastNum-10<1) ? Number-lastNum : lastNum-10
	}else if(GetKeyState("LAlt", "P")==1){ 
    lastNum:=(lastNum-100<1) ? Number-lastNum : lastNum-100	
  }else
	lastNum:=(lastNum<=1) ? Number : lastNum-1
	lastNum:=(!lastNum) ?  1 : lastNum
		ToolTip_(lastNum  " / " Number ,2,2) 
	;IniRead, imagePath , %last_file_list%, File list , %lastNum%
	imagePath:=getLineFromFile(last_file_list,lastNum)
	if(!FileExist(imagePath)){
		;ToolTip_("no file:`n" imagePath "`n" ini_file_list "`n" Number "`n" A_PriorHotkey,5,1)
		;FileAppend, %  "`n"  "Drozd ScreenSaver. No file "  imagePath  " | " ini_file_list  , %log_file%
		return
	}
	lastImagePath:=imagePath
	smallToFullSize_toggle:=0
	Gdip_draw_Win(GuiHwnd,imagePath)
	if(smallToFullSize=0)
		toggle_size:=0	
return



~Numpad3::  ; show next in folder
~NumpadPgDn::
	zoom_start:=0
	Gosub, active
	Gosub, DelayTimer
	if(!foldViewOn){
		lastNum:=pic_list_n[lastImagePath].lastNum, Number:=pic_list_n[lastImagePath].Number
		last_file_list:=pic_list_n[lastImagePath].last_file_list
	}
	if(!lastNum)
		return	
	foldViewOn:=1
	
	if(GetKeyState("Shift", "P")==1){ 
    lastNum:=(lastNum+10>Number) ? Number-lastNum : lastNum+10
	}else if(GetKeyState("LAlt", "P")==1){ 
    lastNum:=(lastNum+100>Number) ? Number-lastNum : lastNum+100	
  }else		
	lastNum:=(lastNum>=Number) ? 1 : lastNum+1
	lastNum:=(!lastNum) ?  1 : lastNum
		ToolTip_(lastNum  " / " Number ,2,2) 
	;IniRead, imagePath , %last_file_list%, File list , %lastNum%
	imagePath:=getLineFromFile(last_file_list,lastNum)
	if(!FileExist(imagePath)){
		;ToolTip_(lastNum " =lastNum`n" "no file:`n" imagePath "`n" ini_file_list "`n" Number "`n" A_PriorHotkey,5,1)
		;FileAppend, %  "`n"  "Drozd ScreenSaver. No file "  imagePath  " | " ini_file_list  , %log_file%	
		return
	}
	lastImagePath:=imagePath
	smallToFullSize_toggle:=0
	Gdip_draw_Win(GuiHwnd,imagePath)
	if(smallToFullSize=0)
		toggle_size:=0	
return

~LAlt & Numpad1::  ; show prev in folder by 100
~LAlt & NumpadEnd::
	Gosub, active
	Gosub, DelayTimer
	zoom_start:=0
	if(!foldViewOn){
		lastNum:=pic_list_n[lastImagePath].lastNum, Number:=pic_list_n[lastImagePath].Number
		last_file_list:=pic_list_n[lastImagePath].last_file_list
	}

	foldViewOn:=1
	LastNum0:=lastNum
	lastNum:=(lastNum-100<1) ? Number-lastNum : lastNum-100	
	lastNum:=(!lastNum) ?  1 : lastNum
	ToolTip_(lastNum  " / " Number ,2,2)
	
	;IniRead, imagePath , %last_file_list%, File list , %lastNum%
	imagePath:=getLineFromFile(last_file_list,lastNum)
	if(!FileExist(imagePath)){
		;ToolTip_( "lastNum=" lastNum "`n" "no file:`n" imagePath "`n" ini_file_list "`n" Number "`n" A_PriorHotkey,5,1)
		;FileAppend, %  "`n"  "Drozd ScreenSaver. No file "  imagePath  " | " ini_file_list  , %log_file%	
		return
	}
	lastImagePath:=imagePath
	smallToFullSize_toggle:=0
	Gdip_draw_Win(GuiHwnd,imagePath)
	
	if(smallToFullSize=0)
		toggle_size:=0	
return


~LAlt & Numpad3::    ; show next in folder by 100
~LAlt & NumpadPgDn::
	Gosub, active
	Gosub, DelayTimer
	zoom_start:=0
	if(!foldViewOn){
		lastNum:=pic_list_n[lastImagePath].lastNum, Number:=pic_list_n[lastImagePath].Number
		last_file_list:=pic_list_n[lastImagePath].last_file_list
	}
	foldViewOn:=1
	lastNum:=(lastNum+100>Number) ? Number-lastNum : lastNum+100
	lastNum:=(!lastNum) ?  1 : lastNum
	ToolTip_(lastNum  " / " Number ,2,2)

	;IniRead, imagePath , %last_file_list%, File list , %lastNum%
	imagePath:=getLineFromFile(last_file_list,lastNum)
	if(!FileExist(imagePath)){
		;ToolTip_( "lastNum=" lastNum "`n" "no file:`n" imagePath "`n" ini_file_list "`n" Number "`n" A_PriorHotkey,5,1)
		;FileAppend, %  "`n"  "Drozd ScreenSaver. No file "  imagePath  " | " ini_file_list  , %log_file%
		return
	}
	lastImagePath:=imagePath
	smallToFullSize_toggle:=0
	Gdip_draw_Win(GuiHwnd,imagePath)
	
	if(smallToFullSize=0)
		toggle_size:=0	
return


~Right::
~2::
~$F2::
~Numpad9::
~NumpadPgUp::
~WheelRight::
~XButton2::
	foldViewOn:=0, pause_:=0,	zoom_start:=0
	Gosub, active
	if(back_on){
		i+=1	
		if(i=pic_list.Length())
			back_on:=0
		lastImagePath:=pic_list[i] ;,lastNum:=pic_list_n[lastImagePath].lastNum,	last_file_list:=pic_list_n[lastImagePath].last_file_list
		if(!FileExist(imagePath)){
			;ToolTip_("no file:`n" imagePath "`n" ini_file_list "`n" Number "`n" A_PriorHotkey,5,1)
			;FileAppend, %  "`n"  "Drozd ScreenSaver. No file "  imagePath  " | " ini_file_list  , %log_file%
		}
		smallToFullSize_toggle:=0
		Gdip_draw_Win(GuiHwnd,pic_list[i])
		return
	}	
	Gosub, ShowImage
	SetTimer, ShowImage, %time_interval%
	
	if(smallToFullSize=0)
		toggle_size:=0	
return

~Left::
~1::
~$F1::
~Numpad7::
~NumpadHome::
~WheelLeft::
~XButton1::
	Gosub, active
	foldViewOn:=0, pause_:=0,	zoom_start:=0
	if(back_on){
		i-=1
	}else{
		len:=pic_list.Length()
		last:=len-1
		i:=last
		back_on:=1
	}
	if(i>0){
		lastImagePath:=pic_list[i] ;,lastNum:=pic_list_n[lastImagePath].lastNum,	last_file_list:=pic_list_n[lastImagePath].last_file_list
		smallToFullSize_toggle:=0
		Gdip_draw_Win(GuiHwnd,pic_list[i])
		SetTimer, ShowImage, %time_interval%
	}
	
		if(!FileExist(imagePath)){
			;ToolTip_("no file:`n" imagePath "`n" ini_file_list "`n" Number "`n" A_PriorHotkey,5,1)
			;FileAppend, %  "`n"  "Drozd ScreenSaver. No file "  imagePath  " | " ini_file_list  , %log_file%
		}
	
	if(smallToFullSize=0)
		toggle_size:=0	
return

~3:: ; pause
~$F3::
~Numpad0::
~NumpadIns::
	Gosub, active	  
	move_on:=0,  
	if(pause_=1){
		pause_:=0
		SetTimer, ShowImage, %time_interval%
	}else{
		pause_:=1
		;SetTimer, ShowImage, Off	
		SetTimer, ShowImage, 60000		
	}
	ToolTip_("pause= " pause_ "`n" ,1,1)
return

clear_pause:
SetTimer, clear_pause, Off 
	pause_:=0
return

~4::
	Gosub, active
	showPath:=1
	Gdip_draw_Win(GuiHwnd,lastImagePath)
	showPath:=0
	if(pause_!=1)
		SetTimer, ShowImage, % 2*time_interval 
return



~Numpad5::
~NumpadClear::
full_size:
	zoom_start:=0
	Gosub, active
	Gosub, DelayTimer
	if(GetKeyState("LShift", "P")==1){ 
		full_size_pointer:=1
	}
	
	toggle_size:= (smallToFullSize_toggle=1) ? 1 : 0
		
	if(toggle_size=0){
		toggle_size:=1
		;SetTimer, ShowImage, % 4*time_interval	
		Gosub, DelayTimer
		Gdip_draw_Win(GuiHwnd,lastImagePath,1)			
	}else if(toggle_size=1){
		toggle_size:=0
		;SetTimer, ShowImage, % 4*time_interval	
		Gosub, DelayTimer		
		Gdip_draw_Win(GuiHwnd,lastImagePath)	
	}
	full_size_pointer:=0
	
	if(smallToFullSize_toggle=1){
		smallToFullSize_toggle:=0
		toggle_size:=0
	}else{
		smallToFullSize_toggle:=1
	}
return




~Numpad4:: 
~NumpadLeft::
	Gosub, active
	Gosub, DelayTimer
	if(toggle_size=0 && !zoom_start)
		return 
	;SetTimer, ShowImage, %time_interval%
	Gdip_draw_Win(GuiHwnd,lastImagePath,1,"L")
return


~Numpad6::
~NumpadRight:: 
	Gosub, active
	Gosub, DelayTimer
	if(toggle_size=0 && !zoom_start)
		return 
	;SetTimer, ShowImage, %time_interval%
	Gdip_draw_Win(GuiHwnd,lastImagePath,1,"R")
return

~Numpad8::
~NumpadUp::
	Gosub, active
	Gosub, DelayTimer
	if(toggle_size=0 && !zoom_start)
		return 
	;SetTimer, ShowImage, %time_interval%
	Gdip_draw_Win(GuiHwnd,lastImagePath,1,"U")	
return

~Numpad2::
~NumpadDown:: 
	Gosub, active
	Gosub, DelayTimer
	if(toggle_size=0 && !zoom_start)
		return 
	;SetTimer, ShowImage, %time_interval%
	Gdip_draw_Win(GuiHwnd,lastImagePath,1,"D")	
return





/* ~NumpadAdd:: Gosub, ZoomInMouse
~NumpadSub:: Gosub, ZoomOutMouse
~Shift & NumpadSub:: Gosub, ZoomOut
~Shift & NumpadAdd:: Gosub, ZoomIn 
*/

~NumpadSub:: Gosub, ZoomOut
~NumpadAdd:: Gosub, ZoomIn
~Shift & NumpadSub:: Gosub, ZoomOutMouse
~Shift & NumpadAdd:: Gosub, ZoomInMouse

;~NumpadAdd
ZoomIn:
	Gosub, active
	Gosub, DelayTimer
	Gdip_draw_Win(GuiHwnd,lastImagePath,0,0,1)	
return

;~NumpadSub:: ;zoom
ZoomOut:
	Gosub, active
	Gosub, DelayTimer
	Gdip_draw_Win(GuiHwnd,lastImagePath,1,0,2)	
return


WheelDown:: ;zoom out
;~Shift & NumpadSub::
ZoomOutMouse:
	Gosub, active
	Gosub, DelayTimer
	Gdip_draw_Win(GuiHwnd,lastImagePath,1,0,2,1)	
return

WheelUp:: ;zoom in  mouseZoom
;~Shift & NumpadAdd::
ZoomInMouse:
	Gosub, active
	Gosub, DelayTimer
	Gdip_draw_Win(GuiHwnd,lastImagePath,0,0,1,1)	
return

;Gdip_draw_Win(hwnd,imagePath,show_full:=0,move:=0,zoom:=0,mouseZoom:=0,drag*)

/* 
~LButton::
	Menu_on:=0
return

 */
#IfWinActive

DelayTimer:
	if(pause_!=1){
		SetTimer, ShowImage, % 4*time_interval  
		SetTimer, restartTimer, % 4*time_interval 
	}
return

restartTimer:
	SetTimer, restartTimer, Off
	SetTimer, ShowImage, % time_interval  
return

MouseUpd: ;drag
 	MouseGetPos, end_x, end_y
	deltX:=Abs(end_x-begin_x)
	deltY:=Abs(end_y-begin_y)
	if(deltX>4 || deltY>4 ){
		Gdip_draw_Win(GuiHwnd,lastImagePath,0,"Drag",0,0,arr*)
	}	
	
return

WM_LBUTTONDOWN(){
	global begin_x, begin_y, arr
	if(A_Gui=3){
		PostMessage, 0xA1, 2    ; movable borderless window 
	}
	Menu_on:=0
	if(A_Gui=1){
		SetSystemCursor("SIZEALL")
		;SetSystemCursor(32654)
		SetTimer, ShowImage, 60000
		CoordMode, Mouse, Screen
		MouseGetPos, begin_x, begin_y	
		arr:=[begin_x,begin_y]
		SetTimer, MouseUpd, %drag_delay%
		KeyWait, LButton				
		SetTimer, MouseUpd, Off
		SetSystemCursor()
		;SetTimer, ShowImage, % 4*time_interval
	}	
	
}

WM_LBUTTONUP(){
	dragStart:=0
	SetTimer, MouseUpd, Off
	Gosub, DelayTimer
	SetSystemCursor()
}

WM_LBUTTONDBLCLK(){
	Gosub, full_size
}


;=====================================


Set_main_timer:
	SetTimer,Set_main_timer, Off
	SetTimer,main_timer, 300
return

main_timer:
		if(forceStart=1)
			return

	if(A_TimeIdle>closeAfter){
		if(ScrSaverOn){
			Gosub, stopScrSaver	
		}			
		return
	}


 if(A_TimeIdle<1000 && A_TimeIdle> 300 && ScrSaverOn){
		if (GetKeyState("RButton") || Menu_on || GetKeyState("LButton"))
			return

		if A_PriorKey not in %key_exempt_list% 
		{
			if (A_PriorHotkey="~^d") ; forceStart
				return
			Gosub, stopScrSaver
		}
	}else if(A_TimeIdle>timeToStart && !ScrSaverOn && !StandbyOn){
		Gosub, startScrSaver
	}
	
	if WinExist("ahk_class WindowsScreenSaverClass")
		WinClose, ahk_class WindowsScreenSaverClass	
return


openLast:
	Run, %lastImagePath%
return


~^h:: 
	stop_loop:=1
	SetTimer,main_timer, Off
return


;============================================

 
MakeINIfilesList:
	;IniDelete, %settings_ini%,  ini files list 
	j:=0
	outO:=1, outW:=1
	block :=""

	
	Loop, Files, %folderLists%\*.*, F ;R ; D: Include folders F: Include files R: Recurse into subfolders
	{ 
		if(A_LoopFileExt !="ini")
			continue
		if(InStr(A_LoopFileName,"DrozdScreenSaver") || InStr(A_LoopFileName,"DrozdSS")){				
/* 			IniRead, Number , %A_LoopFileLongPath%, File list , LastNumber
			if(Number=="ERROR" || Number=="")
				continue			
			Number:=Format("{1:d}",Number)
			 */			 
			LastNum:=LastNum_Get_FromFile(A_LoopFileLongPath)
			if(!LastNum && LastNum!=0 ){
				MsgBox,4096,, %  "No LastNumber" "`n" A_LoopFileLongPath
				continue
			}
			
			j+=1
			
			if !folderExists(A_LoopFileLongPath){
				MsgBox, 0x00040003,, %  "This folder no longer exists`n`n" folder_(A_LoopFileLongPath) "`n`nDelete its picture list?`n`n" A_LoopFileLongPath ; "Yes" "No" "Cancel" ; +100 "No" as default
					IfMsgBox, Yes
						FileRecycle, % A_LoopFileLongPath
					continue
			}
			obj:=GetWeight(A_LoopFileLongPath)
			outO:=obj.outOn,  outW:=obj.outW
			write_:=A_LoopFileLongPath "|" outW "|" outO
			block:= block j "=" write_ "`n"
			;IniWrite, %write_% , %settings_ini%, ini files list , %j% 			
		}
		x := Mod(A_Index, 10)
    if(x=0){ 
			CoordMode,ToolTip,Screen
			ToolTip_("MakeINIfilesList`n" "j #" j "  " ,4,3)
			;ToolTip %  "j #" j "`n"   "`n" A_LoopFileName , 1480, 700
		}
	}
	ToolTip_( "MakeINIfilesList`n" "j #" j " "  ,5,3)
	IniDelete, %settings_ini%,  ini files list
	IniWrite, %block% , %settings_ini%, ini files list
	
	IniDelete, %settings_ini%,  ini files list , number of files	 
	IniWrite, %j% , %settings_ini%, ini files list , number of files	
	
	;IniDelete, %settings_ini%,  Temp ini files list 
return


getfileLists:
	global fileLists:= Object()
	IniRead, len, %settings_ini%, ini files list ,  number of files 
	j:=0
	Loop, % len+20 {
		IniRead, read_ , %settings_ini%, ini files list , %A_Index% 
		if(read_!="ERROR" && read_!=""){
			arr:=StrSplit(read_,"|"), len:=arr.Length() 
			outOn:= arr[3], outW:= arr[2]
			if !FileExist(arr[1]){
				IniDelete, %settings_ini%,  ini files list , %A_Index% 
				continue
			}
			if(outOn!=1)
				continue
			;IniRead, Number , % arr[1], File list , LastNumber
			Number:=LastNum_Get_FromFile(arr[1])
			Loop, % outW { ; Weight
				n:=j+A_Index
				fileLists[n]:= Object() 
				fileLists[n].file:=arr[1], fileLists[n].num:=	Number 
			}
			j:=n
		}	
	}	
return

;================================

folderExists(ini_file_list){
	imagePath:=getLineFromFile(ini_file_list,1)
	arr:= StrSplit(imagePath,"\") , len:=arr.Length() 
	folder_ := StrReplace(imagePath, arr[len],"")
	if(FileExist(folder_)="D")
		return true
	return false
}

folder_(ini_file_list){
	;IniRead, imagePath , %ini_file_list%, File list , 1
	imagePath:=getLineFromFile(ini_file_list,1)	
	arr:= StrSplit(imagePath,"\") , len:=arr.Length() 
	return folder_ := StrReplace(imagePath, arr[len],"")
}


GetWeight(fileName){
	Loop, 200 {
		IniRead, read_ , %settings_ini%, ini files list , %A_Index% 
		if(read_!="ERROR" && read_!=""){
			if(InStr(read_,fileName)){
				arr:=StrSplit(read_,"|"), len:=arr.Length() 
				outOn:= arr[3] ? arr[3] : 1, outW:= arr[2] ? arr[2] : 1
				break
			}		
		}else{
			outW:=1, outOn:=1
		}
	}
	return {outW:outW,outOn:outOn}
}

;================================


AddFileList:
	Gosub, stopScrSaver
	FileSelectFolder, folderPath , ,2,  Another list of images from this folder will be created	
		if ErrorLevel
			return	
		
	arr:=StrSplit(folderPath,"\"), len:=arr.Length() 
	add_name:= (len>2) ? arr[len-1] "-" arr[len] : arr[len]
	
	CoordMode,ToolTip,Screen
	
	;ini_file:=WorkingDir "\DrozdScreenSaver " add_name ".ini"
	ini_file:=WorkingDir "\DrozdSS " add_name ".ini"
	i:=0
	block :=""
	Gosub, GUI_result
	FileDelete, %ini_file%
	GuiControl,3:, text_1 , % shorten(ini_file,1)
	GuiControl,3:, text_2 , % "from folder " shorten(folderPath)
	
	Loop, Files, %folderPath%\*.*, FR ; D: folders F: files R: Recurse into subfolders
	{      
		if A_LoopFileExt not in %ext_list%
			continue
		i+= 1
		block:= block i "=" A_LoopFileLongPath "`n"
		;IniWrite, %A_LoopFileLongPath% , %ini_file%, File list , %i% 		
		if(Mod(A_Index, 50)=0){  ;A_Index
			GuiControl,3:, out , %  "# " i
		}
		if(inBackground=1 && Mod(A_Index, 20)=0){
			Sleep, 1 ; slower in background	
		}
	}
	ToolTip
	GuiControl,3:, out , %  "Final: # " i
	
	FileAppend, % "LastNumber=" i "`n" block , %ini_file%	
	
	;IniWrite, %block% , %ini_file%, File list  ; block write not work. - too big > 500 000 bytes	
	;IniDelete, %ini_file%, File list , LastNumber 
	;IniWrite, %i%  , %ini_file%, File list , LastNumber 
	
	SoundPlay, *48 
	SoundBeep, 2000, 100
	
	;Gui,3:Destroy
	SetTimer,close_result, -3000
	Gosub, MakeINIfilesList 
	Gosub,  getfileLists
return


;=======================================


RefreshAllFileList:
	ask:=0
	Gosub, MakeINIfilesList 
	IniRead, len, %settings_ini%, ini files list ,  number of files 
MsgBox, 0x00040103,Refresh pictures lists, %  "Found " len " picture lists for " len " folders`n`n"  "`n`nYes - Refresh all pictures lists at once?`nNo - Ask for each list/folder"  
		IfMsgBox, Yes
			ask:=0
		IfMsgBox, No
			ask:=1
		IfMsgBox Cancel
			return

	Gosub, GUI_result
	;len_:=len
	Loop, % len {
		IniRead, read_ , %settings_ini%, ini files list , %A_Index% 
		if(read_!="ERROR" && read_!=""){
			arr:=StrSplit(read_,"|"), ;len:=arr.Length() 
			if !FileExist(arr[1]){
				continue
			}
		
			if(ask=1){
				MsgBox, 0x00040003, , % "Refresh pictures lists for this folder?`n`n" folder_(arr[1]) "`n`n" arr[1]
					IfMsgBox, No
						continue	
					IfMsgBox, Yes
					{
						GuiControl,3:, out_t , %  A_Index "/" len_
						RefreshFileList(arr[1])	
					}
					IfMsgBox Cancel
						{
							Gosub, stop_upd
							return  
						}	
			}else{
				GuiControl,3:, out_t , %  A_Index "/" len_
				RefreshFileList(arr[1])
			}
		}	
		
		if(stop_loop=1){
			MsgBox, 0x00040103,, Stop updating picture lists? ; "Yes" "No" "Cancel" ; +100 "No" as default  ;0x00040003
			IfMsgBox, Yes
				{
					Gosub, stop_upd
					return  
				}	
			stop_loop:=0			
    } 
	}	
	SoundPlay, *48 
	SoundBeep, 2000, 100
	SetTimer,close_result, -3000
	Gosub, MakeINIfilesList 
	Gosub,  getfileLists
	inBackground:=0 
return

stop_upd:
	SetTimer,close_result, -3000
	Gosub, MakeINIfilesList 
	Gosub,  getfileLists
	stop_loop:=0
return

RefreshFileList(ini_file){
	Gosub, stopScrSaver	
	CoordMode,ToolTip,Screen
	folderPath:=folder_(ini_file)
	
	i:=0	
	block :=""
 	;Gosub, GUI_result
	FileDelete, %ini_file%
	GuiControl,3:, text_1 , % shorten(ini_file,1)
	GuiControl,3:, text_2 , % "from folder " shorten(folderPath)
	Loop, Files, %folderPath%\*.*, FR ; D: folders F: files R: Recurse into subfolders
	{      
		if A_LoopFileExt not in %ext_list%
			continue
		i+= 1
		block:= block i "=" A_LoopFileLongPath "`n"
		;IniWrite, %A_LoopFileLongPath% , %ini_file%, File list , %i% 		
		if(Mod(A_Index, 50)=0){  ;A_Index
			GuiControl,3:, out , %  "# " i
		}
		if(inBackground=1 && Mod(A_Index, 20)=0){
			Sleep, 1 ; slower in background	
		}
	}
	ToolTip
	GuiControl,3:, out , %  "Final: # " i
	
	FileAppend, % "LastNumber=" i "`n" block  , %ini_file%
	;IniWrite, %block% , %ini_file%, File list  ; block write not working - too big,  > 500 000 bytes	
	;IniDelete, %ini_file%, File list , LastNumber 
	;IniWrite, %i%  , %ini_file%, File list , LastNumber 
	
	;SoundPlay, *48 
	;SoundBeep, 2000, 100
}


;=======================================

AddFileListMultiFolders:
	Gosub, stopScrSaver	
	
	FileSelectFolder, folderPath , ,2,  A list of images for each subfolder of this folder will be created (one level deep only)
		if ErrorLevel
			return	
		
	str:="", FoldArr:= Object()
	Loop, Files, %folderPath%\*.*, D ;R ; D: folders F: files R: Recurse into subfolders
	{	 
		FoldArr.Push(A_LoopFileLongPath)
		str.= A_LoopFileLongPath "`n"
	}

	MsgBox,4096,, % "Lists of pictures from these subfolders will be created:`n" "`n" str ; "`n" FoldArr[5]
	Gosub, GUI_result
	j:=0
	Loop, % FoldArr.Length() {
		pathF:=FoldArr[A_Index]
		arr:=StrSplit(pathF,"\"), len:=arr.Length() 
		add_name:= (len>2) ? arr[len-1] "-" arr[len] : arr[len]
		;ini_file:=WorkingDir "\DrozdScreenSaver " add_name ".ini"
		ini_file:=WorkingDir "\DrozdSS " add_name ".ini"
		block:=""
		i:=0		
		FileDelete, %ini_file%
		GuiControl,3:, text_1 , % shorten(ini_file,1)
		GuiControl,3:, text_2 , % "from folder " shorten(pathF)
		Loop, Files, %pathF%\*.*, FR ; D: folders F: files R: Recurse into subfolders
		{   
			if A_LoopFileExt not in %ext_list%
				continue
			i+= 1, j+=1
	
			;IniWrite, %A_LoopFileLongPath% , %ini_file%, File list , %i% 	
			block:= block i "=" A_LoopFileLongPath "`n"			
			if(Mod(A_Index, 50)=0){
				GuiControl,3:, out , %  "# " i "   (" j ")"
			}
			if(inBackground=1 && Mod(A_Index, 20)=0){
				Sleep, 1 ; slower in background	
			}
		}
		ToolTip
		GuiControl,3:, out , %  "# " i "   (" j ")"
		FileAppend, % "LastNumber=" i "`n" block , %ini_file%
		;IniDelete, %ini_file%, File list , LastNumber 
		;IniWrite, %i%  , %ini_file%, File list , LastNumber		
		
	}
	GuiControl,3:, out , %  "Final: # " j
	SoundPlay, *48 
	SoundBeep, 2000, 100
	
	;Gui,3:Destroy
	SetTimer,close_result, -3000
	Gosub, MakeINIfilesList 
	Gosub,  getfileLists
return

;====================================

createFileListMain:	
	Gosub, stopScrSaver
	Gosub, AddFileList	
return


RefreshPicLists:
	Gosub, MakeINIfilesList 
	Gosub,  getfileLists
return


main_timer_Off:
	SetTimer,main_timer, Off
return

;=====================================

timeToStart_3m:
timeToStart_5m:
timeToStart_10m:
timeToStart_15m:
	Gosub, stopScrSaver
	RegExMatch(A_ThisMenuItem,"i)(\d+) min",out)
	inp:=Format("{1:d}",out1)
	timeToStart:=inp*60*1000
	IniWrite, %timeToStart%  , %settings_ini%, Screen Saver , start after
	Gosub, TrayTip
return

timeToStart_input:
	Gosub, stopScrSaver
	InputBox, inp,  Drozd Screen Saver - input, time to start in minutes, , 280, 130,,, , , % Round((timeToStart/1000)/60) 
		if ErrorLevel  ;CANCEL
			return
	if(inp>0 && inp<100){
		timeToStart:=inp*60*1000
		IniWrite, %timeToStart%  , %settings_ini%, Screen Saver , start after		
	}
	Gosub, TrayTip
return


time_interval_input:
	Gosub, stopScrSaver
	InputBox, inp,  Drozd Screen Saver time interval, Show images for ... seconds, , 280, 130,,, , , % Round(time_interval/1000) 	
		if ErrorLevel  ;CANCEL
			return
	if(inp>0 && inp<100){
		time_interval:=inp*1000
		IniWrite, %time_interval%  , %settings_ini%, Screen Saver , time interval
	}
	Gosub, TrayTip
return


showPath:
	if(showPath=1){
		showPath:=0
		IniWrite, 0  , %settings_ini%, Screen Saver , show picture path
		Menu, Submenu4, UnCheck, Show picture path on/off  
	}else{
		showPath:=1
		IniWrite, 1  , %settings_ini%, Screen Saver , show picture path
		Menu, Submenu4, Check, Show picture path on/off  
	}
	Gosub, TrayTip
return

TrayTip:
temp_:="forceStart=" forceStart " | StandbyOn= " StandbyOn
Menu, Tray,Tip , % "time to start= " Round((timeToStart/1000)/60) " min." "`ntime interval= " Round(time_interval/1000)  " sec." "`nshow path= " showPath ;"`n" temp_
return

;=====================================
GuiContextMenu: 
	Menu_on:=1
	Menu, ContextMenu, Show, % A_GuiX, % A_GuiY
return

ContextMenuMake:	
	Menu, ContextMenu, Add , Add folder to make pictures list , createFileListMain  ; Add folder to make/refresh pictures list
	Menu, ContextMenu, Icon, Add folder to make pictures list, shell32.dll, 280 ;206 ; 4
	Menu, ContextMenu, Add , Add picture lists from subfolders , AddFileListMultiFolders
	Menu, ContextMenu, Icon, Add picture lists from subfolders , shell32.dll, 279
	Menu, ContextMenu, Add ,
	Menu, ContextMenu, Add , Refresh INI files list , RefreshPicLists	
	Menu, ContextMenu, Add , Refresh all lists of pictures, RefreshAllFileList
	Menu, ContextMenu, Add ,
	Menu, ContextMenu, Add ,Open, openLast
	Menu, ContextMenu, Add ,Open file`'s folder, open_file_folder
	Menu, ContextMenu, Add ,

	Menu, Submenu3, Add, Show picture path on/off  , showPath
	Menu, Submenu3, Check, Show picture path on/off	
	Menu, Submenu3, Add,	
	Menu, Submenu3, Add,  Input - start after, timeToStart_input
	Menu, Submenu3, Add,  3 min , timeToStart_3m
	Menu, Submenu3, Add,  5 min , timeToStart_5m
	Menu, Submenu3, Add,  10 min , timeToStart_10m
	Menu, Submenu3, Add,  15 min , timeToStart_15m
	Menu, Submenu3, Add,
	Menu, Submenu3, Add, Time interval ,time_interval_input
	Menu, Submenu3, Add,
	Menu, Submenu3, Add,  Show time to start `, interval , show_timeToStart	
	Menu, ContextMenu, Add, Time interval`, start after , :Submenu3
	Menu, ContextMenu, Add,
	Menu, ContextMenu, Add, Settings , Settings
	Menu, ContextMenu, Icon , Settings , Shell32.dll, 166
	Menu, ContextMenu, Add , Open settings file , Open_ini
	Menu, ContextMenu, Icon , Open settings file , Shell32.dll, 70
	Menu, ContextMenu, Add,
	Menu, ContextMenu, Add, Help , show_help
	Menu, ContextMenu, Icon, Help , shell32.dll, 24
	Menu, ContextMenu, Add,
	Menu, ContextMenu, Add, Stop screen saver , stopScrSaver 
	Menu, ContextMenu, Icon, Stop screen saver , shell32.dll,  208
	Menu, ContextMenu, Add, Exit , Close 
	Menu, ContextMenu, Icon, Exit, Shell32.dll, 132
	
	Menu, Tray, NoStandard

	Menu, Tray, Add , Add folder to make pictures list , createFileListMain
	Menu, Tray, Icon, Add folder to make pictures list, shell32.dll, 280 ;206 ; 4
	Menu, Tray, Add , Add picture lists from subfolders , AddFileListMultiFolders
	Menu, Tray, Icon, Add picture lists from subfolders , shell32.dll, 279
	Menu, Tray, Add ,
	Menu, Tray, Add , Refresh INI files list , RefreshPicLists	
	Menu, Tray, Add , Refresh all lists of pictures, RefreshAllFileList
	Menu, Tray, Add ,

	Menu, Submenu4, Add, Show picture path on/off  , showPath
	Menu, Submenu4, Check, Show picture path on/off	
	Menu, Submenu4, Add,	
	Menu, Submenu4, Add,  Input - start after, timeToStart_input
	Menu, Submenu4, Add,  3 min , timeToStart_3m
	Menu, Submenu4, Add,  5 min , timeToStart_5m
	Menu, Submenu4, Add,  10 min , timeToStart_10m
	Menu, Submenu4, Add,  15 min , timeToStart_15m
	Menu, Submenu4, Add,
	Menu, Submenu4, Add, Time interval , time_interval_input	
	Menu, Submenu4, Add,
	Menu, Submenu4, Add,  Show time to start`, interval , show_timeToStart	
  

	Menu, Tray, Add, Time interval`, start after, :Submenu4
	Menu, Tray, Add,
	Menu, Tray, Add, Settings , Settings
	Menu, Tray, Icon , Settings , Shell32.dll, 166
	Menu, Tray, Add , Open settings file , Open_ini
	Menu, Tray, Icon , Open settings file , Shell32.dll, 70
	Menu, Tray, Add , Open settings folder , Open_folder	
	Menu, Tray, Icon , Open settings folder , Shell32.dll, 4	
	Menu, Tray, Add ,
	Menu, Tray, Add, Help , show_help
	Menu, Tray, Icon, Help , shell32.dll, 24
	Menu, Tray,  Add ,
	;Menu, Tray,  Add , Start screen saver, startScrSaver	
	Menu, Tray, Add , Edit , Edit
	Menu, Tray, Add, Restart, Reload
	Menu, Tray, Add, Pause, Pause
	Menu, Tray, Add, Start, forceStart
	Menu, Tray, Add, Exit program , Close 
	Menu, Tray, Default, Start
return

show_help:
Progress, zh0 w600 M2 C0 ZX20 ZY20 CWFFFFFF FS8 FM10 WM700 WS400 ,%help%, Drozd Screen Saver , Drozd Screen Saver Help, Segoe UI Semibold
return

;====================================

GUI_result:
	;Gui,3:Destroy
	if WinExist("ahk_id " GuiHwnd_3)
		return
	Gui,3:Color, 120F00 
	Gui,3: -Caption
	Gui,3: +HwndGuiHwnd_3
	Gui,3: Font, S8 cD0D0D0, Arial ;
	Gui,3: Add, Text, x5 y4 w120 cFFFFFF vfiles_num ,  Creating ini file:
	Gui,3: Add, Text, x5 y24 w260 vtext_1 ,  % shorten(ini_file,1) 
	Gui,3: Add, Text, x5 y+6 w260 vtext_2 , % "from folder " shorten(folderPath) 

	Gui,3: Font, S10 w400 cFFFFFF , Tahoma ; Segoe UI
	Gui,3: Add, Text, x60 y70 w120 vout Center,  ;" #" 
	;Gui,3: Font, S9 w700 , Tahoma ; Segoe UI
	Gui,3: Add, Text, x+10 y70 w100  vout_t Center,

	OnMessage(0x201, "WM_LBUTTONDOWN") ; movable borderless window  
	Gui,3: Show,% "x" A_ScreenWidth-280 " y" A_ScreenHeight - 270 " h100 w270" , Drozd_show
	;Gui,3: Show, x1350 y625 h100 w240 , Drozd_show
	Winset, Transcolor, EDF0FF 200, Drozd_show  
return

close_result:
	Gui,3:Destroy
return

shorten(file_path,last:=0){
  arr := StrSplit(file_path, "\")
  len:=arr.Length()
	if(last=1)
		return ".." arr[len] ;StrReplace(arr[len], "Drozd Screen Saver", "")   
	else
	file_path:= (len>2) ? arr[len-1] "\" arr[len] : arr[len]	
  return ".." file_path
}
;====================================

Open_ini:
Gosub, stopScrSaver
Run, %settings_ini%
return

Reload:
Reload
return

Pause:
	Pause
return

array_contains(haystack, needle){	
 if(!isObject(haystack))
  return false
 if(haystack.Length()==0)
  return false
 for k,v in haystack	{
	StringLower,v,v
	StringLower,needle,needle
		v:=Trim(v), needle:=Trim(needle)		
  if(v==needle)
   return true
	}
 return false
}

;==================================== 
 
 


Settings:
Gosub, stopScrSaver
Gosub, getfileListsSett
number:=fileListsSet.length()
;if(number>100)
;	MsgBox,4096,, %  "Not enough room to edit all files." "`n`n"  "Try editing the settings file manually:`n" settings_ini

GuiW:=830 , GuiH:=610
SysGet, MonitorWorkArea, MonitorWorkArea, 1 
scr:=MonitorWorkAreaBottom - MonitorWorkAreaTop
clientArea:=scr-36 
rowsNum:=Round((clientArea-85)/26)-1
SaveX:= 100, SaveY:= clientArea-70
CancelX:=160, CancelY:=clientArea-70

;Gui,4:Destroy
Gui,4:Color, 120F00 
Gui,4:+Resize +Minsize700x330  +HwndGUIhwnd_2
Gui,4: Margin, 0,0
Gui,4:Add, Button , x%SaveX% y%SaveY% w60 h22  gSaveSet , Save
Gui,4:Add, Button , x%CancelX% y%CancelY% w60 h22  gCancel_but , Cancel
Gui,4: Font, S10  Q5, Segoe UI  ;
Gui,4:Add, Text, x330  y10 cFFFFFF  , Pictures lists
Gui,4: Font, S8  Q5, Arial ;
Gui,4:Add, Text, x8 y18 cFFFFFF , Weight   On
Gui,4: Font, S9 cFFFFFF w700, Segoe UI 
Gui,4:Add, Checkbox, x120 y16 w60  vCheck_all gcheck_all Checked, ` All  
Gui,4: Font, S8 cDefault w400 Q5, Arial ;

Loop, %number% {
		;if(A_Index>40)
		;break
		
	if(A_Index==1){
		Gui,4: Font, S8
		Gui,4:Add, Edit, x10 y40 w30 h20 vweight%A_Index%, 
		Gui,4:Font, S9
		Gui,4:Add, Checkbox, x+10 y+-18 Checked  vOn%A_Index%
		Gui,4:Add, Text, x+1 y+-16 r1 cFFFFFF w300 vTxtName%A_Index% gShowName, . 
		Gui,4:Add, Text, x+1   r1 c120F00 w10 vTxt%A_Index% , . 
		
		
	}else if(A_Index=4*(rowsNum-1)+1){
		Gui,4: Font, S8  
		Gui,4:Add, Edit, x1610 y40 w30 h20 vweight%A_Index% , %A_Index%
		Gui,4: Font, S9
		Gui,4:Add, Checkbox, x+10 y+-18 Checked vOn%A_Index%
		Gui,4:Add, Text, x+1 y+-16 r1 cFFFFFF w300 vTxtName%A_Index% gShowName, . 
		Gui,4:Add, Text, x+1   r1 c120F00 w10 vTxt%A_Index% , 
	}else if(A_Index>4*(rowsNum-1)+1){
		Gui,4: Font, S8
		Gui,4:Add, Edit, x1610 y+10 w30 h20 vweight%A_Index% , %A_Index%
		Gui,4: Font, S9
		Gui,4:Add, Checkbox, x+10 y+-18 Checked vOn%A_Index%
		Gui,4:Add, Text, x+1  y+-16 r1 cFFFFFF w300 vTxtName%A_Index% gShowName, .  
		Gui,4:Add, Text, x+1   r1 c120F00 w10 vTxt%A_Index% , 	

	}else if(A_Index=3*(rowsNum-1)+1){
		Gui,4: Font, S8  
		Gui,4:Add, Edit, x1210 y40 w30 h20 vweight%A_Index% , %A_Index%
		Gui,4: Font, S9
		Gui,4:Add, Checkbox, x+10 y+-18 Checked vOn%A_Index%
		Gui,4:Add, Text, x+1 y+-16 r1 cFFFFFF w300 vTxtName%A_Index% gShowName, .  
		Gui,4:Add, Text, x+1   r1 c120F00 w10 vTxt%A_Index% , 
	}else if(A_Index>3*(rowsNum-1)+1){
		Gui,4: Font, S8
		Gui,4:Add, Edit, x1210 y+10 w30 h20 vweight%A_Index% , %A_Index%
		Gui,4: Font, S9
		Gui,4:Add, Checkbox, x+10 y+-18 Checked vOn%A_Index%
		Gui,4:Add, Text, x+1  y+-16 r1 cFFFFFF w300 vTxtName%A_Index% gShowName, .  
		Gui,4:Add, Text, x+1   r1 c120F00 w10 vTxt%A_Index% , 
		

	}else if(A_Index=2*rowsNum-1){
		Gui,4: Font, S8  
		Gui,4:Add, Edit, x810 y40 w30 h20 vweight%A_Index% , %A_Index%
		Gui,4: Font, S9
		Gui,4:Add, Checkbox, x+10 y+-18 Checked vOn%A_Index%
		Gui,4:Add, Text, x+1 y+-16 r1 cFFFFFF w300 vTxtName%A_Index% gShowName, .  	
		Gui,4:Add, Text, x+1   r1 c120F00 w10 vTxt%A_Index% , 		
	}else if(A_Index>2*rowsNum-1){
		Gui,4: Font, S8
		Gui,4:Add, Edit, x810 y+10 w30 h20 vweight%A_Index% , %A_Index%
		Gui,4: Font, S9
		Gui,4:Add, Checkbox, x+10 y+-18 Checked vOn%A_Index%
		Gui,4:Add, Text, x+1  y+-16 r1 cFFFFFF w300 vTxtName%A_Index% gShowName, .  
		Gui,4:Add, Text, x+1   r1 c120F00 w10 vTxt%A_Index% , 	
		


	}else if(A_Index==rowsNum){		
		Gui,4: Font, S8  
		Gui,4:Add, Edit, x410 y40 w30 h20 vweight%A_Index% , %A_Index%
		Gui,4: Font, S9
		Gui,4:Add, Checkbox, x+10 y+-18 Checked vOn%A_Index%
		Gui,4:Add, Text, x+1 y+-16 r1 cFFFFFF w300 vTxtName%A_Index% gShowName, .  	
		Gui,4:Add, Text, x+1   r1 c120F00 w10 vTxt%A_Index% , 
	}else if(A_Index>rowsNum){
		Gui,4: Font, S8
		Gui,4:Add, Edit, x410 y+10 w30 h20 vweight%A_Index% , %A_Index%
		Gui,4: Font, S9
		Gui,4:Add, Checkbox, x+10 y+-18 Checked vOn%A_Index%
		Gui,4:Add, Text, x+1  y+-16 r1 cFFFFFF w300 vTxtName%A_Index% gShowName, .  	
		Gui,4:Add, Text, x+1   r1 c120F00 w10 vTxt%A_Index% ,	
		
	}else{
		Gui,4: Font, S8
		Gui,4:Add, Edit, x10 y+10 w30 h20 vweight%A_Index%, 
		Gui,4: Font, S9
		Gui,4:Add, Checkbox, x+10 y+-18 Checked vOn%A_Index%
		Gui,4:Add, Text, x+1  y+-16 r1 cFFFFFF w300 vTxtName%A_Index% gShowName , . 
		Gui,4:Add, Text, x+1   r1 c120F00 w10 vTxt%A_Index% , 
	}
}
Gui, 4:Show,  , Drozd Screen Saver settings 
Winset, Transcolor, EDF0FF 240, Drozd Screen Saver settings



Gosub, Load_Settings
return


Load_Settings:
i:=0
Loop,	% fileListsSet.length(){
	IniRead, read_ , %settings_ini%, ini files list , %A_Index% 
	if(read_!="ERROR" && read_!=""){
		i+=1
		arr:=StrSplit(read_,"|"), len:=arr.Length() 
		name:=shorten_2(arr[1],folderLists) 
		GuiControl,4:,Txt%i% , % arr[1]
		GuiControl,4:,TxtName%i% , % name
		GuiControl,4:,weight%i%, % arr[2]	
		GuiControl,4:,On%i%, % arr[3]				
	}	
}
return

SaveSet:
	Gui,4: Submit, Nohide
	IniDelete, %settings_ini%, ini files list 
	Loop, % fileListsSet.length(){
		GuiControlGet,outT ,4:, Txt%A_Index%  
		GuiControlGet,outW ,4:, weight%A_Index% 
		GuiControlGet,outO ,4:, On%A_Index% 
		write_:=outT "|" outW "|" outO		
		IniWrite, %write_% , %settings_ini%, ini files list , %A_Index%
		j:=A_Index
	}
	IniWrite, %j% , %settings_ini%, ini files list , number of files
Gui,4: Destroy
Gosub, getfileLists
return

4GuiClose:
Cancel_but:
Gui,4: Destroy
return



4GuiSize:
GuiControl Move, Button1, %  "x"  (A_GuiWidth/2-40) "y" . (A_GuiHeight-30)
GuiControl Move, Button2, %  "x"  (A_GuiWidth/2+40) "y" . (A_GuiHeight-30)
return

getfileListsSett:
	global fileListsSet:= Object() 
	j:=0
	
	Loop, Files, %folderLists%\*.*, F ;R ; D: Include folders F: Include files R: Recurse into subfolders
	{ 
		if(A_LoopFileExt !="ini")
			continue		 		
		if(InStr(A_LoopFileName,"DrozdScreenSaver") || InStr(A_LoopFileName,"DrozdSS")){	
			;IniRead, Number , %A_LoopFileLongPath%, File list , LastNumber
			Number:=LastNum_Get_FromFile(A_LoopFileLongPath)
			if(Number=="ERROR" || Number=="")
				continue
			j+=1
			Number:=Format("{1:d}",Number)
			fileListsSet[j]:= Object() 
			name:=A_LoopFileLongPath	
			name:=shorten_2(name,folderLists)			
			fileListsSet[j].file:=A_LoopFileLongPath
			fileListsSet[j].name:=name , fileListsSet[j].num:=	Number 
			fileListsSet[j].freq:=1		
				
		}		
	}
return

shorten_2(name,folder){
	name:=RegExReplace(name,"i)" "\Q" folder "\E","")
	name:=RegExReplace(name,"i)DrozdScreenSaver","")
	name:=RegExReplace(name,"i)\\","..")
  return name
}



ShowName: ;gShowName
RegExMatch(A_GuiControl,"im)\d+", num_)  ;Txt%A_Index% TxtName%A_Index%
GuiControlGet,out ,4:, Txt%num_%
MsgBox,4096,, % out  
return


check_all: ;gcheck_all
  GuiControlGet, Check_all, , Check_all
  if(Check_all==1){
	  Loop %number% { 
		  GuiControl, , On%A_Index% , 1 
	  }
  }else if(Check_all==0){
	  Loop %number% { 
		  GuiControl, , On%A_Index% , 0 
	  } 
  }
return

;==================================== 

show_timeToStart:
	Gosub, stopScrSaver
	MsgBox,4096,, % "Start screen saver after " Round((timeToStart/1000)/60) " min" "`nShow images for " Round(time_interval/1000) " sec" "`n" "showPath=" showPath , 5
return
 
show_fileLists:
str:=""
Loop, % fileLists.Length(){
 str.=fileLists[A_Index].file " | " fileLists[j].num  "`n" 
}
MsgBox,4096,, % str
return

Open_folder:
	Run  %WorkingDir% 
Return

open_file_folder:
	arr:= StrSplit(lastImagePath,"\") , len:=arr.Length() 
	SelectFilePath:=arr[len]
	Run, % "Explorer.exe" " " StrReplace(imagePath, arr[len],"")
	;Gosub, stopScrSaver	
return

Edit:
  Process, Exist, SciTE.exe  ; not to destroy session
  PID := Errorlevel
  if !PID{
    Run , "C:\Program Files\AutoHotkey\SciTE\SciTE.exe"
    WinWaitActive, ahk_class SciTEWindow
  }
  Run, "C:\Program Files\AutoHotkey\SciTE\SciTE.exe" "%A_ScriptFullPath%"

return
;==================================== 

ToolTip_(tekst,t:=2,screen:=0,which:=1){
	global MonitorWorkAreaBottom,	MonitorWorkAreaRight
	if(screen){
		CoordMode, ToolTip,Screen		
		if(screen==2){
			ToolTip, %tekst%,% MonitorWorkAreaRight-200 , % MonitorWorkAreaBottom-30
		}else if(screen==1){	
			ToolTip, %tekst%,% (MonitorWorkAreaRight/2)+400 , % MonitorWorkAreaBottom-30
		}else if(screen==3){				
			ToolTip, %tekst%,% MonitorWorkAreaRight-200 , % MonitorWorkAreaBottom-200		
		}else{
			ToolTip, %tekst%,% (MonitorWorkAreaRight/2)-400 , % MonitorWorkAreaBottom/2
		}	
	}else{
		CoordMode , ToolTip, Relative
		GuiControlGet, Pos, Pos, edit_1
		tipX:= PosX+ 4, tipY:=PosY +2
		ToolTip, %tekst% ,%tipX%, %tipY%, %which%
	}
	t:=t*1000
	Settimer, ToolTip_close , -%t%

}

	ToolTip_close:
	Settimer, ToolTip_close , Off
	ToolTip
	return	
	
;==================
SetSystemCursor(Cursor:=""){ ; Flipeador
    Static Cursors := {APPSTARTING: 32650, ARROW: 32512, CROSS: 32515, HAND: 32649, HELP: 32651, IBEAM: 32513, NO: 32648, SIZEALL: 32646, SIZENESW: 32643, SIZENS: 32645, SIZENWSE: 32642, SIZEWE: 32644, UPARROW: 32516, WAIT: 32514}
    If (Cursor == "")
        Return DllCall("User32.dll\SystemParametersInfoW", "UInt", 0x0057, "UInt", 0, "Ptr", 0, "UInt", 0)
    Cursor := InStr(Cursor, "3") ? Cursor : Cursors[Cursor]
    For Each, ID in Cursors
    {
        hCursor := DllCall("User32.dll\LoadImageW", "Ptr", 0, "Int", Cursor, "UInt", 2, "Int", 0, "Int", 0, "UInt", 0x00008000, "Ptr")
        hCursor := DllCall("User32.dll\CopyIcon", "Ptr", hCursor, "Ptr")
        DllCall("User32.dll\SetSystemCursor", "Ptr", hCursor, "UInt",  ID)
    }
} ; https://msdn.microsoft.com/en-us/library/windows/desktop/ms648395(v=vs.85).aspx

	
;====================================

;^g:: Gosub, test

test:
Gosub, TrayTip
return



GuiClose:
Close:
;Esc:: 
WinShow, ahk_class Shell_TrayWnd
Gdip_Shutdown(pToken)
Gui,3:Destroy
ExitApp
