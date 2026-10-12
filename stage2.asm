bits 16
org 0x8000

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti
    cld

    mov ax, 0x0012
    int 0x10

    mov word [text_x], 299
    mov word [text_y], 185
    mov byte [text_color], 11
    mov si, title
    call draw_text

    mov word [text_x], 251
    mov word [text_y], 215
    mov byte [text_color], 7
    mov si, subtitle
    call draw_text

    mov word [line_x], 240
.line:
    mov cx, [line_x]
    mov dx, 245
    mov al, 3
    call plot_pixel
    inc word [line_x]
    cmp word [line_x], 400
    jb .line

    mov word [text_x], 254
    mov word [text_y], 265
    mov byte [text_color], 7
    mov si, status
    call draw_text

    mov word [text_x], 260
    mov word [text_y], 295
    mov byte [text_color], 8
    mov si, footer
    call draw_text

halt:
    hlt
    jmp halt



draw_text:
.next:
    lodsb
    test al, al
    jz .done

    call draw_char
    add word [text_x], 6
    jmp .next

.done:
    ret



draw_char:
    cmp al, 'a'
    jb .case_done
    cmp al, 'z'
    ja .case_done
    sub al, 32

.case_done:
    mov [char_code], al

    push ax
    push bx
    push cx
    push dx
    push si
    push di

    xor bx, bx

.find:
    mov si, font_chars
    cmp bx, font_chars_end - font_chars
    jae .done

    mov al, [si+bx]
    cmp al, [char_code]
    je .found

    inc bx
    jmp .find

.found:
    ; Glyph address = font_data + (index * 7)
    mov di, bx
    shl bx, 3
    sub bx, di
    mov si, font_data
    add si, bx

    xor di, di

.row:
    ; Read the current row.
    push bx
    mov bx, di
    mov al, [si+bx]
    pop bx

    mov [row_bits], al
    mov byte [col_index], 0

.col:
    ; Bit 4 is the leftmost pixel.
    mov al, 4
    sub al, [col_index]
    mov cl, al

    mov al, [row_bits]
    shr al, cl
    test al, 1
    jz .skip_pixel

    ; Calculate screen coordinates.
    xor cx, cx
    mov cl, [col_index]
    add cx, [text_x]

    mov dx, [text_y]
    add dx, di

    mov al, [text_color]
    call plot_pixel

.skip_pixel:
    inc byte [col_index]
    cmp byte [col_index], 5
    jb .col

    inc di
    cmp di, 7
    jb .row

.done:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret


plot_pixel:
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    mov ah, 0x0C
    xor bh, bh
    int 0x10

    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret


title:
    db 'CAMBRIA', 0

subtitle:
    db 'X86 BIOS BOOTLOADER 0.3', 0

status:
    db 'BOOTLOADER INITIALIZED', 0

footer:
    db 'NO KERNEL CONFIGURED', 0


text_x      dw 0
text_y      dw 0
text_color  db 7
char_code   db 0
row_bits    db 0
col_index   db 0
line_x      dw 0



font_chars:
    db 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    db '0123456789'
    db ' .,:;!?-_/\()[]+=<>#*%&@$'
font_chars_end:



font_data:

    ; A-Z

    ; A
    db 14,17,17,31,17,17,17
    ; B
    db 30,17,17,30,17,17,30
    ; C
    db 14,17,16,16,16,17,14
    ; D
    db 30,17,17,17,17,17,30
    ; E
    db 31,16,16,30,16,16,31
    ; F
    db 31,16,16,30,16,16,16
    ; G
    db 14,17,16,23,17,17,14
    ; H
    db 17,17,17,31,17,17,17
    ; I
    db 14,4,4,4,4,4,14
    ; J
    db 7,2,2,2,18,18,12
    ; K
    db 17,18,20,24,20,18,17
    ; L
    db 16,16,16,16,16,16,31
    ; M
    db 17,27,21,21,17,17,17
    ; N
    db 17,25,21,19,17,17,17
    ; O
    db 14,17,17,17,17,17,14
    ; P
    db 30,17,17,30,16,16,16
    ; Q
    db 14,17,17,17,21,18,13
    ; R
    db 30,17,17,30,20,18,17
    ; S
    db 15,16,16,14,1,1,30
    ; T
    db 31,4,4,4,4,4,4
    ; U
    db 17,17,17,17,17,17,14
    ; V
    db 17,17,17,17,17,10,4
    ; W
    db 17,17,17,21,21,21,10
    ; X
    db 17,17,10,4,10,17,17
    ; Y
    db 17,17,10,4,4,4,4
    ; Z
    db 31,1,2,4,8,16,31

    ; 0-9

    ; 0
    db 14,17,19,21,25,17,14
    ; 1
    db 4,12,4,4,4,4,14
    ; 2
    db 14,17,1,2,4,8,31
    ; 3
    db 30,1,1,14,1,1,30
    ; 4
    db 2,6,10,18,31,2,2
    ; 5
    db 31,16,16,30,1,1,30
    ; 6
    db 14,16,16,30,17,17,14
    ; 7
    db 31,1,2,4,8,8,8
    ; 8
    db 14,17,17,14,17,17,14
    ; 9
    db 14,17,17,15,1,1,14

    ; Space
    db 0,0,0,0,0,0,0

    ; Period .
    db 0,0,0,0,0,4,4

    ; Comma ,
    db 0,0,0,0,4,4,8

    ; Colon :
    db 0,4,4,0,4,4,0

    ; Semicolon ;
    db 0,4,4,0,4,4,8

    ; Exclamation !
    db 4,4,4,4,4,0,4

    ; Question mark ?
    db 14,17,1,2,4,0,4

    ; Hyphen -
    db 0,0,0,31,0,0,0

    ; Underscore _
    db 0,0,0,0,0,0,31

    ; Forward slash /
    db 1,2,2,4,8,8,16

    ; Backslash \
    db 16,8,8,4,2,2,1

    ; Parentheses ( )
    db 2,4,8,8,8,4,2
    db 8,4,2,2,2,4,8

    ; Square brackets [ ]
    db 14,8,8,8,8,8,14
    db 14,2,2,2,2,2,14

    ; Plus +
    db 0,4,4,31,4,4,0

    ; Equals =
    db 0,31,0,31,0,0,0

    ; Less than <
    db 2,4,8,16,8,4,2

    ; Greater than >
    db 8,4,2,1,2,4,8

    ; Hash #
    db 10,31,10,10,31,10,0

    ; Asterisk *
    db 0,17,10,31,10,17,0

    ; Percent %
    db 17,2,4,8,17,0,0

    ; Ampersand &
    db 12,18,20,8,21,18,13

    ; At sign @
    db 14,17,23,21,23,16,14

    ; Dollar sign $
    db 4,15,20,14,5,30,4
