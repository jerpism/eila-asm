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

extern kb_handler

global create_idt

; generic handler for faults
exception_handler:
    cli
    hlt
    jmp $

; intel reserved ones 0x00-0x20
isr0:
isr1:
isr2:
isr3:
isr4:
isr5:
isr6:
isr7:
isr8:
isr9:
isr10:
isr11:
isr12:
isr13:
isr14:
isr15:
isr16:
isr17:
isr18:
isr19:
isr20:
isr21:
isr22:
isr23:
isr24:
isr25:
isr26:
isr27:
isr28:
isr29:
isr30:
isr31:
call exception_handler
iret

; 0x21 IRQ 1 keyboard
isr32:
    pusha
    call kb_handler
    send_eoi 1
    popa
    iret


; intel recommends being aligned on a 8 byte boundary
; not sure if this is just for 64 bit, maybe figure that out
align 64
idt_start:
    %assign i 0
    %rep NUM_HANDLERS
        irq%+i:
            dw  0           ; Address bottom
            dw  0x8         ; code segment
            db  0           ; zero
            db  0           ; attributes
            dw  0           ; Address top
    %assign i i+1
    %endrep
idt_end:

idt_desc:
    dw idt_end - idt_start - 1
    dd idt_start


create_idt:
    %assign i 0
    %rep NUM_HANDLERS
        mov     eax, isr%+i             ; whole address
        mov     word [irq%+i], ax       ; bottom half
        shr     eax, 16
        mov     word [irq%+i + 6], ax   ; top half
    %assign i i+1
    %endrep

    lidt    [idt_desc]
    sti
    ret

    

        
        
