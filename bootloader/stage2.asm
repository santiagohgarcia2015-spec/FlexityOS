[BITS 16]
[ORG 0x0000]

stage2_start:
    ; Configurar segmentos
    mov ax, 0x07E0
    mov ds, ax
    mov es, ax

    ; Limpiar pantalla
    mov ax, 0x0003
    int 0x10

    ; Ocultar cursor
    mov ah, 0x01
    mov cx, 0x2607
    int 0x10

    ; Pintar fondo cyan/negro
    mov si, logo
    call print

    mov si, name_msg
    call print

    mov si, tagline
    call print

    mov si, blank
    call print

    mov si, loading_msg
    call print

    ; Barra de carga
    mov cx, 30
.bar:
    push cx
    mov ah, 0x0E
    mov al, 0xDB
    int 0x10
    
    ; Delay
    push cx
    mov cx, 0
    mov dx, 0x5000
    mov ah, 0x86
    int 0x15
    pop cx
    
    pop cx
    loop .bar

    mov si, blank
    call print
    mov si, ready_msg
    call print

    jmp $

print:
    mov ah, 0x0E
.l:
    lodsb
    test al, al
    jz .d
    int 0x10
    jmp .l
.d:
    ret

logo:
    db 13,10
    db '         ::::::----::::::', 13,10
    db '      :-=++++===========--::', 13,10
    db '   :-=++***********+++++===-:', 13,10
    db ' -=+***##########***++++++===-:', 13,10
    db '=*###############**+++++++++==-:', 13,10
    db '+##%%%%%%%%######*=    -=++++==-:', 13,10
    db '*#%%%%%%%%%%%#*=         -+++==-:', 13,10
    db '*#%%%%%%%%%#=    --==+    =+++=-:', 13,10
    db '+##%%%%%%%#=   =+****+=   =+++=-:', 13,10
    db '=*#%%%%%%%*   +##%%%%#+   =+++=-:', 13,10
    db '-+##%%%%%%#   +#%%%%%#+   =+*+=:', 13,10
    db ' =*##%%%%%#=  =*#%%%%#+   =**+-', 13,10
    db '  -+##%%%%%#+  =+####*=  =+**+-', 13,10
    db '   -+##%%%%%##+        =+*##+-', 13,10
    db '     =*##%%%%%%##*++**####*=', 13,10
    db '       -=*##%%%%%%%###*+-', 13,10
    db '          -==++**+==-', 13,10, 0

name_msg    db 13,10,'           F L E X I T Y', 13,10, 0
tagline     db '         The Flexible Core', 13,10, 0
blank       db 13,10, 0
loading_msg db '      Loading kernel modules', 13,10,'      ', 0
ready_msg   db 13,10,'        [ SYSTEM READY ]', 13,10, 0

times 4096-($-$$) db 0