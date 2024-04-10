#SingleInstance Force
#include "ScrollBall.ahk"
Persistent

sb := ScrollBall()
;
sb.config.xAxis.pixelsPerStep := 20
sb.config.yAxis.pixelsPerStep := 30
;
sb.config.xAxis.scroller := ScrollBall.KeyScroller("{left}", "{right}")
sb.config.yAxis.scroller := ScrollBall.KeyScroller("{up}", "{down}")
;
sb.Listen()
