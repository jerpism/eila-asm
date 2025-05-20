[bits 32]

global print_cell

; Assume we're running 80x25 text mode
COL equ 80
ROW equ 25
VGA_MEM equ 0xb8000

SECTION .data
SECTION .bss

SECTION .text

; print_cell(u8 character, u8 color, i32 offset)
print_cell:
    mov     eax, VGA_MEM          ; eax points to screen memory
    mov     ecx, DWORD [esp+4]    ; get character and color
    mov     edx, DWORD [esp+8]    ; get offset
    mov     WORD [eax + edx], cx  ; write out character

    ret


