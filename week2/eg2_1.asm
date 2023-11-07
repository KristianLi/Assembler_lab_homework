datasg segment para 'data'
mess1 db 'stock number?',13,10,'$'   ; 提示用户输入stock number的信息
;
stoknin label byte
    max db 3    ; 最大输入字符数为3
    act db ?    ; 用户输入的实际字符数
    stokn db 3 dup(?)   ; 用户输入的stock number
;
stoktab db '05','Excavators  '        ; 预定义的stock number和对应的描述信息
        db '08','Lifters     '
        db '09','Presses     '
        db '12','Vakves      '
        db '23','Processors  '
        db '27','Pumps       '
;
descrn db 14 dup(20h),13,10,'$'     ; 存储描述信息的缓冲区，初始为14个空格，然后是回车换行符和'$'结束符
mess db 'Not in table! ','$'        ; 当输入的stock number不在表格中时，显示的消息
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
    mov al,stokn         ; 将用户输入的stock number的第一个字符加载到al寄存器
    mov ah,stokn+1       ; 将用户输入的stock number的第二个字符加载到ah寄存器
    mov cx,06            ; 设置循环次数为6，因为表格中有6个预定义的stock number
    lea si,stoktab       ; 将stoktab的地址加载到si寄存器，用于循环比较
a20:
    cmp ax, word ptr[si] ; 比较用户输入的stock number和表格中的stock number是否相等
    je a30                ; 如果相等，跳转到标号a30
    add si,14            ; 如果不相等，将si寄存器指向下一个stock number的位置
    loop a20              ; 循环比较直到找到相等的stock number或者比较完所有的stock number
    lea dx,mess          ; 将mess的地址加载到dx寄存器
    mov ah,09            ; 设置ah寄存器，表示要调用的功能是显示字符串
    int 21h               ; 调用21h中断，显示"Not in table!"消息
    jmp exit              ; 跳转到标号exit，退出程序
a30:
    mov cx,07            ; 设置循环次数为7，因为描述信息的长度为7个字节
    lea di,descrn        ; 将descrn的地址加载到di寄存器，用于存储描述信息
    rep movsw             ; 将找到的描述信息从stoktab复制到descrn中
    lea dx,descrn        ; 将descrn的地址加载到dx寄存器
    mov ah,09            ; 设置ah寄存器，表示要调用的功能是显示字符串
    int 21h               ; 调用21h中断，显示找到的描述信息
    jmp start             ; 跳转到标号start，继续执行下一次查询
exit:
    ret                    ; 返回，结束程序
main endp
;
codesg ends
;
end main
