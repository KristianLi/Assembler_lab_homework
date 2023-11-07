datasg segment para 'data'
    mess1 db 'Enter keyword: ',13,10,'$'   ; 提示用户输入stock number的信息
    mess2 db 'Enter Sentence: ',13,10,'$'
    stoknin label byte
        max dw 10   
        act dw ?    ; 用户输入的实际字符数
        stokn dw 10 dup(?)   ; 用户输入的stock number
    stoktstc label byte
        max2 dw 100
        act2 dw ?
        stokn2 dw 100 dup(?)
    descrn db 14 dup(20h),13,10,'$'     ; 存储描述信息的缓冲区，初始为14个空格，然后是回车换行符和'$'结束符
    mess db 'No match. ','$'        ; 当输入的stock number不在表格中时，显示的消息
    Mess_1 db 'Match at location: '
    Mess_2 db 'H of the sentence',13,10,'$'
datasg ends
;
codesg segment para 'code'
assume cs:codesg, ds:datasg, es:datasg
;
main proc far
     push ds
     sub ax,ax
     push ax
     mov ax,datasg 
     mov ds,ax
     mov es,ax
;
start:
    lea dx,mess1         ; 将mess1的地址加载到dx寄存器
    mov ah,09            ; 设置ah寄存器，表示要调用的功能是显示字符串
    int 21h               ; 调用21h中断，显示提示信息，等待用户输入
    lea dx,stoknin       ; 将stoknin的地址加载到dx寄存器
    mov ah,0ah           ; 设置ah寄存器，表示要调用的功能是输入字符串
    int 21h               ; 调用21h中断，等待用户输入
sentence:
    lea dx,mess2
    mov ah,09
    int 21h
    lea dx,stoktstc
    mov ah,0ah
    int 21h
    cmp act,0            ; 比较用户输入的字符数是否为0
    je exit               ; 如果为0，直接退出程序
    
    lea di,stoktstc
    add di,2
    mov cx,0
recmp:
    lea si,stoknin
    add si,2
    mov dx,0
compare:
    mov ax,0
    mov bx,0
    mov al,[si]
    mov bl,[di]
    add di,1
    cmp ax,bx
    jne recmp
    add si,1
    add dx,1
    add cx,1
    cmp dx,act
    je ismatch
    cmp cx,act2
    je notmatch
    jmp compare
ismatch:
    lea dx,Mess_1
    mov ah,09
    int 21h
    xor dx,dx
    mov ax,cx
    mov bx,10
    div bx
    add al,'0'
    add dl,'0'
    mov dh,dl
    mov dl,al
    mov ah,2
    int 21h
    mov dl,dh
    int 21h
    mov dl,10
    int 21h
    lea dx,Mess_2
    mov ah,09
    int 21h
    jmp sentence
notmatch:
    lea dx,mess
    mov ah,09
    int 21h
    jmp sentence

exit:
    ret                    ; 返回，结束程序
main endp
;
codesg ends
;
end main
