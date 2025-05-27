[bits 32]
global main

extern print_str
extern print_char

extern pic_remap
extern create_idt

main:
    ; test print
    mov     eax, -1
    mov     edx, -1
    mov     ecx, STR_TEST
    call    print_str

    mov     ecx, 0x20
    mov     edx, 0x28
    call    pic_remap

   ; mask out all but keyboard
    mov     al, 0xfd
    out     0x21, al
    mov     al, 0xff
    out     0xa1, al

    call    create_idt



    jmp $


    STR_TEST: db `Booted into protected mode succesfully`, 0x0

