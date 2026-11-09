.model small
.stack 100h

.data
 
  a db 10,13, 'Enter first 4 bit : $'   
  b db 10,13, 'Enter second 4 bit : $'
  
  msg_and db 10,13, 'And Result: $'
  msg_or db 10,13, 'OR Result: $'
  msg_xor db 10,13, 'XOR Result: $' 
  
 
  
  .code
  
  main proc
    
    mov ax, @data
    mov ds, ax   
    
   mov ah,9
   lea dx,a
   int 21h
   
   mov cx,4
   xor bl,bl
   
   input1:  
   
   mov ah,1
   int 21h
   sub al,48
   shl bl,1
   or bl,al   
   
   loop input1
   
   
   mov ah,9
   lea dx,b
   int 21h
   
   mov cx,4
   xor bh,bh
   
   input2:
   mov ah,1
   int 21h
   sub al,48
   shl bh,1
   or bh,al
   loop input2
   
   
   mov ah,9
   lea dx, msg_and
   int 21h
   
   mov al,bl
   and al,bh
   call PRINT_BIN
   
   
   mov ah,9
   lea dx, msg_or
   int 21h
   
   mov al,bl
   or al,bh
   call PRINT_BIN
   
   mov ah,9
   lea dx,msg_xor
   int 21h
   
   mov al, bl
   xor al,bh
   call PRINT_BIN
   
   exit:
   mov ah,4ch
   int 21h
   main endp
  
  
  PRINT_BIN proc
    shl al,4
    mov cx,4 
    
    print_loop:
    shl al,1
    jc print_1
    
    mov dl, '0'
    jmp do_print
    
    print_1:
    mov dl, '1'
    
    do_print:
    
    push ax
    mov ah,2
    int 21h
    pop ax
    
    loop print_loop
    ret
    PRINT_BIN endp
  
  end main
    
    
    
    
   