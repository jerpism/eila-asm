[bits 32]

SECTION .text

global pic_remap

PIC1_CMD equ 0x20
PIC1_DAT equ 0x21
PIC2_CMD equ 0xA0
PIC2_DAT equ 0xA1

; sends EOI to the correct PIC 
%macro send_eoi 1
    push eax
    mov al, 0x20
    %if %1 < 8
        out PIC1_CMD, al
    %else
        out PIC2_CMD, al
    %endif
    pop eax
%endmacro


; ecx = offset1 for master
; edx = offset2 for slave
pic_remap:
    ; start init on both PICs in cascade mode
    ; and inform ICW4 will be present
    mov     al, 0x11
    out     PIC1_CMD, al
    out     PIC2_CMD, al

    ; Remap PICs 
    mov     eax, ecx 
    out     PIC1_DAT, al   ; master
    mov     eax, edx
    out     PIC2_DAT, al   ; slave

    mov     eax, 0b100      ; let master know there's a slave at line 2
    out     PIC1_DAT, al
    mov     al, 2           ; tell slave its identity is 2
    out     PIC2_DAT, al 

    mov     al, 1           ; set both to 8086 mode
    out     PIC1_DAT, al
    out     PIC2_DAT, al

    mov     al, 0xff    ; mask both
    out     PIC1_DAT, al
    out     PIC2_DAT, al

    ret
