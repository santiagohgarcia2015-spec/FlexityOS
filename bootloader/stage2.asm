[BITS 16]
[ORG 0x7E00]

stage2_start:
    ; Configurar segmentos
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    ; Limpiar pantalla
    mov ax, 0x0003
    int 0x10

    ; Mensaje
    mov si, msg_loading
    call print16

    ; Cargar el kernel en 0x10000
    mov ah, 0x02        ; Funcion leer
    mov al, 20          ; 20 sectores
    mov ch, 0           ; Cilindro 0
    mov cl, 10          ; Sector 10
    mov dh, 0           ; Cabeza 0
    mov dl, 0x00        ; Floppy
    mov bx, 0x1000      ; Segmento
    mov es, bx
    xor bx, bx          ; Offset 0
    int 0x13
    jc disk_error

    ; Resetear ES
    xor ax, ax
    mov es, ax

    ; Mensaje
    mov si, msg_pmode
    call print16

    ; Pequeño delay
    mov cx, 0xFFFF
.delay:
    nop
    loop .delay

    ; Deshabilitar interrupciones
    cli

    ; Cargar GDT
    lgdt [gdt_descriptor]

    ; Habilitar A20 (necesario para acceder a memoria alta)
    in al, 0x92
    or al, 2
    out 0x92, al

    ; Entrar a modo protegido
    mov eax, cr0
    or eax, 1
    mov cr0, eax

    ; Saltar a 32 bits
    jmp CODE_SEG:init_pm

disk_error:
    mov si, msg_error
    call print16
    jmp $

print16:
    mov ah, 0x0E
.l:
    lodsb
    test al, al
    jz .d
    int 0x10
    jmp .l
.d:
    ret

; ╔══════════════════════════════════════╗
; ║   GDT                                ║
; ╚══════════════════════════════════════╝

gdt_start:
    dd 0x0
    dd 0x0

gdt_code:
    dw 0xFFFF
    dw 0x0
    db 0x0
    db 10011010b
    db 11001111b
    db 0x0

gdt_data:
    dw 0xFFFF
    dw 0x0
    db 0x0
    db 10010010b
    db 11001111b
    db 0x0

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

; ╔══════════════════════════════════════╗
; ║   MODO PROTEGIDO 32 BITS             ║
; ╚══════════════════════════════════════╝

[BITS 32]
init_pm:
    mov ax, DATA_SEG
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    mov ebp, 0x90000
    mov esp, ebp

    ; Mensaje en pantalla VGA directamente
    mov edi, 0xB8000
    mov esi, msg_32
    mov ah, 0x0F
.print32:
    lodsb
    test al, al
    jz .done32
    mov [edi], ax
    add edi, 2
    jmp .print32
.done32:

    ; Pequeño delay
    mov ecx, 0xFFFFFF
.delay32:
    nop
    loop .delay32

    ; Saltar al kernel
    jmp 0x10000

msg_32 db 'Jumping to kernel at 0x10000...', 0

; ╔══════════════════════════════════════╗
; ║   DATOS                              ║
; ╚══════════════════════════════════════╝

[BITS 16]
msg_loading db 'Loading kernel from disk...', 13, 10, 0
msg_pmode   db 'Entering protected mode...', 13, 10, 0
msg_error   db 'Disk Error!', 0

times 4096-($-$$) db 0