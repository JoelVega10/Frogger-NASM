columnas equ 15
filas equ 13
sys_write equ 4 
stdout equ 1
sys_exit    equ     1
sys_read equ 3
stdin       equ     0
stderr      equ     3

SECTION .data


men_opcion_no_valida: db "Opcion ingresada no valida.",0x0A
len_opcion_no_valida: equ $-men_opcion_no_valida

mensaje_menu: db "Comenzar juego nuevo(n) o finalizar(f)?",0x0A
len_mensaje_menu: equ $-mensaje_menu

perdio: db " __   __            _                 _  ",0x0A 
len_perdio: equ $-perdio
perdio1: db " \ \ / /___  _  _  | | ___  ___ ___  | |  ",0x0A
len_perdio1: equ $-perdio1
perdio2: db  "  \ V // _ \| || | | |/ _ \(_-</ -_) |_|  ",0x0A
len_perdio2: equ $-perdio2
perdio3: db   "   |_| \___/ \_,_| |_|\___//__/\___| (_)  ",0x0A
len_perdio3: equ $-perdio3


gano: db "  ____    ____  ______    __    __     ____    __    ____  __  .__   __.  __           ___" ,0x0A
len_gano: equ $-gano
gano1: db "  \   \  /   / /  __  \  |  |  |  |    \   \  /  \  /   / |  | |  \ |  | |  |     _    \  \ " ,0x0A
len_gano1: equ $-gano1
gano2: db  "   \   \/   / |  |  |  | |  |  |  |     \   \/    \/   /  |  | |   \|  | |  |    (_)    |  |" ,0x0A
len_gano2: equ $-gano2
gano3: db   "    \_    _/  |  |  |  | |  |  |  |      \            /   |  | |  . `  | |  |           |  |" ,0x0A
len_gano3: equ $-gano3
gano4: db   "      |  |    |  `--'  | |  `--'  |       \    /\    /    |  | |  |\   | |__|     _     |  |" ,0x0A
len_gano4: equ $-gano4
gano5: db   "      |__|     \______/   \______/         \__/  \__/     |__| |__| \__| (__)    (_)    |  |" ,0x0A
len_gano5: equ $-gano5
gano6: db     "                                                                                       /__/ " ,0x0A
len_gano6: equ $-gano6

salto: dd 0xa, 0xd
sal_len: equ $-salto

ClearTerm: db   27,"[H",27,"[2J"    ; <ESC> [H <ESC> [2J
CLEARLEN   equ  $-ClearTerm         ; Length of term clear string

         
max dd 15 

      
SECTION .bss

	tablero resb 980100 
	tablero_log resb 980100                   
	movimiento resb 2   

	  
		
SECTION .text
                                 
global _start


_start:
	nop

crear_matriz:
	xor ecx,ecx
	xor edx, edx
	xor eax,eax
	xor ebx,ebx
	mov ebx,tablero


forI:
	xor esi,esi
	cmp ecx,filas
	jl forJ
	jmp crear_matriz_log


forJ:
	cmp esi,columnas
	jl initialization
	inc ecx
	jmp forI

initialization:  
	mov eax,ecx                                              
	cmp eax, 0
	jz primera_linea
	cmp eax, 6
	jz camino
	cmp eax, 12
	jz camino 
	cmp eax, 7
	jl agua
	jmp espacio_libre
	
crear_matriz_log:
	xor ecx,ecx
	xor eax,eax
	xor ebx,ebx
	mov ebx,tablero_log


forI2:
	xor esi,esi
	cmp ecx,filas
	jl forJ2
	jmp colocar_jugador


forJ2:
	cmp esi,columnas
	jl initialization2
	inc ecx
	jmp forI2

initialization2:  
	mov eax,ecx                                              
	mul dword[max]
	add eax,esi 
	mov dword[ebx + eax * 4],0
	inc esi 
	jmp forJ2

espacio_libre:
	mul dword[max]
	add eax,esi 
	mov dword[ebx + eax * 4],' ' 
	inc esi 
	jmp forJ
	

camino:
	mul dword[max]
	add eax,esi 
	mov dword[ebx + eax * 4],"="
	inc esi 
	jmp forJ

agua:
	mul dword[max]
	add eax,esi 
	mov dword[ebx + eax * 4],'~'
	inc esi 
	jmp forJ

primera_linea:
	mul dword[max]
	add eax,esi 
	call es_par
	cmp edx,0
	jz pared
	mov eax,ecx
	jmp poner_x
	
pared:
	mul dword[max]
	add eax,esi 
	mov dword[ebx + eax * 4],'|' 
	inc esi 
	jmp forJ
	
	
poner_x:
 	mov eax,ecx
	mul dword[max]
	add eax,esi 
	mov dword[ebx + eax * 4],'x'
	inc esi
	jmp forJ 
	

print:
	mov eax, 4                          ; Specify sys_write call
	mov ebx, 1                          ; Specify File Descriptor 1: Stdout
	mov ecx, ClearTerm                  ; Pass offset of terminal control string
	mov edx, CLEARLEN                   ; Pass the length of terminal control string
	int 80h
    mov     esi,tablero
    mov     ecx,filas
    mov     edx,columnas
    imul    ecx,edx
    mov     ebx,ecx
    dec     ebx
    mov     edi, ebx             
    mov     eax, 1

.PrintArray:
    mov     ebx,columnas
    inc     ebx
    cmp     eax,ebx
    jnz     .continue
    call    print_endLine
    jmp     .continue

.continue:
    push    eax                  
    mov     ecx,[esi]                                                            
    push    ecx                          
    mov     ecx, esp    
    mov     edx, 1                 
    mov     ebx, stdout
    mov     eax, sys_write
    int     80h                             
    dec edx
    pop     ecx                             
    add esi,4                        
    pop     eax
    inc     eax
    dec     edi                             
    jns     .PrintArray   
                     
done:
     call print_endLine
     jmp preguntar_movimiento


preguntar_movimiento:
      mov eax, 3
	  mov ebx, 0
   	  mov ecx, movimiento              
   	  mov edx, 2    
      int 80h
      mov ecx, [movimiento]
	  cmp ecx, 0xa77
      jz mover_arriba
      cmp ecx, 0xa73
      jz mover_abajo
      cmp ecx, 0xa64
      jz mover_derecha
      cmp ecx, 0xa61
      jz mover_izquierda
      jmp opcion_no_valida_inicial


print_endLine:
    mov ecx, salto
    mov edx, sal_len
    call display_text
    int 0x80
    mov eax, 1
    ret

display_text:
	mov eax,sys_write
	mov ebx, stdout
	int 80h
	ret

colocar_jugador:
	mov eax,tablero
	mov ebx, 187
	mov edi, dword[eax+ebx*4]
	mov dword[eax+ebx*4], 'o'
	push ebx
	push edi 
	jmp colocar_automoviles


colocar_automoviles:
	mov eax,tablero
	mov ecx,tablero_log
	mov ebx, 177
	mov dword[eax+ebx*4], '<'
	mov dword[ecx+ebx*4], 1
	mov ebx, 170
	mov dword[eax+ebx*4], '<'
	mov dword[ecx+ebx*4], 1
	mov ebx, 165
	mov dword[eax+ebx*4], '<'
	mov dword[ecx+ebx*4], 1
	mov ebx, 164
	mov dword[eax+ebx*4], '>'
	mov dword[ecx+ebx*4], 3
	mov ebx, 160
	mov dword[eax+ebx*4], '>'
	mov dword[ecx+ebx*4], 3
	mov ebx, 155
	mov dword[eax+ebx*4], '>'
	mov dword[ecx+ebx*4], 3
	mov ebx,148
	mov dword[eax+ebx*4], '<'
	dec ebx
	mov dword[eax+ebx*4], '<'
	mov dword[ecx+ebx*4], 5
	mov ebx,137
	mov dword[eax+ebx*4], '<'
	dec ebx
	mov dword[eax+ebx*4], '<'
	mov dword[ecx+ebx*4], 5
	mov ebx,132
	mov dword[eax+ebx*4], '>'
	mov dword[ecx+ebx*4], 9
	dec ebx
	mov dword[eax+ebx*4], '>'
	dec ebx
	mov dword[eax+ebx*4], '>'
	mov ebx, 118
	mov dword[eax+ebx*4], '>'
	mov dword[ecx+ebx*4], 3
	mov ebx, 111
	mov dword[eax+ebx*4], '>'
	mov dword[ecx+ebx*4], 3
	mov ebx, 106
	mov dword[eax+ebx*4], '>'
	mov dword[ecx+ebx*4], 3
	jmp colocar_troncos


colocar_troncos:
	mov ebx, 18
	mov dword[eax+ebx*4], '_'
	mov dword[ecx+ebx*4], "3"
	inc ebx
	mov dword[eax+ebx*4], '_'
	mov ebx, 22
	mov dword[eax+ebx*4], '_'
	mov dword[ecx+ebx*4], "3"
	inc ebx
	mov dword[eax+ebx*4], '_'
	mov ebx, 26
	mov dword[eax+ebx*4], '_'
	mov dword[ecx+ebx*4], "3"
	inc ebx
	mov dword[eax+ebx*4], '_'
	mov ebx, 47
	mov dword[eax+ebx*4], '_'
	mov dword[ecx+ebx*4], "1"
	inc ebx
	mov dword[eax+ebx*4], '_'
	mov ebx, 51 
	mov dword[eax+ebx*4], '_'
	mov dword[ecx+ebx*4], "1"
	inc ebx
	mov dword[eax+ebx*4], '_'
	mov ebx, 55
	mov dword[eax+ebx*4], '_'
	mov dword[ecx+ebx*4], "1"
	inc ebx
	mov dword[eax+ebx*4], '_'
	mov ebx, 77
	mov dword[eax+ebx*4], '_'
	mov dword[ecx+ebx*4], "3"
	inc ebx
	mov dword[eax+ebx*4], '_'
	mov ebx, 81
	mov dword[eax+ebx*4], '_'
	mov dword[ecx+ebx*4], "3"
	inc ebx
	mov dword[eax+ebx*4], '_'
	mov ebx, 85
	mov dword[eax+ebx*4], '_'
	mov dword[ecx+ebx*4], "3"
	inc ebx
	mov dword[eax+ebx*4], '_' 
	mov ebx,30
	mov dword[eax+ebx*4], '_'
	mov dword[ecx+ebx*4], "5"
	inc ebx 
	mov dword[eax+ebx*4], '_'
	inc ebx 
	mov dword[eax+ebx*4], '_'
	mov ebx ,37
	mov dword[eax+ebx*4], '_'
	mov dword[ecx+ebx*4], "5"
	inc ebx 
	mov dword[eax+ebx*4], '_'
	inc ebx 
	mov dword[eax+ebx*4], '_'
	mov ebx ,65
	mov dword[eax+ebx*4], '_'
	mov dword[ecx+ebx*4], "5"
	inc ebx 
	mov dword[eax+ebx*4], '_'
	inc ebx 
	mov dword[eax+ebx*4], '_'
	mov ebx ,70
	mov dword[eax+ebx*4], '_'
	mov dword[ecx+ebx*4], "5"
	inc ebx 
	mov dword[eax+ebx*4], '_'
	inc ebx 
	mov dword[eax+ebx*4], '_'
	jmp print

mover_automoviles:
	mov eax,tablero_log
	mov ebx, tablero
	xor ecx, ecx
	jmp for_automoviles

for_automoviles:
	  mov edx,filas
	  imul edx, columnas
	  cmp ecx,edx
	  jl mover_objetos
	  jmp print

mover_objetos:
	cmp dword[eax+ecx*4],1
	jz mover_rapidos_izquierda
	cmp dword[eax+ecx*4],2
	jz rapido_bandera
	cmp dword[eax+ecx*4],3
	jz mover_rapidos_derecha
	cmp dword[eax+ecx*4],5
	jz mover_medios_izquierda
	cmp dword[eax+ecx*4],6
	jz rapido_bandera
	cmp dword[eax+ecx*4],7
	jz rapido_bandera
	cmp dword[eax+ecx*4],8
	jz rapido_bandera
	cmp dword[eax+ecx*4],9
	jz mover_lentos_derecha
	cmp dword[eax+ecx*4],13
	jz rapido_bandera
	cmp dword[eax+ecx*4],12
	jz rapido_bandera
	cmp dword[eax+ecx*4],11
	jz rapido_bandera
	cmp dword[eax+ecx*4],10
	jz rapido_bandera
	cmp dword[eax+ecx*4],"1"
	jz mover_troncos_rapidos_izquierda
	cmp dword[eax+ecx*4],"2"
	jz rapido_bandera
	cmp dword[eax+ecx*4],"3"
	jz mover_troncos_rapidos_derecha
	cmp dword[eax+ecx*4],"4"
	jz esquina_tronco_derecha
	cmp dword[eax+ecx*4],"5"
	jz mover_troncos_medio_derecha
	cmp dword[eax+ecx*4],"6"
	jz rapido_bandera
	cmp dword[eax+ecx*4],"7"
	jz esquina_tronco_medio_derecha
	inc ecx
	jmp for_automoviles

	

esquina_tronco_derecha:
	mov esi,ecx
	dec esi
	mov dword[ebx+esi*4], '~'
	inc esi
	mov dword[eax+esi*4], 0
	mov dword[ebx+esi*4], '_'
	mov dword[eax+esi*4], "3"
	inc esi 
	mov dword[ebx+esi*4], '_'
	add ecx, 2
	jmp for_automoviles


mover_troncos_rapidos_derecha:
	inc ecx 
	pusha
	call modulo_derecha_autos
	cmp edx,0 
	jz continuar_fila_troncos_rapidos_derecha
	jmp realizar_movimiento_troncos_rapidos_derecha	


realizar_movimiento_troncos_rapidos_derecha:
	popa
	dec ecx
	mov esi,ecx
	dec esi
	mov dword[ebx+esi*4], '~'
	inc esi
	mov dword[eax+esi*4], 0
	mov dword[ebx+esi*4], '~'
	inc esi 
	mov dword[eax+esi*4], "3"
	inc esi 
	mov dword[ebx+esi*4], '_'
	add ecx, 2
	jmp for_automoviles

continuar_fila_troncos_rapidos_derecha:
	popa
	dec ecx
	mov esi,ecx
	mov dword[ebx+esi*4], '~'
	mov dword[eax+esi*4], 0
	inc esi 
	mov dword[ebx+esi*4], '~'
	mov dword[eax+esi*4], 0
	sub esi, 13
	mov dword[ebx+esi*4], '_'
	mov dword[eax+esi*4], "4"
	dec esi 
	mov dword[ebx+esi*4], '_'
	add ecx , 2
	jmp for_automoviles


esquina_tronco_medio_derecha:
	mov esi,ecx
	dec esi
	mov dword[ebx+esi*4], '~'
	inc esi 
	mov dword[eax+esi*4], "6"
	inc esi 
	mov dword[ebx+esi*4], '_'
	inc esi 
	mov dword[ebx+esi*4], '_'
	add ecx, 3
	jmp for_automoviles


mover_troncos_medio_derecha:
	add ecx, 2 
	pusha
	call modulo_derecha_autos
	cmp edx,0 
	jz continuar_fila_troncos_medio_derecha
	jmp realizar_movimiento_troncos_medio_derecha	


realizar_movimiento_troncos_medio_derecha:
	popa
	sub ecx, 2
	mov esi,ecx
	dec esi
	mov dword[ebx+esi*4], '~'
	inc esi
	mov dword[eax+esi*4], "0"
	mov dword[ebx+esi*4], '~'
	inc esi 
	mov dword[eax+esi*4], "6"
	add esi, 2 
	mov dword[ebx+esi*4], '_'
	add ecx, 3
	jmp for_automoviles

continuar_fila_troncos_medio_derecha:
	popa
	sub ecx, 2
	mov esi,ecx
	mov dword[ebx+esi*4], '~'
	mov dword[eax+esi*4], 0
	inc esi 
	mov dword[ebx+esi*4], '~'
	mov dword[eax+esi*4], 0
	inc esi 
	mov dword[ebx+esi*4], '~'
	mov dword[eax+esi*4], 0
	sub esi, 13
	mov dword[ebx+esi*4], '_'
	mov dword[eax+esi*4], "7"
	dec esi 
	mov dword[ebx+esi*4], '_'
	add esi, 2 
	mov dword[ebx+esi*4], '_'
	add ecx , 3
	jmp for_automoviles


mover_troncos_rapidos_izquierda:
	pusha
	call modulo_izquierda_autos
	cmp edx,0 
	jz continuar_fila_troncos_rapidos_izquierda
	jmp realizar_movimiento_troncos_rapidos_izquierda


realizar_movimiento_troncos_rapidos_izquierda:
	popa
	mov esi,ecx
	inc esi
	mov dword[ebx+esi*4], '~'
	dec esi
	mov dword[eax+esi*4], 0
	dec esi 
	mov dword[eax+esi*4], "1"
	mov dword[ebx+esi*4], '_'
	inc ecx
	jmp for_automoviles

	

continuar_fila_troncos_rapidos_izquierda:
	popa
	mov esi,ecx
	mov dword[ebx+esi*4], '~'
	mov dword[eax+esi*4], 0
	inc esi 
	mov dword[ebx+esi*4], '~'
	mov dword[eax+esi*4], 0
	add esi, 13
	mov dword[ebx+esi*4], '_'
	dec esi 
	mov dword[eax+esi*4], "2"
	mov dword[ebx+esi*4], '_'
	inc ecx
	jmp for_automoviles

rapido_bandera:
	mov edx,dword[eax+ecx*4]
	dec edx
	mov dword[eax+ecx*4],edx
	inc ecx 
	jmp for_automoviles 
	

mover_rapidos_izquierda:
	pusha
	call modulo_izquierda_autos
	cmp edx,0 
	jz continuar_fila
	jmp realizar_movimiento 	


realizar_movimiento:
	popa
	mov dword[ebx+ecx*4], ' ' 
	mov dword[eax+ecx*4], 0
	mov esi,ecx
	dec esi 
    call verificar_perdida_automovil
	mov dword[ebx+esi*4], '<'
	mov dword[eax+esi*4], 1
	inc ecx
	jmp for_automoviles

continuar_fila:
	popa
	mov dword[ebx+ecx*4], ' '
	mov dword[eax+ecx*4], 0
	mov edx,ecx
	add edx,14
	call verificar_perdida_automovil
	mov dword[ebx+edx*4], '<'
	mov dword[eax+edx*4], 2
	inc ecx
	jmp for_automoviles
	

mover_rapidos_derecha:
	pusha
	call modulo_derecha_autos
	cmp edx,0 
	jz continuar_fila_derecha
	jmp realizar_movimiento_derecha 


realizar_movimiento_derecha:
	popa
	mov dword[ebx+ecx*4], ' '
	mov dword[eax+ecx*4], 0
	mov esi,ecx
	inc esi 
	call verificar_perdida_automovil
	mov dword[ebx+esi*4], '>'
	mov dword[eax+esi*4], 3
	add ecx, 2
	jmp for_automoviles

continuar_fila_derecha:
	popa
	mov dword[ebx+ecx*4], ' '
	mov dword[eax+ecx*4], 0
	mov edx,ecx
	sub edx,14
	call verificar_perdida_automovil
	mov dword[ebx+edx*4], '>'
	mov dword[eax+edx*4], 3
	add ecx, 2
	jmp for_automoviles



mover_medios_izquierda:
	pusha
	call modulo_izquierda_autos
	cmp edx,0 
	jz continuar_fila_medios_izquierda
	jmp realizar_movimiento_medios_izquierda 	


realizar_movimiento_medios_izquierda:
	popa
	mov esi,ecx
	mov dword[eax+esi*4], 0
	inc esi 
	mov dword[ebx+esi*4], ' '
	sub esi, 2
	call verificar_perdida_automovil
	mov dword[ebx+esi*4], '<'
	mov dword[eax+esi*4], 7
	add ecx, 2
	jmp for_automoviles

continuar_fila_medios_izquierda:
	popa
	mov esi,ecx
	mov dword[ebx+esi*4], ' '
	mov dword[eax+esi*4], 0
	inc esi 
	mov dword[ebx+esi*4], ' '
	mov dword[eax+esi*4], 0
	add esi, 13
	call verificar_perdida_automovil
	mov dword[ebx+esi*4], '<'
	mov dword[eax+esi*4], 8
	add ecx , 2
	jmp for_automoviles
	


mover_lentos_derecha:
	pusha
	call modulo_derecha_autos
	cmp edx,0 
	jz continuar_fila_lentos_derecha
	jmp realizar_movimiento_lentos_derecha	


realizar_movimiento_lentos_derecha:
	popa
	mov esi,ecx
	mov dword[eax+esi*4], 0
	sub esi, 2 
	mov dword[ebx+esi*4], ' '
	add esi, 3
	call verificar_perdida_automovil
	mov dword[ebx+esi*4], '>'
	mov dword[eax+esi*4], 12
	add ecx, 3
	jmp for_automoviles

continuar_fila_lentos_derecha:
	popa
	mov esi,ecx
	mov dword[ebx+esi*4], ' '
	mov dword[eax+esi*4], 0
	dec esi 
	mov dword[ebx+esi*4], ' '
	dec esi
	mov dword[ebx+esi*4], ' ' 
	sub esi, 12
	call verificar_perdida_automovil
	mov dword[ebx+esi*4], '>'
	mov dword[eax+esi*4], 13
	add ecx , 3
	jmp for_automoviles

verificar_abajo_izquierda:
	  mov eax,tablero
	  mov edi,dword[eax+ebx*4]
      call verificar_perdida_jugador
      mov dword[eax+ebx*4],'o'
      push ebx
	  push edi 
	  jmp mover_automoviles

verificar_abajo_derecha:
      mov edi,dword[eax+ebx*4]
      inc ebx 
	  mov eax,tablero
      call verificar_perdida_jugador
      mov dword[eax+ebx*4],'o'
      push ebx
	  push edi 
	  jmp mover_automoviles


verificar_arriba_izquierda:
	  mov eax,tablero
	  mov edi,dword[eax+ebx*4]
      call verificar_perdida_jugador
      mov dword[eax+ebx*4],'o'
      push ebx
	  push edi 
	  jmp mover_automoviles

verificar_arriba_derecha:
      mov edi,dword[eax+ebx*4]
      inc ebx 
	  mov eax,tablero
      call verificar_perdida_jugador
      mov dword[eax+ebx*4],'o'
      push ebx
	  push edi 
	  jmp mover_automoviles
	  		
mover_derecha:
      pop edi
      pop ebx
      call modulo_derecha
      mov edx,ebx
      mov eax,tablero
      mov dword[eax+ebx*4],edi
      inc ebx
      mov eax,tablero
      mov edi,dword[eax+ebx*4]
      call verificar_perdida_jugador
      mov dword[eax+ebx*4],'o'
      push ebx
      push edi 
      jmp mover_automoviles
      
mover_abajo:
	  pop edi
      pop ebx
      call verificar_abajo
      mov eax,tablero
      mov dword[eax+ebx*4],edi
      mov ecx,columnas
      add ebx,ecx
      mov esi, tablero_log 
	  dec ebx  
	  cmp dword[esi+ebx*4],"1"
	  jz verificar_abajo_izquierda
	  inc ebx
	  cmp dword[esi+ebx*4],"3"
	  jz verificar_abajo_derecha
      mov eax,tablero
      mov edi,dword[eax+ebx*4]
      call verificar_perdida_jugador
      mov dword[eax+ebx*4],'o'
      push ebx
	  push edi 
	  jmp mover_automoviles
	  
mover_arriba:
	  pop edi
      pop ebx
      call verificar_arriba
      mov eax,tablero 
      mov dword[eax+ebx*4],edi
      mov ecx,columnas
	  sub ebx,ecx
	  cmp dword[eax+ebx*4],'|'
	  jz hay_pared
	  mov esi, tablero_log 
	  dec ebx  
	  cmp dword[esi+ebx*4],"1"
	  jz verificar_arriba_izquierda
	  inc ebx
	  cmp dword[esi+ebx*4],"3"
	  jz verificar_arriba_derecha
	  mov eax,tablero
	  mov edi,dword[eax+ebx*4]
      call verificar_perdida_jugador
      call verificar_gane
      mov dword[eax+ebx*4],'o'
      push ebx
	  push edi 
	  jmp mover_automoviles


mover_izquierda:
      pop edi
      pop ebx
      call modulo_izquierda
      mov eax,tablero
      mov dword[eax+ebx*4],edi
	  dec ebx
	  mov eax, tablero 
	  mov edi,dword[eax+ebx*4]
	  call verificar_perdida_jugador
      mov dword[eax+ebx*4],'o'
      push ebx
      push edi 
      jmp mover_automoviles
      
      
hay_pared:
	mov ecx,columnas
	add ebx,ecx
	mov edi,'_'
	mov dword[eax+ebx*4],'o'
	jmp push_print
      
modulo_izquierda_autos:         ; calcs eax mod ebx, returns eax
    xor edx,edx
    mov eax,ecx
    dec eax
    sub eax, 14
    mov ebx, 15
	div ebx
	mov eax,edx
	ret

modulo_derecha_autos:         ; calcs eax mod ebx, returns eax
    xor edx,edx
    mov eax,ecx
    inc eax
    mov ebx, 15
	div ebx
	mov eax,edx
	ret
      
 modulo_izquierda:         ; calcs eax mod ebx, returns eax
    xor edx,edx
    mov eax,ebx
    dec eax
    sub eax, 14
    mov ecx, 15
	div ecx
	mov eax,edx
    cmp edx, 0
    jz push_print
    ret 
    
 modulo_derecha:         ; calcs eax mod ebx, returns eax
    xor edx,edx
    mov eax,ebx
    inc eax
    mov ecx, 15
	div ecx
	mov eax,edx
    cmp edx, 0
    jz push_print
    ret 

verificar_arriba:
	mov ecx,columnas
	mov eax,ebx
	sub eax,ecx
	cmp eax, 0 
	jl push_print
	ret

verificar_abajo:
	mov ecx,columnas
	mov eax,ebx
    add eax,ecx
	cmp eax, 194
	jg push_print
	ret


es_par:         ; calcs eax mod ebx, returns eax
    xor edx,edx
    mov edi, 2
	div edi
	mov eax,edx
    ret 

push_print:
	push ebx
	push edi 
	jmp print


opcion_no_valida_inicial:
      mov ecx,men_opcion_no_valida
      mov edx,len_opcion_no_valida
      call display_text
	  jmp print

menu_inicial:
      mov ecx,mensaje_menu
      mov edx,len_mensaje_menu
      call display_text

	mov eax, 3
	mov ebx, 0
   	mov ecx, movimiento              
   	mov edx, 2    
    int 80h
    mov ecx, [movimiento]
	cmp ecx, 0xa6E
    jz crear_matriz
	cmp ecx, 0xa66
    jz finalizar
    

verificar_gane:
	cmp dword[eax+ebx*4],'x'
	jz mensaje_gano
	ret

verificar_perdida_jugador:
	cmp dword[eax+ebx*4],'<'
	jz mensaje_perdio
	cmp dword[eax+ebx*4],'>'
	jz mensaje_perdio
	cmp dword[eax+ebx*4],'~'
	jz mensaje_perdio
	ret

verificar_perdida_automovil:
	cmp dword[ebx+esi*4],'o'
	jz mensaje_perdio
	ret

mensaje_perdio:
	  mov eax, 4                          ; Specify sys_write call
	  mov ebx, 1                          ; Specify File Descriptor 1: Stdout
	  mov ecx, ClearTerm                  ; Pass offset of terminal control string
	  mov edx, CLEARLEN                   ; Pass the length of terminal control string
	  int 80h
	  mov ecx,perdio
      mov edx,len_perdio
      call display_text
      mov ecx,perdio1
      mov edx,len_perdio1
      call display_text
      mov ecx,perdio2
      mov edx,len_perdio2
      call display_text
      mov ecx,perdio3
      mov edx,len_perdio3
      call display_text
      call print_endLine
      jmp menu_inicial

mensaje_gano:
      mov eax, 4                          ; Specify sys_write call
	  mov ebx, 1                          ; Specify File Descriptor 1: Stdout
	  mov ecx, ClearTerm                  ; Pass offset of terminal control string
	  mov edx, CLEARLEN                   ; Pass the length of terminal control string
	  int 80h
	  mov ecx,gano
      mov edx,len_gano
      call display_text
      mov ecx,gano1
      mov edx,len_gano1
      call display_text
	  mov ecx,gano2
      mov edx,len_gano2
      call display_text
      mov ecx,gano3
      mov edx,len_gano3
      call display_text
      mov ecx,gano4
      mov edx,len_gano4
      call display_text
      mov ecx,gano5
      mov edx,len_gano5
      call display_text
      mov ecx,gano6
      mov edx,len_gano6
      call display_text
      jmp menu_inicial


finalizar:
    mov ebx,0
    mov eax,1
    int 0x80
      
      
