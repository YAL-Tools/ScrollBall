#SingleInstance Force
#include "ScrollBall.ahk"

; This example enters scrolling mode when pressing Alt+S

sb := ScrollBall()
sb.config.unlockDelay := 100
sb.config.conditions := ScrollBall.ManualStart()
sb.deviceID := "any"
sb.Listen()

!s::sb.Start()
