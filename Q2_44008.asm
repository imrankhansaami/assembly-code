; Q2_44008.asm - CSE 436 Lab Test 2, Question 2
; Password login (max 3 attempts) with masked input, then new password setup

.model small
.stack 100h

.data
MAXLEN equ 12               ; max password length
MINLEN equ 6                ; min length for a new password
MAXTRY equ 3                ; max login attempts

PASS   db 'Asm@86',0        ; stored password (0 = end marker)
INBUF  db 12 dup(0)         ; typed login password
NEW1   db 12 dup(0)         ; new password, first entry
NEW2   db 12 dup(0)         ; new password, confirmation
len1   db 0                 ; length of NEW1
len2   db 0                 ; length of NEW2
tries  db 0                 ; attempts left

msgEnter   db 'Enter password: $'
msgWrong   db 'Wrong password. Attempts left: $'
msgLocked  db 'Account Locked$'
msgGrant   db 'Access Granted$'
msgNew1    db 'New password: $'
msgNew2    db 'Confirm password: $'
msgNoMatch db 'Passwords do not match$'
msgShort   db 'Password must be at least 6 characters$'
msgNoDigit db 'Password must contain at least one digit$'
msgDone    db 'Password accepted$'

.code
; MAIN: login with up to 3 attempts, then new password entry and checks
main proc
    mov ax, @data
    mov ds, ax
    mov es, ax              ; ES = DS because CMPSB uses ES:DI
    mov tries, MAXTRY

login:
    lea dx, msgEnter
    call PRINTMSG
    lea di, INBUF
    call READPW             ; CX = typed length
    call NEWLINE
    mov bx, cx              ; BX = typed length
    lea si, PASS
    call STRLEN             ; CX = stored password length
    lea di, INBUF
    call COMPARE            ; AL = 1 if equal
    cmp al, 1
    je  granted
    dec tries               ; wrong: one attempt used
    lea dx, msgWrong
    call PRINTMSG
    mov dl, tries           ; print attempts left as one digit
    add dl, '0'
    mov ah, 02h
    int 21h
    call NEWLINE
    cmp tries, 0
    jne login               ; attempts remain: ask again
    lea dx, msgLocked       ; 3 failures: lock and exit with code 1
    call PRINTMSG
    call NEWLINE
    mov ax, 4C01h
    int 21h

granted:
    lea dx, msgGrant
    call PRINTMSG
    call NEWLINE

newpw:
    lea dx, msgNew1         ; first entry
    call PRINTMSG
    lea di, NEW1
    call READPW
    call NEWLINE
    mov len1, cl
    lea dx, msgNew2         ; second entry
    call PRINTMSG
    lea di, NEW2
    call READPW
    call NEWLINE
    mov len2, cl

    mov cl, len1            ; check 1: both entries match
    xor ch, ch
    mov bl, len2
    xor bh, bh
    lea si, NEW1
    lea di, NEW2
    call COMPARE
    cmp al, 1
    je  chklen
    lea dx, msgNoMatch
    call PRINTMSG
    call NEWLINE
    jmp newpw

chklen:
    cmp len1, MINLEN        ; check 2: length at least 6
    jae chkdig
    lea dx, msgShort
    call PRINTMSG
    call NEWLINE
    jmp newpw

chkdig:
    mov cl, len1            ; check 3: at least one digit
    xor ch, ch
    lea si, NEW1
    call HASDIGIT
    cmp al, 1
    je  accepted
    lea dx, msgNoDigit
    call PRINTMSG
    call NEWLINE
    jmp newpw

accepted:
    lea dx, msgDone
    call PRINTMSG
    call NEWLINE
    mov ax, 4C00h           ; exit to DOS
    int 21h
main endp

; READPW: reads a hidden password into the buffer at DI, shows '*', returns length in CX
READPW proc
    push ax
    push dx
    push di
    xor cx, cx              ; CX = characters typed so far
rd1:
    mov ah, 08h             ; read key without echo
    int 21h
    cmp al, 0Dh             ; Enter ends input
    je  rd9
    cmp al, 08h             ; Backspace
    je  rd2
    cmp cx, MAXLEN          ; buffer full: ignore the key
    jae rd1
    mov [di], al            ; store the character
    inc di
    inc cx
    mov dl, '*'             ; show a star instead
    mov ah, 02h
    int 21h
    jmp rd1
rd2:
    cmp cx, 0               ; empty buffer: do nothing
    je  rd1
    dec di                  ; remove last character from the buffer
    dec cx
    mov dl, 08h             ; erase the star: back, space, back
    mov ah, 02h
    int 21h
    mov dl, ' '
    int 21h
    mov dl, 08h
    int 21h
    jmp rd1
rd9:
    pop di
    pop dx
    pop ax
    ret
READPW endp

; COMPARE: SI,DI = strings, CX = length of SI string, BX = length of DI string; AL=1 if equal else 0
COMPARE proc
    push cx
    push si
    push di
    mov al, 0
    cmp cx, bx              ; lengths first (rejects a prefix like Asm@)
    jne cm9
    cld
    jcxz cm8                ; both empty: equal
    repe cmpsb              ; compare byte by byte while equal
    jne cm9                 ; mismatch found
cm8:
    mov al, 1
cm9:
    pop di
    pop si
    pop cx
    ret
COMPARE endp

; STRLEN: returns in CX the length of the 0-terminated string at SI
STRLEN proc
    push ax
    push si
    xor cx, cx
sl1:
    mov al, [si]
    cmp al, 0
    je  sl9
    inc si
    inc cx
    jmp sl1
sl9:
    pop si
    pop ax
    ret
STRLEN endp

; HASDIGIT: checks CX chars at SI; AL=1 if at least one is a digit '0'..'9', else 0
HASDIGIT proc
    push cx
    push si
    mov al, 0
    jcxz hd9                ; empty string: no digit
hd1:
    mov ah, [si]
    cmp ah, '0'
    jb  hd2
    cmp ah, '9'
    ja  hd2
    mov al, 1               ; digit found
    jmp hd9
hd2:
    inc si
    loop hd1
hd9:
    pop si
    pop cx
    ret
HASDIGIT endp

; PRINTMSG: prints the '$'-terminated message whose address is in DX
PRINTMSG proc
    push ax
    mov ah, 09h
    int 21h
    pop ax
    ret
PRINTMSG endp

; NEWLINE: moves the cursor to the start of the next line (CR + LF)
NEWLINE proc
    push ax
    push dx
    mov dl, 0Dh
    mov ah, 02h
    int 21h
    mov dl, 0Ah
    int 21h
    pop dx
    pop ax
    ret
NEWLINE endp

end main
