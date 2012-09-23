newfile:			;Write file using bFS	IN - si, file name, ax, file length
	pusha
	mov di,root
	call addtodir
	popa
	
	mov cx,ax
	mov di,si
.space
	call maloc
.size
	mov [.start],bx
	mov [.end],ax
	mov si,bx
	add si,1
	mov [si],cx
.name
	xchg si,di
	add di,1
	call copystring
.pad
	mov ax,si
	call length
	add di,ax
	mov bx,[.end]
	sub bx,2
.loop
	cmp di,bx
	jge .done
	add di,1
	mov byte [di],0
	jmp .loop
.done
ret
	.start db 0,0
	.end db 0,0

newdir:			;si, dir name
	push si
	mov ax,11
	call newfile
	pop si
	mov di,si
	call findfile
	add ax,10
	mov si,ax
	mov byte[si],'f'
ret

addtodir:			;Add file to directory DI, dir, SI, file
	push si
	call findfile
	cmp ax,0
	je .err
	add bx,1
	push bx

	mov si,bx
	add bx,10
	mov di,bx
	mov ax,256
	call shiftmem
	
	pop bx	
	pop si
	mov di,bx
	push si
	call copystring
	
	pop si
	mov ax,si
	call length
	push ax
	
	mov di,root
	call findfile
	add ax,1
	mov si,ax
	pop ax	
	add ax,1
	add [si],ax
	jmp .done
.err
	pop si
	mov ax,'nf'
.done
ret

killfile:
	call findfile
	cmp ax,0
	je .err
	mov si,bx
	mov di,ax
	add si,1
	mov ax,512
	call shiftmem
	jmp .done
.err
	mov ax,'nf'
.done
ret

filelist:
	mov si,void + 20
	mov dx,si
	add dx,1024
.loop
	cmp byte [si],'*'
	je .found
	add si,1
	cmp si,dx
	je .done
	jmp .loop
.found
	add si,2
	cmp byte [si],'*'
	je .loop
	cmp byte [si],'0'
	je .done
	call print
	call printret
	jmp .loop
.done
ret

findfile:					;Find file and give location
	mov si,void + 20
	mov bx,0
.loop
	cmp byte [si],'*'
	je .file
	cmp byte [si],'0'
	je .err
	add si,1
	jmp .loop
.file
	mov dx,si
	add si,2
	call compare
	jc .found
	jmp .loop
.found
	sub si,2
	mov si,dx
	mov ax,si
	add si,1
	mov bx,0
	mov bl,[si]
	add bx,ax
	jmp .done
.err
	mov ax,0
.done	
ret

copyfile:			;Copy file IN, di,name source, si,name destination
	push di
	mov di,.dname
	call copystring
	pop si
	mov di,.sname
	call copystring
	
	mov di,.sname
	call findfile
	sub bx,ax
	xchg ax,bx
	mov si,.dname
	call newfile
	mov di,.dname
	call findfile
	push ax
	push bx

	mov di,.sname
	call findfile
	mov dx,bx
	mov cx,ax
	pop bx
	pop ax
	mov si,cx
	mov di,ax
	add si,10
	add di,10
	add dx,1
.copyloop
	mov ax,[si]
	mov [di],ax
	add si,1
	add di,1
	cmp si,dx
	jge .done
	jmp .copyloop
.done
ret
	.sname times 8 db 0
	.dname times 8 db 0

cleartmp:				;Destroy all files called tmp
.loop
	mov di,.tmp
	call killfile
	cmp ax,'nf'
	je .done
	jmp .loop
.done
ret
	.tmp db 'tmp',0