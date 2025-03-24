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
Once the string (stored in R1) and the conversion mode (stored R2) is determined, the code loops through each letter in the string, detects if its lowercase and uppercase then changes the value accordingly before ending.
```
@ Mode non-zero: convert lowercase to uppercase
CMP  R4, #'a'
BLT  store_char
CMP  R4, #'z'
BGT  store_char
SUB  R4, R4, #32       @ Convert to uppercase
```
```
@ Mode zero: convert uppercase to lowercase
CMP  R4, #'A'
BLT  store_char
CMP  R4, #'Z'
BGT  store_char
ADD  R4, R4, #32
```
The value of the upper and lower case letters in an ascii table have a difference of 32 which is why we subtract / add the registers by 32, depending on the mode.

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
To simultaneously iterate forward and backward, we define 2 pointers using registers R4 and R2 and compare them at each iteration.

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

## Exercise 2
### 2.a
For this exercise, we simply perform a bitmask operation on the GPIO registers of the LED.



### 2.b
To add the amount of LEDs that lit up when the button is pressed, we first need to initialise the correct GPIOs.
```
BL enable_peripheral_clocks
BL initialise_discovery_board
```
Here, we are simply enabling the GPIOs for the discovery board user button and LED (GPIOA & GPIOE). Only then can we program the button to light up the LED.
We do this by checking if the button is pressed or not (add debounce). If so, we light up a new LED each time the button is pressed. 
```
LSL R6, #1               @ Shift left (no effect when R6=0 initially)
ORR R6, #0x00000100      @ Add the new rightmost LED (PE8)
STR R6, [R5]             @ Store updated pattern
```
To light up the neighboring LED, we perform a left shift operation and a bitmask or so that the LED stays on even when the bit is shifted.
Keep on looping until it reaches the maximum amount of LEDs (8) then stop.

### 2.c




### 2.d
In this exercise, we can seperate our code into 3 modules:
* Checking Letters
* Button
* LEDs

#### Checking Letters
We define an ascii string which has been stored in register R1. We then use 2 registers to keep track of the vowel and consonant count. 
To check for vowels/consonants, we simply iterate through the string and compare if the current letter is equal to a vowel/consonant. If so, we increase the count and loop back until the string has ended.
NOTE THAT THE COUNT IS IN BINARY!

#### Button
The button acts as a mode switch. Initially, the mode is set to show vowels so if we press the button, the mode will change to show consonants.

#### LEDs
```
STRB R5, [R6, #ODR +1]  		@ Show vowel count on LEDs
STRB R3, [R6, #ODR +1]  		@ Show consonant count on LEDs
```
Here, we have #ODR + 1 because the bit location for the LEDs are located on bits 8-15 therefore we need to add the offset.





## Exercise 3
### 3.a



### 3.b



### 3.c



### 3.d




### 3.e




## Exercise 4
### 4.a




### 4.b





### 4.c



## Exercise 5
