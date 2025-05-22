[bits 32]

global print_char
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

SECTION .text


; Puts current cursor character offset in eax
%macro get_cursor 0
    push edx
    push ecx

    ; puts 15 in ah and 14 in al
    ; probably faster to do 2 movs to eax instead
    ; but this is funnier
    mov     ax, 0xF0E   ; even in your vga drivers

    ; read high byte of cursor address
    mov     dx, SCREEN_CTRL_REG
    out     dx, al
    mov     dx, SCREEN_DATA_REG
    in      al, dx
    ror     ax, 8   ; rotate around so al and ah swap places
                    ; this puts high byte of cursor in ah 

    ; read low byte of cursor address
    mov     dx, SCREEN_CTRL_REG
    out     dx, al
    mov     dx, SCREEN_DATA_REG
    in      al, dx

    movzx    eax, ax

   pop ecx
   pop edx 
%endmacro

%macro set_cursor 1
    push    eax
    push    edx
    push    ecx

    mov ecx, %1

    ; write out high byte of cursor offset
    mov     dx, SCREEN_CTRL_REG 
    mov     al, 14
    out     dx, al
    mov     dx, SCREEN_DATA_REG
    mov     al, ch
    out     dx, al
    
    ; write out low byte of cursor offset
    mov     dx, SCREEN_CTRL_REG 
    mov     al, 15
    out     dx, al
    mov     dx, SCREEN_DATA_REG
    mov     al, cl
    out     dx, al

    pop ecx
    pop edx
    pop eax
%endmacro


; print character in eax at cursor position
; uses default color
print_char:
    mov edx, eax                    ; swap character to edx
    get_cursor                      ; get cursor to eax
    add eax, 1                      ; point to next cell
    set_cursor eax                  ; and set cursor to it
    lea eax, [eax * 2 + VGA_MEM - 2]; print out to where cursor used to be
    mov dh, DEF_COLOR               ; default color attributes in dh
    mov WORD [eax], dx              ; write character out

    ret 


; eax = col
; edx = row, to start at
; ecx = pointer to string
print_str:
    push    ebx
    mov     ebx, VGA_MEM

    cmp     eax, -1
    jne     .notatcursor
    cmp     edx, -1
    jne     .notatcursor

    ; get cursor offset 
    get_cursor
    
    jmp     .atcursor


    .notatcursor:
    ; otherwise start at given position
    ; calculate character offset for given col,row
    imul    edx, COL
    lea     eax, [edx + eax]

    .atcursor:
    mov      dh, DEF_COLOR  ; set default color in high byte

    .loop:
    mov     dl, BYTE [ecx]  ; load next character
    test    dl, dl          ; got a NUL?
    jz      .end            ; yeah, we're done

    ; check for special control characters
    ; just newline for now and it behaves as \r\n
    cmp     dl, 0xA             ; newline?
    jnz     .notspecial         ; no, just write out a regular one

    xor     edx, edx            ; zero out edx for idiv
    mov     ebx, COL            ; use ebx as divisor
    div     ebx                 ; divide offset by col to get row in eax
    add     eax, 1              ; point to next row
    imul    eax, COL            ; get character offset for that row
    set_cursor eax              ; set cursor at this point
    mov     ebx, VGA_MEM        ; set ebx back to vga memory base
    mov     dh, DEF_COLOR       ; fix dh back up to what it should be
    add     ecx, 1              ; and then point to next char 
    jmp     .loop               


    .notspecial:
    mov     WORD [eax * 2 + ebx], dx  ; wasn't a special, just write it out
    add     ecx, 1          ; point to next character
    add     eax, 1          ; advance to next cell
    set_cursor eax          ; and set cursor
    
    jmp     .loop

    .end:
    pop ebx
    ret
