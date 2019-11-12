bits 16
org 0

;======================================================================
;                   Entry point of ZerOS
;======================================================================

jmp Boot

 TIMES 3-($-$$) DB 0x90 ; Padding to 3 bytes

bpbOEM			               DB "ZerOS   "	
bpbBytesPerSector:  	          DW 512
bpbSectorsPerCluster: 	          DB 1
bpbReservedSectors: 	          DW 1
bpbNumberOfFATs: 	               DB 2
bpbRootEntries: 	               DW 224
bpbTotalSectors: 	               DW 2880
bpbMedia: 		               DB 0xF0
bpbSectorsPerFAT: 	               DW 9
bpbSectorsPerTrack: 	          DW 18
bpbHeadsPerCylinder: 	          DW 2
bpbHiddenSectors:                  DD 0
bpbTotalSectorsBig:                DD 0
bsDriveNumber: 	               DB 0
bsUnused: 		               DB 0
bsExtBootSignature: 	          DB 0x29
bsSerialNumber:	               DD 0xa0a1a2a3
bsVolumeLabel: 	               DB "MOS FLOPPY "
bsFileSystem: 	                    DB "FAT12   "

Boot:
     ;Settings up the segments

jmp 0x07c0:Init   ;Set code segment to 0x07c0 with a far jump

Init:

;Setting up the segments

cli ;Disable interrupt to avoid problems

mov ax, cs
mov ds, ax
mov fs, ax
mov gs, ax

;Setting up the stack

xor ax, ax ;ax = 0
mov ss, ax
mov es, ax
mov sp, 0x7c00 ;ss = 0, the stack will grow away from our bootloader

sti ;Segments are set up we can re enable interrupts

mov BYTE [Boot.DriveNumber], dl   ;Store the bootdrive for later use

mov si, String.Booting
call Print

;Do some required calculations to load the root directory

xor cx, cx

mov ax, WORD [bpbRootEntries]
mov cx , 0x20                      ;32 bytes per entry
mul cx
div WORD [bpbBytesPerSector]

xchg ax, cx                        ;Store in cx
xor ax, ax

mov al, BYTE [bpbNumberOfFATs]
mul WORD [bpbSectorsPerFAT]
add ax, WORD [bpbReservedSectors]  ;ax = Starting sector of the root directory
mov WORD [Disk.DataSector], ax     ;Store the starting sector of the root directory
add WORD [Disk.DataSector], cx     ;Add size, we know have the start of data area

;Load the root directory to memory

mov bx, 0x800            ;We are going to load the root directory there
call ReadSectors


;Locate the second stage loader named KRNLDR.SYS


mov cx, WORD [bpbRootEntries]
mov di, 0x800
.Loop:
push cx
mov cx, 11  ;Name + extension
mov si, String.FileName
push di
repe cmpsb   ;Check for the filename and extension (11 bytes)
pop di
je .LoadFAT              ;We found our loader
add di, 0x20
pop cx
loop .Loop
jmp CriticalError        ;File not found we can't continue



.LoadFAT:
mov dl, BYTE [es:di + 0x001A]
mov BYTE [Disk.Cluster], dl    ;First cluster of the file, we now need to load the FAT

mov ax, WORD [bpbReservedSectors] ;Location of FAT
mov cx, WORD [bpbSectorsPerFAT]   ;Size of FAT
mov bx, 0x800

call ReadSectors ;Load the FAT to memory


;Routines to load the second stage in memory.

LoadImage:
mov dx, 0x1000 ;Preparing the address and the segment to specify where to load the image.
mov es, dx
xor bx, bx     ;bx = 0

mov al, BYTE [Disk.Cluster] ;Load the cluster to convert
call ClusterLBA
xor cx, cx
mov cl, BYTE [bpbSectorsPerCluster]

call ReadSectors    ;es:bx = 0x1000:0


SecondStage:
jmp 0x1000:0    ;We loaded the second stage at 0x10000, jump to it and set the cs segment.
;Execution is stopped here as we should never return from the jump

CriticalError:
                              ;Display an error message then lock the machine
mov si, String.Critical
call Print
cli
hlt

;======================================================================
; ReadSectors
; 
; Reads sectors from the selected drive using BIOS int 0x13 function AH = 0x02
;
;Input:
;  AX               LBA Address
;  CX               Number of sectors to read
;  ES:BX            Buffer to write to
;======================================================================
ReadSectors:
pusha

.Read:
push cx
mov si, 5                ;5 read retries before aborting
call LBACHS              ;Convert the LBA to CHS

.Loop:
mov ah, 0x02
mov al, 1
mov ch, BYTE [Disk.Cylinder]
mov cl, BYTE [Disk.Sector]
mov dh, BYTE [Disk.Head]
mov dl, BYTE [Boot.DriveNumber]
int 0x13
pop cx
jnc .Success
dec si
jnz .Loop
jmp CriticalError

.Success:            ;Sector read to memory, check if we are done if not read next

inc ax
add bx, 0x200 ;512 bytes
loop .Read

.End:
popa
ret
;======================================================================
; Print
; 
; Prints a null terminated string using BIOS int 10 function ah = 0e
;
;Input:
; SI       Start of the null terminated string
;======================================================================

Print:
pusha
cld ;Clear the direction flag

.Loop:
lodsb ;Load the next byte into AL
cmp al, 0 ;Check for the end of the string
jz .End
 

mov ah, 0x0e  ;BIOS function AH=0E : Teletype output
int 0x10
jmp .Loop

.End:
popa
ret

;======================================================================
; LBACHS
; 
; Converts an LBA address to a CHS one
;
;Input:
; AX       Address to convert
;======================================================================
LBACHS:
pusha
xor     dx, dx                              ; prepare dx:ax for operation
div     WORD [bpbSectorsPerTrack]           ; calculate
inc     dl                                  ; adjust for sector 0
mov     BYTE [Disk.Sector], dl
xor     dx, dx                              ; prepare dx:ax for operation
div     WORD [bpbHeadsPerCylinder]          ; calculate
mov     BYTE [Disk.Head], dl
mov     BYTE [Disk.Cylinder], al
popa
ret

;======================================================================
; ClusterLBA
; 
; Converts a cluster number to an LBA address
; LBA = (Cluster - 2) * Sectors per cluster
;
;Input:
; AX       Cluster number to convert
;======================================================================
ClusterLBA:
xor cx, cx ;Zero out cx
sub ax, 2
mov cl, BYTE [bpbSectorsPerCluster]
mul cx
add ax, WORD [Disk.DataSector]     ;Add offset for the data sector
ret


;======================================================================
;                       Datas and variables
;======================================================================
Disk.Cylinder   DB 0
Disk.Head       DB 0
Disk.Sector     DB 0
Disk.Cluster    DB 0
Disk.DataSector DW 0

Boot.DriveNumber DB 0

String.Critical DB 0x0d, 0x0a,"[PANIC] Critical error, aborting boot !", 0x0d, 0x0a, 0
String.FileName DB "KRNLDR  SYS"
String.Booting  DB "[BOOT] Loading the kernel loader...", 0
;======================================================================
;                      Padding & Boot signature
;======================================================================

TIMES 510-($-$$) DB 0
 DW 0xAA55
