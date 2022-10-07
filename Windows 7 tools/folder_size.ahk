#SingleInstance force
Menu, Tray, Icon, shell32.dll, 81
;Menu, Tray, NoStandard
Menu, Tray, Add , Edit Scite, Edit_Scite
Menu, Tray, Add , Edit Notepad, Edit_Notepad
Menu, Tray, Add, Exit , Close ; double click tray icon to exit
Menu, Tray, Default, Exit 

SetWinDelay, -1
SetControlDelay, -1
SetBatchLines, -1 

subfolders:=1
;WhichFolder=%A_ScriptDir%

param1= %1%   
param2= %2% 

if(param1){
	 WhichFolder:=param1
}

if(!FileExist(WhichFolder)){
	MsgBox,4096,, %   "folder size`n"  "No folder`n" WhichFolder
	ExitApp
}


if(param2=0){
   subfolders:=param2 
}


fileSize(bytes){
      size=
      ;SetFormat Float, 0.2 ;Floor to 2 decimal
      if(bytes >= 1073741824){
				size:=Round(bytes/1073741824,3)
				size := size " GB"
      }else if (bytes >= 1048576) {
				size:=Round(bytes/1048576,2)
				size := size " MB"
      }else if (bytes >= 1024) {	
				size:=Round(bytes/1024)
        size := size " KB"
      }else if(bytes = 0) {	
				size:="Ø"
      }else{
        size := bytes
        size := size " bytes"
      }      
				return size
}

d_n(num,n:=12){ ;num_to_length
  len:=StrLen(num)
  if(len<n){
    loop, % n-len{
      num:=num . "0"
    }    
  }
  return num
}

d_(str,n:=10){ ;str_to_length
  len:=StrLen(str)
  if(len<n){
    str2:=str
    loop, % n-len{
      str2:=str2 . " "
    }    
  }
  return str2
} 



FolderSize = 0
; Loop, FilePattern,IncludeFolders,Recurse ;1 Subfolders , 2 Only folders are retrieved, 0 only files
Loop, %WhichFolder%\*.*, , %subfolders%  ; 1 subfolders 
{
	;if(!RegExMatch(A_LoopFileExt,"i)lnk")){
		i+=1
    FolderSize += %A_LoopFileSize%		
	;} 
}   

 sizeKB:=Round(FolderSize/1024)

sep:="            "
report1:= "Size of folder:  " sizeKB " KB" "`n`n" sep sep fileSize(FolderSize) 

if(subfolders=0){
	report1:=report1 "`n`n" sep      "(not including subfolders)"
}else{
	report1:=report1 "`n`n   "  sep sep sep sep sep
}
	
		report4:=""
		report1:= "Folder size:  " sizeKB " KB" ;d_(" ",10)
		report2:= fileSize(FolderSize)  ; d_(" ",18)
		report4:= "# " i " files"
		if(subfolders=0){
			report4:= "# " i " files" "  (not including subfolders)"
		}
		;MsgBox,4096,, % WhichFolder "`n`n" report1 "`n`n"    ; 4096 Modal (always on top)
		Gosub, Show_report1

return

Show_report1:
Gui,2: +Resize  +Minsize300x130 ; -border
Gui,2:-MinimizeBox -MaximizeBox +AlwaysOnTop
Gui,2:Color, F6F6F6 ;FEFEFE ;
Gui,2:Font, s8 w400, Tahoma
Gui,2:Add, Text,c000000 , % WhichFolder
Gui,2:Font, s10 w400, Tahoma
Gui,2:Add, Text,c000000 , % report1
Gui,2:Font, s12 w800, % Tahoma
Gui,2:Add, Text,cDD0000 , % report2
Gui,2:Font, s8 w400, Tahoma
Gui,2:Add, Text,h30, % report4 
Gui,2:Font, s10, w800 Tahoma
Gui,2:Add, Button, W80 Default, OK
Gui,2:Font, s5
Gui,2:Add, Text,,
Gui,2:Show,, Msg: Folder size
SoundPlay, *-1
Gui,2:+LastFound
WinWaitClose
ExitApp






 
;GuiEscape:
ButtonOK:
Gui, Destroy
ExitApp
return

GuiSize:
;GuiControlGet, Button3, Pos
GuiControlGet, But, Pos, Button3 
GuiControl, Move, Button3, % "x" (A_GuiWidth-ButW)//2
return

2GuiEscape:
2ButtonOK:
Gui,2: Destroy
return

2GuiSize:
SetBatchLines, -1
GuiControlGet, Button,2: Pos, Button1 
GuiControl,2: Move, Button1, % "x" (A_GuiWidth-ButtonW)//2
GuiControlGet, tex,2: Pos, Static3 
GuiControl,2: Move, Static3, % "x" (A_GuiWidth-texW)//2

GuiControlGet, tex1,2: Pos, Static2 
GuiControl,2: Move, Static2, % "x" (A_GuiWidth-tex1W)//2
GuiControlGet, tex2,2: Pos, Static4 
GuiControl,2: Move, Static4, % "x" (A_GuiWidth-tex2W)//2
SetBatchLines,10ms
return



Edit_Notepad:
Run, "C:\Program Files\Misc\Notepad2\Notepad2.exe" "%A_ScriptFullPath%"
return

Edit_Scite:
Run, "C:\Program Files\AutoHotkey\SciTE\SciTE.exe"  "%A_ScriptFullPath%"
return

GuiClose:
Close:
Esc:: 
ExitApp



;Run, C:\Program Files\Misc\AutoHotkey Scripts\folder_size.ahk "%fold_path%" "0" 