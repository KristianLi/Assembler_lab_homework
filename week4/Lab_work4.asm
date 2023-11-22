datasg segment 
    mess1 db 'Input name: ',13,10,'$'   ; 提示用户输入stock number的信息
    mess2 db 'Input a telephone number: ',13,10,'$'
    mess3 db 'Do you want a telephone number?(Y/N)',13,10,'$'
    mess4 db 'Name?',13,10,'$'
    mess5 db 'not exit!',13,10,'$'
    mess6 db 'name                     phone number',13,10,'$'

    name_data label byte
        max db 21
        act db ?
        input db 21 dup('$')
    phone_data label byte
        max2 db 9
        act2 db ?
        input2 db 9 dup('$')

    name_sort_data db 1050 dup('$')
    phone_sort_data db 450 dup('$')

    p1 db 0     ;name_sort_data的偏移量
    p2 db 0     ;phone_sort_data的偏移量
    p_name_front db 0       ;name_sort_data的前指针
    p_name_back db 0        ;name_sort_data的后指针
    p_phone_front db 0      ;phone_sort_data的前指针
    p_phone_back db 0       ;phone_sort_data的后指针
    p_cmpend db 0           ;name_sort_data的末尾指针
    p_check_name db 0       ;name_sort_data的检查指针
    p_check_phone db 0      ;phone_sort_data的检查指针
    yes_no db 0             ;是否查找phone number

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
input_cycle:
    mov ah,9h               
    mov dx,offset mess1     ;Input name
    int 21h


    call input_name         ;输入name
    cmp act,0
    je  input_end           ;如果输入为空，跳转到input_end
    call stor_name          ;存储name
    mov ah,9h
    mov dx,offset mess2     ;Input a telephone number
    int 21h
    call inphone            ;输入phone
    jmp input_cycle

input_end:
    call name_sort          ;按name排序
check:
    mov ah,9h
    mov dx,offset mess3     ;询问是否查名字
    int 21h
    mov ah,1
    int 21h
    cmp al,'Y'
    je  yes
    jne no
yes:
    mov ah,02
    mov dl,10
    int 21h                 ;换行
    mov ah,9h
    mov dx,offset mess4     ;Name?
    int 21h
    call input_name         ;输入name
    mov ah,9h
    mov dx,offset mess6     ;name phone
    int 21h
    mov cl,act
    mov ch,0
    lea si,input
print_name:
    mov ah,2
    mov dl,[si]
    int 21h
    inc si
    loop print_name
    mov cx,19
print_space:
    mov dl,' '
    int 21h
    loop print_space
    call name_search        ;查找name
    jmp check
no:
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
    push ax
    push bx
    push cx
    push dx

    mov cx,0
    mov cl,act
    lea di,name_sort_data
    mov ax,0
    mov al,p1
    add di,ax
    lea si,input

loop1:
    mov al,[si]
    mov [di],al
    inc di
    inc si
    loop loop1

    add p1,21
    add p_cmpend,21

    pop dx
    pop cx
    pop bx
    pop ax
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
    mov cx,0
    mov cl,act2
    lea di,phone_sort_data
    mov ax,0
    mov al,p2
    add di,ax
    lea si,input2

loop2:
    mov al,[si]
    mov [di],al
    inc di
    inc si
    loop loop2

    add p2,9

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

    mov ax,0
    mov al,p1
    mov p_cmpend,al
stringcmp_out:
    mov cx,21
    mov p_name_front,0
    mov p_name_back,21
    mov p_phone_front,0
    mov p_phone_back,9

stringcmp:
    lea si,name_sort_data
    mov al,p_name_front
    add si,ax
    lea di,name_sort_data
    mov al,p_name_back
    add di,ax
cmp1:
    mov al,[si]
    mov bl,[di]
    cmp bl,'$'
    je sort_end
    cmp al,bl
    jg swap
    inc si
    inc di
    loop cmp1
    jmp next
swap:
    lea si,name_sort_data
    mov al,p_name_front
    add si,ax
    lea di,name_sort_data
    mov al,p_name_back
    add di,ax
swap_name:
    mov al,[si]
    mov bl,[di]
    mov [si],bl
    mov [di],al
    inc si
    inc di
    loop swap_name

    mov cx,9
    lea si,phone_sort_data
    lea di,phone_sort_data
    mov al,p_phone_front
    add si,ax
    mov al,p_phone_back
    add di,ax
swap_phone:
    mov al,[si]
    mov bl,[di]
    mov [si],bl
    mov [di],al
    inc si
    inc di
    loop swap_phone 

next:
    add p_name_front,21
    add p_name_back,21
    add p_phone_front,9
    add p_phone_back,9
    mov cx,21
    lea si,p_name_back
    lea di,p_cmpend
    mov ax,[si]
    mov bx,[di]
    cmp ax,bx
    jng stringcmp       ;如果p_name_back<p_cmpend,继续比较
    sub p_cmpend,21     ;否则p_cmpend-21
    cmp p_cmpend,0      ;如果p_cmpend=0,说明已经比较完毕
    jne stringcmp_out       ;否则继续比较

sort_end:
    pop dx
    pop cx
    pop bx
    pop ax
    ret
name_sort endp

name_search proc
    push ax
    push bx
    push cx
    push dx

    mov cx,0
    mov ax,0
    mov cl,act
    mov p_check_name,0
    mov p_check_phone,0
    lea si,name_sort_data
    lea di,input
    mov al,p_check_name
    add si,ax
cmp_for_search:
    mov al,[si]
    cmp al,'$'
    je not_exit
    mov bl,[di]
    cmp al,bl
    jne next1
    inc si
    inc di
    loop cmp_for_search
    call printline
    jmp search_end
next1:
    add p_check_name,21
    add p_check_phone,9
    mov cl,act
    lea si,name_sort_data
    lea di,input
    mov al,p_check_name
    add si,ax
    mov bl,p1
    cmp al,bl
    jng cmp_for_search   ;如果p_check_name<p1,继续比较
    mov ax,09h
    mov dx,offset mess5 ;否则输出not exit
    int 21h
not_exit:
    mov ah,09h
    mov dx,offset mess5
    int 21h

search_end:
    pop dx
    pop cx
    pop bx
    pop ax
    ret
name_search endp

printline proc
    push ax
    push bx
    push cx
    push dx

    lea si,phone_sort_data
    mov ax,0
    mov al,p_check_phone
    add si,ax
print:
    mov al,[si]
    cmp al,'$'
    je printline_end
    mov ah,2
    mov dl,al
    int 21h
    inc si
    jmp print
    
printline_end:
    mov ah,2
    mov dl,10
    int 21h
    pop dx
    pop cx
    pop bx
    pop ax
    ret
printline endp

codesg ends
end start