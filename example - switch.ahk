#SingleInstance Force
#include "ScrollBall.ahk"

; This example shows how to switch between wheel/arrow keys configurations
; when a shortcut (Alt+C in this case) is pressed.

wheelConfig := ScrollBall.Config()

arrowConfig := ScrollBall.Config()
arrowConfig.xAxis.scroller := ScrollBall.KeyScroller("{left}", "{right}")
arrowConfig.yAxis.scroller := ScrollBall.KeyScroller("{up}", "{down}")
arrowConfig.yAxis.lockThreshold := 40
arrowConfig.xAxis.lockThreshold := 40
arrowConfig.xAxis.pixelsPerStep := 20
arrowConfig.yAxis.pixelsPerStep := 30

sb := ScrollBall(wheelConfig)
!c::{
	if sb.config == wheelConfig {
		sb.config := arrowConfig
		trace("Now using arrows")
	} else {
		sb.config := wheelConfig
		trace("Now using wheel")
	}
}
sb.Listen()
