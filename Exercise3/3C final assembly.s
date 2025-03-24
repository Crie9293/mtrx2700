


.syntax unified
.thumb

#include "initialise.s"

.global main

.data
.align
terminating_char: .ascii "$"            @ Custom terminating character

buffer: .space 129			@ Initialise a buffer space to store string
counter: .byte 129			@ Set a maximum buffer size

.text

main:
    @ Initialize peripherals and UART (taken from lectures)
    BL initialise_power
    BL enable_peripheral_clocks
    BL enable_uart
    BL change_clock_speed

    LDR R2, =terminating_char		@ Get address of terminating char
    LDRB R2, [R2]			@ Set R2 to the terminating_char which in this case is $ (dereferencing)
    LDR R1, =buffer			@ Load buffer into R1 to store the string typed in the UART
    LDR R7, =counter			@ Load counter into R7
    LDRB R7, [R7]			@ Load buffer size (129) into R7

    MOV R8, #0x00 			@ Initialise R8 for index/counter

receive_char:
    LDR R0, =UART			@ Load UART address
    LDR R4, [R0, USART_ISR]		@ Read the UART status register

    @ Error checking
    TST R4, 1 << UART_ORE | 1 << UART_FE
    BNE clear_error

    TST R4, 1 << UART_RXNE		@ Check if UART is ready to receive data
    BEQ receive_char

    LDRB R4, [R0, USART_RDR]		@ Read the received character/byte from the UART

    CMP R4, R2				@ Check if current char is same as the terminating char
    BEQ store_null

    @ Store character and increment counter
    STRB R4, [R1, R8]			@ Store the character in the buffer at index R8
    ADD R8, #1				@ Increment the index/count of R8

    @ Check buffer limit
    CMP R8, R7
    BGE store_null            		@ If buffer is at max capacity, terminate

    B receive_char            		@ Continue the receiving loop

store_null:
    STRB R2, [R1, R8]        		@ Null-terminate the string
    B finish                    	@ Stop the program

@ Error handling taken from the lectures
clear_error:
    LDR R4, [R0, USART_ICR]
    ORR R4, 1 << UART_ORECF | 1 << UART_FECF
    STR R4, [R0, USART_ICR]
    B receive_char

finish:
	B finish				@ Infinite loop to stop the program
