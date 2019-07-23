;Displays a string with the current time in this format hh:mm:ss string
;Inputs
;bx string to display


log_string:
pusha


mov ah, 0x02
int 0x1A
jc error_reading_rtc
mov al, ch
shr al, 4
add al, 48
mov [CLOCK_STRING+1], al
mov al, ch
and al, 0x0F
add al, 48
mov [CLOCK_STRING+2], al

mov al, cl
shr al, 4
add al, 48
mov [CLOCK_STRING+4], al
mov al, cl
and al, 0x0F
add al, 48
mov [CLOCK_STRING+5], al

mov al, dh
shr al, 4
add al, 48
mov [CLOCK_STRING+7], al
mov al, dh
and al, 0x0F
add al, 48
mov [CLOCK_STRING+8], al

push bx
mov bx, CLOCK_STRING
call print
pop bx
call print

end_log:
popa
ret

error_reading_rtc:
mov bx, ERROR_RTC_STRING
call print
call print_nl
jmp end_log

CLOCK_STRING db "[00:00:00] ", 0
ERROR_RTC_STRING db "Error accessing the RTC clock !", 0



