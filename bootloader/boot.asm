[BITS 16]
[ORG 0x7C00]

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti

    mov [boot_drive], dl

    ; Limpiar pantalla
    mov ax, 0x0003
    int 0x10

    ; Mensaje
    mov si, msg_loading
    call print

    ; Resetear disco
    xor ah, ah
    mov dl, [boot_drive]
    int 0x13

    ; Cargar Stage 2
    mov ax, 0x07E0      ; Segmento donde cargar
    mov es, ax
    xor bx, bx          ; Offset 0

    mov ah, 0x02        ; Funcion leer
    mov al, 8           ; Cargar 8 sectores (4KB)
    mov ch, 0           ; Cilindro 0
    mov cl, 2           ; Empezar en sector 2
    mov dh, 0           ; Cabeza 0
    mov dl, [boot_drive]
    int 0x13

    jc error

    ; Saltar a Stage 2
    jmp 0x07E0:0x0000

error:
    mov si, msg_error
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

msg_loading db 'Loading Flexity Stage 2...', 13, 10, 0
msg_error   db 'Boot Error!', 0
boot_drive  db 0

times 510-($-$$) db 0
dw 0xAA55