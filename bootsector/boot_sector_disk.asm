[bits 16]
disk_load:
pusha
mov ah, 0x02
mov al, dh
mov ch, 0x00
mov dh, 0x00
mov cl, 0x02
int 0x13
popa
ret
