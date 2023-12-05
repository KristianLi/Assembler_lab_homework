; 定义堆栈段
stack segment para stack 'stack'
    db 256 dup(0) ; 256 字节的堆栈空间
stack ends

; 定义数据段
data segment para public 'data'
    buffer db 16h dup(0) ; 16 字节的缓冲区
    bufpt1 dw 0
    bufpt2 dw 0
    kbflag db 0
    prompt db '--- kbd_io program begin ---',0dh,0ah,'$' ; 提示信息字符串
    scantab db 0,0,'1234567890-=',8,0 ; 扫描表
            db 'qwertyuiop[]',0dh,0 ; 键盘布局
            db 'asdfghjkl;',0,0,0,0
            db 'zxcvbnm,./',0,0,0
            db ' ',0,0,0,0,0,0,0,0,0,0,0,0,0 ; 空白字符
            db '789-456+1230.' ; 键盘布局
    even
    oldcs9 dw ?
    oldip9 dw ?
data ends

; 定义代码段
code segment para public 'code'
start proc far 
    assume cs:code,ds:data
    push ds
    mov ax,0
    push ax
    mov ax,data
    mov ds,ax

    cli ; 禁止中断
    mov al,09 ; 设置键盘中断向量号
    mov ah,35h
    int 21h
    mov oldcs9,es ; 保存旧的代码段地址
    mov oldip9,bx ; 保存旧的指令指针地址

    push ds
    mov dx,offset kbint
    mov ax,seg kbint
    mov ds,ax
    mov al,09 ; 设置新的键盘中断
    mov ah,25h
    int 21h
    pop ds

    in al,21h ; 读取 8259A 端口 1 的内容到 al
    and al,0fdh ; 复位键盘中断允许位
    out 21h,al ; 将更新后的值写回 8259A 端口 1

    mov dx,offset prompt ; 设置提示信息字符串的偏移地址
    mov ah,9
    int 21h ; 显示提示信息
    sti ; 允许中断

forever:
    call kbget ; 调用键盘获取函数
    test kbflag,80h ; 检查键盘标志位
    jnz endint ; 如果按下了键盘的 "Ctrl" 键，则结束程序
    push ax
    call dispchar ; 调用字符显示函数
    pop ax
    cmp al,0dh ; 检查是否输入了回车键
    jnz forever ; 如果不是回车键，则继续循环
    mov al,0ah
    call dispchar ; 显示换行符
    jmp forever ; 继续循环

endint:
    mov dx,oldip9 ; 恢复旧的指令指针地址
    mov ax,oldcs9 ; 恢复旧的代码段地址
    mov ds,ax
    mov al,09h
    mov ah,25h
    int 21h ; 恢复旧的键盘中断
    ret

start endp

; 键盘获取函数
kbget proc near
    push bx
    cli ; 禁止中断
    mov bx,bufpt1 ; 获取缓冲区指针 bufpt1
    cmp bx,bufpt2 ; 检查是否有新的输入
    jnz kbget2 ; 如果有新的输入，则跳转到 kbget2
    cmp kbflag,0 ; 检查键盘标志位
    jnz kbget3 ; 如果键盘标志位被设置，则跳转到 kbget3
    sti ; 允许中断
    pop bx
    jmp kbget ; 继续获取输入

kbget2:
    mov al,[buffer+bx] ; 从缓冲区中读取字符到 al
    inc bx ; 缓冲区指针加一
    cmp bx,16 ; 检查是否超出缓冲区范围
    jc kbget3 ; 如果没有超出，则跳转到 kbget3
    mov bx,0 ; 缓冲区指针清零

kbget3:
    mov bufpt1,bx ; 更新缓冲区指针 bufpt1
    pop bx
    ret

kbget endp

; 键盘中断处理函数
kbint proc far
    push bx
    push ax

    in al,60h ; 读取键盘扫描码
    push ax
    in al,61h ; 读取键盘控制端口
    or al,80h ; 设置第 7 位为 1
    out 61h,al ; 将修改后的值写回键盘控制端口
    and al,7fh ; 设置第 7 位为 0
    out 61h,al ; 将修改后的值写回键盘控制端口

    pop ax
    test al,80h ; 检查键盘状态
    jnz kbint2 ; 如果按下了键盘的 "Break" 键，则跳转到 kbint2
    mov bx,offset scantab ; 设置扫描表的偏移地址
    xlat scantab ; 转换键盘扫描码为 ASCII 码
    cmp al,0 ; 检查是否按下了键盘的 "Ctrl" 键
    jnz kbint4 ; 如果没有按下 "Ctrl" 键，则跳转到 kbint4
    mov kbflag,80h ; 设置键盘标志位为按下 "Ctrl" 键
    jmp kbint2 ; 跳转到 kbint2

kbint4:
    mov bx,bufpt2 ; 获取缓冲区指针 bufpt2
    mov [buffer+bx],al ; 将键盘输入存入缓冲区
    inc bx ; 缓冲区指针加一
    cmp bx,16 ; 检查是否超出缓冲区范围
    jc kbint3 ; 如果没有超出，则跳转到 kbint3
    mov bx,0 ; 缓冲区指针清零

kbint3:
    cmp bx,bufpt1 ; 检查是否和 bufpt1 相等
    jz kbint2 ; 如果相等，则跳转到 kbint2
    mov bufpt2,bx ; 更新缓冲区指针 bufpt2

kbint2:
    cli ; 禁止中断
    mov al,20h ; 发送结束中断信号
    out 20h,al ; 发送到 8259A 端口 1
    pop ax
    pop bx
    sti ; 允许中断
    iret ; 中断返回

kbint endp

; 字符显示函数
dispchar proc near
    push bx
    mov bx,0
    mov ah,0eh
    int 10h ; 使用BIOS中断显示字符
    pop bx
    ret
dispchar endp

code ends
end start
