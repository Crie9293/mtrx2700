.syntax unified
.thumb

.global main


.data
@ define variables
    string1: .asciz "This is a string"

.text
@ define code



@ this is the entry function called from the startup file
@ it replaces the c main function that was removed when we made
@ this project
main:

	LDR R1, =string1
    MOV R2, #1 @ 1 means all uppercase, 0 means all lower case
    MOV R3, R1 @ Save the original value of R1 in R3
    BL upper_or_lower @ Go to the case changing function, saving current spot


@ Case Changing Function
upper_or_lower:
    LDRB R4, [R1] @ Load a byte (one character) into R4
    CMP R4, #0 @ Check if we are at the end of the string (null terminator character is 0 in ASCII)
    BEQ finished @ If null terminator, exit function


    CMP R2, #1 @ Check if converting characters uppercase
    BEQ all_upper @ If yes, do so
    BNE all_lower @ Otherwise assume converting characters to lowercase

 all_upper:
     CMP R4, #97 @ 97 represents 'a' in ASCII
     BLT next @ If our character is less than 'a' (not a lower case letter) we move on
     CMP R4, #122 @ 122 represents 'z' in ASCII
     BGT next @ If our character is greater than 'z' (not a lower case letter) we move on
     SUB R4, #32 @ Subtracting by 32 changes a lower case number to its equivalent upper case
     STRB R4, [R1] @ We save our change of the character to the string
     B next @ Move to next without saving current spot

 all_lower:
     CMP R4, #65 @ 65 represents 'A' in ASCII
     BLT next @ If our character is less than 'A' (not an upper case letter) we move on
     CMP R4, #90 @ 90 represents 'Z' in ASCII
     BGT next @ If our character is greater than 'Z' (not an upper case letter) we move on
     ADD R4, #32 @ Adding 32 changes an upper case number to its equivalent lower case
     STRB R4, [R1] @ We save our change of the character to the string
     B next @ Move to next without saving current spot

 next:
     ADD R1, #1 @ Move one character along in the string
     B upper_or_lower @ Move back to upper_or_lower without saving current spot

 finished:
     BX LR @ Return to main as the case changing function is complete








