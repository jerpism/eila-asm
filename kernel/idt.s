[bits 32]

global create_idt

; generic handler for faults
exception_handler:
    cli
    hlt
    jmp $

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


; intel recommends being aligned on a 8 byte boundary
; not sure if this is just for 64 bit, maybe figure that out
align 64
idt_start:
    %assign i 0
    %rep 32
        irq%+i:
            dw  0           ; Address bottom
            dw  0x8         ; code segment
            db  0           ; zero
            db  0           ; attributes
            dw  0           ; Address top
    %assign i i+1
    %endrep

create_idt:
    %assign i 0
    %rep 32
        mov     eax, isr%+i             ; whole address
        mov     word [isr%+i], ax       ; bottom half
        shr     eax, 16
        mov     word [isr%+i + 6], ax   ; top half
    %assign i i+1
    %endrep

    lidt    [idt_start]
    sti
    ret

        
        
