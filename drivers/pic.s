[bits 32]

SECTION .text

global pictest

PIC1_CMD equ 0x20
PIC1_DAT equ 0x21
PIC2_CMD equ 0xA0
PIC2_DAT equ 0xA1


; sends EOI to the correct PIC 
%macro send_eoi 1
    push eax
    mov al, 0x20

    %if %1 < 8
        out 0x20, al
    %else
        out 0xA0, al
    %endif
    pop eax
%endmacro


pictest:
    send_eoi 20
    send_eoi 7
    ret

