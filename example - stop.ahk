#SingleInstance Force
#include "ScrollBall.ahk"

; This example toggles scrolling mode when pressing Alt+S

sb := ScrollBall()
sb.config.unlockDelay := 0
sb.config.conditions := ScrollBall.ManualStart()
sb.deviceID := "any"
sb.Listen()

!s::{
	if sb.active {
		sb.Stop()
	} else {
		sb.Start()
	}
}
