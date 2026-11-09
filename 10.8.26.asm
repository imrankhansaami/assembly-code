.model small
.stack 100h

.data
    m db 'I am a student $'

.code           

main proc
   
    mov ax, @data
    mov ds, ax

    ; Display string stored in variable 'm'
    mov ah, 9
    lea dx, m
    int 21h
  
    mov ah, 4ch
    int 21h
main endp

end main