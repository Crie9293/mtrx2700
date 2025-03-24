# Project Information
### Group Members
* Callum Riethmuller
* Daniel Maynard
* Nicholas Tika
* Qianhui Cao
### Roles

### Reponsibilities


# Code Information & Instructions
## Excercise 1
### 1.a
This code functions by converting a predefined string to either uppercase or lowercase determined by a value stored in R2.
```
.data
ascii_string: .asciz "Hello!"
.text
main:
    LDR  R1, =ascii_string   @ R1 points to the string
    MOV  R2, #0              @ Conversion mode: 0 = convert to lowercase; non-0 = convert to uppercase

```
Once the string and the conversion mode is determined, the code loops through each letter in the string, detects if its lowercase and uppercase then changes the value accordingly before ending.

### 1.b
The goal of this code is to check if a given word is a palindrome. To do this, it is initially assumed that word *is* a palindrome, before iterating both forward and backwards through the word and checking if the letters match. If not, the word is not a palindrome. 
```
check_palindrome:
    CMP R4, R2
    BCS done			@check if iterations cross

    LDRB R5, [R4]		
    LDRB R6, [R2]
    CMP R5, R6			@check if start and back of word is same
    BNE not_palindrome

    ADD R4, R4, #1		
    SUB R2, R2, #1		@iterate forwards and back
    B check_palindrome
```
Example input and output,
Input: racecar
Output: 1 (Palindrome)

Input: hello
Output: 0 (Not a Palindrome)

### 1.c
This code implements a caeser cypher on the ascii string stored in R1. The code then completes a forwards or backwards cypher by the specified amount by loading a positive or negative number into R2 respectively.
For example
```
.data
ascii_string: .asciz "Hi"

.text
main:
    LDR R1,=ascii_string
    MOV R2,#3
```
The above code with cypher 'Hi" to 'Kl'.

It accomplishes this by iterating through each character and adding the cypher value until the end of the word is reached. However if the cypher reaches too far it must wrap around using the following code:
```
BranchFwd:
	SUB R3, R3, #26	@go to start of alphabet
	B Iterate

BranchBkwd:
	ADD R3, R3, #26	@go to end of alphabet
	B Iterate
```
The new cyphered ascii string is stored in R3















