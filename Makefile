C_SOURCES = $(wildcard kernel/*.c drivers/*.c)
HEADERS = $(wildcard kernel/*.h drivers/*.h)
# Nice syntax for file extension replacement
OBJ = ${C_SOURCES:.c=.o}

# Change this if your cross-compiler is somewhere else
CC = x86_64-elf-gcc
GDB = gdb
# -g: Use debugging symbols in gcc
CFLAGS = -g -masm=intel

# First rule is run by default
os-image.bin: bootsector/boot.bin kernel.bin
	cat $^ > os-image.bin

# '--oformat binary' deletes all symbols as a collateral, so we don't need
# to 'strip' them manually on this case
kernel.bin: bootsector/kernel_entry.o ${OBJ}
	x86_64-elf-ld -o $@ -T ./kernel/linker.txt $^ --oformat binary

# Used for debugging purposes
kernel.elf: bootsector/kernel_entry.o ${OBJ}
	x86_64-elf-ld -o $@ -T ./kernel/linker.txt $^ 

run: os-image.bin
	qemu-system-x86_64 -fda os-image.bin

# Open the connection to qemu and load our kernel-object file with symbols
debug: os-image.bin kernel.elf
	qemu-system-x86_64 -s -S -fda os-image.bin &
	${GDB} -ex "target remote localhost:1234" -ex "symbol-file kernel.elf"

# Generic rules for wildcards
# To make an object, always compile from its .c
%.o: %.c ${HEADERS}
	${CC} ${CFLAGS} -ffreestanding -Wall -Wextra -mcmodel=large -mno-red-zone -mno-mmx -mno-sse -mno-sse2 -c $< -o $@

%.o: %.asm
	nasm $< -f elf -o $@

%.bin: %.asm
	nasm $< -f bin -o $@

clean:
	rm -rf *.bin *.dis *.o os-image.bin *.elf
	rm -rf kernel/*.o boot/*.bin boot/*.o
