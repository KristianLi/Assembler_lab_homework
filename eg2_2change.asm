datarea segment
    grade dw 88,75,95,63,98,78,87,73,90,60,'$'  ; 学生成绩的数组
    rank dw 10 dup(?),'$'  ; 用于存储排名的数组，初始值为10个未知值
    point dw 11 dup(?),'$'
datarea ends
;

prognam segment
;

main proc far
    assume cs:prognam,ds:datarea  ; 设置代码段和数据段的关联

start:
    push ds                ; 保存数据段的值
    sub ax,ax             ; 清零ax寄存器
    push ax                ; 将零值压入栈，作为段地址
    mov ax,datarea        ; 将数据段的地址加载到ax寄存器
    mov ds,ax             ; 设置ds寄存器为数据段的地址

    mov di,10             ; 设置循环次数为10，因为数组中有10个成绩
    mov bx,0              ; 初始化数组索引

lo:
    mov ax,grade[bx]      ; 将当前索引位置的成绩加载到ax寄存器
    mov dx,0              ; 清零dx寄存器，用于统计比当前成绩高的个数
    mov cx,10             ; 设置比较次数为10，因为数组中有10个成绩
    lea si,grade          ; 将成绩数组的地址加载到si寄存器

next:
    cmp ax,[si]           ; 比较当前成绩和数组中的其他成绩
    jg nocount             ; 如果当前成绩大于数组中的某个成绩，跳转到nocount
    inc dx                 ; 如果不大于，增加dx，表示当前成绩比较小
nocount:
    add si,2              ; 将si寄存器指向下一个成绩的位置
    loop next              ; 循环比较直到比较完所有成绩
    mov rank[bx],dx       ; 将比当前成绩小的个数存储到rank数组中
    add bx,2              ; 移动到rank数组的下一个位置
    dec di                 ; 减小循环次数
    jne lo                 ; 如果循环次数不为0，继续循环，否则结束循环
;以上是实验源码
;以下是增加部分，实现顺序输出功能
then:
    mov dx,1
    mov cx,10
    lea di,point

output:
    lea si,rank
    mov bx,0

process:   
    cmp dx,[si]
    jz  eque
    add si,2
    add bx,2
    jmp process
eque:
    mov ax,grade[bx]
    mov [di],ax

    add di,2
    add dx,1
    loop output

    lea si,point
    mov cx,10
display:
    mov ax,[si]
    mov bx,10
    xor dx,dx
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
    add si,2
    loop display

    
    ret                     ; 返回，结束过程
main endp

prognam ends
end start                  ; 程序结束
