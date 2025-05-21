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


; Puts current cursor character offset in edx
%macro get_cursor 0
    push eax
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
    mov     ch, al

    ; shift ah to al here 
    shr     ax, 8

    ; read low byte of cursor address
    mov     dx, SCREEN_CTRL_REG
    out     dx, al
    mov     dx, SCREEN_DATA_REG
    in      al, dx
    mov     cl, al

    movzx    edx, cx

   pop ecx
   pop eax 
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
    get_cursor                      ; first get current position
    lea edx, [edx * 2 + VGA_MEM]    ; convert to a memory address
    mov ah, DEF_COLOR               ; default color attributes in ah
    mov WORD [edx], ax              ; write character out
    lea edx, [edx - VGA_MEM + 2]    ; convert to memory offset for next cell
    shr edx, 1                      ; convert to character offset
    set_cursor edx                  ; and set cursor to it


    ret 


; eax = col
; edx = row, to start at
; ecx = pointer to string
print_str:
    cmp     eax, -1
    jne     .notatcursor
    cmp     edx, -1
    jne     .notatcursor

    ; get cursor offset and convert to memory address
    get_cursor
    lea     edx, [edx * 2 + VGA_MEM]
    

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
    set_cursor eax              ; set cursor at this point
    lea     edx, [eax * 2 + VGA_MEM]; and convert the offset to an address
    mov     ah, DEF_COLOR       ; and fix ah back up to what it should be
    add     ecx, 1              ; and then point to next char 
    pop ebx
    jmp     .loop



    .notspecial:
    mov     WORD [edx], ax  ; no, write out the next one
    add     ecx, 1          ; point to next character

    sub     edx, VGA_MEM    ; calculate character offset
    shr     edx, 1          ; for cursor
    add     edx, 1
    set_cursor edx
    
    lea     edx, [edx * 2 + VGA_MEM]   ; and next memory offset
    jmp     .loop

    .end:
    ret
    


    





