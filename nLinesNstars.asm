.model small
.stack 100h
.data    

msg1 db 10,13, 'Input n lines & n stars print: $'
msg2 db 10,13, 'Show stars:$'
n dw ?

.code 
main proc
    mov ax, @data
    mov ds, ax
    
    mov ah, 9
    lea dx, msg1
    int 21h      

    mov ah, 1
    int 21h
    sub al, 30h
    mov ah, 0
    mov n, ax

    mov ah, 9
    lea dx, msg2
    int 21h      

    mov ah, 2
    mov dl, 10
    int 21h
    mov dl, 13
    int 21h

    mov cx, n

outer_loop:
    push cx
    
    mov cx, n
    mov ah, 2
    mov dl, '*'

inner_loop:
    int 21h
    loop inner_loop

    mov ah, 2
    mov dl, 10
    int 21h
    mov dl, 13
    int 21h

    pop cx
    loop outer_loop

    mov ah, 4ch
    int 21h
main endp
end main