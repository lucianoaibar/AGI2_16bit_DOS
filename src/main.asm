; Sierra Adventure Game Interpreter (AGI) game engine
; https://en.wikipedia.org/wiki/Adventure_Game_Interpreter
;
; Assets editor:
; http://agi.sierrahelp.com/IDEs/AGIStudio.html
;
; Reverse engineering:
; Luciano Aibar - lucianoaibar@gmail.com - www.lucianoaibar.com
;
; About this version:
; Only includes the EGA video and IBM sound drivers
;
; AGIDATA:
;    0	WORD		offset base para SP de stack de INT1C_SystemTimerTick (luego le agrega +0xa00)
;  a2d	WORD		Cantidad en bytes de memoria ocupada en AGIDATA (utilida por LocalAlloc)
; 10c0	WORD		Size en paragraphs SS - DS(original)
; 10c2	WORD		Size en paragraphs de ?
; 10c4	WORD		Video adapter? -1=indefinido, 1=?, 2=TandyLogic
; 10c6	WORD		=3 EGA ?
; 10c8	0x09 BYTES	ASCIIZ "HGC_Font"
; 10d1	0x0A BYTES	ASCIIZ "Tandylogic"
; 10dc	
; 12ba	BYTE		Keyboard flags (0x10 = scrolllock)
; 1303	WORD		Segment buffer de 0x3480 WORDs
; 1305	WORD		Video buffer segment 0xA000
; 1627	WORD		SS Segment						CS + B7F
; 1629	WORD		?
; 162b	WORD		AGIDATA Segment					CS + 9B6
; 162d	WORD		DS Segment original				CS - 0x10
; 16d3	WORD		1=?
; 1727	WORD		Previous video mode (0x3)
; 1b5a	WORD		?

BITS 16
CPU 286

GLOBAL _small_code_


SEGMENT _TEXT USE16 CLASS=CODE ALIGN=16
_small_code_:
..start:
	cli
	mov ax, SEG AGIDATA		; CS + 0x9b6
	mov ds,ax
	mov [0x162b],ax
	mov [0x162d],es
	mov es,ax
	add ax, 0x1c9			; CS + 0x9b6 + 0x1C9
	mov [0x1627],ax
	mov ss,ax
	mov sp,0x1000
	sti

;_78:
	; call _C4
	; call _3FE2
	mov word [0x10c4], 0		; HACK
	mov word [0x10c6], 3		; HACK
	call _40C2					; HACK

	; Alloc de 0xa00 bytes para stack
	mov word [bp-0x2],0xa00
	push word [bp-0x2]
	call LocalAlloc
	add sp,byte +0x2
	mov [0x0],ax			; WORD address que guardo en [DS:0] (AX = 0x1CA0)
	mov si,ax
	mov al,0x73
	mov di,si
	mov cx,0xa00
	rep stosb
	mov word [si],0xaaaa
	add si,0xa00
	cli
	mov ax, SEG AGIDATA
	mov ss,ax
	mov sp,si
	sti

;_11D:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	call _F1B
_128:
	call _7CCE
	call _4B1F
	mov ax,0x2
	push ax
	call _7233
	add sp,byte +0x2
	mov ax,0x4
	push ax
	call _7233
	add sp,byte +0x2
	call _5F87
	call _34AC
	cmp word [0x139],byte +0x0
	jnz short _15B
	mov di,[0x951]
	mov al,[di+0x21]
	mov [0xf],al
	jmp short _165
_15B:
	mov di,[0x951]
	mov al,[0xf]
	mov [di+0x21],al
_165:
	call _611
	mov al,[0xc]
	sub ah,ah
	mov [0x611],ax
	mov ax,0x9
	push ax
	call _7247
	add sp,byte +0x2
	mov [bp-0x2],ax
	mov ax,0x615
	push ax
	call _7C36
	add sp,byte +0x2
_187:
	sub ax,ax
	push ax
	call _127B
	add sp,byte +0x2
	or ax,ax
	jnz short _1B7
	sub ax,ax
	mov [0x12],al
	sub ah,ah
	mov [0xe],al
	sub ah,ah
	mov [0xd],al
	mov ax,0x2
	push ax
	call _7233
	add sp,byte +0x2
	mov al,[0xc]
	sub ah,ah
	mov [0x611],ax
	jmp short _187
_1B7:
	mov di,[0x951]
	mov al,[0xf]
	mov [di+0x21],al
	mov al,[0xc]
	sub ah,ah
	mov di,ax
	mov ax,di
	cmp ax,[0x611]
	jnz short _1E3
	mov ax,0x9
	push ax
	call _7247
	add sp,byte +0x2
	mov di,ax
	mov ax,[bp-0x2]
	cmp ax,di
	jz short _1E6
_1E3:
	call _33ED
_1E6:
	sub ax,ax
	mov [0xe],al
	sub ah,ah
	mov [0xd],al
	mov ax,0x5
	push ax
	call _7233
	add sp,byte +0x2
	mov ax,0x6
	push ax
	call _7233
	add sp,byte +0x2
	mov ax,0xc
	push ax
	call _7233
	add sp,byte +0x2
	cmp byte [0x16d3],0x0
	jz short _218
	jmp _128
_218:
	call _530
	jmp _128
	mov sp,bp
	pop bp
	pop di
	pop si
	ret

;------------------------------------------------------------------------------
_9733:
_97A2:
_987B:
_98E3:
ReturnToDOS:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	mov al,[bp+0x8]
	mov ah,0x4c
	int 0x21
	add sp,byte +0x2
	pop bp
	pop di
	pop si
	ret

;------------------------------------------------------------------------------
;_C4:
;	push ds
;	mov ax,[0x162d]				; =739 (primer segmento DS cuando el programa inicia)
;	mov ds,ax
;	mov si,0x81
;_CD:
;	lodsb
;	cmp al,0xd
;	jz short _11B				; SI salta siempre en nuestro DOS
;	cmp al,0x2d
;	jnz short _119
;	lodsb
;	cmp al,0x63
;	jnz short _E2
;	mov word [es:0x10c6],0x0
;_E2:
;	cmp al,0x72
;	jnz short _ED
;	mov word [es:0x10c6],0x1
;_ED:
;	cmp al,0x65
;	jnz short _F8
;	mov word [es:0x10c6],0x3
;_F8:
;	cmp al,0x68
;	jnz short _103
;	mov word [es:0x10c6],0x2
;_103:
;	cmp al,0x74
;	jnz short _10E
;	mov word [es:0x10c4],0x2
;_10E:
;	cmp al,0x70
;	jnz short _119
;	mov word [es:0x10c4],0x0
;_119:
;	jmp short _CD
;_11B:
;	pop ds
;	ret

_224:
	push si
	push di
	push bp
	mov bp,sp
	mov word [0x613],0x1
	call _437E
	call _5068
	mov ax,0xbe5
	push ax
	call _1CAB
	add sp,byte +0x2
	mov word [0x613],0x0
	mov ax,[bp+0x8]
	pop bp
	pop di
	pop si
	ret

_24C:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	call _5068
	mov di,si
	inc si
	cmp byte [di],0x1
	jz short _272
	mov ax,0x5e1
	push ax
	call _1CAB
	add sp,byte +0x2
	mov di,ax
	mov ax,di
	cmp ax,0x1
	jnz short _275
_272:
	call TerminateProgram
_275:
	mov ax,si
	pop bp
	pop di
	pop si
	ret

TerminateProgram:
	push si
	push di
	push bp
	mov bp,sp
	call _7F0F
	sub ax,ax
	push ax
	call ReturnToDOS
	add sp,byte +0x2
	pop bp
	pop di
	pop si
	ret

	DB	0x0

;------------------------------------------------------------------------------
; AL = index in array of WORD (address in CS) + WORD (integer?)
_291:
	cmp al,0xfc
	jnc short _2D3
	cmp al,0x0
	jz short _2D3
	cmp al,0xa9
	jna short _2A7
	xor ah,ah
	push ax
	mov ax,0x10
	push ax
	call _3F18
_2A7:
	cmp word [0x1b52],byte +0x1
	jnz short _2BA
	xor ah,ah
	push ax
	push si
	push ax
	call _8921
	add sp,byte +0x4
	pop ax
_2BA:
	xor bh,bh
	mov bl,al
	shl bx,1
	shl bx,1
	push si
;_2C3:
	;call [bx + AGIDATA_61B - AGIDATA]			; long table with CS:address
	call [bx + AGIDATA_61B]			; long table with CS:address
	add sp,byte +0x2
	mov si,ax
	or si,si
	jz short _2D3
	lodsb
	jmp short _291
_2D3:
	ret
_2D4:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov di,[si]
	jmp short _2E2
_2E0:
	mov di,[di]
_2E2:
	or di,di
	jz short _2EF
	push di
	call _9903
	add sp,byte +0x2
	jmp short _2E0
_2EF:
	push si
	call _2FA
	add sp,byte +0x2
	pop bp
	pop di
	pop si
	ret
_2FA:
	push si
	push di
	push bp
	mov bp,sp
	mov bx,[bp+0x8]
	mov si,[bx]
	jmp short _308
_306:
	mov si,di
_308:
	or si,si
	jz short _317
	mov di,[si]
	push si
	call _8C88
	add sp,byte +0x2
	jmp short _306
_317:
	sub ax,ax
	mov bx,[bp+0x8]
	mov [bx+0x2],ax
	mov [bx],ax
	pop bp
	pop di
	pop si
	ret

;------------------------------------------------------------------------------
; param 1 = address para CALL
_325:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,0x40a
	mov si,[0x951]
	mov word [bp-0x4],0x0
	jmp short _33C
_339:
	add si,byte +0x2b
_33C:
	mov ax,[0x953]
	cmp ax,si
	jna short _389
	push si
;_344:
	call [bp+0x8]
	add sp,byte +0x2
	or ax,ax
	jz short _339
	mov bx,[bp-0x4]
	shl bx,1
	add bx,bp
	mov [bx-0x206],si
	mov ax,[bp-0x4]
	shl ax,1
	add ax,bp
	mov [bp-0x40a],ax
	test word [si+0x25],0x4
	jz short _379
	mov al,[si+0x24]
	sub ah,ah
	push ax
	call _4BB7
	add sp,byte +0x2
	jmp short _37C
_379:
	mov ax,[si+0x5]
_37C:
	mov bx,[bp-0x40a]
	mov [bx-0x408],ax
	inc word [bp-0x4]
	jmp short _339
_389:
	mov word [bp-0x6],0x0
	jmp short _393
_390:
	inc word [bp-0x6]
_393:
	mov ax,[bp-0x6]
	cmp ax,[bp-0x4]
	jnc short _3F3
	mov word [bp-0x208],0xff
	sub di,di
	jmp short _3A6
_3A5:
	inc di
_3A6:
	mov ax,[bp-0x4]
	cmp ax,di
	jna short _3D0
	mov bx,di
	shl bx,1
	add bx,bp
	mov ax,[bx-0x408]
	cmp ax,[bp-0x208]
	jnl short _3A5
	mov [bp-0x2],di
	mov bx,di
	shl bx,1
	add bx,bp
	mov ax,[bx-0x408]
	mov [bp-0x208],ax
	jmp short _3A5
_3D0:
	mov bx,[bp-0x2]
	shl bx,1
	add bx,bp
	mov word [bx-0x408],0xff
	push word [bp+0xa]
	mov bx,[bp-0x2]
	shl bx,1
	add bx,bp
	push word [bx-0x206]
	call _3FC
	add sp,byte +0x4
	jmp short _390
_3F3:
	mov ax,[bp+0xa]
	mov sp,bp
	pop bp
	pop di
	pop si
	ret
_3FC:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0xa]
	push word [bp+0x8]
	call _8C15
	add sp,byte +0x2
	mov di,ax
	mov ax,[si]
	mov [di],ax
	or ax,ax
	jz short _41C
	mov bx,[di]
	mov [bx+0x2],di
_41C:
	mov [si],di
	cmp word [si+0x2],byte +0x0
	jnz short _427
	mov [si+0x2],di
_427:
	pop bp
	pop di
	pop si
	ret
_42B:
	push si
	push di
	push bp
	mov bp,sp
	mov di,[bp+0x8]
	mov si,[di+0x2]
	jmp short _43B
_438:
	mov si,[si+0x2]
_43B:
	or si,si
	jz short _451
	push si
	call _9900
	add sp,byte +0x2
	push word [si+0x4]
	call _9906
	add sp,byte +0x2
	jmp short _438
_451:
	pop bp
	pop di
	pop si
	ret
_455:
	push si
	push di
	push bp
	mov bp,sp
	mov bx,[bp+0x8]
	mov si,[bx]
	jmp short _463
_461:
	mov si,[si]
_463:
	or si,si
	jz short _4A2
	mov di,[si+0x4]
	push di
	call _557B
	add sp,byte +0x2
	mov al,[di+0x1]
	cmp al,[di]
	jnz short _461
	mov ax,[di+0x3]
	cmp ax,[di+0x16]
	jnz short _48F
	mov ax,[di+0x5]
	cmp ax,[di+0x18]
	jnz short _48F
	or word [di+0x25],0x4000
	jmp short _461
_48F:
	mov ax,[di+0x3]
	mov [di+0x16],ax
	mov ax,[di+0x5]
	mov [di+0x18],ax
	and word [di+0x25],0xbfff
	jmp short _461
_4A2:
	pop bp
	pop di
	pop si
	ret

_4A6:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov di,si
	inc si
	mov al,[di]
	sub ah,ah
	push ax
	call _4C2
	add sp,byte +0x2
	mov ax,si
	pop bp
	pop di
	pop si
	ret
_4C2:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov ax,si
	imul word [cs:_776]
	mov bx,ax
	mov cx,[0x951]
	add cx,bx
	mov di,cx
	mov ax,cx
	cmp ax,[0x953]
	jc short _4EE
	push si
	mov ax,0xd
	push ax
	call _3F18
	add sp,byte +0x4
_4EE:
	test word [di+0x25],0x40
	jnz short _506
	mov word [di+0x25],0x70
	mov byte [di+0x22],0x0
	mov byte [di+0x23],0x0
	mov byte [di+0x21],0x0
_506:
	pop bp
	pop di
	pop si
	ret

_50A:
	push si
	push di
	push bp
	mov bp,sp
	call _67E9
	mov si,[0x951]
	jmp short _51B
_518:
	add si,byte +0x2b
_51B:
	mov ax,[0x953]
	cmp ax,si
	jna short _529
	and word [si+0x25],0xffbe
	jmp short _518
_529:
	mov ax,[bp+0x8]
	pop bp
	pop di
	pop si
	ret
_530:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x1
	sub di,di
	mov si,[0x951]
	jmp short _543
_540:
	add si,byte +0x2b
_543:
	mov ax,[0x953]
	cmp ax,si
	ja short _54D
	jmp _5DD
_54D:
	mov cx,[si+0x25]
	and cx,0x51
	mov ax,cx
	cmp ax,0x51
	jnz short _540
	inc di
	mov byte [bp-0x1],0x4
	test word [si+0x25],0x2000
	jnz short _594
	cmp byte [si+0xb],0x2
	jz short _573
	cmp byte [si+0xb],0x3
	jnz short _580
_573:
	mov al,[si+0x21]
	sub ah,ah
	mov bx,ax
	mov al,[bx+0x8c3]
	jmp short _591
_580:
	cmp byte [si+0xb],0x4
	jnz short _594
	mov al,[si+0x21]
	sub ah,ah
	mov bx,ax
	mov al,[bx+0x8cd]
_591:
	mov [bp-0x1],al
_594:
	cmp byte [si+0x1],0x1
	jnz short _5B5
	cmp byte [bp-0x1],0x4
	jz short _5B5
	mov al,[si+0xa]
	cmp al,[bp-0x1]
	jz short _5B5
	mov al,[bp-0x1]
	sub ah,ah
	push ax
	push si
	call _3AE7
	add sp,byte +0x4
_5B5:
	test word [si+0x25],0x20
	jz short _540
	cmp byte [si+0x20],0x0
	jnz short _5C5
	jmp _540
_5C5:
	dec byte [si+0x20]
	jz short _5CD
	jmp _540
_5CD:
	push si
	call _47AF
	add sp,byte +0x2
	mov al,[si+0x1f]
	mov [si+0x20],al
	jmp _540
_5DD:
	or di,di
	jz short _60B
	mov ax,0x167b
	push ax
	call _2D4
	add sp,byte +0x2
	call _14CF
	call _67BB
	push ax
	call _42B
	add sp,byte +0x2
	mov ax,0x167b
	push ax
	call _455
	add sp,byte +0x2
	mov bx,[0x951]
	and word [bx+0x25],0xf6ff
_60B:
	mov sp,bp
	pop bp
	pop di
	pop si
	ret
_611:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[0x951]
	jmp short _61F
_61C:
	add si,byte +0x2b
_61F:
	mov ax,[0x953]
	cmp ax,si
	jna short _643
	mov di,[si+0x25]
	and di,0x51
	mov ax,di
	cmp ax,0x51
	jnz short _61C
	cmp byte [si+0x1],0x1
	jnz short _61C
	push si
	call _647
	add sp,byte +0x2
	jmp short _61C
_643:
	pop bp
	pop di
	pop si
	ret
_647:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov al,[si+0x22]
	sub ah,ah
	jmp short _66B
_656:
	push si
	call _3E8A
_65A:
	add sp,byte +0x2
	jmp short _680
_65F:
	push si
	call _B03
	jmp short _65A
_665:
	push si
	call _1637
	jmp short _65A
_66B:
	dec ax
	cmp ax,0x2
	ja short _680
	shl ax,1
	mov bx,ax
	jmp [cs:bx+_67A]
_67A:
	DW	_656
	DW	_65F
	DW	_665

_680:
	cmp word [0x13d],byte +0x0
	jnz short _68E
	and word [si+0x25],0xff7f
	jmp short _6A2
_68E:
	test word [si+0x25],0x2
	jnz short _6A2
	cmp byte [si+0x21],0x0
	jz short _6A2
	push si
	call _6A6
	add sp,byte +0x2
_6A2:
	pop bp
	pop di
	pop si
	ret
_6A6:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x6
	mov si,[bp+0x8]
	mov ax,[si+0x3]
	mov [bp-0x4],ax
	mov ax,[si+0x5]
	mov [bp-0x6],ax
	push ax
	push word [bp-0x4]
	call _793C
	add sp,byte +0x4
	mov [bp-0x2],ax
	mov al,[si+0x21]
	sub ah,ah
	jmp short _71F
_6D1:
	mov al,[si+0x1e]
	sub ah,ah
	sub [bp-0x6],ax
	jmp short _73E
_6DB:
	mov al,[si+0x1e]
	sub ah,ah
	add [bp-0x4],ax
	jmp short _6D1
_6E5:
	mov al,[si+0x1e]
	sub ah,ah
	add [bp-0x4],ax
	jmp short _73E
_6EF:
	mov al,[si+0x1e]
	sub ah,ah
	add [bp-0x4],ax
_6F7:
	mov al,[si+0x1e]
	sub ah,ah
	add [bp-0x6],ax
	jmp short _73E
_701:
	mov al,[si+0x1e]
	sub ah,ah
	sub [bp-0x4],ax
	jmp short _6F7
_70B:
	mov al,[si+0x1e]
	sub ah,ah
	sub [bp-0x4],ax
	jmp short _73E
_715:
	mov al,[si+0x1e]
	sub ah,ah
	sub [bp-0x4],ax
	jmp short _6D1
_71F:
	dec ax
	cmp ax,0x7
	ja short _73E
	shl ax,1
	mov bx,ax
	jmp [cs:bx+_72E]
_72E:
	DW	_6D1
	DW	_6DB
	DW	_6E5
	DW	_6EF
	DW	_6F7
	DW	_701
	DW	_70B
	DW	_715

_73E:
	push word [bp-0x6]
	push word [bp-0x4]
	call _793C
	add sp,byte +0x4
	mov di,ax
	mov ax,[bp-0x2]
	cmp ax,di
	jnz short _75A
	and word [si+0x25],0xff7f
	jmp short _76F
_75A:
	or word [si+0x25],0x80
	mov byte [si+0x21],0x0
	mov ax,[0x951]
	cmp ax,si
	jnz short _76F
	mov byte [0xf],0x0
_76F:
	mov sp,bp
	pop bp
	pop di
	pop si
	ret

	DB	0x0
_776:
	DB	0x2B
	DB	0x0

;------------------------------------------------------------------------------
; Decrypt using "Avis Durgan" as dictionary
; * object
DecryptUsingAvisDurgan:		; 0x778
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	mov si,[bp+0x8]			; from address
	mov di,0x8d7			; "Avis Durgan"
_786:
	mov ax,[bp+0xa]			; to address
	cmp ax,si
	jna short _7A9
	cmp byte [di],0x0		; end of dictionary string ?
	jnz short _795
	mov di,0x8d7			; "Avis Durgan"
_795:
	mov ax,si
	inc si
	mov [bp-0x2],ax
	mov bx,di
	inc di
	mov al,[bx]
	sub ah,ah
	mov bx,[bp-0x2]
;_7A5:
	xor [bx],al
	jmp short _786
_7A9:
	mov sp,bp
	pop bp
	pop di
	pop si
	ret

	DB	0x0

_7B0:
	mov [0x92f],si
	dec word [0x92f]
	cmp al,0x26
	jnc short _7DF
	xor bh,bh
	mov bl,al
	shl bx,1
	shl bx,1
	call [bx+0x8e3]
	cmp word [0x1b52],byte +0x1
	jnz short _7DE
	xor ah,ah
	push ax
	push word [0x92f]
	push ax
	call _8947
	add sp,byte +0x4
	pop ax
_7DE:
	ret
_7DF:
	xor ah,ah
	push ax
	mov word [bp-0x2],0xf
	push word [bp-0x2]
	call _3F18
	add sp,byte +0x4
_7F0:
	lodsb
	xor bh,bh
	mov bl,al
	lodsb
	cmp al,[bx+0x9]
	mov al,0x0
	jnz short _800
	inc al
_800:
	ret

_801:
	lodsb
	xor bh,bh
	mov bl,al
	mov ah,[bx+0x9]
	lodsb
	mov bl,al
	xor al,al
	cmp ah,[bx+0x9]
	jnz short _817
	inc al
_817:
	ret

_818:
	lodsb
	xor bh,bh
	mov bl,al
	lodsb
	cmp [bx+0x9],al
	mov al,0x0
	jnc short _828
	inc al
_828:
	ret

_829:
	lodsb
	xor bh,bh
	mov bl,al
	mov ah,[bx+0x9]
	lodsb
	mov bl,al
	xor al,al
	cmp ah,[bx+0x9]
	jnc short _83F
	inc al
_83F:
	ret

_840:
	lodsb
	xor bh,bh
	mov bl,al
	lodsb
	cmp [bx+0x9],al
	mov al,0x0
	jna short _850
	inc al
_850:
	ret

_851:
	lodsb
	xor bh,bh
	mov bl,al
	mov ah,[bx+0x9]
	lodsb
	mov bl,al
	xor al,al
	cmp ah,[bx+0x9]
	jna short _867
	inc al
_867:
	ret

_868:
	lodsb
	call _7265
	ret

_86D:
	lodsb
	xor bh,bh
	mov bl,al
	mov al,[bx+0x9]
	call _7265
	ret

_87A:
	lodsb
	xor ah,ah
	mov bx,0x3
	mul bx
	mov bx,ax
	xor al,al
	mov di,[0x957]
	cmp byte [bx+di+0x2],0xff
	jnz short _892
	inc al
_892:
	ret

_893:
	call _8E7
	jmp short _8BD

_899:
	call _8E7
	mov al,[bx+0x1a]
	shr al,1
	add dh,al
	mov ch,dh
	jmp short _8BD

_8A8:
	call _8E7
	add dh,[bx+0x1a]
	dec dh
	mov ch,dh
	jmp short _8BD

_8B5:
	call _8E7
	add ch,[bx+0x1a]
	dec ch
_8BD:
	lodsb
	cmp dh,al
	jnc short _8C8
	add si,byte +0x3
	jmp short _8E4
_8C8:
	lodsb
	cmp dl,al
	jnc short _8D3
	add si,byte +0x2
	jmp short _8E4
_8D3:
	lodsb
	cmp ch,al
	jna short _8DC
	inc si
	jmp short _8E4
_8DC:
	lodsb
	cmp dl,al
	ja short _8E4
	mov al,0x1
	ret
_8E4:
	xor al,al
	ret
_8E7:
	lodsb
	xor ah,ah
	mov bx,0x2b
	mul bx
	mov bx,ax
	add bx,[0x951]
	mov dh,[bx+0x3]
	mov ch,dh
	mov dl,[bx+0x5]
	ret

_8FE:
	lodsb
	xor bh,bh
	mov bl,al
	mov al,[bx+0x11ae]
	ret

_908:
	lodsb
	xor ah,ah
	mov bx,0x3
	mul bx
	mov bx,ax
	mov di,[0x957]
	mov ah,[bx+di+0x2]
	lodsb
	xor bh,bh
	mov bl,al
	xor al,al
	cmp ah,[bx+0x9]
	jnz short _928
	inc al
_928:
	ret

_929:
	xor ax,ax
	lodsb
	push ax
	mov dx,[0xc7b]
	or dx,dx
	jz short _988
	mov al,0x4
	call _7265
	jnz short _988
	mov al,0x2
	call _7265
	jz short _988
	pop cx
	xor bx,bx
_946:
	or cx,cx
	jz short _972
	lodsw
	dec cx
	cmp ax,0x270f
	jnz short _95B
	shl cx,1
	add si,cx
	xor cx,cx
	mov dx,cx
	jmp short _972
_95B:
	or dx,dx
	jnz short _962
	inc dx
	jmp short _972
_962:
	cmp ax,[bx+0xc53]
	jz short _96D
	cmp ax,0x1
	jnz short _972
_96D:
	inc bx
	inc bx
	dec dx
	jmp short _946
_972:
	mov bx,cx
	or cx,dx
	jnz short _981
	mov al,0x4
	call _7251
	mov al,0x1
	jmp short _987
_981:
	shl bx,1
	add si,bx
	xor al,al
_987:
	ret
_988:
	pop cx
	jmp short _972

_98B:
	mov al,[0x1c]
	test al,al
	jnz short _99A
_992:
	call _449A
	cmp ax,0xffff
	jz short _992
_99A:
	test al,al
	jz short _9A4
	mov [0x1c],al
	mov ax,0x1
_9A4:
	ret

_9A5:
	xor ax,ax
	ret

_9A8:
	xor ah,ah
	lodsb
	mov bx,ax
	lodsb
	push bx
	push ax
	call _E79
	add sp,byte +0x4
	ret

_9B7:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov di,si
	inc si
	mov al,[di]
	sub ah,ah
	push ax
	call _9D3
	add sp,byte +0x2
	mov ax,si
	pop bp
	pop di
	pop si
	ret
_9D3:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov ax,si
	imul word [cs:_B01]
	mov cx,ax
	mov ax,[0x951]
	add ax,cx
	mov di,ax
	mov ax,[0x953]
	cmp ax,di
	jnc short _9FD
	push si
	mov ax,0x13
	push ax
	call _3F18
	add sp,byte +0x4
_9FD:
	cmp word [di+0x10],byte +0x0
	jnz short _A0E
	push si
	mov ax,0x14
	push ax
	call _3F18
	add sp,byte +0x4
_A0E:
	test word [di+0x25],0x1
	jnz short _A58
	or word [di+0x25],0x10
	push di
	call _5753
	add sp,byte +0x2
	mov ax,[di+0x10]
	mov [di+0x12],ax
	mov ax,[di+0x3]
	mov [di+0x16],ax
	mov ax,[di+0x5]
	mov [di+0x18],ax
	mov ax,0x167b
	push ax
	call _2D4
	add sp,byte +0x2
	or word [di+0x25],0x1
	call _67BB
	push ax
	call _42B
	add sp,byte +0x2
	push di
	call _557B
	add sp,byte +0x2
	and word [di+0x25],0xefff
_A58:
	pop bp
	pop di
	pop si
	ret

_A5C:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov di,si
	inc si
	mov al,[di]
	sub ah,ah
	push ax
	call _A78
	add sp,byte +0x2
	mov ax,si
	pop bp
	pop di
	pop si
	ret
_A78:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	mov si,[bp+0x8]
	mov ax,si
	imul word [cs:_B01]
	mov cx,ax
	mov ax,[0x951]
	add ax,cx
	mov di,ax
	mov ax,[0x953]
	cmp ax,di
	jnc short _AA5
	push si
	mov ax,0xc
	push ax
	call _3F18
	add sp,byte +0x4
_AA5:
	test word [di+0x25],0x1
	jz short _AFB
	mov ax,0x167b
	push ax
	call _2D4
	add sp,byte +0x2
	test word [di+0x25],0x10
	jnz short _AC2
	mov ax,0x1
	jmp short _AC4
_AC2:
	sub ax,ax
_AC4:
	mov [bp-0x2],ax
	or ax,ax
	jz short _AD5
	mov ax,0x167f
	push ax
	call _2D4
	add sp,byte +0x2
_AD5:
	and word [di+0x25],0xfffe
	cmp word [bp-0x2],byte +0x0
	jz short _AEA
	call _67D2
	push ax
	call _42B
	add sp,byte +0x2
_AEA:
	call _67BB
	push ax
	call _42B
	add sp,byte +0x2
	push di
	call _557B
	add sp,byte +0x2
_AFB:
	mov sp,bp
	pop bp
	pop di
	pop si
	ret
_B01:
	sub ax,[bx+si]
_B03:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x8
	mov si,[bp+0x8]
	mov di,[0x951]
	mov ax,[di+0x1a]
	cwd
	idiv word [cs:_C0F]
	mov cx,ax
	mov ax,[di+0x3]
	add ax,cx
	mov [bp-0x4],ax
	mov ax,[si+0x1a]
	cwd
	idiv word [cs:_C0F]
	mov di,ax
	mov ax,[si+0x3]
	add ax,di
	mov [bp-0x6],ax
	mov al,[si+0x27]
	sub ah,ah
	push ax
	mov di,[0x951]
	push word [di+0x5]
	push word [bp-0x4]
	push word [si+0x5]
	push word [bp-0x6]
	call _16B2
	add sp,byte +0xa
	mov [bp-0x2],ax
	cmp word [bp-0x2],byte +0x0
	jnz short _B74
	mov byte [si+0x21],0x0
	mov byte [si+0x22],0x0
	mov al,[si+0x28]
	sub ah,ah
	push ax
	call _7229
	add sp,byte +0x2
	jmp _C09
_B74:
	cmp byte [si+0x29],0xff
	jnz short _B80
	mov byte [si+0x29],0x0
	jmp short _BED
_B80:
	test word [si+0x25],0x4000
	jz short _BED
_B87:
	call _3ED3
	mov [si+0x21],al
	sub ah,ah
	or ax,ax
	jz short _B87
	mov bx,[0x951]
	mov ax,[si+0x5]
	sub ax,[bx+0x5]
	push ax
	call _4B9F
	add sp,byte +0x2
	mov di,ax
	mov ax,[bp-0x6]
	sub ax,[bp-0x4]
	push ax
	call _4B9F
	add sp,byte +0x2
	add ax,di
	shr ax,1
	inc ax
	mov [bp-0x8],ax
	mov al,[si+0x1e]
	sub ah,ah
	mov di,ax
	mov ax,[bp-0x8]
	cmp ax,di
	ja short _BD1
	mov al,[si+0x1e]
	mov [si+0x29],al
	jmp short _C09
_BD1:
	mov al,[si+0x1e]
	sub ah,ah
	mov di,ax
	call _6F23
	sub dx,dx
	div word [bp-0x8]
	mov ax,dx
	mov [si+0x29],al
	sub ah,ah
	cmp ax,di
	jnc short _C09
	jmp short _BD1
_BED:
	cmp byte [si+0x29],0x0
	jz short _C03
	mov al,[si+0x1e]
	sub ah,ah
	sub [si+0x29],al
	jnl short _C09
	mov byte [si+0x29],0x0
	jmp short _C09
_C03:
	mov ax,[bp-0x2]
	mov [si+0x21],al
_C09:
	mov sp,bp
	pop bp
	pop di
	pop si
	ret
_C0F:
	DB	0x2
	DB	0x0

_C11:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,0x19a
	mov si,[bp+0x8]
	call _3793
	mov [bp-0xa],ax
	call _2A69
	call _375E
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	imul word [cs:_F19]
	add ax,0x20d
	mov di,ax
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	mov [bp-0x8],ax
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	mov [bp-0x2],ax
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	mov [bp-0x4],ax
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	mov cx,ax
	inc cx
	mov [bp-0x6],cx
	mov ax,cx
	cmp ax,0x28
	jng short _C71
	mov word [bp-0x6],0x28
_C71:
	mov byte [di],0x0
	cmp word [bp-0x2],byte +0x19
	jnl short _C86
	push word [bp-0x4]
	push word [bp-0x2]
	call _2A4E
	add sp,byte +0x4
_C86:
	cmp word [0x10c6],byte +0x2
	jnz short _C94
	cmp word [0xce7],byte +0x0
	jz short _CC0
_C94:
	mov ax,0x28
	push ax
	push word [bp-0x8]
	call _21B3
	add sp,byte +0x2
	push ax
	lea ax,[bp-0x19a]
	push ax
	call _1F17
	add sp,byte +0x6
	push ax
	call _2353
	add sp,byte +0x2
	push word [bp-0x6]
	push di
	call _D76
	add sp,byte +0x4
	jmp short _CF0
_CC0:
	push word [bp-0x6]
	mov ax,0x24
	push ax
	push word [bp-0x8]
	call _21B3
	add sp,byte +0x2
	push ax
	lea ax,[bp-0x19a]
	push ax
	call _1F17
	add sp,byte +0x6
	push ax
	call _97A2
	add sp,byte +0x4
	push word [bp-0x6]
	push di
	call _D76
	add sp,byte +0x4
	call _98E3
_CF0:
	call _2A90
	cmp word [bp-0xa],byte +0x0
	jz short _CFC
	call _3727
_CFC:
	mov ax,si
	mov sp,bp
	pop bp
	pop di
	pop si
	ret

_D04:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	imul word [cs:_F19]
	add ax,0x20d
	mov di,ax
	mov ax,0x28
	push ax
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	push ax
	call _21B3
	add sp,byte +0x2
	push ax
	push di
	call _4C1D
	add sp,byte +0x6
	mov ax,si
	pop bp
	pop di
	pop si
	ret

_D3D:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	imul word [cs:_F19]
	add ax,0x20d
	mov di,ax
	mov ax,0x28
	push ax
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	mov bx,ax
	shl bx,1
	push word [bx+0xc67]
	push di
	call _4C1D
	add sp,byte +0x6
	mov ax,si
	pop bp
	pop di
	pop si
	ret
_D76:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2a
	cmp word [bp+0xa],byte +0x28
	jng short _D89
	mov word [bp+0xa],0x28
_D89:
	mov ax,[bp+0xa]
	add ax,bp
	sub ax,0x2a
	mov [bp-0x2],ax
	push word [bp+0xa]
	push word [bp+0x8]
	lea ax,[bp-0x2a]
	push ax
	call _4C1D
	add sp,byte +0x6
	lea ax,[bp-0x2a]
	push ax
	call _2353
	add sp,byte +0x2
	lea ax,[bp-0x2a]
	push ax
	call _4BCE
	add sp,byte +0x2
	add ax,bp
	sub ax,0x2a
	mov si,ax
_DBF:
	call _3727
	call _44D3
	mov di,ax
	call _375E
	mov ax,di
	jmp short _E1E
_DCE:
	lea cx,[bp-0x2a]
	mov ax,cx
	cmp ax,si
	jnc short _DBF
	dec si
_DD8:
	push di
	call _2953
	add sp,byte +0x2
	jmp short _DBF
_DE1:
	lea cx,[bp-0x2a]
	mov ax,cx
	cmp ax,si
	jnc short _DBF
	dec si
	mov ax,0x8
	push ax
	call _2953
	add sp,byte +0x2
	jmp short _DE1
_DF7:
	mov byte [si],0x0
	lea ax,[bp-0x2a]
	push ax
	push word [bp+0x8]
	call _4BE9
	add sp,byte +0x4
_E07:
	mov ax,di
	jmp short _E45
_E0B:
	mov cx,[bp-0x2]
	dec cx
	mov ax,cx
	cmp ax,si
	jna short _DBF
	mov bx,si
	inc si
	mov ax,di
	mov [bx],al
	jmp short _DD8
_E1E:
	mov bx,_E31-2
	mov cx,0x5
_E24:
	inc bx
	inc bx
	cmp ax,[cs:bx]
	loopne _E24
	jnz short _E0B
	jmp [cs:bx+0xA]
_E31:
	DW	3
	DW	0x8
	DW	0xD
	DW	0x18
	DW	0x1B
	DW	_DE1
	DW	_DCE
	DW	_DF7
	DW	_DE1
	DW	_E07

_E45:
	mov sp,bp
	pop bp
	pop di
	pop si
	ret

_E4B:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov ax,0x7
	push ax
	mov di,si
	inc si
	mov al,[di]
	sub ah,ah
	push ax
	call _21B3
	add sp,byte +0x2
	push ax
	mov ax,0x2
	push ax
	call _4C1D
	add sp,byte +0x6
	call _5962
	mov ax,si
	pop bp
	pop di
	pop si
	ret

_E79:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x52
	lea ax,[bp-0x29]
	push ax
	push word [bp+0x8]
	call _EC5
	add sp,byte +0x4
	lea ax,[bp-0x52]
	push ax
	push word [bp+0xa]
	call _EC5
	add sp,byte +0x4
	lea si,[bp-0x29]
	lea di,[bp-0x52]
	jmp short _EA5
_EA3:
	inc si
	inc di
_EA5:
	cmp byte [si],0x0
	jz short _EB2
	mov al,[si]
	cmp al,[di]
	jz short _EA3
	jmp short _EBD
_EB2:
	mov al,[si]
	cmp al,[di]
	jnz short _EBD
	mov ax,0x1
	jmp short _EBF
_EBD:
	sub ax,ax
_EBF:
	mov sp,bp
	pop bp
	pop di
	pop si
	ret

_EC5:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	mov si,[bp+0xa]
	mov ax,[bp+0x8]
	mul word [cs:_F19]
	add ax,0x20d
	mov di,ax
	jmp short _EE0
_EDF:
	inc di
_EE0:
	cmp byte [di],0x0
	jz short _F10
	mov al,[di]
	sub ah,ah
	push ax
	mov ax,0x931
	push ax
	call _4E92
	add sp,byte +0x4
	or ax,ax
	jnz short _EDF
	mov ax,si
	inc si
	mov [bp-0x2],ax
	mov al,[di]
	sub ah,ah
	push ax
	call _4E1F
	add sp,byte +0x2
	mov bx,[bp-0x2]
	mov [bx],al
	jmp short _EDF
_F10:
	mov byte [si],0x0
	mov sp,bp
	pop bp
	pop di
	pop si
	ret

_F19:
	DW	0x28

_F1B:
	push si
	push di
	push bp
	mov bp,sp
	call _7E9D
	call _4201
	sub ax,ax
	push ax
	mov ax,0xf
	push ax
	call _7538
	add sp,byte +0x4
	call _3807
	call _436F
	sub ax,ax
	push ax
	push word [0x94d]
	call _3043
	add sp,byte +0x4
	mov [0xc7d],ax
	call _10B5
	call _388E
	call _4EF1
	call _48C9
	call _F72
	sub ax,ax
	push ax
	call _1167
	add sp,byte +0x2
	call _1443
	mov ax,0x9
	push ax
	call _7229
	add sp,byte +0x2
	pop bp
	pop di
	pop si
	ret

_F72:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x4
	cmp word [0x957],byte +0x0
	jz short _F86
	sub word [0x957],byte +0x3
_F86:
	push word [0x957]
	push word [0x94f]
	call _3043
	add sp,byte +0x4
	mov [0x957],ax
	add ax,[0xeb0]
	push ax
	push word [0x957]
	call DecryptUsingAvisDurgan			; object
	add sp,byte +0x4
	mov ax,[0xeb0]
	add ax,0xfffd
	mov [0x95b],ax
	mov bx,[0x957]
	mov al,[bx+0x2]
	sub ah,ah
	mov [bp-0x2],ax
	mov ax,[bx]
	mov [bp-0x4],ax
	add word [0x957],byte +0x3
	mov ax,[0x957]
	add ax,[bp-0x4]
	mov [0x959],ax
	inc word [bp-0x2]
	cmp word [0x951],byte +0x0
	jnz short _FED
	mov ax,[bp-0x2]
	imul word [cs:_10B3]
	mov [0x955],ax
	push ax
	call LocalAlloc
	add sp,byte +0x2
	mov [0x951],ax
_FED:
	sub ax,ax
	push ax
	push word [0x955]
	push word [0x951]
	call _5945
	add sp,byte +0x6
	mov ax,[bp-0x2]
	imul word [cs:_10B3]
	mov cx,ax
	mov ax,[0x951]
	add ax,cx
	mov [0x953],ax
	sub ax,0x2b
	mov [0xe4a],ax
	sub di,di
	mov si,[0x951]
	jmp short _1022
_101E:
	inc di
	add si,byte +0x2b
_1022:
	mov ax,[bp-0x2]
	cmp ax,di
	jng short _1030
	mov ax,di
	mov [si+0x2],al
	jmp short _101E
_1030:
	sub ax,ax
	push ax
	mov ax,0x100
	push ax
	mov ax,0x9
	push ax
	call _5945
	add sp,byte +0x6
	call _728D
	call _4B1F
	call _109D
	call _67E9
	mov ax,[0x10c4]
	mov [0x1d],al
	mov ax,[0x10c6]
	mov [0x23],al
	mov byte [0x21],0x29
	mov ax,0x5
	push ax
	call _7229
	add sp,byte +0x2
	mov word [0x139],0x1
	mov word [0x13b],0x0
	mov word [0x13d],0x0
	cmp word [0x10c4],byte +0x0
	jnz short _1088
	mov byte [0x1f],0x1
	jmp short _1097
_1088:
	mov byte [0x1f],0x3
	mov ax,0xb
	push ax
	call _7229
	add sp,byte +0x2
_1097:
	mov sp,bp
	pop bp
	pop di
	pop si
	ret
_109D:
	push si
	push di
	push bp
	mov bp,sp
	call _10C4
	call _389D
	call _4F00
	call _48D8
	pop bp
	pop di
	pop si
	ret

	DB	0x0
_10B3:
	DB	0x2B
	DB	0x0
_10B5:
	push si
	push di
	push bp
	mov bp,sp
	mov word [0x95d],0x0
	pop bp
	pop di
	pop si
	ret
_10C4:
	push si
	push di
	push bp
	mov bp,sp
	cmp word [0x95d],byte +0x0
	jz short _10D8
	mov di,[0x95d]
	mov word [di],0x0
_10D8:
	pop bp
	pop di
	pop si
	ret
_10DC:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[0x95d]
	mov di,0x95d
	jmp short _10EE
_10EA:
	mov di,si
	mov si,[si]
_10EE:
	or si,si
	jz short _1100
	mov al,[si+0x2]
	sub ah,ah
	mov cx,ax
	mov ax,cx
	cmp ax,[bp+0x8]
	jnz short _10EA
_1100:
	mov [0x969],di
	mov ax,si
	pop bp
	pop di
	pop si
	ret

_110A:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov di,si
	inc si
	mov al,[di]
	sub ah,ah
	push ax
	call _114A
	add sp,byte +0x2
	mov ax,si
	pop bp
	pop di
	pop si
	ret

_1126:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov di,si
	inc si
	mov al,[di]
	sub ah,ah
	mov di,ax
	mov al,[di+0x9]
	sub ah,ah
	push ax
	call _114A
	add sp,byte +0x2
	mov ax,si
	pop bp
	pop di
	pop si
	ret

_114A:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	push si
	call _1167
	add sp,byte +0x2
	push si
	sub ax,ax
	push ax
	call _6E46
	add sp,byte +0x4
	pop bp
	pop di
	pop si
	ret
_1167:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x4
	push word [bp+0x8]
	call _10DC
	add sp,byte +0x2
	mov si,ax
	or ax,ax
	jz short _1181
	jmp _121F
_1181:
	call _67E9
	mov ax,0xa
	push ax
	call LocalAlloc
	add sp,byte +0x2
	mov si,ax
	mov bx,[0x969]
	mov [bx],ax
	mov word [si],0x0
	mov ax,[bp+0x8]
	mov [si+0x2],al
	sub ax,ax
	push ax
	push word [bp+0x8]
	call _426D
	add sp,byte +0x2
	push ax
	call _2D62
	add sp,byte +0x4
	mov di,ax
	lea ax,[di+0x2]
	mov [si+0x4],ax
	mov [si+0x6],ax
	mov [bp-0x2],ax
	mov al,[di+0x1]
	sub ah,ah
	mov cl,0x8
	shl ax,cl
	mov cx,ax
	mov al,[di]
	sub ah,ah
	add ax,cx
	add [bp-0x2],ax
	mov bx,[bp-0x2]
	inc word [bp-0x2]
	mov al,[bx]
	mov [si+0x3],al
	mov ax,[bp-0x2]
	mov [si+0x8],ax
	mov ax,[0x967]
	mov [bp-0x4],ax
	mov [0x967],si
	cmp byte [si+0x3],0x0
	jz short _1216
	sub ax,ax
	push ax
	call _21B3
	add sp,byte +0x2
	push ax
	mov al,[si+0x3]
	sub ah,ah
	inc ax
	shl ax,1
	mov cx,ax
	mov ax,[si+0x8]
	add ax,cx
	push ax
;_1210:
	call DecryptUsingAvisDurgan
	add sp,byte +0x4
_1216:
	mov ax,[bp-0x4]
	mov [0x967],ax
	call _6823
_121F:
	mov ax,si
	mov sp,bp
	pop bp
	pop di
	pop si
	ret

_1227:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	push ax
	call _127B
	add sp,byte +0x2
	mov di,ax
	or di,di
	jnz short _1247
	sub ax,ax
	jmp short _1249
_1247:
	mov ax,si
_1249:
	pop bp
	pop di
	pop si
	ret

_124D:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	mov bx,ax
	mov al,[bx+0x9]
	sub ah,ah
	push ax
	call _127B
	add sp,byte +0x2
	mov di,ax
	or di,di
	jnz short _1275
	sub ax,ax
	jmp short _1277
_1275:
	mov ax,si
_1277:
	pop bp
	pop di
	pop si
	ret

_127B:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x8
	mov ax,[0x967]
	mov [bp-0x2],ax
	mov si,0x1
	push word [bp+0x8]
	call _10DC
	add sp,byte +0x2
	mov [0x967],ax
	or ax,ax
	jnz short _12B3
	mov ax,[0x969]
	mov [bp-0x4],ax
	push word [bp+0x8]
	call _1167
	add sp,byte +0x2
	mov [0x967],ax
	mov [bp-0x8],ax
	sub si,si
_12B3:
	cmp word [0x1b52],byte +0x2
	jnz short _12C0
	mov word [0x1b52],0x1
_12C0:
	cmp word [bp+0x8],byte +0x0
	jnz short _12CC
	mov word [0x1b62],0x1
_12CC:
	push word [0x967]
	call _2899
	add sp,byte +0x2
	mov [bp-0x6],ax
	or si,si
	jnz short _12F3
	mov di,[bp-0x4]
	mov word [di],0x0
	call _67E9
	push word [bp-0x8]
	call _1409
	add sp,byte +0x2
	call _6823
_12F3:
	mov ax,[bp-0x2]
	mov [0x967],ax
	mov ax,[bp-0x6]
	mov sp,bp
	pop bp
	pop di
	pop si
	ret

_1302:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov ax,si
	mov di,[0x967]
	mov [di+0x6],ax
	pop bp
	pop di
	pop si
	ret

_1317:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[0x967]
	mov di,[0x967]
	mov ax,[si+0x4]
	mov [di+0x6],ax
	mov ax,[bp+0x8]
	pop bp
	pop di
	pop si
	ret

_1331:
	push si
	push di
	push bp
	mov bp,sp
	mov si,0x95d
	mov di,0x96b
	jmp short _1343
_133E:
	mov si,[si]
	add di,byte +0x4
_1343:
	or si,si
	jz short _1359
	mov al,[si+0x2]
	sub ah,ah
	mov [di],ax
	mov ax,[si+0x6]
	sub ax,[si+0x4]
	mov [di+0x2],ax
	jmp short _133E
_1359:
	mov word [di],0xffff
	mov ax,di
	sub ax,0x96b
	sub dx,dx
	div word [cs:_13A1]
	inc ax
	shl ax,1
	shl ax,1
	pop bp
	pop di
	pop si
	ret
_1372:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov di,0x96b
	jmp short _1382
_137F:
	add di,byte +0x4
_1382:
	cmp word [di],byte -0x1
	jz short _139D
	mov al,[si+0x2]
	sub ah,ah
	mov cx,ax
	mov ax,[di]
	cmp ax,cx
	jnz short _137F
	mov ax,[di+0x2]
	add ax,[si+0x4]
	mov [si+0x6],ax
_139D:
	pop bp
	pop di
	pop si
	ret

_13A1:
	DW	0x4


;------------------------------------------------------------------------------
; Local Alloc Memory
; param 1 = size in bytes
; 13A3
LocalAlloc:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x64
	mov si,[bp+0x8]
	mov cx,[0xa33]
	sub cx,[0xa2d]			; inicialmente = 1ca0
	cmp si,cx
	jna short _13DE
	mov ax,[0xa33]
	sub ax,[0xa2d]
	push ax
	push si
	mov ax,0x9e3
	push ax
	lea ax,[bp-0x64]
	push ax
	call _2337
	add sp,byte +0x8
	lea ax,[bp-0x64]
	push ax
	call _1CAB
	add sp,byte +0x2
	call TerminateProgram
_13DE:
	mov di,[0xa2d]
	add [0xa2d],si
	call _146D
	mov ax,[0xa2d]
	cmp ax,[0xa37]
	jna short _13F5
	mov [0xa37],ax
_13F5:
	mov ax,di
	mov sp,bp
	pop bp
	pop di
	pop si
	ret
_13FD:
	push si
	push di
	push bp
	mov bp,sp
	mov ax,[0xa2d]
	pop bp
	pop di
	pop si
	ret
_1409:
	push si
	push di
	push bp
	mov bp,sp
	mov ax,[bp+0x8]
	mov [0xa2d],ax
	pop bp
	pop di
	pop si
	ret

	push si
	push di
	push bp
	mov bp,sp
	mov ax,[0xa2d]
	mov [0xa35],ax
	pop bp
	pop di
	pop si
	ret

	push si
	push di
	push bp
	mov bp,sp
	cmp word [0xa35],byte +0x0
	jz short _143F
	mov ax,[0xa35]
	mov [0xa2d],ax
	mov word [0xa35],0x0
_143F:
	pop bp
	pop di
	pop si
	ret
_1443:
	push si
	push di
	push bp
	mov bp,sp
	mov ax,[0xa2d]
	mov [0xa31],ax
	pop bp
	pop di
	pop si
	ret
_1452:
	push si
	push di
	push bp
	mov bp,sp
	call _6806
	mov word [0xa35],0x0
	mov ax,[0xa31]
	mov [0xa2d],ax
	call _146D
	pop bp
	pop di
	pop si
	ret

_146D:
	push si
	push di
	push bp
	mov bp,sp
	mov ax,[0xa33]
	sub ax,[0xa2d]
	mov si,ax
	mov ax,si
	mov cl,0x8
	shr ax,cl
	mov [0x11],al
	mov ax,si
	pop bp
	pop di
	pop si
	ret

_148A:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x64
	push word [0x168b]
	mov ax,[0xa37]
	sub ax,[0xa31]
	push ax
	mov ax,[0xa2d]
	sub ax,[0xa31]
	push ax
	mov ax,[0xa33]
	sub ax,[0xa31]
	push ax
	mov ax,0x9ff
	push ax
	lea ax,[bp-0x64]
	push ax
	call _2337
	add sp,byte +0xc
	lea ax,[bp-0x64]
	push ax
	call _1CAB
	add sp,byte +0x2
	mov ax,[bp+0x8]
	mov sp,bp
	pop bp
	pop di
	pop si
	ret
_14CF:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0xc
	sub ax,ax
	mov [0xe],al
	sub ah,ah
	mov [0xd],al
	sub ah,ah
	mov [0xb],al
	mov si,[0x951]
	jmp short _14EF
_14EC:
	add si,byte +0x2b
_14EF:
	mov ax,[0x953]
	cmp ax,si
	ja short _14F9
	jmp _1631
_14F9:
	mov cx,[si+0x25]
	and cx,0x51
	mov ax,cx
	cmp ax,0x51
	jnz short _14EC
	cmp byte [si+0x1],0x0
	jz short _1512
	dec byte [si+0x1]
	jnz short _14EC
_1512:
	mov al,[si]
	mov [si+0x1],al
	mov word [bp-0xc],0x0
	mov ax,[si+0x3]
	mov [bp-0x4],ax
	mov [bp-0x2],ax
	mov ax,[si+0x5]
	mov [bp-0x6],ax
	mov di,ax
	test word [si+0x25],0x400
	jnz short _1560
	mov al,[si+0x21]
	sub ah,ah
	mov [bp-0xa],ax
	mov al,[si+0x1e]
	sub ah,ah
	mov [bp-0x8],ax
	mov bx,[bp-0xa]
	shl bx,1
	imul word [bx+0xa39]
	add [bp-0x2],ax
	mov bx,[bp-0xa]
	shl bx,1
	mov ax,[bp-0x8]
	imul word [bx+0xa4b]
	mov cx,ax
	add di,cx
_1560:
	cmp word [bp-0x2],byte +0x0
	jnl short _1572
	mov word [bp-0x2],0x0
	mov word [bp-0xc],0x4
	jmp short _158D
_1572:
	mov cx,[bp-0x2]
	add cx,[si+0x1a]
	mov ax,cx
	cmp ax,0xa0
	jng short _158D
	mov ax,0xa0
	sub ax,[si+0x1a]
	mov [bp-0x2],ax
	mov word [bp-0xc],0x2
_158D:
	mov cx,di
	sub cx,[si+0x1c]
	mov ax,cx
	cmp ax,0xffff
	jnl short _159F
	mov ax,[si+0x1c]
	dec ax
	jmp short _15BE
_159F:
	cmp di,0xa7
	jng short _15AF
	mov di,0xa7
	mov word [bp-0xc],0x3
	jmp short _15C5
_15AF:
	test word [si+0x25],0x8
	jnz short _15C5
	mov ax,[0x12d]
	cmp ax,di
	jl short _15C5
	inc ax
_15BE:
	mov di,ax
	mov word [bp-0xc],0x1
_15C5:
	mov ax,[bp-0x2]
	mov [si+0x3],ax
	mov [si+0x5],di
	push si
	call _4615
	add sp,byte +0x2
	or ax,ax
	jnz short _15E4
	push si
	call _54D1
	add sp,byte +0x2
	or ax,ax
	jnz short _15FC
_15E4:
	mov ax,[bp-0x4]
	mov [si+0x3],ax
	mov ax,[bp-0x6]
	mov [si+0x5],ax
	mov word [bp-0xc],0x0
	push si
	call _5753
	add sp,byte +0x2
_15FC:
	cmp word [bp-0xc],byte +0x0
	jz short _1629
	cmp byte [si+0x2],0x0
	jnz short _1610
	mov ax,[bp-0xc]
	mov [0xb],al
	jmp short _161C
_1610:
	mov al,[si+0x2]
	mov [0xd],al
	mov ax,[bp-0xc]
	mov [0xe],al
_161C:
	cmp byte [si+0x22],0x3
	jnz short _1629
	push si
	call _167E
	add sp,byte +0x2
_1629:
	and word [si+0x25],0xfbff
	jmp _14EC
_1631:
	mov sp,bp
	pop bp
	pop di
	pop si
	ret
_1637:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov al,[si+0x1e]
	sub ah,ah
	push ax
	mov al,[si+0x28]
	sub ah,ah
	push ax
	mov al,[si+0x27]
	sub ah,ah
	push ax
	push word [si+0x5]
	push word [si+0x3]
	call _16B2
	add sp,byte +0xa
	mov [si+0x21],al
	mov ax,[0x951]
	cmp ax,si
	jnz short _166D
	mov al,[si+0x21]
	mov [0xf],al
_166D:
	cmp byte [si+0x21],0x0
	jnz short _167A
	push si
	call _167E
	add sp,byte +0x2
_167A:
	pop bp
	pop di
	pop si
	ret
_167E:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov al,[si+0x29]
	mov [si+0x1e],al
	mov al,[si+0x2a]
	sub ah,ah
	push ax
	call _7229
	add sp,byte +0x2
	mov byte [si+0x22],0x0
	mov ax,[0x951]
	cmp ax,si
	jnz short _16AE
	mov word [0x139],0x1
	mov byte [0xf],0x0
_16AE:
	pop bp
	pop di
	pop si
	ret
_16B2:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	mov si,[bp+0x10]
	push si
	mov ax,[bp+0xc]
	sub ax,[bp+0x8]
	push ax
	call _16F2
	add sp,byte +0x4
	shl ax,1
	mov [bp-0x2],ax
	push si
	mov ax,[bp+0xe]
	sub ax,[bp+0xa]
	push ax
	call _16F2
	add sp,byte +0x4
	imul word [cs:_171F]
	mov di,ax
	add di,[bp-0x2]
	mov ax,[di+0xa5d]
	mov sp,bp
	pop bp
	pop di
	pop si
	ret
_16F2:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov cx,[bp+0xa]
	neg cx
	mov ax,cx
	cmp ax,si
	jl short _1709
	sub di,di
	jmp short _1718
_1709:
	mov ax,[bp+0xa]
	cmp ax,si
	jg short _1715
	mov di,0x2
	jmp short _1718
_1715:
	mov di,0x1
_1718:
	mov ax,di
	pop bp
	pop di
	pop si
	ret

	DB	0x0
_171F:
	DB	0x6
	DB	0x0

_1721:
	push si
	push di
	push bp
	mov bp,sp
	mov di,[bp+0x8]
	mov al,[di]
	sub ah,ah
	push ax
	call _1757
	add sp,byte +0x2
	pop bp
	pop di
	pop si
	ret

_1738:
	push si
	push di
	push bp
	mov bp,sp
	mov di,[bp+0x8]
	mov al,[di]
	sub ah,ah
	mov di,ax
	mov al,[di+0x9]
	sub ah,ah
	push ax
	call _1757
	add sp,byte +0x2
	pop bp
	pop di
	pop si
	ret

_1757:
	push si
	push di
	push bp
	mov bp,sp
	call _5068
	call _1452
	call _437E
	call _6E11
	call _6E02
	mov si,[0x951]
	jmp short _1774
_1771:
	add si,byte +0x2b
_1774:
	mov ax,[0x953]
	cmp ax,si
	jna short _17AF
	and word [si+0x25],0xffbe
	or word [si+0x25],0x10
	mov word [si+0x10],0x0
	mov word [si+0x8],0x0
	mov word [si+0x14],0x0
	mov ax,0x1
	mov [si],al
	sub ah,ah
	mov [si+0x1],al
	sub ah,ah
	mov [si+0x20],al
	sub ah,ah
	mov [si+0x1f],al
	sub ah,ah
	mov [si+0x1e],al
	jmp short _1771
_17AF:
	call _109D
	mov word [0x139],0x1
	mov word [0x13d],0x0
	mov word [0x12d],0x24
	mov al,[0x9]
	mov [0xa],al
	mov ax,[bp+0x8]
	mov [0x9],al
	sub ax,ax
	mov [0xe],al
	sub ah,ah
	mov [0xd],al
	mov di,[0x951]
	mov al,[di+0x7]
	mov [0x19],al
	push word [bp+0x8]
	call _114A
	add sp,byte +0x2
	cmp word [0x1b54],byte +0x0
	jz short _17FE
	push word [0x1b54]
	call _1167
	add sp,byte +0x2
_17FE:
	mov al,[0xb]
	sub ah,ah
	jmp short _1839
_1805:
	mov di,[0x951]
	mov word [di+0x5],0xa7
	jmp short _1850
_1810:
	mov di,[0x951]
	mov word [di+0x3],0x0
	jmp short _1850
_181B:
	mov di,[0x951]
	mov word [di+0x5],0x25
	jmp short _1850
_1826:
	mov bx,[0x951]
	mov ax,0xa0
	sub ax,[bx+0x1a]
	mov di,[0x951]
	mov [di+0x3],ax
	jmp short _1850
_1839:
	dec ax
	cmp ax,0x3
	ja short _1850
	shl ax,1
	mov bx,ax
	jmp [cs:bx+_1848]
_1848:
	DW	_1805
	DW	_1810
	DW	_181B
	DW	_1826

_1850:
	mov byte [0xb],0x0
	mov ax,0x5
	push ax
	call _7229
	add sp,byte +0x2
	call _4B1F
	call _33ED
	call _3807
	sub ax,ax
	pop bp
	pop di
	pop si
	ret

	DB	0x0
_186F:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x4
	mov si,[bp+0x8]
	sub ax,ax
	push ax
	mov ax,0x14
	push ax
	mov ax,0xc67
	push ax
	call _5945
	add sp,byte +0x6
	sub ax,ax
	push ax
	mov ax,0x14
	push ax
	mov ax,0xc53
	push ax
	call _5945
	add sp,byte +0x6
	push si
	call _1960
	add sp,byte +0x2
	sub di,di
	mov ax,0xc7f
	mov [0xca9],ax
_18AB:
	mov [bp-0x4],ax
	mov bx,[0xca9]
	cmp byte [bx],0x0
	jz short _1903
	cmp di,byte +0xa
	jnl short _1903
	call _1A2E
	mov [bp-0x2],ax
	jmp short _18F5
_18C4:
	mov bx,di
	shl bx,1
	mov ax,[0xca9]
	mov [bx+0xc67],ax
	mov ax,di
	inc ax
	mov [0x12],al
	sub ah,ah
	mov [0xc7b],ax
	jmp short _190B
_18DC:
	mov bx,di
	shl bx,1
	mov ax,[bp-0x2]
	mov [bx+0xc53],ax
	mov bx,di
	inc di
	shl bx,1
	mov ax,[bp-0x4]
	mov [bx+0xc67],ax
	jmp short _18FE
_18F5:
	cmp ax,0xffff
	jz short _18C4
	or ax,ax
	jnz short _18DC
_18FE:
	mov ax,[0xca9]
	jmp short _18AB
_1903:
	or di,di
	jng short _1915
	mov [0xc7b],di
_190B:
	mov ax,0x2
	push ax
	call _7229
	add sp,byte +0x2
_1915:
	mov sp,bp
	pop bp
	pop di
	pop si
	ret

_191B:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov ax,0x2
	push ax
	call _7233
	add sp,byte +0x2
	mov ax,0x4
	push ax
	call _7233
	add sp,byte +0x2
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	mov cx,ax
	mov di,cx
	mov ax,cx
	cmp ax,0xc
	jnl short _195A
	mov ax,di
	imul word [cs:_1BC7]
	add ax,0x20d
	push ax
	call _186F
	add sp,byte +0x2
_195A:
	mov ax,si
	pop bp
	pop di
	pop si
	ret

_1960:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x3
	mov si,[bp+0x8]
	mov word [bp-0x3],0xc7f
_1970:
	mov al,[si]
	mov [bp-0x1],al
	or al,al
	jnz short _197C
	jmp _1A0F
_197C:
	cmp byte [bp-0x1],0x0
	jz short _19B4
	mov al,[bp-0x1]
	sub ah,ah
	push ax
	mov ax,0xc3f
	push ax
	call _4E92
	add sp,byte +0x4
	or ax,ax
	jnz short _19AA
	mov al,[bp-0x1]
	sub ah,ah
	push ax
	mov ax,0xc4d
	push ax
	call _4E92
	add sp,byte +0x4
	or ax,ax
	jz short _19B4
_19AA:
	inc si
	mov di,si
	mov al,[di]
	mov [bp-0x1],al
	jmp short _197C
_19B4:
	cmp byte [bp-0x1],0x0
	jz short _1A0F
_19BA:
	cmp byte [bp-0x1],0x0
	jz short _19FD
	mov al,[bp-0x1]
	sub ah,ah
	push ax
	mov ax,0xc3f
	push ax
	call _4E92
	add sp,byte +0x4
	or ax,ax
	jnz short _19FD
	mov al,[bp-0x1]
	sub ah,ah
	push ax
	mov ax,0xc4d
	push ax
	call _4E92
	add sp,byte +0x4
	or ax,ax
	jnz short _19F3
	mov di,[bp-0x3]
	inc word [bp-0x3]
	mov al,[bp-0x1]
	mov [di],al
_19F3:
	inc si
	mov di,si
	mov al,[di]
	mov [bp-0x1],al
	jmp short _19BA
_19FD:
	cmp byte [bp-0x1],0x0
	jz short _1A0F
	mov di,[bp-0x3]
	inc word [bp-0x3]
	mov byte [di],0x20
	jmp _1970
_1A0F:
	cmp word [bp-0x3],0xc7f
	jna short _1A22
	mov di,[bp-0x3]
	cmp byte [di-0x1],0x20
	jnz short _1A22
	dec word [bp-0x3]
_1A22:
	mov di,[bp-0x3]
	mov byte [di],0x0
	mov sp,bp
	pop bp
	pop di
	pop si
	ret
_1A2E:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0xc
	mov word [bp-0x4],0xffff
	mov word [bp-0x2],0x0
	mov bx,[0xca9]
	mov al,[bx]
	sub ah,ah
	push ax
	call _4E1F
	add sp,byte +0x2
	mov [bp-0x8],ax
	cmp word [bp-0x8],byte +0x61
	jl short _1A5E
	cmp word [bp-0x8],byte +0x7a
	jng short _1A64
_1A5E:
	call _1B8A
	jmp _1B81
_1A64:
	mov bx,[0xca9]
	cmp byte [bx+0x1],0x20
	jz short _1A74
	cmp byte [bx+0x1],0x0
	jnz short _1A99
_1A74:
	cmp word [bp-0x8],byte +0x61
	jz short _1A80
	cmp word [bp-0x8],byte +0x69
	jnz short _1A99
_1A80:
	mov word [bp-0x4],0x0
	mov ax,[0xca9]
	inc ax
	mov [bp-0x2],ax
	mov bx,[0xca9]
	cmp byte [bx+0x1],0x20
	jnz short _1A99
	inc word [bp-0x2]
_1A99:
	mov ax,[bp-0x8]
	sub ax,0x61
	shl ax,1
	mov [bp-0x6],ax
	mov cx,[bp-0x6]
	inc cx
	mov bx,[0xc7d]
	add bx,cx
	mov al,[bx]
	sub ah,ah
	mov dx,ax
	mov bx,[0xc7d]
	add bx,[bp-0x6]
	mov al,[bx]
	sub ah,ah
	mov cl,0x8
	shl ax,cl
	add ax,dx
	mov [bp-0xc],ax
	cmp word [bp-0xc],byte +0x0
	jz short _1A5E
	mov ax,[0xc7d]
	add ax,[bp-0xc]
	mov si,ax
	mov di,[0xca9]
	mov word [bp-0xa],0x0
	jmp short _1AEA
_1AE1:
	push si
	call _1BA7
	add sp,byte +0x2
	mov si,ax
_1AEA:
	mov al,[si]
	sub ah,ah
	mov cx,ax
	mov ax,cx
	cmp ax,[bp-0xa]
	jc short _1B65
	or si,si
	jz short _1B65
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	mov cx,ax
	mov ax,cx
	cmp ax,[bp-0xa]
	jnz short _1B5D
	jmp short _1B0E
_1B0D:
	inc si
_1B0E:
	mov al,[di]
	sub ah,ah
	push ax
	call _4E1F
	add sp,byte +0x2
	mov cx,ax
	xor cx,0x7f
	mov al,[si]
	sub ah,ah
	and ax,0x7f
	cmp ax,cx
	jnz short _1B5D
	inc di
	inc word [bp-0xa]
	test byte [si],0x80
	jz short _1B0D
	cmp byte [di],0x0
	jz short _1B3D
	cmp byte [di],0x20
	jnz short _1B5D
_1B3D:
	mov al,[si+0x2]
	sub ah,ah
	mov bx,ax
	mov al,[si+0x1]
	sub ah,ah
	mov cl,0x8
	shl ax,cl
	add ax,bx
	mov [bp-0x4],ax
	mov [bp-0x2],di
	cmp byte [di],0x0
	jz short _1B5D
	inc word [bp-0x2]
_1B5D:
	cmp byte [di],0x0
	jz short _1B65
	jmp _1AE1
_1B65:
	cmp word [bp-0x2],byte +0x0
	jnz short _1B6E
	jmp _1A5E
_1B6E:
	mov ax,[bp-0x2]
	mov [0xca9],ax
	mov bx,[0xca9]
	cmp byte [bx],0x0
	jz short _1B81
	mov byte [bx-0x1],0x0
_1B81:
	mov ax,[bp-0x4]
	mov sp,bp
	pop bp
	pop di
	pop si
	ret
_1B8A:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[0xca9]
_1B93:
	cmp byte [si],0x20
	jz short _1BA0
	cmp byte [si],0x0
	jz short _1BA0
	inc si
	jmp short _1B93
_1BA0:
	mov byte [si],0x0
	pop bp
	pop di
	pop si
	ret
_1BA7:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
_1BAF:
	test byte [si],0x80
	jnz short _1BB7
	inc si
	jmp short _1BAF
_1BB7:
	cmp byte [si],0x0
	jnz short _1BC0
	sub ax,ax
	jmp short _1BC3
_1BC0:
	lea ax,[si+0x3]
_1BC3:
	pop bp
	pop di
	pop si
	ret

_1BC7:
	DW	0x0028

_1BC9:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov di,si
	inc si
	mov al,[di]
	sub ah,ah
	push ax
	call _21B3
	add sp,byte +0x2
	push ax
	call _1CAB
	add sp,byte +0x2
	mov ax,si
	pop bp
	pop di
	pop si
	ret

_1BEC:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov di,si
	inc si
	mov al,[di]
	sub ah,ah
	mov di,ax
	mov al,[di+0x9]
	sub ah,ah
	push ax
	call _21B3
	add sp,byte +0x2
	push ax
	call _1CAB
	add sp,byte +0x2
	mov ax,si
	pop bp
	pop di
	pop si
	ret

_1C17:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	mov di,ax
	push si
	push di
	call _1C59
	add sp,byte +0x4
	pop bp
	pop di
	pop si
	ret

_1C34:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	mov bx,ax
	mov al,[bx+0x9]
	sub ah,ah
	mov di,ax
	push si
	push di
	call _1C59
	add sp,byte +0x4
	pop bp
	pop di
	pop si
	ret

_1C59:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0xa]
	mov di,si
	inc si
	mov al,[di]
	sub ah,ah
	mov [0xce3],ax
	mov di,si
	inc si
	mov al,[di]
	sub ah,ah
	mov [0xce5],ax
	mov di,si
	inc si
	mov al,[di]
	sub ah,ah
	mov [0xce1],ax
	or ax,ax
	jnz short _1C89
	mov word [0xce1],0x1e
_1C89:
	push word [bp+0x8]
	call _21B3
	add sp,byte +0x2
	push ax
	call _1CAB
	add sp,byte +0x2
	mov ax,0xffff
	mov [0xce5],ax
	mov [0xce3],ax
	mov [0xce1],ax
	mov ax,si
	pop bp
	pop di
	pop si
	ret

_1CAB:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x4
	sub ax,ax
	push ax
	push ax
	push ax
	push word [bp+0x8]
	call _1D59
	add sp,byte +0x8
	mov ax,0xf
	push ax
	call _7247
	add sp,byte +0x2
	or ax,ax
	jz short _1CDE
	mov ax,0xf
	push ax
	call _7233
	add sp,byte +0x2
	mov ax,0x1
	jmp short _1D53
_1CDE:
	cmp byte [0x1e],0x0
	jnz short _1CFC
	call _4514
	mov di,ax
	mov ax,di
	cmp ax,0x1
	jnz short _1CF6
	mov ax,0x1
	jmp short _1CF8
_1CF6:
	sub ax,ax
_1CF8:
	mov si,ax
	jmp short _1D48
_1CFC:
	mov al,[0x1e]
	sub ah,ah
	mul word [cs:_2331]
	mov di,ax
	mov ax,di
	sub dx,dx
	mov bx,ax
	mov cx,dx
	mov ax,[0x129]
	mov dx,[0x12b]
	add ax,bx
	adc dx,cx
	mov [bp-0x4],ax
	mov [bp-0x2],dx
_1D21:
	mov ax,[0x129]
	mov dx,[0x12b]
	cmp dx,[bp-0x2]
	jl short _1D34
	jg short _1D40
	cmp ax,[bp-0x4]
	jnc short _1D40
_1D34:
	call _44EC
	mov di,ax
	mov ax,di
	cmp ax,0xffff
	jz short _1D21
_1D40:
	mov si,0x1
	mov byte [0x1e],0x0
_1D48:
	sub ax,ax
	push ax
	call _1EEE
	add sp,byte +0x2
	mov ax,si
_1D53:
	mov sp,bp
	pop bp
	pop di
	pop si
	ret
_1D59:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,0x2bd
	cmp word [0xcf5],byte +0x0
	jz short _1D72
	sub ax,ax
	push ax
	call _1EEE
	add sp,byte +0x2
_1D72:
	call _76EC
	call _2A69
	mov ax,0xf
	push ax
	sub ax,ax
	push ax
	call _7538
	add sp,byte +0x4
	cmp word [0xce1],byte -0x1
	jnz short _1D99
	cmp word [bp+0xc],byte +0x0
	jnz short _1D99
	mov word [bp+0xc],0x1e
	jmp short _1DA6
_1D99:
	cmp word [0xce1],byte -0x1
	jz short _1DA6
	mov ax,[0xce1]
	mov [bp+0xc],ax
_1DA6:
	push word [bp+0xc]
	push word [bp+0x8]
	lea ax,[bp-0x258]
	push ax
	call _1F17
	add sp,byte +0x6
	cmp word [bp+0xe],byte +0x0
	jz short _1DCF
	mov ax,[bp+0xc]
	mov [0xcf9],ax
	cmp word [bp+0xa],byte +0x0
	jz short _1DCF
	mov ax,[bp+0xa]
	mov [0xcf7],ax
_1DCF:
	mov di,[0xce9]
	add di,byte -0x1
	mov ax,[0xcf7]
	cmp ax,di
	jna short _1E0E
	mov di,[bp+0x8]
	mov al,[di+0x14]
	mov [bp-0x2bd],al
	mov byte [di+0x14],0x0
	push di
	mov ax,0xcab
	push ax
	lea ax,[bp-0x2bc]
	push ax
	call _2337
	add sp,byte +0x6
	mov di,[bp+0x8]
	mov al,[bp-0x2bd]
	mov [di+0x14],al
	lea ax,[bp-0x2bc]
	mov [bp+0x8],ax
	jmp short _1DA6
_1E0E:
	mov di,[0xcf9]
	shl di,1
	shl di,1
	add di,byte +0xa
	mov ax,[0xcf7]
	mul word [0xceb]
	add ax,0xa
	mov cl,0x8
	shl ax,cl
	or ax,di
	mov [0xcfd],ax
	cmp word [0xce3],byte -0x1
	jnz short _1E42
	mov ax,[0xce9]
	add ax,0xffff
	sub ax,[0xcf7]
	shr ax,1
	inc ax
	jmp short _1E45
_1E42:
	mov ax,[0xce3]
_1E45:
	mov [0xcff],ax
	mov ax,[0x5dd]
	add [0xcff],ax
	mov ax,[0xcf7]
	add ax,[0xcff]
	add ax,0xffff
	mov [0xd03],ax
	cmp word [0xce5],byte -0x1
	jnz short _1E6E
	mov ax,0x28
	sub ax,[0xcf9]
	shr ax,1
	jmp short _1E71
_1E6E:
	mov ax,[0xce5]
_1E71:
	mov [0xd01],ax
	mov [0xe28],ax
	mov ax,[0xd01]
	add ax,[0xcf9]
	mov [0xd05],ax
	push word [0xd01]
	push word [0xcff]
	call _2A4E
	add sp,byte +0x4
	mov ax,[0xd03]
	inc ax
	sub ax,[0x5dd]
	mul word [0xceb]
	mov di,ax
	add di,byte +0x4
	mov ax,[0xd01]
	shl ax,1
	shl ax,1
	add ax,0xfffb
	mov cl,0x8
	shl ax,cl
	or ax,di
	mov [0xcfb],ax
	mov ax,0x40f
	push ax
	push word [0xcfd]
	push word [0xcfb]
	call _53C4
	add sp,byte +0x6
	mov word [0xcf5],0x1
	lea ax,[bp-0x258]
	push ax
	call _2353
	add sp,byte +0x2
	mov word [0xe28],0x0
	call _2A90
	call _7726
	mov word [0xce7],0x1
	mov sp,bp
	pop bp
	pop di
	pop si
	ret

_1EEE:
	push si
	push di
	push bp
	mov bp,sp
	cmp word [0xcf5],byte +0x0
	jz short _1F08
	push word [0xcfd]
	push word [0xcfb]
	call _5440
	add sp,byte +0x4
_1F08:
	sub ax,ax
	mov [0xce7],ax
	mov [0xcf5],ax
	mov ax,[bp+0x8]
	pop bp
	pop di
	pop si
	ret
_1F17:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov di,[bp+0xa]
	mov word [0xcef],0x0
	mov ax,[bp+0xc]
	mov [0xcf1],ax
	mov word [0xcf3],0x0
	sub ax,ax
	mov [0xcf9],ax
	mov [0xcf7],ax
	or di,di
	jz short _1F50
	push si
	push di
	call _1F56
	add sp,byte +0x4
	mov di,ax
	mov byte [di],0x0
	call _2311
_1F50:
	mov ax,si
	pop bp
	pop di
	pop si
	ret
_1F56:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0xe
	mov si,[bp+0x8]
	mov di,[bp+0xa]
	mov [bp-0x2],si
_1F67:
	cmp byte [si],0x0
	jnz short _1F6F
	jmp _21AB
_1F6F:
	mov cx,[0xce9]
	add cx,byte -0x1
	mov ax,[0xcf7]
	cmp ax,cx
	jna short _1F80
	jmp _21AB
_1F80:
	mov ax,[0xcef]
	cmp ax,[0xcf1]
	jc short _1F8C
	jmp _2154
_1F8C:
	mov al,[si]
	cmp al,[0xced]
	jnz short _1FA1
	inc si
_1F95:
	mov al,[si]
	mov [di],al
	inc di
	inc si
	inc word [0xcef]
	jmp short _1F80
_1FA1:
	mov al,[si]
	sub ah,ah
	jmp _212E
_1FA8:
	inc si
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	jmp _20E5
	lea ax,[bp-0x8]
	push ax
	push si
	call _22D9
	add sp,byte +0x4
	mov si,ax
	dec word [bp-0x8]
	mov ax,[bp-0x8]
	cmp ax,[0xc7b]
	jnc short _1F80
	push di
	mov bx,[bp-0x8]
	shl bx,1
	push word [bx+0xc67]
_1FD6:
	call _1F56
	add sp,byte +0x4
	mov di,ax
	jmp short _1F80
_1FE0:
	lea ax,[bp-0x8]
	push ax
	push si
	call _22D9
	add sp,byte +0x4
	mov si,ax
	push di
	mov ax,[bp-0x8]
	mul word [cs:_2333]
	add ax,0x20d
_1FF9:
	push ax
	jmp short _1FD6
_1FFC:
	lea ax,[bp-0x8]
	push ax
	push si
	call _22D9
	add sp,byte +0x4
	mov si,ax
	push word [bp-0x8]
	call _21B3
	add sp,byte +0x2
	mov [bp-0x4],ax
	or ax,ax
	jnz short _201C
	jmp _1F80
_201C:
	push di
	jmp short _1FF9
_201F:
	lea ax,[bp-0x8]
	push ax
	push si
	call _22D9
	add sp,byte +0x4
	mov si,ax
	mov ax,[0x967]
	mov [bp-0xc],ax
	sub ax,ax
	push ax
	call _10DC
	add sp,byte +0x2
	mov [0x967],ax
	push word [bp-0x8]
	call _21B3
	add sp,byte +0x2
	mov [bp-0x4],ax
	or ax,ax
	jz short _2058
	push di
	push ax
	call _1F56
	add sp,byte +0x4
	mov di,ax
_2058:
	mov ax,[bp-0xc]
	mov [0x967],ax
	jmp _1F80
_2061:
	mov word [bp-0xa],0x0
	lea ax,[bp-0x8]
	push ax
	push si
	call _22D9
	add sp,byte +0x4
	mov si,ax
	mov bx,[bp-0x8]
	mov al,[bx+0x9]
	sub ah,ah
	push ax
	call _4CFD
	add sp,byte +0x2
	mov [bp-0x6],ax
	cmp byte [si],0x7c
	jnz short _20AA
	lea ax,[bp-0xa]
	push ax
	inc si
	mov ax,si
	push ax
	call _22D9
	add sp,byte +0x4
	mov si,ax
	push word [bp-0xa]
	push word [bp-0x6]
	call _4D3B
	add sp,byte +0x4
	mov [bp-0x6],ax
_20AA:
	push di
	push word [bp-0x6]
	jmp _1FD6
_20B1:
	lea ax,[bp-0x8]
	push ax
	push si
	call _22D9
	add sp,byte +0x4
	mov si,ax
	mov bx,[bp-0x8]
	mov al,[bx+0x9]
	mov [bp-0xe],al
	mov al,[bp-0xe]
	sub ah,ah
	imul word [cs:_2335]
	mov cx,ax
	mov bx,[0x957]
	add bx,cx
	mov ax,[0x957]
	add ax,[bx]
	mov [bp-0x6],ax
	jmp _201C
_20E5:
	sub ax,0x67
	cmp ax,0x10
	jna short _20F0
	jmp _1F80
_20F0:
	shl ax,1
	mov bx,ax
	jmp [cs:bx+_20F9]
_20F9:
	DW	_201F
	DW	_1F80
	DW	_1F80
	DW	_1F80
	DW	_1F80
	DW	_1F80
	DW	_1FFC
	DW	_1F80
	DW	_20B1
	DW	_1F80
	DW	_1F80
	DW	_1F80
	DW	_1FE0
	DW	_1F80
	DW	_1F80
	DW	_2061

_2119:
	mov bl,0x1f
_211B:
	mov al,[si]
	mov [di],al
	inc di
	inc si
	call _2311
	jmp _1F80
_2127:
	mov [0xcf3],di
	jmp _1F95
_212E:
	mov bx,_2144-2
	mov cx,0x4
_2134:
	inc bx
	inc bx
	cmp ax,[cs:bx]
	loopne _2134
	jz short _2140
	jmp _1F95
_2140:
	jmp [cs:bx+0x8]
_2144:
	DW	0x00
	DW	0x0A
	DW	0x20
	DW	0x25
	DW	_21AB
	DW	_211B
	DW	_2127
	DW	_1FA8

_2154:
	cmp word [0xcf3],byte +0x0
	jnz short _2167
	mov bx,di
	inc di
	mov byte [bx],0xa
	call _2311
	jmp _1F67
_2167:
	mov byte [di],0x0
	mov ax,di
	sub ax,[0xcf3]
	sub [0xcef],ax
	call _2311
	mov bx,[0xcf3]
	mov di,bx
	mov byte [bx],0xa
_2180:
	inc di
	mov bx,di
	cmp byte [bx],0x20
	jz short _2180
	push di
	mov ax,[0xcf3]
	inc ax
	push ax
	call _4BE9
	add sp,byte +0x4
	mov di,ax
	mov word [0xcf3],0x0
_219C:
	cmp byte [di],0x0
	jnz short _21A4
	jmp _1F67
_21A4:
	inc di
	inc word [0xcef]
	jmp short _219C
_21AB:
	mov ax,di
	mov sp,bp
	pop bp
	pop di
	pop si
	ret

_21B3:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	mov bx,[0x967]					; struct
	mov al,[bx+0x3]
	sub ah,ah
	mov cx,ax
	mov ax,[bp+0x8]
	cmp ax,cx
	jna short _21D1
	sub ax,ax
	jmp short _220D
_21D1:
	mov bx,[0x967]
	mov si,[bx+0x8]
	mov ax,[bp+0x8]
	shl ax,1
	add ax,si
	mov di,ax
	mov al,[di+0x1]
	sub ah,ah
	mov cl,0x8
	shl ax,cl
	mov cx,ax
	mov al,[di]
	sub ah,ah
	add ax,cx
	mov [bp-0x2],ax
	cmp word [bp-0x2],byte +0x0
	jnz short _2208
	push word [bp+0x8]
	mov ax,0xe
	push ax
	call _3F18
	add sp,byte +0x4
_2208:
	mov ax,[bp-0x2]
	add ax,si
_220D:
	mov sp,bp
	pop bp
	pop di
	pop si
	ret

_2213:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,0x3e8
	mov si,[bp+0x8]
	call _2A69
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	mov di,ax
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	push ax
	push di
	call _2A4E
	add sp,byte +0x4
	mov ax,0x28
	push ax
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	push ax
	call _21B3
	add sp,byte +0x2
	push ax
	lea ax,[bp-0x3e8]
	push ax
	call _1F17
	add sp,byte +0x6
	push ax
	call _2353
	add sp,byte +0x2
	call _2A90
	mov ax,si
	mov sp,bp
	pop bp
	pop di
	pop si
	ret

_226A:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,0x3e8
	mov si,[bp+0x8]
	call _2A69
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	mov bx,ax
	mov al,[bx+0x9]
	sub ah,ah
	mov di,ax
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	mov bx,ax
	mov al,[bx+0x9]
	sub ah,ah
	push ax
	push di
	call _2A4E
	add sp,byte +0x4
	mov ax,0x28
	push ax
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	mov bx,ax
	mov al,[bx+0x9]
	sub ah,ah
	push ax
	call _21B3
	add sp,byte +0x2
	push ax
	lea ax,[bp-0x3e8]
	push ax
	call _1F17
	add sp,byte +0x6
	push ax
	call _2353
	add sp,byte +0x2
	call _2A90
	mov ax,si
	mov sp,bp
	pop bp
	pop di
	pop si
	ret

_22D9:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	sub di,di
_22E3:
	cmp byte [si],0x30
	jc short _2306
	cmp byte [si],0x39
	ja short _2306
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	mov cx,ax
	mov ax,di
	imul word [cs:_2331]
	add ax,cx
	add ax,0xffd0
	mov di,ax
	jmp short _22E3
_2306:
	mov bx,[bp+0xa]
	mov [bx],di
	mov ax,si
	pop bp
	pop di
	pop si
	ret
_2311:
	push si
	push di
	push bp
	mov bp,sp
	inc word [0xcf7]
	mov ax,[0xcef]
	cmp ax,[0xcf9]
	jna short _2326
	mov [0xcf9],ax
_2326:
	mov word [0xcef],0x0
	pop bp
	pop di
	pop si
	ret

	DB	0x0
_2331:
	DB	0xA
	DB	0x0
_2333:
	DB	0x28
	DB	0x0
_2335:
	DB	0x3
	DB	0x0
_2337:
	inc byte [0xd0b]
	pop word [0xd07]
	pop word [0xd09]
	call _2353
	push word [0xd09]
	push word [0xd07]
	dec byte [0xd0b]
	ret
_2353:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	mov si,[bp+0x8]
	mov di,[0xd09]
	mov bx,bp
	add bx,byte +0xa
_2367:
	lodsb
	test al,al
	jz short _23B5
	cmp al,0x25
	jz short _2375
	call _2421
	jmp short _23B3
_2375:
	lodsb
	cmp al,0x73
	jnz short _2380
	call _2407
	jmp short _23B3
_2380:
	cmp al,0x64
	jnz short _238A
	call _23C6
	jmp short _23B3
_238A:
	cmp al,0x75
	jnz short _2394
	call _23E5
	jmp short _23B3
_2394:
	cmp al,0x78
	jnz short _239E
	call _23F6
	jmp short _23B3
_239E:
	cmp al,0x63
	jnz short _23AD
	mov al,[bx]
	add bx,byte +0x2
	call _2421
	jmp short _23B3
_23AD:
	mov al,0x25
	call _2421
	dec si
_23B3:
	jmp short _2367
_23B5:
	test byte [0xd0b],0xff
	jz short _23BF
	xor al,al
	stosb
_23BF:
	add sp,byte +0x2
	pop bp
	pop di
	pop si
	ret
_23C6:
	mov ax,[bx]
	test ax,ax
	jns short _23D5
	push ax
	mov al,0x2d
	call _2421
	pop ax
	neg ax
_23D5:
	push bx
	push ax
	call _4CFD
	add sp,byte +0x2
	pop bx
	call _2410
	add bx,byte +0x2
	ret
_23E5:
	push bx
	push word [bx]
	call _4CFD
	add sp,byte +0x2
	pop bx
	call _2410
	add bx,byte +0x2
	ret
_23F6:
	push bx
	push word [bx]
	call _4D8E
	add sp,byte +0x2
	pop bx
	call _2410
	add bx,byte +0x2
	ret
_2407:
	mov ax,[bx]
	call _2410
	add bx,byte +0x2
	ret
_2410:
	push si
	mov si,ax
_2413:
	lodsb
	test al,al
	jz short _241F
	push si
	call _2421
	pop si
	jmp short _2413
_241F:
	pop si
	ret
_2421:
	test byte [0xd0b],0xff
	jz short _242B
	stosb
	jmp short _2434
_242B:
	push bx
	push ax
	call _2953
	add sp,byte +0x2
	pop bx
_2434:
	ret

_2435:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x4
	call _5068
	call _375E
	mov ax,0x10
	push ax
	call _7247
	add sp,byte +0x2
	or ax,ax
	jz short _2458
	mov word [bp-0x2],0x1
	jmp short _2465
_2458:
	mov ax,0xab3
	push ax
	call _1CAB
	add sp,byte +0x2
	mov [bp-0x2],ax
_2465:
	cmp word [bp-0x2],byte +0x0
	jz short _24BE
	call _3656
	mov ax,0x9
	push ax
	call _7247
	add sp,byte +0x2
	mov [bp-0x4],ax
	call _1452
	call _F72
	call _3006
	mov ax,0x6
	push ax
	call _7229
	add sp,byte +0x2
	cmp word [bp-0x4],byte +0x0
	jz short _249E
	mov ax,0x9
	push ax
	call _7229
	add sp,byte +0x2
_249E:
	mov word [0x129],0x0
	mov word [0x12b],0x0
	cmp word [0x1b54],byte +0x0
	jz short _24BB
	push word [0x1b54]
	call _1167
	add sp,byte +0x2
_24BB:
	call _8E8C
_24BE:
	call _3727
	cmp word [bp-0x2],byte +0x0
	jz short _24CB
	sub ax,ax
	jmp short _24CE
_24CB:
	mov ax,[bp+0x8]
_24CE:
	mov sp,bp
	pop bp
	pop di
	pop si
	ret

	DB	0x0

_24D5:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,0xcf
	mov word [0x613],0x1
	mov ax,[bp+0x8]
	mov [bp-0xce],ax
	mov al,[0xced]
	mov [bp-0xcf],al
	mov byte [0xced],0x40
	mov ax,0x72
	push ax
	call _827F
	add sp,byte +0x2
	mov [bp-0x2],ax
	or ax,ax
	jnz short _250B
	jmp _2629
_250B:
	mov ax,0xc11
	push ax
	mov ax,0x1ace
	push ax
	mov ax,0x1aae
	push ax
	mov ax,0xd0c
	push ax
	lea ax,[bp-0xca]
	push ax
	call _2337
	add sp,byte +0xa
	sub ax,ax
	push ax
	mov ax,0x23
	push ax
	sub ax,ax
	push ax
	lea ax,[bp-0xca]
	push ax
	call _1D59
	add sp,byte +0x8
	call _4514
	or ax,ax
	jnz short _2545
	jmp _2629
_2545:
	sub ax,ax
	push ax
	mov ax,0x1ace
	push ax
	call FileOpen
	add sp,byte +0x4
	mov di,ax
	mov [bp-0xcc],di
	mov ax,di
	cmp ax,0xffff
	jnz short _2580
	mov ax,0x1ace
	push ax
	mov ax,0xd4b
	push ax
	lea ax,[bp-0xca]
	push ax
	call _2337
	add sp,byte +0x6
	lea ax,[bp-0xca]
	push ax
	call _1CAB
	add sp,byte +0x2
	jmp _2629
_2580:
	sub ax,ax
	push ax
	push ax
	mov ax,0x1f
	push ax
	push word [bp-0xcc]
	call _5B84
	add sp,byte +0x8
	mov ax,0x2
	push ax
	push word [bp-0xcc]
	call _2643
	add sp,byte +0x4
	or ax,ax
	jz short _25EC
	push word [0x951]
	push word [bp-0xcc]
	call _2643
	add sp,byte +0x4
	or ax,ax
	jz short _25EC
	push word [0x957]
	push word [bp-0xcc]
	call _2643
	add sp,byte +0x4
	or ax,ax
	jz short _25EC
	push word [0x1683]
	push word [bp-0xcc]
	call _2643
	add sp,byte +0x4
	or ax,ax
	jz short _25EC
	mov ax,0x96b
	push ax
	push word [bp-0xcc]
	call _2643
	add sp,byte +0x4
	or ax,ax
	jnz short _2603
_25EC:
	push word [bp-0xcc]
	call FileClose
	add sp,byte +0x2
	mov ax,0xd5f
	push ax
	call _1CAB
	add sp,byte +0x2
	call TerminateProgram
_2603:
	push word [bp-0xcc]
	call FileClose
	add sp,byte +0x2
	call _65B1
	call _4B1F
	mov ax,0xc
	push ax
	call _7229
	add sp,byte +0x2
	call _3006
	mov word [bp-0xce],0x0
	call _8E8C
_2629:
	call _1EEE
	mov al,[bp-0xcf]
	mov [0xced],al
	mov word [0x613],0x0
	mov ax,[bp-0xce]
	mov sp,bp
	pop bp
	pop di
	pop si
	ret
_2643:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x3
	mov ax,0x1
	push ax
	lea ax,[bp-0x3]
	push ax
	push word [bp+0x8]
	call _5B08
	add sp,byte +0x6
	mov di,ax
	mov ax,di
	cmp ax,0x1
	jnz short _26B0
	mov al,[bp-0x3]
	sub ah,ah
	mov [bp-0x2],ax
	mov ax,0x1
	push ax
	lea ax,[bp-0x3]
	push ax
	push word [bp+0x8]
	call _5B08
	add sp,byte +0x6
	mov di,ax
	mov ax,di
	cmp ax,0x1
	jnz short _26B0
	mov al,[bp-0x3]
	sub ah,ah
	mov cl,0x8
	shl ax,cl
	add [bp-0x2],ax
	push word [bp-0x2]
	push word [bp+0xa]
	push word [bp+0x8]
	call _5B08
	add sp,byte +0x6
	mov di,ax
	mov ax,di
	cmp ax,[bp-0x2]
	jnz short _26B0
	mov ax,0x1
	jmp short _26B2
_26B0:
	sub ax,ax
_26B2:
	mov sp,bp
	pop bp
	pop di
	pop si
	ret

	DB	0x0

_26B9:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,0xcd
	mov word [0x613],0x1
	mov al,[0xced]
	mov [bp-0xcd],al
	mov byte [0xced],0x40
	mov ax,0x73
	push ax
	call _827F
	add sp,byte +0x2
	mov [bp-0x2],ax
	or ax,ax
	jnz short _26E8
	jmp _280C
_26E8:
	mov ax,0xc11
	push ax
	mov ax,0x1ace
	push ax
	mov ax,0x1aae
	push ax
	mov ax,0xd8e
	push ax
	lea ax,[bp-0xca]
	push ax
	call _2337
	add sp,byte +0xa
	sub ax,ax
	push ax
	mov ax,0x23
	push ax
	sub ax,ax
	push ax
	lea ax,[bp-0xca]
	push ax
	call _1D59
	add sp,byte +0x8
	call _4514
	or ax,ax
	jnz short _2722
	jmp _280C
_2722:
	sub ax,ax
	push ax
	mov ax,0x1ace
	push ax
	call _5AC6
	add sp,byte +0x4
	mov di,ax
	mov [bp-0xcc],di
	mov ax,di
	cmp ax,0xffff
	jnz short _275A
	mov ax,0x17a4
	push ax
	mov ax,0xdc8
	push ax
	lea ax,[bp-0xca]
	push ax
	call _2337
	add sp,byte +0x6
	lea ax,[bp-0xca]
_2753:
	push ax
	call _1CAB
	jmp _2809
_275A:
	mov ax,0x1f
	push ax
	mov ax,0x1aae
	push ax
	push word [bp-0xcc]
	call _5B2B
	add sp,byte +0x6
	mov di,ax
	mov ax,di
	cmp ax,0x1f
	jnz short _27E8
	mov ax,0x5e1
	sub ax,0x2
	push ax
	mov ax,0x2
	push ax
	push word [bp-0xcc]
	call _2825
	add sp,byte +0x6
	or ax,ax
	jz short _27E8
	push word [0x955]
	push word [0x951]
	push word [bp-0xcc]
	call _2825
	add sp,byte +0x6
	or ax,ax
	jz short _27E8
	push word [0x95b]
	push word [0x957]
	push word [bp-0xcc]
	call _2825
	add sp,byte +0x6
	or ax,ax
	jz short _27E8
	mov ax,[0x141]
	shl ax,1
	push ax
	push word [0x1683]
	push word [bp-0xcc]
	call _2825
	add sp,byte +0x6
	or ax,ax
	jz short _27E8
	call _1331
	push ax
	mov ax,0x96b
	push ax
	push word [bp-0xcc]
	call _2825
	add sp,byte +0x6
	or ax,ax
	jnz short _2802
_27E8:
	push word [bp-0xcc]
	call FileClose
	add sp,byte +0x2
	mov ax,0x1ace
	push ax
	call _5B4E
	add sp,byte +0x2
	mov ax,0xdfc
	jmp _2753
_2802:
	push word [bp-0xcc]
	call FileClose
_2809:
	add sp,byte +0x2
_280C:
	call _1EEE
	mov al,[bp-0xcd]
	mov [0xced],al
	mov word [0x613],0x0
	mov ax,[bp+0x8]
	mov sp,bp
	pop bp
	pop di
	pop si
	ret
_2825:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x1
	mov ax,[bp+0xc]
	and ax,0xff
	mov [bp-0x1],al
	mov ax,0x1
	push ax
	lea ax,[bp-0x1]
	push ax
	push word [bp+0x8]
	call _5B2B
	add sp,byte +0x6
	mov di,ax
	mov ax,di
	cmp ax,0x1
	jnz short _2891
	mov ax,[bp+0xc]
	mov cl,0x8
	shr ax,cl
	mov [bp-0x1],al
	mov ax,0x1
	push ax
	lea ax,[bp-0x1]
	push ax
	push word [bp+0x8]
	call _5B2B
	add sp,byte +0x6
	mov di,ax
	mov ax,di
	cmp ax,0x1
	jnz short _2891
	push word [bp+0xc]
	push word [bp+0xa]
	push word [bp+0x8]
	call _5B2B
	add sp,byte +0x6
	mov di,ax
	mov ax,di
	cmp ax,[bp+0xc]
	jnz short _2891
	mov ax,0x1
	jmp short _2893
_2891:
	sub ax,ax
_2893:
	mov sp,bp
	pop bp
	pop di
	pop si
	ret

;------------------------------------------------------------------------------
_2899:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	mov si,[bp+0x8]
	mov si,[si+0x6]
_28A7:
	lodsb
_28A8:
	test al,al
	jz short _28C0
	cmp al,0xff
	jz short _28C9
	cmp al,0xfe
	jnz short _28B9
	lodsw
	add si,ax
	jmp short _28A7
_28B9:
	call _291
	test si,si
	jnz short _28A8
_28C0:
	mov ax,si
	add sp,byte +0x2
	pop bp
	pop di
	pop si
	ret
_28C9:
	xor bx,bx
_28CB:
	lodsb
	cmp al,0xfc
	jc short _28EC
	jnz short _28DA
	test bh,bh
	jnz short _2927
	inc bh
	jmp short _28CB
_28DA:
	cmp al,0xff
	jnz short _28E3
	add si,byte +0x2
	jmp short _28A7
_28E3:
	cmp al,0xfd
	jnz short _28EC
	xor bl,0x1
	jmp short _28CB
_28EC:
	push bx
	call _7B0
	pop bx
	xor al,bl
	mov bl,0x0
	jnz short _28FD
	test bh,bh
	jz short _2927
	jmp short _28CB
_28FD:
	test bh,bh
	jz short _2925
	xor bh,bh
	xor ah,ah
_2905:
	lodsb
	cmp al,0xfc
	jz short _2925
	ja short _2905
	cmp al,0xe
	jnz short _2917
	lodsb
	shl ax,1
	add si,ax
	jmp short _2905
_2917:
	mov di,ax
	shl di,1
	shl di,1
	mov al,[di+0x8e5]
	add si,ax
	jmp short _2905
_2925:
	jmp short _28CB
_2927:
	xor bh,bh
	xor ah,ah
_292B:
	lodsb
	cmp al,0xff
	jz short _294D
	cmp al,0xfc
	jnc short _292B
	cmp al,0xe
	jnz short _293F
	lodsb
	shl ax,1
	add si,ax
	jmp short _292B
_293F:
	mov bl,al
	shl bx,1
	shl bx,1
	mov al,[bx+0x8e5]
	add si,ax
	jmp short _292B
_294D:
	lodsw
	add si,ax
	jmp _28A7
_2953:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	xor bh,bh
	mov al,[bp+0x8]
	cmp al,0x8
	jnz short _2991
	mov ah,0x3
	int 0x10
	cmp dl,0x0
	jz short _2971
	dec dl
	jmp short _297A
_2971:
	cmp dh,0x15
	jna short _297A
	mov dl,0x27
	dec dh
_297A:
	push dx
	xor al,al
	mov cx,dx
	mov bh,[0x5cf]
	mov ah,0x6
	int 0x10
	pop dx
	xor bh,bh
	mov ah,0x2
	int 0x10
	jmp _2A47
_2991:
	cmp al,0xd
	jz short _2997
	cmp al,0xa
_2997:
	jnz short _29AF
	mov ah,0x3
	int 0x10
	cmp dh,0x18
	jnc short _29A4
	inc dh
_29A4:
	mov dl,[0xe28]
	mov ah,0x2
	int 0x10
	jmp _2A47
_29AF:
	mov ah,0x3
	int 0x10
	push dx
	mov bl,[0x5d1]
	mov al,[bp+0x8]
	cmp word [0x10c6],byte +0x2
	jz short _2A0F
	cmp word [0x16d3],byte +0x0
	jnz short _2A0F
	test word [0x5d1],0x80
	jz short _29D7
	call _2B67
	mov [bp+0x8],al
_29D7:
	cmp word [0xe3a],byte +0x0
	jz short _29E4
	call _2B76
	mov [bp+0x8],al
_29E4:
	cmp word [0x10c6],byte +0x3
	jnz short _2A0C
	push ds
	xor cx,cx
	mov ds,cx
	mov si,0x10c
	mov di,0xe36
	movsw
	movsw
	cmp al,0x80
	jnz short _2A0B
	mov si,0x10c
	mov cx,0xe3c
	sub cx,0x400
	mov [si],cx
	mov [si+0x2],es
_2A0B:
	pop ds
_2A0C:
	and bl,0x7f
_2A0F:
	mov cx,0x1
	mov ah,0x9
	int 0x10
	pop dx
	inc dl
	cmp dl,0x27
	ja short _2A24
	mov ah,0x2
	int 0x10
	jmp short _2A32
_2A24:
	mov word [bp-0x2],0xd
	push word [bp-0x2]
	call _2953
	add sp,byte +0x2
_2A32:
	cmp word [0x10c6],byte +0x3
	jnz short _2A47
	push es
	xor cx,cx
	mov es,cx
	mov si,0xe36
	mov di,0x10c
	movsw
	movsw
	pop es
_2A47:
	add sp,byte +0x2
	pop bp
	pop di
	pop si
	ret

_2A4E:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	mov dh,[bp+0x8]
	mov dl,[bp+0xa]
	xor bh,bh
	mov ah,0x2
	int 0x10
	add sp,byte +0x2
	pop bp
	pop di
	pop si
	ret
_2A69:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	xor bh,bh
	mov ah,0x3
	int 0x10
	mov bx,[0xe34]
	cmp bx,byte +0xa
	jnc short _2A89
	mov [bx+0xe2a],dx
	add word [0xe34],byte +0x2
_2A89:
	add sp,byte +0x2
	pop bp
	pop di
	pop si
	ret
_2A90:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	mov bx,[0xe34]
	cmp bx,byte +0x0
	jna short _2AB2
	sub bx,byte +0x2
	mov [0xe34],bx
	mov dx,[bx+0xe2a]
	xor bh,bh
	mov ah,0x2
	int 0x10
_2AB2:
	add sp,byte +0x2
	pop bp
	pop di
	pop si
	ret
_2AB9:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	push word [bp+0xc]
	mov word [bp-0x2],0x27
	push word [bp-0x2]
	push word [bp+0xa]
	mov word [bp-0x2],0x0
	push word [bp-0x2]
	push word [bp+0x8]
	call _2B05
	add sp,byte +0xa
	add sp,byte +0x2
	pop bp
	pop di
	pop si
	ret
_2AE7:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	push word [bp+0xa]
	push word [bp+0x8]
	push word [bp+0x8]
	call _2AB9
	add sp,byte +0x6
	add sp,byte +0x2
	pop bp
	pop di
	pop si
	ret
_2B05:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	xor bh,bh
	mov ah,0x3
	int 0x10
	push dx
	xor al,al
	mov ch,[bp+0x8]
	mov cl,[bp+0xa]
	mov dh,[bp+0xc]
	mov dl,[bp+0xe]
	mov bh,[bp+0x10]
	mov ah,0x6
	int 0x10
	pop dx
	xor bh,bh
	mov ah,0x2
	int 0x10
	add sp,byte +0x2
	pop bp
	pop di
	pop si
	ret
_2B37:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	mov al,0x1
	mov ch,[bp+0x8]
	mov cl,[bp+0xa]
	mov dh,[bp+0xc]
	mov dl,[bp+0xe]
	mov bh,[bp+0x10]
	mov ah,0x6
	int 0x10
	mov dh,[bp+0xc]
	mov dl,[bp+0xa]
	xor bh,bh
	mov ah,0x2
	int 0x10
	add sp,byte +0x2
	pop bp
	pop di
	pop si
	ret
_2B67:
	call _2B85
	mov ax,0xffff
_2B6D:
	xor [di],ax
	inc di
	inc di
	loop _2B6D
	mov al,0x80
	ret
_2B76:
	call _2B85
	mov ax,0xaa55
_2B7C:
	or [di],ax
	inc di
	inc di
	loop _2B7C
	mov al,0x80
	ret
_2B85:
	xor ah,ah
	cmp al,0x80
	jz short _2BA3
	push ds
	mov cx,0xf000
	mov ds,cx
	mov di,0xe3c
	mov si,0xfa6e
	mov cl,0x3
	shl ax,cl
	add si,ax
	mov cx,0x4
	rep movsw
	pop ds
_2BA3:
	mov di,0xe3c
	mov cx,0x4
	ret

_2BAA:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov di,si
	inc si
	mov al,[di]
	mov [0xe44],al
	mov di,si
	inc si
	mov al,[di]
	mov [0xe45],al
	mov di,si
	inc si
	mov al,[di]
	mov [0xe46],al
	mov di,si
	inc si
	mov al,[di]
	mov [0xe47],al
	mov di,si
	inc si
	mov al,[di]
	mov [0xe48],al
	mov di,si
	inc si
	mov al,[di]
	mov [0xe49],al
	mov di,si
	inc si
	mov al,[di]
	sub ah,ah
	mov cl,0x4
	shl ax,cl
	or [0xe49],al
	call _2C82
	mov ax,si
	pop bp
	pop di
	pop si
	ret

_2BFA:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	mov di,ax
	mov al,[di+0x9]
	mov [0xe44],al
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	mov di,ax
	mov al,[di+0x9]
	mov [0xe45],al
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	mov di,ax
	mov al,[di+0x9]
	mov [0xe46],al
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	mov di,ax
	mov al,[di+0x9]
	mov [0xe47],al
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	mov di,ax
	mov al,[di+0x9]
	mov [0xe48],al
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	mov di,ax
	mov al,[di+0x9]
	mov [0xe49],al
	mov di,si
	inc si
	mov al,[di]
	sub ah,ah
	mov di,ax
	mov al,[di+0x9]
	sub ah,ah
	mov cl,0x4
	shl ax,cl
	or [0xe49],al
	call _2C82
	mov ax,si
	pop bp
	pop di
	pop si
	ret
_2C82:
	push si
	push di
	push bp
	mov bp,sp
	sub ax,ax
	push ax
	mov ax,0x5
	push ax
	call _6E46
	add sp,byte +0x4
	mov al,[0xe45]
	sub ah,ah
	push ax
	mov al,[0xe44]
	sub ah,ah
	push ax
	call _6E46
	add sp,byte +0x4
	mov al,[0xe47]
	sub ah,ah
	push ax
	mov al,[0xe46]
	sub ah,ah
	push ax
	call _6E46
	add sp,byte +0x4
	mov al,[0xe49]
	sub ah,ah
	push ax
	mov al,[0xe48]
	sub ah,ah
	push ax
	call _6E46
	add sp,byte +0x4
	mov al,[0xe44]
	sub ah,ah
	push ax
	mov ax,0xe4a
	push ax
	call _3A17
	add sp,byte +0x4
	mov al,[0xe45]
	sub ah,ah
	push ax
	mov ax,0xe4a
	push ax
	call _3AE7
	add sp,byte +0x4
	mov al,[0xe46]
	sub ah,ah
	push ax
	mov ax,0xe4a
	push ax
	call _3BFB
	add sp,byte +0x4
	mov ax,[0xe5a]
	mov [0xe5c],ax
	mov al,[0xe47]
	sub ah,ah
	mov [0xe60],ax
	mov [0xe4d],ax
	mov al,[0xe48]
	sub ah,ah
	mov [0xe62],ax
	mov [0xe4f],ax
	mov word [0xe6f],0x20c
	mov byte [0xe6e],0xf
	mov ax,0xe4a
	push ax
	call _5753
	add sp,byte +0x2
	mov al,[0xe49]
	sub ah,ah
	mov di,ax
	test di,0xf
	jnz short _2D3E
	mov word [0xe6f],0x8
_2D3E:
	mov al,[0xe49]
	mov [0xe6e],al
	call _67E9
	mov ax,0xe4a
	push ax
	call _55E8
	add sp,byte +0x2
	call _6823
	mov ax,0xe4a
	push ax
	call _557B
	add sp,byte +0x2
	pop bp
	pop di
	pop si
	ret
_2D62:
	push si
	push di
	push bp
	mov bp,sp
_2D67:
	push word [bp+0xa]
	push word [bp+0x8]
	call _2D86
	add sp,byte +0x4
	mov si,ax
	or ax,ax
	jnz short _2D80
	cmp word [0xe98],byte +0x5
	jnz short _2D67
_2D80:
	mov ax,si
	pop bp
	pop di
	pop si
	ret

_2D86:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x17
	call _13FD
	mov [bp-0xa],ax
	cmp word [0xe9a],byte -0x1
	jnz short _2D9E
	call _2FB0
_2D9E:
	mov di,[bp+0x8]
	mov al,[di]
	sub ah,ah
	mov cl,0x4
	shr ax,cl
	mov [bp-0x8],ax
	cmp word [bp-0x8],byte +0x0
	jz short _2DB5
	mov [0xeb2],ax
_2DB5:
	cmp word [0xeb2],byte +0x0
	jnz short _2DC2
	mov word [0xeb2],0x1
_2DC2:
	mov si,[bp-0x8]
	shl si,1
	mov di,[si+0xe9a]
	mov [bp-0x6],di
	mov ax,di
	cmp ax,0xffff
	jnz short _2DED
	call _3006
	mov word [0xe98],0x1
	push word [bp-0x8]
	call _2F21
	add sp,byte +0x2
_2DE7:
	call _2FB0
	jmp _2F10
_2DED:
	mov di,[bp+0x8]
	mov al,[di+0x2]
	sub ah,ah
	cwd
	mov [bp-0x17],ax
	mov [bp-0x15],dx
	mov si,[bp+0x8]
	mov al,[si+0x1]
	sub ah,ah
	mov di,ax
	mov cl,0x8
	shl di,cl
	mov ax,di
	sub dx,dx
	mov [bp-0x13],ax
	mov [bp-0x11],dx
	mov al,[si]
	sub ah,ah
	mov di,ax
	and di,0xf
	mov ax,di
	sub dx,dx
	mov cx,0x10
_2E25:
	shl ax,1
	rcl dx,1
	loop _2E25
	add ax,[bp-0x13]
	adc dx,[bp-0x11]
	add ax,[bp-0x17]
	adc dx,[bp-0x15]
	mov [bp-0x4],ax
	mov [bp-0x2],dx
	sub ax,ax
	push ax
	push dx
	push word [bp-0x4]
	push word [bp-0x6]
	call _5B84
	add sp,byte +0x8
	mov ax,0x5
	push ax
	lea ax,[bp-0xf]
	push ax
	push word [bp-0x6]
	call _5B08
	add sp,byte +0x6
	mov di,ax
	mov ax,di
	cmp ax,0x5
	jz short _2E6A
	jmp _2F06
_2E6A:
	cmp byte [bp-0xf],0x12
	jnz short _2E84
	cmp byte [bp-0xe],0x34
	jnz short _2E84
	mov al,[bp-0xd]
	sub ah,ah
	mov di,ax
	mov ax,di
	cmp ax,[bp-0x8]
	jz short _2EA3
_2E84:
	call _3006
	mov word [0xe98],0x1
	push word [bp-0x8]
	call _2F6B
	add sp,byte +0x2
	or ax,ax
	jz short _2E9D
	jmp _2DE7
_2E9D:
	call TerminateProgram
	jmp _2DE7
_2EA3:
	mov al,[bp-0xb]
	sub ah,ah
	mov di,ax
	mov cl,0x8
	shl di,cl
	mov al,[bp-0xc]
	sub ah,ah
	add ax,di
	mov [0xeb0],ax
	cmp word [bp+0xa],byte +0x0
	jnz short _2EE7
	cmp word [0xeae],byte +0x0
	jz short _2EDA
	call _146D
	mov di,ax
	mov ax,di
	cmp ax,[0xeb0]
	jnc short _2EDA
	mov word [0xe98],0x5
	jmp short _2F10
_2EDA:
	push word [0xeb0]
	call LocalAlloc
	add sp,byte +0x2
	mov [bp+0xa],ax
_2EE7:
	push word [0xeb0]
	push word [bp+0xa]
	push word [bp-0x6]
	call _5B08
	add sp,byte +0x6
	mov di,ax
	mov ax,di
	cmp ax,[0xeb0]
	jnz short _2F06
	mov ax,[bp+0xa]
	jmp short _2F1B
_2F06:
	call _3F4D
	or ax,ax
	jnz short _2F10
	call TerminateProgram
_2F10:
	push word [bp-0xa]
	call _1409
	add sp,byte +0x2
	sub ax,ax
_2F1B:
	mov sp,bp
	pop bp
	pop di
	pop si
	ret
_2F21:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x64
	push word [bp+0x8]
	lea ax,[bp-0x64]
	push ax
	call _2F46
	add sp,byte +0x4
	lea ax,[bp-0x64]
	push ax
	call _1CAB
	add sp,byte +0x2
	mov sp,bp
	pop bp
	pop di
	pop si
	ret
_2F46:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov di,[bp+0xa]
	or di,di
	jnz short _2F5B
	push word [0xeb2]
	jmp short _2F5C
_2F5B:
	push di
_2F5C:
	mov ax,0xb6f
	push ax
	push si
	call _2337
	add sp,byte +0x6
	pop bp
	pop di
	pop si
	ret
_2F6B:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,0x12c
	call _3EF5
	push word [bp+0x8]
	lea ax,[bp-0x64]
	push ax
	call _2F46
	add sp,byte +0x4
	mov ax,0xa6f
	push ax
	lea ax,[bp-0x64]
	push ax
	mov ax,0xbcb
	push ax
	mov ax,0xe76
	push ax
	lea ax,[bp-0x12c]
	push ax
	call _2337
	add sp,byte +0xa
	lea ax,[bp-0x12c]
	push ax
	call _1CAB
	add sp,byte +0x2
	mov sp,bp
	pop bp
	pop di
	pop si
	ret
_2FB0:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0xa
	sub si,si
	jmp short _2FBD
_2FBC:
	inc si
_2FBD:
	cmp si,byte +0x5
	jnl short _3000
	push si
	mov ax,0xe7e
	push ax
	lea ax,[bp-0xa]
	push ax
	call _2337
	add sp,byte +0x6
_2FD1:
	mov di,si
	shl di,1
	sub ax,ax
	push ax
	lea ax,[bp-0xa]
	push ax
	call FileOpen
	add sp,byte +0x4
	mov [di+0xe9a],ax
	cmp word [0x176d],byte +0x0
	jz short _2FF7
	call _3F4D
	or ax,ax
	jnz short _2FF7
	call TerminateProgram
_2FF7:
	cmp word [0x176d],byte +0x0
	jnz short _2FD1
	jmp short _2FBC
_3000:
	mov sp,bp
	pop bp
	pop di
	pop si
	ret

_3006:
	push si
	push di
	push bp
	mov bp,sp
	sub si,si
	jmp short _3010
_300F:
	inc si
_3010:
	cmp si,byte +0x5
	jnl short _303C
	mov di,si
	shl di,1
	mov ax,[di+0xe9a]
	cmp ax,0xffff
	jz short _300F
	mov di,si
	shl di,1
	push word [di+0xe9a]
	call FileClose
	add sp,byte +0x2
	mov di,si
	shl di,1
	mov word [di+0xe9a],0xffff
	jmp short _300F
_303C:
	call _8026
	pop bp
	pop di
	pop si
	ret
_3043:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x68
_304B:
	sub ax,ax
	push ax
	push word [bp+0x8]
	call FileOpen
	add sp,byte +0x4
	mov di,ax
	mov [bp-0x2],di
	mov ax,di
	cmp ax,0xffff
	jnz short _3094
	mov ax,0xa6f
	push ax
	mov ax,0x1088
	push ax
	push word [bp+0x8]
	mov ax,0xe85
	push ax
	lea ax,[bp-0x68]
	push ax
	call _2337
	add sp,byte +0xa
	mov byte [0xced],0x40
	lea ax,[bp-0x68]
	push ax
	call _1CAB
	add sp,byte +0x2
	or ax,ax
	jnz short _304B
	call TerminateProgram
	jmp short _304B
_3094:
	mov ax,0x2
	push ax
	sub ax,ax
	push ax
	push ax
	push word [bp-0x2]
	call _5B84
	add sp,byte +0x8
	mov bx,ax
	mov cx,dx
	mov ax,bx
	mov [bp-0x4],ax
	sub ax,ax
	push ax
	push ax
	push ax
	push word [bp-0x2]
	call _5B84
	add sp,byte +0x8
	mov ax,[bp-0x4]
	mov [0xeb0],ax
	cmp word [bp+0xa],byte +0x0
	jnz short _30D4
	push word [bp-0x4]
	call LocalAlloc
	add sp,byte +0x2
	mov [bp+0xa],ax
_30D4:
	push word [bp-0x4]
	push word [bp+0xa]
	push word [bp-0x2]
	call _5B08
	add sp,byte +0x6
	mov di,ax
	mov ax,di
	cmp ax,[bp-0x4]
	jz short _30F6
	call _3F4D
	or ax,ax
	jnz short _30F6
	call TerminateProgram
_30F6:
	push word [bp-0x2]
	call FileClose
	add sp,byte +0x2
	mov ax,[bp+0xa]
	mov sp,bp
	pop bp
	pop di
	pop si
	ret

_3108:
	push si
	push di
	push bp
	mov bp,sp
	call _375E
	call _76EC
	mov ax,0xf
	push ax
	sub ax,ax
	push ax
	call _7538
	add sp,byte +0x4
	call _742D
	call _3133
	call _7726
	call _762E
	mov ax,[bp+0x8]
	pop bp
	pop di
	pop si
	ret
_3133:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,0x19c
	mov word [bp-0x19a],0x2
	mov word [bp-0x19c],0x0
	lea ax,[bp-0x192]
	mov si,ax
	mov [bp-0x194],ax
	mov ax,[0x957]
	mov [bp-0x2],ax
	mov word [bp-0x198],0x0
	jmp short _3168
_3160:
	add word [bp-0x2],byte +0x3
	inc word [bp-0x198]
_3168:
	mov ax,[bp-0x2]
	cmp ax,[0x959]
	jnc short _31D4
	mov bx,[bp-0x2]
	cmp byte [bx+0x2],0xff
	jnz short _3160
	mov al,[0x22]
	sub ah,ah
	mov cx,ax
	mov ax,[bp-0x198]
	cmp ax,cx
	jnz short _318D
	mov [bp-0x194],si
_318D:
	mov ax,[bp-0x198]
	mov [si],ax
	mov bx,[bp-0x2]
	mov ax,[0x957]
	add ax,[bx]
	mov [si+0x2],ax
	mov ax,[bp-0x19a]
	mov [si+0x4],ax
	test word [bp-0x19c],0x1
	jnz short _31B4
	mov word [si+0x6],0x1
	jmp short _31CB
_31B4:
	inc word [bp-0x19a]
	push word [si+0x2]
	call _4BCE
	add sp,byte +0x2
	mov cx,ax
	mov ax,0x27
	sub ax,cx
	mov [si+0x6],ax
_31CB:
	inc word [bp-0x19c]
	add si,byte +0x8
	jmp short _3160
_31D4:
	cmp word [bp-0x19c],byte +0x0
	jnz short _31F3
	mov word [si],0x0
	mov word [si+0x2],0xeb4
	mov ax,[bp-0x19a]
	mov [si+0x4],ax
	mov word [si+0x6],0x10
	add si,byte +0x8
_31F3:
	lea ax,[si-0x8]
	mov [bp-0x196],ax
	mov si,[bp-0x194]
	push si
	push ax
	lea ax,[bp-0x192]
	push ax
	call _3276
	add sp,byte +0x6
	mov ax,0xd
	push ax
	call _7247
	add sp,byte +0x2
	or ax,ax
	jnz short _321E
	call _4425
	jmp short _3270
_321E:
	call _4425
	mov di,ax
	push di
	call _4530
	add sp,byte +0x2
	mov ax,[di]
	jmp short _3264
_322E:
	mov ax,[di+0x2]
	jmp short _3241
_3233:
	mov ax,[si]
	mov [0x22],al
	jmp short _3270
_323A:
	mov byte [0x22],0xff
	jmp short _3270
_3241:
	cmp ax,0xd
	jz short _3233
	cmp ax,0x1b
	jz short _323A
	jmp short _321E
_324D:
	push word [di+0x2]
	push si
	push word [bp-0x196]
	lea ax,[bp-0x192]
	push ax
	call _332C
	add sp,byte +0x8
	mov si,ax
	jmp short _321E
_3264:
	cmp ax,0x1
	jz short _322E
	cmp ax,0x2
	jz short _324D
	jmp short _321E
_3270:
	mov sp,bp
	pop bp
	pop di
	pop si
	ret
_3276:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0xc]
	mov ax,0xb
	push ax
	sub ax,ax
	push ax
	call _2A4E
	add sp,byte +0x4
	mov ax,0xebc
	push ax
	call _2353
	add sp,byte +0x2
	mov di,[bp+0x8]
	jmp short _329D
_329A:
	add di,byte +0x8
_329D:
	mov ax,[bp+0xa]
	cmp ax,di
	jc short _32E2
	push word [di+0x6]
	push word [di+0x4]
	call _2A4E
	add sp,byte +0x4
	cmp si,di
	jnz short _32CA
	mov ax,0xd
	push ax
	call _7247
	add sp,byte +0x2
	or ax,ax
	jz short _32CA
	sub ax,ax
	push ax
	mov ax,0xf
	jmp short _32D0
_32CA:
	mov ax,0xf
	push ax
	sub ax,ax
_32D0:
	push ax
	call _7538
	add sp,byte +0x4
	push word [di+0x2]
	call _2353
	add sp,byte +0x2
	jmp short _329A
_32E2:
	mov ax,0xf
	push ax
	sub ax,ax
	push ax
	call _7538
	add sp,byte +0x4
	mov ax,0xd
	push ax
	call _7247
	add sp,byte +0x2
	or ax,ax
	jz short _3310
	mov ax,0x2
	push ax
	mov ax,0x18
	push ax
	call _2A4E
	add sp,byte +0x4
	mov ax,0xece
	jmp short _3321
_3310:
	mov ax,0x4
	push ax
	mov ax,0x18
	push ax
	call _2A4E
	add sp,byte +0x4
	mov ax,0xef3
_3321:
	push ax
	call _2353
	add sp,byte +0x2
	pop bp
	pop di
	pop si
	ret
_332C:
	push si
	push di
	push bp
	mov bp,sp
	mov ax,[bp+0xe]
	jmp short _3358
_3336:
	mov ax,[bp+0xc]
	sub ax,0x10
_333C:
	mov si,ax
	jmp short _3375
_3340:
	mov ax,[bp+0xc]
	add ax,0x8
	jmp short _333C
_3348:
	mov ax,[bp+0xc]
	add ax,0x10
	jmp short _333C
_3350:
	mov ax,[bp+0xc]
	sub ax,0x8
	jmp short _333C
_3358:
	dec ax
	cmp ax,0x6
	ja short _3375
	shl ax,1
	mov bx,ax
	jmp [cs:bx+_3367]
_3367:
	DW	_3336
	DW	_3375
	DW	_3340
	DW	_3375
	DW	_3348
	DW	_3375
	DW	_3350

_3375:
	mov ax,[bp+0x8]
	cmp ax,si
	ja short _3383
	mov ax,[bp+0xa]
	cmp ax,si
	jnc short _3386
_3383:
	mov si,[bp+0xc]
_3386:
	push si
	push word [bp+0xc]
	call _3394
	add sp,byte +0x4
	pop bp
	pop di
	pop si
	ret
_3394:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov di,[bp+0xa]
	cmp di,si
	jz short _33E7
	sub ax,ax
	push ax
	mov ax,0xf
	push ax
	call _7538
	add sp,byte +0x4
	push word [di+0x6]
	push word [di+0x4]
	call _2A4E
	add sp,byte +0x4
	push word [di+0x2]
	call _2353
	add sp,byte +0x2
	mov ax,0xf
	push ax
	sub ax,ax
	push ax
	call _7538
	add sp,byte +0x4
	push word [si+0x6]
	push word [si+0x4]
	call _2A4E
	add sp,byte +0x4
	push word [si+0x2]
	call _2353
	add sp,byte +0x2
_33E7:
	mov ax,di
	pop bp
	pop di
	pop si
	ret
_33ED:
	push si
	push di
	push bp
	mov bp,sp
	call _2A69
	call _76EC
	cmp word [0x5d9],byte +0x0
	jz short _346D
	mov ax,0xff
	push ax
	push word [0x5db]
	call _2AE7
	add sp,byte +0x4
	mov ax,0xf
	push ax
	sub ax,ax
	push ax
	call _7538
	add sp,byte +0x4
	mov ax,0x1
	push ax
	push word [0x5db]
	call _2A4E
	add sp,byte +0x4
	mov al,[0x10]
	sub ah,ah
	push ax
	mov al,[0xc]
	sub ah,ah
	push ax
	mov ax,0xf15
	push ax
	call _2353
	add sp,byte +0x6
	mov ax,0x1e
	push ax
	push word [0x5db]
	call _2A4E
	add sp,byte +0x4
	mov ax,0x9
	push ax
	call _7247
	add sp,byte +0x2
	or ax,ax
	jz short _345F
	mov ax,0xf2f
	jmp short _3462
_345F:
	mov ax,0xf33
_3462:
	push ax
	mov ax,0xf26
	push ax
	call _2353
	add sp,byte +0x4
_346D:
	call _7726
	call _2A90
	pop bp
	pop di
	pop si
	ret

_3477:
	push si
	push di
	push bp
	mov bp,sp
	mov word [0x5d9],0x1
	call _33ED
	mov ax,[bp+0x8]
	pop bp
	pop di
	pop si
	ret

_348C:
	push si
	push di
	push bp
	mov bp,sp
	mov word [0x5d9],0x0
	sub ax,ax
	push ax
	push word [0x5db]
	call _2AE7
	add sp,byte +0x4
	mov ax,[bp+0x8]
	pop bp
	pop di
	pop si
	ret

	DB	0x0
_34AC:
	push si
	push di
	push bp
	mov bp,sp
	mov byte [0x1c],0x0
	mov byte [0x12],0x0
	cmp word [0x1b64],byte +0x0
	jz short _34C5
	call _8F4F
_34C5:
	call _43F5
	push ax
	call _4462
	add sp,byte +0x2
	mov si,ax
	or ax,ax
	jnz short _34D8
	jmp _357E
_34D8:
	mov ax,[si]
	jmp _3566
_34DD:
	mov ax,[si+0x2]
	mov [0x1c],al
	cmp word [0x5d3],byte +0x0
	jz short _34C5
	cmp word [0x10c6],byte +0x2
	jnz short _34F7
	cmp word [si+0x2],byte +0xd
	jnz short _3502
_34F7:
	push word [si+0x2]
_34FA:
	call _3582
	add sp,byte +0x2
	jmp short _34C5
_3502:
	mov ax,0x23
	push ax
	mov ax,0x1c70
	push ax
	call _97A2
	add sp,byte +0x4
	mov al,[0x1c]
	sub ah,ah
	push ax
	call _987B
	add sp,byte +0x2
	mov [0x1c],al
	call _98E3
	mov al,[0x1c]
	sub ah,ah
	push ax
	jmp short _34FA
_352A:
	mov bx,[0x951]
	mov al,[bx+0x21]
	sub ah,ah
	mov di,ax
	mov ax,[si+0x2]
	cmp ax,di
	jnz short _3540
	sub ax,ax
	jmp short _3543
_3540:
	mov ax,[si+0x2]
_3543:
	mov [0xf],al
	cmp word [0x139],byte +0x0
	jnz short _3550
	jmp _34C5
_3550:
	mov di,[0x951]
	mov byte [di+0x22],0x0
	jmp _34C5
_355B:
	mov di,[si+0x2]
	mov byte [di+0x11ae],0x1
	jmp _34C5
_3566:
	dec ax
	cmp ax,0x2
	jna short _356F
	jmp _34C5
_356F:
	shl ax,1
	mov bx,ax
	jmp [cs:bx+_3578]
_3578:
	DW	_34DD
	DW	_352A
	DW	_355B

_357E:
	pop bp
	pop di
	pop si
	ret
_3582:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	cmp word [0xce7],byte +0x0
	jz short _3596
	mov di,0x24
	jmp short _35A9
_3596:
	mov ax,0x20d
	push ax
	call _4BCE
	add sp,byte +0x2
	mov cx,ax
	mov ax,0x28
	sub ax,cx
	mov di,ax
_35A9:
	cmp byte [0x5d7],0x0
	jz short _35B1
	dec di
_35B1:
	mov al,[0x21]
	sub ah,ah
	mov cx,ax
	mov ax,cx
	cmp ax,di
	jnc short _35C5
	mov al,[0x21]
	sub ah,ah
	mov di,ax
_35C5:
	call _375E
	mov ax,si
	jmp short _3632
_35CC:
	cmp word [0xf8e],byte +0x0
	jz short _364F
	mov ax,0xf3a
	push ax
	mov ax,0xf64
	push ax
	call _4BE9
	add sp,byte +0x4
	mov ax,0xf3a
	push ax
	call _186F
	add sp,byte +0x2
	mov word [0xf8e],0x0
	mov byte [0xf3a],0x0
	call _3807
	jmp short _364F
_35FB:
	cmp word [0xf8e],byte +0x0
	jz short _364F
	dec word [0xf8e]
_3606:
	mov bx,[0xf8e]
	mov byte [bx+0xf3a],0x0
	push si
	call _2953
	add sp,byte +0x2
	jmp short _364F
_3618:
	cmp di,[0xf8e]
	jna short _364F
	or si,si
	jz short _364F
	mov bx,[0xf8e]
	inc word [0xf8e]
	mov ax,si
	mov [bx+0xf3a],al
	jmp short _3606
_3632:
	sub ax,0x8
	cmp ax,0x5
	ja short _3618
	shl ax,1
	mov bx,ax
	jmp [cs:bx+_3643]
_3643:
	DW	_35FB
	DW	_3618
	DW	_364F
	DW	_3618
	DW	_3618
	DW	_35CC

_364F:
	call _3727
	pop bp
	pop di
	pop si
	ret
_3656:
	push si
	push di
	push bp
	mov bp,sp
	cmp word [0x10c6],byte +0x2
	jnz short _3669
	cmp word [0xce7],byte +0x0
	jz short _367C
_3669:
	cmp word [0xf8e],byte +0x0
	jz short _367C
	mov ax,0x8
	push ax
	call _3582
	add sp,byte +0x2
	jmp short _3669
_367C:
	mov ax,[bp+0x8]
	pop bp
	pop di
	pop si
	ret

_3683:
	push si
	push di
	push bp
	mov bp,sp
	cmp word [0x5d3],byte +0x0
	jz short _36CE
	cmp word [0x10c6],byte +0x2
	jnz short _36CB
	cmp word [0xce7],byte +0x0
	jnz short _36CB
	mov ax,0x23
	push ax
	mov ax,0x1c70
	push ax
	call _97A2
	add sp,byte +0x4
	call _36D5
	sub ax,ax
	push ax
	call _987B
	add sp,byte +0x2
	mov [0x1c],al
	call _98E3
	mov al,[0x1c]
	sub ah,ah
	push ax
	call _3582
	add sp,byte +0x2
	jmp short _36CE
_36CB:
	call _36D5
_36CE:
	mov ax,[bp+0x8]
	pop bp
	pop di
	pop si
	ret
_36D5:
	push si
	push di
	push bp
	mov bp,sp
	mov ax,0xf64
	push ax
	call _4BCE
	add sp,byte +0x2
	mov di,ax
	mov ax,[0xf8e]
	cmp ax,di
	jnl short _3723
	call _375E
_36F0:
	mov si,[0xf8e]
	mov di,[0xf8e]
	mov al,[si+0xf64]
	mov [di+0xf3a],al
	or al,al
	jz short _3717
	inc word [0xf8e]
	mov al,[di+0xf3a]
	sub ah,ah
	push ax
	call _2953
	add sp,byte +0x2
	jmp short _36F0
_3717:
	mov di,[0xf8e]
	mov byte [di+0xf3a],0x0
	call _3727
_3723:
	pop bp
	pop di
	pop si
	ret
_3727:
	push si
	push di
	push bp
	mov bp,sp
	cmp word [0xf38],byte +0x0
	jnz short _375A
	cmp word [0x10c6],byte +0x2
	jnz short _3741
	cmp word [0xce7],byte +0x0
	jz short _375A
_3741:
	mov word [0xf38],0x1
	cmp byte [0x5d7],0x0
	jz short _375A
	mov al,[0x5d7]
	sub ah,ah
	push ax
	call _2953
	add sp,byte +0x2
_375A:
	pop bp
	pop di
	pop si
	ret
_375E:
	push si
	push di
	push bp
	mov bp,sp
	cmp word [0xf38],byte +0x1
	jnz short _378F
	cmp word [0x10c6],byte +0x2
	jnz short _3778
	cmp word [0xce7],byte +0x0
	jz short _378F
_3778:
	mov word [0xf38],0x0
	cmp byte [0x5d7],0x0
	jz short _378F
	mov ax,0x8
	push ax
	call _2953
	add sp,byte +0x2
_378F:
	pop bp
	pop di
	pop si
	ret
_3793:
	push si
	push di
	push bp
	mov bp,sp
	mov ax,[0xf38]
	pop bp
	pop di
	pop si
	ret

_379F:
	push si
	push di
	push bp
	mov bp,sp
	mov word [0x5d3],0x0
	cmp word [0x10c6],byte +0x2
	jz short _37C1
	call _375E
	sub ax,ax
	push ax
	push word [0x5d5]
	call _2AE7
	add sp,byte +0x4
_37C1:
	mov ax,[bp+0x8]
	pop bp
	pop di
	pop si
	ret

_37C8:
	push si
	push di
	push bp
	mov bp,sp
	mov word [0x5d3],0x1
	cmp word [0x10c6],byte +0x2
	jz short _37DD
	call _3807
_37DD:
	mov ax,[bp+0x8]
	pop bp
	pop di
	pop si
	ret

_37E4:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	push ax
	call _21B3
	add sp,byte +0x2
	mov di,ax
	mov al,[di]
	mov [0x5d7],al
	mov ax,si
	pop bp
	pop di
	pop si
	ret
_3807:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,0x190
	cmp word [0x5d3],byte +0x0
	jz short _3863
	cmp word [0x10c6],byte +0x2
	jz short _3863
	call _375E
	push word [0x5cf]
	push word [0x5d5]
	call _2AE7
	add sp,byte +0x4
	sub ax,ax
	push ax
	push word [0x5d5]
	call _2A4E
	add sp,byte +0x4
	mov ax,0x28
	push ax
	mov ax,0x20d
	push ax
	lea ax,[bp-0x190]
	push ax
	call _1F17
	add sp,byte +0x6
	push ax
	call _2353
	add sp,byte +0x2
	mov ax,0xf3a
	push ax
	call _2353
	add sp,byte +0x2
	call _3727
_3863:
	mov sp,bp
	pop bp
	pop di
	pop si
	ret

_3869:
	push si
	push di
	push bp
	mov bp,sp
	mov word [0xce7],0x1
	mov ax,[bp+0x8]
	pop bp
	pop di
	pop si
	ret

_387B:
	push si
	push di
	push bp
	mov bp,sp
	mov word [0xce7],0x0
	mov ax,[bp+0x8]
	pop bp
	pop di
	pop si
	ret

	DB	0x0
_388E:
	push si
	push di
	push bp
	mov bp,sp
	mov word [0xf90],0x0
	pop bp
	pop di
	pop si
	ret
_389D:
	push si
	push di
	push bp
	mov bp,sp
	call _388E
	pop bp
	pop di
	pop si
	ret
_38A9:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	mov si,[bp+0x8]
	mov di,[0xf90]
	mov word [bp-0x2],0xf90
	jmp short _38C4
_38BF:
	mov [bp-0x2],di
	mov di,[di]
_38C4:
	or di,di
	jz short _38D3
	mov al,[di+0x2]
	sub ah,ah
	mov cx,ax
	cmp si,cx
	jnz short _38BF
_38D3:
	mov ax,[bp-0x2]
	mov [0xf96],ax
	mov ax,di
	mov sp,bp
	pop bp
	pop di
	pop si
	ret

_38E1:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	sub ax,ax
	push ax
	mov di,si
	inc si
	mov al,[di]
	sub ah,ah
	push ax
	call _3927
	add sp,byte +0x4
	mov ax,si
	pop bp
	pop di
	pop si
	ret

_3900:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	sub ax,ax
	push ax
	mov di,si
	inc si
	mov al,[di]
	sub ah,ah
	mov di,ax
	mov al,[di+0x9]
	sub ah,ah
	push ax
	call _3927
	add sp,byte +0x4
	mov ax,si
	pop bp
	pop di
	pop si
	ret

_3927:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	push si
	call _38A9
	add sp,byte +0x2
	mov di,ax
	or ax,ax
	jz short _3942
	cmp word [bp+0xa],byte +0x0
	jz short _39A1
_3942:
	call _67E9
	or di,di
	jnz short _3974
	push si
	mov ax,0x1
	push ax
	call _6E46
	add sp,byte +0x4
	mov ax,0x5
	push ax
	call LocalAlloc
	add sp,byte +0x2
	mov di,ax
	mov bx,[0xf96]
	mov [bx],ax
	mov word [di],0x0
	mov ax,si
	mov [di+0x2],al
	mov word [di+0x3],0x0
_3974:
	push word [di+0x3]
	mov al,[di+0x2]
	sub ah,ah
	push ax
	call _42A1
	add sp,byte +0x2
	push ax
	call _2D62
	add sp,byte +0x4
	mov [di+0x3],ax
	or ax,ax
	jnz short _3995
	sub ax,ax
	jmp short _39A3
_3995:
	push word [di+0x3]
	call _5738
	add sp,byte +0x2
	call _6823
_39A1:
	mov ax,di
_39A3:
	pop bp
	pop di
	pop si
	ret

_39A7:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	mov di,ax
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	push ax
	mov ax,di
	imul word [cs:_3E88]
	mov cx,ax
	mov ax,[0x951]
	add ax,cx
	push ax
	call _3A17
	add sp,byte +0x4
	mov ax,si
	pop bp
	pop di
	pop si
	ret

_39DB:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	mov di,ax
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	mov bx,ax
	mov al,[bx+0x9]
	sub ah,ah
	push ax
	mov ax,di
	imul word [cs:_3E88]
	mov cx,ax
	mov ax,[0x951]
	add ax,cx
	push ax
	call _3A17
	add sp,byte +0x4
	mov ax,si
	pop bp
	pop di
	pop si
	ret

_3A17:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x4
	mov si,[bp+0x8]
	mov di,[bp+0xa]
	push di
	call _38A9
	add sp,byte +0x2
	mov [bp-0x4],ax
	or ax,ax
	jnz short _3A3E
	push di
	mov ax,0x3
	push ax
	call _3F18
	add sp,byte +0x4
_3A3E:
	mov bx,[bp-0x4]
	mov ax,[bx+0x3]
	mov [si+0x8],ax
	mov [bp-0x2],ax
	mov ax,di
	mov [si+0x7],al
	mov bx,[bp-0x2]
	mov al,[bx+0x2]
	mov [si+0xb],al
	mov al,[si+0xa]
	cmp al,[si+0xb]
	jc short _3A64
	sub ax,ax
	jmp short _3A69
_3A64:
	mov al,[si+0xa]
	sub ah,ah
_3A69:
	push ax
	push si
	call _3AE7
	add sp,byte +0x4
	mov sp,bp
	pop bp
	pop di
	pop si
	ret

_3A77:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	mov di,ax
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	push ax
	mov ax,di
	imul word [cs:_3E88]
	mov cx,ax
	mov ax,[0x951]
	add ax,cx
	push ax
	call _3AE7
	add sp,byte +0x4
	mov ax,si
	pop bp
	pop di
	pop si
	ret

_3AAB:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	mov di,ax
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	mov bx,ax
	mov al,[bx+0x9]
	sub ah,ah
	push ax
	mov ax,di
	imul word [cs:_3E88]
	mov cx,ax
	mov ax,[0x951]
	add ax,cx
	push ax
	call _3AE7
	add sp,byte +0x4
	mov ax,si
	pop bp
	pop di
	pop si
	ret
_3AE7:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	mov si,[bp+0x8]
	mov di,[bp+0xa]
	mov ax,si
	sub ax,[0x951]
	sub dx,dx
	div word [cs:_3E88]
	mov [bp-0x2],ax
	cmp word [si+0x8],byte +0x0
	jnz short _3B16
	push ax
	mov ax,0x6
	push ax
	call _3F18
	add sp,byte +0x4
_3B16:
	mov al,[si+0xb]
	sub ah,ah
	mov cx,ax
	mov ax,cx
	cmp ax,di
	jnc short _3B30
	push word [bp-0x2]
	mov ax,0x5
	push ax
	call _3F18
	add sp,byte +0x4
_3B30:
	push di
	push si
	call _3B4B
	add sp,byte +0x4
	mov al,[si+0xe]
	sub ah,ah
	push ax
	push si
	call _3BFB
	add sp,byte +0x4
	mov sp,bp
	pop bp
	pop di
	pop si
	ret
_3B4B:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov di,[bp+0xa]
	mov ax,di
	mov [si+0xa],al
	shl ax,1
	mov cx,ax
	mov bx,[si+0x8]
	add bx,cx
	mov ax,[bx+0x5]
	add ax,[si+0x8]
	mov [si+0xc],ax
	mov bx,[si+0xc]
	mov al,[bx]
	mov [si+0xf],al
	mov al,[si+0xe]
	cmp al,[si+0xf]
	jc short _3B81
	mov byte [si+0xe],0x0
_3B81:
	pop bp
	pop di
	pop si
	ret

_3B85:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	imul word [cs:_3E88]
	mov cx,ax
	mov ax,[0x951]
	add ax,cx
	mov di,ax
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	push ax
	push di
	call _3BFB
	add sp,byte +0x4
	and word [di+0x25],0xefff
	mov ax,si
	pop bp
	pop di
	pop si
	ret

_3BBC:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	imul word [cs:_3E88]
	mov cx,ax
	mov ax,[0x951]
	add ax,cx
	mov di,ax
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	mov bx,ax
	mov al,[bx+0x9]
	sub ah,ah
	push ax
	push di
	call _3BFB
	add sp,byte +0x4
	and word [di+0x25],0xefff
	mov ax,si
	pop bp
	pop di
	pop si
	ret

_3BFB:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	mov si,[bp+0x8]
	mov di,[bp+0xa]
	mov ax,si
	sub ax,[0x951]
	sub dx,dx
	div word [cs:_3E88]
	mov [bp-0x2],ax
	cmp word [si+0x8],byte +0x0
	jnz short _3C2A
	push ax
	mov ax,0xa
	push ax
	call _3F18
	add sp,byte +0x4
_3C2A:
	mov al,[si+0xf]
	sub ah,ah
	mov cx,ax
	mov ax,cx
	cmp ax,di
	ja short _3C44
	push word [bp-0x2]
	mov ax,0x8
	push ax
	call _3F18
	add sp,byte +0x4
_3C44:
	push di
	push si
	call _3C9A
	add sp,byte +0x4
	mov cx,[si+0x3]
	add cx,[si+0x1a]
	mov ax,cx
	cmp ax,0xa0
	jng short _3C67
	or word [si+0x25],0x400
	mov ax,0xa0
	sub ax,[si+0x1a]
	mov [si+0x3],ax
_3C67:
	mov cx,[si+0x5]
	sub cx,[si+0x1c]
	mov ax,cx
	cmp ax,0xffff
	jnl short _3C94
	or word [si+0x25],0x400
	mov ax,[si+0x1c]
	dec ax
	mov [si+0x5],ax
	cmp ax,[0x12d]
	jg short _3C94
	test word [si+0x25],0x8
	jnz short _3C94
	mov ax,[0x12d]
	inc ax
	mov [si+0x5],ax
_3C94:
	mov sp,bp
	pop bp
	pop di
	pop si
	ret

_3C9A:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov ax,[bp+0xa]
	mov [si+0xe],al
	shl ax,1
	mov cx,ax
	mov bx,[si+0xc]
	add bx,cx
	mov ax,[bx+0x1]
	add ax,[si+0xc]
	mov [si+0x10],ax
	mov di,ax
	mov al,[di]
	sub ah,ah
	mov [si+0x1a],ax
	mov al,[di+0x1]
	sub ah,ah
	mov [si+0x1c],ax
	pop bp
	pop di
	pop si
	ret

_3CCF:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x4
	mov si,[bp+0x8]
	mov bx,si
	inc si
	mov al,[bx]
	mov [bp-0x4],al
	mov al,[bp-0x4]
	sub ah,ah
	imul word [cs:_3E88]
	mov cx,ax
	mov bx,[0x951]
	add bx,cx
	mov ax,[bx+0xc]
	mov [bp-0x2],ax
	mov bx,[bp-0x2]
	mov al,[bx]
	sub ah,ah
	add ax,0xffff
	mov di,ax
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	mov bx,ax
	mov ax,di
	mov [bx+0x9],al
	mov ax,si
	mov sp,bp
	pop bp
	pop di
	pop si
	ret

_3D1D:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	imul word [cs:_3E88]
	mov cx,ax
	mov bx,[0x951]
	add bx,cx
	mov al,[bx+0xe]
	sub ah,ah
	mov di,ax
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	mov bx,ax
	mov ax,di
	mov [bx+0x9],al
	mov ax,si
	pop bp
	pop di
	pop si
	ret

_3D55:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	imul word [cs:_3E88]
	mov cx,ax
	mov bx,[0x951]
	add bx,cx
	mov al,[bx+0xa]
	sub ah,ah
	mov di,ax
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	mov bx,ax
	mov ax,di
	mov [bx+0x9],al
	mov ax,si
	pop bp
	pop di
	pop si
	ret

_3D8D:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	imul word [cs:_3E88]
	mov cx,ax
	mov bx,[0x951]
	add bx,cx
	mov al,[bx+0x7]
	sub ah,ah
	mov di,ax
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	mov bx,ax
	mov ax,di
	mov [bx+0x9],al
	mov ax,si
	pop bp
	pop di
	pop si
	ret

_3DC5:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	imul word [cs:_3E88]
	mov cx,ax
	mov bx,[0x951]
	add bx,cx
	mov al,[bx+0xb]
	sub ah,ah
	mov di,ax
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	mov bx,ax
	mov ax,di
	mov [bx+0x9],al
	mov ax,si
	pop bp
	pop di
	pop si
	ret

_3DFD:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov di,si
	inc si
	mov al,[di]
	sub ah,ah
	push ax
	call _3E3D
	add sp,byte +0x2
	mov ax,si
	pop bp
	pop di
	pop si
	ret

_3E19:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov di,si
	inc si
	mov al,[di]
	sub ah,ah
	mov di,ax
	mov al,[di+0x9]
	sub ah,ah
	push ax
	call _3E3D
	add sp,byte +0x2
	mov ax,si
	pop bp
	pop di
	pop si
	ret

_3E3D:
	push si
	push di
	push bp
	mov bp,sp
	push word [bp+0x8]
	call _38A9
	add sp,byte +0x2
	mov si,ax
	or ax,ax
	jnz short _3E5E
	push word [bp+0x8]
	mov ax,0x1
	push ax
	call _3F18
	add sp,byte +0x4
_3E5E:
	push word [bp+0x8]
	mov ax,0x7
	push ax
	call _6E46
	add sp,byte +0x4
	mov di,[0xf96]
	mov word [di],0x0
	call _67E9
	push si
	call _1409
	add sp,byte +0x2
	call _6823
	call _146D
	pop bp
	pop di
	pop si
	ret

	DB	0x0

_3E88:
	DW	0x002B

_3E8A:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov al,[si+0x27]
	sub ah,ah
	dec byte [si+0x27]
	or ax,ax
	jz short _3EA5
	test word [si+0x25],0x4000
	jz short _3ECF
_3EA5:
	call _3ED3
	mov [si+0x21],al
	mov ax,[0x951]
	cmp ax,si
	jnz short _3EB8
	mov al,[si+0x21]
	mov [0xf],al
_3EB8:
	cmp byte [si+0x27],0x6
	jnc short _3ECF
	call _6F23
	sub dx,dx
	div word [cs:_3EE8]
	mov ax,dx
	mov [si+0x27],al
	jmp short _3EB8
_3ECF:
	pop bp
	pop di
	pop si
	ret
_3ED3:
	push si
	push di
	push bp
	mov bp,sp
	call _6F23
	sub dx,dx
	div word [cs:_3EEA]
	mov ax,dx
	pop bp
	pop di
	pop si
	ret
_3EE8:
	xor ax,[bx+si]
_3EEA:
	or [bx+si],ax
	mov bx,0x1000
	mov cx,0x8000
	jmp short _3EFD
_3EF5:
	mov bx,0x500
	xor cx,cx
	jmp short _3EFD
_3EFD:
	mov al,0xb6
	out 0x43,al
	mov ax,bx
	out 0x42,al
	mov al,ah
	out 0x42,al
	in al,0x61
	mov ah,al
	or al,0x3
	out 0x61,al
_3F11:
	loop _3F11
	mov al,ah
	out 0x61,al
	ret

;------------------------------------------------------------------------------
; Start hang freeze colgar PC ??????????
_3F18:
	push si
	push di
	push bp
	mov bp,sp
	call _5068
	call _1452
	call _437E
	call _109D
	call _3EF5
	call _3EF5
	mov ax,[bp+0x8]
	mov [0x1a],al
	mov ax,[bp+0xa]
	mov [0x1b],al
	mov ax,0x1
	push ax
	mov ax,0x615
	push ax
	call _7C45
	add sp,byte +0x4
	pop bp
	pop di
	pop si
	ret

_3F4D:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x64
	call _375E
	call _3EF5
	call _3EF5
	mov ax,[0x176d]
	jmp short _3F97
_3F63:
	mov ax,0x102f
_3F66:
	push ax
	lea ax,[bp-0x64]
	push ax
	call _4BE9
	add sp,byte +0x4
	jmp short _3FB6
_3F73:
	mov ax,0x103c
	jmp short _3F66
_3F78:
	mov ax,0x105a
	jmp short _3F66
_3F7D:
	mov di,[0x176d]
	shl di,1
	push word [di+0x10a4]
	mov ax,0x1078
	push ax
	lea ax,[bp-0x64]
	push ax
	call _2337
	add sp,byte +0x6
	jmp short _3FB6
_3F97:
	mov bx,_3FAA-2
	mov cx,0x3
_3F9D:
	inc bx
	inc bx
	cmp ax,[cs:bx]
	loopne _3F9D
	jnz short _3F7D
	jmp [cs:bx+0x6]
_3FAA:
	DW	0
	DW	2
	DW	0x100
	DW	_3F63
	DW	_3F78
	DW	_3F73

_3FB6:
	mov ax,0x1088
	push ax
	lea ax,[bp-0x64]
	push ax
	call _4C5C
	add sp,byte +0x4
	mov ax,0xa6f
	push ax
	lea ax,[bp-0x64]
	push ax
	call _4C5C
	add sp,byte +0x4
	lea ax,[bp-0x64]
	push ax
	call _1CAB
	add sp,byte +0x2
	mov sp,bp
	pop bp
	pop di
	pop si
	ret

;------------------------------------------------------------------------------
;_3FE2:
;	push si
;	push di
;	push bp
;	mov bp,sp
;	sub sp,byte +0x2
;	cmp word [0x10c4],byte -0x1
;	jnz short _3FF4					; no salta (=-1)
;	call _4017
;_3FF4:
;	mov ah,0x0
;	int 0x11						; devuelve AX = D426
;	test ax,0xc0
;	jz short _4003					; si salta
;	mov word [0x10be],0x1
;_4003:
;	cmp word [0x10c6],byte -0x1
;	jnz short _400D					; no salta
;	call _4057
;_400D:
;	call _40C2
;	add sp,byte +0x2
;	pop bp
;	pop di
;	pop si
;	ret

;------------------------------------------------------------------------------
; Verifica si el video es TGA (Tandy Graphics Adapter)
; y otro video mas... supongo
;_4017:
;	mov word [0x10c4],0x0
;	push es
;	mov ax,0xf000
;	mov es,ax
;	mov bl,[es:0xfffe]
;	cmp bl,0xfd
;	jnz short _4036					; si salta
;	mov word [0x10c4],0x1
;	jmp short _4055
;;_4036:
;	mov di,0xc000
;_4039:
;	lea si,[0x10d1]					; "TandyLogic"
;	push di
;	mov cx,0x5
;	repe cmpsb
;	pop di
;	jnz short _404E
;	mov word [0x10c4],0x2
;	jmp short _4055
;_404E:
;	inc di
;	cmp di,0xc400
;	jl short _4039
;_4055:
;	pop es
;	ret

;------------------------------------------------------------------------------
; AX = parametro recibido (de int 0x11)
;_4057:
;	and ax,0x30
;	cmp ax,0x30
;	jnz short _409B				; SI
;	mov dx,0x3ba
;_4062:
;	in al,dx
;	or al,al
;	jns short _4062
;	xor ah,ah
;	int 0x1a
;	add dx,byte +0x2
;	mov ax,dx
;_4070:
;	push ax
;	mov dx,0x3ba
;	in al,dx
;	or al,al
;	js short _407C
;	pop ax
;	jmp short _4093
;_407C:
;	xor ah,ah
;	int 0x1a
;	pop ax
;	cmp ax,dx
;	jnc short _4091
;	call _3EF5
;	add sp,byte +0x0
;	mov al,0x1
;	mov ah,0x4c
;	int 0x21
;_4091:
;	jmp short _4070
;_4093:
;	mov word [0x10c6],0x2
;	jmp short _40C1
;_409B:
;	mov word [0x10c6],0x0
;	xor al,al
;	mov bl,0x10
;	mov bh,0xff
;	mov cl,0xf
;	mov ah,0x12
;	int 0x10					; Verifica algo si es Tandy, supongo
;	cmp cl,0xc
;	jnc short _40C1
;	cmp bl,0x3
;	ja short _40C1
;	or bh,bh
;	jnz short _40C1
;	mov word [0x10c6],0x3
;_40C1:
;	ret

;------------------------------------------------------------------------------
_40C2:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	mov word [0x16d3],0x1
	mov word [bp-0x2],0x0
	push word [bp-0x2]
	mov word [bp-0x2],0xff
	push word [bp-0x2]
	call _7538
	add sp,byte +0x4
	mov bx,[0x1627]
	sub bx,[0x162d]
	mov [0x10c0],bx
	push es
	mov ax,[0x162d]
	mov es,ax
	mov ah,0x4a
	int 0x21
	pop es
	mov bx,0x1000
	add bx, SEG AGIDATA
	sub bx,[0x1627]
	mov [0x10c2],bx
	mov ah,0x48
	int 0x21
	jnc short _4115
	jmp _41E3
_4115:
	sub ax, SEG AGIDATA
	mov cl,0x4
	shl ax,cl
	mov [0xa2d],ax
	mov [0xa2f],ax
	mov ax,[0x10c2]
	mov cl,0x4
	shl ax,cl
	add ax,[0xa2f]
	mov [0xa33],ax
	cmp word [0x10c6],byte +0x2
	jnz short _413C
	mov bx,0xd20
	jmp short _413F
_413C:
	mov bx,0x690
_413F:
	mov ah,0x48
	int 0x21
	jnc short _4148
	jmp _41E3
_4148:
	mov [0x1303],ax
	cmp word [0x10c6],byte +0x2
	jz short _4155
	jmp _41D6
_4155:
	add ax,0x690
	mov [0x1307],ax
	mov bx,0xc0
	mov ah,0x48
	int 0x21
	jnc short _4167
	jmp short _41E3
_4167:
	mov [0x1309],ax
	mov word [bp-0x2],0x0
	push word [bp-0x2]
	push ax
	lea ax,[0x10c8]
	mov [bp-0x2],ax
	pop ax
	push word [bp-0x2]
	call FileOpen
	add sp,byte +0x4
	or ax,ax
	jns short _419D
	push ax
	lea ax,[0xb55]
	mov [bp-0x2],ax
	pop ax
	push word [bp-0x2]
	call _2353
	add sp,byte +0x2
	jmp short _41F5
_419D:
	push ax
	mov word [bp-0x2],0xc00
	push word [bp-0x2]
	push word [0xa2f]
	push ax
	call _5B08
	add sp,byte +0x6
	pop ax
	push ax
	call FileClose
	add sp,byte +0x2
	mov si,[0xa2f]
	push es
	mov es,[0x1309]
	xor di,di
	mov cx,0xc00
	rep movsb
	mov word [0xce9],0x18
	mov word [0xceb],0x7
	pop es
_41D6:
	mov word [0x16d3],0x0
	add sp,byte +0x2
	pop bp
	pop di
	pop si
	ret

_41E3:
	push ax
	lea ax,[0xaf7]
	mov [bp-0x2],ax
	pop ax
	push word [bp-0x2]
	call _2353
	add sp,byte +0x2
_41F5:
	call _3EF5
	add sp,byte +0x0
	mov al,0x1
	mov ah,0x4c
	int 0x21
_4201:
	push si
	push di
	push bp
	mov bp,sp
	sub ax,ax
	push ax
	mov ax,0x1100
	push ax
	call _3043
	add sp,byte +0x4
	mov [0x1148],ax
	sub ax,ax
	push ax
	mov ax,0x1110
	push ax
	call _3043
	add sp,byte +0x4
	mov [0x114c],ax
	sub ax,ax
	push ax
	mov ax,0x1108
	push ax
	call _3043
	add sp,byte +0x4
	mov [0x114a],ax
	sub ax,ax
	push ax
	mov ax,0x1118
	push ax
	call _3043
	add sp,byte +0x4
	mov [0x114e],ax
	pop bp
	pop di
	pop si
	ret

_424A:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov al,[si]
	sub ah,ah
	mov di,ax
	and di,0xf0
	mov ax,di
	cmp ax,0xf0
	jnz short _4267
	sub ax,ax
	jmp short _4269
_4267:
	mov ax,si
_4269:
	pop bp
	pop di
	pop si
	ret

_426D:
	push si
	push di
	push bp
	mov bp,sp
	mov ax,[bp+0x8]
	imul word [cs:_436D]
	mov di,ax
	mov ax,[0x1148]
	add ax,di
	push ax
	call _424A
	add sp,byte +0x2
	mov si,ax
	or ax,ax
	jnz short _429B
	push word [bp+0x8]
	mov ax,0x10d6
	push ax
	call _433D
	add sp,byte +0x4
_429B:
	mov ax,si
	pop bp
	pop di
	pop si
	ret

_42A1:
	push si
	push di
	push bp
	mov bp,sp
	mov ax,[bp+0x8]
	imul word [cs:_436D]
	mov di,ax
	mov ax,[0x114a]
	add ax,di
	push ax
	call _424A
	add sp,byte +0x2
	mov si,ax
	or ax,ax
	jnz short _42CF
	push word [bp+0x8]
	mov ax,0x10dc
	push ax
	call _433D
	add sp,byte +0x4
_42CF:
	mov ax,si
	pop bp
	pop di
	pop si
	ret

_42D5:
	push si
	push di
	push bp
	mov bp,sp
	mov ax,[bp+0x8]
	imul word [cs:_436D]
	mov di,ax
	mov ax,[0x114c]
	add ax,di
	push ax
	call _424A
	add sp,byte +0x2
	mov si,ax
	or ax,ax
	jnz short _4303
	push word [bp+0x8]
	mov ax,0x10e1
	push ax
	call _433D
	add sp,byte +0x4
_4303:
	mov ax,si
	pop bp
	pop di
	pop si
	ret

_4309:
	push si
	push di
	push bp
	mov bp,sp
	mov ax,[bp+0x8]
	imul word [cs:_436D]
	mov di,ax
	mov ax,[0x114e]
	add ax,di
	push ax
	call _424A
	add sp,byte +0x2
	mov si,ax
	or ax,ax
	jnz short _4337
	push word [bp+0x8]
	mov ax,0x10e9
	push ax
	call _433D
	add sp,byte +0x4
_4337:
	mov ax,si
	pop bp
	pop di
	pop si
	ret

_433D:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x64
	push word [bp+0xa]
	push word [bp+0x8]
	mov ax,0x10ef
	push ax
	lea ax,[bp-0x64]
	push ax
	call _2337
	add sp,byte +0x8
	lea ax,[bp-0x64]
	push ax
	call _1CAB
	add sp,byte +0x2
	call TerminateProgram
	mov sp,bp
	pop bp
	pop di
	pop si
	ret

	DB	0x0
_436D:
	DW	3

_436F:
	push si
	push di
	push bp
	mov bp,sp
	call _5ED1
	call _437E
	pop bp
	pop di
	pop si
	ret

_437E:
	push si
	push di
	push bp
	mov bp,sp
	call _456B
	call _60BB
	mov ax,0x1150
	mov [0x11a2],ax
	mov [0x11a0],ax
	pop bp
	pop di
	pop si
	ret

_4396:
	push si
	push di
	push bp
	mov bp,sp
	call _5FEE
	call _457B
	pop bp
	pop di
	pop si
	ret

_43A5:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	mov word [bp-0x2],0x0
	mov di,[0x11a0]
	mov ax,[bp+0x8]
	mov [di],ax
	mov ax,[bp+0xa]
	mov [di+0x2],ax
	mov si,[0x11a0]
	add word [0x11a0],byte +0x4
	mov di,[0x11a0]
	mov ax,di
	cmp ax,0x11a0
	jc short _43DB
	mov word [0x11a0],0x1150
_43DB:
	mov ax,[0x11a0]
	cmp ax,[0x11a2]
	jz short _43E9
	mov ax,0x1
	jmp short _43EF
_43E9:
	mov [0x11a0],si
	sub ax,ax
_43EF:
	mov sp,bp
	pop bp
	pop di
	pop si
	ret
_43F5:
	push si
	push di
	push bp
	mov bp,sp
	mov ax,[0x11a0]
	cmp ax,[0x11a2]
	jnz short _4407
	sub ax,ax
	jmp short _440F
_4407:
	mov ax,[0x11a2]
	add word [0x11a2],byte +0x4
_440F:
	mov si,ax
	cmp word [0x11a2],0x11a0
	jc short _441F
	mov word [0x11a2],0x1150
_441F:
	mov ax,si
	pop bp
	pop di
	pop si
	ret

_4425:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x4
_442D:
	mov ax,[0x129]
	mov dx,[0x12b]
	mov [bp-0x4],ax
	mov [bp-0x2],dx
_443A:
	call _43F5
	mov si,ax
	or ax,ax
	jnz short _445A
	mov ax,[bp-0x4]
	mov dx,[bp-0x2]
	cmp dx,[0x12b]
	jnz short _4455
	cmp ax,[0x129]
	jz short _443A
_4455:
	call _5F87
	jmp short _442D
_445A:
	mov ax,si
	mov sp,bp
	pop bp
	pop di
	pop si
	ret

_4462:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	cmp word [si],byte +0x1
	jnz short _4494
	mov di,0x145
	jmp short _4477
_4474:
	add di,byte +0x4
_4477:
	cmp word [di],byte +0x0
	jz short _448D
	mov ax,[si+0x2]
	cmp ax,[di]
	jnz short _4474
	mov word [si],0x3
	mov ax,[di+0x2]
	mov [si+0x2],ax
_448D:
	push si
	call _45E4
	add sp,byte +0x2
_4494:
	mov ax,si
	pop bp
	pop di
	pop si
	ret

_449A:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	call _43F5
	mov [bp-0x2],ax
	or ax,ax
	jnz short _44B0
	sub ax,ax
	jmp short _44CD
_44B0:
	push word [bp-0x2]
	call _4530
	add sp,byte +0x2
	mov bx,[bp-0x2]
	mov di,[bx]
	mov si,[bx+0x2]
	cmp di,byte +0x1
	jnz short _44CA
	mov ax,si
	jmp short _44CD
_44CA:
	mov ax,0xffff
_44CD:
	mov sp,bp
	pop bp
	pop di
	pop si
	ret
_44D3:
	push si
	push di
	push bp
	mov bp,sp
_44D8:
	call _449A
	mov si,ax
	or ax,ax
	jz short _44D8
	cmp si,byte -0x1
	jz short _44D8
	mov ax,si
	pop bp
	pop di
	pop si
	ret
_44EC:
	push si
	push di
	push bp
	mov bp,sp
	call _449A
	mov di,ax
	mov si,di
	mov ax,di
	cmp ax,0xd
	jnz short _4504
	mov ax,0x1
	jmp short _4510
_4504:
	cmp si,byte +0x1b
	jnz short _450D
	sub ax,ax
	jmp short _4510
_450D:
	mov ax,0xffff
_4510:
	pop bp
	pop di
	pop si
	ret
_4514:
	push si
	push di
	push bp
	mov bp,sp
	call _437E
_451C:
	call _44EC
	mov di,ax
	mov si,di
	mov ax,di
	cmp ax,0xffff
	jz short _451C
	mov ax,si
	pop bp
	pop di
	pop si
	ret
_4530:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	cmp word [si],byte +0x1
	jnz short _4567
	mov cx,[si+0x2]
	mov di,cx
	mov ax,cx
	cmp ax,0x101
	jz short _454F
	cmp di,0x301
	jnz short _4556
_454F:
	mov word [si+0x2],0xd
	jmp short _4567
_4556:
	cmp di,0x201
	jz short _4562
	cmp di,0x401
	jnz short _4567
_4562:
	mov word [si+0x2],0x1b
_4567:
	pop bp
	pop di
	pop si
	ret
_456B:
	push si
	push di
	push bp
	mov bp,sp
_4570:
	call GetPressedKey
	or ax,ax
	jnz short _4570
	pop bp
	pop di
	pop si
	ret
_457B:
	push si
	push di
	push bp
	mov bp,sp
_4580:
	call GetPressedKey
	mov si,ax
	or ax,ax
	jz short _45AE
	push si
	call _45B2
	add sp,byte +0x2
	mov cx,ax
	mov di,cx
	mov ax,cx
	cmp ax,0xffff
	jz short _45A8
	push di
	mov ax,0x2
_459F:
	push ax
	call _43A5
	add sp,byte +0x4
	jmp short _4580
_45A8:
	push si
	mov ax,0x1
	jmp short _459F
_45AE:
	pop bp
	pop di
	pop si
	ret
_45B2:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	mov si,[bp+0x8]
	mov word [bp-0x2],0xffff
	mov di,0x162f
	jmp short _45CA
_45C7:
	add di,byte +0x4
_45CA:
	cmp word [di],byte +0x0
	jz short _45DB
	mov ax,[di]
	cmp ax,si
	jnz short _45C7
	mov ax,[di+0x2]
	mov [bp-0x2],ax
_45DB:
	mov ax,[bp-0x2]
	mov sp,bp
	pop bp
	pop di
	pop si
	ret
_45E4:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	cmp word [0x10c4],byte +0x2
	jnz short _4611
	mov di,0x1653
	jmp short _45FB
_45F8:
	add di,byte +0x4
_45FB:
	cmp word [di],byte +0x0
	jz short _4611
	mov ax,[si+0x2]
	cmp ax,[di]
	jnz short _45F8
	mov word [si],0x2
	mov ax,[di+0x2]
	mov [si+0x2],ax
_4611:
	pop bp
	pop di
	pop si
	ret

_4615:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	test word [si+0x25],0x200
	jnz short _4695
	mov di,[0x951]
	jmp short _462D
_462A:
	add di,byte +0x2b
_462D:
	mov ax,[0x953]
	cmp ax,di
	jna short _4695
	mov cx,[di+0x25]
	and cx,0x41
	mov ax,cx
	cmp ax,0x41
	jnz short _462A
	test word [di+0x25],0x200
	jnz short _462A
	mov al,[si+0x2]
	cmp al,[di+0x2]
	jz short _462A
	mov cx,[si+0x3]
	add cx,[si+0x1a]
	mov ax,cx
	cmp ax,[di+0x3]
	jl short _462A
	mov cx,[di+0x3]
	add cx,[di+0x1a]
	mov ax,[si+0x3]
	cmp ax,cx
	jg short _462A
	mov ax,[si+0x5]
	cmp ax,[di+0x5]
	jz short _4690
	cmp ax,[di+0x5]
	jng short _4680
	mov ax,[si+0x18]
	cmp ax,[di+0x18]
	jl short _4690
_4680:
	mov ax,[si+0x5]
	cmp ax,[di+0x5]
	jnl short _462A
	mov ax,[si+0x18]
	cmp ax,[di+0x18]
	jng short _462A
_4690:
	mov ax,0x1
	jmp short _4697
_4695:
	sub ax,ax
_4697:
	pop bp
	pop di
	pop si
	ret

_469B:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	imul word [cs:_47AB]
	mov cx,ax
	mov ax,[0x951]
	add ax,cx
	mov di,ax
	or word [di+0x25],0x200
	mov ax,si
	pop bp
	pop di
	pop si
	ret

_46C3:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	imul word [cs:_47AB]
	mov cx,ax
	mov ax,[0x951]
	add ax,cx
	mov di,ax
	and word [di+0x25],0xfdff
	mov ax,si
	pop bp
	pop di
	pop si
	ret

_46EB:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x4
	mov bx,[bp+0x8]
	inc word [bp+0x8]
	mov al,[bx]
	sub ah,ah
	imul word [cs:_47AB]
	mov cx,ax
	mov ax,[0x951]
	add ax,cx
	mov si,ax
	mov bx,[bp+0x8]
	inc word [bp+0x8]
	mov al,[bx]
	sub ah,ah
	imul word [cs:_47AB]
	mov cx,ax
	mov ax,[0x951]
	add ax,cx
	mov di,ax
	test word [si+0x25],0x1
	jz short _4731
	test word [di+0x25],0x1
	jnz short _4744
_4731:
	mov bx,[bp+0x8]
	inc word [bp+0x8]
	mov al,[bx]
	sub ah,ah
	mov bx,ax
	mov byte [bx+0x9],0xff
	jmp short _47A2
_4744:
	mov ax,[si+0x5]
	sub ax,[di+0x5]
	push ax
	call _4B9F
	add sp,byte +0x2
	mov [bp-0x4],ax
	mov ax,[di+0x1a]
	cwd
	idiv word [cs:_47AD]
	mov cx,ax
	mov bx,[di+0x3]
	add bx,cx
	mov ax,[si+0x1a]
	cwd
	idiv word [cs:_47AD]
	mov cx,ax
	mov ax,[si+0x3]
	add ax,cx
	sub ax,bx
	push ax
	call _4B9F
	add sp,byte +0x2
	add ax,[bp-0x4]
	mov [bp-0x2],ax
	mov bx,[bp+0x8]
	inc word [bp+0x8]
	mov al,[bx]
	sub ah,ah
	mov bx,ax
	cmp word [bp-0x2],0xfe
	jna short _479B
	mov ax,0xfe
	jmp short _479E
_479B:
	mov ax,[bp-0x2]
_479E:
	mov [bx+0x9],al
_47A2:
	mov ax,[bp+0x8]
	mov sp,bp
	pop bp
	pop di
	pop si
	ret
_47AB:
	sub ax,[bx+si]
_47AD:
	add al,[bx+si]
_47AF:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	mov si,[bp+0x8]
	test word [si+0x25],0x1000
	jz short _47C9
	and word [si+0x25],0xefff
	jmp _4871
_47C9:
	mov al,[si+0xe]
	mov [bp-0x1],al
	mov al,[si+0xf]
	sub ah,ah
	add ax,0xffff
	mov [bp-0x2],al
	mov al,[si+0x23]
	sub ah,ah
	jmp short _484E
_47E1:
	mov al,[bp-0x2]
	sub ah,ah
	mov di,ax
	inc byte [bp-0x1]
	mov al,[bp-0x1]
	sub ah,ah
	cmp ax,di
	jna short _4864
	mov byte [bp-0x1],0x0
	jmp short _4864
_47FA:
	mov al,[bp-0x1]
	cmp al,[bp-0x2]
	jnc short _4815
	mov al,[bp-0x2]
	sub ah,ah
	mov di,ax
	inc byte [bp-0x1]
	mov al,[bp-0x1]
	sub ah,ah
	cmp ax,di
_4813:
	jnz short _4864
_4815:
	mov al,[si+0x27]
	sub ah,ah
	push ax
	call _7229
	add sp,byte +0x2
	and word [si+0x25],0xffdf
	mov byte [si+0x21],0x0
	mov byte [si+0x23],0x0
	jmp short _4864
_4830:
	cmp byte [bp-0x1],0x0
	jz short _4815
	dec byte [bp-0x1]
	jmp short _4813
_483B:
	cmp byte [bp-0x1],0x0
	jz short _4846
	dec byte [bp-0x1]
	jmp short _4864
_4846:
	mov al,[bp-0x2]
	mov [bp-0x1],al
	jmp short _4864
_484E:
	cmp ax,0x3
	ja short _4864
	shl ax,1
	mov bx,ax
	jmp [cs:bx+_485C]
_485C:
	DW	_47E1
	DW	_47FA
	DW	_4830
	DW	_483B

_4864:
	mov al,[bp-0x1]
	sub ah,ah
	push ax
	push si
	call _3BFB
	add sp,byte +0x4
_4871:
	mov sp,bp
	pop bp
	pop di
	pop si
	ret

_4877:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	imul word [cs:_48C7]
	mov cx,ax
	mov ax,[0x951]
	add ax,cx
	mov di,ax
	or word [di+0x25],0x2000
	mov ax,si
	pop bp
	pop di
	pop si
	ret

_489F:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	imul word [cs:_48C7]
	mov cx,ax
	mov ax,[0x951]
	add ax,cx
	mov di,ax
	and word [di+0x25],0xdfff
	mov ax,si
	pop bp
	pop di
	pop si
	ret

_48C7:
	DW	0x002B

_48C9:
	push si
	push di
	push bp
	mov bp,sp
	mov word [0x11a4],0x0
	pop bp
	pop di
	pop si
	ret
_48D8:
	push si
	push di
	push bp
	mov bp,sp
	call _48C9
	pop bp
	pop di
	pop si
	ret

_48E4:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[0x11a4]
	mov di,0x11a4
	jmp short _48F6
_48F2:
	mov di,si
	mov si,[si]
_48F6:
	or si,si
	jz short _4908
	mov al,[si+0x2]
	sub ah,ah
	mov cx,ax
	mov ax,cx
	cmp ax,[bp+0x8]
	jnz short _48F2
_4908:
	mov [0x11aa],di
	mov ax,si
	pop bp
	pop di
	pop si
	ret

_4912:
	push si
	push di
	push bp
	mov bp,sp
	mov di,[bp+0x8]
	inc word [bp+0x8]
	mov al,[di]
	sub ah,ah
	mov di,ax
	mov al,[di+0x9]
	sub ah,ah
	push ax
	call _4937
	add sp,byte +0x2
	mov ax,[bp+0x8]
	pop bp
	pop di
	pop si
	ret

_4937:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	push si
	call _48E4
	add sp,byte +0x2
	mov di,ax
	or ax,ax
	jnz short _49A0
	call _67E9
	push si
	mov ax,0x2
	push ax
	call _6E46
	add sp,byte +0x4
	cmp word [0x11aa],byte +0x0
	jnz short _4966
	mov di,0x11a4
	jmp short _497C
_4966:
	mov ax,0x5
	push ax
	call LocalAlloc
	add sp,byte +0x2
	mov di,ax
	mov bx,[0x11aa]
	mov [bx],ax
	mov word [di],0x0
_497C:
	mov ax,si
	mov [di+0x2],al
	sub ax,ax
	push ax
	push si
	call _42D5
	add sp,byte +0x2
	push ax
	call _2D62
	add sp,byte +0x4
	mov [di+0x3],ax
	or ax,ax
	jnz short _499D
	sub ax,ax
	jmp short _49A2
_499D:
	call _6823
_49A0:
	mov ax,di
_49A2:
	pop bp
	pop di
	pop si
	ret

_49A6:
	push si
	push di
	push bp
	mov bp,sp
	mov di,[bp+0x8]
	inc word [bp+0x8]
	mov al,[di]
	sub ah,ah
	mov di,ax
	mov al,[di+0x9]
	sub ah,ah
	push ax
	call _49CB
	add sp,byte +0x2
	mov ax,[bp+0x8]
	pop bp
	pop di
	pop si
	ret

;------------------------------------------------------------------------------
_49CB:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov [0x13b],si
	push si
	call _48E4
	add sp,byte +0x2
	mov di,ax
	or ax,ax
	jnz short _49EF
	push si
	mov ax,0x12
	push ax
	call _3F18
	add sp,byte +0x4
_49EF:
	push si
	mov ax,0x4
	push ax
	call _6E46
	add sp,byte +0x4
	mov ax,[di+0x3]
	mov [0x130b],ax
	call _67E9
	call _61DA
	call _6823
	mov word [0x11ac],0x0
	pop bp
	pop di
	pop si
	ret

_4A13:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov di,si
	inc si
	mov al,[di]
	sub ah,ah
	mov di,ax
	mov al,[di+0x9]
	sub ah,ah
	push ax
	call _4A37
	add sp,byte +0x2
	mov ax,si
	pop bp
	pop di
	pop si
	ret
_4A37:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	push si
	call _48E4
	add sp,byte +0x2
	mov di,ax
	or ax,ax
	jnz short _4A57
	push si
	mov ax,0x12
	push ax
	call _3F18
	add sp,byte +0x4
_4A57:
	push si
	mov ax,0x8
	push ax
	call _6E46
	add sp,byte +0x4
	mov ax,[di+0x3]
	mov [0x130b],ax
	call _67E9
	call _61D5
	call _6823
	call _6840
	mov word [0x11ac],0x0
	pop bp
	pop di
	pop si
	ret

_4A7E:
	push si
	push di
	push bp
	mov bp,sp
	mov ax,0xf
	push ax
	call _7233
	add sp,byte +0x2
	sub ax,ax
	push ax
	call _1EEE
	add sp,byte +0x2
	call _537A
	mov word [0x11ac],0x1
	mov ax,[bp+0x8]
	pop bp
	pop di
	pop si
	ret

_4AA6:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov di,si
	inc si
	mov al,[di]
	sub ah,ah
	mov di,ax
	mov al,[di+0x9]
	sub ah,ah
	push ax
	call _4ACA
	add sp,byte +0x2
	mov ax,si
	pop bp
	pop di
	pop si
	ret
_4ACA:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	push si
	call _48E4
	add sp,byte +0x2
	mov di,ax
	or ax,ax
	jnz short _4AEA
	push si
	mov ax,0x15
	push ax
	call _3F18
	add sp,byte +0x4
_4AEA:
	push si
	mov ax,0x6
	push ax
	call _6E46
	add sp,byte +0x4
	mov bx,[0x11aa]
	mov word [bx],0x0
	call _67E9
	push di
	call _1409
	add sp,byte +0x2
	call _6823
	call _146D
	pop bp
	pop di
	pop si
	ret

_4B11:
	push si
	push di
	push bp
	mov bp,sp
	mov ax,[bp+0x8]
	inc ax
	inc ax
	pop bp
	pop di
	pop si
	ret

_4B1F:
	push si
	push di
	push bp
	mov bp,sp
	sub ax,ax
	push ax
	mov ax,0x32
	push ax
	mov ax,0x11ae
	push ax
	call _5945
	add sp,byte +0x6
	pop bp
	pop di
	pop si
	ret

_4B39:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x4
	mov si,[bp+0x8]
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	mov [bp-0x2],ax
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	mov cl,0x8
	shl ax,cl
	add [bp-0x2],ax
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	mov [bp-0x4],ax
	sub di,di
	jmp short _4B6B
_4B6A:
	inc di
_4B6B:
	cmp di,byte +0x27
	jnl short _4B97
	mov bx,di
	shl bx,1
	shl bx,1
	cmp word [bx+0x145],byte +0x0
	jnz short _4B6A
	mov bx,di
	shl bx,1
	shl bx,1
	mov ax,[bp-0x2]
	mov [bx+0x145],ax
	mov bx,di
	shl bx,1
	shl bx,1
	mov ax,[bp-0x4]
	mov [bx+0x147],ax
_4B97:
	mov ax,si
	mov sp,bp
	pop bp
	pop di
	pop si
	ret
_4B9F:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	or si,si
	jnl short _4BB1
	mov ax,si
	neg ax
	jmp short _4BB3
_4BB1:
	mov ax,si
_4BB3:
	pop bp
	pop di
	pop si
	ret
_4BB7:
	push si
	push di
	push bp
	mov bp,sp
	mov ax,[bp+0x8]
	sub ax,0x5
	imul word [cs:_4EEB]
	add ax,0x30
	pop bp
	pop di
	pop si
	ret
_4BCE:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov di,si
_4BD8:
	mov bx,di
	inc di
	cmp byte [bx],0x0
	jnz short _4BD8
	mov ax,di
	sub ax,si
	dec ax
	pop bp
	pop di
	pop si
	ret
_4BE9:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x4
	mov si,[bp+0x8]
	mov di,[bp+0xa]
	mov [bp-0x2],si
_4BFA:
	mov ax,si
	inc si
	mov [bp-0x4],ax
	mov bx,di
	inc di
	mov al,[bx]
	sub ah,ah
	mov cx,ax
	mov bx,[bp-0x4]
	mov al,cl
	mov [bx],al
	or al,al
	jnz short _4BFA
	mov ax,[bp-0x2]
	mov sp,bp
	pop bp
	pop di
	pop si
	ret
_4C1D:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x4
	mov si,[bp+0x8]
	mov di,[bp+0xa]
	mov [bp-0x2],si
_4C2E:
	dec word [bp+0xc]
	jz short _4C4D
	mov ax,si
	inc si
	mov [bp-0x4],ax
	mov bx,di
	inc di
	mov al,[bx]
	sub ah,ah
	mov cx,ax
	mov bx,[bp-0x4]
	mov al,cl
	mov [bx],al
	or al,al
	jnz short _4C2E
_4C4D:
	mov bx,si
	inc si
	mov byte [bx],0x0
	mov ax,[bp-0x2]
	mov sp,bp
	pop bp
	pop di
	pop si
	ret
_4C5C:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x4
	mov si,[bp+0x8]
	mov di,[bp+0xa]
	mov [bp-0x2],si
_4C6D:
	cmp byte [si],0x0
	jz short _4C75
	inc si
	jmp short _4C6D
_4C75:
	mov ax,si
	inc si
	mov [bp-0x4],ax
	mov bx,di
	inc di
	mov al,[bx]
	sub ah,ah
	mov cx,ax
	mov bx,[bp-0x4]
	mov al,cl
	mov [bx],al
	or al,al
	jnz short _4C75
	mov ax,[bp-0x2]
	mov sp,bp
	pop bp
	pop di
	pop si
	ret
_4C98:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov di,[bp+0xa]
	jmp short _4CA7
_4CA5:
	inc si
	inc di
_4CA7:
	cmp byte [si],0x0
	jz short _4CB2
	mov al,[si]
	cmp al,[di]
	jz short _4CA5
_4CB2:
	mov al,[di]
	sub ah,ah
	mov cx,ax
	mov al,[si]
	sub ah,ah
	sub ax,cx
	pop bp
	pop di
	pop si
	ret
_4CC2:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	jmp short _4CCD
_4CCC:
	inc si
_4CCD:
	cmp byte [si],0x20
	jz short _4CCC
	sub di,di
_4CD4:
	cmp byte [si],0x30
	jc short _4CF7
	cmp byte [si],0x39
	ja short _4CF7
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	mov cx,ax
	mov ax,di
	imul word [cs:_4EED]
	add ax,cx
	add ax,0xffd0
	mov di,ax
	jmp short _4CD4
_4CF7:
	mov ax,di
	pop bp
	pop di
	pop si
	ret
_4CFD:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov di,0x11e0
_4D08:
	mov bx,di
	inc di
	mov ax,si
	sub dx,dx
	div word [cs:_4EED]
	mov ax,dx
	add ax,0x30
	mov [bx],al
	mov ax,si
	sub dx,dx
	div word [cs:_4EED]
	mov si,ax
	or ax,ax
	jnz short _4D08
	mov byte [di],0x0
	mov ax,0x11e0
	push ax
	call _4DE4
	add sp,byte +0x2
	pop bp
	pop di
	pop si
	ret
_4D3B:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0xb
	mov si,[bp+0xa]
	push word [bp+0x8]
	lea ax,[bp-0xb]
	push ax
	call _4BE9
	add sp,byte +0x4
	push ax
	call _4BCE
	add sp,byte +0x2
	mov di,ax
	mov ax,0x30
	push ax
	mov ax,0xa
	push ax
	mov ax,0x11e0
	push ax
	call _5945
	add sp,byte +0x6
	cmp di,si
	jna short _4D74
	mov si,di
_4D74:
	lea ax,[bp-0xb]
	push ax
	lea ax,[si+0x11e0]
	sub ax,di
	push ax
	call _4BE9
	add sp,byte +0x4
	mov ax,0x11e0
	mov sp,bp
	pop bp
	pop di
	pop si
	ret
_4D8E:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x1
	mov si,0x11e0
_4D99:
	mov ax,[bp+0x8]
	cwd
	idiv word [cs:_4EEF]
	mov ax,dx
	mov [bp-0x1],al
	mov di,si
	inc si
	cmp byte [bp-0x1],0x9
	jna short _4DB5
	mov cx,0x57
	jmp short _4DB8
_4DB5:
	mov cx,0x30
_4DB8:
	mov al,[bp-0x1]
	sub ah,ah
	add ax,cx
	mov [di],al
	mov ax,[bp+0x8]
	cwd
	idiv word [cs:_4EEF]
	mov [bp+0x8],ax
	or ax,ax
	jg short _4D99
	mov byte [si],0x0
	mov ax,0x11e0
	push ax
	call _4DE4
	add sp,byte +0x2
	mov sp,bp
	pop bp
	pop di
	pop si
	ret
_4DE4:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x1
	mov si,[bp+0x8]
	push si
	call _4BCE
	add sp,byte +0x2
	add ax,[bp+0x8]
	dec ax
	mov di,ax
_4DFC:
	cmp di,si
	jna short _4E16
	mov al,[si]
	mov [bp-0x1],al
	mov bx,si
	inc si
	mov al,[di]
	mov [bx],al
	mov bx,di
	dec di
	mov al,[bp-0x1]
	mov [bx],al
	jmp short _4DFC
_4E16:
	mov ax,[bp+0x8]
	mov sp,bp
	pop bp
	pop di
	pop si
	ret
_4E1F:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	cmp si,byte +0x41
	jc short _4E38
	cmp si,byte +0x5a
	ja short _4E38
	mov ax,si
	add ax,0x20
	jmp short _4E3A
_4E38:
	mov ax,si
_4E3A:
	pop bp
	pop di
	pop si
	ret

_4E3E:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x6
	mov si,[bp+0x8]
	mov di,si
	inc si
	mov al,[di]
	sub ah,ah
	mov [bp-0x4],ax
	mov di,si
	inc si
	mov al,[di]
	sub ah,ah
	mov [bp-0x2],ax
	sub ax,[bp-0x4]
	inc ax
	mov [bp-0x6],ax
	mov di,si
	inc si
	mov al,[di]
	sub ah,ah
	mov di,ax
	call _6F23
	sub dx,dx
	div word [bp-0x6]
	mov ax,dx
	add ax,[bp-0x4]
	mov [di+0x9],al
	mov ax,si
	mov sp,bp
	pop bp
	pop di
	pop si
	ret

_4E86:
	push si
	push di
	push bp
	mov bp,sp
	mov ax,[bp+0x8]
	pop bp
	pop di
	pop si
	ret

_4E92:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov di,[bp+0xa]
_4E9D:
	cmp byte [si],0x0
	jz short _4EAF
	mov al,[si]
	sub ah,ah
	mov cx,ax
	cmp di,cx
	jz short _4EAF
	inc si
	jmp short _4E9D
_4EAF:
	mov al,[si]
	sub ah,ah
	mov cx,ax
	cmp di,cx
	jnz short _4EBD
	mov ax,si
	jmp short _4EBF
_4EBD:
	sub ax,ax
_4EBF:
	pop bp
	pop di
	pop si
	ret
_4EC3:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov di,si
	jmp short _4ED0
_4ECF:
	inc di
_4ED0:
	cmp byte [di],0x0
	jz short _4EE4
	mov al,[di]
	sub ah,ah
	push ax
	call _4E1F
	add sp,byte +0x2
	mov [di],al
	jmp short _4ECF
_4EE4:
	mov ax,si
	pop bp
	pop di
	pop si
	ret

	DB	0x0
_4EEB:
	DB	0xC
	DB	0x0
_4EED:
	DB	0xA
	DB	0x0
_4EEF:
	DB	0x10
	DB	0x0
_4EF1:
	push si
	push di
	push bp
	mov bp,sp
	mov word [0x11ee],0x0
	pop bp
	pop di
	pop si
	ret
_4F00:
	push si
	push di
	push bp
	mov bp,sp
	call _4EF1
	pop bp
	pop di
	pop si
	ret
_4F0C:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	mov si,[bp+0x8]
	mov di,[0x11ee]
	mov word [bp-0x2],0x11ee
	jmp short _4F27
_4F22:
	mov [bp-0x2],di
	mov di,[di]
_4F27:
	or di,di
	jz short _4F30
	cmp si,[di+0x2]
	jnz short _4F22
_4F30:
	mov ax,[bp-0x2]
	mov [0x11fc],ax
	mov ax,di
	mov sp,bp
	pop bp
	pop di
	pop si
	ret

_4F3E:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov di,si
	inc si
	mov al,[di]
	sub ah,ah
	push ax
	call _4F5A
	add sp,byte +0x2
	mov ax,si
	pop bp
	pop di
	pop si
	ret

_4F5A:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	push word [bp+0x8]
	call _4F0C
	add sp,byte +0x2
	mov si,ax
	or ax,ax
	jz short _4F74
	jmp _4FFF
_4F74:
	call _67E9
	cmp word [0x11fc],byte +0x0
	jnz short _4F83
	mov si,0x11ee
	jmp short _4F99
_4F83:
	mov ax,0xe
	push ax
	call LocalAlloc
	add sp,byte +0x2
	mov si,ax
	mov bx,[0x11fc]
	mov [bx],ax
	mov word [si],0x0
_4F99:
	push word [bp+0x8]
	mov ax,0x3
	push ax
	call _6E46
	add sp,byte +0x4
	mov ax,[bp+0x8]
	mov [si+0x2],ax
	sub ax,ax
	push ax
	push word [bp+0x8]
	call _4309
	add sp,byte +0x2
	push ax
	call _2D62
	add sp,byte +0x4
	mov [si+0x4],ax
	mov word [bp-0x2],0x0
	mov di,[si+0x4]
	jmp short _4FD2
_4FCC:
	inc word [bp-0x2]
	add di,byte +0x2
_4FD2:
	cmp word [bp-0x2],byte +0x4
	jnc short _4FFC
	mov bx,[bp-0x2]
	shl bx,1
	add bx,si
	mov al,[di]
	sub ah,ah
	mov dx,ax
	mov al,[di+0x1]
	sub ah,ah
	mov cl,0x8
	shl ax,cl
	mov cx,ax
	add cx,dx
	mov ax,[si+0x4]
	add ax,cx
	mov [bx+0x6],ax
	jmp short _4FCC
_4FFC:
	call _6823
_4FFF:
	mov ax,si
	mov sp,bp
	pop bp
	pop di
	pop si
	ret

_5007:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	mov si,[bp+0x8]
	call _5068
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	mov di,ax
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	mov [0x11fe],ax
	push ax
	call _7233
	add sp,byte +0x2
	push di
	call _4F0C
	add sp,byte +0x2
	mov [bp-0x2],ax
	or ax,ax
	jnz short _5048
	push di
	mov ax,0x9
	push ax
	call _3F18
	add sp,byte +0x4
_5048:
	push word [bp-0x2]
	call _7CEC
	add sp,byte +0x2
	mov ax,si
	mov sp,bp
	pop bp
	pop di
	pop si
	ret

_5059:
	push si
	push di
	push bp
	mov bp,sp
	call _5068
	mov ax,[bp+0x8]
	pop bp
	pop di
	pop si
	ret

_5068:
	push si
	push di
	push bp
	mov bp,sp
	cmp word [0x11ec],byte +0x0
	jz short _5087
	mov word [0x11ec],0x0
	push word [0x11fe]
	call _7229
	add sp,byte +0x2
	call _7DDB
_5087:
	pop bp
	pop di
	pop si
	ret
_508B:
	push es
	mov es,[0x1303]
	xor di,di
	mov cx,0x3480
	rep stosw
	pop es
	cmp word [0x10c6],byte +0x2
	jnz short _50A2
	call _93E9
_50A2:
	ret
_50A3:
	mov dx,[0x149f]
	mov bx,[0x14a1]
	push bx
	cmp dh,bh
	jna short _50BA
	xchg dx,bx
	mov [0x14a0],dh
	mov [0x14a2],bh
_50BA:
	xor ch,ch
	mov cl,bh
	sub cl,dh
	inc cx
	call _512D
	dec cx
	jz short _50DA
	push es
	mov es,[0x1303]
_50CC:
	inc di
	mov al,[es:di]
	or al,bh
	and al,bl
	mov [es:di],al
	loop _50CC
	pop es
_50DA:
	pop word [0x149f]
	ret
_50DF:
	mov dx,[0x149f]
	mov bx,[0x14a1]
	push bx
	cmp dl,bl
	jc short _50F6
	xchg dx,bx
	mov [0x149f],dl
	mov [0x14a1],bl
_50F6:
	xor ch,ch
	mov cl,bl
	sub cl,dl
	inc cx
	call _512D
	dec cx
	jz short _5128
	push es
	mov es,[0x1303]
	mov bl,[0x1301]
	mov dh,[0x1302]
	test dl,0x1
	jz short _5117
_5115:
	xchg bl,dh
_5117:
	add di,0xa0
	mov al,[es:di]
	or al,bh
	and al,bl
	mov [es:di],al
	loop _5115
	pop es
_5128:
	pop word [0x149f]
	ret
_512D:
	push es
	mov es,[0x1303]
	mov ax,[0x149f]
	xor bh,bh
	mov bl,al
	mov di,bx
	shl di,1
	shl di,1
	shl di,1
	shl bx,1
	add di,bx
	shl di,1
	shl di,1
	shl di,1
	shl di,1
	xor bh,bh
	mov bl,ah
	add di,bx
	mov bl,[0x1302]
	test al,0x1
	jz short _515F
	mov bl,[0x1301]
_515F:
	mov bh,[0x12fd]
	mov al,[es:di]
	or al,bh
	and al,bl
	mov [es:di],al
	pop es
	ret
_516F:
	push si
	call _547F
	push es
	mov es,[0x1303]
	mov bh,[0x12fd]
	mov bl,0x4f
	test bh,0xf
	jz short _518E
	mov dl,0xf
	cmp byte [0x12ff],0xf
	jz short _519C
	jmp short _519F
_518E:
	test bh,0xf0
	jz short _519C
	mov dl,0xf0
	cmp byte [0x1300],0x40
	jnz short _519F
_519C:
	jmp _5359
_519F:
	and bl,dl
	mov al,[es:di]
	and al,dl
	cmp al,bl
	jnz short _519C
	push bp
	mov ax,0xffff
	push ax
	push ax
	push ax
	push ax
	mov byte [0x1201],0xa1
	mov byte [0x1200],0x0
	mov byte [0x1202],0x1
	mov byte [0x1204],0x0
_51C6:
	mov ax,[0x1200]
	mov [0x1208],ax
	mov ax,[0x1204]
	mov [0x120a],ax
	mov ax,[0x149f]
	mov [0x1207],ah
	mov cl,ah
	mov ah,[0x1301]
	test al,0x1
	jnz short _51E7
	mov ah,[0x1302]
_51E7:
	mov bp,di
	xor ch,ch
	inc cx
	mov al,[es:di]
	std
_51F0:
	or al,bh
	and al,ah
	stosb
	mov al,[es:di]
	mov dh,al
	and dh,dl
	cmp dh,bl
	loope _51F0
	inc di
	mov cx,di
	sub cx,bp
	mov al,[0x14a0]
	add cl,al
	mov [0x1201],cl
	mov [0x14a0],cl
	xchg bp,di
	inc di
	mov cx,0x9f
	sub cl,al
	cld
	jcxz _522F
_521D:
	mov al,[es:di]
	mov dh,al
	and dh,dl
	cmp dh,bl
	jnz short _522F
	or al,bh
	and al,ah
	stosb
	loop _521D
_522F:
	mov ax,di
	sub ax,bp
	dec al
	add al,[0x1201]
	mov [0x1200],al
	cmp byte [0x1209],0xa1
	jz short _528D
	cmp al,[0x1208]
	jz short _5255
	ja short _5272
	mov [0x1207],al
	mov byte [0x1204],0x0
	jmp short _527D
_5255:
	mov al,[0x1201]
	cmp al,[0x1209]
	jnz short _5272
	cmp byte [0x1204],0x1
	jz short _528D
	mov byte [0x1204],0x1
	mov al,[0x1200]
	mov [0x1207],al
	jmp short _527D
_5272:
	mov byte [0x1204],0x0
	mov al,[0x1208]
	mov [0x1207],al
_527D:
	push word [0x120a]
	push word [0x1202]
	push word [0x1206]
	push word [0x1208]
_528D:
	mov al,[0x1202]
	mov [0x1203],al
	mov al,[0x149f]
	mov [0x1206],al
_5299:
	add al,[0x1202]
	mov [0x149f],al
	cmp al,0xa7
	ja short _530F
_52A4:
	mov ax,[0x149f]
	xor ch,ch
	mov cl,al
	mov di,cx
	shl di,1
	shl di,1
	shl di,1
	shl cx,1
	add di,cx
	shl di,1
	shl di,1
	shl di,1
	shl di,1
	xor ch,ch
	mov cl,ah
	add di,cx
	mov al,[es:di]
	mov dh,al
	and dh,dl
	cmp dh,bl
	jnz short _52D3
	jmp _51C6
_52D3:
	mov al,[0x14a0]
	mov ah,[0x1202]
	cmp ah,[0x1203]
	jz short _5302
	cmp byte [0x1204],0x1
	jz short _5302
	cmp al,[0x120d]
	jc short _5302
	mov ah,[0x120c]
	cmp al,ah
	ja short _5302
	mov al,ah
	cmp al,[0x1200]
	jnc short _530F
	inc al
	mov [0x14a0],al
_5302:
	cmp al,[0x1200]
	jnc short _530F
	inc al
	mov [0x14a0],al
	jmp short _52A4
_530F:
	mov al,[0x1202]
	cmp al,[0x1203]
	jnz short _5332
	cmp byte [0x1204],0x0
	jnz short _5332
	neg al
	mov [0x1202],al
	mov al,[0x1201]
	mov [0x14a0],al
	mov al,[0x1206]
	mov [0x149f],al
	jmp short _534C
_5332:
	pop word [0x1200]
	pop word [0x149f]
	pop word [0x1202]
	pop word [0x1204]
	mov al,[0x149f]
	cmp al,0xff
	jz short _5358
	mov [0x1206],al
_534C:
	mov bp,sp
	mov cx,[bp+0x0]
	mov [0x120c],cx
	jmp _5299
_5358:
	pop bp
_5359:
	pop es
	pop si
	ret

_535C:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	mov ax,0x4040
	call _508B
	call _935F
	call _54BB
	call SetGraphicsMode
	add sp,byte +0x2
	pop bp
	pop di
	pop si
	ret

_537A:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	test word [0x16d1],0x1
	jz short _53B2
	push es
	push ds
	mov ax,[0x1303]
	mov ds,ax
	mov es,ax
	xor si,si
	mov di,si
	mov cx,0x6900
_539A:
	lodsb
	ror al,1
	ror al,1
	ror al,1
	ror al,1
	stosb
	loop _539A
	pop ds
	pop es
	cmp word [0x10c6],byte +0x2
	jnz short _53B2
	call _93E9
_53B2:
	mov al,0xa7
	mov ah,0x0
	mov bl,0xa0
	mov bh,0xa8
	call _935C
	add sp,byte +0x2
	pop bp
	pop di
	pop si
	ret
_53C4:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	mov ax,[bp+0x8]
	mov bx,[bp+0xa]
	mov dx,[bp+0xc]
	call _9362
	mov ax,[bp+0x8]
	mov bx,[bp+0xa]
	mov dx,[bp+0xc]
	mov bh,0x1
	sub bl,0x2
	inc ah
	dec al
	mov dl,dh
	call _9362
	mov ax,[bp+0x8]
	mov bx,[bp+0xa]
	mov dx,[bp+0xc]
	add ah,bl
	sub ah,0x2
	sub al,0x2
	sub bh,0x4
	mov bl,0x1
	mov dl,dh
	call _9362
	mov ax,[bp+0x8]
	mov bx,[bp+0xa]
	mov dx,[bp+0xc]
	inc ah
	sub al,bh
	add al,0x2
	mov bh,0x1
	sub bl,0x2
	mov dl,dh
	call _9362
	mov ax,[bp+0x8]
	mov bx,[bp+0xa]
	mov dx,[bp+0xc]
	inc ah
	sub al,0x2
	sub bh,0x4
	mov bl,0x1
	mov dl,dh
	call _9362
	add sp,byte +0x2
	pop bp
	pop di
	pop si
	ret
_5440:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	mov ax,[bp+0x8]
	mov bx,[bp+0xa]
	call _935C
	add sp,byte +0x2
	pop bp
	pop di
	pop si
	ret

_5458:
	lea di,[0x130f]
	mov bx,[0x130d]
	add bl,al
	shl bx,1
	mov di,[bx+di]
	xor bh,bh
	mov bl,ah
	cmp word [0x10c4],byte +0x0
	jnz short _547C
	shr bx,1
	cmp word [0x10c6],byte +0x3
	jnz short _547C
	shr bx,1
_547C:
	add di,bx
	ret
_547F:
	xor bh,bh
	mov bl,al
	mov di,bx
	shl di,1
	shl di,1
	shl di,1
	shl bx,1
	add di,bx
	shl di,1
	shl di,1
	shl di,1
	shl di,1
	xor bh,bh
	mov bl,ah
	add di,bx
	ret
_549E:
	mov ah,al
	cmp word [0x10c4],byte +0x0
	jz short _54A8
	ret
_54A8:
	cmp word [0x10c6],byte +0x2
	jnz short _54B0
	ret
_54B0:
	cmp word [0x10c6],byte +0x3
	jnz short _54B8
	ret
_54B8:
	jmp SetGraphicsModeEGA
_54BB:
	lea di,[0x120e]
	mov cx,0x30
	mov al,0x4
_54C4:
	rep stosb
	cmp al,0xe
	jnc short _54D0
	inc al
	mov cl,0xc
	jmp short _54C4
_54D0:
	ret
_54D1:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	mov bp,[bp+0x8]
	mov ah,[bp+0x5]
	mov dx,[bp+0x25]
	test dx,0x4
	jnz short _54F2
	mov al,ah
	lea bx,[0x120e]
	xlatb
	mov [bp+0x24],al
_54F2:
	mov al,[bp+0x3]
	xchg al,ah
	call _547F
	mov si,di
	mov di,[bp+0x10]
	mov ah,[bp+0x2]
	xor cx,cx
	mov bx,cx
	mov cl,[di]
	mov di,0x1
	cmp byte [bp+0x24],0xf
	jz short _5544
	push ds
	mov ds,[0x1303]
	mov bx,di
_5518:
	lodsb
	and al,0xf0
	jz short _5541
	cmp al,0x30
	jz short _552B
	xor bl,bl
	cmp al,0x10
	jz short _556F
	cmp al,0x20
	jz short _5577
_552B:
	loop _5518
	cmp bl,0x1
	jz short _553B
	test dx,0x100
	jz short _5543
	jmp short _5541
_553B:
	test dx,0x800
	jz short _5543
_5541:
	xor di,di
_5543:
	pop ds
_5544:
	test ah,ah
	jnz short _5566
	mov dx,bx
	mov al,0x3
	test dh,dh
	jnz short _5555
	call _7257
	jmp short _5558
_5555:
	call _7251
_5558:
	mov al,0x0
	test dl,dl
	jnz short _5563
	call _7257
	jmp short _5566
_5563:
	call _7251
_5566:
	mov ax,di
	add sp,byte +0x2
	pop bp
	pop di
	pop si
	ret

_556F:
	test dx,0x2
	jz short _5541
	jmp short _552B
_5577:
	mov bh,0x1
	jmp short _552B
_557B:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	cmp word [0x11ac],byte +0x0
	jz short _55E1
	mov bp,[bp+0x8]
	mov si,[bp+0x10]
	mov di,[bp+0x12]
	mov [bp+0x12],si
	mov al,[bp+0x5]
	mov cl,[si+0x1]
	mov bh,[bp+0x18]
	mov ch,[di+0x1]
	cmp al,bh
	jnc short _55AA
	xchg al,bh
	xchg ch,cl
_55AA:
	inc bh
	sub bh,ch
	neg cl
	add cl,al
	inc cl
	cmp bh,cl
	jna short _55BA
	mov bh,cl
_55BA:
	neg bh
	add bh,al
	inc bh
	mov ah,[bp+0x3]
	mov cl,[si]
	mov bl,[bp+0x16]
	mov ch,[di]
	cmp ah,bl
	jna short _55D2
	xchg ah,bl
	xchg ch,cl
_55D2:
	add cl,ah
	add bl,ch
	cmp bl,cl
	jnc short _55DC
	mov bl,cl
_55DC:
	sub bl,ah
	call _935C
_55E1:
	add sp,byte +0x2
	pop bp
	pop di
	pop si
	ret
_55E8:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	mov bp,[bp+0x8]
	mov ah,[bp+0x5]
	mov al,ah
	lea bx,[0x120e]
	xlatb
	push ax
	mov ah,[bp+0x24]
	and ah,0xf
	jnz short _5609
	or [bp+0x24],al
_5609:
	push bp
	call _9906
	pop bp
	pop ax
	mov cl,ah
	mov dl,al
	cmp byte [bp+0x24],0x3f
	ja short _568F
	lea bx,[0x120e]
	xor dh,dh
_561F:
	inc dh
	or cl,cl
	jz short _562E
	dec cl
	mov al,cl
	xlatb
	cmp al,dl
	jz short _561F
_562E:
	mov al,[bp+0x3]
	xchg al,ah
	call _547F
	mov si,di
	mov dl,[bp+0x24]
	mov bp,[bp+0x10]
	xor bx,bx
	mov bl,[bp+0x0]
	mov ah,[bp+0x1]
	cmp ah,dh
	jna short _564C
	mov ah,dh
_564C:
	mov al,bl
	dec bx
	and dl,0xf0
	mov dh,0xf
	push es
	mov es,[0x1303]
	xor cx,cx
	mov cl,al
_565D:
	and [es:di],dh
	or [es:di],dl
	inc di
	loop _565D
	mov di,si
	mov cl,ah
	dec cl
	jz short _568E
_566E:
	sub di,0xa0
	and [es:di],dh
	or [es:di],dl
	and [es:bx+di],dh
	or [es:bx+di],dl
	loop _566E
	mov cl,al
	sub cl,0x2
_5685:
	inc di
	and [es:di],dh
	or [es:di],dl
	loop _5685
_568E:
	pop es
_568F:
	add sp,byte +0x2
	pop bp
	pop di
	pop si
	ret

_5696:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	mov bp,[bp+0x8]
	mov al,[si+0x2]
	mov bl,al
	and al,0x30
	mov cl,0x4
	shr al,cl
	mov ah,[bp+0xa]
	cmp al,ah
	jz short _5731
	mov al,0x30
	not al
	and al,bl
	shl ah,cl
	or al,ah
	mov [si+0x2],al
	sub sp,0x800
	mov di,sp
	lodsw
	mov bh,al
	xor cx,cx
	mov cl,ah
	lodsb
	shl al,1
	shl al,1
	shl al,1
	shl al,1
	mov bl,al
	push si
	push di
_56DA:
	xor dx,dx
_56DC:
	lodsb
	or al,al
	jz short _5720
	mov ah,al
	and ax,0xf00f
	cmp ah,bl
	jnz short _56F3
	add dl,al
	jmp short _56DC
_56EE:
	lodsb
	and al,0xf
	jz short _56F9
_56F3:
	add dl,al
	inc dh
	jmp short _56EE
_56F9:
	neg dl
	add dl,bh
	jz short _5711
_56FF:
	mov al,bl
	sub dl,0xf
	jna short _570B
	or al,0xf
	stosb
	jmp short _56FF
_570B:
	add dl,0xf
	or al,dl
	stosb
_5711:
	mov bp,si
	sub si,byte +0x2
_5716:
	std
	lodsb
	cld
	stosb
	dec dh
	jnz short _5716
	mov si,bp
_5720:
	mov al,dh
	stosb
	loop _56DA
	pop si
	mov cx,di
	sub cx,si
	pop di
	rep movsb
	add sp,0x800
_5731:
	add sp,byte +0x2
	pop bp
	pop di
	pop si
	ret
_5738:
	cmp word [0x10c4],byte +0x0
	jz short _5740
	ret
_5740:
	cmp word [0x10c6],byte +0x2
	jnz short _5748
	ret
_5748:
	cmp word [0x10c6],byte +0x3
	jnz short _5750
	ret
_5750:
	jmp _9387
_5753:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x4
	mov si,[bp+0x8]
	mov ax,[si+0x5]
	cmp ax,[0x12d]
	jg short _5775
	test word [si+0x25],0x8
	jnz short _5775
	mov ax,[0x12d]
	inc ax
	mov [si+0x5],ax
_5775:
	push si
	call _582D
	add sp,byte +0x2
	or ax,ax
	jz short _5799
	push si
	call _4615
	add sp,byte +0x2
	or ax,ax
	jnz short _5799
	push si
	call _54D1
	add sp,byte +0x2
	or ax,ax
	jz short _5799
	jmp _5827
_5799:
	mov word [bp-0x2],0x0
	mov ax,0x1
	mov [bp-0x4],ax
	mov di,ax
_57A6:
	push si
	call _582D
	add sp,byte +0x2
	or ax,ax
	jz short _57C7
	push si
	call _4615
	add sp,byte +0x2
	or ax,ax
	jnz short _57C7
	push si
	call _54D1
	add sp,byte +0x2
	or ax,ax
	jnz short _5827
_57C7:
	mov ax,[bp-0x2]
	jmp short _5811
_57CC:
	dec word [si+0x3]
	dec word [bp-0x4]
	jnz short _57A6
	mov word [bp-0x2],0x1
_57D9:
	mov [bp-0x4],di
	jmp short _57A6
_57DE:
	inc word [si+0x5]
	dec word [bp-0x4]
	jnz short _57A6
	mov word [bp-0x2],0x2
_57EB:
	inc di
	mov ax,di
	mov [bp-0x4],ax
	jmp short _57A6
_57F3:
	inc word [si+0x3]
	dec word [bp-0x4]
	jnz short _57A6
	mov word [bp-0x2],0x3
	jmp short _57D9
_5802:
	dec word [si+0x5]
	dec word [bp-0x4]
	jnz short _57A6
	mov word [bp-0x2],0x0
	jmp short _57EB
_5811:
	cmp ax,0x3
	ja short _57A6
	shl ax,1
	mov bx,ax
	jmp [cs:bx+_581F]
_581F:
	DW	_57CC
	DW	_57DE
	DW	_57F3
	DW	_5802

_5827:
	mov sp,bp
	pop bp
	pop di
	pop si
	ret
_582D:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	cmp word [si+0x3],byte +0x0
	jl short _5871
	mov di,[si+0x3]
	add di,[si+0x1a]
	mov ax,di
	cmp ax,0xa0
	jg short _5871
	mov di,[si+0x5]
	sub di,[si+0x1c]
	mov ax,di
	cmp ax,0xffff
	jl short _5871
	cmp word [si+0x5],0xa7
	jg short _5871
	test word [si+0x25],0x8
	jnz short _586C
	mov ax,[si+0x5]
	cmp ax,[0x12d]
	jng short _5871
_586C:
	mov ax,0x1
	jmp short _5873
_5871:
	sub ax,ax
_5873:
	pop bp
	pop di
	pop si
	ret

;------------------------------------------------------------------------------
; 5877
SetVideoMode:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	mov al,[bp+0x8]
	mov ah,0x0
	int 0x10
	add sp,byte +0x2
	pop bp
	pop di
	pop si
	ret

GetCurrentVideoMode:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	mov ah,0xf
	int 0x10
	xor ah,ah
	add sp,byte +0x2
	pop bp
	pop di
	pop si
	ret

;------------------------------------------------------------------------------
; Returns AL
; 58A2
GetPressedKey:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	mov ah,0x2						; Get shift flags
	int 0x16
	and al,0x10
	cmp byte [0x12ba],0xff
	jnz short _58BC
	mov [0x12ba],al
	jmp short _58D4
_58BC:
	cmp al,[0x12ba]
	jz short _58D4
	mov [0x12ba],al
	cmp word [0x1b52],byte +0x0
	jnz short _58D1
	call _882C
	jmp short _58D4
_58D1:
	call _88F7
_58D4:
	mov ah,0x1						; tengo tecla presionada ?
	int 0x16
	jnz short _58DE
	xor ax,ax
	jmp short _58E8
_58DE:
	mov ah,0x0						; get tecla presionada
	int 0x16
	test al,al
	jz short _58E8
	xor ah,ah
_58E8:
	add sp,byte +0x2
	pop bp
	pop di
	pop si
	ret

_58EF:
	push si					; REVISAR
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	mov dx,[bp+0x8]
	in al,dx
	xor ah,ah
	add sp,byte +0x2
	pop bp
	pop di
	pop si
	ret

_5904:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	mov dx,[bp+0x8]
	mov al,[bp+0xa]
	out dx,al
	add sp,byte +0x2
	pop bp
	pop di
	pop si
	ret

_591A:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	push ds
	push es
	mov ax,[bp+0xc]
	mov ds,ax
	mov si,[bp+0xe]
	mov ax,[bp+0x8]
	mov es,ax
	mov di,[bp+0xa]
	mov cx,[bp+0x10]
	rep movsb
	mov ax,[bp+0x10]
	pop es
	pop ds
	add sp,byte +0x2
	pop bp
	pop di
	pop si
	ret

_5945:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	mov di,[bp+0x8]
	mov cx,[bp+0xa]
	mov al,[bp+0xc]
	rep stosb
	mov ax,[bp+0x8]
	add sp,byte +0x2
	pop bp
	pop di
	pop si
	ret

_5962:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	mov si,0x2
	mov di,_5985
_5970:
	lodsb
	cmp al,[cs:di]
	jz short _5979
	call TerminateProgram
_5979:
	inc di
	or al,al
	jnz short _5970
	add sp,byte +0x2
	pop bp
	pop di
	pop si
	ret

_5985:
	DB	0x4C					; REVISAR ANTI HACK ?
	DB	0x4C
	DB	0x4C
	DB	0x4C
	DB	0x4C
	DB	0x0
	DB	0x58

_598C:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov ax,0x17a4
	push ax
	call _4BCE
	add sp,byte +0x2
	mov bx,ax
	mov al,[bx+0x17a3]
	sub ah,ah
	push ax
	mov ax,0x12f3
	push ax
	call _4E92
	add sp,byte +0x4
	or ax,ax
	jz short _59BA
	mov di,0x12bb
	jmp short _59D4
_59BA:
	mov ax,0x2f
	push ax
	mov ax,0x17a4
	push ax
	call _4E92
	add sp,byte +0x4
	or ax,ax
	jnz short _59D1
	mov di,0x12bc
	jmp short _59D4
_59D1:
	mov di,0x12be
_59D4:
	push word [bp+0xa]
	mov ax,0x2
	push ax
	push di
	mov ax,0x17a4
	push ax
	mov ax,0x12c0
	push ax
	push si
	call _2337
	add sp,byte +0xc
	push si
	call _4EC3
	add sp,byte +0x2
	pop bp
	pop di
	pop si
	ret
_59F6:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2d
	mov si,[bp+0x8]
_5A01:
	cmp byte [si],0x20
	jnz short _5A09
	inc si
	jmp short _5A01
_5A09:
	push si
	call _4BCE
	add sp,byte +0x2
	mov di,ax
	or ax,ax
	jnz short _5A26
	push si
	call _5BCB
	add sp,byte +0x2
	push si
	call _4BCE
	add sp,byte +0x2
	mov di,ax
_5A26:
	mov ax,si
	add ax,di
	dec ax
	mov [bp-0x2d],ax
	mov bx,[bp-0x2d]
	mov al,[bx]
	sub ah,ah
	push ax
	mov ax,0x12f3
	push ax
	call _4E92
	add sp,byte +0x4
	or ax,ax
	jz short _5A50
	cmp di,byte +0x1
	jz short _5A50
	dec di
	mov bx,[bp-0x2d]
	mov byte [bx],0x0
_5A50:
	cmp byte [si+0x1],0x3a
	jnz short _5A63
	mov al,[si]
	sub ah,ah
	push ax
	call _4E1F
	add sp,byte +0x2
	jmp short _5A66
_5A63:
	call _5C03
_5A66:
	mov [0x12f7],al
	cmp di,byte +0x1
	jnz short _5A86
	mov al,[si]
	sub ah,ah
	push ax
	mov ax,0x12f3
	push ax
	call _4E92
	add sp,byte +0x4
	or ax,ax
	jz short _5A86
_5A81:
	mov ax,0x1
	jmp short _5ABF
_5A86:
	cmp byte [si+0x1],0x3a
	jnz short _5AA5
	cmp di,byte +0x2
	jnz short _5AA5
	mov al,[si]
	sub ah,ah
	push ax
	call _4E1F
	add sp,byte +0x2
	push ax
	call _5C57
	add sp,byte +0x2
	jmp short _5ABF
_5AA5:
	lea ax,[bp-0x2b]
	push ax
	mov ax,0x10
	push ax
	push si
	call _5C1A
	add sp,byte +0x6
	mov cx,ax
	mov ax,cx
	cmp ax,0xffff
	jnz short _5A81
	sub ax,ax
_5ABF:
	mov sp,bp
	pop bp
	pop di
	pop si
	ret

	DB	0x0
_5AC6:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	call _5CA6
	mov dx,[bp+0x8]
	mov cx,[bp+0xa]
	mov ah,0x3c
	int 0x21
	jnc short _5AE0
	mov ax,0xffff
_5AE0:
	add sp,byte +0x2
	pop bp
	pop di
	pop si
	ret

;------------------------------------------------------------------------------
FileOpen:		; 5AE7
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	call _5CA6
	mov dx,[bp+0x8]
	mov al,[bp+0xa]
	mov ah,0x3d
	int 0x21
	jnc short _5B01
	mov ax,0xffff
_5B01:
	add sp,byte +0x2
	pop bp
	pop di
	pop si
	ret

;------------------------------------------------------------------------------
_5B08:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	call _5CA6
	mov bx,[bp+0x8]
	mov cx,[bp+0xc]
	mov dx,[bp+0xa]
	mov ah,0x3f
	int 0x21
	jnc short _5B24
	xor ax,ax
_5B24:
	add sp,byte +0x2
	pop bp
	pop di
	pop si
	ret

;------------------------------------------------------------------------------
_5B2B:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	call _5CA6
	mov bx,[bp+0x8]
	mov cx,[bp+0xc]
	mov dx,[bp+0xa]
	mov ah,0x40
	int 0x21
	jnc short _5B47
	xor ax,ax
_5B47:
	add sp,byte +0x2
	pop bp
	pop di
	pop si
	ret

;------------------------------------------------------------------------------
_5B4E:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	call _5CA6
	mov dx,[bp+0x8]
	mov ah,0x41
	int 0x21
	jnc short _5B64
	xor ax,ax
_5B64:
	add sp,byte +0x2
	pop bp
	pop di
	pop si
	ret

;------------------------------------------------------------------------------
FileClose:		; 5B6B
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	call _5CA6
	mov bx,[bp+0x8]
	mov ah,0x3e
	int 0x21
	add sp,byte +0x2
	pop bp
	pop di
	pop si
	ret

;------------------------------------------------------------------------------
_5B84:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	call _5CA6
	mov bx,[bp+0x8]
	mov al,[bp+0xe]
	mov dx,[bp+0xa]
	mov cx,[bp+0xc]
	mov ah,0x42
	int 0x21
	jnc short _5BA6
	mov ax,0xffff
	mov dx,ax
_5BA6:
	add sp,byte +0x2
	pop bp
	pop di
	pop si
	ret

;------------------------------------------------------------------------------
_5BAD:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	call _5CA6
	mov bx,[bp+0x8]
	mov ah,0x45
	int 0x21
	jnc short _5BC4
	mov ax,0xffff
_5BC4:
	add sp,byte +0x2
	pop bp
	pop di
	pop si
	ret

;------------------------------------------------------------------------------
_5BCB:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	mov si,[bp+0x8]
	mov byte [si],0x5c
	inc si
	xor dl,dl
	mov ah,0x47
	int 0x21
	push word [bp+0x8]
	call _4BCE
	add sp,byte +0x2
	mov cx,ax
	mov al,0x2f
	mov di,[bp+0x8]
	repne scasb
	or cx,cx
	jz short _5BFC
	mov di,[bp+0x8]
	mov byte [di],0x2f
_5BFC:
	add sp,byte +0x2
	pop bp
	pop di
	pop si
	ret

;------------------------------------------------------------------------------
_5C03:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	mov ah,0x19
	int 0x21
	xor ah,ah
	add al,0x61
	add sp,byte +0x2
	pop bp
	pop di
	pop si
	ret

;------------------------------------------------------------------------------
_5C1A:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	mov dx,[bp+0xc]
	mov ah,0x1a
	int 0x21
	mov dx,[bp+0x8]
	mov cx,[bp+0xa]
	mov ah,0x4e
	int 0x21
	jnc short _5C38
	mov ax,0xffff
_5C38:
	add sp,byte +0x2
	pop bp
	pop di
	pop si
	ret

	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	mov ah,0x4f
	int 0x21
	jnc short _5C50
	mov ax,0xffff
_5C50:
	add sp,byte +0x2
	pop bp
	pop di
	pop si
	ret

;------------------------------------------------------------------------------
_5C57:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	call _5CA6
	mov ah,0x19
	int 0x21
	mov cl,al
	mov dl,[bp+0x8]
	sub dl,0x61
	mov ah,0xe
	int 0x21
	mov ah,0x19
	int 0x21
	xor bx,bx
	cmp al,dl
	jnz short _5C7D
	inc bx
_5C7D:
	mov dl,cl
	mov ah,0xe
	int 0x21
	mov ax,bx
	add sp,byte +0x2
	pop bp
	pop di
	pop si
	ret

;------------------------------------------------------------------------------
_5C8C:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	mov bx,[bp+0x8]
	mov al,0x0
	mov ah,0x57
	int 0x21
	mov ax,cx
	add sp,byte +0x2
	pop bp
	pop di
	pop si
	ret

;------------------------------------------------------------------------------
_5CA6:
	push ds
	mov ax, SEG AGIDATA
	mov ds,ax
	mov word [0x176d],0x0
	pop ds
	ret

_5CB4:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov di,si
	inc si
	mov al,[di]
	sub ah,ah
	mov di,ax
	mov al,[di+0x9]
	sub ah,ah
	push ax
	call _5CF4
	add sp,byte +0x2
	mov ax,si
	pop bp
	pop di
	pop si
	ret

_5CD8:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov di,si
	inc si
	mov al,[di]
	sub ah,ah
	push ax
	call _5CF4
	add sp,byte +0x2
	mov ax,si
	pop bp
	pop di
	pop si
	ret

_5CF4:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x33
	call _6DF3
	mov word [bp-0x33],0x0
	push word [bp+0x8]
	call _38A9
	add sp,byte +0x2
	or ax,ax
	jz short _5D16
	mov ax,0x1
	jmp short _5D18
_5D16:
	sub ax,ax
_5D18:
	mov [bp-0x31],ax
	mov word [0xeae],0x1
	sub ax,ax
	push ax
	push word [bp+0x8]
	call _3927
	add sp,byte +0x4
	or ax,ax
	jnz short _5D44
	mov word [0xeae],0x0
	mov ax,0x14a3
	push ax
	call _1CAB
	add sp,byte +0x2
	jmp _5E40
_5D44:
	mov word [0xeae],0x0
	sub ax,ax
	mov [bp-0x21],al
	sub ah,ah
	mov [bp-0x25],al
	push word [bp+0x8]
	lea ax,[bp-0x2f]
	push ax
	call _3A17
	add sp,byte +0x4
	mov ax,[bp-0x1f]
	mov [bp-0x1d],ax
	mov ax,0x9f
	sub ax,[bp-0x15]
	cwd
	idiv word [cs:_5E46]
	mov [bp-0x19],ax
	mov [bp-0x2c],ax
	mov ax,0xa7
	mov [bp-0x17],ax
	mov [bp-0x2a],ax
	mov byte [bp-0xb],0xf
	or word [bp-0xa],0x4
	mov byte [bp-0x2d],0xff
	mov ax,[bp-0x15]
	mov [bp-0x4],ax
	cmp word [0x10c6],byte +0x2
	jnz short _5DAD
	mov ax,[bp-0x2c]
	and ax,0x1
	add ax,[bp-0x4]
	inc ax
	sar ax,1
	shl ax,1
	add [bp-0x4],ax
_5DAD:
	mov ax,[bp-0x13]
	imul word [bp-0x4]
	add ax,0x10
	mov [bp-0x4],ax
	call _146D
	mov di,ax
	mov ax,di
	cmp ax,[bp-0x4]
	jna short _5DF2
	mov word [bp-0x33],0x1
	lea ax,[bp-0x2f]
	push ax
	call _8C15
	add sp,byte +0x2
	mov [bp-0x2],ax
	push ax
	call _9900
	add sp,byte +0x2
	lea ax,[bp-0x2f]
	push ax
	call _9906
	add sp,byte +0x2
	lea ax,[bp-0x2f]
	push ax
	call _557B
	add sp,byte +0x2
_5DF2:
	push word [bp+0x8]
	call _38A9
	add sp,byte +0x2
	mov si,ax
	mov di,[si+0x3]
	mov ax,[di+0x3]
	add ax,di
	push ax
	call _1CAB
	add sp,byte +0x2
	cmp word [bp-0x33],byte +0x0
	jz short _5E2E
	push word [bp-0x2]
	call _9903
	add sp,byte +0x2
	lea ax,[bp-0x2f]
	push ax
	call _557B
	add sp,byte +0x2
	push word [bp-0x2]
	call _8C88
	add sp,byte +0x2
_5E2E:
	cmp word [bp-0x31],byte +0x0
	jnz short _5E3D
	push word [bp+0x8]
	call _3E3D
	add sp,byte +0x2
_5E3D:
	call _6E02
_5E40:
	mov sp,bp
	pop bp
	pop di
	pop si
	ret
_5E46:
	add al,[bx+si]

IRQ1_INT9_KeyboardDataReady:
	sti
	push ds
	push ax
	mov ax, SEG AGIDATA
	mov ds,ax
	mov ah,0x2
	int 0x16
	mov ah,al
	in al,0x60
	cmp al,0x4c
	jnz short _5E82
	and ah,0xf
	jnz short _5EC9
	push ax
	push bx
	push cx
	push dx
	push si
	push di
	push bp
	push ds
	push es
	xor bx,bx
	mov ax,0x2
	push bx
	push ax
	call _43A5
	add sp,byte +0x4
	pop es
	pop ds
	pop bp
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	jmp short _5EB6
_5E82:
	and ah,0xc
	cmp ah,0xc
	jnz short _5EC9
	cmp al,0x4d
	jnz short _5E97
	mov word [0x12fb],0xffff
	jmp short _5EA1
_5E97:
	cmp al,0x4b
	jnz short _5EC9
	mov word [0x12fb],0x1
_5EA1:
	push ax
	push bx
	push cx
	push dx
	push si
	push di
	push bp
	push ds
	push es
	call _9359
	pop es
	pop ds
	pop bp
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
_5EB6:
	in al,0x61
	or al,0x80
	out 0x61,al
	and al,0x7f
	out 0x61,al
	cli
	mov al,0x20
	out 0x20,al
	pop ax
	jmp short _5ECF
_5EC9:
	pop ax
	pushf
	call far [0x1761]
_5ECF:
	pop ds
	iret
_5ED1:
	push si
	push di
	push bp
	mov bp,sp
	mov ax,0xffff
	mov [0x1543],ax
	mov [0x1541],ax
	call _6153
	cmp word [0x153d],byte +0x0
	jz short _5EF0
	cmp word [0x153f],byte +0x0
	jnz short _5EF8
_5EF0:
	mov word [0x1543],0x0
	jmp short _5F07
_5EF8:
	sub ax,ax
	push ax
	push ax
	push ax
	mov ax,0x14c5
	push ax
	call _1D59
	add sp,byte +0x8
_5F07:
	cmp word [0x1543],byte -0x1
	jnz short _5F27
	call _44D3
	jmp short _5F1B
_5F13:
	mov word [0x1543],0x1
	jmp short _5F07
_5F1B:
	cmp ax,0xd
	jz short _5F13
	cmp ax,0x1b
	jz short _5EF0
	jmp short _5F07
_5F27:
	call _1EEE
	cmp word [0x1543],byte +0x0
	jz short _5F7D
	call _6153
	mov ax,[0x153d]
	cwd
	idiv word [cs:_6151]
	mov si,ax
	mov ax,si
	add ax,[0x153d]
	mov [0x1545],ax
	mov ax,[0x153d]
	sub ax,si
	mov [0x1549],ax
	mov ax,[0x153f]
	cwd
	idiv word [cs:_6151]
	mov di,ax
	mov ax,di
	add ax,[0x153f]
	mov [0x1547],ax
	mov ax,[0x153f]
	sub ax,di
	mov [0x154b],ax
_5F6C:
	call _61BA
	cmp word [0x14ad],byte +0x0
	jnz short _5F6C
	cmp word [0x14b9],byte +0x0
	jnz short _5F6C
_5F7D:
	call _437E
	mov ax,[bp+0x8]
	pop bp
	pop di
	pop si
	ret

_5F87:
	push si
	push di
	push bp
	mov bp,sp
	cmp word [0x1543],byte +0x0
	jz short _5FEA
	cmp word [0x1537],byte +0x0
	jz short _5FAF
	mov ax,[0x1539]
	mov dx,[0x153b]
	cmp dx,[0x12b]
	jl short _5FAF
	jg short _5FEA
	cmp ax,[0x129]
	ja short _5FEA
_5FAF:
	call _6153
	mov di,ax
	mov ax,di
	cmp ax,0xffff
	jz short _5FEA
	call _60D4
	mov si,ax
	mov ax,[0x1541]
	cmp ax,si
	jz short _5FD6
	push si
	mov ax,0x2
	push ax
	call _43A5
	add sp,byte +0x4
	mov [0x1541],si
_5FD6:
	mov ax,[0x129]
	mov dx,[0x12b]
	add ax,0x9
	adc dx,byte +0x0
	mov [0x1539],ax
	mov [0x153b],dx
_5FEA:
	pop bp
	pop di
	pop si
	ret
_5FEE:
	push si
	push di
	push bp
	mov bp,sp
	cmp word [0x1543],byte +0x0
	jnz short _5FFD
	jmp _60B7
_5FFD:
	call _61BA
	mov si,0x14ad
	jmp short _6008
_6005:
	add si,byte +0xc
_6008:
	cmp si,0x14b9
	jna short _6011
	jmp _60B7
_6011:
	cmp word [si+0x2],byte +0x2
	jnz short _603D
	mov ax,[si+0x8]
	mov dx,[si+0xa]
	cmp dx,[0x12b]
	jl short _602B
	jg short _603D
	cmp ax,[0x129]
	ja short _603D
_602B:
	mov word [si+0x2],0x0
	push word [si+0x4]
	mov ax,0x1
	push ax
	call _43A5
	add sp,byte +0x4
_603D:
	mov ax,[si+0x2]
	jmp short _609E
_6042:
	cmp word [si],byte +0x0
	jz short _6005
_6047:
	inc word [si+0x2]
	jmp short _6005
_604C:
	cmp word [si],byte +0x0
	jnz short _6005
	mov ax,0x8
	push ax
	call _7247
	add sp,byte +0x2
	or ax,ax
	jz short _607C
	mov al,[0x18]
	sub ah,ah
	cwd
	mov bx,ax
	mov cx,dx
	mov ax,[0x129]
	mov dx,[0x12b]
	add ax,bx
	adc dx,cx
	mov [si+0x8],ax
	mov [si+0xa],dx
	jmp short _6047
_607C:
	push word [si+0x4]
_607F:
	mov ax,0x1
	push ax
	call _43A5
	add sp,byte +0x4
	mov word [si+0x2],0x0
	jmp _6005
_6091:
	cmp word [si],byte +0x0
	jz short _6099
	jmp _6005
_6099:
	push word [si+0x6]
	jmp short _607F
_609E:
	cmp ax,0x3
	jna short _60A6
	jmp _6005
_60A6:
	shl ax,1
	mov bx,ax
	jmp [cs:bx+_60AF]
_60AF:
	DW	_6042
	DW	_604C
	DW	_6042
	DW	_6091

_60B7:
	pop bp
	pop di
	pop si
	ret

_60BB:
	push si
	push di
	push bp
	mov bp,sp
	sub ax,ax
	mov [0x14b9],ax
	mov [0x14ad],ax
	sub ax,ax
	mov [0x14bb],ax
	mov [0x14af],ax
	pop bp
	pop di
	pop si
	ret
_60D4:
	push si
	push di
	push bp
	mov bp,sp
	mov ax,[0x153f]
	cmp ax,[0x154b]
	jnl short _6103
	mov ax,[0x153d]
	cmp ax,[0x1549]
	jnl short _60F0
	mov si,0x8
	jmp short _614B
_60F0:
	mov ax,[0x153d]
	cmp ax,[0x1545]
	jng short _60FE
	mov si,0x2
	jmp short _614B
_60FE:
	mov si,0x1
	jmp short _614B
_6103:
	mov ax,[0x153f]
	cmp ax,[0x1547]
	jng short _612D
	mov ax,[0x153d]
	cmp ax,[0x1549]
	jnl short _611A
	mov si,0x6
	jmp short _614B
_611A:
	mov ax,[0x153d]
	cmp ax,[0x1545]
	jng short _6128
	mov si,0x4
	jmp short _614B
_6128:
	mov si,0x5
	jmp short _614B
_612D:
	mov ax,[0x153d]
	cmp ax,[0x1549]
	jnl short _613B
	mov si,0x7
	jmp short _614B
_613B:
	mov ax,[0x153d]
	cmp ax,[0x1545]
	jng short _6149
	mov si,0x3
	jmp short _614B
_6149:
	sub si,si
_614B:
	mov ax,si
	pop bp
	pop di
	pop si
	ret
_6151:
	add al,[bx+si]
_6153:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	cli
	mov ah,0x1
	int 0x16
	jz short _6167
	mov ax,0xffff
	jmp short _61B2
_6167:
	xor bx,bx
	mov ch,0x1
	mov cl,0x2
	mov dx,0x201
	out dx,al
_6171:
	jmp short _6173
_6173:
	aaa
	in al,dx
	test ch,al
	jz short _617F
	cli
	inc bh
	jz short _61AA
_617F:
	test cl,al
	jz short _6189
	cli
	inc bl
	jz short _61AA
_6189:
	and al,0x3
	jnz short _6171
	mov ah,0x1
	int 0x16
	jz short _6198
	mov ax,0xffff
	jmp short _61B2
_6198:
	sti
	xor ah,ah
	mov al,bh
	mov [0x153d],ax
	xor bh,bh
	mov [0x153f],bx
	xor ax,ax
	jmp short _61B2
_61AA:
	xor ax,ax
	mov [0x153d],ax
	mov [0x153f],ax
_61B2:
	sti
	add sp,byte +0x2
	pop bp
	pop di
	pop si
	ret
_61BA:
	mov dx,0x201
	in al,dx
	xor bx,bx
	test al,0x10
	jnz short _61C5
	inc bx
_61C5:
	mov [0x14ad],bx
	xor bx,bx
	test al,0x20
	jnz short _61D0
	inc bx
_61D0:
	mov [0x14b9],bx
	ret
_61D5:
	push si
	push di
	push bp
	jmp short _61E3
_61DA:
	push si
	push di
	push bp
	mov ax,0x4f4f
	call _508B
_61E3:
	mov word [0x12fd],0x0
	mov word [0x156a],0x0
	mov byte [0x1301],0xff
	mov byte [0x1302],0xff
	call _620A
	cmp word [0x10c6],byte +0x2
	jnz short _6206
	call _93E9
_6206:
	pop bp
	pop di
	pop si
_6209:
	ret
_620A:
	mov si,[0x130b]
_620E:
	lodsb
_620F:
	cmp al,0xff
	jz short _6209
	sub al,0xf0
	jc short _620E
	cmp al,0xa
	ja short _620E
	mov bl,al
	xor bh,bh
	shl bx,1
	call [bx+0x1552]
	jmp short _620F
	lodsb
	ret

_6229:
	lodsb
	call _549E
	mov [0x12ff],al
	or word [0x12fd],0xf
	and byte [0x1301],0xf0
	or [0x1301],al
	and byte [0x1302],0xf0
	or [0x1302],ah
	lodsb
	ret

_624A:
	and word [0x12fd],0xf0
	or byte [0x1301],0xf
	or byte [0x1302],0xf
	lodsb
	ret

_625C:
	lodsb
	shl al,1
	shl al,1
	shl al,1
	shl al,1
	mov [0x1300],al
	or word [0x12fd],0xf0
	and byte [0x1301],0xf
	or [0x1301],al
	and byte [0x1302],0xf
	or [0x1302],al
	lodsb
	ret

_6282:
	and word [0x12fd],0xf
	or byte [0x1301],0xf0
	or byte [0x1302],0xf0
	lodsb
	ret

_6294:
	test word [0x156a],0x20
	jz short _62A5
	lodsb
	cmp al,0xf0
	jc short _62A2
	ret
_62A2:
	mov [0x1574],al
_62A5:
	call _644D
	jnc short _62AB
	ret
_62AB:
	mov [0x156c],ah
	mov [0x156e],al
	push si
	call _62BF
	pop si
	jmp short _6294

_62B9:
	lodsb
	mov [0x156a],al
	lodsb
	ret

_62BF:
	mov si,[0x156a]
	and si,0x7
	shl si,1
	mov si,[si+0x1595]
	mov ax,[0x156c]
	shl ax,1
	mov bx,[0x156a]
	and bx,0x7
	sub ax,bx
	jns short _62E1
	mov ax,0x0
_62E1:
	add bx,bx
	mov cx,0x140
	sub cx,bx
	cmp ax,cx
	jl short _62EE
	mov ax,cx
_62EE:
	shr ax,1
	mov [0x156c],ax
	mov [0x1570],ax
	mov bx,[0x156a]
	and bx,0x7
	mov ax,[0x156e]
	sub ax,bx
	jns short _6308
	mov ax,0x0
_6308:
	add bx,bx
	mov cx,0xa7
	sub cx,bx
	cmp ax,cx
	jl short _6315
	mov ax,cx
_6315:
	mov [0x156e],ax
	mov [0x1572],ax
	mov dl,[0x1574]
	or dl,0x1
	mov bx,[0x156a]
	and bx,0x7
	shl bx,1
	inc bx
	add [0x1572],bx
	shl bx,1
	mov [0x1568],bx
_6337:
	mov bx,0x0
	lodsw
_633B:
	test word [0x156a],0x10
	jnz short _6349
	test [bx+0x1575],ax
	jz short _6377
_6349:
	test word [0x156a],0x20
	jz short _6362
	shr dl,1
	jnc short _6358
	xor dl,0xb8
_6358:
	test dl,0x1
	jnz short _6377
	test dl,0x2
	jz short _6377
_6362:
	push dx
	push ax
	push bx
	push si
	mov ah,[0x156c]
	mov al,[0x156e]
	mov [0x149f],ax
	call _512D
	pop si
	pop bx
	pop ax
	pop dx
_6377:
	inc word [0x156c]
	add bx,byte +0x4
	cmp bx,[0x1568]
	jng short _633B
	mov ax,[0x1570]
	mov [0x156c],ax
	inc word [0x156e]
	mov ax,[0x156e]
	cmp ax,[0x1572]
	jnz short _6337
	ret

_6398:
	call _644D
	jc short _63B5
	mov [0x149f],ax
	call _512D
	call _63B6
	ret
_63A7:
	call _644D
	jc short _63B5
	mov [0x149f],ax
	call _512D
	call _63C8
_63B5:
	ret
_63B6:
	call _6456
	jc short _63B5
	mov [0x14a2],ah
	mov al,[0x149f]
	mov [0x14a1],al
	call _50A3
_63C8:
	call _6469
	jc short _63B5
	mov [0x14a1],al
	mov al,[0x14a0]
	mov [0x14a2],al
	call _50DF
	jmp short _63B6
_63DB:
	call _644D
	jc short _63B5
	mov [0x149f],ax
	call _512D
_63E6:
	call _644D
	jc short _63B5
	mov [0x14a1],ax
	call _6476
	jmp short _63E6
_63F3:
	call _644D
	jc short _63B5
	mov [0x149f],ax
	call _512D
_63FE:
	lodsb
	cmp al,0xef
	ja short _63B5
	mov ah,al
	mov bx,[0x149f]
	and al,0x70
	mov cl,0x4
	shr al,cl
	test ah,0x80
	jnz short _6418
	add bh,al
	jmp short _641A
_6418:
	sub bh,al
_641A:
	cmp bh,0x9f
	jna short _6421
	mov bh,0x9f
_6421:
	mov al,ah
	and al,0x7
	test ah,0x8
	jnz short _642E
	add bl,al
	jmp short _6430
_642E:
	sub bl,al
_6430:
	cmp bl,0xa7
	jna short _6437
	mov bl,0xa7
_6437:
	mov [0x14a1],bx
	call _6476
	jmp short _63FE
_6440:
	call _644D
	jc short _6467
	mov [0x149f],ax
	call _516F
	jmp short _6440
_644D:
	call _6456
	jc short _6455
	call _6469
_6455:
	ret
_6456:
	lodsb
	mov ah,al
	cmp ah,0xef
	ja short _6467
	cmp ah,0x9f
	jna short _6465
	mov ah,0x9f
_6465:
	clc
	ret
_6467:
	stc
	ret
_6469:
	lodsb
	cmp al,0xef
	ja short _6467
	cmp al,0xa7
	jna short _6465
	mov al,0xa7
	clc
	ret
_6476:
	xor ch,ch
	mov bx,[0x149f]
	xchg bl,bh
	cmp bh,[0x14a1]
	jnz short _6487
	jmp _50A3
_6487:
	cmp bl,[0x14a2]
	jnz short _6490
	jmp _50DF
_6490:
	mov dh,[0x14a1]
	mov [0x154e],dh
	mov ah,0x1
	sub dh,bh
	jnc short _64A2
	neg ah
	neg dh
_64A2:
	mov dl,[0x14a2]
	mov [0x154d],dl
	mov al,0x1
	sub dl,bl
	jnc short _64B4
	neg al
	neg dl
_64B4:
	mov [0x154f],ax
	cmp dl,dh
	jc short _64CA
	mov cl,dl
	mov [0x1551],dl
	mov ah,dl
	shr ah,1
	xor al,al
	jmp short _64D6
_64CA:
	mov cl,dh
	mov [0x1551],dh
	mov al,dh
	shr al,1
	xor ah,ah
_64D6:
	add ah,dh
	cmp ah,[0x1551]
	jc short _64E6
	sub ah,[0x1551]
	add bh,[0x1550]
_64E6:
	add al,dl
	cmp al,[0x1551]
	jc short _64F6
	sub al,[0x1551]
	add bl,[0x154f]
_64F6:
	push ax
	push bx
	push cx
	push dx
	mov [0x149f],bh
	mov [0x14a0],bl
	call _512D
	pop dx
	pop cx
	pop bx
	pop ax
	loop _64D6
	ret


;------------------------------------------------------------------------------
; 0x6558
; param1 = filex index (1, 2, 3, 4, 5, 6, 7)
; 7		AGIDATA.OVL		-> 10FF:0		cs+9B6
; 3		EGA_GRAF.OVL	-> 107E:0		cs+935		0x400+ bytes size
; 5		IBM_OBJS.OVL	-> 10D9:0		cs+990		0x200+ bytes size
;LoadOVL:
;	push si
;	push di
;	push bp
;	mov bp,sp
;	sub sp,byte +0x2
;	push ds
;_6561:
;	mov ax,0x927
;	mov ds,ax
;	mov ax,[bp+0x8]				; 6566
;	dec ax
;	mov bx,0x10
;	mul bx
;	add ax,0x4
;	mov si,ax
;	xor ax,ax
;	push ax
;	push word [si+0x8]			; filename
;	call FileOpen				; File Open		657a
;	add sp,byte +0x4
;	mov [cs:_65AF],ax
;	mov bx,ax
;	mov cx,[si+0xe]
;	shl cx,1
;	shl cx,1
;	shl cx,1
;	shl cx,1
;	xor dx,dx
;	mov ax,[si+0x4]
;	mov ds,ax
;	mov ah,0x3f					; Read File    6598
;	int 0x21
;	push word [cs:_65AF]
;	call FileClose
;	add sp,byte +0x2
;	pop ds
;	add sp,byte +0x2
;	pop bp
;	pop di
;	pop si
;	ret

;_65AF:
;	DW	0

_65B1:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x4
	call _5068
	call _109D
	call _6DF3
	mov ax,[0x951]
	mov [bp-0x2],ax
	jmp short _65CE
_65CA:
	add word [bp-0x2],byte +0x2b
_65CE:
	mov ax,[bp-0x2]
	cmp ax,[0x953]
	jnc short _65FB
	mov bx,[bp-0x2]
	mov ax,[bx+0x3]
	mov [bx+0x2],al
	mov cx,[bx+0x25]
	mov ax,cx
	mov [bx+0x3],ax
	test word [bx+0x25],0x40
	jz short _65CA
	and word [bx+0x25],0xfffe
	or word [bx+0x25],0x10
	jmp short _65CA
_65FB:
	call _67E9
	call _1452
	mov word [0x11ac],0x0
	call _6EC4
_660A:
	call _6EE1
	mov si,ax
	or ax,ax
	jnz short _6616
	jmp _66BC
_6616:
	mov al,[si+0x1]
	sub ah,ah
	mov di,ax
	mov al,[si]
	sub ah,ah
	jmp short _6699
_6623:
	push di
	call _1167
	add sp,byte +0x2
	push ax
	call _1372
_662E:
	add sp,byte +0x2
	jmp short _660A
_6633:
	mov ax,0x1
	push ax
	push di
	call _3927
	add sp,byte +0x4
	jmp short _660A
_6640:
	push di
	call _4937
	jmp short _662E
_6646:
	push di
	call _4F5A
	jmp short _662E
_664C:
	push di
	call _49CB
	jmp short _662E
_6652:
	call _6EE1
	mov si,ax
	mov al,[si]
	mov [0xe44],al
	mov al,[si+0x1]
	mov [0xe45],al
	call _6EE1
	mov si,ax
	mov al,[si]
	mov [0xe46],al
	mov al,[si+0x1]
	mov [0xe47],al
	call _6EE1
	mov si,ax
	mov al,[si]
	mov [0xe48],al
	mov al,[si+0x1]
	mov [0xe49],al
	call _2C82
	jmp short _660A
_6687:
	push di
	call _4ACA
	jmp short _662E
_668D:
	push di
	call _3E3D
	jmp short _662E
_6693:
	push di
	call _4A37
	jmp short _662E
_6699:
	cmp ax,0x8
	jna short _66A1
	jmp _660A
_66A1:
	shl ax,1
	mov bx,ax
	jmp [cs:bx+_66AA]
_66AA:
	DW	_6623
	DW	_6633
	DW	_6640
	DW	_6646
	DW	_664C
	DW	_6652
	DW	_6687
	DW	_668D
	DW	_6693

_66BC:
	call _6E02
	mov ax,[0x951]
	mov [bp-0x2],ax
	sub di,di
	jmp short _66CE
_66C9:
	add word [bp-0x2],byte +0x2b
	inc di
_66CE:
	mov ax,[bp-0x2]
	cmp ax,[0x953]
	jc short _66DA
	jmp _675D
_66DA:
	mov bx,[bp-0x2]
	mov ax,[bx+0x3]
	mov [bp-0x4],ax
	mov al,[bx+0x2]
	sub ah,ah
	mov [bx+0x3],ax
	mov ax,di
	mov [bx+0x2],al
	mov al,[bx+0x7]
	sub ah,ah
	push ax
	call _38A9
	add sp,byte +0x2
	or ax,ax
	jz short _6710
	mov bx,[bp-0x2]
	mov al,[bx+0x7]
	sub ah,ah
	push ax
	push bx
	call _3A17
	add sp,byte +0x4
_6710:
	test word [bp-0x4],0x40
	jz short _66C9
	test word [bp-0x4],0x1
	jz short _673A
	mov bx,[bp-0x2]
	mov al,[bx+0x2]
	sub ah,ah
	push ax
	call _9D3
	add sp,byte +0x2
	mov bx,[bp-0x2]
	cmp byte [bx+0x22],0x2
	jnz short _673A
	mov byte [bx+0x29],0xff
_673A:
	mov cx,[bp-0x4]
	and cx,0x11
	mov ax,cx
	cmp ax,0x1
	jnz short _6751
	push word [bp-0x2]
	call _68D9
	add sp,byte +0x2
_6751:
	mov bx,[bp-0x2]
	mov ax,[bp-0x4]
	mov [bx+0x25],ax
	jmp _66C9
_675D:
	call _375E
	call _3656
	call _537A
	mov word [0x11ac],0x1
	call _33ED
	call _3807
	mov sp,bp
	pop bp
	pop di
	pop si
	ret

	DB	0x0

_6779:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov di,[si+0x25]
	and di,0x11
	mov ax,di
	cmp ax,0x11
	jnz short _6794
	mov ax,0x1
	jmp short _6796
_6794:
	sub ax,ax
_6796:
	pop bp
	pop di
	pop si
	ret

_679A:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov di,[si+0x25]
	and di,0x11
	mov ax,di
	cmp ax,0x1
	jnz short _67B5
	mov ax,0x1
	jmp short _67B7
_67B5:
	sub ax,ax
_67B7:
	pop bp
	pop di
	pop si
	ret

_67BB:
	push si
	push di
	push bp
	mov bp,sp
	mov ax,0x167b
	push ax
	mov ax,_6779
	push ax
	call _325
	add sp,byte +0x4
	pop bp
	pop di
	pop si
	ret
_67D2:
	push si
	push di
	push bp
	mov bp,sp
	mov ax,0x167f
	push ax
	mov ax, _679A
	push ax
	call _325
	add sp,byte +0x4
	pop bp
	pop di
	pop si
	ret
_67E9:
	push si
	push di
	push bp
	mov bp,sp
	mov ax,0x167b
	push ax
	call _2D4
	add sp,byte +0x2
	mov ax,0x167f
	push ax
	call _2D4
	add sp,byte +0x2
	pop bp
	pop di
	pop si
	ret
_6806:
	push si
	push di
	push bp
	mov bp,sp
	mov ax,0x167b
	push ax
	call _2FA
	add sp,byte +0x2
	mov ax,0x167f
	push ax
	call _2FA
	add sp,byte +0x2
	pop bp
	pop di
	pop si
	ret
_6823:
	push si
	push di
	push bp
	mov bp,sp
	call _67D2
	push ax
	call _42B
	add sp,byte +0x2
	call _67BB
	push ax
	call _42B
	add sp,byte +0x2
	pop bp
	pop di
	pop si
	ret
_6840:
	push si
	push di
	push bp
	mov bp,sp
	mov ax,0x167f
	push ax
	call _455
	add sp,byte +0x2
	mov ax,0x167b
	push ax
	call _455
	add sp,byte +0x2
	pop bp
	pop di
	pop si
	ret

_685D:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	imul word [cs:_6915]
	mov di,ax
	mov ax,[0x951]
	add ax,di
	push ax
	call _68D9
	add sp,byte +0x2
	mov ax,si
	pop bp
	pop di
	pop si
	ret

_6885:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	imul word [cs:_6915]
	mov di,ax
	mov ax,[0x951]
	add ax,di
	push ax
	call _68F7
	add sp,byte +0x2
	mov ax,si
	pop bp
	pop di
	pop si
	ret

_68AD:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	imul word [cs:_6915]
	mov cx,ax
	mov ax,[0x951]
	add ax,cx
	mov di,ax
	call _67E9
	call _6823
	call _6840
	mov ax,si
	pop bp
	pop di
	pop si
	ret

_68D9:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	test word [si+0x25],0x10
	jz short _68F3
	call _67E9
	and word [si+0x25],0xffef
	call _6823
_68F3:
	pop bp
	pop di
	pop si
	ret
_68F7:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	test word [si+0x25],0x10
	jnz short _6911
	call _67E9
	or word [si+0x25],0x10
	call _6823
_6911:
	pop bp
	pop di
	pop si
	ret

_6915:
	DW	0x002B

_6917:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	imul word [cs:_6A77]
	mov cx,ax
	mov ax,[0x951]
	add ax,cx
	mov di,ax
	mov byte [di+0x23],0x0
	or word [di+0x25],0x20
	mov ax,si
	pop bp
	pop di
	pop si
	ret

_6943:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	imul word [cs:_6A77]
	mov cx,ax
	mov ax,[0x951]
	add ax,cx
	mov di,ax
	mov byte [di+0x23],0x1
	or word [di+0x25],0x1030
	mov bx,si
	inc si
	mov al,[bx]
	mov [di+0x27],al
	sub ah,ah
	push ax
	call _7233
	add sp,byte +0x2
	mov ax,si
	pop bp
	pop di
	pop si
	ret

_6980:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	imul word [cs:_6A77]
	mov cx,ax
	mov ax,[0x951]
	add ax,cx
	mov di,ax
	mov byte [di+0x23],0x3
	or word [di+0x25],0x20
	mov ax,si
	pop bp
	pop di
	pop si
	ret

_69AC:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	imul word [cs:_6A77]
	mov cx,ax
	mov ax,[0x951]
	add ax,cx
	mov di,ax
	mov byte [di+0x23],0x2
	or word [di+0x25],0x1030
	mov bx,si
	inc si
	mov al,[bx]
	mov [di+0x27],al
	sub ah,ah
	push ax
	call _7233
	add sp,byte +0x2
	mov ax,si
	pop bp
	pop di
	pop si
	ret

_69E9:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	mov si,[bp+0x8]
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	imul word [cs:_6A77]
	mov cx,ax
	mov ax,[0x951]
	add ax,cx
	mov di,ax
	mov bx,si
	inc si
	mov al,[bx]
	mov [bp-0x2],al
	mov al,[bp-0x2]
	sub ah,ah
	mov bx,ax
	mov al,[bx+0x9]
	mov [di+0x1f],al
	sub ah,ah
	mov [di+0x20],al
	mov ax,si
	mov sp,bp
	pop bp
	pop di
	pop si
	ret

_6A2C:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov di,si
	inc si
	mov al,[di]
	sub ah,ah
	imul word [cs:_6A77]
	mov di,ax
	add di,[0x951]
	and word [di+0x25],0xffdf
	mov ax,si
	pop bp
	pop di
	pop si
	ret

_6A51:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov di,si
	inc si
	mov al,[di]
	sub ah,ah
	imul word [cs:_6A77]
	mov di,ax
	add di,[0x951]
	or word [di+0x25],0x20
	mov ax,si
	pop bp
	pop di
	pop si
	ret

	DB	0x0

_6A77:
	DB	0x2B
	DB	0x0

_6A79:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	mov si,[bp+0x8]
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	imul word [cs:_6DF1]
	mov cx,ax
	mov ax,[0x951]
	add ax,cx
	mov di,ax
	mov byte [di+0x22],0x3
	mov bx,si
	inc si
	mov al,[bx]
	mov [di+0x27],al
	mov bx,si
	inc si
	mov al,[bx]
	mov [di+0x28],al
	mov al,[di+0x1e]
	mov [di+0x29],al
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	mov [bp-0x2],ax
	or ax,ax
	jz short _6AC4
	mov [di+0x1e],al
_6AC4:
	mov bx,si
	inc si
	mov al,[bx]
	mov [di+0x2a],al
	sub ah,ah
	push ax
	call _7233
	add sp,byte +0x2
	or word [di+0x25],0x10
	mov ax,[0x951]
	cmp ax,di
	jnz short _6AE7
	mov word [0x139],0x0
_6AE7:
	push di
	call _1637
	add sp,byte +0x2
	mov ax,si
	mov sp,bp
	pop bp
	pop di
	pop si
	ret

_6AF6:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x4
	mov si,[bp+0x8]
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	imul word [cs:_6DF1]
	mov cx,ax
	mov ax,[0x951]
	add ax,cx
	mov di,ax
	mov byte [di+0x22],0x3
	mov bx,si
	inc si
	mov al,[bx]
	mov [bp-0x4],al
	mov al,[bp-0x4]
	sub ah,ah
	mov bx,ax
	mov al,[bx+0x9]
	mov [di+0x27],al
	mov bx,si
	inc si
	mov al,[bx]
	mov [bp-0x4],al
	mov al,[bp-0x4]
	sub ah,ah
	mov bx,ax
	mov al,[bx+0x9]
	mov [di+0x28],al
	mov al,[di+0x1e]
	mov [di+0x29],al
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	mov bx,ax
	mov al,[bx+0x9]
	sub ah,ah
	mov [bp-0x2],ax
	or ax,ax
	jz short _6B65
	mov [di+0x1e],al
_6B65:
	mov bx,si
	inc si
	mov al,[bx]
	mov [di+0x2a],al
	sub ah,ah
	push ax
	call _7233
	add sp,byte +0x2
	or word [di+0x25],0x10
	mov ax,[0x951]
	cmp ax,di
	jnz short _6B88
	mov word [0x139],0x0
_6B88:
	push di
	call _1637
	add sp,byte +0x2
	mov ax,si
	mov sp,bp
	pop bp
	pop di
	pop si
	ret

_6B97:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	mov si,[bp+0x8]
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	imul word [cs:_6DF1]
	mov cx,ax
	mov ax,[0x951]
	add ax,cx
	mov di,ax
	mov byte [di+0x22],0x2
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	mov [bp-0x2],ax
	mov al,[di+0x1e]
	sub ah,ah
	mov cx,ax
	mov ax,[bp-0x2]
	cmp ax,cx
	ja short _6BD8
	mov al,[di+0x1e]
	sub ah,ah
_6BD8:
	mov [di+0x27],al
	mov bx,si
	inc si
	mov al,[bx]
	mov [di+0x28],al
	sub ah,ah
	push ax
	call _7233
	add sp,byte +0x2
	mov byte [di+0x29],0xff
	or word [di+0x25],0x10
	mov ax,si
	mov sp,bp
	pop bp
	pop di
	pop si
	ret

_6BFD:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	imul word [cs:_6DF1]
	mov cx,ax
	mov ax,[0x951]
	add ax,cx
	mov di,ax
	mov ax,[0x951]
	cmp ax,di
	jnz short _6C27
	mov word [0x139],0x0
_6C27:
	mov byte [di+0x22],0x1
	or word [di+0x25],0x10
	mov ax,si
	pop bp
	pop di
	pop si
	ret

_6C36:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	imul word [cs:_6DF1]
	mov cx,ax
	mov ax,[0x951]
	add ax,cx
	mov di,ax
	mov byte [di+0x22],0x0
	mov ax,si
	pop bp
	pop di
	pop si
	ret

_6C5D:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	imul word [cs:_6DF1]
	mov cx,ax
	mov ax,[0x951]
	add ax,cx
	mov di,ax
	mov byte [di+0x21],0x0
	mov byte [di+0x22],0x0
	mov ax,[0x951]
	cmp ax,di
	jnz short _6C94
	mov byte [0xf],0x0
	mov word [0x139],0x0
_6C94:
	mov ax,si
	pop bp
	pop di
	pop si
	ret

_6C9A:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	imul word [cs:_6DF1]
	mov cx,ax
	mov ax,[0x951]
	add ax,cx
	mov di,ax
	mov byte [di+0x22],0x0
	mov ax,[0x951]
	cmp ax,di
	jnz short _6CCD
	mov byte [0xf],0x0
	mov word [0x139],0x1
_6CCD:
	mov ax,si
	pop bp
	pop di
	pop si
	ret

_6CD3:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	mov si,[bp+0x8]
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	imul word [cs:_6DF1]
	mov cx,ax
	mov ax,[0x951]
	add ax,cx
	mov di,ax
	mov bx,si
	inc si
	mov al,[bx]
	mov [bp-0x2],al
	mov al,[bp-0x2]
	sub ah,ah
	mov bx,ax
	mov al,[bx+0x9]
	mov [di+0x1e],al
	mov ax,si
	mov sp,bp
	pop bp
	pop di
	pop si
	ret

_6D11:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	mov si,[bp+0x8]
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	imul word [cs:_6DF1]
	mov cx,ax
	mov ax,[0x951]
	add ax,cx
	mov di,ax
	mov bx,si
	inc si
	mov al,[bx]
	mov [bp-0x2],al
	mov al,[bp-0x2]
	sub ah,ah
	mov bx,ax
	mov al,[bx+0x9]
	mov [di+0x1],al
	sub ah,ah
	mov [di],al
	mov ax,si
	mov sp,bp
	pop bp
	pop di
	pop si
	ret

_6D53:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	mov si,[bp+0x8]
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	imul word [cs:_6DF1]
	mov cx,ax
	mov ax,[0x951]
	add ax,cx
	mov di,ax
	mov bx,si
	inc si
	mov al,[bx]
	mov [bp-0x2],al
	mov al,[bp-0x2]
	sub ah,ah
	mov bx,ax
	mov al,[bx+0x9]
	mov [di+0x21],al
	mov ax,si
	mov sp,bp
	pop bp
	pop di
	pop si
	ret

_6D91:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	imul word [cs:_6DF1]
	mov cx,ax
	mov ax,[0x951]
	add ax,cx
	mov di,ax
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	mov bx,ax
	mov al,[di+0x21]
	mov [bx+0x9],al
	mov ax,si
	pop bp
	pop di
	pop si
	ret

_6DC4:
	push si
	push di
	push bp
	mov bp,sp
	mov word [0x139],0x0
	mov ax,[bp+0x8]
	pop bp
	pop di
	pop si
	ret

_6DD6:
	push si
	push di
	push bp
	mov bp,sp
	mov word [0x139],0x1
	mov di,[0x951]
	mov byte [di+0x22],0x0
	mov ax,[bp+0x8]
	pop bp
	pop di
	pop si
	ret

	DB	0x0

_6DF1:
	DB	0x2B
	DB	0x0

_6DF3:
	push si
	push di
	push bp
	mov bp,sp
	mov word [0x1689],0x0
	pop bp
	pop di
	pop si
	ret
_6E02:
	push si
	push di
	push bp
	mov bp,sp
	mov word [0x1689],0x1
	pop bp
	pop di
	pop si
	ret
_6E11:
	push si
	push di
	push bp
	mov bp,sp
	cmp word [0x141],byte +0x0
	jng short _6E36
	cmp word [0x1683],byte +0x0
	jnz short _6E36
	mov ax,[0x141]
	shl ax,1
	push ax
	call LocalAlloc
	add sp,byte +0x2
	mov [0x1683],ax
	call _1443
_6E36:
	mov ax,[0x1683]
	mov [0x1685],ax
	mov word [0x143],0x0
	pop bp
	pop di
	pop si
	ret
_6E46:
	push si
	push di
	push bp
	mov bp,sp
	mov ax,0x7
	push ax
	call _7247
	add sp,byte +0x2
	or ax,ax
	jnz short _6EC0
	cmp word [0x1689],byte +0x0
	jz short _6E97
	mov di,[0x141]
	shl di,1
	add di,[0x1683]
	mov ax,[0x1685]
	cmp ax,di
	jc short _6E7F
	push word [0x168b]
	mov ax,0xb
	push ax
	call _3F18
	add sp,byte +0x4
_6E7F:
	mov ax,[bp+0x8]
	mov di,[0x1685]
	mov [di],al
	mov ax,[bp+0xa]
	mov [di+0x1],al
	add word [0x1685],byte +0x2
	inc word [0x143]
_6E97:
	mov ax,[0x1685]
	sub ax,[0x1683]
	sub dx,dx
	div word [cs:_6F21]
	mov di,ax
	mov ax,di
	cmp ax,[0x168b]
	jng short _6EC0
	mov ax,[0x1685]
	sub ax,[0x1683]
	sub dx,dx
	div word [cs:_6F21]
	mov [0x168b],ax
_6EC0:
	pop bp
	pop di
	pop si
	ret
_6EC4:
	push si
	push di
	push bp
	mov bp,sp
	mov ax,[0x1683]
	mov [0x1687],ax
	mov di,[0x143]
	shl di,1
	mov ax,[0x1683]
	add ax,di
	mov [0x1685],ax
	pop bp
	pop di
	pop si
	ret
_6EE1:
	push si
	push di
	push bp
	mov bp,sp
	mov ax,[0x1687]
	cmp ax,[0x1685]
	jc short _6EF3
	sub ax,ax
	jmp short _6EFB
_6EF3:
	mov ax,[0x1687]
	add word [0x1687],byte +0x2
_6EFB:
	pop bp
	pop di
	pop si
	ret

_6EFF:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov di,si
	inc si
	mov al,[di]
	sub ah,ah
	mov [0x141],ax
	call _67E9
	call _6E11
	call _6823
	mov ax,si
	pop bp
	pop di
	pop si
	ret

	DB	0x0
_6F21:
	DB	0x2
	DB	0x0
_6F23:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	cmp word [0x168d],byte +0x0
	jnz short _6F3A
	mov ah,0x0
	int 0x1a
	mov [0x168d],dx
_6F3A:
	mov ax,0x7c4d
	mul word [0x168d]
	inc ax
	mov [0x168d],ax
	xor al,ah
	xor ah,ah
	add sp,byte +0x2
	pop bp
	pop di
	pop si
	ret

_6F50:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,0x194
	mov si,[bp+0x8]
	mov byte [bp-0x4],0x0
	cmp word [0x10c6],byte +0x2
	jnz short _6F6E
	cmp word [0xce7],byte +0x0
	jz short _6FB9
_6F6E:
	call _375E
	sub ax,ax
	push ax
	push word [0x5d5]
	call _2A4E
	add sp,byte +0x4
	mov ax,0x28
	push ax
	mov di,si
	inc si
	mov al,[di]
	sub ah,ah
	push ax
	call _21B3
	add sp,byte +0x2
	push ax
	lea ax,[bp-0x194]
	push ax
	call _1F17
	add sp,byte +0x6
	push ax
	call _2353
	add sp,byte +0x2
	call _3727
	mov ax,0x4
	push ax
	lea ax,[bp-0x4]
	push ax
	call _D76
	add sp,byte +0x4
	call _3807
	jmp short _6FF3
_6FB9:
	mov ax,0x4
	push ax
	mov ax,0x24
	push ax
	mov di,si
	inc si
	mov al,[di]
	sub ah,ah
	push ax
	call _21B3
	add sp,byte +0x2
	push ax
	lea ax,[bp-0x194]
	push ax
	call _1F17
	add sp,byte +0x6
	push ax
	call _97A2
	add sp,byte +0x4
	mov ax,0x4
	push ax
	lea ax,[bp-0x4]
	push ax
	call _D76
	add sp,byte +0x4
	call _98E3
_6FF3:
	mov di,si
	inc si
	mov al,[di]
	sub ah,ah
	mov di,ax
	lea ax,[bp-0x4]
	push ax
	call _4CC2
	add sp,byte +0x2
	sub ah,ah
	mov cx,ax
	mov al,cl
	mov [di+0x9],al
	mov ax,si
	mov sp,bp
	pop bp
	pop di
	pop si
	ret

_7018:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x66
	mov si,[bp+0x8]
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	mov bx,ax
	mov al,[bx+0x9]
	sub ah,ah
	mov [bp-0x2],ax
	imul word [cs:_70B6]
	mov cx,ax
	mov ax,[0x951]
	add ax,cx
	mov di,ax
	mov al,[di+0x1e]
	sub ah,ah
	push ax
	mov al,[di+0x24]
	sub ah,ah
	push ax
	push word [di+0x1c]
	push word [di+0x5]
	push word [di+0x1a]
	push word [di+0x3]
	push word [bp-0x2]
	mov ax,0x168f
	push ax
	lea ax,[bp-0x66]
	push ax
	call _2337
	add sp,byte +0x12
	lea ax,[bp-0x66]
	push ax
	call _1CAB
	add sp,byte +0x2
	mov ax,si
	mov sp,bp
	pop bp
	pop di
	pop si
	ret

_707E:
	push si
	push di
	push bp
	mov bp,sp
	mov word [0x16d1],0x1
	call _537A
	call _4514
	call _537A
	mov word [0x16d1],0x0
	mov ax,[bp+0x8]
	pop bp
	pop di
	pop si
	ret

_709F:
	push si
	push di
	push bp
	mov bp,sp
	mov ax,0xa83
	push ax
	call _1CAB
	add sp,byte +0x2
	mov ax,[bp+0x8]
	pop bp
	pop di
	pop si
	ret

	DB	0x0

_70B6:
	DW	0x002B

_70B8:
	xor bh,bh
	lodsb
	mov bl,al
	cmp byte [bx+0x9],0xff
	jnc short _70C8
	inc byte [bx+0x9]
_70C8:
	mov ax,si
	ret

_70CB:
	xor bh,bh
	lodsb
	mov bl,al
	cmp byte [bx+0x9],0x0
	jz short _70DB
	dec byte [bx+0x9]
_70DB:
	mov ax,si
	ret

_70DE:
	xor bh,bh
	lodsb
	mov bl,al
	lodsb
	mov [bx+0x9],al
	mov ax,si
	ret

_70EB:
	xor ah,ah
	lodsb
	mov di,ax
	lodsb
	mov bx,ax
	mov al,[bx+0x9]
	mov [di+0x9],al
	mov ax,si
	ret

_70FE:
	xor bh,bh
	lodsb
	mov bl,al
	lodsb
	add [bx+0x9],al
	mov ax,si
	ret

_710B:
	xor ah,ah
	lodsb
	mov di,ax
	lodsb
	mov bx,ax
	mov al,[bx+0x9]
	add [di+0x9],al
	mov ax,si
	ret

_711E:
	xor bh,bh
	lodsb
	mov bl,al
	lodsb
	sub [bx+0x9],al
	mov ax,si
	ret

_712B:
	xor ah,ah
	lodsb
	mov di,ax
	lodsb
	mov bx,ax
	mov al,[bx+0x9]
	sub [di+0x9],al
	mov ax,si
	ret

_713E:
	xor ah,ah
	lodsb
	mov di,ax
	mov al,[di+0x9]
	mov di,ax
	lodsb
	mov bx,ax
	mov al,[bx+0x9]
	mov [di+0x9],al
	mov ax,si
	ret

_7157:
	xor bh,bh
	lodsb
	mov bl,al
	mov bl,[bx+0x9]
	lodsb
	mov [bx+0x9],al
	mov ax,si
	ret

_7168:
	xor ah,ah
	lodsb
	mov di,ax
	lodsb
	mov bx,ax
	mov al,[bx+0x9]
	mov bx,ax
	mov al,[bx+0x9]
	mov [di+0x9],al
	mov ax,si
	ret

_7181:
	xor bh,bh
	lodsb
	mov bl,al
	mov cl,[bx+0x9]
	lodsb
	mul cl
	mov [bx+0x9],al
	mov ax,si
	ret

_7194:
	xor bh,bh
	lodsb
	mov bl,al
	mov cl,[bx+0x9]
	push bx
	lodsb
	mov bl,al
	mov al,[bx+0x9]
	mul cl
	pop di
	mov [di+0x9],al
	mov ax,si
	ret

_71AF:
	xor ah,ah
	xor bh,bh
	lodsb
	mov bl,al
	mov ch,[bx+0x9]
	lodsb
	mov cl,al
	mov al,ch
	div cl
	mov [bx+0x9],al
	mov ax,si
	ret

_71C8:
	xor ah,ah
	xor bh,bh
	lodsb
	mov bl,al
	mov ch,[bx+0x9]
	push bx
	lodsb
	mov bl,al
	mov cl,[bx+0x9]
	mov al,ch
	div cl
	pop bx
	mov [bx+0x9],al
	mov ax,si
	ret

_71E7:
	lodsb
	call _7251
	mov ax,si
	ret

_71EE:
	lodsb
	call _7257
	mov ax,si
	ret

_71F5:
	lodsb
	call _725F
	mov ax,si
	ret

_71FC:
	lodsb
	xor bh,bh
	mov bl,al
	mov al,[bx+0x9]
	call _7251
	mov ax,si
	ret

_720B:
	lodsb
	xor bh,bh
	mov bl,al
	mov al,[bx+0x9]
	call _7257
	mov ax,si
	ret

_721A:
	lodsb
	xor bh,bh
	mov bl,al
	mov al,[bx+0x9]
	call _725F
	mov ax,si
	ret

_7229:
	mov bx,sp
	mov al,[ss:bx+0x2]
	call _7251
	ret
_7233:
	mov bx,sp
	mov al,[ss:bx+0x2]
	call _7257
	ret

	mov bx,sp
	mov al,[ss:bx+0x2]
	call _725F
	ret
_7247:
	mov bx,sp
	mov al,[ss:bx+0x2]
	call _7265
	ret

_7251:
	call _7274
	or [bx],al
	ret

_7257:
	call _7274
	xor al,0xff
	and [bx],al
	ret
_725F:
	call _7274
	xor [bx],al
	ret
_7265:
	call _7274
	test [bx],al
	jnz short _7270
	xor ax,ax
	jmp short _7273
_7270:
	xor ax,ax
	inc ax
_7273:
	ret

;------------------------------------------------------------------------------
; Devuelve EBX address de ?
_7274:
	xor ah,ah
	mov bx,ax
	shr bx,1
	shr bx,1
	shr bx,1
	add bx,0x109
	mov cx,ax
	and cx,0x7
	mov al,0x80
	shr al,cl
	ret

_728D:
	push di
	xor ax,ax
	mov cx,0x10
	lea di,[0x109]
	rep stosw
	pop di
	ret

_729B:
	push si
	push di
	push bp
	mov bp,sp
	lea ax,[bp+0x8]
	push ax
	call _7370
	add sp,byte +0x2
	mov di,ax
	mov byte [di+0x2],0xff
	mov ax,[bp+0x8]
	pop bp
	pop di
	pop si
	ret

_72B7:
	push si
	push di
	push bp
	mov bp,sp
	lea ax,[bp+0x8]
	push ax
	call _73C6
	add sp,byte +0x2
	mov di,ax
	mov byte [di+0x2],0xff
	mov ax,[bp+0x8]
	pop bp
	pop di
	pop si
	ret

_72D3:
	push si
	push di
	push bp
	mov bp,sp
	lea ax,[bp+0x8]
	push ax
	call _7370
	add sp,byte +0x2
	mov di,ax
	mov byte [di+0x2],0x0
	mov ax,[bp+0x8]
	pop bp
	pop di
	pop si
	ret

_72EF:
	push si
	push di
	push bp
	mov bp,sp
	lea ax,[bp+0x8]
	push ax
	call _7370
	add sp,byte +0x2
	mov si,ax
	mov bx,[bp+0x8]
	inc word [bp+0x8]
	mov al,[bx]
	sub ah,ah
	mov di,ax
	mov al,[di+0x9]
	mov [si+0x2],al
	mov ax,[bp+0x8]
	pop bp
	pop di
	pop si
	ret

_731A:
	push si
	push di
	push bp
	mov bp,sp
	lea ax,[bp+0x8]
	push ax
	call _73C6
	add sp,byte +0x2
	mov si,ax
	mov bx,[bp+0x8]
	inc word [bp+0x8]
	mov al,[bx]
	sub ah,ah
	mov di,ax
	mov al,[di+0x9]
	mov [si+0x2],al
	mov ax,[bp+0x8]
	pop bp
	pop di
	pop si
	ret

_7345:
	push si
	push di
	push bp
	mov bp,sp
	lea ax,[bp+0x8]
	push ax
	call _73C6
	add sp,byte +0x2
	mov si,ax
	mov di,[bp+0x8]
	inc word [bp+0x8]
	mov al,[di]
	sub ah,ah
	mov di,ax
	mov al,[si+0x2]
	mov [di+0x9],al
	mov ax,[bp+0x8]
	pop bp
	pop di
	pop si
	ret

_7370:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	mov bx,[bp+0x8]
	mov di,[bx]
	mov bx,di
	inc di
	mov al,[bx]
	mov [bp-0x2],al
	mov al,[bp-0x2]
	sub ah,ah
	imul word [cs:_742B]
	mov bx,ax
	mov cx,[0x957]
	add cx,bx
	mov si,cx
	mov ax,cx
	cmp ax,[0x959]
	jc short _73B9
	mov ax,si
	sub ax,[0x959]
	sub dx,dx
	div word [cs:_742B]
	push ax
	mov ax,0x17
	push ax
	call _3F18
	add sp,byte +0x4
_73B9:
	mov bx,[bp+0x8]
	mov [bx],di
	mov ax,si
	mov sp,bp
	pop bp
	pop di
	pop si
	ret

_73C6:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x4
	mov bx,[bp+0x8]
	mov di,[bx]
	mov bx,di
	inc di
	mov al,[bx]
	mov [bp-0x4],al
	mov al,[bp-0x4]
	sub ah,ah
	mov bx,ax
	mov al,[bx+0x9]
	mov [bp-0x2],al
	mov al,[bp-0x2]
	sub ah,ah
	imul word [cs:_742B]
	mov bx,ax
	mov cx,[0x957]
	add cx,bx
	mov si,cx
	mov ax,cx
	cmp ax,[0x959]
	jc short _741D
	mov ax,si
	sub ax,[0x959]
	sub dx,dx
	div word [cs:_742B]
	push ax
	mov ax,0x17
	push ax
	call _3F18
	add sp,byte +0x4
_741D:
	mov bx,[bp+0x8]
	mov [bx],di
	mov ax,si
	mov sp,bp
	pop bp
	pop di
	pop si
	ret

	DB	0x0

_742B:
	DW	0x0003

_742D:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	call _375E
	mov byte [0x16d3],0x1
	push word [0x5cf]
	push word [0x5cd]
	call _7538
	add sp,byte +0x4
	call _9353
	push word [0x5d1]
	mov ax,0x18
	push ax
	sub ax,ax
	push ax
	call _2AB9
	add sp,byte +0x6
	mov ax,si
	pop bp
	pop di
	pop si
	ret

_7465:
	push si
	push di
	push bp
	mov bp,sp
	call _375E
	call _762E
	mov ax,[bp+0x8]
	pop bp
	pop di
	pop si
	ret

_7477:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	mov si,[bp+0x8]
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	mov di,ax
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	mov [bp-0x2],ax
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	push ax
	call _7610
	add sp,byte +0x2
	push ax
	push word [bp-0x2]
	push di
	call _2AB9
	add sp,byte +0x6
	mov ax,si
	mov sp,bp
	pop bp
	pop di
	pop si
	ret

_74B6:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x8
	mov si,[bp+0x8]
	mov di,si
	inc si
	mov al,[di]
	sub ah,ah
	mov [bp-0x2],ax
	mov di,si
	inc si
	mov al,[di]
	sub ah,ah
	mov [bp-0x6],ax
	mov di,si
	inc si
	mov al,[di]
	sub ah,ah
	mov [bp-0x4],ax
	mov di,si
	inc si
	mov al,[di]
	sub ah,ah
	mov [bp-0x8],ax
	mov di,si
	inc si
	mov al,[di]
	sub ah,ah
	push ax
	call _7610
	add sp,byte +0x2
	push ax
	push word [bp-0x8]
	push word [bp-0x4]
	push word [bp-0x6]
	push word [bp-0x2]
	call _2B05
	add sp,byte +0xa
	mov ax,si
	mov sp,bp
	pop bp
	pop di
	pop si
	ret

_7512:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	mov di,ax
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	push ax
	push di
	call _7538
	add sp,byte +0x4
	mov ax,si
	pop bp
	pop di
	pop si
	ret

;------------------------------------------------------------------------------
; Input dos parametros de cantidad ?
_7538:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov di,[bp+0xa]
	push di
	push si
	call _7566
	add sp,byte +0x4
	mov [0x5d1],ax
	push si
	call _7604
	add sp,byte +0x2
	mov [0x5cd],ax
	push di
	call _7610
	add sp,byte +0x2
	mov [0x5cf],ax
	pop bp
	pop di
	pop si
	ret

;------------------------------------------------------------------------------
; llamada desde 7538
_7566:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov di,[bp+0xa]
	cmp word [0x10c6],byte +0x2
	jnz short _7586		; SI salta
	cmp si,di
	jna short _7581
	mov ax,0x7
	jmp short _7600
_7581:
	mov ax,0x70
	jmp short _7600
_7586:
	mov al,[0x16d3]
	sub ah,ah
	mov cx,ax
	mov ax,cx
	cmp ax,0x1
	jnz short _75A2		; NO salta
	mov ax,di
	mov cl,0x4
	shl ax,cl
	mov cx,ax
	mov ax,si
	or ax,cx
	jmp short _7600
_75A2:
	or di,di
	jz short _75AB
	mov ax,0x8f
	jmp short _7600
_75AB:
	cmp word [0x10c6],byte +0x3
	jz short _75B9
	cmp word [0x10c4],byte +0x0
	jz short _75BD
_75B9:
	mov ax,si
	jmp short _7600
_75BD:
	mov ax,si
	jmp short _75D4
_75C1:
	sub ax,ax
	jmp short _7600
_75C5:
	mov ax,0x1
	jmp short _7600
_75CA:
	mov ax,0x2
	jmp short _7600
_75CF:
	mov ax,0x3
	jmp short _7600
_75D4:
	cmp ax,0xe
	ja short _75CF
	shl ax,1
	mov bx,ax
	jmp [cs:bx+_75E2]
_75E2:
	DW	_75C1
	DW	_75C5
	DW	_75C5
	DW	_75C5
	DW	_75CA
	DW	_75CA
	DW	_75CA
	DW	_75CF
	DW	_75CF
	DW	_75C5
	DW	_75C5
	DW	_75C5
	DW	_75CA
	DW	_75CA
	DW	_75CA

_7600:
	pop bp
	pop di
	pop si
	ret

_7604:
	push si
	push di
	push bp
	mov bp,sp
	mov ax,[bp+0x8]
	pop bp
	pop di
	pop si
	ret

_7610:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	cmp byte [0x16d3],0x0
	jnz short _7628
	or si,si
	jz short _7628
	mov ax,0xff
	jmp short _762A
_7628:
	sub ax,ax
_762A:
	pop bp
	pop di
	pop si
	ret

_762E:
	push si
	push di
	push bp
	mov bp,sp
	mov byte [0x16d3],0x0
	push word [0x5cf]
	push word [0x5cd]
	call _7538
	add sp,byte +0x4
	call _9356
	call _33ED
	call _3807
	pop bp
	pop di
	pop si
	ret

_7653:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov di,si
	inc si
	mov al,[di]
	sub ah,ah
	mov [0x5dd],ax
	add ax,0x15
	mov [0x5df],ax
	cmp word [0x10c6],byte +0x2
	jnz short _768B
	cmp word [0x5dd],byte +0x1
	jna short _7681
	mov word [0x130d],0x6
	jmp short _7695
_7681:
	mov ax,[0x5dd]
	mul word [cs:_7761]
	jmp short _7692
_768B:
	mov ax,[0x5dd]
	mov cl,0x3
	shl ax,cl
_7692:
	mov [0x130d],ax
_7695:
	mov di,si
	inc si
	mov al,[di]
	sub ah,ah
	mov [0x5d5],ax
	mov di,si
	inc si
	mov al,[di]
	sub ah,ah
	mov [0x5db],ax
	mov ax,si
	pop bp
	pop di
	pop si
	ret

_76AF:
	push si
	push di
	push bp
	mov bp,sp
	cmp word [0x10c4],byte +0x0
	jnz short _76E5
	cmp byte [0x9],0x0
	jz short _76E5
	cmp word [0x10c6],byte +0x3
	jz short _76E5
	cmp word [0x10c6],byte +0x2
	jz short _76E5
	call _1331
	xor word [0x10c6],0x1
	call _2A69
	call _535C
	call _2A90
	call _65B1
_76E5:
	mov ax,[bp+0x8]
	pop bp
	pop di
	pop si
	ret
_76EC:
	push si
	push di
	push bp
	mov bp,sp
	cmp word [0x16f3],byte +0x5
	jnc short _7722
	mov ax,[0x16f3]
	mul word [cs:_7761]
	add ax,0x16d5
	mov si,ax
	mov ax,[0x5cd]
	mov [si],ax
	add si,byte +0x2
	mov di,si
	mov ax,[0x5cf]
	mov [di],ax
	add si,byte +0x2
	mov di,si
	mov ax,[0x5d1]
	mov [di],ax
	inc word [0x16f3]
_7722:
	pop bp
	pop di
	pop si
	ret
_7726:
	push si
	push di
	push bp
	mov bp,sp
	cmp word [0x16f3],byte +0x0
	jz short _775C
	dec word [0x16f3]
	mov ax,[0x16f3]
	mul word [cs:_7761]
	add ax,0x16d5
	mov si,ax
	mov ax,[si]
	mov [0x5cd],ax
	add si,byte +0x2
	mov di,si
	mov ax,[di]
	mov [0x5cf],ax
	add si,byte +0x2
	mov di,si
	mov ax,[di]
	mov [0x5d1],ax
_775C:
	pop bp
	pop di
	pop si
	ret

	DB	0x0

_7761:
	DW	0x0006

_7763:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	mov di,[bp+0x8]
	xor ch,ch
	mov cl,[di]
	inc di
	cmp byte [0x10c6],0x3
	jnz short _777F
	call _950E
	jmp short _77CD
_777F:
	cmp word [0x10c6],byte +0x2
	jnz short _778B
	call _9733
	jmp short _77CD
_778B:
	cmp word [0x10c4],byte +0x0
	jnz short _7799
	mov byte [0x16f5],0x70
	jmp short _779E
_7799:
	mov byte [0x16f5],0x38
_779E:
	mov dx,0x3d5
_77A1:
	lea si,[0x16f6]
_77A5:
	mov al,0x2
	dec dx
	out dx,al
	lodsb
	add al,[0x12f9]
	inc dx
	out dx,al
	mov al,0x7
	dec dx
	out dx,al
	lodsb
	add al,[0x16f5]
	inc dx
	out dx,al
	mov bx,[0x129]
_77BF:
	cmp bx,[0x129]
	jz short _77BF
	cmp al,[0x16f5]
	jnz short _77A5
	loop _77A1
_77CD:
	mov ax,di
	add sp,byte +0x2
	pop bp
	pop di
	pop si
	ret

_77D6:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	imul word [cs:_78A2]
	mov cx,ax
	mov ax,[0x951]
	add ax,cx
	mov di,ax
	or word [di+0x25],0x4
	mov bx,si
	inc si
	mov al,[bx]
	mov [di+0x24],al
	mov ax,si
	pop bp
	pop di
	pop si
	ret

_7806:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov di,si
	inc si
	mov al,[di]
	sub ah,ah
	imul word [cs:_78A2]
	mov di,ax
	add di,[0x951]
	and word [di+0x25],0xfffb
	mov ax,si
	pop bp
	pop di
	pop si
	ret

_782B:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	imul word [cs:_78A2]
	mov cx,ax
	mov ax,[0x951]
	add ax,cx
	mov di,ax
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	mov bx,ax
	mov al,[di+0x24]
	mov [bx+0x9],al
	mov ax,si
	pop bp
	pop di
	pop si
	ret

_785E:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	mov si,[bp+0x8]
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	imul word [cs:_78A2]
	mov cx,ax
	mov ax,[0x951]
	add ax,cx
	mov di,ax
	or word [di+0x25],0x4
	mov bx,si
	inc si
	mov al,[bx]
	mov [bp-0x2],al
	mov al,[bp-0x2]
	sub ah,ah
	mov bx,ax
	mov al,[bx+0x9]
	mov [di+0x24],al
	mov ax,si
	mov sp,bp
	pop bp
	pop di
	pop si
	ret

	DB	0x0

_78A2:
	DW	0x002B

_78A4:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov word [0x13d],0x1
	mov di,si
	inc si
	mov al,[di]
	sub ah,ah
	mov [0x131],ax
	mov di,si
	inc si
	mov al,[di]
	sub ah,ah
	mov [0x133],ax
	mov di,si
	inc si
	mov al,[di]
	sub ah,ah
	mov [0x135],ax
	mov di,si
	inc si
	mov al,[di]
	sub ah,ah
	mov [0x137],ax
	mov ax,si
	pop bp
	pop di
	pop si
	ret

_78E0:
	push si
	push di
	push bp
	mov bp,sp
	mov word [0x13d],0x0
	mov ax,[bp+0x8]
	pop bp
	pop di
	pop si
	ret

_78F2:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov di,si
	inc si
	mov al,[di]
	sub ah,ah
	imul word [cs:_796E]
	mov di,ax
	add di,[0x951]
	or word [di+0x25],0x2
	mov ax,si
	pop bp
	pop di
	pop si
	ret

_7917:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov di,si
	inc si
	mov al,[di]
	sub ah,ah
	imul word [cs:_796E]
	mov di,ax
	add di,[0x951]
	and word [di+0x25],0xfffd
	mov ax,si
	pop bp
	pop di
	pop si
	ret

_793C:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov di,[bp+0xa]
	mov ax,[0x131]
	cmp ax,si
	jnl short _7968
	mov ax,[0x135]
	cmp ax,si
	jng short _7968
	mov ax,[0x133]
	cmp ax,di
	jnl short _7968
	mov ax,[0x137]
	cmp ax,di
	jng short _7968
	mov ax,0x1
	jmp short _796A
_7968:
	sub ax,ax
_796A:
	pop bp
	pop di
	pop si
	ret

_796E:
	DW	0x002B

_7970:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	imul word [cs:_7C34]
	mov cx,ax
	mov ax,[0x951]
	add ax,cx
	mov di,ax
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	mov [di+0x16],ax
	mov [di+0x3],ax
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	mov [di+0x18],ax
	mov [di+0x5],ax
	mov ax,si
	pop bp
	pop di
	pop si
	ret

_79AD:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	imul word [cs:_7C34]
	mov cx,ax
	mov ax,[0x951]
	add ax,cx
	mov di,ax
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	mov bx,ax
	mov al,[bx+0x9]
	sub ah,ah
	mov [di+0x16],ax
	mov [di+0x3],ax
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	mov bx,ax
	mov al,[bx+0x9]
	sub ah,ah
	mov [di+0x18],ax
	mov [di+0x5],ax
	mov ax,si
	pop bp
	pop di
	pop si
	ret

_79FA:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	imul word [cs:_7C34]
	mov cx,ax
	mov ax,[0x951]
	add ax,cx
	mov di,ax
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	mov bx,ax
	mov ax,[di+0x3]
	mov [bx+0x9],al
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	mov bx,ax
	mov ax,[di+0x5]
	mov [bx+0x9],al
	mov ax,si
	pop bp
	pop di
	pop si
	ret

_7A3D:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	mov si,[bp+0x8]
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	imul word [cs:_7C34]
	mov cx,ax
	mov ax,[0x951]
	add ax,cx
	mov di,ax
	or word [di+0x25],0x400
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	mov bx,ax
	mov al,[bx+0x9]
	cbw
	mov [bp-0x2],ax
	or ax,ax
	jnl short _7A8A
	mov cx,[bp-0x2]
	neg cx
	mov ax,[di+0x3]
	cmp ax,cx
	jnl short _7A8A
	mov word [di+0x3],0x0
	jmp short _7A90
_7A8A:
	mov ax,[bp-0x2]
	add [di+0x3],ax
_7A90:
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	mov bx,ax
	mov al,[bx+0x9]
	cbw
	mov [bp-0x2],ax
	or ax,ax
	jnl short _7AB8
	mov cx,[bp-0x2]
	neg cx
	mov ax,[di+0x5]
	cmp ax,cx
	jnl short _7AB8
	mov word [di+0x5],0x0
	jmp short _7ABE
_7AB8:
	mov ax,[bp-0x2]
	add [di+0x5],ax
_7ABE:
	push di
	call _5753
	add sp,byte +0x2
	mov ax,si
	mov sp,bp
	pop bp
	pop di
	pop si
	ret

_7ACD:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	imul word [cs:_7C34]
	mov cx,ax
	mov ax,[0x951]
	add ax,cx
	mov di,ax
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	mov [di+0x3],ax
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	mov [di+0x5],ax
	or word [di+0x25],0x400
	push di
	call _5753
	add sp,byte +0x2
	mov ax,si
	pop bp
	pop di
	pop si
	ret

_7B10:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	imul word [cs:_7C34]
	mov cx,ax
	mov ax,[0x951]
	add ax,cx
	mov di,ax
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	mov bx,ax
	mov al,[bx+0x9]
	sub ah,ah
	mov [di+0x3],ax
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	mov bx,ax
	mov al,[bx+0x9]
	sub ah,ah
	mov [di+0x5],ax
	or word [di+0x25],0x400
	push di
	call _5753
	add sp,byte +0x2
	mov ax,si
	pop bp
	pop di
	pop si
	ret

_7B63:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov di,si
	inc si
	mov al,[di]
	sub ah,ah
	imul word [cs:_7C34]
	mov di,ax
	add di,[0x951]
	or word [di+0x25],0x100
	mov ax,si
	pop bp
	pop di
	pop si
	ret

_7B88:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov di,si
	inc si
	mov al,[di]
	sub ah,ah
	imul word [cs:_7C34]
	mov di,ax
	add di,[0x951]
	or word [di+0x25],0x800
	mov ax,si
	pop bp
	pop di
	pop si
	ret

_7BAD:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov di,si
	inc si
	mov al,[di]
	sub ah,ah
	imul word [cs:_7C34]
	mov di,ax
	add di,[0x951]
	and word [di+0x25],0xf6ff
	mov ax,si
	pop bp
	pop di
	pop si
	ret

_7BD2:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov di,si
	inc si
	mov al,[di]
	sub ah,ah
	mov [0x12d],ax
	mov ax,si
	pop bp
	pop di
	pop si
	ret

_7BEA:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov di,si
	inc si
	mov al,[di]
	sub ah,ah
	imul word [cs:_7C34]
	mov di,ax
	add di,[0x951]
	or word [di+0x25],0x8
	mov ax,si
	pop bp
	pop di
	pop si
	ret

_7C0F:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov di,si
	inc si
	mov al,[di]
	sub ah,ah
	imul word [cs:_7C34]
	mov di,ax
	add di,[0x951]
	and word [di+0x25],0xfff7
	mov ax,si
	pop bp
	pop di
	pop si
	ret

_7C34:
	DW	0x002B

_7C36:
	pop dx
	pop bx
	mov [bx],bp
	mov [bx+0x2],sp
	mov [bx+0x4],dx
	push bx
	push dx
	xor ax,ax
	ret

;------------------------------------------------------------------------------
; Free - Fail - Hang ???????
_7C45:
	pop dx
	pop bx
	pop ax
	mov bp,[bx]
	mov sp,[bx+0x2]
	push bx
	push word [bx+0x4]
	ret

_7C52:
	push si
	push di
	push bp
	mov bp,sp
	add word [0x129],byte +0x1
	adc word [0x12b],byte +0x0
	call _4396
	cmp word [0x613],byte +0x0
	jnz short _7CCA
	inc word [0x1700]
	inc word [0x1702]
_7C73:
	cmp word [0x1702],byte +0x14
	jl short _7CCA
	sub word [0x1702],byte +0x14
	inc byte [0x14]
	mov al,[0x14]
	sub ah,ah
	mov di,ax
	mov ax,di
	cmp ax,0x3c
	jc short _7C9A
	mov byte [0x14],0x0
	inc byte [0x15]
_7C9A:
	mov al,[0x15]
	sub ah,ah
	mov di,ax
	mov ax,di
	cmp ax,0x3c
	jc short _7CB1
	mov byte [0x15],0x0
	inc byte [0x16]
_7CB1:
	mov al,[0x16]
	sub ah,ah
	mov di,ax
	mov ax,di
	cmp ax,0x18
	jc short _7C73
	mov byte [0x16],0x0
	inc byte [0x17]
	jmp short _7C73
_7CCA:
	pop bp
	pop di
	pop si
	ret
_7CCE:
	push si
	push di
	push bp
	mov bp,sp
_7CD3:
	mov al,[0x13]
	sub ah,ah
	mov di,ax
	mov ax,[0x1700]
	cmp ax,di
	jc short _7CD3
	mov word [0x1700],0x0
	pop bp
	pop di
	pop si
	ret

	DB	0x0
_7CEC:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	mov si,[bp+0x8]
	add si,byte +0x6
	mov di,0x1704
	mov cx,0x4
	rep movsw
	mov ax,0x1
	mov di,0x170c
	mov cx,0x4
	rep stosw
	mov di,0x1714
	mov cx,0x4
	rep stosw
	cmp word [0x10c4],byte +0x0
	jnz short _7D29
	mov word [0x1724],0x2
	mov byte [0x1726],0x1
	jmp short _7D34
_7D29:
	mov word [0x1724],0x8
	mov byte [0x1726],0x4
_7D34:
	cmp word [0x10c4],byte +0x0
	jz short _7D41
	in al,0x61
	or al,0x60
	out 0x61,al
_7D41:
	mov word [0x11ec],0x1
	add sp,byte +0x2
	pop bp
	pop di
	pop si
	ret
_7D4E:
	push bx
	push cx
	push dx
	push si
	mov al,0x9
	call _7265
	or ax,ax
	jz short _7DCA
	xor bx,bx
_7D5D:
	cmp word [bx+0x1714],byte +0x0
	jnz short _7D6F
	add bx,byte +0x2
	cmp bx,[0x1724]
	jl short _7D5D
	jmp short _7DBE
_7D6F:
	dec word [bx+0x170c]
	jnz short _7DB5
	mov si,[bx+0x1704]
	lodsw
	cmp ax,0xffff
	jnz short _7DA2
	dec byte [0x1726]
	mov word [bx+0x1714],0x0
	mov cl,[bx+0x171c]
	mov dh,cl
	and dh,0xef
	xor dl,dl
	call _7E0C
	add bx,byte +0x2
	cmp bx,[0x1724]
	jl short _7D5D
	jmp short _7DBE
_7DA2:
	mov [bx+0x170c],ax
	lodsw
	mov dx,ax
	lodsb
	mov cl,al
	mov [bx+0x1704],si
	push bx
	call _7E0C
	pop bx
_7DB5:
	add bx,byte +0x2
	cmp bx,[0x1724]
	jl short _7D5D
_7DBE:
	cmp byte [0x1726],0x0
	jz short _7DCA
_7DC5:
	pop si
	pop dx
	pop cx
	pop bx
	ret
_7DCA:
	mov word [0x11ec],0x0
	mov al,[0x11fe]
	call _7251
	call _7DED
	jmp short _7DC5
_7DDB:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	call _7DED
	add sp,byte +0x2
	pop bp
	pop di
	pop si
	ret
_7DED:
	cmp word [0x10c4],byte +0x0
	jnz short _7DFB
	mov cl,0x9f
	call _7E0C
	jmp short _7E0B
_7DFB:
	mov al,0x9f
	out 0xc0,al
	mov al,0xbf
	out 0xc0,al
	mov al,0xdf
	out 0xc0,al
	mov al,0xff
	out 0xc0,al
_7E0B:
	ret
_7E0C:
	cmp word [0x10c4],byte +0x0
	jz short _7E42
	cmp word [0x10c4],byte +0x2
	jnz short _7E1D
	call _7E65
_7E1D:
	mov al,dh
	out 0xc0,al
	and al,0xe0
	cmp al,0xe0
	jz short _7E2B
	mov al,dl
	out 0xc0,al
_7E2B:
	mov al,cl
	and al,0xf
	add al,[0x20]
	cmp al,0xf
	jng short _7E39
	mov al,0xf
_7E39:
	and cl,0xf0
	or al,cl
	out 0xc0,al
	jmp short _7E64
_7E42:
	cmp cl,0x9f
	jnz short _7E4F
	in al,0x61
	and al,0xfc
	out 0x61,al
	jmp short _7E64
_7E4F:
	call _7E82
	mov al,0xb6
	out 0x43,al
	mov ax,bx
	out 0x42,al
	mov al,ah
	out 0x42,al
	in al,0x61
	or al,0x3
	out 0x61,al
_7E64:
	ret
_7E65:
	mov ch,cl
	and ch,0x90
	cmp ch,0x90
	jnz short _7E81
	mov ch,cl
	and ch,0xf
	cmp ch,0x8
	jnl short _7E81
	and cl,0xf0
	add ch,0x3
	or cl,ch
_7E81:
	ret
_7E82:
	and dh,0xf
	mov bl,dh
	xor dh,dh
	and dl,0x3f
	mov cl,0x4
	shl dx,cl
	add bx,dx
	shl bx,1
	shl bx,1
	mov dx,bx
	shl bx,1
	add bx,dx
	ret

_7E9D:
	push si
	push di
	push bp
	mov bp,sp
	call _437E
	call _7EC2
	call SetInterruptsVectors
	sub si,si
	jmp short _7EB0
_7EAF:
	inc si
_7EB0:
	cmp si,byte +0x5
	jnc short _7EBE
	push si
	call FileClose
	add sp,byte +0x2
	jmp short _7EAF
_7EBE:
	pop bp
	pop di
	pop si
	ret

;------------------------------------------------------------------------------
; LoadVideoDriver
_7EC2:
	push si
	push di
	push bp
	mov bp,sp
	call GetCurrentVideoMode
	mov [0x1727],ax
	cmp word [0x10c6],byte +0x2
	jnz short _7EDC
;	mov si,0x6						; HGC_OBJS.OVL
;	mov di,0x4
;	jmp short _7EFA
_7EDC:
	mov si,0x5
	cmp word [0x10c6],byte +0x3
	jnz short _7EEB
	mov di,0x3
	jmp short _7EFA
_7EEB:
	cmp word [0x10c4],byte +0x0
	jnz short _7EF7
	mov di,0x1
	jmp short _7EFA
_7EF7:
	mov di,0x2
_7EFA:
	push di
	;call LoadOVL
	add sp,byte +0x2
	push si
	;call LoadOVL
	add sp,byte +0x2
	call _535C						; Set Video Mode
	pop bp
	pop di
	pop si
	ret

_7F0F:
	push si
	push di
	push bp
	mov bp,sp
	call _8026
	call RestoreInterruptsVectors
	push word [0x1727]
	call SetVideoMode
	add sp,byte +0x2
	pop bp
	pop di
	pop si
	ret

	DB 0

_7F29:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,0x3ea
	mov di,[bp+0x8]
	inc word [bp+0x8]
	mov al,[di]
	sub ah,ah
	mov [bp-0x3ea],ax
	cmp word [0x1743],byte -0x1
	jnz short _7F4A
	call _7FD9
_7F4A:
	cmp word [0x1743],byte -0x1
	jz short _7FD0
	push word [0x1743]
	call _5BAD
	add sp,byte +0x2
	mov di,ax
	mov si,di
	mov ax,di
	cmp ax,0xffff
	jz short _7FD0
	mov ax,0xf64
	push ax
	mov al,[0x9]
	sub ah,ah
	push ax
	mov ax,0x1729
	push ax
	lea ax,[bp-0x3e8]
	push ax
	call _2337
	add sp,byte +0x8
	lea ax,[bp-0x3e8]
	push ax
	call _4BCE
	add sp,byte +0x2
	push ax
	lea ax,[bp-0x3e8]
	push ax
	push si
	call _5B2B
	add sp,byte +0x6
	mov ax,0x4e
	push ax
	push word [bp-0x3ea]
	call _21B3
	add sp,byte +0x2
	push ax
	lea ax,[bp-0x3e8]
	push ax
	call _1F17
	add sp,byte +0x6
	lea ax,[bp-0x3e8]
	push ax
	call _4BCE
	add sp,byte +0x2
	push ax
	lea ax,[bp-0x3e8]
	push ax
	push si
	call _5B2B
	add sp,byte +0x6
	push si
	call FileClose
	add sp,byte +0x2
_7FD0:
	mov ax,[bp+0x8]
	mov sp,bp
	pop bp
	pop di
	pop si
	ret
_7FD9:
	push si
	push di
	push bp
	mov bp,sp
	cmp word [0x1743],byte -0x1
	jnz short _8022
	mov ax,0x2
	push ax
	mov ax,0x1745
	push ax
	call FileOpen
	add sp,byte +0x4
	mov di,ax
	mov [0x1743],di
	mov ax,di
	cmp ax,0xffff
	jnz short _8010
	sub ax,ax
	push ax
	mov ax,0x1745
	push ax
	call _5AC6
	add sp,byte +0x4
	mov [0x1743],ax
_8010:
	mov ax,0x2
	push ax
	sub ax,ax
	push ax
	push ax
	push word [0x1743]
	call _5B84
	add sp,byte +0x8
_8022:
	pop bp
	pop di
	pop si
	ret

_8026:
	push si
	push di
	push bp
	mov bp,sp
	cmp word [0x1743],byte -0x1
	jz short _8042
	push word [0x1743]
	call FileClose
	add sp,byte +0x2
	mov word [0x1743],0xffff
_8042:
	pop bp
	pop di
	pop si
	ret

	DB	0x0

; Address para las interrupts
; 0x8254
; 0x5e48
; 0x81bb
; 0x81e6
; 0x8255
; 0xe3c
; 0x959a
SetInterruptsVectors:
	push es
	mov al,0x5
	mov ah,0x35				; Get Interrupt Vector
	int 0x21
	mov [0x175d],bx
	mov [0x175f],es
	mov al,0x9
	mov ah,0x35				; Get Interrupt Vector
	int 0x21
	mov [0x1761],bx
	mov [0x1763],es
	mov al,0x8
	mov ah,0x35				; Get Interrupt Vector
	int 0x21
	mov [0x174d],bx
	mov [0x174f],es
	mov al,0x1c
	mov ah,0x35				; Get Interrupt Vector
	int 0x21
	mov [0x1751],bx
	mov [0x1753],es
	mov al,0x23
	mov ah,0x35				; Get Interrupt Vector
	int 0x21
	mov [0x1755],bx
	mov [0x1757],es
	mov al,0x24
	mov ah,0x35				; Get Interrupt Vector
	int 0x21
	mov [0x1759],bx
	mov [0x175b],es
	mov al,0x1f
	mov ah,0x35				; Get Interrupt Vector
	int 0x21
	mov [0x1769],bx
	mov [0x176b],es
	cmp word [0x10c6],byte +0x2
	jnz short _80BF
	mov al,0x10
	mov ah,0x35				; Get Interrupt Vector
	int 0x21
	mov [0x1765],bx
	mov [0x1767],es
_80BF:
	pop es
	push ds
	mov dx,DisabledInterrupt
	mov ax,cs
	mov ds,ax
	mov al,0x5
	mov ah,0x25				; Set Interrupt Vector
	int 0x21
	mov al,0x23
	mov ah,0x25				; Set Interrupt Vector
	int 0x21
	mov dx,IRQ1_INT9_KeyboardDataReady
	mov ax,cs
	mov ds,ax
	mov al,0x9
	mov ah,0x25				; Set Interrupt Vector
	int 0x21
	mov al,0x36
	out 0x43,al
	mov ax,0x4dae
	out 0x40,al
	xchg ah,al
	out 0x40,al
	mov dx,IRQ0_INT8_SystemTimer
	mov ax,cs
	mov ds,ax
	mov al,0x8
	mov ah,0x25				; Set Interrupt Vector
	int 0x21
	mov dx,INT1C_SystemTimerTick
	mov ax,cs
	mov ds,ax
	mov al,0x1c
	mov ah,0x25				; Set Interrupt Vector
	int 0x21
	mov dx,INT24_CriticalErrorHandler
	mov ax,cs
	mov ds,ax
	mov al,0x24				; 810F
	mov ah,0x25				; Set Interrupt Vector
	int 0x21
	mov dx,0xe3c			; FONT
	mov ax,es
	mov ds,ax
	mov al,0x1f				; SYSTEM DATA - 8x8 GRAPHICS FONT
	mov ah,0x25				; Set Interrupt Vector
	int 0x21
	cmp word [es:0x10c6],byte +0x2
	jnz short _8137
	mov dx,_959A
	mov ax,cs
	mov ds,ax
	mov al,0x10
	mov ah,0x25				; Set Interrupt Vector
	int 0x21
_8137:
	pop ds
	ret

RestoreInterruptsVectors:
	lds dx,[0x1769]
	mov al,0x1f
	mov ah,0x25				; Set Interrupt Vector
	int 0x21
	mov ax,es
	mov ds,ax
	lds dx,[0x175d]
	mov al,0x5
	mov ah,0x25				; Set Interrupt Vector
	int 0x21
	mov ax,es
	mov ds,ax
	mov al,0x36
	out 0x43,al
	xor al,al
	out 0x40,al
	out 0x40,al
	lds dx,[0x174d]
	mov al,0x8
	mov ah,0x25				; Set Interrupt Vector
	int 0x21
	mov ax,es
	mov ds,ax
	lds dx,[0x1751]
	mov al,0x1c
	mov ah,0x25				; Set Interrupt Vector
	int 0x21
	mov ax,es
	mov ds,ax
	lds dx,[0x1761]
	mov al,0x9
	mov ah,0x25				; Set Interrupt Vector
	int 0x21
	mov ax,es
	mov ds,ax
	lds dx,[0x1755]
	mov al,0x23
	mov ah,0x25				; Set Interrupt Vector
	int 0x21
	mov ax,es
	mov ds,ax
	lds dx,[0x1759]
	mov al,0x24
	mov ah,0x25				; Set Interrupt Vector
	int 0x21
	mov ax,es
	mov ds,ax
	cmp word [0x10c6],byte +0x2
	jnz short _81BA
	lds dx,[0x1765]
	mov al,0x10
	mov ah,0x25				; Set Interrupt Vector
	int 0x21
	mov ax,es
	mov ds,ax
_81BA:
	ret

IRQ0_INT8_SystemTimer:
	push ax
	push ds
	mov ax, SEG AGIDATA
	mov ds,ax
	cld
	cmp word [0x11ec],byte +0x0
	jz short _81CD
	call _7D4E
_81CD:
	dec byte [0x176f]
	jz short _81D9
	mov al,0x20
	out 0x20,al
	jmp short _81E3
_81D9:
	mov byte [0x176f],0x3
	pushf
	call far [0x174d]
_81E3:
	pop ds
	pop ax
	iret

INT1C_SystemTimerTick:
	cli
	push ax
	push bx
	push cx
	push dx
	push si
	push di
	push bp
	push ds
	push es
	mov ax, SEG AGIDATA
	mov ds,ax
	mov es,ax
	call _7C52
	pushf
	call far [0x1751]			; call original INT 1C
	mov si,[0x0]
	cmp word [si],0xaaaa
	jz short _8217
	mov word [si],0xaaaa
	mov bx,sp
	mov word [bx+0x12],_8222
	mov [bx+0x14],cs
_8217:
	pop es
	pop ds
	pop bp
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	sti
	iret

_8222:
	mov ax, SEG AGIDATA
	mov ds,ax
	mov es,ax
	mov ax,[0x0]
	add ax,0xa00
	mov sp,ax
	call _3EF5
	call _3EF5
	push ax
	lea ax,[0x1770]
	mov [bp-0x2],ax
	pop ax
	push word [bp-0x2]
	call _1D59
	add sp,byte +0x2
_8249:
	call GetPressedKey
	cmp ax,0x1b
	jnz short _8249
	call TerminateProgram

DisabledInterrupt:				; 8254
	iret

INT24_CriticalErrorHandler:		; 8255
	add sp,byte +0x6
	mov ax, SEG AGIDATA
	mov ds,ax
	and di,0xff
	jnz short _8266
	mov di,0x100
_8266:
	mov [0x176d],di
	mov bp,sp
	mov ax,[bp+0x16]
	or ax,0x1
	mov [bp+0x16],ax
	pop ax
	pop bx
	pop cx
	pop dx
	pop si
	pop di
	pop bp
	pop ds
	pop es
	iret
_827F:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,0xa4
	call _3793
	mov [bp-0xa4],ax
	call _375E
	call _76EC
	call _2A69
	call _5068
	mov ax,0xf
	push ax
	sub ax,ax
	push ax
	call _7538
	add sp,byte +0x4
	push word [bp+0x8]
	call _8382
	add sp,byte +0x2
	or ax,ax
	jnz short _82BD
_82B5:
	mov word [bp-0x2],0x0
	jmp _8369
_82BD:
	mov al,[0x12f7]
	sub ah,ah
	mov di,ax
	mov ax,di
	cmp ax,0x62
	jnz short _82DD
	cmp word [0x10be],byte +0x0
	jnz short _82DD
	mov ax,0x61
	mov [0x17a4],al
	sub ah,ah
	mov [0x12f7],al
_82DD:
	mov al,[0x12f7]
	sub ah,ah
	mov di,ax
	call _5C03
	cmp ax,di
	jnz short _832F
	mov al,[0x12f7]
	sub ah,ah
	mov di,ax
	mov ax,di
	cmp ax,0x62
	ja short _832F
	call _3006
	cmp word [bp+0x8],byte +0x72
	jnz short _8307
	mov ax,0x1790
	jmp short _830A
_8307:
	mov ax,0x1798
_830A:
	push ax
	mov al,[0x12f7]
	sub ah,ah
	push ax
	mov ax,0x1888
	push ax
	lea ax,[bp-0xa2]
	push ax
	call _2337
	add sp,byte +0x8
	lea ax,[bp-0xa2]
	push ax
	call _1CAB
	add sp,byte +0x2
	or ax,ax
	jz short _82B5
_832F:
	push word [bp+0x8]
	call _848E
	add sp,byte +0x2
	mov [bp-0x2],ax
	cmp word [bp-0x2],byte +0x0
	jz short _8369
	cmp word [bp+0x8],byte +0x73
	jnz short _835C
	mov ax,0x1aae
	push ax
	mov ax,0x19ec
	push ax
	call _840E
	add sp,byte +0x4
	or ax,ax
	jnz short _835C
	jmp _82B5
_835C:
	push word [bp-0x2]
	mov ax,0x1ace
	push ax
	call _598C
	add sp,byte +0x4
_8369:
	call _2A90
	call _7726
	cmp word [bp-0xa4],byte +0x0
	jz short _8379
	call _3727
_8379:
	mov ax,[bp-0x2]
	mov sp,bp
	pop bp
	pop di
	pop si
	ret
_8382:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,0xa0
	cmp byte [0x17a4],0x0
	jnz short _839C
	mov ax,0x17a4
	push ax
	call _5BCB
	add sp,byte +0x2
_839C:
	mov ax,0x12cd
	push ax
	cmp word [bp+0x8],byte +0x73
	jnz short _83AB
	mov ax,0x17c4
	jmp short _83AE
_83AB:
	mov ax,0x1822
_83AE:
	push ax
	lea ax,[bp-0xa0]
	push ax
	call _2337
	add sp,byte +0x6
	mov ax,0x17a4
	push ax
	lea ax,[bp-0xa0]
	push ax
	call _840E
	add sp,byte +0x4
	or ax,ax
	jnz short _83D1
_83CD:
	sub ax,ax
	jmp short _8408
_83D1:
	mov ax,0x17a4
	push ax
	call _59F6
	add sp,byte +0x2
	or ax,ax
	jz short _83E4
	mov ax,0x1
	jmp short _8408
_83E4:
	mov ax,0x17a4
	push ax
	mov ax,0x1a5e
	push ax
	lea ax,[bp-0xa0]
	push ax
	call _2337
	add sp,byte +0x6
	lea ax,[bp-0xa0]
	push ax
	call _1CAB
	add sp,byte +0x2
	or ax,ax
	jnz short _839C
	jmp short _83CD
_8408:
	mov sp,bp
	pop bp
	pop di
	pop si
	ret
_840E:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x4
	mov ax,0x1
	push ax
	mov ax,0x1f
	push ax
	sub ax,ax
	push ax
	push word [bp+0x8]
	call _1D59
	add sp,byte +0x8
	mov ax,[0xd03]
	mov [bp-0x4],ax
	push word [0xd01]
	push ax
	call _2A4E
	add sp,byte +0x4
	sub ax,ax
	push ax
	mov ax,[0xd05]
	add ax,0xffff
	push ax
	push word [bp-0x4]
	push word [0xd01]
	push word [bp-0x4]
	call _2B05
	add sp,byte +0xa
	call _76EC
	sub ax,ax
	push ax
	mov ax,0xf
	push ax
	call _7538
	add sp,byte +0x4
	mov ax,0x1f
	push ax
	push word [bp+0xa]
	call _D76
	add sp,byte +0x4
	mov [bp-0x2],ax
	call _7726
	call _1EEE
	cmp word [bp-0x2],byte +0xd
	jnz short _8486
	mov ax,0x1
	jmp short _8488
_8486:
	sub ax,ax
_8488:
	mov sp,bp
	pop bp
	pop di
	pop si
	ret
_848E:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,0x202
	mov word [bp-0x1fe],0x0
	mov word [bp-0x1fc],0x0
	mov word [bp-0x1f6],0x0
	cmp word [bp+0x8],byte +0x73
	jnz short _851E
	mov word [bp-0x1f2],0x0
	jmp short _84BB
_84B7:
	inc word [bp-0x1f2]
_84BB:
	cmp word [bp-0x1f2],byte +0xc
	jnc short _8516
	lea ax,[bp-0x202]
	push ax
	mov ax,[bp-0x1f2]
	mul word [cs:_880D]
	add ax,bp
	sub ax,0x18c
	push ax
	mov ax,[bp-0x1f2]
	inc ax
	push ax
	call _871D
	add sp,byte +0x6
	or ax,ax
	jz short _84B7
	mov ax,[bp-0x202]
	mov dx,[bp-0x200]
	cmp dx,[bp-0x1fc]
	jg short _84FC
	jl short _84B7
	cmp ax,[bp-0x1fe]
	jna short _84B7
_84FC:
	mov ax,[bp-0x202]
	mov dx,[bp-0x200]
	mov [bp-0x1fe],ax
	mov [bp-0x1fc],dx
	mov ax,[bp-0x1f2]
	mov [bp-0x1f6],ax
	jmp short _84B7
_8516:
	mov word [bp-0x1f4],0xc
	jmp short _858D
_851E:
	sub ax,ax
	mov [bp-0x1f4],ax
	mov [bp-0x1f2],ax
	jmp short _852E
_852A:
	inc word [bp-0x1f2]
_852E:
	cmp word [bp-0x1f2],byte +0xc
	jnc short _858D
	lea ax,[bp-0x202]
	push ax
	mov ax,[bp-0x1f4]
	mul word [cs:_880D]
	add ax,bp
	sub ax,0x18c
	push ax
	mov ax,[bp-0x1f2]
	inc ax
	push ax
	call _871D
	add sp,byte +0x6
	or ax,ax
	jz short _852A
	mov ax,[bp-0x202]
	mov dx,[bp-0x200]
	cmp dx,[bp-0x1fc]
	jg short _856F
	jl short _8587
	cmp ax,[bp-0x1fe]
	jna short _8587
_856F:
	mov ax,[bp-0x202]
	mov dx,[bp-0x200]
	mov [bp-0x1fe],ax
	mov [bp-0x1fc],dx
	mov ax,[bp-0x1f4]
	mov [bp-0x1f6],ax
_8587:
	inc word [bp-0x1f4]
	jmp short _852A
_858D:
	cmp word [bp-0x1f4],byte +0x0
	jnz short _85B7
	mov ax,0x17a4
	push ax
	mov ax,0x1a1e
	push ax
	lea ax,[bp-0x1f0]
	push ax
	call _2337
	add sp,byte +0x6
	lea ax,[bp-0x1f0]
	push ax
	call _1CAB
	add sp,byte +0x2
_85B2:
	sub ax,ax
	jmp _8717
_85B7:
	mov word [bp-0x1fa],0x5
	mov ax,[bp-0x1fa]
	add ax,[bp-0x1f4]
	mov [bp-0x1f8],ax
	mov ax,0x1
	push ax
	mov ax,0x22
	push ax
	push word [bp-0x1f8]
	cmp word [bp+0x8],byte +0x73
	jnz short _85E0
	mov ax,0x18ea
	jmp short _85E3
_85E0:
	mov ax,0x196e
_85E3:
	push ax
	call _1D59
	add sp,byte +0x8
	mov ax,[0xcff]
	add [bp-0x1fa],ax
	mov word [bp-0x1f2],0x0
	jmp short _85FD
_85F9:
	inc word [bp-0x1f2]
_85FD:
	mov ax,[bp-0x1f2]
	cmp ax,[bp-0x1f4]
	jnc short _8635
	push word [0xd01]
	add ax,[bp-0x1fa]
	push ax
	call _2A4E
	add sp,byte +0x4
	mov ax,[bp-0x1f2]
	mul word [cs:_880D]
	mov di,ax
	mov ax,bp
	add ax,di
	sub ax,0x18a
	push ax
	mov ax,0x179d
	push ax
	call _2353
	add sp,byte +0x4
	jmp short _85F9
_8635:
	mov ax,[bp-0x1f6]
_8639:
	mov [bp-0x1f2],ax
	add ax,[bp-0x1fa]
	push ax
	call _87CC
	add sp,byte +0x2
_8648:
	call _4425
	mov si,ax
	push si
	call _4530
	add sp,byte +0x2
	mov ax,[si]
	jmp _8707
_8659:
	mov ax,[si+0x2]
	jmp short _8698
_865E:
	mov ax,[bp-0x1f2]
	mul word [cs:_880D]
	mov di,ax
	mov ax,bp
	add ax,di
	sub ax,0x18a
	push ax
	mov ax,0x1aae
	push ax
	call _4BE9
	add sp,byte +0x4
	call _1EEE
	mov ax,[bp-0x1f2]
	mul word [cs:_880D]
	mov di,ax
	add di,bp
	mov ax,[di-0x18c]
	jmp _8717
_8692:
	call _1EEE
	jmp _85B2
_8698:
	cmp ax,0xd
	jz short _865E
	cmp ax,0x1b
	jz short _8692
	jmp short _8648
_86A4:
	mov ax,[si+0x2]
	jmp short _86FA
_86A9:
	mov ax,[bp-0x1f2]
	add ax,[bp-0x1fa]
	push ax
	call _87EC
	add sp,byte +0x2
	cmp word [bp-0x1f2],byte +0x0
	jnz short _86C5
	mov ax,[bp-0x1f4]
	jmp short _86C9
_86C5:
	mov ax,[bp-0x1f2]
_86C9:
	add ax,0xffff
	jmp _8639
_86CF:
	mov ax,[bp-0x1f2]
	add ax,[bp-0x1fa]
	push ax
	call _87EC
	add sp,byte +0x2
	mov di,[bp-0x1f4]
	add di,byte -0x1
	mov ax,[bp-0x1f2]
	cmp ax,di
	jnz short _86F2
	sub ax,ax
	jmp _8639
_86F2:
	mov ax,[bp-0x1f2]
	inc ax
	jmp _8639
_86FA:
	cmp ax,0x1
	jz short _86A9
	cmp ax,0x5
	jz short _86CF
	jmp _8648
_8707:
	cmp ax,0x1
	jnz short _870F
	jmp _8659
_870F:
	cmp ax,0x2
	jz short _86A4
	jmp _8648
_8717:
	mov sp,bp
	pop bp
	pop di
	pop si
	ret
_871D:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x49
	mov di,[bp+0xa]
	mov ax,[bp+0x8]
	mov [di],ax
	push word [bp+0x8]
	lea ax,[bp-0x40]
	push ax
	call _598C
	add sp,byte +0x4
	sub ax,ax
	push ax
	lea ax,[bp-0x40]
	push ax
	call FileOpen
	add sp,byte +0x4
	mov di,ax
	mov [bp-0x49],di
	mov ax,di
	cmp ax,0xffff
	jnz short _875E
_8753:
	mov di,[bp+0xa]
	mov byte [di+0x2],0x0
	sub ax,ax
	jmp short _87C6
_875E:
	push word [bp-0x49]
	call _5C8C
	add sp,byte +0x2
	mov di,[bp+0xc]
	mov [di],ax
	mov [di+0x2],dx
	mov ax,0x1f
	push ax
	mov ax,[bp+0xa]
	inc ax
	inc ax
	push ax
	push word [bp-0x49]
	call _5B08
	add sp,byte +0x6
	mov ax,0x1
	push ax
	mov ax,0x0
	push ax
	mov ax,0x2
	push ax
	push word [bp-0x49]
	call _5B84
	add sp,byte +0x8
	mov ax,0x7
	push ax
	lea ax,[bp-0x47]
	push ax
	push word [bp-0x49]
	call _5B08
	add sp,byte +0x6
	push word [bp-0x49]
	call FileClose
	add sp,byte +0x2
	mov ax,0x2
	push ax
	lea ax,[bp-0x47]
	push ax
	call _4C98
	add sp,byte +0x4
	or ax,ax
	jnz short _8753
	mov ax,0x1
_87C6:
	mov sp,bp
	pop bp
	pop di
	pop si
	ret
_87CC:
	push si
	push di
	push bp
	mov bp,sp
	push word [0xd01]
	push word [bp+0x8]
	call _2A4E
	add sp,byte +0x4
	mov ax,0x1a
	push ax
	call _2953
	add sp,byte +0x2
	pop bp
	pop di
	pop si
	ret
_87EC:
	push si
	push di
	push bp
	mov bp,sp
	push word [0xd01]
	push word [bp+0x8]
	call _2A4E
	add sp,byte +0x4
	mov ax,0x20
	push ax
	call _2953
	add sp,byte +0x2
	pop bp
	pop di
	pop si
	ret

	DB	0x0
_880D:
	DB	0x21
	DB	0x0

_880F:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	cmp word [0x1b52],byte +0x0
	jz short _8823
	lea ax,[si+0x1]
	jmp short _8828
_8823:
	call _882C
	mov ax,si
_8828:
	pop bp
	pop di
	pop si
	ret

;------------------------------------------------------------------------------
_882C:
	push si
	push di
	push bp
	mov bp,sp
	cmp word [0x1b52],byte +0x0
	jnz short _88B7
	mov ax,0xa
	push ax
	call _7247
	add sp,byte +0x2
	or ax,ax
	jz short _88B7
	mov word [0x1b52],0x1
	mov ax,[0x5dd]
	add ax,[0x1b4a]
	inc ax
	mov [0x1b56],ax
	mov ax,[0x1b4c]
	add ax,[0x1b56]
	add ax,0xffff
	mov [0x1b5a],ax
	mov word [0x1b58],0x2
	mov ax,[0x1b58]
	add ax,0x23
	mov [0x1b5c],ax
	mov di,[0x1b5a]
	mov cl,0x3
	shl di,cl
	add di,byte +0x5
	mov ax,[0x1b58]
	shl ax,1
	shl ax,1
	add ax,0xfffb
	mov cl,0x8
	shl ax,cl
	or ax,di
	mov [0x1b5e],ax
	mov ax,[0x1b4c]
	mov cl,0x3
	shl ax,cl
	add ax,0xa
	mov cl,0x8
	shl ax,cl
	or ax,0x9a
	mov [0x1b60],ax
	mov ax,0x40f
	push ax
	push word [0x1b60]
	push word [0x1b5e]
	call _53C4
	add sp,byte +0x6
_88B7:
	pop bp
	pop di
	pop si
	ret

_88BB:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov di,si
	inc si
	mov al,[di]
	sub ah,ah
	mov [0x1b54],ax
	mov di,si
	inc si
	mov al,[di]
	sub ah,ah
	mov [0x1b4a],ax
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	mov di,ax
	mov [0x1b4c],di
	mov ax,di
	cmp ax,0x2
	jnc short _88F1
	mov word [0x1b4c],0x2
_88F1:
	mov ax,si
	pop bp
	pop di
	pop si
	ret
_88F7:
	push si
	push di
	push bp
	mov bp,sp
	cmp word [0x1b52],byte +0x0
	jz short _891D
	mov word [0x1b52],0x0
	mov word [0x1b4e],0xffff
	push word [0x1b60]
	push word [0x1b5e]
	call _5440
	add sp,byte +0x4
_891D:
	pop bp
	pop di
	pop si
	ret
_8921:
	push si
	push di
	push bp
	mov bp,sp
	mov word [0x1b50],0x0
	mov ax,0xffff
	push ax
	sub ax,ax
	push ax
	push word [bp+0xa]
	mov ax,0x61b
	push ax
	push word [bp+0x8]
	call _8989
	add sp,byte +0xa
	pop bp
	pop di
	pop si
	ret
_8947:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	mov di,[bp+0xa]
	inc word [bp+0xa]
	mov al,[di]
	sub ah,ah
	mov [bp-0x2],ax
	cmp word [bp-0x2],byte +0xe
	jnz short _8967
	mov ax,0x1
	jmp short _8969
_8967:
	sub ax,ax
_8969:
	mov [0x1b50],ax
	push word [bp+0x8]
	mov ax,0xdc
	push ax
	push word [bp+0xa]
	mov ax,0x8e3
	push ax
	push word [bp-0x2]
	call _8989
	add sp,byte +0xa
	mov sp,bp
	pop bp
	pop di
	pop si
	ret

;------------------------------------------------------------------------------
; param 1 = index in array of WORD + WORD, second WORD
_8989:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x4
	mov ax,[bp+0x8]
	shl ax,1
	shl ax,1
	add [bp+0xa],ax
	call _2A69
	call _76EC
	mov ax,0xf
	push ax
	sub ax,ax
	push ax
	call _7538
	add sp,byte +0x4
	call _8BF2
	cmp word [0x1b62],byte +0x0
	jz short _89CB
	mov word [0x1b62],0x0
	mov ax,0x1b0e
	push ax
	call _2353
	add sp,byte +0x2
	call _8BF2
_89CB:
	mov ax,[0x967]
	mov [bp-0x2],ax
	cmp word [0x1b54],byte +0x0
	jz short _89E9
	push word [0x1b54]
	call _10DC
	add sp,byte +0x2
	mov [0x967],ax
	or ax,ax
	jnz short _89FB
_89E9:
	push word [bp+0x8]
	mov di,[0x967]
	mov al,[di+0x2]
	sub ah,ah
	push ax
	mov ax,0x1b29
	jmp short _8A20
_89FB:
	cmp word [bp+0x8],byte +0x0
	jnz short _8A06
	mov ax,0x1b37
	jmp short _8A13
_8A06:
	mov ax,[bp+0xe]
	add ax,[bp+0x8]
	push ax
	call _21B3
	add sp,byte +0x2
_8A13:
	push ax
	mov di,[bp-0x2]
	mov al,[di+0x2]
	sub ah,ah
	push ax
	mov ax,0x1b30
_8A20:
	push ax
	call _2353
	add sp,byte +0x6
	mov ax,[bp-0x2]
	mov [0x967],ax
	push word [bp+0xc]
	push word [bp+0xa]
	call _8AA7
	add sp,byte +0x4
	cmp word [bp+0x10],byte -0x1
	jz short _8A69
	mov ax,[0x1b5c]
	add ax,0xfffe
	push ax
	push word [0x1b5a]
	call _2A4E
	add sp,byte +0x4
	cmp word [bp+0x10],byte +0x0
	jnz short _8A5B
	mov ax,0x46
	jmp short _8A5E
_8A5B:
	mov ax,0x54
_8A5E:
	push ax
	mov ax,0x1b3e
	push ax
	call _2353
	add sp,byte +0x4
_8A69:
	cmp word [0x1b52],byte +0x0
	jz short _8A84
	call _43F5
	mov [bp-0x4],ax
	or ax,ax
	jz short _8A69
	mov di,[bp-0x4]
	mov ax,[di]
	cmp ax,0x1
	jnz short _8A69
_8A84:
	cmp word [bp-0x4],byte +0x0
	jz short _8A9B
	mov di,[bp-0x4]
	mov ax,[di+0x2]
	cmp ax,0x2b
	jnz short _8A9B
	mov word [0x1b52],0x2
_8A9B:
	call _2A90
	call _7726
	mov sp,bp
	pop bp
	pop di
	pop si
	ret
_8AA7:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0xa
	call _2A69
	cmp word [0x1b50],byte +0x0
	jz short _8AC3
	mov di,[bp+0xa]
	inc word [bp+0xa]
	mov al,[di]
	jmp short _8AC9
_8AC3:
	mov di,[bp+0x8]
	mov al,[di+0x2]
_8AC9:
	sub ah,ah
	mov [bp-0x6],ax
	mov di,[bp+0x8]
	mov al,[di+0x3]
	sub ah,ah
	mov [bp-0x2],ax
	mov ax,0x28
	push ax
	call _2953
	add sp,byte +0x2
	mov word [bp-0x8],0x0
_8AE8:
	mov ax,[bp-0x8]
	cmp ax,[bp-0x6]
	jnc short _8B21
	push ax
	push word [bp+0xa]
	call _8BB5
	add sp,byte +0x4
	mov [bp-0xa],ax
	push ax
	mov ax,0x1b43
	push ax
	call _2353
	add sp,byte +0x4
	inc word [bp-0x8]
	mov di,[bp-0x8]
	mov ax,di
	cmp ax,[bp-0x6]
	jnc short _8AE8
	mov ax,0x2c
	push ax
	call _2953
	add sp,byte +0x2
	jmp short _8AE8
_8B21:
	mov ax,0x29
	push ax
	call _2953
	add sp,byte +0x2
	cmp word [bp-0x2],byte +0x0
	jz short _8B34
	call _8BF2
_8B34:
	call _2A90
	cmp word [bp-0x2],byte +0x0
	jz short _8BAF
	mov word [bp-0x4],0x80
	mov ax,0x28
	push ax
	call _2953
	add sp,byte +0x2
	mov word [bp-0x8],0x0
	jmp short _8B56
_8B53:
	shr word [bp-0x4],1
_8B56:
	mov ax,[bp-0x8]
	cmp ax,[bp-0x6]
	jnc short _8BA5
	push ax
	push word [bp+0xa]
	call _8BB5
	add sp,byte +0x4
	mov [bp-0xa],ax
	mov ax,[bp-0x2]
	and ax,[bp-0x4]
	jnz short _8B78
	push word [bp-0xa]
	jmp short _8B82
_8B78:
	mov di,[bp-0xa]
	mov al,[di+0x9]
	sub ah,ah
	push ax
_8B82:
	mov ax,0x1b46
	push ax
	call _2353
	add sp,byte +0x4
	inc word [bp-0x8]
	mov di,[bp-0x8]
	mov ax,di
	cmp ax,[bp-0x6]
	jnc short _8B53
	mov ax,0x2c
	push ax
	call _2953
	add sp,byte +0x2
	jmp short _8B53
_8BA5:
	mov ax,0x29
	push ax
	call _2953
	add sp,byte +0x2
_8BAF:
	mov sp,bp
	pop bp
	pop di
	pop si
	ret
_8BB5:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov di,[bp+0xa]
	cmp word [0x1b50],byte +0x0
	jz short _8BE6
	mov bx,di
	shl bx,1
	inc bx
	add bx,si
	mov al,[bx]
	sub ah,ah
	mov cl,0x8
	shl ax,cl
	mov cx,ax
	mov bx,di
	shl bx,1
	add bx,si
	mov al,[bx]
	sub ah,ah
	add ax,cx
	jmp short _8BEE
_8BE6:
	mov bx,di
	add bx,si
	mov al,[bx]
	sub ah,ah
_8BEE:
	pop bp
	pop di
	pop si
	ret
_8BF2:
	push si
	push di
	push bp
	mov bp,sp
	mov ax,0xff
	push ax
	push word [0x1b5c]
	push word [0x1b5a]
	push word [0x1b58]
	push word [0x1b56]
	call _2B37
	add sp,byte +0xa
	pop bp
	pop di
	pop si
	ret
_8C15:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x4
	mov si,[bp+0x8]
	mov ax,0x10
	push ax
	call LocalAlloc
	add sp,byte +0x2
	mov di,ax
	sub ax,ax
	mov [di+0x2],ax
	mov [di],ax
	mov [di+0x4],si
	mov ax,[si+0x3]
	mov [di+0x6],ax
	mov ax,[si+0x5]
	sub ax,[si+0x1c]
	inc ax
	mov [di+0x8],ax
	mov ax,[si+0x1a]
	mov [di+0xa],ax
	mov [bp-0x2],ax
	cmp word [0x10c6],byte +0x2
	jnz short _8C67
	mov ax,[di+0x6]
	and ax,0x1
	add ax,[bp-0x2]
	inc ax
	shr ax,1
	shl ax,1
	add [bp-0x2],ax
_8C67:
	mov ax,[si+0x1c]
	mov [di+0xc],ax
	mov [bp-0x4],ax
	mul word [bp-0x2]
	push ax
	call LocalAlloc
	add sp,byte +0x2
	mov [di+0xe],ax
	mov [si+0x14],di
	mov ax,di
	mov sp,bp
	pop bp
	pop di
	pop si
	ret
_8C88:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	push si
	call _1409
	add sp,byte +0x2
	pop bp
	pop di
	pop si
	ret

_8C9B:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	mov si,[bp+0x8]
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	push ax
	call _21B3
	add sp,byte +0x2
	mov [bp-0x2],ax
	cmp word [0x1b6c],byte +0x1
	jnz short _8CC1
	jmp _8D45
_8CC1:
	mov ax,0x12
	push ax
	call LocalAlloc
	add sp,byte +0x2
	mov di,ax
	cmp word [0x1b6e],byte +0x0
	jnz short _8CE0
	mov [0x1b6e],di
	mov word [0x1b66],0x1
	jmp short _8CFB
_8CE0:
	mov bx,[0x1b70]
	cmp word [bx+0xc],byte +0x0
	jnz short _8CEF
	mov word [bx+0xa],0x0
_8CEF:
	mov bx,[0x1b70]
	mov [bx],di
	mov ax,[0x1b70]
	mov [di+0x2],ax
_8CFB:
	mov ax,[0x1b6e]
	mov [di],ax
	mov bx,[0x1b6e]
	mov [bx+0x2],di
	mov [0x1b70],di
	mov word [di+0x6],0x0
	mov word [di+0x10],0x0
	mov ax,[bp-0x2]
	mov [di+0x4],ax
	mov ax,[0x1b66]
	mov [di+0x8],ax
	mov word [di+0xa],0x1
	mov word [di+0xc],0x0
	push word [bp-0x2]
	call _4BCE
	add sp,byte +0x2
	inc ax
	add [0x1b66],ax
	mov word [0x1b72],0x0
	mov word [0x1b68],0x1
_8D45:
	mov ax,si
	mov sp,bp
	pop bp
	pop di
	pop si
	ret

;------------------------------------------------------------------------------
; This is executed several times in a row
_8D4D:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x5
	mov si,[bp+0x8]
	mov bx,si
	inc si
	mov al,[bx]
	sub ah,ah
	push ax
	call _21B3
	add sp,byte +0x2
	mov [bp-0x2],ax
	mov bx,si
	inc si
	mov al,[bx]
	mov [bp-0x3],al
	cmp word [0x1b6c],byte +0x1
	jnz short _8D7B
	jmp _8E30
_8D7B:
	mov ax,0xe
	push ax
	call LocalAlloc
	add sp,byte +0x2
	mov di,ax
	cmp word [0x1b72],byte +0x0
	jnz short _8D9F
	mov ax,di
	mov bx,[0x1b70]
	mov [bx+0xc],ax
	mov [bx+0xe],ax
	mov [di+0x2],di
	jmp short _8DAB
_8D9F:
	mov bx,[0x1b72]
	mov [bx],di
	mov ax,[0x1b72]
	mov [di+0x2],ax
_8DAB:
	mov bx,[0x1b70]
	mov ax,[bx+0xc]
	mov [di],ax
	mov ax,[bx+0xc]
	mov [bp-0x5],ax
	mov bx,[bp-0x5]
	mov [bx+0x2],di
	mov [0x1b72],di
	mov ax,[bp-0x2]
	mov [di+0x4],ax
	cmp word [0x1b68],byte +0x1
	jnz short _8E0C
	mov bx,[0x1b70]
	mov ax,[bx+0x8]
	mov [bp-0x5],ax
	push word [bp-0x2]
	call _4BCE
	add sp,byte +0x2
	mov cx,ax
	add cx,[bp-0x5]
	mov ax,cx
	cmp ax,0x27
	jnc short _8DF9
	mov bx,[0x1b70]
	mov ax,[bx+0x8]
	jmp short _8E09
_8DF9:
	push word [bp-0x2]
	call _4BCE
	add sp,byte +0x2
	mov cx,ax
	mov ax,0x27
	sub ax,cx
_8E09:
	mov [0x1b6a],ax
_8E0C:
	inc word [0x1b68]
	mov ax,[0x1b68]
	mov [di+0x6],ax
	mov ax,[0x1b6a]
	mov [di+0x8],ax
	mov word [di+0xa],0x1
	mov al,[bp-0x3]
	sub ah,ah
	mov [di+0xc],ax
	mov bx,[0x1b70]
	inc word [bx+0x10]
_8E30:
	mov ax,si
	mov sp,bp
	pop bp
	pop di
	pop si
	ret

_8E38:
	push si
	push di
	push bp
	mov bp,sp
	mov di,[0x1b70]
	cmp word [di+0xc],byte +0x0
	jnz short _8E4C
	mov word [di+0xa],0x0
_8E4C:
	call _1443
	mov ax,[0x1b6e]
	mov [0x1b70],ax
	mov di,[0x1b70]
	mov ax,[di+0xc]
	mov [0x1b72],ax
	mov word [0x1b6c],0x1
	mov ax,[bp+0x8]
	pop bp
	pop di
	pop si
	ret

_8E6C:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov ax,0x1
	push ax
	mov di,si
	inc si
	mov al,[di]
	sub ah,ah
	push ax
	call _8EDD
	add sp,byte +0x4
	mov ax,si
	pop bp
	pop di
	pop si
	ret
_8E8C:
	push si
	push di
	push bp
	mov bp,sp
	mov ax,[0x1b6e]
	mov si,ax
	or ax,ax
	jz short _8EBA
_8E9A:
	cmp word [si+0xa],byte +0x0
	jz short _8EB1
	mov di,[si+0xc]
_8EA3:
	mov word [di+0xa],0x1
	mov di,[di]
	mov ax,[si+0xc]
	cmp ax,di
	jnz short _8EA3
_8EB1:
	mov si,[si]
	mov ax,[0x1b6e]
	cmp ax,si
	jnz short _8E9A
_8EBA:
	pop bp
	pop di
	pop si
	ret

_8EBE:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	sub ax,ax
	push ax
	mov di,si
	inc si
	mov al,[di]
	sub ah,ah
	push ax
	call _8EDD
	add sp,byte +0x4
	mov ax,si
	pop bp
	pop di
	pop si
	ret
_8EDD:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	mov si,[bp+0x8]
	mov di,[0x1b6e]
_8EEC:
	cmp word [di+0xa],byte +0x0
	jz short _8F20
	mov ax,[di+0xc]
	mov [bp-0x2],ax
_8EF8:
	mov bx,[bp-0x2]
	cmp si,[bx+0xc]
	jnz short _8F13
	cmp word [bp+0xa],byte +0x1
	jnz short _8F0B
	mov ax,0x1
	jmp short _8F0D
_8F0B:
	sub ax,ax
_8F0D:
	mov bx,[bp-0x2]
	mov [bx+0xa],ax
_8F13:
	mov bx,[bp-0x2]
	mov ax,[bx]
	mov [bp-0x2],ax
	cmp ax,[di+0xc]
	jnz short _8EF8
_8F20:
	mov di,[di]
	mov ax,[0x1b6e]
	cmp ax,di
	jnz short _8EEC
	mov sp,bp
	pop bp
	pop di
	pop si
	ret

_8F2F:
	push si
	push di
	push bp
	mov bp,sp
	mov ax,0xe
	push ax
	call _7247
	add sp,byte +0x2
	or ax,ax
	jz short _8F48
	mov word [0x1b64],0x1
_8F48:
	mov ax,[bp+0x8]
	pop bp
	pop di
	pop si
	ret

_8F4F:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	call _2A69
	call _76EC
	mov ax,0xf
	push ax
	call _7610
	add sp,byte +0x2
	push ax
	sub ax,ax
	push ax
	call _2AE7
	add sp,byte +0x4
	mov si,[0x1b6e]
_8F75:
	push si
	call _919C
	add sp,byte +0x2
	mov si,[si]
	mov ax,[0x1b6e]
	cmp ax,si
	jnz short _8F75
	mov si,[0x1b70]
	mov di,[0x1b72]
	push si
	call _90D5
	add sp,byte +0x2
_8F94:
	call _4425
	mov [bp-0x2],ax
	push ax
	call _4530
	add sp,byte +0x2
	push word [bp-0x2]
	call _45E4
	add sp,byte +0x2
	mov bx,[bp-0x2]
	mov ax,[bx]
	jmp _90B4
_8FB2:
	mov bx,[bp-0x2]
	mov ax,[bx+0x2]
	jmp short _8FFA
_8FBA:
	cmp word [di+0xa],byte +0x0
	jz short _8F94
	push word [di+0xc]
	mov ax,0x3
	push ax
	call _43A5
	add sp,byte +0x4
_8FCD:
	push di
	push si
	call _9127
	add sp,byte +0x4
	call _7726
	call _2A90
	cmp word [0x5d9],byte +0x0
	jz short _8FE7
	call _33ED
	jmp short _8FF1
_8FE7:
	sub ax,ax
	push ax
	push ax
	call _2AE7
	add sp,byte +0x4
_8FF1:
	mov word [0x1b64],0x0
	jmp _90CF
_8FFA:
	cmp ax,0xd
	jz short _8FBA
	cmp ax,0x1b
	jz short _8FCD
	jmp _90C4
_9007:
	mov bx,[bp-0x2]
	mov ax,[bx+0x2]
	jmp _9095
_9010:
	push di
	call _919C
	add sp,byte +0x2
	mov di,[di+0x2]
_901A:
	push di
	call _914E
_901E:
	add sp,byte +0x2
	jmp _90C4
_9024:
	push di
	call _919C
	add sp,byte +0x2
	mov di,[si+0xc]
	jmp short _901A
_9030:
	push di
	push si
	call _9127
	add sp,byte +0x4
_9038:
	mov si,[si]
	cmp word [si+0xa],byte +0x0
	jz short _9038
_9040:
	mov di,[si+0xe]
	push si
	call _90D5
	jmp short _901E
_9049:
	push di
	call _919C
	add sp,byte +0x2
	mov bx,[si+0xc]
	mov di,[bx+0x2]
	jmp short _901A
_9058:
	push di
	call _919C
	add sp,byte +0x2
	mov di,[di]
	jmp short _901A
_9063:
	push di
	push si
	call _9127
	add sp,byte +0x4
	mov bx,[0x1b6e]
	mov si,[bx+0x2]
	jmp short _9040
_9074:
	push di
	push si
	call _9127
	add sp,byte +0x4
_907C:
	mov si,[si+0x2]
	cmp word [si+0xa],byte +0x0
	jz short _907C
	jmp short _9040
_9087:
	push di
	push si
	call _9127
	add sp,byte +0x4
	mov si,[0x1b6e]
	jmp short _9040
_9095:
	dec ax
	cmp ax,0x7
	ja short _90C4
	shl ax,1
	mov bx,ax
	jmp [cs:bx+_90A4]
_90A4:
	DW	_9010
	DW	_9024
	DW	_9030
	DW	_9049
	DW	_9058
	DW	_9063
	DW	_9074
	DW	_9087

_90B4:
	cmp ax,0x1
	jnz short _90BC
	jmp _8FB2
_90BC:
	cmp ax,0x2
	jnz short _90C4
	jmp _9007
_90C4:
	mov [0x1b70],si
	mov [0x1b72],di
	jmp _8F94
_90CF:
	mov sp,bp
	pop bp
	pop di
	pop si
	ret

_90D5:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	push si
	call _914E
	add sp,byte +0x2
	push si
	call _91FB
	add sp,byte +0x2
	mov ax,0xf
	push ax
	push word [0x1b76]
	push word [0x1b74]
	call _53C4
	add sp,byte +0x6
	mov ax,[si+0xc]
	mov di,ax
	or ax,ax
	jz short _9123
_9106:
	mov ax,[si+0xe]
	cmp ax,di
	jnz short _9113
	push di
	call _914E
	jmp short _9117
_9113:
	push di
	call _919C
_9117:
	add sp,byte +0x2
	mov di,[di]
	mov ax,[si+0xc]
	cmp ax,di
	jnz short _9106
_9123:
	pop bp
	pop di
	pop si
	ret
_9127:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	mov di,[bp+0xa]
	mov [si+0xe],di
	push si
	call _919C
	add sp,byte +0x2
	push word [0x1b76]
	push word [0x1b74]
	call _5440
	add sp,byte +0x4
	pop bp
	pop di
	pop si
	ret
_914E:
	push si
	push di
	push bp
	mov bp,sp
	mov si,[bp+0x8]
	push word [si+0x8]
	push word [si+0x6]
	call _2A4E
	add sp,byte +0x4
	sub ax,ax
	push ax
	call _7610
	add sp,byte +0x2
	push ax
	mov ax,0xf
	push ax
	call _7604
	add sp,byte +0x2
	push ax
	call _7538
	add sp,byte +0x4
	cmp word [si+0xa],byte +0x0
	jnz short _9189
	mov word [0xe3a],0x1
_9189:
	push word [si+0x4]
	call _2353
	add sp,byte +0x2
	mov word [0xe3a],0x0
	pop bp
	pop di
	pop si
	ret
_919C:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x4
	mov si,[bp+0x8]
	mov ax,[si+0x6]
	mov [bp-0x2],ax
	mov ax,[si+0x8]
	mov [bp-0x4],ax
	mov ax,0xf
	push ax
	call _7610
	add sp,byte +0x2
	push ax
	sub ax,ax
	push ax
	call _7604
	add sp,byte +0x2
	push ax
	call _7538
	add sp,byte +0x4
	push word [bp-0x4]
	push word [bp-0x2]
	call _2A4E
	add sp,byte +0x4
	cmp word [si+0xa],byte +0x0
	jnz short _91E6
	mov word [0xe3a],0x1
_91E6:
	push word [si+0x4]
	call _2353
	add sp,byte +0x2
	mov word [0xe3a],0x0
	mov sp,bp
	pop bp
	pop di
	pop si
	ret

_91FB:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x4
	mov si,[bp+0x8]
	mov di,[si+0xc]
	push word [di+0x4]
	call _4BCE
	add sp,byte +0x2
	mov [bp-0x4],ax
	mov ax,[si+0x10]
	mov [bp-0x2],ax
	mov bx,[bp-0x4]
	shl bx,1
	shl bx,1
	add bx,byte +0x8
	mov di,[0xceb]
	shl di,1
	mul word [0xceb]
	add ax,di
	mov cl,0x8
	shl ax,cl
	or ax,bx
	mov [0x1b76],ax
	mov ax,[bp-0x2]
	inc ax
	inc ax
	sub ax,[0x5dd]
	mul word [0xceb]
	mov di,ax
	mov bx,[0xceb]
	add bx,di
	add bx,byte -0x1
	mov di,[si+0xc]
	mov ax,[di+0x8]
	add ax,0xffff
	shl ax,1
	shl ax,1
	mov cl,0x8
	shl ax,cl
	or ax,bx
	mov [0x1b74],ax
	mov sp,bp
	pop bp
	pop di
	pop si
	ret




;==============================================================================
;								EGA VIDEO DRIVER
;==============================================================================

; 9350
SetGraphicsMode:
	jmp SetGraphicsModeEGA

_9353:
	jmp _9385
_9356:
	jmp _93BF
_9359:
	jmp _93D4
_935C:
	jmp _93D5
_935F:
	jmp _94D9
_9362:
	jmp _945C

; 9365
SetGraphicsModeEGA:
	mov ax,0x000d				; 320x200 16 colores
	int 0x10
	mov ah,0x10
	mov al,0x3
	xor bx,bx
	int 0x10
	mov dx,0x3ce
	mov al,0x3
	out dx,al
	mov dx,0x3cf
	xor al,al
	out dx,al
	mov word [0x1305],0xa000
	ret

_9385:
	push si
	push di
_9387:
	push bp
	mov bp,sp
	sub sp,byte +0x2
	mov ah,0x0
	mov al,0x1
	int 0x10
	mov ah,0x10
	mov al,0x3
	xor bx,bx
	int 0x10
	mov ah,0x1
	mov cx,0x1000
	int 0x10
	mov ah,0x2
	xor bh,bh
	xor dx,dx
	int 0x10
	mov al,[0x5d1]
	mov ah,0x6
	xor al,al
	xor cx,cx
	mov dx,0x1827
	int 0x10
	add sp,byte +0x2
	pop bp
	pop di
	pop si
	ret
_93BF:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	call SetGraphicsModeEGA
	call _537A
	add sp,byte +0x2
	pop bp
	pop di
	pop si
	ret
_93D4:
	ret
_93D5:
	mov cx,bx
	call _547F
	mov si,di
	call _5458
	mov bx,cx
	mov bp,di
	push ds
	push es
	mov es,[0x1305]
_93E9:
	mov ds,[0x1303]
	call _956A
	xor cx,cx
	mov di,_9418
	sub di,_9456
	and ah,0x3
	mov cl,ah
	jcxz _9406
_9400:
	add di,0xc
	loop _9400
_9406:
	mov cx,di
	mov di,_9454+1
	mov [cs:di],cl
	xor cx,cx
	mov cl,bl
	mov di,bp
	or cl,cl
	jmp short _9454
_9418:
	mov al,0xc0
	out dx,al
	mov al,[es:di]
	movsb
	dec cl
	jz short _9445
	dec di
	mov al,0x30
	out dx,al
	mov al,[es:di]
	movsb
	dec cl
	jz short _9445
	dec di
	mov al,0xc
	out dx,al
	mov al,[es:di]
	movsb
	dec cl
	jz short _9445
	dec di
	mov al,0x3
	out dx,al
	mov al,[es:di]
	movsb
	loop _9418
_9445:
	mov cl,bl
	sub si,0xa0
	sub si,cx
	sub bp,byte +0x28
	mov di,bp
	dec bh
_9454:
	jnz short _9454
_9456:
	call _958C
	pop es
	pop ds
	ret
_945C:
	push es
	mov es,[0x1305]
	push bp
	mov bp,dx
	mov si,bx
	call _5458
	mov bx,si
	mov si,di
	and ah,0x3
	call _956A
	xor di,di
	mov cx,di
	mov cl,ah
	jcxz _9481
_947B:
	add di,0xd
	loop _947B
_9481:
	mov cx,di
	mov di,_9496
	inc di
	mov [cs:di],cl
	mov di,si
	mov cx,bp
	xor ch,ch
	xchg cl,bl
	mov bp,cx
_9494:
	mov cx,bp
_9496:
	jmp short _9498
_9498:
	mov al,0xc0
	out dx,al
	mov al,[es:di]
	mov [es:di],bl
	dec cl
	jz short _94CA
	mov al,0x30
	out dx,al
	mov al,[es:di]
	mov [es:di],bl
	dec cl
	jz short _94CA
	mov al,0xc
	out dx,al
	mov al,[es:di]
	mov [es:di],bl
	dec cl
	jz short _94CA
	mov al,0x3
	out dx,al
	mov al,[es:di]
	mov al,bl
	stosb
	loop _9498
_94CA:
	sub si,byte +0x28
	mov di,si
	dec bh
	jnz short _9494
	call _958C
	pop bp
	pop es
	ret
_94D9:
	lea di,[0x130f]
	mov ax,0x0
	cmp ax,[es:di]
	jz short _950D
	mov cx,0xc8
_94E8:
	stosw
	add ax,0x28
	loop _94E8
	call _956A
	push es
	push ds
	mov ax,0xa000
	mov es,ax
	mov ds,ax
	mov di,0x2000
	mov cx,0x1f40
_9500:
	mov al,0xff
	out dx,al
	mov al,[es:di]
	xor al,al
	stosb
	loop _9500
	pop ds
	pop es
_950D:
	ret

_950E:
	push bx
	push si
	push di
	push cx
	call _956A
	push es
	push ds
	mov ax,0xa000
	mov es,ax
	mov ds,ax
	xor si,si
	mov di,0x20a1
	mov cx,0xc4
_9526:
	push cx
	mov cx,0x27
_952A:
	xor al,al
	out dx,al
	lodsb
	stosb
	loop _952A
	inc si
	inc di
	pop cx
	loop _9526
	pop ds
	pop es
	pop cx
_9539:
	push cx
	mov cx,0x4
_953D:
	push cx
	mov bl,0x1
_9540:
	mov ah,0x5
	mov al,bl
	int 0x10
	mov dx,0x3da
	mov cx,0x4
_954C:
	in al,dx
	test al,0x8
	jz short _954C
_9551:
	in al,dx
	test al,0x8
	jnz short _9551
	loop _954C
	xor bl,0x1
	jz short _9540
	pop cx
	loop _953D
	pop cx
	loop _9539
	call _958C
	pop di
	pop si
	pop bx
	ret
_956A:
	mov dx,0x3ce
	mov al,0x5
	out dx,al
	mov dx,0x3cf
	mov al,0x2
	out dx,al
	mov dx,0x3ce
	mov al,0x3
	out dx,al
	mov dx,0x3cf
	xor al,al
	out dx,al
	mov al,0x8
	mov dx,0x3ce
	out dx,al
	mov dx,0x3cf
	ret
_958C:
	mov dx,0x3ce
	mov al,0x5
	out dx,al
	mov dx,0x3cf
	xor al,al
	out dx,al
	mov al,0x8
_959A:
	mov dx,0x3ce
	out dx,al
	mov al,0xff
	mov dx,0x3cf
	out dx,al
	ret




;==============================================================================
;							IBM SPEAKER SOUND DRIVER
;==============================================================================
_9900:
	jmp _9909
_9903:
	jmp _9948
_9906:
	jmp _9985
_9909:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	mov bp,[bp+0x8]
	mov al,[bp+0x8]
	mov ah,[bp+0x6]
	call _547F
	mov si,di
	mov ah,[bp+0xc]
	mov al,[bp+0xa]
	mov di,[bp+0xe]
	push ds
	mov ds,[0x1303]
	xor dx,dx
	mov cx,dx
	mov dx,0xa0
	sub dl,al
_9936:
	mov cl,al
	rep movsb
	add si,dx
	dec ah
	jnz short _9936
	pop ds
	add sp,byte +0x2
	pop bp
	pop di
	pop si
	ret
_9948:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	mov bp,[bp+0x8]
	mov al,[bp+0x8]
	mov ah,[bp+0x6]
	call _547F
	mov si,[bp+0xe]
	mov ah,[bp+0xc]
	mov al,[bp+0xa]
	push es
	mov es,[0x1303]
	xor dx,dx
	mov cx,dx
	mov dx,0xa0
	sub dl,al
_9973:
	mov cl,al
	rep movsb
	add di,dx
	dec ah
	jnz short _9973
	pop es
	add sp,byte +0x2
	pop bp
	pop di
	pop si
	ret
_9985:
	push si
	push di
	push bp
	mov bp,sp
	sub sp,byte +0x2
	mov bp,[bp+0x8]
	mov al,[bp+0x2]
	push ax
	mov si,[bp+0x10]
	test byte [si+0x2],0x80
	jz short _99A5
	push bp
	call _5696
	pop bp
	mov si,[bp+0x10]
_99A5:
	inc si
	lodsw
	mov dx,ax
	mov ah,[bp+0x3]
	mov al,[bp+0x5]
	sub al,dl
	inc al
	call _547F
	shl dh,1
	shl dh,1
	shl dh,1
	shl dh,1
	push es
	mov es,[0x1303]
	mov bl,0x1
	mov bh,[bp+0x24]
	shl bh,1
	shl bh,1
	shl bh,1
	shl bh,1
	mov bp,di
	xor cx,cx
	jmp short _99DA
_99D7:
	cbw
	add di,ax
_99DA:
	lodsb
	or al,al
	jz short _9A0A
	mov ah,al
	and ax,0xf00f
	cmp ah,dh
	jz short _99D7
	mov cl,al
	shr ah,1
	shr ah,1
	shr ah,1
	shr ah,1
_99F2:
	mov al,[es:di]
	and al,0xf0
	cmp al,0x20
	jna short _9A16
	cmp al,bh
	ja short _9A35
	mov al,bh
_9A01:
	or al,ah
	stosb
	xor bl,bl
	loop _99F2
	jmp short _99DA
_9A0A:
	dec dl
	jz short _9A3A
	add bp,0xa0
	mov di,bp
	jmp short _99DA
_9A16:
	push di
	xor ch,ch
_9A19:
	cmp di,0x6860
	jnc short _9A2E
	add di,0xa0
	mov ch,[es:di]
	and ch,0xf0
	cmp ch,0x20
	jna short _9A19
_9A2E:
	pop di
	cmp ch,bh
	mov ch,0x0
	jna short _9A01
_9A35:
	inc di
	loop _99F2
	jmp short _99DA
_9A3A:
	pop es
	pop ax
	or al,al
	jnz short _9A4E
	mov al,0x1
	test bl,bl
	jnz short _9A4B
	call _7257
	jmp short _9A4E
_9A4B:
	call _7251
_9A4E:
	add sp,byte +0x2
	pop bp
	pop di
	pop si
	ret




;==============================================================================
;							AGIDATA.OVL = CS + 9B6 = CS:9B60
;==============================================================================
SEGMENT _DATA CLASS=DATA ALIGN=16
AGIDATA:
	DW	0	; address LocalAlloc Stack 0xA00 bytes (here in data segment)
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0F
	DB	0x00, 0x32, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x17, 0x00, 0x00, 0x00, 0x00, 0x00, 0x15, 0x00, 0x00, 0x00, 0x00
	DB	0x00
	DB	"Press ENTER to quit.", 0x0A
	DB	"Press ESC to keep playing."
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00

AGIDATA_61B:
	DW	_4E86, 0x0
	DW	_70B8, 0x8001
	DW	_70CB, 0x8001
	DW	_70DE, 0x8002
	DW	_70EB, 0xC002
	DW	_70FE, 0x8002
	DW	_710B, 0xC002
	DW	_711E, 0x8002
	DW	_712B, 0xC002
	DW	_713E, 0xC002
	DW	_7168, 0xC002
	DW	_7157, 0x8002
	DW	_71E7, 0x1
	DW	_71EE, 0x1
	DW	_71F5, 0x1
	DW	_71FC, 0x8001
	DW	_720B, 0x8001
	DW	_721A, 0x8001
	DW	_1721, 0x1
	DW	_1738, 0x8001
	DW	_110A, 0x1
	DW	_1126, 0x8001
	DW	_1227, 0x1
	DW	_124D, 0x8001
	DW	_4912, 0x8001
	DW	_49A6, 0x8001
	DW	_4A7E, 0x0
	DW	_4AA6, 0x8001
	DW	_4A13, 0x8001
	DW	_707E, 0x0
	DW	_38E1, 0x1
	DW	_3900, 0x8001
	DW	_3DFD, 0x1
	DW	_4A6, 0x1
	DW	_50A, 0x0
	DW	_9B7, 0x1
	DW	_A5C, 0x1
	DW	_7970, 0x3
	DW	_79AD, 0x6003
	DW	_79FA, 0x6003
	DW	_7A3D, 0x6003
	DW	_39A7, 0x2
	DW	_39DB, 0x4002
	DW	_3A77, 0x2
	DW	_3AAB, 0x4002
	DW	_4877, 0x1
	DW	_489F, 0x1
	DW	_3B85, 0x2
	DW	_3BBC, 0x4002
	DW	_3CCF, 0x4002
	DW	_3D1D, 0x4002
	DW	_3D55, 0x4002
	DW	_3D8D, 0x4002
	DW	_3DC5, 0x4002
	DW	_77D6, 0x2
	DW	_785E, 0x4002
	DW	_7806, 0x1
	DW	_782B, 0x4002
	DW	_685D, 0x1
	DW	_6885, 0x1
	DW	_68AD, 0x1
	DW	_7BEA, 0x1
	DW	_7C0F, 0x1
	DW	_7BD2, 0x1
	DW	_7B63, 0x1
	DW	_7B88, 0x1
	DW	_7BAD, 0x1
	DW	_469B, 0x1
	DW	_46C3, 0x1
	DW	_46EB, 0x2003
	DW	_6A2C, 0x1
	DW	_6A51, 0x1
	DW	_6917, 0x1
	DW	_6943, 0x2
	DW	_6980, 0x1
	DW	_69AC, 0x2
	DW	_69E9, 0x4002
	DW	_6C5D, 0x1
	DW	_6C9A, 0x1
	DW	_6CD3, 0x4002
	DW	_6D11, 0x4002
	DW	_6A79, 0x5
	DW	_6AF6, 0x7005
	DW	_6B97, 0x3
	DW	_6BFD, 0x1
	DW	_6C36, 0x1
	DW	_6D53, 0x4002
	DW	_6D91, 0x4002
	DW	_78F2, 0x1
	DW	_7917, 0x1
	DW	_78A4, 0x4
	DW	_78E0, 0x0
	DW	_729B, 0x1
	DW	_72B7, 0x8001
	DW	_72D3, 0x1
	DW	_72EF, 0x2
	DW	_731A, 0x4002
	DW	_7345, 0xC002
	DW	_4F3E, 0x1
	DW	_5007, 0x2
	DW	_5059, 0x0
	DW	_1BC9, 0x1
	DW	_1BEC, 0x8001
	DW	_2213, 0x3
	DW	_226A, 0xE003
	DW	_7477, 0x3
	DW	_742D, 0x0
	DW	_7465, 0x0
	DW	_37E4, 0x1
	DW	_7512, 0x2
	DW	_7763, 0x1
	DW	_7653, 0x3
	DW	_3477, 0x0
	DW	_348C, 0x0
	DW	_D04, 0x2
	DW	_C11, 0x5
	DW	_D3D, 0x2
	DW	_191B, 0x1
	DW	_6F50, 0x4002
	DW	_379F, 0x0
	DW	_37C8, 0x0
	DW	_4B39, 0x3
	DW	_2BAA, 0x7
	DW	_2BFA, 0xFE07
	DW	_3108, 0x0
	DW	_26B9, 0x0
	DW	_24D5, 0x0
	DW	_4E86, 0x0
	DW	_2435, 0x0
	DW	_5CD8, 0x1
	DW	_4E3E, 0x2003
	DW	_6DC4, 0x0
	DW	_6DD6, 0x0
	DW	_7018, 0x8001
	DW	_24C, 0x1
	DW	_148A, 0x0
	DW	_224, 0x0
	DW	_3683, 0x0
	DW	_3656, 0x0
	DW	_5ED1, 0x0
	DW	_76AF, 0x0
	DW	_709F, 0x0
	DW	_6EFF, 0x1
	DW	_E4B, 0x1
	DW	_7F29, 0x1
	DW	_1302, 0x0
	DW	_1317, 0x0
	DW	_7ACD, 0x3
	DW	_7B10, 0x6003
	DW	_880F, 0x0
	DW	_88BB, 0x3
	DW	_1C17, 0x3
	DW	_1C34, 0x8003
	DW	_3E19, 0x8001
	DW	_74B6, 0x5
	DW	_4B11, 0x2
	DW	_8C9B, 0x1
	DW	_8D4D, 0x2
	DW	_8E38, 0x0
	DW	_8E6C, 0x1
	DW	_8EBE, 0x1
	DW	_8F2F, 0x0
	DW	_5CB4, 0x101
	DW	_3869, 0x0
	DW	_387B, 0x0
	DW	_7181, 0x8002
	DW	_7194, 0xC002
	DW	_71AF, 0x8002
	DW	_71C8, 0xC002
	DW	_1EEE, 0x0

AGIDATA_8C3:
	DB	0x04, 0x04, 0x00, 0x00, 0x00, 0x04, 0x01, 0x01, 0x01, 0x00, 0x04, 0x03, 0x00
	DB	0x00, 0x00, 0x02, 0x01, 0x01, 0x01, 0x00
	
	DB	"Avis Durgan", 0
	
AGIDATA_8E3:
	DW	_9A5, 0x0000
	DW	_7F0, 0x8002
	DW	_801, 0xC002
	DW	_818, 0x8002
	DW	_829, 0xC002
	DW	_840, 0x8002
	DW	_851, 0xC002
	DW	_868, 0x0001
	DW	_86D, 0x8001
	DW	_87A, 0x0001
	DW	_908, 0x4002
	DW	_893, 0x0005
	DW	_8FE, 0x0001
	DW	_98B, 0x0000
	DW	_929, 0x0000
	DW	_9A8, 0x0002
	DW	_8B5, 0x0005
	DW	_899, 0x0005
	DW	_8A8, 0x0005
	
	DB	0x00
	DB	0x00, 0x20, 0x09, 0x2E, 0x2C, 0x3B, 0x3A, 0x27, 0x21, 0x2D, 0x00, 0x77, 0x6F, 0x72, 0x64, 0x73
	DB	0x2E, 0x74, 0x6F, 0x6B, 0x00, 0x6F, 0x62, 0x6A, 0x65, 0x63, 0x74, 0x00, 0x00, 0x3B, 0x09, 0x45
	DB	0x09, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x4E, 0x6F, 0x20, 0x6D, 0x65, 0x6D, 0x6F, 0x72, 0x79, 0x2E, 0x0A, 0x57, 0x61
	DB	0x6E, 0x74, 0x20, 0x25, 0x64, 0x2C, 0x20, 0x68, 0x61, 0x76, 0x65, 0x20, 0x25, 0x64, 0x00, 0x68
	DB	0x65, 0x61, 0x70, 0x73, 0x69, 0x7A, 0x65, 0x3A, 0x20, 0x25, 0x75, 0x0A, 0x6E, 0x6F, 0x77, 0x3A
	DB	0x20, 0x25, 0x75, 0x20, 0x20, 0x6D, 0x61, 0x78, 0x3A, 0x20, 0x25, 0x75, 0x0A, 0x6D, 0x61, 0x78
	DB	0x20, 0x73, 0x63, 0x72, 0x69, 0x70, 0x74, 0x3A, 0x20, 0x25, 0x64, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x01
	DB	0x00, 0x01, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0x00, 0xFF, 0xFF, 0xFF
	DB	0xFF, 0x00, 0x00, 0x01, 0x00, 0x01, 0x00, 0x01, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0x08, 0x00, 0x01
	DB	0x00, 0x02, 0x00, 0x07, 0x00, 0x00, 0x00, 0x03, 0x00, 0x06, 0x00, 0x05, 0x00, 0x04, 0x00, 0x0A
	DB	0x50, 0x72, 0x65, 0x73, 0x73, 0x20, 0x45, 0x53, 0x43, 0x20, 0x74, 0x6F, 0x20, 0x71, 0x75, 0x69
	DB	0x74, 0x2E, 0x00, 0x41, 0x64, 0x76, 0x65, 0x6E, 0x74, 0x75, 0x72, 0x65, 0x20, 0x47, 0x61, 0x6D
	DB	0x65, 0x20, 0x49, 0x6E, 0x74, 0x65, 0x72, 0x70, 0x72, 0x65, 0x74, 0x65, 0x72, 0x0A, 0x20, 0x20
	DB	0x20, 0x20, 0x20, 0x20, 0x56, 0x65, 0x72, 0x73, 0x69, 0x6F, 0x6E, 0x20, 0x32, 0x2E, 0x34, 0x34
	DB	0x30, 0x00, 0x00, 0x50, 0x72, 0x65, 0x73, 0x73, 0x20, 0x45, 0x4E, 0x54, 0x45, 0x52, 0x20, 0x74
	DB	0x6F, 0x20, 0x72, 0x65, 0x73, 0x74, 0x61, 0x72, 0x74, 0x0A, 0x74, 0x68, 0x65, 0x20, 0x67, 0x61
	DB	0x6D, 0x65, 0x2E, 0x0A, 0x0A, 0x50, 0x72, 0x65, 0x73, 0x73, 0x20, 0x45, 0x53, 0x43, 0x20, 0x74
	DB	0x6F, 0x20, 0x63, 0x6F, 0x6E, 0x74, 0x69, 0x6E, 0x75, 0x65, 0x0A, 0x74, 0x68, 0x69, 0x73, 0x20
	DB	0x67, 0x61, 0x6D, 0x65, 0x2E, 0x00, 0x00, 0x53, 0x6F, 0x72, 0x72, 0x79, 0x2C, 0x20, 0x79, 0x6F
	DB	0x75, 0x72, 0x20, 0x63, 0x6F, 0x6D, 0x70, 0x75, 0x74, 0x65, 0x72, 0x20, 0x64, 0x6F, 0x65, 0x73
	DB	0x0A, 0x6E, 0x6F, 0x74, 0x20, 0x68, 0x61, 0x76, 0x65, 0x20, 0x65, 0x6E, 0x6F, 0x75, 0x67, 0x68
	DB	0x20, 0x6D, 0x65, 0x6D, 0x6F, 0x72, 0x79, 0x20, 0x74, 0x6F, 0x0A, 0x70, 0x6C, 0x61, 0x79, 0x20
	DB	0x74, 0x68, 0x69, 0x73, 0x20, 0x67, 0x61, 0x6D, 0x65, 0x2E, 0x0A, 0x32, 0x35, 0x36, 0x4B, 0x20
	DB	0x6F, 0x66, 0x20, 0x52, 0x41, 0x4D, 0x20, 0x69, 0x73, 0x20, 0x72, 0x65, 0x71, 0x75, 0x69, 0x72
	DB	0x65, 0x64, 0x2E, 0x00, 0x00, 0x43, 0x61, 0x6E, 0x27, 0x74, 0x20, 0x66, 0x69, 0x6E, 0x64, 0x20
	DB	0x48, 0x47, 0x43, 0x5F, 0x46, 0x6F, 0x6E, 0x74, 0x20, 0x66, 0x69, 0x6C, 0x65, 0x2E, 0x00, 0x50
	DB	0x6C, 0x65, 0x61, 0x73, 0x65, 0x20, 0x69, 0x6E, 0x73, 0x65, 0x72, 0x74, 0x20, 0x64, 0x69, 0x73
	DB	0x6B, 0x20, 0x25, 0x64, 0x0A, 0x61, 0x6E, 0x64, 0x20, 0x70, 0x72, 0x65, 0x73, 0x73, 0x20, 0x45
	DB	0x4E, 0x54, 0x45, 0x52, 0x2E, 0x00, 0x00, 0x50, 0x6C, 0x65, 0x61, 0x73, 0x65, 0x20, 0x69, 0x6E
	DB	0x73, 0x65, 0x72, 0x74, 0x20, 0x79, 0x6F, 0x75, 0x72, 0x20, 0x73, 0x61, 0x76, 0x65, 0x20, 0x67
	DB	0x61, 0x6D, 0x65, 0x0A, 0x64, 0x69, 0x73, 0x6B, 0x20, 0x61, 0x6E, 0x64, 0x20, 0x70, 0x72, 0x65
	DB	0x73, 0x73, 0x20, 0x45, 0x4E, 0x54, 0x45, 0x52, 0x2E, 0x00, 0x00, 0x54, 0x68, 0x61, 0x74, 0x20
	DB	0x69, 0x73, 0x20, 0x74, 0x68, 0x65, 0x20, 0x77, 0x72, 0x6F, 0x6E, 0x67, 0x20, 0x64, 0x69, 0x73
	DB	0x6B, 0x2E, 0x0A, 0x0A, 0x00, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x47, 0x61, 0x6D, 0x65, 0x20
	DB	0x70, 0x61, 0x75, 0x73, 0x65, 0x64, 0x2E, 0x0A, 0x50, 0x72, 0x65, 0x73, 0x73, 0x20, 0x45, 0x6E
	DB	0x74, 0x65, 0x72, 0x20, 0x74, 0x6F, 0x20, 0x63, 0x6F, 0x6E, 0x74, 0x69, 0x6E, 0x75, 0x65, 0x2E
	DB	0x00, 0x50, 0x72, 0x65, 0x73, 0x73, 0x20, 0x45, 0x4E, 0x54, 0x45, 0x52, 0x20, 0x74, 0x6F, 0x20
	DB	0x63, 0x6F, 0x6E, 0x74, 0x69, 0x6E, 0x75, 0x65, 0x2E, 0x0A, 0x50, 0x72, 0x65, 0x73, 0x73, 0x20
	DB	0x45, 0x53, 0x43, 0x20, 0x74, 0x6F, 0x20, 0x63, 0x61, 0x6E, 0x63, 0x65, 0x6C, 0x2E, 0x00, 0x20
	DB	0x2C, 0x2E, 0x3F, 0x21, 0x28, 0x29, 0x3B, 0x3A, 0x5B, 0x5D, 0x7B, 0x7D, 0x00, 0x27, 0x60, 0x2D
	DB	0x22, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x4D, 0x65, 0x73, 0x73, 0x61
	DB	0x67, 0x65, 0x20, 0x74, 0x6F, 0x6F, 0x20, 0x76, 0x65, 0x72, 0x62, 0x6F, 0x73, 0x65, 0x3A, 0x0A
	DB	0x0A, 0x22, 0x25, 0x73, 0x2E, 0x2E, 0x2E, 0x22, 0x0A, 0x0A, 0x50, 0x72, 0x65, 0x73, 0x73, 0x20
	DB	0x45, 0x53, 0x43, 0x20, 0x74, 0x6F, 0x20, 0x63, 0x6F, 0x6E, 0x74, 0x69, 0x6E, 0x75, 0x65, 0x2E
	DB	0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0x00, 0x14, 0x00, 0x08, 0x00, 0x5C, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x41, 0x62, 0x6F, 0x75
	DB	0x74, 0x20, 0x74, 0x6F, 0x20, 0x72, 0x65, 0x73, 0x74, 0x6F, 0x72, 0x65, 0x20, 0x74, 0x68, 0x65
	DB	0x20, 0x67, 0x61, 0x6D, 0x65, 0x0A, 0x64, 0x65, 0x73, 0x63, 0x72, 0x69, 0x62, 0x65, 0x64, 0x20
	DB	0x61, 0x73, 0x3A, 0x0A, 0x0A, 0x25, 0x73, 0x0A, 0x0A, 0x66, 0x72, 0x6F, 0x6D, 0x20, 0x66, 0x69
	DB	0x6C, 0x65, 0x3A, 0x0A, 0x25, 0x73, 0x0A, 0x0A, 0x25, 0x73, 0x00, 0x43, 0x61, 0x6E, 0x27, 0x74
	DB	0x20, 0x6F, 0x70, 0x65, 0x6E, 0x20, 0x66, 0x69, 0x6C, 0x65, 0x3A, 0x0A, 0x25, 0x73, 0x00, 0x45
	DB	0x72, 0x72, 0x6F, 0x72, 0x20, 0x69, 0x6E, 0x20, 0x72, 0x65, 0x73, 0x74, 0x6F, 0x72, 0x69, 0x6E
	DB	0x67, 0x20, 0x67, 0x61, 0x6D, 0x65, 0x2E, 0x0A, 0x50, 0x72, 0x65, 0x73, 0x73, 0x20, 0x45, 0x4E
	DB	0x54, 0x45, 0x52, 0x20, 0x74, 0x6F, 0x20, 0x71, 0x75, 0x69, 0x74, 0x2E, 0x00, 0x00, 0x41, 0x62
	DB	0x6F, 0x75, 0x74, 0x20, 0x74, 0x6F, 0x20, 0x73, 0x61, 0x76, 0x65, 0x20, 0x74, 0x68, 0x65, 0x20
	DB	0x67, 0x61, 0x6D, 0x65, 0x0A, 0x64, 0x65, 0x73, 0x63, 0x72, 0x69, 0x62, 0x65, 0x64, 0x20, 0x61
	DB	0x73, 0x3A, 0x0A, 0x0A, 0x25, 0x73, 0x0A, 0x0A, 0x69, 0x6E, 0x20, 0x66, 0x69, 0x6C, 0x65, 0x3A
	DB	0x0A, 0x25, 0x73, 0x0A, 0x0A, 0x25, 0x73, 0x00, 0x54, 0x68, 0x65, 0x20, 0x64, 0x69, 0x72, 0x65
	DB	0x63, 0x74, 0x6F, 0x72, 0x79, 0x0A, 0x25, 0x73, 0x0A, 0x20, 0x69, 0x73, 0x20, 0x66, 0x75, 0x6C
	DB	0x6C, 0x2E, 0x0A, 0x50, 0x72, 0x65, 0x73, 0x73, 0x20, 0x45, 0x4E, 0x54, 0x45, 0x52, 0x20, 0x74
	DB	0x6F, 0x20, 0x63, 0x6F, 0x6E, 0x74, 0x69, 0x6E, 0x75, 0x65, 0x2E, 0x00, 0x54, 0x68, 0x65, 0x20
	DB	0x64, 0x69, 0x73, 0x6B, 0x20, 0x69, 0x73, 0x20, 0x66, 0x75, 0x6C, 0x6C, 0x2E, 0x0A, 0x50, 0x72
	DB	0x65, 0x73, 0x73, 0x20, 0x45, 0x4E, 0x54, 0x45, 0x52, 0x20, 0x74, 0x6F, 0x20, 0x63, 0x6F, 0x6E
	DB	0x74, 0x69, 0x6E, 0x75, 0x65, 0x2E, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x25, 0x73, 0x25, 0x73, 0x0A, 0x25, 0x73, 0x00, 0x76, 0x6F
	DB	0x6C, 0x2E, 0x25, 0x64, 0x00, 0x43, 0x61, 0x6E, 0x27, 0x74, 0x20, 0x66, 0x69, 0x6E, 0x64, 0x20
	DB	0x25, 0x73, 0x2E, 0x25, 0x73, 0x25, 0x73, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
	DB	0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x6E, 0x6F, 0x74, 0x68, 0x69, 0x6E, 0x67, 0x00, 0x59, 0x6F, 0x75, 0x20
	DB	0x61, 0x72, 0x65, 0x20, 0x63, 0x61, 0x72, 0x72, 0x79, 0x69, 0x6E, 0x67, 0x3A, 0x00, 0x50, 0x72
	DB	0x65, 0x73, 0x73, 0x20, 0x45, 0x4E, 0x54, 0x45, 0x52, 0x20, 0x74, 0x6F, 0x20, 0x73, 0x65, 0x6C
	DB	0x65, 0x63, 0x74, 0x2C, 0x20, 0x45, 0x53, 0x43, 0x20, 0x74, 0x6F, 0x20, 0x63, 0x61, 0x6E, 0x63
	DB	0x65, 0x6C, 0x00, 0x50, 0x72, 0x65, 0x73, 0x73, 0x20, 0x61, 0x20, 0x6B, 0x65, 0x79, 0x20, 0x74
	DB	0x6F, 0x20, 0x72, 0x65, 0x74, 0x75, 0x72, 0x6E, 0x20, 0x74, 0x6F, 0x20, 0x74, 0x68, 0x65, 0x20
	DB	0x67, 0x61, 0x6D, 0x65, 0x00, 0x53, 0x63, 0x6F, 0x72, 0x65, 0x3A, 0x25, 0x64, 0x20, 0x6F, 0x66
	DB	0x20, 0x25, 0x64, 0x20, 0x20, 0x00, 0x53, 0x6F, 0x75, 0x6E, 0x64, 0x3A, 0x25, 0x73, 0x00, 0x6F
	DB	0x6E, 0x20, 0x00, 0x6F, 0x66, 0x66, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00

	DB	0x55, 0x6E, 0x6B, 0x6E, 0x6F, 0x77, 0x6E
	DB	0x20, 0x75, 0x6E, 0x69, 0x74, 0x00, 0x00, 0x55, 0x6E, 0x6B, 0x6E, 0x6F, 0x77, 0x6E, 0x20, 0x63
	DB	0x6F, 0x6D, 0x6D, 0x61, 0x6E, 0x64, 0x00, 0x44, 0x61, 0x74, 0x61, 0x20, 0x65, 0x72, 0x72, 0x6F
	DB	0x72, 0x00, 0x42, 0x61, 0x64, 0x20, 0x72, 0x65, 0x71, 0x75, 0x65, 0x73, 0x74, 0x20, 0x73, 0x74
	DB	0x72, 0x75, 0x63, 0x74, 0x75, 0x72, 0x65, 0x00, 0x53, 0x65, 0x65, 0x6B, 0x20, 0x65, 0x72, 0x72
	DB	0x6F, 0x72, 0x00, 0x55, 0x6E, 0x6B, 0x6E, 0x6F, 0x77, 0x6E, 0x20, 0x6D, 0x65, 0x64, 0x69, 0x61
	DB	0x20, 0x74, 0x79, 0x70, 0x65, 0x00, 0x53, 0x65, 0x63, 0x74, 0x6F, 0x72, 0x20, 0x6E, 0x6F, 0x74
	DB	0x20, 0x66, 0x6F, 0x75, 0x6E, 0x64, 0x00, 0x00, 0x57, 0x72, 0x69, 0x74, 0x65, 0x20, 0x66, 0x61
	DB	0x75, 0x6C, 0x74, 0x00, 0x52, 0x65, 0x61, 0x64, 0x20, 0x66, 0x61, 0x75, 0x6C, 0x74, 0x00, 0x47
	DB	0x65, 0x6E, 0x65, 0x72, 0x61, 0x6C, 0x20, 0x66, 0x61, 0x69, 0x6C, 0x75, 0x72, 0x65, 0x00, 0x44
	DB	0x69, 0x73, 0x6B, 0x20, 0x65, 0x72, 0x72, 0x6F, 0x72, 0x2E, 0x0A, 0x00, 0x54, 0x68, 0x65, 0x20
	DB	0x64, 0x69, 0x73, 0x6B, 0x20, 0x69, 0x73, 0x20, 0x77, 0x72, 0x69, 0x74, 0x65, 0x20, 0x70, 0x72
	DB	0x6F, 0x74, 0x65, 0x63, 0x74, 0x65, 0x64, 0x2E, 0x0A, 0x00, 0x54, 0x68, 0x65, 0x20, 0x64, 0x69
	DB	0x73, 0x6B, 0x20, 0x64, 0x72, 0x69, 0x76, 0x65, 0x20, 0x69, 0x73, 0x20, 0x6E, 0x6F, 0x74, 0x20
	DB	0x72, 0x65, 0x61, 0x64, 0x79, 0x2E, 0x0A, 0x00, 0x44, 0x69, 0x73, 0x6B, 0x20, 0x65, 0x72, 0x72
	DB	0x6F, 0x72, 0x3A, 0x0A, 0x25, 0x73, 0x0A, 0x00, 0x0A, 0x50, 0x72, 0x65, 0x73, 0x73, 0x20, 0x45
	DB	0x4E, 0x54, 0x45, 0x52, 0x20, 0x74, 0x6F, 0x20, 0x74, 0x72, 0x79, 0x20, 0x61, 0x67, 0x61, 0x69
	DB	0x6E, 0x2E, 0x00, 0x00, 0x98, 0x0F, 0x99, 0x0F, 0xA6, 0x0F, 0xA7, 0x0F, 0xB7, 0x0F, 0xC2, 0x0F
	DB	0xD8, 0x0F, 0xE3, 0x0F, 0xF6, 0x0F, 0x07, 0x10, 0x08, 0x10, 0x14, 0x10, 0x1F, 0x10, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0xFF
	
	DB	"HGC_Font", 0
	DB	"Tandylogic", 0
	DB	"view", 0
	DB	"picture", 0
	DB	"sound", 0
	DB	"%s %d not found", 0, 0
	DB	"logdir", 0, 0
	DB	"viewdir", 0
	DB	"picdir", 0, 0
	DB	"snddir", 0, 0
	
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0x00, 0x5C, 0x00, 0x2F, 0x00
	DB	0x25, 0x73, 0x25, 0x73, 0x25, 0x73, 0x73, 0x67, 0x2E, 0x25, 0x64, 0x00, 0x00, 0x28, 0x46, 0x6F
	DB	0x72, 0x20, 0x65, 0x78, 0x61, 0x6D, 0x70, 0x6C, 0x65, 0x2C, 0x20, 0x22, 0x42, 0x3A, 0x22, 0x20
	DB	0x6F, 0x72, 0x20, 0x22, 0x43, 0x3A, 0x5C, 0x73, 0x61, 0x76, 0x65, 0x67, 0x61, 0x6D, 0x65, 0x22
	DB	0x29, 0x00, 0x00, 0x5C, 0x2F, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0xB8, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF
	DB	0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x4E, 0x6F, 0x74, 0x20, 0x6E, 0x6F, 0x77, 0x2E, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x01, 0x01, 0x01, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x02, 0x01
	DB	0x04, 0x00, 0x00, 0x00, 0x00, 0x50, 0x6C, 0x65, 0x61, 0x73, 0x65, 0x20, 0x63, 0x65, 0x6E, 0x74
	DB	0x65, 0x72, 0x20, 0x79, 0x6F, 0x75, 0x72, 0x20, 0x6A, 0x6F, 0x79, 0x73, 0x74, 0x69, 0x63, 0x6B
	DB	0x2E, 0x0A, 0x0A, 0x50, 0x72, 0x65, 0x73, 0x73, 0x20, 0x45, 0x4E, 0x54, 0x45, 0x52, 0x20, 0x77
	DB	0x68, 0x65, 0x6E, 0x20, 0x69, 0x74, 0x20, 0x69, 0x73, 0x0A, 0x63, 0x65, 0x6E, 0x74, 0x65, 0x72
	DB	0x65, 0x64, 0x2E, 0x0A, 0x0A, 0x50, 0x72, 0x65, 0x73, 0x73, 0x20, 0x45, 0x53, 0x43, 0x20, 0x69
	DB	0x66, 0x20, 0x79, 0x6F, 0x75, 0x20, 0x64, 0x6F, 0x20, 0x6E, 0x6F, 0x74, 0x20, 0x77, 0x69, 0x73
	DB	0x68, 0x0A, 0x74, 0x6F, 0x20, 0x75, 0x73, 0x65, 0x20, 0x74, 0x68, 0x65, 0x20, 0x6A, 0x6F, 0x79
	DB	0x73, 0x74, 0x69, 0x63, 0x6B, 0x2E, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00
	
AGIDATA_1552:	
	DW	_6229
	DW	_624A
	DW	_625C
	DW	_6282
	DW	_63A7
	DW	_6398
	DW	_63DB
	DW	_63F3
	DW	_6440
	DW	_62B9
	DW	_6294

	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x40, 0x00, 0x20, 0x00, 0x10, 0x00, 0x08, 0x00
	DB	0x04, 0x00, 0x02, 0x00, 0x01, 0x80, 0x00, 0x40, 0x00, 0x20, 0x00, 0x10, 0x00, 0x08, 0x00, 0x04
	DB	0x00, 0x02, 0x00, 0x01, 0x00, 0xA5, 0x15, 0xA7, 0x15, 0xAD, 0x15, 0xB7, 0x15, 0xC5, 0x15, 0xD7
	DB	0x15, 0xEF, 0x15, 0x09, 0x16, 0x00, 0x80, 0x00, 0xE0, 0x00, 0xE0, 0x00, 0xE0, 0x00, 0x70, 0x00
	DB	0xF8, 0x00, 0xF8, 0x00, 0xF8, 0x00, 0x70, 0x00, 0x38, 0x00, 0x7C, 0x00, 0xFE, 0x00, 0xFE, 0x00
	DB	0xFE, 0x00, 0x7C, 0x00, 0x38, 0x00, 0x1C, 0x00, 0x7F, 0x80, 0xFF, 0x80, 0xFF, 0x80, 0xFF, 0x80
	DB	0xFF, 0x80, 0xFF, 0x00, 0x7F, 0x00, 0x1C, 0x00, 0x0E, 0x80, 0x3F, 0xC0, 0x7F, 0xC0, 0x7F, 0xE0
	DB	0xFF, 0xE0, 0xFF, 0xE0, 0xFF, 0xC0, 0x7F, 0xC0, 0x7F, 0x80, 0x3F, 0x00, 0x1F, 0x00, 0x0E, 0x80
	DB	0x0F, 0xE0, 0x3F, 0xF0, 0x7F, 0xF0, 0x7F, 0xF8, 0xFF, 0xF8, 0xFF, 0xF8, 0xFF, 0xF8, 0xFF, 0xF8
	DB	0xFF, 0xF0, 0x7F, 0xF0, 0x7F, 0xE0, 0x3F, 0x80, 0x0F, 0xC0, 0x07, 0xF0, 0x1F, 0xF8, 0x3F, 0xFC
	DB	0x7F, 0xFC, 0x7F, 0xFE, 0xFF, 0xFE, 0xFF, 0xFE, 0xFF, 0xFE, 0xFF, 0xFE, 0xFF, 0xFC, 0x7F, 0xFC
	DB	0x7F, 0xF8, 0x3F, 0xF0, 0x1F, 0xC0, 0x07, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x48, 0x01, 0x00, 0x00, 0x49, 0x02, 0x00, 0x00, 0x4D, 0x03, 0x00, 0x00, 0x51, 0x04, 0x00, 0x00
	DB	0x50, 0x05, 0x00, 0x00, 0x4F, 0x06, 0x00, 0x00, 0x4B, 0x07, 0x00, 0x00, 0x47, 0x08, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x38, 0x00, 0x01, 0x00, 0x39, 0x00, 0x02, 0x00, 0x36, 0x00, 0x03, 0x00, 0x33
	DB	0x00, 0x04, 0x00, 0x32, 0x00, 0x05, 0x00, 0x31, 0x00, 0x06, 0x00, 0x34, 0x00, 0x07, 0x00, 0x37
	DB	0x00, 0x08, 0x00, 0x35, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x4F
	DB	0x62, 0x6A, 0x65, 0x63, 0x74, 0x20, 0x25, 0x64, 0x3A, 0x0A, 0x78, 0x3A, 0x20, 0x25, 0x64, 0x20
	DB	0x20, 0x78, 0x73, 0x69, 0x7A, 0x65, 0x3A, 0x20, 0x25, 0x64, 0x0A, 0x79, 0x3A, 0x20, 0x25, 0x64
	DB	0x20, 0x20, 0x79, 0x73, 0x69, 0x7A, 0x65, 0x3A, 0x20, 0x25, 0x64, 0x0A, 0x70, 0x72, 0x69, 0x3A
	DB	0x20, 0x25, 0x64, 0x0A, 0x73, 0x74, 0x65, 0x70, 0x73, 0x69, 0x7A, 0x65, 0x3A, 0x20, 0x25, 0x64
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0xFF, 0x01, 0x01, 0xFF, 0xFF, 0xFF, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x9F, 0x00, 0xBF, 0x00
	DB	0xDF, 0x00, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0A, 0x0A, 0x52, 0x6F, 0x6F, 0x6D, 0x20
	DB	0x25, 0x64, 0x0A, 0x49, 0x6E, 0x70, 0x75, 0x74, 0x20, 0x6C, 0x69, 0x6E, 0x65, 0x3A, 0x20, 0x25
	DB	0x73, 0x0A, 0x00, 0xFF, 0xFF, 0x6C, 0x6F, 0x67, 0x66, 0x69, 0x6C, 0x65, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03
	DB	0x53, 0x74, 0x61, 0x63, 0x6B, 0x20, 0x62, 0x6C, 0x6F, 0x77, 0x6E, 0x2E, 0x0A, 0x50, 0x72, 0x65
	DB	0x73, 0x73, 0x20, 0x45, 0x53, 0x43, 0x20, 0x74, 0x6F, 0x20, 0x65, 0x78, 0x69, 0x74, 0x2E, 0x00
	DB	0x72, 0x65, 0x73, 0x74, 0x6F, 0x72, 0x65, 0x00, 0x73, 0x61, 0x76, 0x65, 0x00, 0x20, 0x2D, 0x20
	DB	0x25, 0x73, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x53, 0x41, 0x56
	DB	0x45, 0x20, 0x47, 0x41, 0x4D, 0x45, 0x0A, 0x0A, 0x4F, 0x6E, 0x20, 0x77, 0x68, 0x69, 0x63, 0x68
	DB	0x20, 0x64, 0x69, 0x73, 0x6B, 0x20, 0x6F, 0x72, 0x20, 0x69, 0x6E, 0x20, 0x77, 0x68, 0x69, 0x63
	DB	0x68, 0x20, 0x64, 0x69, 0x72, 0x65, 0x63, 0x74, 0x6F, 0x72, 0x79, 0x20, 0x64, 0x6F, 0x20, 0x79
	DB	0x6F, 0x75, 0x20, 0x77, 0x69, 0x73, 0x68, 0x20, 0x74, 0x6F, 0x20, 0x73, 0x61, 0x76, 0x65, 0x20
	DB	0x74, 0x68, 0x69, 0x73, 0x20, 0x67, 0x61, 0x6D, 0x65, 0x3F, 0x0A, 0x0A, 0x25, 0x73, 0x0A, 0x0A
	DB	0x00, 0x00, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x52, 0x45, 0x53, 0x54, 0x4F, 0x52
	DB	0x45, 0x20, 0x47, 0x41, 0x4D, 0x45, 0x0A, 0x0A, 0x4F, 0x6E, 0x20, 0x77, 0x68, 0x69, 0x63, 0x68
	DB	0x20, 0x64, 0x69, 0x73, 0x6B, 0x20, 0x6F, 0x72, 0x20, 0x69, 0x6E, 0x20, 0x77, 0x68, 0x69, 0x63
	DB	0x68, 0x20, 0x64, 0x69, 0x72, 0x65, 0x63, 0x74, 0x6F, 0x72, 0x79, 0x20, 0x69, 0x73, 0x20, 0x74
	DB	0x68, 0x65, 0x20, 0x67, 0x61, 0x6D, 0x65, 0x20, 0x74, 0x68, 0x61, 0x74, 0x20, 0x79, 0x6F, 0x75
	DB	0x20, 0x77, 0x61, 0x6E, 0x74, 0x20, 0x74, 0x6F, 0x20, 0x72, 0x65, 0x73, 0x74, 0x6F, 0x72, 0x65
	DB	0x3F, 0x0A, 0x0A, 0x25, 0x73, 0x0A, 0x0A, 0x00, 0x50, 0x6C, 0x65, 0x61, 0x73, 0x65, 0x20, 0x70
	DB	0x75, 0x74, 0x20, 0x79, 0x6F, 0x75, 0x72, 0x20, 0x73, 0x61, 0x76, 0x65, 0x20, 0x67, 0x61, 0x6D
	DB	0x65, 0x0A, 0x64, 0x69, 0x73, 0x6B, 0x20, 0x69, 0x6E, 0x20, 0x64, 0x72, 0x69, 0x76, 0x65, 0x20
	DB	0x25, 0x63, 0x2E, 0x0A, 0x50, 0x72, 0x65, 0x73, 0x73, 0x20, 0x45, 0x4E, 0x54, 0x45, 0x52, 0x20
	DB	0x74, 0x6F, 0x20, 0x63, 0x6F, 0x6E, 0x74, 0x69, 0x6E, 0x75, 0x65, 0x2E, 0x0A, 0x50, 0x72, 0x65
	DB	0x73, 0x73, 0x20, 0x45, 0x53, 0x43, 0x20, 0x74, 0x6F, 0x20, 0x6E, 0x6F, 0x74, 0x20, 0x25, 0x73
	DB	0x20, 0x61, 0x20, 0x67, 0x61, 0x6D, 0x65, 0x2E, 0x00, 0x00, 0x55, 0x73, 0x65, 0x20, 0x74, 0x68
	DB	0x65, 0x20, 0x61, 0x72, 0x72, 0x6F, 0x77, 0x20, 0x6B, 0x65, 0x79, 0x73, 0x20, 0x74, 0x6F, 0x20
	DB	0x73, 0x65, 0x6C, 0x65, 0x63, 0x74, 0x20, 0x74, 0x68, 0x65, 0x20, 0x73, 0x6C, 0x6F, 0x74, 0x20
	DB	0x69, 0x6E, 0x20, 0x77, 0x68, 0x69, 0x63, 0x68, 0x20, 0x79, 0x6F, 0x75, 0x20, 0x77, 0x69, 0x73
	DB	0x68, 0x20, 0x74, 0x6F, 0x20, 0x73, 0x61, 0x76, 0x65, 0x20, 0x74, 0x68, 0x65, 0x20, 0x67, 0x61
	DB	0x6D, 0x65, 0x2E, 0x20, 0x50, 0x72, 0x65, 0x73, 0x73, 0x20, 0x45, 0x4E, 0x54, 0x45, 0x52, 0x20
	DB	0x74, 0x6F, 0x20, 0x73, 0x61, 0x76, 0x65, 0x20, 0x69, 0x6E, 0x20, 0x74, 0x68, 0x65, 0x20, 0x73
	DB	0x6C, 0x6F, 0x74, 0x2C, 0x20, 0x45, 0x53, 0x43, 0x20, 0x74, 0x6F, 0x20, 0x6E, 0x6F, 0x74, 0x20
	DB	0x73, 0x61, 0x76, 0x65, 0x20, 0x61, 0x20, 0x67, 0x61, 0x6D, 0x65, 0x2E, 0x00, 0x00, 0x55, 0x73
	DB	0x65, 0x20, 0x74, 0x68, 0x65, 0x20, 0x61, 0x72, 0x72, 0x6F, 0x77, 0x20, 0x6B, 0x65, 0x79, 0x73
	DB	0x20, 0x74, 0x6F, 0x20, 0x73, 0x65, 0x6C, 0x65, 0x63, 0x74, 0x20, 0x74, 0x68, 0x65, 0x20, 0x67
	DB	0x61, 0x6D, 0x65, 0x20, 0x77, 0x68, 0x69, 0x63, 0x68, 0x20, 0x79, 0x6F, 0x75, 0x20, 0x77, 0x69
	DB	0x73, 0x68, 0x20, 0x74, 0x6F, 0x20, 0x72, 0x65, 0x73, 0x74, 0x6F, 0x72, 0x65, 0x2E, 0x20, 0x50
	DB	0x72, 0x65, 0x73, 0x73, 0x20, 0x45, 0x4E, 0x54, 0x45, 0x52, 0x20, 0x74, 0x6F, 0x20, 0x72, 0x65
	DB	0x73, 0x74, 0x6F, 0x72, 0x65, 0x20, 0x74, 0x68, 0x65, 0x20, 0x67, 0x61, 0x6D, 0x65, 0x2C, 0x20
	DB	0x45, 0x53, 0x43, 0x20, 0x74, 0x6F, 0x20, 0x6E, 0x6F, 0x74, 0x20, 0x72, 0x65, 0x73, 0x74, 0x6F
	DB	0x72, 0x65, 0x20, 0x61, 0x20, 0x67, 0x61, 0x6D, 0x65, 0x2E, 0x00, 0x00, 0x48, 0x6F, 0x77, 0x20
	DB	0x77, 0x6F, 0x75, 0x6C, 0x64, 0x20, 0x79, 0x6F, 0x75, 0x20, 0x6C, 0x69, 0x6B, 0x65, 0x20, 0x74
	DB	0x6F, 0x20, 0x64, 0x65, 0x73, 0x63, 0x72, 0x69, 0x62, 0x65, 0x20, 0x74, 0x68, 0x69, 0x73, 0x20
	DB	0x73, 0x61, 0x76, 0x65, 0x64, 0x20, 0x67, 0x61, 0x6D, 0x65, 0x3F, 0x0A, 0x0A, 0x00, 0x54, 0x68
	DB	0x65, 0x72, 0x65, 0x20, 0x61, 0x72, 0x65, 0x20, 0x6E, 0x6F, 0x20, 0x67, 0x61, 0x6D, 0x65, 0x73
	DB	0x20, 0x74, 0x6F, 0x0A, 0x72, 0x65, 0x73, 0x74, 0x6F, 0x72, 0x65, 0x20, 0x69, 0x6E, 0x0A, 0x0A
	DB	0x25, 0x73, 0x0A, 0x0A, 0x50, 0x72, 0x65, 0x73, 0x73, 0x20, 0x45, 0x4E, 0x54, 0x45, 0x52, 0x20
	DB	0x74, 0x6F, 0x20, 0x63, 0x6F, 0x6E, 0x74, 0x69, 0x6E, 0x75, 0x65, 0x2E, 0x00, 0x00, 0x54, 0x68
	DB	0x65, 0x72, 0x65, 0x20, 0x69, 0x73, 0x20, 0x6E, 0x6F, 0x20, 0x64, 0x69, 0x72, 0x65, 0x63, 0x74
	DB	0x6F, 0x72, 0x79, 0x20, 0x6E, 0x61, 0x6D, 0x65, 0x64, 0x0A, 0x25, 0x73, 0x2E, 0x0A, 0x50, 0x72
	DB	0x65, 0x73, 0x73, 0x20, 0x45, 0x4E, 0x54, 0x45, 0x52, 0x20, 0x74, 0x6F, 0x20, 0x74, 0x72, 0x79
	DB	0x20, 0x61, 0x67, 0x61, 0x69, 0x6E, 0x2E, 0x0A, 0x50, 0x72, 0x65, 0x73, 0x73, 0x20, 0x45, 0x53
	DB	0x43, 0x20, 0x74, 0x6F, 0x20, 0x63, 0x61, 0x6E, 0x63, 0x65, 0x6C, 0x2E, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x3D, 0x3D
	DB	0x3D, 0x3D, 0x3D, 0x3D, 0x3D, 0x3D, 0x3D, 0x3D, 0x3D, 0x3D, 0x3D, 0x3D, 0x3D, 0x3D, 0x3D, 0x3D
	DB	0x3D, 0x3D, 0x3D, 0x3D, 0x3D, 0x3D, 0x3D, 0x3D, 0x00, 0x25, 0x64, 0x3A, 0x20, 0x25, 0x64, 0x00
	DB	0x25, 0x64, 0x3A, 0x20, 0x25, 0x73, 0x00, 0x72, 0x65, 0x74, 0x75, 0x72, 0x6E, 0x00, 0x20, 0x3A
	DB	0x25, 0x63, 0x00, 0x25, 0x64, 0x00, 0x25, 0x64, 0x00, 0x00, 0x01, 0x00, 0x0F, 0x00, 0xFF, 0xFF
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x01, 0x04
	DB	0x05, 0x03, 0x01, 0x00, 0x04, 0x0A, 0x0A, 0x06, 0x03, 0x0C, 0x08, 0x0B, 0x0E, 0x05, 0x03, 0x04
	DB	0x0A, 0x04, 0x03, 0x07, 0x0D, 0x00, 0x09, 0x01, 0x04, 0x0B, 0x05, 0x05, 0x0E, 0x0E, 0x0E, 0x0C
	DB	0x02, 0x08, 0x0D, 0x0D, 0x07, 0x0F, 0x0F, 0x0F, 0x00, 0x22, 0x11, 0x33, 0x44, 0x66, 0x88, 0x55
	DB	0xAA, 0x77, 0x99, 0xBB, 0xEE, 0xCC, 0xDD, 0xFF, 0x00, 0x00, 0xCC, 0x11, 0xAA, 0x22, 0x99, 0xDD
	DB	0x00, 0x33, 0x55, 0x77, 0xEE, 0xEE, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x35, 0x2D, 0x2E, 0x07, 0x5B, 0x02
	DB	0x57, 0x57, 0x02, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x88, 0x00, 0x00, 0x00, 0x22, 0x00, 0x00, 0x00, 0x80, 0x10, 0x02, 0x20, 0x01, 0x08
	DB	0x40, 0x04, 0xAA, 0x00, 0xAA, 0x00, 0xAA, 0x00, 0xAA, 0x00, 0x22, 0x88, 0x22, 0x88, 0x22, 0x88
	DB	0x22, 0x88, 0x88, 0x00, 0x88, 0x00, 0x88, 0x00, 0x88, 0x00, 0x11, 0x22, 0x44, 0x88, 0x11, 0x22
	DB	0x44, 0x88, 0x55, 0xAA, 0x55, 0xAA, 0x55, 0xAA, 0x55, 0xAA, 0x22, 0x00, 0x88, 0x00, 0x22, 0x00
	DB	0x88, 0x00, 0xD7, 0xFF, 0x7D, 0xFF, 0xD7, 0xFF, 0x7D, 0xFF, 0xDD, 0x55, 0x77, 0xAA, 0xDD, 0x55
	DB	0x77, 0xAA, 0x7F, 0xEF, 0xFD, 0xDF, 0xFE, 0xF7, 0xBF, 0xFB, 0xAA, 0xFF, 0xAA, 0xFF, 0xAA, 0xFF
	DB	0xAA, 0xFF, 0x77, 0xBB, 0xDD, 0xEE, 0x77, 0xBB, 0xDD, 0xEE, 0x77, 0xFF, 0xFF, 0xFF, 0xDD, 0xFF
	DB	0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x0A, 0x00, 0x0A, 0x0A, 0x00, 0x00
	DB	0x45, 0x4E, 0x54, 0x45, 0x52, 0x20, 0x43, 0x4F, 0x4D, 0x4D, 0x41, 0x4E, 0x44, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00

	DB	0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53	; 0x1C90
	DB	0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53	; 0x1CA0
	DB	0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53
	DB	0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53
	DB	0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53
	DB	0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53
	DB	0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53
	DB	0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53, 0x53

	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	DB	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
