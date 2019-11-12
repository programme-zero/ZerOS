bits 16	;We still are in 16 real mode
org 0

;======================================================================
;              Entry point of the second stage boot loader
;				
;	We assume we are loaded at 0x10000 with segment cs = 0x1000
;======================================================================

;Setting the ds segment to the proper value
mov ax, cs
mov ds, ax

mov si, String.State.OK
call Print

;We need to enable the A20 line 

mov si, String.A20.IsEnabled
call Print

call check_a20	;Is the A20 line already enabled ?
cmp ax, 1
jz A20_enabled

mov si, String.State.Disabled
call Print

mov si, String.Panic.A20
call Print
jmp Panic   ;If the A20 line is disabled then panic
;jmp A20_done


A20_enabled:
mov si, String.State.Enabled
call Print


A20_done:




jmp $	;We will remove this later on



;======================================================================
; Print
; 
; Prints a null terminated string using BIOS int 10 function ah = 0e
;
;Input:
; DS:SI       Start of the null terminated string
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
;   Panic
;   
;   Called in case of critical errors that cannot be recovered from.
;   Halts the system.
;======================================================================
Panic:
cli
hlt
jmp $
;======================================================================
; Function: check_a20
;
; Purpose: to check the status of the a20 line in a completely self-contained state-preserving way.
;          The function can be modified as necessary by removing push's at the beginning and their
;          respective pop's at the end if complete self-containment is not required.
;
; Returns: 0 in ax if the a20 line is disabled (memory wraps around)
;          1 in ax if the a20 line is enabled (memory does not wrap around)
;======================================================================
 
check_a20:      ;TODO : Rewrite this code and comment it
    pushf
    push ds
    push es
    push di
    push si
 
    cli
 
    xor ax, ax ; ax = 0
    mov es, ax
 
    not ax ; ax = 0xFFFF
    mov ds, ax
 
    mov di, 0x0500
    mov si, 0x0510
 
    mov al, byte [es:di]
    push ax
 
    mov al, byte [ds:si]
    push ax
 
    mov byte [es:di], 0x00
    mov byte [ds:si], 0xFF
 
    cmp byte [es:di], 0xFF
 
    pop ax
    mov byte [ds:si], al
 
    pop ax
    mov byte [es:di], al
 
    mov ax, 0
    je .check_a20__exit
 
    mov ax, 1
 
.check_a20__exit:
    pop si
    pop di
    pop es
    pop ds
    popf
 
    ret


;======================================================================
;                       Datas and variables
;======================================================================

String.State.OK 	  DB "OK", 0x0d, 0x0a, 0
String.State.Enabled  DB "Enabled", 0x0d, 0x0a, 0
String.State.Disabled DB "Disabled", 0x0d, 0x0a, 0

String.A20.IsEnabled  DB "[A20] Checking the A20 line state : ", 0

String.Panic.A20      DB "[PANIC] The A20 line  needs to be enabled !", 0x0d, 0x0a, 0
