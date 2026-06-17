void kernel_main(void) {
    // Apuntar directo a memoria de video
    volatile unsigned short* video = (volatile unsigned short*)0xB8000;
    
    // Limpiar pantalla con espacios cyan
    for (int i = 0; i < 80 * 25; i++) {
        video[i] = 0x0B20;  // Espacio en cyan
    }
    
    // Escribir "FLEXITY KERNEL OK" en la pantalla
    const char* msg = "FLEXITY KERNEL OK";
    int x = 0;
    while (msg[x] != 0) {
        video[80 * 12 + 30 + x] = (0x0F << 8) | msg[x];
        x++;
    }
    
    // Loop infinito
    while (1) {
        asm volatile("hlt");
    }
}