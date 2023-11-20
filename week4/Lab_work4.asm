datasg segment 
    mess1 db 'Input name: ',13,10,'$'   ; 提示用户输入stock number的信息
    mess2 db 'Input a telephone number: ',13,10,'$'
    mess3 db 'Do you want a telephone number?(Y/N)',13,10,'$'

    name_data label byte
        max db 20
        act db ?
        input db 20 dup(?)
    phone_data label byte
        max2 db 8
        act2 db ?
        input2 db 8 dup(?)

    name_sort_data db 1000 dup(?),'$'
    phone_sort_data db 400 dup(?),'$'
datasg ends
codesg segment
    assume cs:codesg,ds:datasg,es:datasg
main proc far
start:
    push ds
    sub ax,ax
    push ax
    mov ax,datasg
    mov ds,ax
    mov es,ax
                            ;八股文结束
    mov ah,9h               ;显示提示信息
    mov dx,offset mess1
    int 21h


    call input_name         ;输入name
    call name_sort
    mov ah,9h
    mov dx,offset mess2
    int 21h
    call inphone            ;输入phone
    call phone_sort
    mov ah,9h
    mov dx,offset mess3
    int 21h
    mov ah,1h
    int 21h
    cmp al,'Y'
    je  yes
    jne no
yes:
    call stor_name          ;存储name
    call inphone            ;输入phone
    call name_sort          ;按name排序
    call phone_sort         ;按phone排序
    call printline          ;输出结果
no:
    pop ax
    pop ds
    mov ah,4ch              ; 退出程序
    int 21h


    ret                    ; 返回，结束程序
main endp

;

input_name proc near      ; 输入name
    push ax
    push bx
    push cx
    push dx

    mov ah,0ah
    lea dx,name_data
    int 21h

    pop dx
    pop cx
    pop bx
    pop ax
    
    ret
input_name endp

stor_name proc
    ret
stor_name endp

inphone proc
    push ax
    push bx
    push cx
    push dx

    mov ah,0ah
    lea dx,phone_data
    int 21h

    pop dx
    pop cx
    pop bx
    pop ax
    ret
inphone endp

name_sort proc
    push ax
    push bx
    push cx
    push dx 

    mov ax,offset name_data
    mov bx,offset name_sort_data
    mov cx,word ptr [ax+1]
    mov dx,word ptr [bx+1]
    mov si,2
    mov di,2
    mov cl,byte ptr [ax+1]
    mov dl,byte ptr [bx+1]
    cmp cl,dl
    jae name_sort1
    

    pop dx
    pop cx
    pop bx
    pop ax
    ret
name_sort endp

phone_sort proc
    ret
phone_sort endp

printline proc
    ret
printline endp

codesg ends
end start