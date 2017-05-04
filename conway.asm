%define	ALIVE	1
%define DEAD	0

%define CHAR_DEAD	'.'
%define CHAR_ALIVE	'#'

%define GRID_MODIFIER	10
%define GRID_TOTAL		(GRID_MODIFIER*GRID_MODIFIER)
%define CYCLE_LIMIT 10
%define SLEEP 1

%define GRID	grid_glider_10

%define lvar1	DWORD[ebp-4]
%define lvar2	DWORD[ebp-8]
%define lvar3	DWORD[ebp-12]

%define arg1	DWORD[ebp+8]
%define arg2	DWORD[ebp+12]
%define arg3	DWORD[ebp+16]
%define arg4    DWORD[ebp+20]
%define row		arg1
%define	col		arg2

segment .data
	; GLOBAL VARIABLES
	iteration: dd 0 ; could initialize in .bss but I'd rather have it here for segregation
	; printf
	NLCR:	db  0x0A,0x0D,0
	header:	db	"NASM Game of Life", \
				0x0A,0x0D,"Written by Andrew Jorgenson", \
				0x0A,0x0D,"Current Iteration: %d",0x0A,0x0D,0
	; System
	sys_clear:		db	"clear",0
	sys_initialize:	db	"stty raw -echo",0
	sys_terminate:	db	"stty -raw echo",0
	; GRID TEMPLATES
	grid_test_10:	db \
                    0,0,0,1,0,0,0,0,0,0, \
					1,1,0,0,0,0,0,0,1,1, \
					1,1,0,0,0,0,0,0,1,1, \
					0,0,0,0,0,0,0,0,0,0, \
					1,1,0,0,0,1,0,0,0,0, \
					1,1,0,0,0,0,0,0,0,0, \
					1,1,0,0,0,0,0,0,0,0, \
					0,0,0,0,0,0,0,0,0,0, \
					1,1,0,0,0,0,0,0,1,1, \
					1,1,0,0,0,0,0,0,1,1
    
    grid_glider_10:	db \
                    0,0,0,0,0,0,0,0,0,0, \
					0,0,0,0,0,0,0,0,0,0, \
					0,0,0,0,0,0,0,0,0,0, \
					0,0,0,0,1,0,0,0,0,0, \
					0,0,0,0,0,1,0,0,0,0, \
					0,0,0,1,1,1,0,0,0,0, \
					0,0,0,0,0,0,0,0,0,0, \
					0,0,0,0,0,0,0,0,0,0, \
					0,0,0,0,0,0,0,0,0,0, \
					0,0,0,0,0,0,0,0,0,0

	grid_full_10:	db \
                    1,1,1,1,1,1,1,1,1,1, \
					1,1,1,1,1,1,1,1,1,1, \
					1,1,1,1,1,1,1,1,1,1, \
					1,1,1,1,1,1,1,1,1,1, \
					1,1,1,1,1,1,1,1,1,1, \
					1,1,1,1,1,1,1,1,1,1, \
					1,1,1,1,1,1,1,1,1,1, \
					1,1,1,1,1,1,1,1,1,1, \
					1,1,1,1,1,1,1,1,1,1, \
					1,1,1,1,1,1,1,1,1,1
					
	grid_spicy_24:	db \
                    0, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 0, 0, 1, 1, 1, 0, 1, 0, 0, 0, 1, 0, 0, \
					0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, \
					0, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, \
					0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, \
					0, 1, 1, 1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 1, 1, 0, 0, 0, 1, 0, 0, 0, 0, \
					0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, \
					0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, \
					0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, \
					0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, \
					0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, \
					0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, \
					0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, \
					0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, \
					0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, \
					0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, \
					0, 0, 0, 1, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, \
					0, 0, 1, 1, 1, 1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, \
					0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, \
					0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, \
					0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, \
					0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, \
					0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, \
					0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, \
					0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

segment .bss
    grid_buffer: resb GRID_TOTAL
segment .text
	global  asm_main
	extern printf
	extern system
	extern putchar
    extern sleep
asm_main:
	enter	0,0
	pusha
	;***************CODE STARTS HERE***************************
	push sys_initialize
	call system
	add esp, 4

	call game_loop

	push sys_terminate
	call system
	add esp, 4

	call newline
	
	;***************CODE ENDS HERE*****************************
	popa
	mov	eax, 0
	leave
	ret

game_loop:
    enter 0,0
    gl_s:
    cmp DWORD[iteration], CYCLE_LIMIT
    jg gl_e
    call render
    call update
    push SLEEP ; 2 seconds
    call sleep
    add esp, 4
    inc DWORD[iteration]
    call gl_s
    gl_e:
    leave
    ret

update:
	enter 12,0
	mov lvar1, 0 ; r
    mov lvar2, 0 ; c
    mov lvar3, 0 ; neighbors buffer
	loopR_s: ; for(r=0; r < R; r++)
    cmp lvar1, GRID_MODIFIER
    jg loopR_e

        loopC_s: ; for(c=0; c < C; c++)
        cmp lvar2, GRID_MODIFIER
        jg loopC_e
        
        push lvar2
        push lvar1
        call neighbors
        add esp, 8
        mov lvar3, eax

        push lvar2
        push lvar1
        call coordVal
        add esp, 8

        cmp eax, DEAD
        je DEAD_S 

        LIVE_S:
            ; LIVE CELL CONDITIONS
            ; Any live cell with fewer than two live neighbours dies, as if caused by under-population.
            ; if(count < 2)
            cmp eax, 2
            jge con1
            push DEAD ; newar[r][c] = 0;
            push lvar2
            push lvar1 
            call setBufCoord
            add esp, 12
            con1:
            ; Any live cell with two or three live neighbours lives on to the next generation.
            ; count == 2 || count == 3
            cmp lvar3, 2
            je con2_met
            cmp lvar3, 3
            je con2_met
            jmp con2 
            con2_met:
            push ALIVE
            push lvar2
            push lvar1
            call setBufCoord
            add esp, 12
            con2:

            ; Any live cell with more than three live neighbours dies, as if by over-population.
            ; if(count > 3)
            cmp lvar3, 3
            jle con3
            push DEAD ; newar[r][c] = 0;
            push lvar2
            push lvar1 
            call setBufCoord
            add esp, 12
            con3:
            jmp loopC_epi
        LIVE_E:
        DEAD_S:
            ; Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction. 
            ; if(count == 3) newarr[r][c] = 1
            cmp lvar3, 3
            je dead_a
            jmp dead_d
            dead_a:
            mov eax, ALIVE
            jmp dead_epi 
            dead_d:
            mov eax, DEAD
            jmp dead_epi
            dead_epi:
            push eax
            push lvar2
            push lvar1
            call setBufCoord
            add esp, 12
            jmp loopC_epi
        DEAD_E:

        loopC_epi:
        inc lvar2
        jmp loopC_s
        loopC_e:

    mov lvar2, 0 ; reset column counter
    inc lvar1
    jmp loopR_s
    loopR_e:
	
    ; Finally, let's copy the buffer to the official array
    mov lvar1, 0
    gc_s:
    cmp lvar1, GRID_TOTAL
    jg gc_e
    mov eax, lvar1
    mov dl, BYTE[grid_buffer + eax]
    mov BYTE[GRID + eax], dl

    inc lvar1
    jmp gc_s
    gc_e:

	leave
	ret
	
render:
	enter 0,0
	call newline
	push sys_clear
	call system
	add esp, 4
	
	push DWORD[iteration]
	push header
	call printf
	add esp, 8
	
	call printGrid
	
	leave
	ret

neighbors:
	enter 4,0
	;*******************************************************
	; arg1: row
	; arg2: column
	;
	; lvar1: count
	;*******************************************************
	mov lvar1, 0
	cmp row, 0 ; r > 0 && c > 0
	je neighbors_epi
	cmp col, 0
	je neighbors_epi
	
	top_left: ; grid[r-1][c-1] == 1
		mov eax, row
		mov ebx, col
		dec eax
		dec ebx
		push ebx
		push eax
		call coordVal
		add esp, 8
		
		cmp eax, 1
		jne top_middle
		inc lvar1
		
	top_middle: ; grid[r-1][c] == 1
		mov eax, row
		mov ebx, col
		dec eax
		push ebx
		push eax
		call coordVal
		add esp, 8
		
		cmp eax, 1
		jne top_right
		inc lvar1
	top_right: ; grid[r-1][c+1] == 1
		mov eax, row
		mov ebx, col
		dec eax
		inc ebx
		push ebx
		push eax
		call coordVal
		add esp, 8
		
		cmp eax, 1
		jne middle_left
		inc lvar1
	middle_left: ; grid[r][c-1] == 1
		mov eax, row
		mov ebx, col
		dec ebx
		push ebx
		push eax
		call coordVal
		add esp, 8
		
		cmp eax, 1
		jne middle_right
		inc lvar1
	middle_right: ; grid[r][c+1] == 1
		mov eax, row
		mov ebx, col
		inc ebx
		push ebx
		push eax
		call coordVal
		add esp, 8
		
		cmp eax, 1
		jne end0
		inc lvar1
		
	end0:
	cmp row, GRID_MODIFIER-1 ; r < R-1
	jge bottom_right
	
	bottom_left: ; grid[r+1][c-1] == 1
		mov eax, row
		mov ebx, col
		inc eax
		dec ebx
		push ebx
		push eax
		call coordVal
		add esp, 8
		
		cmp eax, 1
		jne bottom_middle
		inc lvar1
	bottom_middle: ; grid[r+1][c] == 1
		mov eax, row
		mov ebx, col
		inc eax
		push ebx
		push eax
		call coordVal
		add esp, 8
		
		cmp eax, 1
		jne bottom_right
		inc lvar1
	bottom_right: ; c < C-1 && grid[r+1][c+1] == 1
		; c < C-1
		cmp col, GRID_MODIFIER-1
		jge neighbors_epi
		
		; grid[r+1][c+1] == 1
		mov eax, row
		mov ebx, col
		inc eax
		inc ebx
		push ebx
		push eax
		call coordVal
		add esp, 8
		
		cmp eax, 1
		jne neighbors_epi
		inc lvar1
		
		
	neighbors_epi:
	
	
	mov eax, lvar1
	leave
	ret

setBufCoord:
    enter 0,0
	;*******************************************************
	; arg1: row
	; arg2: column
    ; arg3: value
	;*******************************************************
	push col
	push row
	call coordConv
	add esp, 8
    
    ;mov ebx, arg3
    ;xor ecx, ecx
    xor ecx, ecx
    mov ecx, arg3
    ;mov cl, bl
    
    mov BYTE[grid_buffer + eax], cl

    leave
    ret

setCoord:
    enter 0,0
	;*******************************************************
	; arg1: row
	; arg2: column
    ; arg3: value
	;*******************************************************
	; push col
	; push row
	; call coordConv
	; add esp, 8
    
    mov ebx, arg3
    xor ecx, ecx
    mov cl, bl
    
    mov BYTE[GRID + eax], cl

    leave
    ret

coordVal:
	enter 0,0
	;*******************************************************
	; arg1: row
	; arg2: column
	;*******************************************************
	push col
	push row
	call coordConv
	add esp, 8
	mov ebx, eax
	xor eax, eax
	mov al, BYTE[GRID + ebx]
	
	leave
	ret
	
coordConv:
	enter 0,0
	;*******************************************************
	; arg1: row
	; arg2: column
	;*******************************************************
	;xor eax,eax
	; EAX = (R*MODIFIER) + COLUMN
	xor eax,eax
	xor ebx,ebx
	mov eax, row
	mov ebx, GRID_MODIFIER
	mul ebx
	add eax, col
	
	leave
	ret

printGrid:
	enter 12,0
	;*******************************************************
	; lvar1: loop counter
	; lvar2: column reset counter, resets by grid modifier
	; lvar3: used as a buffer
	;*******************************************************
	
	mov lvar1, 0
	mov lvar2, 0
	mov ecx, GRID_TOTAL
	pg_s:
	mov eax, lvar1
	mov lvar3, ecx
	;mov ebx, lvar2 
	cmp lvar2, GRID_MODIFIER
	jl pg_noreset
	mov lvar2, 0 ; Reset counter and print a newline
	
	call newline
	
	pg_noreset:
	mov eax, lvar1
	
	cmp BYTE[GRID + eax], 0
	jz dead
	
	push CHAR_ALIVE
	jmp pg_epi
	
	dead:
	push CHAR_DEAD
	
	pg_epi:
	
	call putchar
	add esp, 4
	push 0x20 ; ' '
	call putchar
	add esp, 4
	
	mov ecx, lvar3
	inc lvar1
	inc lvar2
	loop pg_s
	
	call newline
	
	leave
	ret

newline:
	enter 0,0
	
	push NLCR
	call printf
	add esp, 4
	
	leave
	ret

	
