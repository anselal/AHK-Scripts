#NoTrayIcon
#SingleInstance off 
#NoEnv

;Run, text-to-speech.ahk "text" "speed" "loudness"

text:=""  ;"text-to-speech test" 

speed:=0  	; speed: from -10 to 10 ; 0 is default
loudness:=100 ; loudness: from 0 to 100

param1= %1%   
param2= %2% 
param3= %3% 

if(param1){
   text=%param1%
}

if(!text)
  ExitApp


if(param2){  
  if (param2 is integer) && (param2<=10) && (param2>=-10) 
  speed:=param2 
}

if(param3){  
  if (param3 is integer) && (param3<=100) && (param3>0) 
  loudness:=param3 
}

text:=RegExReplace(text,"im)(\d\d):(\d\d) ?(?:h|hour)?",", hour $1,$2") ; fix the loony USA "military time": 18:00="eighteen hundred hours" lol

oVoice := ComObjCreate("SAPI.SpVoice") 
oVoice.Rate := speed		
oVoice.Volume := loudness

oVoice.Speak(text)

ExitApp

	