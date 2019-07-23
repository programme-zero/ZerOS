#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

void outb(uint16_t port, uint8_t value)
{
asm ("mov dx, %0"::"r" (port):);
asm ("mov al, %0"::"r" (value):);
asm("out dx, al");
}

void outw(uint16_t port, uint16_t value)
{
asm ("mov dx, %0"::"r" (port):);
asm ("mov ax, %0"::"r" (value):);
asm("out dx, ax");
}