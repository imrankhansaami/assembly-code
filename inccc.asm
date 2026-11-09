.model small
.stack 100h

.data

    prompt db 'Enter a value: $'
    buffer db 10
           db 0
           db 10 dup('$')

.code

main proc

    mov ax, @data
    mov ds, ax

    mov ah, 9
    lea dx, prompt
    int 21h

    mov ah, 0Ah
    lea dx, inc
    int 21h

    mov dl, 0Dh
    mov ah, 2
    int 21h

    mov dl, 0Ah
    mov ah, 2
    int 21h

    mov si, offset buffer + 1
    mov cl, [si]
    mov ch, 0
    add si, cx
    mov byte ptr [si], '$'

    mov ah, 9
    lea dx, buffer + 2
    int 21h

    exit:

    mov ah, 4ch
    int 21h

main endp

end main