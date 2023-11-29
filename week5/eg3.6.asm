stack segment para stack 'stack'
    db 256 dup(0) ; 256 bytes de stack
stack ends

data segment para public 'data'
    buffer db 16h dup(0) ; 16 bytes de buffer
    bufpt1 dw 0
    bufpt2 dw 0
    kbflag db 0
    prompt db '--- kbd_io program begin ---',0dh,0ah,'$'
    scantab db 0,0,'1234567890-=',8,0
            db 'qwertyuiop[]',0dh,0
            db 'asdfghjkl;',0,0,0,0
            db 'zxcvbnm,./',0,0,0
            db ' ',0,0,0,0,0,0,0,0,0,0,0,0,0
            db '789-456+1230.'
    even
    oldcs9 dw ?
    oldip9 dw ?
data ends

code segment para public 'code'
start proc far 
    assume cs:code,ds:data
    push ds
    mov ax,0
    push ax
    mov ax,data
    mov ds,ax

    cli
    mov al,09
    mov ah,35h
    int 21h
    mov oldcs9,es
    mov oldip9,bx

    push ds
    mov dx,offset kbint
    mov ax,seg kbint
    mov ds,ax
    mov al,09
    mov ah,25h
    int 21h
    pop ds

    in al,21h
    and al,0fdh
    out 21h,al

    mov dx,offset prompt
    mov ah,9
    int 21h
    sti

forever:
    call kbget
    test kbflag,80h
    jnz endint
    push ax
    call dispchar
    pop ax
    cmp al,0dh
    jnz forever
    mov al,0ah
    call dispchar
    jmp forever

endint:
    mov dx,oldip9
    mov ax,oldcs9
    mov ds,ax
    mov al,09h
    mov ah,25h
    int 21h

    ret
start endp

kbget proc near
    push bx
    cli
    mov bx,bufpt1
    cmp bx,bufpt2
    jnz kbget2
    cmp kbflag,0
    jnz kbget3
    sti
    pop bx
    jmp kbget

kbget2:
    mov al,[buffer+bx]
    inc bx
    cmp bx,16
    jc kbget3
    mov bx,0

kbget3:
    mov bufpt1,bx
    pop bx
    ret
kbget endp

kbint proc far
    push bx
    push ax

    in al,60h
    push ax
    in al,61h
    or al,80h
    out 61h,al
    and al,7fh
    out 61h,al

    pop ax
    test al,80h
    jnz kbint2
    mov bx,offset scantab
    xlat scantab
    cmp al,0
    jnz kbint4
    mov kbflag,80h
    jmp kbint2

kbint4:
    mov bx,bufpt2
    mov [buffer+bx],al
    inc bx
    cmp bx,16
    jc kbint3
    mov bx,0

kbint3:
    cmp bx,bufpt1
    jz kbint2
    mov bufpt2,bx

kbint2:
    cli
    mov al,20h
    out 20h,al
    pop ax
    pop bx
    sti
    iret
kbint endp

dispchar proc near
    push bx
    mov bx,0
    mov ah,0eh
    int 10h
    pop bx
    ret
dispchar endp

code ends
end start