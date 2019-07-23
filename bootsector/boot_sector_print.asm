;Prints a null terminated string using BIOS functions. BX must contain the adress 
;of the null terminated string


print:
   pusha

start:
  mov al, [bx]
  cmp al, 0
  je done
  

  mov ah, 0x0e
  int 0x10
  
  add bx, 1
  jmp start



done:
   popa
   ret



print_nl:
   pusha
   mov ah, 0x0e
   mov al, 0x0a ;New line
   int 0x10
   mov al, 0x0d ;Carriage return
   int 0x10
   popa
   ret

