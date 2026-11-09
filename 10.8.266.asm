.model small
.stack 100h

.data
    m db 'I am a student $' ; creating variable and using it

.code
main proc
    ; 1 -> single key input
    ; 2 -> single key output
    ; 9 -> character string output

    ; Initialize data segment
    mov ax, @data
    mov ds, ax

    ; Print the string
    mov ah, 9
    lea dx, m
    int 21h

    ; Take single key input
    mov ah, 1
    int 21h
    mov bl, al

    ; Output the single key
    mov ah, 2
    mov dl, bl
    int 21h

    exit:
    mov ah, 4ch
    int 21h
main endp

end main