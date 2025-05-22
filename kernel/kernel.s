[bits 32]
global main

extern print_str
extern pic_remap

main:
    ; test print
    mov eax, -1
    mov edx, -1
    mov ecx, STR_TEST
    call print_str

    ; remap pic, puts IMR value in ax
    mov ecx, 0x20
    mov edx, 0x28
    call pic_remap

    jmp $


STR_TEST: db `Booted into protected mode succesfully`, 0x0

