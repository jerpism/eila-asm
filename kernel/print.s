[bits 32]

SECTION .bss
buffer: resb 11

SECTION .text

extern print_str

global print_uint

; eax contains number
print_uint:
    push edi
    mov     edi, buffer + 11    ; set to end of buffer
    mov     byte [edi], 0       ; and null terminate always
    mov     ecx, 10

    .loop:
    xor     edx, edx
    sub     edi, 1
    div     ecx
    add     edx,'0'
    mov     byte [edi], dl
    test    eax, eax
    jnz     .loop

    mov     eax, edi
    call    print_str


    pop edi
    ret


global print_hex
; eax contains number
print_hex:
    push edi
    mov     edi, buffer + 11    ; make sure it's NUL terminated
    mov     byte [edi], 0
    mov     edi, buffer + 2     ; point to +2 so we can have 0x prefix

    mov     byte [edi-2], '0'
    mov     byte [edi-1], 'x'     

    mov     cl, 32          ; 32 bit number max

    .loop:
    mov     edx, 0xf0000000 ; mask out 4 most significant bits
    rol     edx, cl         ; rotate it to where it's supposed to be
    sub     cl, 4           ; initially rotates all the way around
    and     edx, eax        ; mask out our bits
    shr     edx, cl         ; and put them as the 4 least significant bits

    cmp     edx, 9          ; is the value <= 9?
    jle     .digit          ; it is, just add '0'
    add     edx, 0x7        ; it's not, first add 7 
    .digit:
    add     edx, '0'        ; and then add '0' so we get the ascii value
    mov     byte [edi], dl  ; store it
    add     edi, 1

    test    cl, cl          ; did we do the whole thing?
    jnz     .loop           ; no, do next

    mov     eax, buffer
    call    print_str

    pop edi

    ret


