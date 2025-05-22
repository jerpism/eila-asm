[org 0x7c00]

jmp _start

    align 32
    gdt_start:
        ; GDT null descriptor
        ; 8 bytes of 0
        gdt_null:
            dq 0x0

        gdt_code:
        ; Base 0x0,     Limit 0xffff
        ; Flags 1:      (present)1 (privilege)00 (type)1
        ; -> 0b1001
        ; Type flags:   (code)1 (conforming)0 (readable)1 (accessed)0
        ; -> 0b1100
        ; Flags 2:      (granularity)1 (32-bit default)1 (64-bit seg)0 (AVL)0
        ; -> 0b1100
        dw 0xffff       ; limit (0-15)
        dw 0x0          ; base (0-15)
        db 0x0          ; base (16-23)
        db 0b10011100   ; 1st flags and type flags
        db 0b11001111   ; 2nd flags and limit (16-19)
        db 0x0          ; base (24-31)

        gdt_data:
        ; See above for base, limit and flags 1&2
        ; Type flags:   (code)0 (expand down)0 (writable)1 (accessed)0 
        ; -> 0b0010
        dw 0xffff       ; limit (0-15)
        dw 0x0          ; base (0-15)
        db 0x0          ; base (16-23)
        db 0b10010010   ; 1st flags and type flags
        db 0b11001111   ; 2nd flags, limit (16-19)
        db 0x0          ; base (24-31)
    gdt_end:

    gdt_desc:
        dw gdt_end - gdt_start - 1  ; size of GDT
        dd gdt_start                ; address of GDT

    ; addresses of code segment and data segment
    CODE_SEG equ gdt_code - gdt_start
    DATA_SEG equ gdt_data - gdt_start



SECTION .text
[bits 16]

KERNEL_OFFSET equ 0x1000

_start:
    mov     [BOOT_DRIVE], dl    ; store # of drive we booted from

    ; set up a stack at 0x9000 temporarily
    mov     bp, 0x9000          
    mov     sp, bp


    ; zero out segment registers
    xor     ax, ax
    mov     es, ax
    mov     ds, ax

    ; set video mode to 80x25 text
    mov     ah, 0x00    ; set video mode
    mov     al, 0x03    ; 80x25 text
    int     0x10

    ; welcome the user
    mov     bx, STR_WELCOME
    call    print_str
    mov     bx, STR_READDISK
    call    print_str

    ; read the rest of our data from the disk
    mov     bx, KERNEL_OFFSET   ; load kernel to offset address
    mov     dh, 1               ; # sectors
    mov     dl, [BOOT_DRIVE]    ; from the drive we booted from
    call    read_disk

    ; and enter protected mode
    mov     bx, STR_PMSWITCH
    call    print_str

    call    switch_to_pm
    jmp $


; Simple print routine for real mode
; Prints a NUL terminated string pointed to by bx
print_str:
    push    ax
    mov     ah, 0x0e    ; print character call

    .loop:
    mov     al, [bx]
    test    al, al
    jz      .end

    int     0x10

    add     bx, 1
    jmp     .loop
    
    .end:
    pop     ax
    ret


read_disk:
    push    dx
    mov     ah, 0x2     ; read disk call
    mov     al, dh      ; # of sectors
    mov     ch, 0x0     ; Cylinder 0
    mov     dh, 0x0     ; Head 0 
    mov     cl, 0x2     ; Sector 2

    int     0x13
    pop     dx
    jc      .error

    ; See if read sectors equals requested
    cmp     al, dh
    jne     .error

    ret

    .error:
    mov     bx, STR_DISKERROR
    call    print_str
    hlt


switch_to_pm:
    ; load gdt descriptor
    cli
    lgdt    [gdt_desc]

    ; set PE bit in cr0
    mov     eax, cr0
    or      eax, 0x1
    mov     cr0, eax

    ; long jump to flush our pipeline
    jmp     CODE_SEG:BEGIN_PM

; PM ZONE 
[bits 32]
BEGIN_PM:
    ; set up all segment registers
    mov     ax, DATA_SEG
    mov     ds, ax
    mov     ss, ax
    mov     es, ax
    mov     fs, ax
    mov     gs, ax

    ; and set up stack again
    mov     ebp, 0x9000
    mov     esp, ebp

    ; enable fast A20 here
    ; won't cause problems on qemu, might on real hardware
    in      al, 0x92
    or      al,2
    out     0x92, al

    ; Leave bootloader and jump to kernel
    call    KERNEL_OFFSET
    jmp $
        


BOOT_DRIVE: db 0
STR_WELCOME: db "Booted up in real mode", 0xa, 0xd, 0x0
STR_READDISK: db "Reading disk...", 0xa, 0xd, 0x0
STR_DISKERROR: db "Error reading disk!", 0xa, 0xd, 0x0
STR_PMSWITCH: db "Disk read success! Now leaving real mode", 0xa, 0xd, 0x0

times 510 - ($-$$) db 0
dw 0xaa55
