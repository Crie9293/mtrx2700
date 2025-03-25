# Project Information
### Group Members
* Callum Riethmuller
* Daniel Maynard
* Nicholas Tika
* Qianhui Cao
### Roles
* Exercise 1A: Everyone
* Exercise 1B: Everyone
* Exercise 1C: Callum & Daniel
* Exercise 2A: Qianhui & Daniel
* Exercise 2B: Qianhui & Callum
* Exercise 2C: Qianhui & Callum
* Exercise 2D: Nicholas
* Exercise 3A: Nicholas
* Exercise 3B: Nicholas
* Exercise 3C: Daniel
* Exercise 3D: Nicholas
* Exercise 3E: Nicholas & Daniel
* Exercise 4A: Callum & Qianhui
* Exercise 4B: Callum
* Exercise 4C: Callum
* Exercise 5: Callum, Nicholas & Daniel
* Documentation: Everyone
* Minutes: Qianhui and Daniel
  
### Reponsibilities
We assigned individual questions to either one or two group members. They would complete them generally alone and then compare solutions as well as explain their code to the rest of the group. For the more complicated questions towards the end such as 5 and for documentation we completed them together at PNR.

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
```
LDR R4, =0b10101010 @ load a pattern for the set of LEDs (every second one is on)
```
The code shown above is the bitmasking used to light up the LED with a given pattern. We then store this binary value in R4 into the bits of the LED located in the GPIOE as shown below
```
LDR R0, =GPIOE  @ load the address of the GPIOE register into R0
STRB R4, [R0, #ODR + 1]   @ store the LED pattern byte to the second byte of the ODR (bits 8-15)
```

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
Modifying 2b, we get another function that will decreases the amount of LED lighting up each time the button is pressed (when all LED is on). We store the direction of the LED lighting up using one of the registers available.
```
 @ update counter base on directioin
 CMP R8, #1
 BEQ increment_mode
 B decrement_mode
```
Increment mode and Decreament mode for decreasing and increasing the LED number:
```
increment_mode:
 ADD R9, #1
 CMP R9, #8
 BLS update_leds
 MOV R8, #0 @ change to decrease
 STR R8, [R7] @ store new direction
 B update_leds

decrement_mode:
 SUBS R9, #1
 BHI update_leds
 MOV R8, #1 @ change to increase
 STR R8, [R7]
 MOV R9, #1 @ reset counter
 LDR R6, =0x00000100 @ reset LED pattern
 STR R6, [R5]
 B program_loop
```

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
```
check_button_debounced:
    PUSH {R1-R4, LR}        	@ Save registers

    @ Check if button is pressed
    LDR R1, [R7, #IDR]      	@ Read input data register
    TST R1, #1              	@ Test bit 0 (USER button)
    BNE button_not_pressed  	@ If not pressed, branch

    LDR R4, =DEBOUNCE_DELAY		@ Add bounce delay

debounce_loop:
    SUBS R4, R4, #1         	@ Decrement counter
    BNE debounce_loop       	@ Continue loop if not zero

    @ Check if button is still pressed after delay
    LDR R1, [R7, #IDR]      	@ Read input data register again
    TST R1, #1              	@ Test bit 0 (USER button)
    BNE button_not_pressed  	@ If not pressed anymore, branch

    @ Button is still pressed - wait for release
wait_for_release:
    LDR R1, [R7, #IDR]			@ Read input data register
    TST R1, #1
    BEQ wait_for_release    	@ If still pressed, keep waiting

    @ Add a small delay after release
    LDR R4, =DEBOUNCE_DELAY

release_debounce_loop:
    SUBS R4, R4, #1
    BNE release_debounce_loop

    @ Button passed debounce check
    MOV R0, #1              	@ Return 1 (button pressed)
    B button_check_exit

button_not_pressed:
    MOV R0, #0              	@ Return 0 (button not pressed)

button_check_exit:
    POP {R1-R4, LR}         	@ Restore registers
    BX LR                   	@ Return
```
Using this function will ensure that the button has been released before starting other functions.

#### LEDs
```
STRB R5, [R6, #ODR +1]  		@ Show vowel count on LEDs
STRB R3, [R6, #ODR +1]  		@ Show consonant count on LEDs
```
Here, we have #ODR + 1 because the bit location for the LEDs are located on bits 8-15 therefore we need to add the offset.





## Exercise 3
### 3.a
In this exercise we can seperate our code into two modules:
* Checking the status of the button
* Transmitting the string

#### Checking the status of the button
The program checks whether the button is being pressed. If not, it cycles checking again and again, until it detects that it is being pressed. If it detects it is pressed it reads the button state again until it detects the button has been released. It then returns to the main function so the string can be transmitted.
```
check_button:
    LDR R0, =GPIOA			@ Load GPIOA address into R0 (button bit)
poll_press:
    LDR R3, [R0, #GPIO_IDR]   		@ Read button state (0 = not pressed, 1 = pressed)
    TST R3, #1               		@ Check if PA0 is pressed (bit if button)
    BEQ poll_press            		@ Keep polling if not pressed 

poll_release:
    LDR R3, [R0, #GPIO_IDR]   		@ Read button state again
    TST R3, #1                		@ Check if PA0 is still pressed
    BNE poll_release          		@ Wait until button is released

    BX LR				@ Go back to the main flow (load_message)
```

#### Transmitting the string
The program copies the memory address of the string we want to transmit into register R1. It then loads each byte (character) into the UART transmit one-by-one with a slight delay to keep the process stable checking each time that the transmit buffer is empty (the character has been successfully transmitted) before it sends the next one. Once it detects the null terminator in the string (signifying the end), it copies the memory address of the terminating character into R1 and loads this byte/character into the UART transmit before returning to the main function and looping through the whole program again.
```
load_message:
	LDR R1, =message           	@ Load address of message
	transmit_loop:
		LDRB R5, [R1], #1	@ Loads the char into R5 and post increment R1 by 1
		CMP R5, #0		@ Check if it's end of string
		BEQ end_loop		@ Branch to end loop if null terminator detected
		B uart_loop		@ If not end of string, continue the transmission

end_loop:
	LDR R0, =terminating_char	@ Set R0 to the terminating char
	LDRB R5, [R0]			@ Get the byte of the terminating char
	poll_end:
		LDR R0, =UART			@ Get address of UART 
		LDR R3, [R0, USART_ISR]		@ Read the UART status register
		ANDS R3, #1 << UART_TXE		@ Check if TX buffer is empty (ready to transmit)
		BEQ poll_end			@ If not empty, keep on checking

		STRB R5, [R0, USART_TDR]	@ Transmit the terminating character 
		B main_flow			@ Restart the whole process (wait for button input)

uart_loop:
	LDR R0, =UART				@ Get address of UART

	poll_uart:				
		LDR R3, [R0, USART_ISR]		@ Read the UART status register

		ANDS R3, #1 << UART_TXE		@ Check if TX bufer is empy (ready to transmit)
		BEQ uart_loop			@ If not empty, keep on checking

		STRB R5, [R0, USART_TDR]	@ Transmit the current character
		BL delay_loop			@ Delay to make the transmission stable
		B transmit_loop			@ Loop the transmission process

@ Basic delay function following the lecture
delay_loop:
	LDR R9, =0xfffff 			@ Arbitrary value (should be large enough)
delay_inner:
	SUBS R9, #1
	BGT delay_inner
	BX LR
```

### 3.b
For this task, we are typing a string for the UART to receive, unlike in 3a. We define a custom terminating character to make the UART stop reading once it reaches this character. We also define a buffer space.
Similar to the structure of the code above, we check if the UART is ready to receive data before load the data in to the UART. Afterwards, we store it into the buffer.
```
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
```
The microcontroller checks if the current string is the custom terminating character and if so, it branches onto another function to stop reading the string. 


### 3.c
This code involved uncommenting a line from the Week 3 UART example code to call a function defined in initialise.s to change the clock speed to six times faster than before (from 8MHz to 48MHz). 
```
@ step 2, now the clock is HSE, we are allowed to switch to PLL
	@ clock is set to External clock (external crystal) - 8MHz, can enable the PLL now
	LDR R1, [R0, #RCC_CFGR] @ load the original value from the enable register
	LDR R2, =1 << 20 | 1 << PLLSRC | 1 << 22 @ the last term is for the USB prescaler to be 1
	ORR R1, R2  @ set PLLSRC (use PLL) and PLLMUL to 0100 - bit 20 is 1 (set speed as 6x faster)
				@ see page 140 of the large manual for options
				@ NOTE: cannot go faster than 72MHz)
	STR R1, [R0, #RCC_CFGR] @ store the modified enable register values back to RCC
```

The same baud rate must be maintained for the computer to continue to be able to communicate with the microcontroller through the UART. We are over sampling by 16 so use the equation:
<img width="278" alt="Screenshot 2025-03-25 at 10 47 56 AM" src="https://github.com/user-attachments/assets/8e225650-711f-470f-af53-e7ecac45787b" />

Our desired baud rate is 115,200. Previously, this gave USARTDIV = 8,000,000 / 115,200 = 0x46, with the new clock speed we get USARTDIV = 48,000,000 / 115,200 = 0x1A1.
```
@ this is the baud rate
@MOV R1, #0x46 @ from our earlier calculations (for 8MHz), store this in register R1
MOV R1, #0x1A1 @ From calculation for clock at 48MHz
```


### 3.d
Here, we are basically just putting 3a and 3b alltogether. After reading the string and storing it in the buffer, it will retransmit back on the same UART until it reaches the terminating character. The first half of the code will be the same as 3b and the second half would be similar to 3a with some changes.
```
store_null:
    STRB R2, [R1, R8]                   @ Null-terminate the string
    B transmit_loop                     @ transmit the string in same UART

transmit_loop:
	LDRB R5, [R1], #1		@ Loads the char into R5 and post increment R1 by 1
	CMP R5, R2			@ Check if current char is same as the terminating char
	BEQ end_loop
	B uart_loop
```
After storing the terminating character in the buffer, we branch to the transmitting function where we not check if the current character is the same as the terminating character. This is a slight modification from part 3a where we want to append a terminating character at the end of the string. The rest of the code follows the same structure.



### 3.e
For this exercise, we use one microcontroller connected to one computer to transmit, through UART4, characters to another microcontroller. This second microcontroller connected to a second computer reads these incoming character from UART4 and transmits them to USART1 where we can display them on a terminal emulator demonstrating they are now on the second computer.

We split the code for 3e into two modules:
* Code for reading incoming characters
* Code for transmitting/retransmitting the characters on a different UART
  
#### Code for reading incoming characters
Here, we check UART4's status register, we continually loop until data is detected. Once detected, we save the byte (character) into register R2.
```
listen_loop:
    @ Check UART4 for incoming data
    LDR R0, =UART4  @ Load base address of UART4
    LDR R1, [R0, USART_ISR]  @ Load UART status register
	LDR R2, 1 << UART_RXNE
    TST R1, 1 << UART_RXNE @ Check if ready to read
    BEQ listen_loop  @ If no data, keep listening

    @ Read character from secondary UART
    LDRB R2, [R0, USART_RDR]  @ Read received character

    @ Prepare USART1 for transmission
    LDR R0, =USART1  @ Load base address of primary UART (PC connection)
```

#### Retransmitting the characters on a different UART
Here, we first check if USART1's transmit buffer is empty, continually looping until it is. Once it is, we store the character saved in register R2 to the memory address where it is transmitted back.
NOTE: We use essentially the same code to send the characters from the first microcontroller to the second just swapping out LDR R0, =USART1 to LDR RO, =UART4.
```
transmit_wait:
    @ Wait for transmit buffer to be empty
    LDR R0, =USART1 @ Load base address of USART1
    LDR R1, [R0, USART_ISR]
    TST R1, 1 << UART_TXE
    BEQ transmit_wait  @ Wait if transmit buffer not empty

    @ Transmit the character on USART1
    STRB R2, [R0, USART_TDR]

    @ Optional: Echo character back to secondary UART
    LDR R0, =UART4 @ Switch back to secondary UART
```

#### Hardware
In terms of hardware, we can receive data using PA1 as UART4's RX (receiving pin) and PA10 as USART1's RX. We can send data using PA9 as USART1's TX (transmission pin) and PA0 as UART4's TX. 
![IMG_4820](https://github.com/user-attachments/assets/a161d566-e302-401b-b166-59e229710f97)



## Exercise 4
### 4.a
This exercise makes use of the hardware timer in the STM controller to simulate a time delay. In order to accomplish this the following registers must be activated.
```
main: 
    MOV R1, #0x3E8   @ 1ms delay

    LDR R0, =RCC	@ load the base adress for the timer
    LDR R2, [R0, #APB1ENR]    @ load peripheral control clock register
    ORR R2, 1 << TIM2EN      @ enable tim2 flag
    STR R2, [R0, #APB1ENR]


    LDR R0, =TIM2
    MOV R2, #1000		@ AAR value set as 1000ms
    STR R2, [R0, #TIM_ARR]	@ store auto-reload value

    MOV R2, #0
    STR R2, [R0, #TIM_CNT]	@ reset and clear the counter

    MOV R2, #1
    STR R2, [R0, #TIM_CR1]	@start the timer
```
- **TIM2EN**: The bit that enables the TIM2 clock.
- **TIM_ARR**: The auto-reload register, which resets the timer count back to zero once it reaches this value.
- **TIM_CNT**: The count register, which contains the number of clock ticks that have passed.
- **TIM_CR1**: The timer control register, which ensures the timer is running.

After these are set up, a simple polling technique is used to create a delay.
```
delay:
    LDR R2, [R0, #TIM_CNT]
    CMP R2, R1	 		@ check if reached delay time
    BLT delay	 		@ if CNT < delay, loop

    MOV R2, #0                   @ stop timer
    STR R2, [R0, #TIM_CR1]       @ disable TIM2
```
It functions by constantly checking the the count has reached to preset delay value in R1, the timer is then stopped and the function passes when this happens.


### 4.b
This part implements the prescaler function, which allows for the timer speed to be changed and thus delay period to be increased/decreased.
```
    LDR R0, =TIM2
    MOV R2, #7999  @ set prescaler
    STR R2, [R0, #TIM_PSC]
```
Upon storing a value in the prescaler register, the following equation sets the new timer speed.


$$f_{timer} = \frac{f_{clock}}{\text{PSC} + 1}$$


Where:
- $$\( f_{timer} \)$$ is the timer's frequency after prescaling.
- $$\( f_{clock} \)$$ is the input clock frequency to the timer.
- $$\( \text{PSC} \)$$ is the value loaded into the prescaler register.

The hardware clock has a frequency of 8Mhz, assuming the delay is set to a value of 1000, (takes 1000 clock ticks to reach delay.) Setting the prescaler value to 7999 will produce a delay of 1s. 



$$f_{timer} = \frac{8,000,000}{7999 + 1} = \frac{8,000,000}{8000} = 1000 \, \text{Hz}$$


This means the timer counts at **1000 ticks per second**. For a delay of 1000 ticks:


$$\text{Delay} = \frac{\text{Clock ticks}}{f_{timer}} = \frac{1000}{1000} = 1 \, \text{second}$$

Using this equation to achieve a delay of 1 microsecond and 1 hour respectively, a prescaler of 7 and 28,799,999 must be used.

### 4.c
This exercise uses ARPE and ARR to make a highly accurate delay function entirely managed in hardware. TIM_ARR is already implemented, however when the ARPE bit equals 1, this makes it so when changing the ARR value, it only changes once it resets which creates safer code as it does not interrupt the current cycle. The bit is sotred in the 7th bit of the TIM_CR1 register thus is set using the following code.
```
    MOV R2, #(1 << 7) 
    STR R2, [R0, #TIM_CR1]	@ Enable ARPE bit
```






## Exercise 5
This final exercise essentially requires us to implement all of the previous modules. To do this, we have to connect the two microcontrollers so that they can communicate with each other. We do this by connecting the UART pins to each other (TX & RX) and both grounds should also be connected. 
![IMG_4820](https://github.com/user-attachments/assets/a161d566-e302-401b-b166-59e229710f97)


### Receiving Message
Using the USART1, we receive the message from the PC as we did in Exercise 3b. We then store this messsage in the register to be passed on to another function to check whether or not the message is a palindrome.

### Palindrome Detection
This segment uses the code from Exercise 1b. Using a register to store data of whether or not the message is a palindrome, we can then decide to encode this message in caesar cipher or not. If it is a palindrome, we pass the message to the caesar cipher function and if not, it goes directly to the transmitting function.

### Caesar Cipher
Using the code from Exercise 1c, we can encode the messages in caesar cipher with a defined value. This value can be changed. After iterating through all the characters and encoding them, it will then be passed on to the transmitting function.

### Transmitting Message
Here, the USART1 transmit the message to another microcontroller using the UART module. This is done like in Exercise 3a.


### Deciphering Message
Since the message was encoded before transmitting, we decipher it using the same caesar function as above but with the opposite signed value. Here is an example:
```
MOV R2, #-1	@ value of the caesar cypher for ENCODING
MOV R2, #1	@ value of the caesar cypher to DECIPHER
B caesar_cypher
```
Another thing to note is that since we are using the same caesar_cypher function as above to decipher to message, we need to set a 'mode' value in one of the registers to know that this is done for decicphering, not encoding. If not, it will be passed again onto the transmitting function. Once it has been deciphered, we pass it on to the LED function

### LED Vowel / Consonants
Unlike Exercise 2d, we now use our timer to switch between the vowel and consonant counts. Therefore, we are integrating our timer module in here as well.
```
vowel_LED:
	LDR R6, =GPIOE
	STRB R5, [R6, #ODR + 1]		@ Display vowel
    LDR R2, [R0, #TIM_CNT]
    CMP R2, R9	 			@ check if reached delay time
    BLT vowel_LED	 		@ if CNT < delay, loop
	
    //MOV R2, #0                   	@ stop timer
    //STR R2, [R0, #TIM_CR1]       	@ disable TIM2
    
consonant_LED:
	LDR R6, =GPIOE
	STRB R3, [R6, #ODR + 1]		@ Display consonant
	LDR R2, [R0, #TIM_CNT]
	CMP R2, R1			@ check if reached delay time
    	BLT consonant_LED
	B vowel_LED
```
Here, we put a delay function between storing R5 and R3 in the LED bits which are the vowel and consonant count respectively. The logic behind is that if the time count is not below the delay, it will keep on looping its own function. The delay period can be modified in the code shown below:
```
MOV R9, #500000   @ 1ms delay

    LDR R0, =RCC	@ load the base adress for the timer
    LDR R2, [R0, #APB1ENR]    @ load peripheral control clock register
	  ORR R2, 1 << TIM2EN      @ enable tim2 flag
    STR R2, [R0, #APB1ENR]

	LDR R0, =TIM2
    MOV R2, #7999  @ set prescaler
    STR R2, [R0, #TIM_PSC]

    LDR R0, =TIM2
    STR R1, [R0, #TIM_ARR]	@ store auto-reload value

    MOV R2, #0
    STR R2, [R0, #TIM_CNT]	@ reset and clear the counter

    MOV R2, #(1 << 7)
    STR R2, [R0, #TIM_CR1]	@ Enable ARPE bit

    MOV R2, #1
    STR R2, [R0, #TIM_CR1]	@start the timer
```
