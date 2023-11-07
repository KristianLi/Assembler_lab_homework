datasg segment para 'data'
    mess1 db 'Enter keyword: ','$'   ; 提示用户输入stock number的信息
    mess2 db 'Enter Sentence: ','$'
    stoknin label byte
        max db 10   
        act db ?    ; 用户输入的实际字符数
        stokn db 10 dup(?)   ; 用户输入的stock number
    stoktstc label byte
        max2 db 100
        act2 db ?
        stokn2 db 100 dup(?)
    descrn db 14 dup(20h),13,10,'$'     ; 存储描述信息的缓冲区，初始为14个空格，然后是回车换行符和'$'结束符
    mess db 'No match. ','$'        ; 当输入的stock number不在表格中时，显示的消息
    Mess_1 db 'Match at location: ','$'
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
    cmp act,0            ; 比较用户输入的字符数是否为0
    je exit               ; 如果为0，直接退出程序
    lea si,stokn
    lea dx,mess2
    mov ah,09
    int 21h
    lea dx,stoktstc
    mov ah,0ah
    int 21h
    mov cl,act
    sub cl,act2
    add cl,1
    lea di,stoktstc
recmp:
    lea si,stoknin
    mov dl,0
compare:
    mov ax,[si]
    mov bx,[di]
    cmp ax,bx
    jne recmp
    add si,1
    add di,1
    add dl,1
    cmp dl,act
    je ismatch
    cmp
    
    loop compare
ismatch:
    
notmatch:

exit:
    ret                    ; 返回，结束程序
main endp
;
codesg ends
;
end main
