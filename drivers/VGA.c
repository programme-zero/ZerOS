#include "../drivers/VGA.h"
#include "../drivers/ports.h"

//Fix this ugly as fuck driver, rewrite the whole code and make it based on a struct
 
static inline uint8_t vga_entry_color(enum vga_color fg, enum vga_color bg) 
{
	return fg | bg << 4;
}
 
static inline uint16_t vga_entry(unsigned char uc, uint8_t color) 
{
	return (uint16_t) uc | (uint16_t) color << 8;
}
 
size_t strlen(const char* str)  //TODO: Move this function in the proper file
{
	size_t len = 0;
	while (str[len])
		len++;
	return len;
}
 
static const size_t VGA_WIDTH = 80;
static const size_t VGA_HEIGHT = 25;
 
size_t terminal_row;
size_t terminal_column;
uint8_t terminal_color;
uint16_t* terminal_buffer;

void terminal_disable_cursor(){
	outb(0x3D4, 0xA);
	outb(0x3D5, 0x20);
}

/*Resets the terminal to a blank state */

void terminal_initialize() 
{
	terminal_disable_cursor();
	terminal_row = 0;
	terminal_column = 0;
	terminal_color = vga_entry_color(VGA_COLOR_LIGHT_GREY, VGA_COLOR_BLACK);
	terminal_buffer = (uint16_t*) VGA_BUFFER;
	for (size_t y = 0; y < VGA_HEIGHT; y++) {
		for (size_t x = 0; x < VGA_WIDTH; x++) {
			const size_t index = y * VGA_WIDTH + x;
			terminal_buffer[index] = vga_entry(' ', terminal_color);
		}
	}
}

/*Sets the current color being used when printing to the terminal */

void terminal_setcolor(uint8_t color) 
{
	terminal_color = color;
}

/*Puts a character to the specified position */
 
void terminal_putentryat(char c, uint8_t color, size_t x, size_t y) 
{
	const size_t index = y * VGA_WIDTH + x;
	terminal_buffer[index] = vga_entry(c, color);
}

/*Writes a character to the last position in the terminal */
 
void terminal_putchar(char c) 
{
	if (c == LINE_RETURN) {
		terminal_row++;
		terminal_column = 0;
	}
	else {
	terminal_putentryat(c, terminal_color, terminal_column, terminal_row);

	if (++terminal_column == VGA_WIDTH) {
		terminal_column = 0;
		if (++terminal_row == VGA_HEIGHT)
			terminal_row = 0;
	}
		}
}

/*Writes to the VGA memory*/
 
void terminal_write(const char* data, size_t size) 
{
	for (size_t i = 0; i < size; i++)
		terminal_putchar(data[i]);
}

/*Writes a string to terminal */
 
void terminal_writestring(const char* data) 
{
	terminal_write(data, strlen(data));
}
 