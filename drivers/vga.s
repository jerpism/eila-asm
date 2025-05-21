[bits 32]

global print_character
global print_str

; Assume we're running 80x25 text mode
COL equ 80
ROW equ 25

VGA_MEM equ 0xb8000
SCREEN_CTRL_REG equ 0x3d4
SCREEN_DATA_REG equ 0x3d5

DEF_COLOR equ 0x4f ; 0x4f white on red

SECTION .data
SECTION .bss

; keep track of current offset
cursor: resw 1

SECTION .text


; Puts current cursor character offset in ax
%macro get_cursor 0
    push edx
    mov dl, SCREEN_CTRL_REG 
    out 14, dl              ; ask for high byte of cursor offset
    in  ah, SCREEN_DATA_REG ; get it
    out 15, dl              ; ask for low byte of cursor offset
    in  al, SCREEN_DATA_REG ; get it
    pop edx
%endmacro


; eax = col
; edx = row, to start at
; ecx = pointer to string
print_str:
    cmp     eax, -1
    jne     .notatcursor
    cmp     edx, -1
    jne     .notatcursor
    mov     edx, [cursor]
    jmp     .atcursor


    .notatcursor:
    ; otherwise start at given position
    ; calculate offset for given col,row
    imul    edx, COL
    lea     edx, [edx + eax]
    shl     edx, 1

    ; set it as our base to begin at
    lea     edx, [VGA_MEM + edx]

    .atcursor:

    mov      ah, DEF_COLOR  ; set default color in high byte
    .loop:
    mov     al, BYTE [ecx]  ; load next character
    test    al, al          ; got a NUL?
    jz      .end            ; yeah, we're done

    ; check for special control characters
    ; just newline for now and it behaves as \r\n
    cmp     al, 0xA             ; newline?
    jnz     .notspecial         ; no, just write out a regular one

    ; TODO: figure out a better way to do this in way less instructions
    ; there must be a smarter solution but for now I just want it to work
    push ebx
    mov     eax, edx            ; copy address to eax
    sub     eax, VGA_MEM        ; convert it to an offset
    shr     eax, 1              ; convert to a character offset
    xor     edx, edx            ; zero out edx for idiv
    mov     ebx, COL            ; use ebx as divisor
    idiv    ebx                 ; divide offset by col to get row in eax
    add     eax, 1              ; point to next row
    imul    eax, COL            ; get character offset for that row
    shl     eax, 1              ; and just point to the start of it

    lea     edx, [eax + VGA_MEM]; then convert back to an address
    mov     [cursor], edx       ; also save it
    mov     ah, DEF_COLOR       ; and fix ah back up to what it should be
    add     ecx, 1              ; and then point to next so we don't get stuck
    pop ebx
    jmp     .loop



    .notspecial:
    mov     WORD [edx], ax  ; no, write out the next one
    add     ecx, 1          ; point to next character
    add     edx, 2          ; and next memory offset
    mov     [cursor], edx   ; and save it
    jmp     .loop

    .end:
    ret
    


    





