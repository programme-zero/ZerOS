;TODO : Change the bootloader to a 2 staged one


[org 0x7C00]
[bits 16]

%define PMAPL4 0xA000
%define KENTRY 0x100000 ;Kernel entry point

boot:
    jmp init
    TIMES 3-($-$$) DB 0x90   ; Support 2 or 3 byte encoded JMPs before BPB.

    ; Dos 4.0 EBPB 1.44MB floppy
    OEMname:           db    "mkfs.fat"  ; mkfs.fat is what OEMname mkdosfs uses
    bytesPerSector:    dw    512
    sectPerCluster:    db    1
    reservedSectors:   dw    1
    numFAT:            db    2
    numRootDirEntries: dw    224
    numSectors:        dw    2880
    mediaType:         db    0xf0
    numFATsectors:     dw    9
    sectorsPerTrack:   dw    18
    numHeads:          dw    2
    numHiddenSectors:  dd    0
    numSectorsHuge:    dd    0
    driveNum:          db    0
    reserved:          db    0
    signature:         db    0x29
    volumeID:          dd    0x2d7e5a1a
    volumeLabel:       db    "NO NAME    "
    fileSysType:       db    "FAT12   "

mov ax, 0x2403   ;Enabling the A20 line with the BIOS
int 0x15
jmp 0x0000:init

init:
xor ax, ax
mov ss, ax
mov ds, ax
mov es, ax
mov fs, ax
mov gs, ax

mov sp, boot

mov ax, 0xFFFF
mov es, ax

mov bx, 0x10
mov dh, 15

call disk_load

xor ax, ax
mov es, ax

cld

mov edi, PMAPL4
jmp SwitchToLongMode

jmp $ ; jump to current address = infinite loop

%include "./bootsector/boot_sector_longmode.asm"
%include "./bootsector/boot_sector_disk.asm"

; padding and magic number
times 510 - ($-$$) db 0
dw 0xaa55