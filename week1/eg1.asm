dataarea segment
    string1 db 'Move the cursor backward.'
    string2 db 'Move the cursor backward.'
    ;
    mess1 db 'Match.',13,10,'$'
    mess2 db 'No Match!',13,10,'$'
dataarea ends

prognam segment
main proc far
assume cs:prognam,ds:dataarea,es:dataarea
start:    
   push ds
   sub ax,ax
   push ax
   mov ax,dataarea
   mov ds,ax
   mov es,ax
   lea si,string1
   lea di,string2
   cld
   mov cx,25
   repz cmpsb
   jz match 
   lea dx,mess2
   jmp short disp
match:
   lea dx,mess1
disp:
   mov ah,09
   int 21h
   ret
main endp
prognam ends
   end start