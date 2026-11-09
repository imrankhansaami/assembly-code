.MODEL SMALL
.STACK 100H

.DATA
    msg   DB 'Enter a 2-digit number: $'
    msg_even DB 0DH, 0AH, 'The number is Even.$'
    msg_odd  DB 0DH, 0AH, 'The number is Odd.$'
    msg_rem  DB 0DH, 0AH, 'Remainder when divided by 10: $'
    num      DB ?
    rem      DB ?

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX

    MOV AH, 09H
    LEA DX, msg
    INT 21H

    MOV AH, 01H
    INT 21H
    SUB AL, 30H
    MOV BL, 10
    MUL BL
    MOV num, AL

    MOV AH, 01H
    INT 21H
    SUB AL, 30H
    ADD num, AL

    MOV AL, num
    TEST AL, 1
    JZ IS_EVEN

IS_ODD:
    MOV AH, 09H
    LEA DX, msg_odd
    INT 21H
    JMP FIND_REM

IS_EVEN:
    MOV AH, 09H
    LEA DX, msg_even
    INT 21H

FIND_REM:
    MOV AL, num
    MOV AH, 0
    MOV BL, 10
    DIV BL
    MOV rem, AH

    MOV AH, 09H
    LEA DX, msg_rem
    INT 21H

    MOV DL, rem
    ADD DL, 30H
    MOV AH, 02H
    INT 21H

    MOV AH, 4CH
    INT 21H
MAIN ENDP
END MAIN