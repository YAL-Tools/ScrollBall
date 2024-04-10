#SingleInstance Force
#include "ScrollBall.ahk"
Persistent

; This example allows you to scroll with any pointing device while Left Alt is held.
; Note that this doesn't mask Alt itself, so this might trigger alt+wheel shortcuts.
; For your own uses, consider remapping some key to an uncommon one (F13/etc.)
sb := ScrollBall()
sb.config.conditions := ScrollBall.KeyHoldConditions("LAlt", true)
sb.deviceID := "any"
sb.Listen()
