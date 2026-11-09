.model small
.stack 100h

.data

    prompt db 'Enter a number: $'
    result db 'Incremented by 2: $'
    buffer db 6
           db 0
           db 6 dup('$')
    outbuf db 6 dup('$')

.code

main proc

    mov ax, @data
    mov ds, ax

    mov ah, 9
    lea dx, prompt
    int 21h

    mov ah, 0Ah
    lea dx, buffer
    int 21h

    mov dl, 0Dh
    mov ah, 2
    int 21h

    mov dl, 0Ah
    mov ah, 2
    int 21h

    mov si, offset buffer + 2
    xor ax, ax
    xor bx, bx

convert_loop:

    mov bl, [si]
    cmp bl, 0Dh
    je done_convert
    sub bl, '0'
    cmp bl, 9
    ja done_convert
    mov cx, 10
    mul cx
    add ax, bx
    inc si
    jmp convert_loop

done_convert:

    add ax, 2

    mov di, offset outbuf + 5
    mov byte ptr [di], '$'
    dec di

    test ax, ax
    jnz not_zero
    mov byte ptr [di], '0'
    jmp output_result

not_zero:

    mov bx, 10

divide:

    xor dx, dx
    div bx
    add dl, '0'
    mov [di], dl
    dec di
    test ax, ax
    jnz divide
    inc di

output_result:

    mov ah, 9
    lea dx, result
    int 21h

    mov ah, 9
    mov dx, di
    int 21h

    exit:

    mov ah, 4ch
    int 21h

main endp

end main