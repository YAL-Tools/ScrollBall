global stdout_ready := false
/*
Quick tip now that I see that the image say Cyrillic.
Save the script with BOM (UTF-16 in this case) and use the exclusive mode in the FileOpen() so you can pass an encoding and actually works
FileOpen("*", 0x1, "UTF-16") or FileOpen("*", 0x1, 1200)
*/

trace(params*) {
	global stdout_ready, stdout
	if (!stdout_ready) {
		stdout_ready := true
		DllCall("AllocConsole")
		stdout := FileOpen("*", "w")
	}
	for i,v in params {
		if (i > 1)
			stdout.Write(" ")
		stdout.Write(v)
	}
	stdout.Write("`r`n")
	tmp := stdout.Handle
}
;trace("hello!")