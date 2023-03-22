; sumar.asm
;
; Author : Daniel Eduardo Caicedo Castillo

.def num_in = r16 ; Registro para almacenar el n�mero en binario recibido
.def ctrl_in = r17 ; Registro para leer el estado de los pines de entrada
.def ctrl_out = r18 ; Registro para escribir en los pines de salida
.def pos_mem = r19 ; Registro para llevar la cuenta de la posici�n actual en memoria

.equ mem_start = 0x0100 ; Direcci�n de inicio de la partici�n de memoria
.equ mem_size = 16 ; Tama�o de la partici�n de memoria

main:
    ldi pos_mem, mem_start ; Inicializar el registro que lleva la cuenta de la posici�n en memoria

read_loop:
    call read_number ; Leer el n�mero en binario del puerto D

    call store_number ; Guardar el n�mero en una partici�n de memoria cuando se reciba una se�al en el pin C1

    inc pos_mem ; Incrementar el registro que lleva la cuenta de la posici�n en memoria

    cpi pos_mem, mem_start + mem_size ; Comparar la posici�n actual en memoria con la direcci�n final de la partici�n de memoria
    brne read_loop ; Si a�n hay espacio en la memoria, volver a leer un n�mero en binario

end_loop:
    rjmp end_loop ; Esperar indefinidamente

read_number:
    ldi ctrl_in, 0xFF ; Cargar un valor en el registro para leer el estado de los pines de entrada
    in ctrl_in, PIND ; Leer el estado de los pines del puerto D

    mov num_in, ctrl_in ; Mover el valor le�do al registro que almacenar� el n�mero en binario

    ret ; Retornar del subprograma

store_number:
    ldi ctrl_in, 0b00000010 ; Cargar un valor en el registro para leer el estado del pin C1
    in ctrl_in, PINC ; Leer el estado del pin C1

    cpi ctrl_in, 0b00000010 ; Comparar el estado del pin C1 con el valor esperado (activo bajo)
    brne store_number ; Si el pin C1 no est� activo bajo, volver a leer el estado del pin C1

    ldi ctrl_out, 0xFF ; Configurar todos los pines del puerto C como salidas
    out DDRC, ctrl_out ; Configurar el puerto C como salidas

    st num_in, pos_mem ; Guardar el n�mero en binario en la posici�n actual en memoria

    clr ctrl_out ; Limpiar el registro que escribir� en los pines de salida
    out PORTC, ctrl_out ; Desactivar todos los pines del puerto C

    ret ; Retornar del subprograma
