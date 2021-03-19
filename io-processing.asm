TITLE Project 6    (Proj6_BYBEESH.asm)

; Author: Shauna Bybee
; Last Modified: 12/1/2020
; OSU email address: bybeesh@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 6               Due Date: 12/6/2020
; Description:  Gets integers from the user, converts the string input to numeric data, stores the values of the integers,
;				then displays the integers, along with the sum and the average.

INCLUDE Irvine32.inc


; --------------------------------------------------------------------------------------
; Name: mGetString
; 
; Prompts the user for input, then gets a string from the user.
; 
; Preconditions: None
;
; Postconditions: None
;
; Receives: 
;		promptAddr: Address of text prompt to display to user
;		stringAddr:	(output) Address of an array for string entered by user
;		stringSize: Size of the array that will contain string entered by user
;		charCount:  (output) Number of characters entered by user
; 
; Returns:
;		stringAddr:	String entered by user
;		charCount:	Number of characters entered by user (up to stringSize). 
;				    (Note, if user enters a number of characters > stringSize, extra
;				    characters will be ignored.)
; --------------------------------------------------------------------------------------

mGetString MACRO promptAddr, stringAddr, stringSize, charCount
	PUSH	EAX
	PUSH	ECX
	PUSH	EDX
	
	MOV		EDX, promptAddr
	CALL	WriteString

	MOV		EDX, stringAddr
	MOV		ECX, stringSize
	CALL	ReadString

	MOV		charCount, EAX

	POP		EDX
	POP		ECX
	POP		EAX
ENDM


; --------------------------------------------------------------------------------------
; Name: mDisplayString
; 
; Prints a string.
; 
; Preconditions: String to be written is null-terminated
;
; Postconditions: None
;
; Receives: 
;		stringAddr:	Address of an array for string entered by user
; 
; Returns: None
; --------------------------------------------------------------------------------------

mDisplayString MACRO stringAddr
	PUSH	EDX
	MOV		EDX, stringAddr
	CALL	WriteString
	POP		EDX
ENDM


; --------------------------------------------------------------------------------------
; Program Constants
; --------------------------------------------------------------------------------------

NUMINTEGERS = 10			; Number of integers to get from the user


.data
	textTitle		BYTE	"A Program to Read, Store, and Write Integers by Shauna Bybee",0
	textIntro1		BYTE	"Enter ",0
	textIntro2		BYTE	" signed decimal integers.",13,10
					BYTE	"Each number must be able to fit in a 32-bit register.",13,10
					BYTE	"The program will then print the list of integers you entered, ",13,10
					BYTE	"along with the sum and the average of the integers (rounded down).",0

	textPrompt		BYTE	"Enter a signed integer: ",0
	textPrintArray	BYTE	"The integers you entered are: ",0
	textPrintSum	BYTE	"The sum of the integers is: ",0
	textPrintAvg	BYTE	"The average of the integers (rounded down) is: ",0
	textSeparator	BYTE	", ",0
	textGoodbye		BYTE	"Thank you for using this program. Goodbye!",0
	invalidCount	BYTE	"You entered too many characters.",13,10,
							"Please enter a value in the range: [-2147483648 to 2147483647].",0
	invalidSize		BYTE	"The input you entered will not fit in a 32-bit integer.",13,10,
							"Please enter a value in the range: [-2147483648 to 2147483647].",0
	invalidValue	BYTE	"The input you entered is not a valid integer. Please try again.",0
	intArray		SDWORD	NUMINTEGERS DUP(?)
	numValues		DWORD	0
	sum				SDWORD	0
	average			SDWORD	0
	userString		BYTE	16 DUP(?)
	userValue		SDWORD	?


.code
main PROC

	; --------------------------------------------------------------------------------------
	; Print program introduction
	; --------------------------------------------------------------------------------------

	PUSH	OFFSET textTitle
	PUSH	OFFSET textIntro1
	PUSH	OFFSET textIntro2
	PUSH	NUMINTEGERS
	CALL	introduction


	; --------------------------------------------------------------------------------------
	; Loop to get integers from the user
	; --------------------------------------------------------------------------------------

	MOV		ECX, NUMINTEGERS
	MOV		EDI, OFFSET intArray
	CLD

_getInteger:
	PUSH	OFFSET textPrompt
	PUSH	OFFSET invalidCount
	PUSH	OFFSET invalidSize
	PUSH	OFFSET invalidValue
	PUSH	SIZEOF userString
	PUSH	OFFSET userString
	PUSH	OFFSET userValue
	CALL	ReadVal

	MOV		EAX, userValue					; Store input in intArray
	STOSD
	INC		numValues
	LOOP	_getInteger


	; --------------------------------------------------------------------------------------
	; Print the array of integers
	; --------------------------------------------------------------------------------------

	CALL	Crlf
	PUSH	OFFSET textPrintArray
	PUSH	OFFSET textSeparator
	PUSH	numValues
	PUSH	OFFSET intArray
	CALL	PrintArray
	CALL	Crlf
	

	; --------------------------------------------------------------------------------------
	; Calculate and print the sum
	; --------------------------------------------------------------------------------------

	PUSH	OFFSET sum
	PUSH	numValues
	PUSH	OFFSET intArray
	CALL	calculateSum

	MOV		EDX, OFFSET textPrintSum
	CALL	WriteString
	PUSH	sum
	CALL	WriteVal
	CALL	Crlf


	; --------------------------------------------------------------------------------------
	; Calculate and print the average
	; --------------------------------------------------------------------------------------

	MOV		EAX, sum					; Calculate average
	CDQ
	IDIV	numValues
	MOV		average, EAX

	MOV		EDX, OFFSET textPrintAvg	; Print average
	CALL	WriteString
	PUSH	average
	CALL	WriteVal
	CALL	Crlf


	; --------------------------------------------------------------------------------------
	; Print a goodbye message
	; --------------------------------------------------------------------------------------

	CALL	Crlf
	MOV		EDX, OFFSET textGoodbye
	CALL	WriteString
	CALL	Crlf
	CALL	Crlf


  Invoke ExitProcess,0  ; exit to operating system

main ENDP


; --------------------------------------------------------------------------------------
; Name: introduction
; 
; Displays introductory text to the user.
; 
; Preconditions: None
;
; Postconditions: None
;
; Receives: 
;		[EBP + 20]	String containing program title text
;		[EBP + 16]	String containing textIntro1
;		[EBP + 12]	String containing textIntro2
;		[EBP + 8]	NUMINTEGERS - the number of integers that will be collected
; 
; Returns: None
; --------------------------------------------------------------------------------------

introduction PROC
	PUSH	EBP
	MOV		EBP, ESP
	PUSH	EAX
	PUSH	EDX

	; --------------------------------------------------------------------------------------
	; Print Program Title
	; --------------------------------------------------------------------------------------

	MOV		EDX, [EBP + 20]
	CALL	WriteString
	CALL	Crlf
	CALL	Crlf

	; --------------------------------------------------------------------------------------
	; Print Program Intro and Explanation, with embedded constant values
	; --------------------------------------------------------------------------------------

	MOV		EDX, [EBP + 16]			; Intro 1
	CALL	WriteString
	MOV		EAX, [EBP + 8]			; NUMINTEGERS
	PUSH	EAX
	CALL	WriteVal
	MOV		EDX, [EBP + 12]			; Intro 2
	CALL	WriteString
	CALL	Crlf
	CALL	Crlf

	POP		EDX
	POP		EAX
	POP		EBP
	RET	16
introduction ENDP


; --------------------------------------------------------------------------------------
; Name: ReadVal
; 
; Gets input from the user and then converts the user's input string into a 
; signed 32-bit integer value. If input is a valid signed integer in the range
; [-2147483648 to 2147483647], procedure will set isValid = 1. Otherwise, isValid = 0.
; 
; Preconditions: None
;
; Postconditions: None
;
; Receives:
;		[EBP + 32]	Prompt: Address of text prompt to display to user
;		[EBP + 28]	Invalid Count: Address of message for too many characters entered
;		[EBP + 24]	Invalid Size: Address of message for invalid (out of range) input size
;		[EBP + 20]	Invalid Value: Address of message for invalid (non-integer) input
;		[EBP + 16]	String Size: Size of the array that will contain string entered by user
;		[EBP + 12]	(output) User String: Address of an array for string entered by user
;		[EBP + 8]	(output) User Value: Address of signed integer value entered by user
; 
; Returns:
;		[EBP + 16]	String entered by user
;		[EBP + 12]	Signed integer value entered by user
;
; --------------------------------------------------------------------------------------

ReadVal PROC
	LOCAL numChars: DWORD, val: SDWORD, isNegative: DWORD, multiplier: DWORD, \
		  countErrorMsg: DWORD, sizeErrorMsg: DWORD, valueErrorMsg: DWORD
	PUSHAD

	; --------------------------------------------------------------------------------------
	; Initialize local variables
	; --------------------------------------------------------------------------------------

	MOV		EAX, 0
	MOV		val, EAX				; This will store the return value

	MOV		EAX, 1
	MOV		multiplier, 1			; Used for integer conversion calculations

	MOV		EAX, [EBP + 24]
	MOV		sizeErrorMsg, EAX

	MOV		EAX, [EBP + 20]
	MOV		valueErrorMsg, EAX

	MOV		EAX, [EBP + 28]
	MOV		countErrorMsg, EAX

	; --------------------------------------------------------------------------------------
	; Get input from the user
	;	[EBP + 16]	String entered by user
	;	numChars	Number of characters entered (up to the limit given in [EBP + 20]
	; --------------------------------------------------------------------------------------

_getString:
	mGetString [EBP + 32], [EBP + 12], [EBP + 16], [EBP - 4]

	; --------------------------------------------------------------------------------------
	; First, check to make sure the number of characters is valid 
	; --------------------------------------------------------------------------------------

	MOV		EAX, 0
	CMP		numChars, EAX
	JE		_invalidError

	MOV		EAX, 12
	CMP		numChars, EAX
	JA		_countError

	; --------------------------------------------------------------------------------------
	; Check to see if the integer is negative (first character is a minus sign)
	; --------------------------------------------------------------------------------------

	CLD
	MOV		ESI, [EBP + 12]
	LODSB
	CMP		EAX, 45
	JNE		_nonNegative

_negative:
	MOV		isNegative, 1
	DEC		numChars					; For negative numbers, ignore the first character for calculations
	JMP		_negativeCheckComplete

_nonNegative:
	MOV		isNegative, 0
	MOV		ESI, [EBP + 12]				; For non-negative number, reset the pointer to the beginning of string

_negativeCheckComplete:

	; --------------------------------------------------------------------------------------
	; Get the multiplier for the first digit (e.g., if the number if 3 digits long,
	; the first digit needs to be multiplied by 100)
	; --------------------------------------------------------------------------------------

	MOV		ECX, numChars
	DEC		ECX

	MOV		EAX, 1
	CMP		ECX, 0						; Skip the loop if there is only one digit
	JE		_multiplierComplete

	MOV		EBX, 10
	CDQ

_getMultiplier:
	MUL		EBX
	LOOP	_getMultiplier

_multiplierComplete:
	MOV		multiplier, EAX

	; --------------------------------------------------------------------------------------
	; Main loop to process digits and build up the return val
	; --------------------------------------------------------------------------------------

	CLD
	MOV		ECX, numChars

_processDigit:
	MOV		EAX, 0
	CDQ
	LODSB

	CMP		EAX, 57				; Check to make sure character is a valid digit
	JG		_invalidError
	CMP		EAX, 48
	JL		_invalidError	

	SUB		EAX, 48				; Convert to digit
	IMUL	multiplier
	JO		_sizeError
	CMP		EDX, 0				; Check for multiplier overflow (if there is a value in EDX, then input is out of range)
	JNE		_sizeError

	CMP		isNegative, 1		; If value is negative, subtract from total. If positive, add to total.
	JNE		_addValue

	SUB		val, EAX
	JO		_sizeError			; If input is out of range, throw an error
	JMP		_continue

_addValue:
	ADD		val, EAX
	JO		_sizeError			; If input is out of range, throw an error

_continue:


	MOV		EAX, multiplier
	MOV		EBX, 10
	DIV		EBX
	MOV		multiplier, EAX

	LOOP	_processDigit

	MOV		EAX, val
	MOV		EDI, [EBP + 8]
	MOV		[EDI], EAX

	JMP		_exit
	
_countError:
	CALL	Crlf
	MOV		EDX, countErrorMsg
	CALL	WriteString
	CALL	Crlf
	JMP		_getString

_sizeError:
	CALL	Crlf
	MOV		EDX, sizeErrorMsg
	CALL	WriteString
	CALL	Crlf
	JMP		_getString

_invalidError:
	CALL	Crlf
	MOV		EDX, valueErrorMsg
	CALL	WriteString
	CALL	Crlf
	JMP		_getString

_exit:

	POPAD
	RET 28
ReadVal ENDP


; --------------------------------------------------------------------------------------
; Name: WriteVal
; 
; Prints a signed integer
; 
; Preconditions: None
;
; Postconditions: None
;
; Receives: 
;		[EBP + 8]	integer: Address of the signed integer to be printed
; 
; Returns: None
; --------------------------------------------------------------------------------------

WriteVal PROC
	LOCAL	digits[12]:BYTE, printString[12]:BYTE, isNegative:DWORD, integer:SDWORD, digitCount:DWORD
	PUSHAD

	; --------------------------------------------------------------------------------------
	; Initialize local variables
	; --------------------------------------------------------------------------------------

	MOV		digitCount, 0			; Counter for the number of digits in the integer

	MOV		EAX, [EBP + 8]
	MOV		integer, EAX			; Store the given integer value


	; --------------------------------------------------------------------------------------
	; Check to see if integer is positive, negative, or zero.
	; --------------------------------------------------------------------------------------

	MOV		EAX, 0
	CMP		integer, EAX	
	JE		_zero
	JG		_positive
	JMP		_negative

_zero:								; Zero case: skip calculations; go straight to printing
	CLD
	MOV		EDI, EBP
	SUB		EDI, 24
	MOV		AL, 48					; Store a '0' in printString
	STOSB
	MOV		AL, 0
	STOSB
	JMP		_print

_positive:
	MOV		isNegative, 0			; For positive integer, sign = 0
	JMP		_getDigits

_negative:								
	MOV		isNegative, 1			; For negative integer, sign = 1
	JMP		_getDigits


	; --------------------------------------------------------------------------------------
	; Get the digits of the integer.
	; Digits will be stored in reverse order in local array: digits
	; --------------------------------------------------------------------------------------

_getDigits:
	CLD
	MOV		EDI, EBP
	SUB		EDI, 12					; EDI = local variable: digits

	; --------------------------------------------------------------------------------------
	; LOOP: Keep dividing by 10 and storing the remainder until there are no digits left
	; --------------------------------------------------------------------------------------

_storeDigit:
	MOV		EAX, integer		
	CDQ
	MOV		EBX, 10
	IDIV	EBX
	MOV		integer, EAX
	MOV		EAX, EDX

	CMP		isNegative, 1			
	JNE		_continueStore

	SUB		EAX, EDX				; Convert negative values to positive before ascii conversion
	SUB		EAX, EDX

_continueStore:
	ADD		EAX, 48					; Convert integer to ascii code
	STOSB
	INC		digitCount
	CMP		integer, 0
	JNE		_storeDigit


	; --------------------------------------------------------------------------------------
	; Reverse the digits and store in the local variable: printString
	; --------------------------------------------------------------------------------------

	MOV		EDI, EBP			; Destination = local array: printString
	SUB		EDI, 24

	CMP		isNegative, 0				; If the integer is negative, add a minus sign to the string
	JE		_skipMinus
	MOV		EAX, 45
	STOSB

_skipMinus:
	MOV		ESI, EBP			; Source = local array: digits
	SUB		ESI, 12
	ADD		ESI, digitCount
	SUB		ESI, 1

	MOV		ECX, digitCount		; Loop counter 

_reverseDigits:					; Store the digits in the destination in reverse order
	MOV		AL, [ESI]
	MOV		[EDI], AL
	DEC		ESI
	INC		EDI
	LOOP	_reverseDigits

	CLD
	MOV		EAX, 0
	STOSB

_print:
	MOV		ESI, EBP
	SUB		ESI, 24				; Move printString array to ESI
	mDisplayString ESI

	POPAD
	RET 4
WriteVal ENDP


; --------------------------------------------------------------------------------------
; Name: PrintArray
; 
; Prints an array of signed 32-bit integers.
; 
; Preconditions: Array contains the given number of signed 32-bit integers.
;
; Postconditions: None
;
; Receives:
;		[EBP + 20]	Address of message to print before printing the array
;		[EBP + 16]	Address of separator to print between array elements
;		[EBP + 12]	numValues: The number of integers in the array
;		[EBP + 8]	arrayAddr: Address of the array of integers
; 
; Returns: None
;
; --------------------------------------------------------------------------------------

PrintArray PROC
	PUSH	EBP
	MOV		EBP, ESP
	PUSHAD

	MOV		EDX, [EBP + 20]			; Print label for the array
	CALL	WriteString

	MOV		ECX, [EBP + 12]			; Prep for print loop
	MOV		ESI, [EBP + 8]
	CLD

_printInteger:
	LODSD
	PUSH	EAX
	CALL	WriteVal

	CMP		ECX, 1
	JE		_skipSeparator
	MOV		EDX, [EBP + 16]			; Print a separator between elements
	CALL	WriteString

_skipSeparator:
	LOOP	_printInteger

	POPAD
	POP		EBP
	RET 20
PrintArray ENDP



; --------------------------------------------------------------------------------------
; Name: calculateSum
; 
; Calculates the sum of integers in an array of signed 32-bit integers.
; 
; Preconditions: Array contains the given number of signed 32-bit integers.
;
; Postconditions: None
;
; Receives:
;		[EBP + 16]	(output) Sum of the integers in the array
;		[EBP + 12]	numValues: The number of integers in the array
;		[EBP + 8]	arrayAddr: Address of the array of integers
; 
; Returns:
;		[EBP + 16]	Sum of integers in the array
;
; --------------------------------------------------------------------------------------

calculateSum PROC
	PUSH	EBP
	MOV		EBP, ESP
	PUSHAD

	MOV		EAX, [EBP + 12]			; Check for edge case: array with 0 integers
	CMP		EAX, 0
	JE		_zeroCase

	MOV		ECX, [EBP + 12]
	MOV		ESI, [EBP + 8]
	MOV		EBX, 0
	CLD

_addValues:							; Loop through the array and sum up all the values
	LODSD
	ADD		EBX, EAX
	LOOP	_addValues
	MOV		EDI, [EBP + 16]
	MOV		[EDI], EBX
	JMP		_exit

_zeroCase:
	MOV		EBX, 0
	MOV		EDI, [EBP + 16]
	MOV		[EDI], EBX
	JMP		_exit

_exit:

	POPAD
	POP		EBP
	RET
calculateSum ENDP


END main