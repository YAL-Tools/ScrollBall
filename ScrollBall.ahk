#include "trace.ahk"

class ScrollBall {
	deviceID := "select"
	selectThreshold := 100
	
	; shows mouse lock/unlock, for unlockDelay troubleshooting
	showLockUnlock := false
	
	; per-axis configurations
	xAxis := ScrollBall.Axis("X")
	yAxis := ScrollBall.Axis("Y")
	__New(config := ScrollBall.Config()) {
		this.config := config
	}
	
	active := false
	selectDistances := Map()
	lockedAxis := 0
	
	class Config {
		unlockDelay := 50
		conditions := ScrollBall.Conditions()
		diagonals := false
		xAxis := ScrollBall.AxisConfig()
		xAxis.scroller := ScrollBall.WheelScroller(false)
		yAxis := ScrollBall.AxisConfig()
		yAxis.scroller := ScrollBall.WheelScroller(true)
	}
	class AxisConfig {
		pixelsPerStep := 12
		scroller := ScrollBall.Scroller()
		lockThreshold := 0
		enabled := true
	}
	
	; conditions
	class Conditions {
		CanStart() => true
		ShouldStop() => false
	}
	class ManualStart extends ScrollBall.Conditions {
		CanStart() => false
	}
	class KeyHoldConditions extends ScrollBall.Conditions {
		holdKey := ""
		stopOnRelease := false
		__New(key, stopOnRelease) {
			this.holdKey := key
			this.stopOnRelease := stopOnRelease
		}
		CanStart() => GetKeyState(this.holdKey)
		ShouldStop() => this.stopOnRelease and not GetKeyState(this.holdKey)
	}
	
	; scrollers
	class Scroller {
		stepped := true
		Apply(dir) {
			
		}
	}
	class WheelScroller extends ScrollBall.Scroller {
		isVertical := false
		flags := 0
		scale := 120
		sign := 1
		__New(isVertical, scale := 120) {
			static MOUSEEVENTF_HWHEEL := 0x01000
			static MOUSEEVENTF_WHEEL := 0x0800
			this.isVertical := isVertical
			this.flags := isVertical ? MOUSEEVENTF_WHEEL : MOUSEEVENTF_HWHEEL
			this.scale := scale
		}
		Apply(dir) {
			DllCall("mouse_event",
				"int", this.flags,
				"int", 0,
				"int", 0,
				"int", this.scale * dir * (this.isVertical ? -1 : 1),
				"uptr", 0
			)
		}
	}
	class KeyScroller extends ScrollBall.Scroller {
		up := ""
		down := ""
		__New(keyUp, keyDown) {
			this.up := keyUp
			this.down := keyDown
		}
		Apply(dir) {
			if dir < 0 {
				Send(this.up)
			} else {
				Send(this.down)
			}
		}
	}
	
	class Axis {
		accMove := 0
		accLock := 0
		__New(name) {
			this.name := name
			this.scroller := ScrollBall.WheelScroller(name == "Y")
		}
		Stop() {
			this.accMove := 0
			this.accLock := 0
		}
		Move(delta, parent, config) {
			if not config.enabled or config.pixelsPerStep == 0 {
				return
			}
			if config.lockThreshold > 0 and parent.lockedAxis == 0 {
				this.accLock += Abs(delta)
				if this.accLock >= config.lockThreshold {
					parent.lockedAxis := this
				}
			}
			delta /= config.pixelsPerStep
			
			; flip on direction change so that we don't have to move 2 steps
			if delta > 0 {
				this.accMove := this.accMove < 0 ? delta : this.accMove + delta
			} else {
				this.accMove := this.accMove > 0 ? delta : this.accMove + delta
			}
			
			steps := this.accMove
			steps := steps >= 0 ? Floor(steps) : -Floor(-steps)
			if steps != 0 {
				this.accMove -= steps
				if config.scroller.stepped {
					if steps > 0 {
						while steps > 0 {
							config.scroller.Apply(1)
							steps -= 1
						}
					} else {
						while steps < 0 {
							config.scroller.Apply(-1)
							steps += 1
						}
					}
				} else {
					config.scroller.Apply(steps)
				}
			}
		}
	}
	
	Listen() {
		sizeof_RAWINPUTDEVICE := 2 + 2 + 4 + A_PtrSize
		pRAWINPUTDEVICE := Buffer(sizeof_RAWINPUTDEVICE)
		NumPut(
			"ushort", 1,
			"ushort", 0x02, ; mouse
			"uint", 0x100, ; RIDEV_INPUTSINK
			"uptr", A_ScriptHwnd,
			pRAWINPUTDEVICE
		)

		if (DllCall("RegisterRawInputDevices",
			"uptr", pRAWINPUTDEVICE.Ptr,
			"uint", 1,
			"uint", sizeof_RAWINPUTDEVICE,
		) == 0) {
			trace("Failed to RegisterRawInputDevices")
			Exit(1)
		}
		
		this.__OnRawInput_bound := this.OnRawInput.Bind(this)
		OnMessage(0x00FF, this.__OnRawInput_bound)
		
		if this.deviceID == "select" {
			trace("Move the desired pointing device a little bit.")
		}
	}
	
	__StartAt(mx, my) {
		static clipRect := Buffer(4 * 4)
		NumPut(
			"int", mx,
			"int", my,
			"int", mx + 1,
			"int", my + 1,
			clipRect
		)
		DllCall("ClipCursor",
			"uptr", clipRect.Ptr
		)
		this.active := true
		
		if this.showLockUnlock {
			trace("lock")
		}
		;SetTimer(this.__Stop_bound, this.config.unlockDelay)
	}
	
	Start() {
		static cursorPos := Buffer(4 * 2)
		DllCall("GetCursorPos",
			"uptr", cursorPos.Ptr,
		)
		mx := NumGet(cursorPos, 0, "int")
		my := NumGet(cursorPos, 4, "int")
		this.__StartAt(mx, my)
	}
	
	Stop() {
		if not this.active {
			return
		}
		this.active := false
		this.lockedAxis := 0
		this.xAxis.Stop()
		this.yAxis.Stop()
		
		DllCall("ClipCursor", "uptr", 0)
		SetTimer(this.__Stop_bound, 0)
		
		if this.showLockUnlock {
			trace("unlock")
		}
	}
	; can't SetTimer a method without binding it
	__Stop_bound := this.Stop.bind(this)
	
	lastAbsX := 0
	lastAbsY := 0
	hasLastAbs := false
	OnRawInput(wParam, lParam, msg, hwnd) {
		Critical
		static RID_INPUT := 0x10000003
		static MOUSE_MOVE_ABSOLUTE := 0x01
		;
		static sizeof_RAWINPUTHEADER := 4 + 4 + A_PtrSize * 2
		static offsetof_RAWMOUSE_flags := sizeof_RAWINPUTHEADER
		static offsetof_RAWMOUSE_x := offsetof_RAWMOUSE_flags + 4 + 4 + 4
		static offsetof_RAWMOUSE_y := offsetof_RAWMOUSE_x + 4
		
		pcbSize := 0
		if DllCall("GetRawInputData",
			"uptr", lParam,
			"uint", RID_INPUT,
			"uptr", 0,
			"uint*", &pcbSize,
			"uint", sizeof_RAWINPUTHEADER,
		) != 0 {
			trace("Failed to fetch raw input header size")
			return 0
		}
		
		pData := Buffer(pcbSize, 0)
		if DllCall("GetRawInputData",
			"uptr", lParam,
			"uint", RID_INPUT,
			"uptr", pData.Ptr,
			"uint*", &pcbSize,
			"uint", sizeof_RAWINPUTHEADER,
		) < 0 {
			trace("Failed to fetch raw input header")
			trace("GetLastError is " A_LastError)
			return 0
		}
		
		hDevice := NumGet(pData, 4 + 4, "uptr")
		if Type(this.deviceID) != "String" && hDevice != this.deviceID {
			return 0
		}
		
		dx := NumGet(pData, offsetof_RAWMOUSE_x, "int")
		dy := NumGet(pData, offsetof_RAWMOUSE_y, "int")
		
		usFlags := NumGet(pData, offsetof_RAWMOUSE_flags, "ushort")
		if (usFlags & MOUSE_MOVE_ABSOLUTE) != 0 {
			; if this is a tablet, we need to calculate delta ourselves
			if (this.hasLastAbs) {
				dx -= this.lastAbsX
				this.lastAbsX += dx
				dy -= this.lastAbsY
				this.lastAbsY += dy
			} else {
				this.hasLastAbs := true
				this.lastAbsX := dx
				this.lastAbsY := dy
				dx := 0
				dy := 0
			}
		}
		
		if dx == 0 and dy == 0 {
			; nothing to do here! (probably a scroll/click event)
			return 0
		}
		if not this.config.diagonals {
			; if diagonal motions are disabled, find the primary (larger absolute value) axis
			; and ignore motion from the other axis
			if Abs(dx) > Abs(dy) {
				dy := 0
				; and reset accumulators on direction change?
				; Feels weird if you accidentally do a digonal input
				;this.yAxis.accMove := 0
				;this.yAxis.accLock := 0
			} else {
				dx := 0
				;this.xAxis.accMove := 0
				;this.xAxis.accLock := 0
			}
		}
		
		if this.deviceID == "select" {
			currDist := this.selectDistances.Get(hDevice, 0)
			currDist += Sqrt(dx * dx + dy * dy)
			if currDist >= this.selectThreshold {
				this.deviceID := hDevice
				trace("")
				trace("Selected device " hDevice ".")
				trace("You can avoid this prompt in future by assigning ")
				trace("sb.deviceID := " hDevice)
				trace("on your ScrollBall class reference.")
				trace("")
				trace("If you have just accidentally locked your primary device,")
				trace("you can focus this window with Alt+Tab and close it with Alt+F4")
				trace("")
			} else {
				this.selectDistances.Set(hDevice, currDist)
				return 0
			}
		}
		
		if this.deviceID == "debug" {
			trace("device: " hDevice " dx: " dx " dy: " dy)
			return 0
		}
		
		static clipRect := Buffer(4 * 4)
		DllCall("GetClipCursor", "uptr", clipRect.Ptr)
		
		if (NumGet(clipRect, 8, "int") > NumGet(clipRect, 0, "int") + 1
			or NumGet(clipRect, 12, "int") > NumGet(clipRect, 4, "int") + 1
		) and this.config.conditions.CanStart() {
			; not a 1x1 area => not clipped yet!
			
			; rewind the cursor:
			static cursorPos := Buffer(4 * 2)
			DllCall("GetCursorPos", "uptr", cursorPos.Ptr)
			mx := NumGet(cursorPos, 0, "int") - dx
			my := NumGet(cursorPos, 4, "int") - dy
			DllCall("SetCursorPos", "int", mx, "int", my)
			
			this.__StartAt(mx, my)
		} else if this.active && this.config.conditions.shouldStop() {
			this.Stop()
			return 0
		}
		
		if not this.active {
			return 0
		}
		
		if dx != 0 and this.lockedAxis != this.yAxis {
			this.xAxis.Move(dx, this, this.config.xAxis)
		}
		if dy != 0 and this.lockedAxis != this.xAxis {
			this.yAxis.Move(dy, this, this.config.yAxis)
		}
		
		SetTimer(this.__Stop_bound, this.config.unlockDelay)
		Critical false
	}
}
