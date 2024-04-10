#SingleInstance Force
#include "ScrollBall.ahk"
Persistent

sb := ScrollBall()
; sb.xAxis.enabled := false ; disable horizontal scrolling?
sb.Listen()
