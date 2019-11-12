#!/bin/bash
echo "Building os-image.bin ..."
i686-elf-gcc -c ./kernel/kernel.c -o ./kernel/kernel.o -g -std=gnu99 -masm=intel -ffreestanding -O2 -Wall -Wextra

i686-elf-gcc -o ./kernel/kernel.bin -T ./kernel/linker.txt ./kernel/kernel_entry.o ./kernel/kernel.o -ffreestanding -O2 -nostdlib -lgcc -g

cat ./kernel/bootsect.bin ./kernel/kernel.bin > os-image.bin

echo "Done !"
