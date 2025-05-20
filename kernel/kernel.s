[bits 32]
global main

extern print_cell

main:
    mov eax, 0
    mov dx, 0x4f42

    push eax
    push edx

    call print_cell

   jmp $
