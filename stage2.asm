
bits 16
org 0x8000

SCREEN_WIDTH equ 640
CHAR_WIDTH   equ 6
CHAR_HEIGHT  equ 7

COLOR_BLACK  equ 0
COLOR_BLUE   equ 1
COLOR_CYAN   equ 11
COLOR_GREY   equ 8
COLOR_WHITE  equ 7

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti
    cld

    call read_bios_date
    mov byte [selection], 0

    call set_graphics_mode
    call draw_frame
    call draw_menu

keyboard_loop:
    xor ah, ah
    int 0x16

    cmp ah, 0x48
    je key_up

    cmp ah, 0x50
    je key_down

    cmp ah, 0x1C
    je key_enter

    jmp keyboard_loop

key_up:
    call erase_marker
    call draw_option_unselected

    cmp byte [selection], 0
    jne key_up_previous

    mov byte [selection], 2
    jmp key_up_finish

key_up_previous:
    dec byte [selection]

key_up_finish:
    call draw_option_selected
    call draw_marker
    jmp keyboard_loop

key_down:
    call erase_marker
    call draw_option_unselected

    cmp byte [selection], 2
    jne key_down_next

    mov byte [selection], 0
    jmp key_down_finish

key_down_next:
    inc byte [selection]

key_down_finish:
    call draw_option_selected
    call draw_marker
    jmp keyboard_loop

key_enter:
    cmp byte [selection], 0
    je boot_cambria

    cmp byte [selection], 1
    je bios_information

    cmp byte [selection], 2
    je reboot_system

    jmp keyboard_loop

boot_cambria:
    call set_graphics_mode
    call draw_frame

    mov word [text_y], 210
    mov byte [text_color], COLOR_CYAN
    mov si, no_kernel
    call draw_centered_text

    mov word [text_y], 240
    mov byte [text_color], COLOR_WHITE
    mov si, press_esc
    call draw_centered_text

boot_wait:
    xor ah, ah
    int 0x16

    cmp ah, 0x01
    jne boot_wait

    call set_graphics_mode
    call draw_frame
    call draw_menu
    jmp keyboard_loop

bios_information:
    call set_graphics_mode
    call draw_frame

    mov word [text_y], 140
    mov byte [text_color], COLOR_CYAN
    mov si, bios_title
    call draw_centered_text

    mov word [text_y], 205
    mov byte [text_color], COLOR_WHITE
    mov si, bios_date_label
    call draw_centered_text

    mov word [text_y], 230
    mov byte [text_color], COLOR_CYAN
    mov si, bios_date
    call draw_centered_text

    mov word [text_y], 315
    mov byte [text_color], COLOR_WHITE
    mov si, press_esc
    call draw_centered_text

bios_wait:
    xor ah, ah
    int 0x16

    cmp ah, 0x01
    jne bios_wait

    call set_graphics_mode
    call draw_frame
    call draw_menu
    jmp keyboard_loop

reboot_system:
    int 0x19

reboot_halt:
    cli
    hlt
    jmp reboot_halt

set_graphics_mode:
    mov ax, 0x0012
    int 0x10
    call init_vga
    ret

init_vga:
    mov ax, 0xA000
    mov es, ax

    mov dx, 0x03C4
    mov al, 2
    out dx, al
    inc dx
    mov al, 0x0F
    out dx, al

    mov dx, 0x03CE
    mov al, 1
    out dx, al
    inc dx
    mov al, 0x0F
    out dx, al

    mov byte [current_vga_color], 255
    ret

draw_frame:
    mov word [line_x], 130
    mov word [line_end], 510
    mov word [line_y], 55
    mov byte [line_color], COLOR_GREY
    call draw_horizontal

    mov word [line_x], 130
    mov word [line_end], 510
    mov word [line_y], 425
    call draw_horizontal

    mov word [line_x], 130
    mov word [line_y], 55
    mov word [line_end], 425
    call draw_vertical

    mov word [line_x], 510
    mov word [line_y], 55
    mov word [line_end], 425
    call draw_vertical

    mov word [line_x], 140
    mov word [line_end], 500
    mov word [line_y], 65
    mov byte [line_color], COLOR_BLUE
    call draw_horizontal

    mov word [line_x], 140
    mov word [line_end], 500
    mov word [line_y], 415
    call draw_horizontal

    mov word [line_x], 140
    mov word [line_y], 65
    mov word [line_end], 415
    call draw_vertical

    mov word [line_x], 500
    mov word [line_y], 65
    mov word [line_end], 415
    call draw_vertical

    mov word [line_x], 160
    mov word [line_end], 480
    mov word [line_y], 120
    mov byte [line_color], COLOR_CYAN
    call draw_horizontal

    mov word [line_x], 180
    mov word [line_end], 460
    mov word [line_y], 160
    mov byte [line_color], COLOR_GREY
    call draw_horizontal

    mov word [line_x], 205
    mov word [line_end], 435
    mov word [line_y], 195
    call draw_horizontal

    mov word [line_x], 205
    mov word [line_end], 435
    mov word [line_y], 300
    call draw_horizontal

    mov word [line_x], 205
    mov word [line_y], 195
    mov word [line_end], 300
    call draw_vertical

    mov word [line_x], 435
    mov word [line_y], 195
    mov word [line_end], 300
    call draw_vertical

    mov word [line_x], 160
    mov word [line_end], 220
    mov word [line_y], 385
    mov byte [line_color], COLOR_CYAN
    call draw_horizontal

    mov word [line_x], 420
    mov word [line_end], 480
    mov word [line_y], 385
    call draw_horizontal

    ret

draw_horizontal:
.draw_horizontal_loop:
    mov cx, [line_x]
    mov dx, [line_y]
    mov al, [line_color]
    call plot_pixel

    inc word [line_x]
    mov ax, [line_x]
    cmp ax, [line_end]
    jbe .draw_horizontal_loop
    ret

draw_vertical:
.draw_vertical_loop:
    mov cx, [line_x]
    mov dx, [line_y]
    mov al, [line_color]
    call plot_pixel

    inc word [line_y]
    mov ax, [line_y]
    cmp ax, [line_end]
    jbe .draw_vertical_loop
    ret

draw_menu:
    mov word [text_y], 90
    mov byte [text_color], COLOR_CYAN
    mov si, title
    call draw_centered_text

    mov word [text_y], 110
    mov byte [text_color], COLOR_WHITE
    mov si, version_label
    call draw_centered_text

    mov byte [selection], 0
    call draw_option_unselected

    mov byte [selection], 1
    call draw_option_unselected

    mov byte [selection], 2
    call draw_option_unselected

    mov byte [selection], 0
    call draw_option_selected
    call draw_marker

    mov word [text_y], 340
    mov byte [text_color], COLOR_GREY
    mov si, menu_hint
    call draw_centered_text

    ret

option_position:
    cmp byte [selection], 0
    je .option_boot

    cmp byte [selection], 1
    je .option_bios

    mov word [text_y], 275
    mov si, option_reboot
    ret

.option_boot:
    mov word [text_y], 215
    mov si, option_boot
    ret

.option_bios:
    mov word [text_y], 245
    mov si, option_bios
    ret

draw_option_unselected:
    call option_position
    mov byte [text_color], COLOR_WHITE
    call draw_centered_text
    ret

draw_option_selected:
    call option_position
    mov byte [text_color], COLOR_CYAN
    call draw_centered_text
    ret

marker_position:
    call option_position
    call center_position
    sub word [text_x], 12
    ret

draw_marker:
    call marker_position
    mov byte [text_color], COLOR_CYAN
    mov al, '>'
    call draw_char
    ret

erase_marker:
    call marker_position
    mov byte [text_color], COLOR_BLACK
    mov al, '>'
    call draw_char
    ret

draw_centered_text:
    call center_position
    call draw_text
    ret

center_position:
    push ax
    push bx
    push cx
    push dx
    push di

    mov di, si
    xor cx, cx

.count_characters:
    cmp byte [di], 0
    je .characters_counted

    inc di
    inc cx
    jmp .count_characters

.characters_counted:
    jcxz .empty_string

    mov ax, cx
    mov bx, CHAR_WIDTH
    mul bx

    dec ax

    mov bx, SCREEN_WIDTH
    sub bx, ax
    shr bx, 1
    mov [text_x], bx
    jmp .center_done

.empty_string:
    mov word [text_x], 0

.center_done:
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret

draw_text:
.draw_text_next:
    lodsb
    test al, al
    jz .draw_text_done

    call draw_char
    add word [text_x], CHAR_WIDTH
    jmp .draw_text_next

.draw_text_done:
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

.find_glyph:
    mov si, font_chars
    cmp bx, font_chars_end - font_chars
    jae .glyph_done

    mov al, [si+bx]
    cmp al, [char_code]
    je .glyph_found

    inc bx
    jmp .find_glyph

.glyph_found:
    mov di, bx
    shl bx, 3
    sub bx, di

    mov si, font_data
    add si, bx

    xor di, di

.draw_row:
    push bx
    mov bx, di
    mov al, [si+bx]
    pop bx

    mov [row_bits], al
    mov byte [col_index], 0

.draw_column:
    mov al, 4
    sub al, [col_index]
    mov cl, al

    mov al, [row_bits]
    shr al, cl
    test al, 1
    jz .skip_pixel

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
    jb .draw_column

    inc di
    cmp di, CHAR_HEIGHT
    jb .draw_row

.glyph_done:
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

    mov [pixel_color], al

    mov ax, dx
    mov bx, 80
    mul bx
    mov di, ax

    mov ax, cx
    mov bx, ax
    and bx, 7

    shr ax, 1
    shr ax, 1
    shr ax, 1
    add di, ax

    mov al, 0x80
    mov cl, bl
    shr al, cl
    mov [pixel_mask], al

    mov al, [pixel_color]
    cmp al, [current_vga_color]
    je .color_ready

    mov dx, 0x03CE
    mov al, 0
    out dx, al
    inc dx

    mov al, [pixel_color]
    out dx, al

    mov al, [pixel_color]
    mov [current_vga_color], al

.color_ready:
    mov dx, 0x03C4
    mov al, 2
    out dx, al
    inc dx
    mov al, 0x0F
    out dx, al

    mov dx, 0x03CE
    mov al, 1
    out dx, al
    inc dx
    mov al, 0x0F
    out dx, al

    mov dx, 0x03CE
    mov al, 8
    out dx, al
    inc dx
    mov al, [pixel_mask]
    out dx, al

    mov al, [es:di]
    mov [es:di], al

    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

read_bios_date:
    push ds
    push es
    push si
    push di
    push cx

    mov ax, 0xF000
    mov ds, ax
    mov si, 0xFFF5

    xor ax, ax
    mov es, ax
    mov di, bios_date
    mov cx, 8
    rep movsb

    mov byte [es:di], 0

    pop cx
    pop di
    pop si
    pop es
    pop ds
    ret

title:
    db 'CAMBRIA', 0

version_label:
    db 'VERSION 0.3', 0

option_boot:
    db 'BOOT CAMBRIA', 0

option_bios:
    db 'BIOS INFORMATION', 0

option_reboot:
    db 'REBOOT', 0

menu_hint:
    db 'ARROWS MOVE ENTER SELECT', 0

no_kernel:
    db 'NO KERNEL CONFIGURED', 0

press_esc:
    db 'PRESS ESC TO RETURN', 0

bios_title:
    db 'BIOS INFORMATION', 0

bios_date_label:
    db 'BIOS ROM DATE:', 0

text_x              dw 0
text_y              dw 0
text_color          db COLOR_WHITE

char_code           db 0
row_bits            db 0
col_index           db 0

line_x              dw 0
line_y              dw 0
line_end            dw 0
line_color          db COLOR_GREY

selection           db 0
bios_date           times 9 db 0

pixel_color         db 0
pixel_mask          db 0
current_vga_color   db 255

font_chars:
    db 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    db '0123456789'
    db ' .:/->'
font_chars_end:

font_data:
    db 14,17,17,31,17,17,17
    db 30,17,17,30,17,17,30
    db 14,17,16,16,16,17,14
    db 30,17,17,17,17,17,30
    db 31,16,16,30,16,16,31
    db 31,16,16,30,16,16,16
    db 14,17,16,23,17,17,14
    db 17,17,17,31,17,17,17
    db 14,4,4,4,4,4,14
    db 7,2,2,2,18,18,12
    db 17,18,20,24,20,18,17
    db 16,16,16,16,16,16,31
    db 17,27,21,21,17,17,17
    db 17,25,21,19,17,17,17
    db 14,17,17,17,17,17,14
    db 30,17,17,30,16,16,16
    db 14,17,17,17,21,18,13
    db 30,17,17,30,20,18,17
    db 15,16,16,14,1,1,30
    db 31,4,4,4,4,4,4
    db 17,17,17,17,17,17,14
    db 17,17,17,17,17,10,4
    db 17,17,17,21,21,21,10
    db 17,17,10,4,10,17,17
    db 17,17,10,4,4,4,4
    db 31,1,2,4,8,16,31

    db 14,17,19,21,25,17,14
    db 4,12,4,4,4,4,14
    db 14,17,1,2,4,8,31
    db 30,1,1,14,1,1,30
    db 2,6,10,18,31,2,2
    db 31,16,16,30,1,1,30
    db 14,16,16,30,17,17,14
    db 31,1,2,4,8,8,8
    db 14,17,17,14,17,17,14
    db 14,17,17,15,1,1,14

    db 0,0,0,0,0,0,0
    db 0,0,0,0,0,4,4
    db 0,4,4,0,4,4,0
    db 1,2,2,4,8,8,16
    db 0,0,0,31,0,0,0
    db 8,4,2,1,2,4,8

