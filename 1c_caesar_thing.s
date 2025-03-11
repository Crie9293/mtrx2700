.syntax unified
.thumb

.global main


.data
@ define variables
    string1: .asciz "inf"

.text
@ define code



@ this is the entry function called from the startup file
@ it replaces the c main function that was removed when we made
@ this project
main:

	LDR R1, =string1
    MOV R2, #1 @ Amount it will shift
    BL iteration @ We move to start iterating through the string and changing
                 @ the characters.


iteration:
    LDRB R3, [R1] @ Put one character (one byte) from string into R3
    CMP R3, #0
    BEQ finished
    ADD R3, R2 @ Do the caesar thing
    STRB R3, [R1] @ Update value in the actual string
    ADD R1, #1 @ Move onto the next character of the string
    B iteration


 finished:
     BX LR @ Return to main as the case changing function is complete
