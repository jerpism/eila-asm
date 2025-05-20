[bits 32]
global main

extern print_cell

main:
    mov eax, 0
    mov dx, 0x4441

    push eax
    push edx

    call print_cell

jmp $
   jmp $
