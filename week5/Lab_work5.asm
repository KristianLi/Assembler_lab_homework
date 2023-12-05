stack segment para stack 'stack'
    db 256 dup(0) ; 256 bytes of stack
stack ends

data segment para public 'data'
    buffer db 16h dup(0) ; 16 bytes of buffer
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
    oldcs09 dw ?
    oldip09 dw ?
data ends

code segment para public 'code'
start proc far 
    assume cs:code,ds:data
    push ds
    mov ax,0
    push ax
    mov ax,data
    mov ds,ax

    ; save old 09h interrupt
    cli
    mov ax,cs
    mov es,ax
    mov ax,0924h ; interrupt vector for 09h
    mov bx,0000h
    mov ds,ax
    mov ax,[bx]
    mov oldip09,ax
    mov ax,[bx+2]
    mov oldcs09,ax

    ; set new 09h interrupt
    mov dx,offset newint09
    mov ax,cs
    mov ds,ax
    mov ax,2509h
    int 21h

    ; enable keyboard interrupts
    in al,21h
    and al,0fdh
    out 21h,al
    sti

    ; display prompt
    mov dx,offset prompt
    mov ah,9
    int 21h

    ; main program loop
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
        ; restore old 09h interrupt
        mov dx,oldip09
        mov ax,oldcs09
        mov ds,ax
        mov ax,2509h
        int 21h

        ret
start endp

kbget proc near
    ; existing kbget code...
kbget endp

newint09 proc far
    pusha
    call original09h ; call the original 09h interrupt
    ; add custom keyboard handling code here
    popa
    iret
newint09 endp

original09h proc near
    pushf
    call far ptr [cs:oldcs09:oldip09]
    ret
original09h endp

; existing dispchar and other procedures...

code ends
end start
