[bits 32]
global main

extern print_character
extern print_str

main:
    mov eax, 0
    mov edx, 5
    mov ecx, STR_TEST

    call print_str

    mov eax, -1
    mov edx, -1
    mov ecx, STR_TEST2
    call print_str
    jmp $


STR_TEST: db `Hhello\nhi`, 0x0
STR_TEST2: db 'Hihi', 0x0

