; ╔══════════════════════════════════════╗
; ║   Flexity Bootloader v0.1            ║
; ║   The Flexible Core                  ║
; ╚══════════════════════════════════════╝

[BITS 16]
[ORG 0x7C00]

start:
    ; Limpiar registros
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    ; Limpiar pantalla (modo 80x25 color)
    mov ax, 0x0003
    int 0x10

    ; Imprimir primer mensaje
    mov si, msg_boot
    call print_string

    ; Imprimir segundo mensaje
    mov si, msg_version
    call print_string

    ; Loop infinito
    jmp $

print_string:
    mov ah, 0x0E
.loop:
    lodsb
    cmp al, 0
    je .done
    int 0x10
    jmp .loop
.done:
    ret

msg_boot     db 'Flexity Bootloader', 13, 10, 0
msg_version  db 'v0.1 - The Flexible Core', 13, 10, 0

times 510-($-$$) db 0
dw 0xAA55