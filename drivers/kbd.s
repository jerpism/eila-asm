[bits 32]

global kb_handler
extern print_char

SECTION .text

kb_handler:
    in      al, 0x60
    movzx   eax, al
    movzx   eax, byte [kb_map + eax]
    call print_char
    ret


kb_map:
    db 0                ; 0x00 not valid
    db 27               ; 0x01 escape
    db "1","2","3","4"  ; 0x2-0x05
    db "5","6","7","8"  ; 0x06-0x09
    db "9","0","-","="  ; 0x0A-0x0D
    db `\b`             ; 0x0E backspace
    db `\t`             ; 0x0F tab
    db "q","w","e","r"  ; 0x10-0x13
    db "t","y","u","i"  ; 0x14-0x17
    db "o","p","[","]"  ; 0x18-0x1B
    db `\n`             ; 0x1C enter
    db 0                ; 0x1D lctrl
    db "a","s","d","f"  ; 0x1E-0x21
    db "g","h","j","k"  ; 0x22-0x25
    db "l",";","'","`"  ; 0x26-0x29
    db 0                ; 0x2A lshift
    db '\',"z","x","c"  ; 0x2B-0x2E
    db "v","b","n","m"  ; 0x2F-0x32
    db ",",".","/"      ; 0x33-0x35
    db 0                ; 0x36 rshift
    db "*"              ; 0x37 keypad *
    db 0                ; 0x38 lalt
    db " "              ; 0x39 space
    db 0                ; 0x3A capslock
    db 0,0,0,0,0        ; 0x3B-0x3F F1-F5
    db 0,0,0,0,0        ; 0x40-0x44 F6-F10
    db 0,0              ; 0x45-0x46 numlock, scrolllock
    db 0                ; 0x47 Home
    db 0                ; 0x48 up arrow
    db 0                ; 0x49 pgup
    db "-"              ; 0x4A kp -
    db 0                ; 0x4B left arrow
    db 0                ; 0x4C kp 5
    db 0                ; 0x4D right arrow
    db '+'              ; 0x4E kp + 
    db 0                ; 0x4F end
    db 0                ; 0x50 down arrow
    db 0                ; 0x51 pgdn
    db 0                ; 0x52 kp 0
    db "."              ; 0x53 kp .
    db 0,0,0            ; 0x54-0x56 unused
    db 0,0              ; 0x57-0x58 F11, F12
