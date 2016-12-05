TITLE 			MouseClickTest		(main.asm)

INCLUDE Irvine32.inc
INCLUDE GraphWin.inc
;INCLUDELIB User32.lib 
;INCLUDELIB Kernel32.lib

.data
	rHnd HANDLE ?
	numEventsRead DWORD ?
	numEventsOccurred DWORD ?
	eventBuffer INPUT_RECORD 128 DUP(<>)
	coordString BYTE "Coordinate change: (", 0
	buttonString BYTE "Right Button Pressed!", 0Ah, 0	

	msg MSGStruct <>

	savedCoords dw 0			; Current coordinates that we are printing to
	initialTime dd 0			; Time when the program starts
	lastTimeSeconds dd 0		; Last time that was put onto the clock (in seconds)
	clockMax dd 100				; What the clock will start at


.code
main PROC	
	mov edx, 0		; Initializer for gotoXY

	; Initialize the timer
	call GetMseconds
	mov initialTime, eax
	
	invoke GetStdHandle, STD_INPUT_HANDLE		; Get a handle to std_input
	mov rHnd, eax								;						02h                    10h                    80h
	invoke SetConsoleMode, rHnd, 92h			; 92h comes from (ENABLE_LINE_INPUT OR ENABLE_MOUSE_INPUT OR ENABLE_EXTENDED_FLAGS. These values are declared in Windows.h but for whatever reason, the SmallWin.inc included in the Irvine32.inc does not have them.

appContinue:
	call ClockFunc
	invoke GetNumberOfConsoleInputEvents, rHnd, OFFSET numEventsOccurred		; Gets the number of mouse/input events held in the buffer
	cmp numEventsOccurred, 0													; If there were no events raised, we dont need to do anything
	je appContinue	

	; If we are here, there were inputs of some kind
	invoke ReadConsoleInput, rHnd, OFFSET eventBuffer, numEventsOccurred, OFFSET numEventsRead
	mov ecx, numEventsRead
	mov esi, OFFSET eventBuffer

	; Go through each user-input and deal with it appropriately
loopOverEvents:
	cmp (INPUT_RECORD PTR [esi]).EventType, MOUSE_EVENT		; We only care about mouse-events
	jne notMouse

	test (INPUT_RECORD PTR [esi]).Event.dwButtonState, 2	; 2 is the value of RIGHTMOST_BUTTON_PRESSED event
	jz CheckLeftClick
	mov dx, savedCoords
	call GoToXY
	inc BYTE PTR [savedCoords + 1]
	mov BYTE PTR savedCoords, 0
	mov edx, offset buttonString
	call WriteString
	jmp notMouse											; It can only be either a left or right click, so we can just skip the next check

CheckLeftClick:
	test (INPUT_RECORD PTR [esi]).Event.dwButtonState, 1	; 1 is the value of FROM_LEFT_1ST_BUTTON_PRESSED event
	jz notMouse
	
	; Print the coordinates where the user LEFT clicked
	mov dx, savedCoords
	call GoToXY
	inc BYTE PTR [savedCoords + 1]
	mov BYTE PTR savedCoords, 0
	mov edx, OFFSET coordString
	call WriteString
	movzx eax, (INPUT_RECORD PTR [esi]).Event.dwMousePosition.x
	call WriteInt
	mov al, ','
	call WriteChar
	movzx eax, (INPUT_RECORD PTR [esi]).Event.dwMousePosition.y
	call WriteInt
	mov al, ')'
	call WriteChar

notMouse:
	add esi, TYPE INPUT_RECORD			; If it was not a mouse-event, just go to the next event in the buffer
	dec ecx
	jnz loopOverEvents
	;loop loopOverEvents
	jmp appContinue
done:

	exit
main ENDP

;-----------------------------------------------
; ClockFunc
; Updates the clock
; Receives: 
; Returns: 
;-----------------------------------------------
ClockFunc PROC USES eax ebx edx
	call GetMseconds			; Puts time in eax (milliseconds since midnight)
	sub eax, initialTime		; Calculates elapsed time since the program started

	mov edx, 0					; This will calculate the number of seconds since the program started (and put it into eax)
	mov ebx, 1000
	div ebx

	cmp eax, lastTimeSeconds	; If the time hasnt changed, we dont need to update the clock
	je NoUpdate

	mov lastTimeSeconds, eax	; Update the last time variable

	mov dh, 0					; If the time HAS changed, update the clock
	mov dl, 90
	call GoToXY

	neg eax
	add eax, clockMax

	call WriteDec			; Using WriteDec instead of WriteInt because it will not put the +/- sign in front of it

	;cmp eax, 0
	;je END THE GAME BECAUSE TIME IS UP!!

NoUpdate:
	ret
ClockFunc ENDP

;------------------------------------------------
; MouseClickTest1
; This is the program from the powerpoint. I had 
;  to change some things to make it work because 
;  certain aspects of the Windows API could not be found...
;  Not useful!! I'm just saving this becasue it took forever
;  to get it work and im a sentimental person...
;------------------------------------------------
;MouseClickTest1 PROC
;	invoke GetStdHandle, STD_INPUT_HANDLE
;	mov rHnd, eax						;						02h                    10h                    80h
;	invoke SetConsoleMode, rHnd, 92h	; 92h comes from (ENABLE_LINE_INPUT OR ENABLE_MOUSE_INPUT OR ENABLE_EXTENDED_FLAGS). These values are declared in Windows.h but for whatever reason, the SmallWin.inc included in the Irvine32.inc does not have them.
;appContinue:
;	invoke GetNumberOfConsoleInputEvents, rHnd, OFFSET numEventsOccurred
;	cmp numEventsOccurred, 0
;	je appContinue
;
;	invoke ReadConsoleInput, rHnd, OFFSET eventBuffer, numEventsOccurred, OFFSET numEventsRead
;	mov ecx, numEventsRead
;	mov esi, OFFSET eventBuffer
;loopOverEvents:
;	cmp (INPUT_RECORD PTR [esi]).EventType, MOUSE_EVENT
;	jne notMouse
;	cmp (INPUT_RECORD PTR [esi]).Event.dwEventFlags, 1		; 1 is the value of MOUSE_MOVED event
;	jne continue
;	mov edx, OFFSET coordString
;	call WriteString
;	movzx eax, (INPUT_RECORD PTR [esi]).Event.dwMousePosition.x
;	call WriteInt
;	mov al, ','
;	call WriteChar
;	movzx eax, (INPUT_RECORD PTR [esi]).Event.dwMousePosition.y
;	call WriteInt
;	mov al, ')'
;	call WriteChar
;	call Crlf
;continue:
;	test (INPUT_RECORD PTR [esi]).Event.dwButtonState, 1     ; 1 is the value of FROM_LEFT_1ST_BUTTON_PRESSED event
;	jz notMouse
;	mov edx, OFFSET buttonString
;	call WriteString
;notMouse:
;	add esi, TYPE INPUT_RECORD
;	loop loopOverEvents
;	jmp appContinue
;done:
;	ret
;MouseClickTest1 ENDP


END main