TITLE Project 6 - String Primitives and Macros     (Proj6_JANT.asm)

; Author: Timothy Jan
; Last Modified: 12/03/2020
; OSU email address:JANT@oregonstate.edu
; Course number/section:   CS271 Section 401
; Project Number: 6                 Due Date: 12/06/2020
; Description: Uses macros and string processing to ask the user for ten (valid) numbers, reports the list of numbers entered, and shows the sum and rounded average. 

INCLUDE Irvine32.inc

; ---------------------------------------------------------------------------------
; Name: mGetString
;
; Reads a string input from the user
;
; Preconditions: Uses parameters passed onto parameter stack. 
;
; Receives:
; inputMessage = string address 
;	- prompts the user for their number input
; outputString = string address
;	- temporary buffer to store user's input; used by procedure to validate user's entry
; maxStringLength = constant
; userStringLength = variable address
;
; returns: 
; outputString = user generated string
; userStringLength = user generated string length
; ---------------------------------------------------------------------------------

mGetString MACRO inputMessage, outputString, maxStringLength, userStringLength

	PUSH	EAX
	MOV		EDX, inputMessage
	CALL	WriteString

	MOV		EDX, outputString
	MOV		ECX, maxStringLength
	CALL	ReadString
	
	MOV		userStringLength, EAX
	POP		EAX
	
	CALL	CrLf

ENDM

; ---------------------------------------------------------------------------------
; Name: mDisplayString
;
; Prints a given string stored in a given memory location
;
; Preconditions: String by reference
;
; Receives:
; displayInput = string address
;
; returns: None
; ---------------------------------------------------------------------------------

mDisplayString MACRO displayInput
	PUSH	EDX

	MOV		EDX, displayInput
	CALL	WriteString

	POP		EDX

ENDM

	; constants
	MAXLENGTH = 45

.data

	; messages
	programTitle			BYTE	"Project 6: Using string primitives and macros to process numbers",0
	programBy				BYTE	"Programmer: Timothy Jan",0
	programInstructions1	BYTE	"Please enter 10 signed decimal integers.",0 
	programInstructions2	BYTE	"Each decimal must fit inside a signed 32 bit register [-2,147,483,648 ... 2,147,483,647].",13,10,"After you're done, I'll display a list of the numbers you entered, their sum, and the average value.",0
	messageInput			BYTE	"Please enter a signed integer: ",0
	messageError			BYTE	"ERROR: You didn't enter a valid signed integer or the integer you entered was too big. Please try again!",0
	messageIntegers			BYTE	"You entered the following integers:",0
	messageSum				BYTE	"The sum of the integers you entered is: ",0
	messageAverage			BYTE	"The rounded average of the integers you entered is: ",0
	messageSpace			BYTE	" ",0
	messageComma			BYTE	",",0
	goodbye					BYTE	"Thank you for helping test my Project 6!", 0

	; variables
	userInputTemp			BYTE    45 DUP(?)		; store strings
	userInputTempLength		DWORD	?				; store string length
	userVal					SDWORD	?
	printTemp				BYTE	12 DUP(?)
	userNumSum				SDWORD	?
	userNumAverage			SDWORD	?

	; arrays
	userNumArray			SDWORD	10 DUP(?)

.code
main PROC
	
; INTRODUCTION
	PUSH	OFFSET programInstructions2
	PUSH	OFFSET programInstructions1
	PUSH	OFFSET programBy
	PUSH	OFFSET programTitle
	CALL	introduction

; GET NUMBERS FROM USER

	; initialize loop to get user input and store address of userNumArray in EDI
	MOV		ECX, 10
	MOV		EDI, OFFSET userNumArray
		
	; get 10 valid integers from the user
	_inputLoop:
	PUSH	EDI
	PUSH	OFFSET userVal
	PUSH	OFFSET userNumArray
	PUSH	MAXLENGTH
	PUSH	OFFSET userInputTempLength
	PUSH	OFFSET userInputTemp
	PUSH	OFFSET messageError
	PUSH	OFFSET messageInput
	CALL	ReadVal

	; store valid integers in userNumArray	
	POP		EDI
	MOV		EBX, userVal
	MOV		[EDI], EBX
	ADD		EDI, 4

	LOOP	_inputLoop

; DISPLAY USER'S INTEGERS

	; title message
	mDisplayString OFFSET messageIntegers
	CALL	CrLf

	; initialize display counter and move address of userNumArray in EDI
	MOV		ECX, 9
	MOV		ESI, OFFSET userNumArray

	_displayLoop:
	PUSH	OFFSET printTemp
	PUSH	ESI
	CALL	WriteVal

	; print comma after first 9 numbers
	mDisplayString OFFSET messageComma
	; print blank space between numbers
	mDisplayString OFFSET messageSpace
	
	ADD		ESI, 4
	LOOP	_displayLoop

	; one last print for term without commma
	PUSH	OFFSET printTemp
	PUSH	ESI
	CALL	WriteVal

	; print blank space between numbers
	mDisplayString OFFSET messageSpace

	CALL	CrLf
	CALL	CrLf

; CALCULATE AND DISPLAY SUM
	
	XOR		EAX, EAX
	XOR		ESI, ESI
	XOR		ECX, ECX

	MOV		ESI, OFFSET userNumArray
	MOV		ECX, 10

	_sumLoop:
	ADD		EAX, [ESI]
	ADD		ESI, 4
	LOOP	_sumLoop

	MOV		userNumSum, EAX

	mDisplayString OFFSET messageSum

	PUSH	OFFSET printTemp
	PUSH	OFFSET userNumSum
	CALL	WriteVal

	CALL	CrLf
	CALL	CrLf

; CALCULATE AND DISPLAY AVERAGE

	MOV		EAX, userNumSum

	CDQ	
	MOV		EBX, 10
	IDIV	EBX

	CMP		EDX, 5				
	JL		_noRound				; since the divisor will always be 10, if the remainder is less than 5 we don't round. otherwise, round up 
	INC		EAX

	_noRound:
	MOV		userNumAverage, EAX

	mDisplayString OFFSET messageAverage

	PUSH	OFFSET printTemp
	PUSH	OFFSET userNumAverage
	CALL	WriteVal

	CALL	CrLf
	CALL	CrLf

; BYE BYE

	PUSH	OFFSET goodbye
	CALL	farewell

main ENDP

; ---------------------------------------------------------------------------------
; Name: introduction
;
; Description: Displays program title, programmer name, and two sets of instructions. 
;
; Preconditions: None
;
; Postconditions: None
;
; Receives: Addresses for title, programmer name, and two user instructions.
;
; Returns: None
; ---------------------------------------------------------------------------------

introduction PROC

	PUSH	EBP
	MOV		EBP, ESP

	mDisplayString [EBP + 8]			; title
	CALL	CrLf	
	mDisplayString [EBP + 12]			; programmer
	CALL	CrLf
	CALL	CrLf
	mDisplayString [EBP + 16]			; first instructions
	CALL	CrLf
	mDisplayString [EBP + 20]			; second instruction
	CALL	CrLf
	CALL	CrLf

	POP		EBP
	RET		20

introduction ENDP


; ---------------------------------------------------------------------------------
; Name: ReadVal
;
; Description: Invokes mGetString to receive user input, converts ascii digits to SDWORD, validates user input, and if valid, stores in userNumArray.
;			   Returns error message and reprompts if user enters an invalid number.
;
; Preconditions: Procedure must have addressses for input message, message error, user temporary input array, user temporary input length, max length constant,
;				 user value array, and user value pushed in that order. 
;
; Postconditions: Overwrites userVal each time a valid number is called - make sure you store it outside the function call if you want to save it.
;
; Receives: 
;	userVal variable (address)
;	userNumArray (address)
;	MAXLENGTH (constant)
;	userInputTempLength variable (address)
;	userInputTemp variable (address)
;	messageError string (address)
;	messageInput (address)
;
; Returns: Validated user entry stored in userVal 
; ---------------------------------------------------------------------------------

ReadVal PROC

	PUSH	EBP
	MOV		EBP, ESP
	PUSH	ECX

	_input:
	;inputMessage, outputString, maxStringLength, userStringLength
	mGetString [EBP + 8], [EBP + 16], [EBP + 24], [EBP + 20]
	
	; string characters are stored in userInputTemp (ebp + 16) and string length is stored in userStringLength (ebp + 20)

	MOV		ECX, [EBP + 20]				; string length
	MOV		ESI, [EBP + 16]				; user's entry
	MOV		EDI, [EBP + 32]				; user end value

	XOR		EAX, EAX
	XOR		EBX, EBX

	_posConvertLoop:
	CLD
	LODSB
	CMP		AL, 45
	JE		_negConvert					; converts negative string
	CMP		AL, 43						; else, checks if necessary to skip plus sign and continues with normal converting
	JE		_plusSign
	CMP		AL, 48						; below 0
	JL		_errorEntry
	CMP		AL, 57						; above 9
	JG		_errorEntry	

	SUB		AL, 48
	IMUL	EBX, 10
	JO		_errorEntry					; jumps to entry error if multiplication results in an overflow
	ADD		EBX, EAX
	
	LOOP _posConvertLoop
	
	_numStore:
	; store final number in userNumArray
	PUSH	EDI
	MOV		EDI, [EBP + 32]				; userVal
	MOV		[EDI], EBX
	POP		EDI

	POP		ECX
	POP		EBP
	RET		28

	_errorEntry:
	mDisplayString [EBP + 12]
	CALL	CrLf
	CALL	CrLf
	JMP		_input

	_plusSign:
	; only allows a plus sign to be entered as the first character (counter == string length) 
	CMP		ECX, [EBP + 20]
	JNE		_errorEntry
	LOOP	_posConvertLoop

	_negConvert:
	; only allows minus sign to be entered as the first character
	CMP		ECX, [EBP + 20]
	JNE		_errorEntry
	DEC		ECX
	
	_negConvertLoop:
	LODSB

	CMP		AL, 48						; below 0
	JL		_errorEntry
	CMP		AL, 57						; above 9
	JG		_errorEntry	

	SUB		AL, 48
	IMUL	EBX, 10
	JO		_errorEntry
	SUB		EBX, EAX

	LOOP	_negConvertLoop
	JMP		_numStore

	POP		ECX
	POP		EBP
	RET		28

ReadVal ENDP


; ---------------------------------------------------------------------------------
; Name: WriteVal
;
; Description: Converts a numeric value to ascii digits and calls mDisplayString to print the ascii representation of the numeric value. 
;
; Preconditions: Must be passed a numeric value (no passing strings!)
;
; Postconditions: Doesn't save the converted numeric value - each time WriteVal is called it overwrites the temporary print buffer with the next value
;
; Receives: 
;	printTemp address (buffer to store converted string)
;	ESI (user value into Writeval)
;
; Returns: None
; ---------------------------------------------------------------------------------

WriteVal PROC
	
	PUSH	EBP
	MOV		EBP, ESP
	
	; get the integer			; NEGATIVE USE SIGN FLAG??? 
	MOV		ESI, [EBP + 8]      ; integer value in
	MOV		EDI, [EBP + 12]		; string out

	; move initial value into EAX
	MOV		EAX, [ESI] 

	; check if integer is negative
	CMP		EAX, 0
	JGE		_integerToASCII		; if positive, skip negative sign and convert normally

	CDQ	

	MOV		EBX, -1				; make positive
	IDIV	EBX

	PUSH	EAX
	MOV		EAX, 45
	MOV		[EDI], EAX			; store negative sign in first position
	ADD		EDI, 1				; increment EDI to account for negative sign in first position
	POP		EAX

	; checks how many digits we'll need to store and adjusts EDI accordingly 
	_integerToASCII:
	CMP		EAX, 9
	JLE		_oneDigit
	CMP		EAX, 99
	JLE		_twoDigit
	CMP		EAX, 999
	JLE		_threeDigit
	CMP		EAX, 9999
	JLE		_fourDigit
	CMP		EAX, 99999
	JLE		_fiveDigit
	CMP		EAX, 999999
	JLE		_sixDigit
	CMP		EAX, 9999999
	JLE		_sevenDigit
	CMP		EAX, 99999999
	JLE		_eightDigit
	CMP		EAX, 999999999
	JLE		_nineDigit

	_oneDigit:
	ADD		EDI, 1
	JMP		_asciiLoop

	_twoDigit:
	ADD		EDI, 2
	JMP		_asciiLoop

	_threeDigit:
	ADD		EDI, 3
	JMP		_asciiLoop

	_fourDigit:
	ADD		EDI, 4
	JMP		_asciiLoop

	_fiveDigit:
	ADD		EDI, 5
	JMP		_asciiLoop

	_sixDigit:
	ADD		EDI, 6
	JMP		_asciiLoop

	_sevenDigit:
	ADD		EDI, 7
	JMP		_asciiLoop

	_eightDigit:
	ADD		EDI, 8
	JMP		_asciiLoop

	_nineDigit:
	ADD		EDI, 9
	JMP		_asciiLoop

	; loop starts with a null terminator then moves backward, storing ASCII bytes
	_asciiLoop:
	PUSH	EAX
	STD						; go backward through print buffer
	MOV		AL, 0
	STOSB
	POP		EAX

	_innerAsciiLoop:
	CDQ	

	MOV		EBX, 10
	IDIV	EBX

	; calculate ASCII
	PUSH	EAX
	ADD		EDX, 48
	MOV		AL, DL

	STOSB			
	POP		EAX

	; exits when dividend is zero (i.e. when we're done converting)
	CMP		EAX, 0
	JE		_exitASCII
	JMP		_innerAsciiLoop

	_exitASCII:
	mDisplayString [EBP + 12]

	POP		EBP
	RET		8

WriteVal ENDP


; ---------------------------------------------------------------------------------
; Name: farewell
;
; Description: Says goodbye and exits the program.
;
; Preconditions: None.
;
; Postconditions: None.
;
; Receives: String message goodbye.
;
; Returns: None.
; ---------------------------------------------------------------------------------

farewell PROC
	
	PUSH	EBP
	MOV		EBP, ESP

	mDisplayString [EBP + 8]
	CALL	CrLf
	
	INVOKE	ExitProcess, 0

farewell ENDP

END main
