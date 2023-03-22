; sumar.asm
;
; Author : Daniel Eduardo Caicedo Castillo

.def num_in = r16 ; Registro para almacenar el número en binario recibido
.def ctrl_in = r17 ; Registro para leer el estado de los pines de entrada
.def ctrl_out = r18 ; Registro para escribir en los pines de salida
.def pos_mem = r19 ; Registro para llevar la cuenta de la posición actual en memoria

.equ mem_start = 0x0100 ; Dirección de inicio de la partición de memoria
.equ mem_size = 16 ; Tamaño de la partición de memoria

main:
    ldi pos_mem, mem_start ; Inicializar el registro que lleva la cuenta de la posición en memoria

read_loop:
    call read_number ; Leer el número en binario del puerto D

    call store_number ; Guardar el número en una partición de memoria cuando se reciba una señal en el pin C1

    inc pos_mem ; Incrementar el registro que lleva la cuenta de la posición en memoria

    cpi pos_mem, mem_start + mem_size ; Comparar la posición actual en memoria con la dirección final de la partición de memoria
    brne read_loop ; Si aún hay espacio en la memoria, volver a leer un número en binario

end_loop:
    rjmp end_loop ; Esperar indefinidamente

read_number:
    ldi ctrl_in, 0xFF ; Cargar un valor en el registro para leer el estado de los pines de entrada
    in ctrl_in, PIND ; Leer el estado de los pines del puerto D

    mov num_in, ctrl_in ; Mover el valor leído al registro que almacenará el número en binario

    ret ; Retornar del subprograma

store_number:
    ldi ctrl_in, 0b00000010 ; Cargar un valor en el registro para leer el estado del pin C1
    in ctrl_in, PINC ; Leer el estado del pin C1

    cpi ctrl_in, 0b00000010 ; Comparar el estado del pin C1 con el valor esperado (activo bajo)
    brne store_number ; Si el pin C1 no está activo bajo, volver a leer el estado del pin C1

    ldi ctrl_out, 0xFF ; Configurar todos los pines del puerto C como salidas
    out DDRC, ctrl_out ; Configurar el puerto C como salidas

    st num_in, pos_mem ; Guardar el número en binario en la posición actual en memoria

    clr ctrl_out ; Limpiar el registro que escribirá en los pines de salida
    out PORTC, ctrl_out ; Desactivar todos los pines del puerto C

    ret ; Retornar del subprograma
