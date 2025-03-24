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
This code functinos by converting a predefined string to either uppercase or lowercase determined by a value stored in R2.
```
.data
ascii_string: .asciz "Hello!"
.text
main:
    LDR  R1, =ascii_string   @ R1 points to the string
    MOV  R2, #0              @ Conversion mode: 0 = convert to lowercase; non-0 = convert to uppercase

```
Once the string and the conversion mode is determined, the code loops through each letter in the string, detects if its lowercase and uppercase then changes the value accordingly before ending.


