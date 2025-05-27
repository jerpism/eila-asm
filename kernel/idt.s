[bits 32]

PIC1_CMD equ 0x20
PIC1_DAT equ 0x21
PIC2_CMD equ 0xA0
PIC2_DAT equ 0xA1

; sends EOI to the correct PIC 
%macro send_eoi 1
    push eax
    mov al, 0x20

    %if %1 < 8
        out PIC1_CMD, al
    %else
        out PIC2_CMD, al
    %endif

    pop eax
%endmacro

%define NUM_HANDLERS 33

global create_idt

SECTION .text
; Each idt entry consists of
; +0    dw address_bottom
; +2    dw cs_selector
; +4    db res (0)
; +5    db flags
; +6    dw address_top
; for a total of 8 bytes per entry
align 64
idt_start:
    resq 255
idt_end:

idt_desc:
    dw 0x07ff     ; 255 at most
    dd idt_start


create_idt:
    mov     esi, isr_stub_table

    ; assign the first 32 intel isr handlers 0-31
    %assign i 0
    %rep 32
    lea     edx, [idt_start + %+i * 8]  ; get idt entry address for i
    mov     eax, [esi + %+i * 4]        ; find matching in stub table and get address to eax

    mov     word [edx], ax              ; write bottom half of address to idt entry

    ; since these don't change, maybe combine to one mov
    mov     word [edx+2], 0x8           ; cs selector
    mov     byte [edx+4], 0x0           ; res, maybe this is unnecessary? does resq init to 0?
    mov     byte [edx+5], 0x8e          ; flags 
    shr     eax, 16 
    mov     word [edx+6], ax            ; and last write out top of address
    %assign i i+1
    %endrep

    ; edx will point to last entry at this point
    ; so increment by 16 to get to irq1
    lea     edx, [idt_start + 31 * 8]
    lea     edx, [edx + 16]
    mov     eax, isr33
    mov     word [edx], ax
    mov     word [edx+2], 0x8
    mov     byte [edx+4], 0x0
    mov     byte [edx+5], 0x8e
    shr     eax, 16 
    mov     word [edx+6], ax

    lidt    [idt_desc]
    sti
    ret


    extern kb_handler
    ; irq1
    isr33:
        call kb_handler
        send_eoi 1
        iret


; generic handler for faults
exception_handler:
    cli
    hlt
    jmp $

isr_stub_table:
    %assign i 0
    %rep    32
        dd isr_stub_%+i
    %assign i i+1
    %endrep

        
%macro isr_err_stub 1
isr_stub_%+%1:
    call    exception_handler
    iret
%endmacro

%macro isr_no_err_stub 1
isr_stub_%+%1:
    call    exception_handler
    iret
%endmacro

isr_no_err_stub 0
isr_no_err_stub 1
isr_no_err_stub 2
isr_no_err_stub 3
isr_no_err_stub 4
isr_no_err_stub 5
isr_no_err_stub 6
isr_no_err_stub 7
isr_err_stub    8
isr_no_err_stub 9
isr_err_stub    10
isr_err_stub    11
isr_err_stub    12
isr_err_stub    13
isr_err_stub    14
isr_no_err_stub 15
isr_no_err_stub 16
isr_err_stub    17
isr_no_err_stub 18
isr_no_err_stub 19
isr_no_err_stub 20
isr_no_err_stub 21
isr_no_err_stub 22
isr_no_err_stub 23
isr_no_err_stub 24
isr_no_err_stub 25
isr_no_err_stub 26
isr_no_err_stub 27
isr_no_err_stub 28
isr_no_err_stub 29
isr_err_stub    30
isr_no_err_stub 31
