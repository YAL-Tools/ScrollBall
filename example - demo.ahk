#SingleInstance Force
#include "ScrollBall.ahk"

; This is used to record the demo GIF that you see in the repository

mouse := ScrollBall.Config()
mouse.conditions := ScrollBall.ManualStart()

wheel := ScrollBall.Config()
wheel.xAxis.scroller := ScrollBall.KeyScroller("^{PgUp}", "^{PgDn}")
wheel.xAxis.pixelsPerStep := 80

arrows := ScrollBall.Config()
arrows.unlockDelay := 30
arrows.xAxis.scroller := ScrollBall.KeyScroller("{left}", "{right}")
arrows.yAxis.scroller := ScrollBall.KeyScroller("{up}", "{down}")
arrows.xAxis.pixelsPerStep := 20
arrows.yAxis.pixelsPerStep := 30
arrows.xAxis.lockThreshold := 30
arrows.yAxis.lockThreshold := 30

media := ScrollBall.Config()
media.yAxis.scroller := ScrollBall.KeyScroller("{Volume_Up}", "{Volume_Down}")
media.xAxis.scroller := ScrollBall.KeyScroller("{Media_Prev}", "{Media_Next}")
media.xAxis.pixelsPerStep := 80

class WindowMover extends ScrollBall.Scroller {
	__New(isVertical) {
		this.isVertical := isVertical
		this.stepped := false
	}
	Apply(delta) {
		winDelay := SetWinDelay(-1)
		hwnd := WinExist("A")
		cx := 0
		cy := 0
		WinGetPos(&cx, &cy, , , hwnd)
		if this.isVertical {
			WinMove(, cy + delta, , , hwnd)
		} else {
			WinMove(cx + delta, , , , hwnd)
		}
		SetWinDelay(winDelay)
	}
}
mover := ScrollBall.Config()
mover.diagonals := true
mover.xAxis.scroller := WindowMover(false)
mover.xAxis.pixelsPerStep := 1
mover.yAxis.scroller := WindowMover(true)
mover.yAxis.pixelsPerStep := 1

sb := ScrollBall(mouse)
+F1::sb.config := mouse
+F2::sb.config := wheel
+F3::sb.config := arrows
+F4::sb.config := media
+F5::sb.config := mover

sb.deviceID := 2137527569
configs := [mouse, wheel, arrows, media, mover]
config_id := 1
VKDC::{ ; Backslash
	global config_id, configs
	config_id := 1 + Mod(config_id, configs.Length)
	trace("Config is now #" config_id)
	sb.config := configs[config_id]
}

trace("hi!")
sb.Listen()
