bits 16

org 0x7C00

%macro PRINT 5
    mov ah, 0x13
    mov al, 0x01
    mov bh, 0x00
    mov bl, %3
    mov dh, %1
    mov dl, %2
    mov bp, %4
    mov cx, %5
    int 0x10
%endmacro

start:
    cli
    
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti
    cld
    
    mov ax, 0x0003
    int 0x10
  
    PRINT 7, 36, 0x0B, name, name_len
    PRINT 9, 24, 0x07, subtitle, subtitle_len
    PRINT 12, 24, 0x08, separator, separator_len
    PRINT 14, 24, 0x07, status, status_len
    PRINT 17, 24, 0x08, footer, footer_len

    halt:
        hlt
        jmp halt

    name:
        db 'CAMBRIA'
    name_len equ $ - name

    subtitle:
        db 'x86 / BIOS BOOTLOADER / 0.1'
    subtitle_len equ $ - subtitle

    separator:
        db '--------------------------------'
    separator_len equ $ - separator

    status:
        db 'Bootloader initialized.'
    status_len equ $ - status

    footer:
        db 'NO KERNEL CONFIGURED'
    footer_len equ $ - footer

    times 510 - ($ - $$) db 0
    dw 0xAA55


