#Requires AutoHotkey v2.0
; A script converting CAPSLOCK key to act as the ESC key when tapped on its own or as a CTRL key when held down as part of a chord. 
; Examples:
; Press CAPSLOCK for < 0.5s, no other keys held down as part of chord --> equivalent to tapping ESC
; CAPSLOCK + W --> Ctrl+W
; CAPSLOCK+Shift+W --> Ctrl+Shift+W
; Shift + tap CAPSLOCK (capslock pressed as final key in chord) --> Shift+Esc
; Hold CAPSLOCK for >0.5s, no other keys held down as part of chord --> holding Ctrl until CAPSLOCK is released

; warning: using any shortcut that involves Esc requires CapsLock (which maps to Esc) to be the final key in the chord

; TODO: investigate Ctrl clicking using CAPSLOCK, such as for opening links in a new tab. Script currently does not consider mouse inputs. 

; Initialize InputHook used to detect additional keypresses
global ih := InputHook("L1 V T0.5") 
; L1 = stop after 1 character
; V = visible (transparent mode)
; T0.5 = timeout after 0.5 seconds (in testing & subject to change. Means that an accidental press can be held to cancel the esc input)
ih.KeyOpt("{All}", "E") ; Treat ALL keys as "End Keys" (triggers stop)

; CapsLock key pressed
; * allows other modifiers to be held at the same time 
; $ prevents this hotkey from triggering itself
*$CapsLock::{

    Send "{Blind}{LCtrl Down}" ; send ctrl down immediately
    ; thus if any key is pressed while holding CapsLock, it is treated as though Ctrl is held

    ; start InputHook to detect additional keypresses
    ;   if any key is pressed, the InputHook will stop automatically which signals to $CapsLock Up that
    ;   the user desires a Ctrl hold behavior (as why else would they press another key?)
    ih.Start()
    ih.Wait()
}
; CapsLock key released
*$CapsLock Up::{
    Send "{Blind}{LCtrl Up}" ; release ctrl regardless of mode

    if (ih.InProgress = 1) { ; means InputHook is still running, so no additional key was pressed
        ; implying the user is not attempting a chord and therefore wants an Esc tap
        ih.Stop() ; stop InputHook
        Send "{Blind}{Esc}" ; and send Esc
    }    
}

; Esc key toggles CAPSLOCK
$Esc::{
    static toggle := 0
    toggle := !toggle
    if toggle {
        SetCapsLockState "On"
    } else {
        SetCapsLockState "Off"
    }
}