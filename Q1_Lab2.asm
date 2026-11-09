; =====================================================================
;  CSE 436 - Computer Interfacing Lab          Lab Test 2 - Question 1
;  8086 Assembly for emu8086 (DOS INT 21h only, no emu8086.inc macros)
;  File: Q1_Lab2.asm  (rename to Q1_<your student ID>.asm to submit)
;
;  Reads a line of text (max 60 chars, DOS function 0Ah) and prints:
;    (a) lowercase letters changed to uppercase
;    (b) every letter with its case toggled
;    (c) number of uppercase / lowercase / digits / other characters
;    (d) the original string in reverse (stack only, PUSH/POP)
;
;  Works for ANY input, not just the sample. The original text is
;  preserved because (a) and (b) convert a copy of it (explanation
;  comment at part (a)).
; =====================================================================

.MODEL SMALL
.STACK 100H

.DATA
; ---------------- input buffer for DOS function 0Ah ----------------
IN_MAX   DB 61              ; 61 -> up to 60 typed chars (DOS counts
                            ; the Enter/CR inside this limit)
IN_LEN   DB 0               ; DOS puts here the number of chars typed
IN_BUF   DB 64 DUP(0)       ; the typed characters (THE ORIGINAL STRING)

SCRATCH  DB 64 DUP(0)       ; working copy used ONLY by parts (a) and (b)

; ---------------- counters for part (c) ----------------
UP_CNT   DB 0               ; uppercase letters
LO_CNT   DB 0               ; lowercase letters
DG_CNT   DB 0               ; digits
OT_CNT   DB 0               ; spaces and symbols (everything else)

; ---------------- messages ----------------
CRLF     DB 0Dh, 0Ah, '$'
MSG_IN   DB 'Enter string: $'
MSG_UP   DB 'To upper : $'
MSG_TOG  DB 'Toggled  : $'
MSG_REV  DB 'Reversed : $'
MSG_U    DB 'Upper=$'
MSG_L    DB ' Lower=$'
MSG_DG   DB ' Digits=$'
MSG_OT   DB ' Other=$'

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX

    ; ---------- prompt + buffered input (DOS 0Ah, max 60 chars) ----------
    LEA DX, MSG_IN
    MOV AH, 09h
    INT 21h
    LEA DX, IN_MAX
    MOV AH, 0Ah
    INT 21h
    LEA DX, CRLF              ; move to the next line
    MOV AH, 09h
    INT 21h

    ; ================= (a) lowercase -> uppercase =================
    ; (a) and (b) convert a COPY (SCRATCH); the original stays in IN_BUF for (c) and (d).
    CALL COPY_ORIG
    LEA SI, SCRATCH
    MOV CL, IN_LEN
    MOV CH, 0
    MOV BL, 0                 ; BL = mode 0 : lowercase-to-uppercase only
    CALL CONVERT
    LEA DX, MSG_UP
    MOV AH, 09h
    INT 21h
    LEA SI, SCRATCH
    MOV CL, IN_LEN
    MOV CH, 0
    CALL PRINT_STR
    LEA DX, CRLF
    MOV AH, 09h
    INT 21h

    ; ================= (b) toggle every letter =================
    CALL COPY_ORIG            ; fresh copy of the original
    LEA SI, SCRATCH
    MOV CL, IN_LEN
    MOV CH, 0
    MOV BL, 1                 ; BL = mode 1 : toggle the case
    CALL CONVERT
    LEA DX, MSG_TOG
    MOV AH, 09h
    INT 21h
    LEA SI, SCRATCH
    MOV CL, IN_LEN
    MOV CH, 0
    CALL PRINT_STR
    LEA DX, CRLF
    MOV AH, 09h
    INT 21h

    ; ================= (c) counts =================
    LEA SI, IN_BUF            ; count in the untouched ORIGINAL
    MOV CL, IN_LEN
    MOV CH, 0
    CALL COUNT_CHARS
    LEA DX, MSG_U
    MOV AH, 09h
    INT 21h
    MOV AL, UP_CNT
    CALL PRINT_DEC
    LEA DX, MSG_L
    MOV AH, 09h
    INT 21h
    MOV AL, LO_CNT
    CALL PRINT_DEC
    LEA DX, MSG_DG
    MOV AH, 09h
    INT 21h
    MOV AL, DG_CNT
    CALL PRINT_DEC
    LEA DX, MSG_OT
    MOV AH, 09h
    INT 21h
    MOV AL, OT_CNT
    CALL PRINT_DEC
    LEA DX, CRLF
    MOV AH, 09h
    INT 21h

    ; ================= (d) reverse (stack only) =================
    LEA DX, MSG_REV
    MOV AH, 09h
    INT 21h
    LEA SI, IN_BUF            ; read the ORIGINAL string
    MOV CL, IN_LEN
    MOV CH, 0
    CALL REVERSE_PRINT        ; PUSH chars, POP them straight to screen
    LEA DX, CRLF
    MOV AH, 09h
    INT 21h

    ; ---------- back to DOS ----------
    MOV AH, 4Ch
    INT 21h
MAIN ENDP

; ---------------------------------------------------------------------
; COPY_ORIG - copies the typed text (IN_LEN chars) into SCRATCH.
; ---------------------------------------------------------------------
COPY_ORIG PROC
    PUSH AX
    PUSH CX
    PUSH SI
    PUSH DI
    MOV CL, IN_LEN
    MOV CH, 0
    LEA SI, IN_BUF
    LEA DI, SCRATCH
    JCXZ CO_DONE
CO_LOOP:
    MOV AL, [SI]
    MOV [DI], AL
    INC SI
    INC DI
    LOOP CO_LOOP
CO_DONE:
    POP DI
    POP SI
    POP CX
    POP AX
    RET
COPY_ORIG ENDP

; ---------------------------------------------------------------------
; CONVERT - converts the CX characters at SI in place. BL=0 changes
;           lowercase letters to uppercase only, BL=1 toggles every
;           letter. Each flip uses XOR AL,20h after an A-Z/a-z check.
; ---------------------------------------------------------------------
CONVERT PROC
    PUSH AX
    PUSH CX
    PUSH SI
    JCXZ CV_DONE
CV_LOOP:
    MOV AL, [SI]
    CMP AL, 'A'
    JB CV_NEED_LOWER           ; below 'A' -> maybe not a letter
    CMP AL, 'Z'
    JBE CV_IS_UPPER            ; 'A'..'Z' -> uppercase letter
CV_NEED_LOWER:
    CMP AL, 'a'
    JB CV_NEXT                 ; between 'Z' and 'a' -> not a letter
    CMP AL, 'z'
    JA CV_NEXT                 ; above 'z' -> not a letter
    JMP CV_FLIP                ; lowercase letter -> flip in BOTH modes
CV_IS_UPPER:
    TEST BL, BL
    JZ CV_NEXT                 ; mode 0: uppercase letters stay unchanged
CV_FLIP:
    XOR AL, 20h                ; flip the case bit (mask 20h, no +-32)
    MOV [SI], AL
CV_NEXT:
    INC SI
    LOOP CV_LOOP
CV_DONE:
    POP SI
    POP CX
    POP AX
    RET
CONVERT ENDP

; ---------------------------------------------------------------------
; PRINT_STR - prints the CX characters of the string at SI (DOS 02h).
; ---------------------------------------------------------------------
PRINT_STR PROC
    PUSH AX
    PUSH CX
    PUSH DX
    PUSH SI
    JCXZ PS_DONE
PS_LOOP:
    MOV DL, [SI]
    MOV AH, 02h
    INT 21h
    INC SI
    LOOP PS_LOOP
PS_DONE:
    POP SI
    POP DX
    POP CX
    POP AX
    RET
PRINT_STR ENDP

; ---------------------------------------------------------------------
; PRINT_DEC - prints the unsigned byte in AL as a decimal number
;             (one or two digits, also prints 0 correctly).
; ---------------------------------------------------------------------
PRINT_DEC PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    MOV AH, 0                  ; AX = number to print
    XOR CX, CX                 ; CL will count the digits
    MOV BX, 10
PD_LOOP:
    XOR DX, DX                 ; clear the high word before DIV
    DIV BX                     ; AX = value/10, DX = value mod 10
    PUSH DX                    ; save this digit
    INC CX
    CMP AX, 0
    JNE PD_LOOP
PD_PRINT:
    POP DX                     ; digits come back most significant first
    ADD DL, '0'
    MOV AH, 02h
    INT 21h
    LOOP PD_PRINT
    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_DEC ENDP

; ---------------------------------------------------------------------
; COUNT_CHARS - counts the CX characters at SI into UP_CNT (A-Z),
;               LO_CNT (a-z), DG_CNT (0-9), OT_CNT (everything else).
; ---------------------------------------------------------------------
COUNT_CHARS PROC
    PUSH AX
    PUSH CX
    PUSH SI
    MOV UP_CNT, 0
    MOV LO_CNT, 0
    MOV DG_CNT, 0
    MOV OT_CNT, 0
    JCXZ CC_DONE
CC_LOOP:
    MOV AL, [SI]
    CMP AL, 'A'
    JB CC_TRY_LOWER
    CMP AL, 'Z'
    JBE CC_UPPER
CC_TRY_LOWER:
    CMP AL, 'a'
    JB CC_TRY_DIGIT
    CMP AL, 'z'
    JBE CC_LOWER
CC_TRY_DIGIT:
    CMP AL, '0'
    JB CC_OTHER
    CMP AL, '9'
    JBE CC_DIGIT
CC_OTHER:
    INC OT_CNT
    JMP CC_NEXT
CC_UPPER:
    INC UP_CNT
    JMP CC_NEXT
CC_LOWER:
    INC LO_CNT
    JMP CC_NEXT
CC_DIGIT:
    INC DG_CNT
CC_NEXT:
    INC SI
    LOOP CC_LOOP
CC_DONE:
    POP SI
    POP CX
    POP AX
    RET
COUNT_CHARS ENDP

; ---------------------------------------------------------------------
; REVERSE_PRINT - prints the CX characters at SI in reverse order.
;                 Only the stack is used: every character is PUSHed,
;                 then POPped straight to the screen (no buffer).
; ---------------------------------------------------------------------
REVERSE_PRINT PROC
    PUSH AX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH BP
    MOV BP, CX                 ; keep the count for the print loop
    JCXZ RP_DONE
RP_PUSH:
    MOV AL, [SI]
    MOV AH, 0
    PUSH AX                    ; save one character on the stack
    INC SI
    LOOP RP_PUSH
    MOV CX, BP                 ; count back into CX
RP_POP:
    POP DX                     ; LIFO: last character comes out first
    MOV AH, 02h
    INT 21h
    LOOP RP_POP
RP_DONE:
    POP BP
    POP SI
    POP DX
    POP CX
    POP AX
    RET
REVERSE_PRINT ENDP

END MAIN
