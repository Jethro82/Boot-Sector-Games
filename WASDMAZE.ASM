Org 7C00h
Start:
xor ax,ax
mov ss,ax
mov ds,ax ;set SS, DS to zero
mov Ax,0B800h
mov es,Ax ;set es to screen output
mov sp,ax ;start stack pointer with away from code



StartMazeWrite:
mov ah,0
int 1ah
mov [7902],dx ;set initial timer
mov dh,7Ch ;point to boot code as random data
mov [7900],dx ;save random pointer

mov ax,3
int 10h ;cls for text mode

mov ax,1112h
int 10h ;set text mode to 50x80

mov ax,0900h+219
mov bx,4 ;set colour to red
mov cx,3600
int 10h ;write out solid blocks as maze

mov bp,322 ;set pointer to first cell in maze

FreeGrid:
	mov bl,32 ;set left to right length as 32 cells
	FG2:
		mov byte [es:bp],' ' ;clear grid pattern for both x,y as odd numbered cell
		call random3bits
		cmp dl,1
		jg checkdown
			mov byte [es:bp+2],' ' ;one in eight chance of deleted next right space in grid
		checkdown:
		call random3bits
		cmp dl,1
		jg Advancegrid
			mov byte [es:bp+160],' ';one in eight chance of deleting next down space in grid
		advancegrid:
		add bp,4 ;advance grid two cells forward
		dec bx ;count down from 32
	jnz FG2
	add bp,192 ;advance bp to first cell on next row down
	cmp bp,7000 ;check to see if 18 up down cells have been reached
jl FreeGrid
;initialize X-Y coordinates of maze


xor ax,ax ; set ah, al to zero

NewRandomSeed1:
	Random3Bit1:
		call Random3Bits
		cmp dl,3
			jl GoDown1 ;25 percent chance of going down(if down is possible)
		cmp dl,6
			jl GoRight1 ;37.5 percent chance to go right
			je GoLeft1
			GoUp1:
				CMP AL,0
	jz AdvanceSeed1
				DEC AX
				Call GridCalcAndClear2
	jnc AdvanceSeed1
			GoDown1:
				CMP AL,20
	jz AdvanceSeed1
				Call GridCalcAndClear2
				inc ax
	jnz AdvanceSeed1
			GoLeft1:
				cmp ah,0
	jz AdvanceSeed1
				dec ah
				Call GridCalcAndClear
	jnz AdvanceSeed1
			GoRight1:
				cmp ah,31
	jz AdvanceSeed1
				Call GridCalcAndClear
				inc ah
	AdvanceSeed1:
		cmp ax,1f14h
jnz NewRandomSeed1


WriteSecondPath:
mov al,0
NewRandomSeed2: 
	Random3Bit2:
		Call Random3Bits
		cmp dl,3
			jl GoDown2
		cmp dl,6
			jl GoLeft2
			je GoRight2
			GoUp2:
				CMP AL,0
	jz AdvanceSeed2
				dec ax
				Call GridCalcAndClear2
	jnc AdvanceSeed2

			GoDown2:
				CMP Al,20
	jz AdvanceSeed2
				Call GridCalcAndClear2
				inc ax
	jnz AdvanceSeed2
			GoLeft2:
				cmp ah,0
	jz AdvanceSeed2
				dec ah
				Call GridCalcAndClear
	jnc AdvanceSeed2
			GoRight2:
				cmp ah,31
	jz AdvanceSeed2
				Call GridCalcAndClear
				inc ah
	AdvanceSeed2:
		cmp ax,14h
jnz NewRandomSeed2

initrd:


mov word [es:322],5700h+'G'
mov bp,6846
mov WORD [es:bp],301h
push bp

mov ah,02
mov bh,0
mov dx,2D00h
int 10h ; set cursor location for progress bar


mov ax,0a00h+178
mov cx,364
int 10h ; set time progress bar as shaded blocks







GamePlayLoop:
	mov ah,1
	int 16h
	jz TimerCheck
		mov ah,0
		int 16h
		pop bp
		mov si,bp
		cmp al,'w'
		jnz CheckLeft
			sub si,160
		CheckLeft:
		cmp al, 'a'
		jnz checkdown2
			dec si
			dec si
		checkdown2:             
		cmp al,'s'
		jnz CheckRight
			add si,160
		CheckRight:
		cmp al,'d'
		jnz Move
			inc si
			inc si
		Move:
		cmp byte [es:si],' '    
		jnz CheckGoal
			mov byte [es:bp],' '
			mov word [es:si],301h
			push si
		jz TimerCheck
		CheckGoal:
		cmp byte [es:si],'G'
		jz EndGame1
		push bp
	TimerCheck:
	mov ah,0
	int 1ah
	sub dx,[7902]
	cmp dx,364
	jz EndGame1
	mov cx,dx
	mov ax,0a20h
	inc cx
	int 10h 

jmp GamePlayLoop


EndGame1:
mov ax,3
int 10h
xor di,di
mov si,offset Victory
cmp dx,364
jnz EndGame
	mov si,offset Defeat
	call StringWrite
	mov si,offset NewGame
EndGame:
call stringwrite
NewGameKey:
	mov ah,0
	int 16h
	cmp al,'n'
jnz NewGameKey

NewGame3ByteJump:
jmp StartMazeWrite



GridCalcAndClear2:
	mov Dx,482
	db 0ebh,3 ;jmp +3 - skip mov dx,324 instruction
GridCalcAndClear:
	mov dx,324
	mov bh,0
	push ax
	mov bl,ah
	shl bl,2
	add bx,dx
	mov ah,0
	mov dx,320
	mul dx
	add bx,ax
	mov byte [es:bx],' '
	pop ax
Ret

StringWrite:
	CLD
	StringWrite2:
		movsb
		inc di
		cmp byte [si],0
	jnz StringWrite2
Ret
defeat:
db 'Loss',0

org 32206
Random3Bits:
	shr cx,3
	jnz Next3bits
		inc byte [7900]
		mov si,[7900]
		mov cx,[si]
	Next3bits:
	mov dl,cl
	and dl,7
ret

TimeLabel:
Victory:
db 'WIN'
NewGame:
db ':n - New Game',0

