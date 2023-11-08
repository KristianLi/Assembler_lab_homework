datasg segment para 'data'
    mess1 db 'Enter keyword: ',13,10,'$'   ; 提示用户输入stock number的信息
    mess2 db 'Enter Sentence: ',13,10,'$'
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
    Mess_2 db 'H of the sentence.',13,10,'$'
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
    int 21h              
    lea dx,stoknin       ;输入关键字
    mov ah,0ah            
    int 21h               
sentence:
    lea dx,mess2        ;同上，输入长句子
    mov ah,09
    int 21h
    lea dx,stoktstc
    mov ah,0ah
    int 21h
    cmp stokn2,'#'            ; 结束程序
    je exit               ; 如果为0，直接退出程序
    
    lea di,stokn2         ;di指向输入的长句子
    mov cx,0
recmp:
    lea si,stokn          ;si指向关键词
    mov dx,0
compare:
    mov ax,0              ;因为单位是字节，计数器用的寄存器地位，把高位置0以防cmp出错
    mov bx,0
    mov al,[si]
    mov bl,[di]
    add di,1
    add cx,1
    cmp cl,act2
    ja notmatch         ;如果cl-act2>0说明输入的长句子已经被比完了，cx已经大于其长度，所以不匹配
    cmp ax,bx
    jne recmp1           ;不匹配，跳转重来
    add si,1
    add dx,1            ;dx记录了匹配成功了几个字符，因为是字节操作，比较时用dl低位
    cmp dl,act          ;当dl和关键词长度相同代表匹配成功,跳转
    je ismatch
    jmp compare
recmp1:
    sub cx,dx           ;回退长句比过的部分
    sub di,dx           ;对应指针回退
    jmp recmp
ismatch:
    lea dx,Mess_1       ;输出：Match at location: 
    mov ah,09
    int 21h
    xor dx,dx
    sub cl,act
    add cl,1
    mov ax,cx          ;把位置转换成16进制数的ASCII码输出
    mov bx,16
    div bx
    add al,'0'
    add dl,'0'
    mov dh,dl
    mov dl,al
    cmp dl,'9'         ;如果小于等于'9'则直接输出就行，大了就要加7让他显示A～F
    jbe display1
    add dl,7
display1:
    mov ah,2
    int 21h
    mov dl,dh
    cmp dl,'9'
    jbe display2
    add dl,7
display2: 
    int 21h
    lea dx,Mess_2   ;输出：H of the sentence
    mov ah,09
    int 21h
    jmp sentence    ;跳转，继续比对新的输入长句
notmatch:
    lea dx,mess     ;输出： No match. 
    mov ah,09
    int 21h
    jmp sentence    ;跳转，继续比对新的输入长句

exit:
    ret                    ; 返回，结束程序
main endp
;
codesg ends
;
end main
