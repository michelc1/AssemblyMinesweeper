TITLE 			MouseClickTest		(main.asm)

INCLUDE Irvine32.inc
;INCLUDELIB User32.lib 
;INCLUDELIB Kernel32.lib

.data
	rHnd HANDLE ?
	numEventsRead DWORD ?
	numEventsOccurred DWORD ?
	eventBuffer INPUT_RECORD 128 DUP(<>)
	coordString BYTE "Coordinate change: (", 0
	buttonString BYTE "Right Button Pressed!", 0Ah, 0

.code
main PROC
	invoke GetStdHandle, STD_INPUT_HANDLE		; Get a handle to std_input
	mov rHnd, eax								;						02h                    10h                    80h
	invoke SetConsoleMode, rHnd, 92h			; 92h comes from (ENA	. These values are declared in Windows.h but for whatever reason, the SmallWin.inc included in the Irvine32.inc does not have them.
appContinue:
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
	mov edx, offset buttonString
	call WriteString
	jmp notMouse											; It can only be either a left or right click, so we can just skip the next check

CheckLeftClick:
	test (INPUT_RECORD PTR [esi]).Event.dwButtonState, 1	; 1 is the value of FROM_LEFT_1ST_BUTTON_PRESSED event
	jz notMouse
	
	; Print the coordinates where the user LEFT clicked
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
	call Crlf

notMouse:
	add esi, TYPE INPUT_RECORD			; If it was not a mouse-event, just go to the next event in the buffer
	loop loopOverEvents
	jmp appContinue
done:

	exit
main ENDP

;------------------------------------------------
; MouseClickTest1
; This is the program from the powerpoint. I had 
;  to change some things to make it work because 
;  certain aspects of the Windows API could not be found...
;  Not useful!! I'm just saving this becasue it took forever
;  to get it work and im a sentimental person...
;------------------------------------------------
MouseClickTest1 PROC
	invoke GetStdHandle, STD_INPUT_HANDLE
	mov rHnd, eax						;						02h                    10h                    80h
	invoke SetConsoleMode, rHnd, 92h	; 92h comes from (ENABLE_LINE_INPUT OR ENABLE_MOUSE_INPUT OR ENABLE_EXTENDED_FLAGS). These values are declared in Windows.h but for whatever reason, the SmallWin.inc included in the Irvine32.inc does not have them.
appContinue:
	invoke GetNumberOfConsoleInputEvents, rHnd, OFFSET numEventsOccurred
	cmp numEventsOccurred, 0
	je appContinue

	invoke ReadConsoleInput, rHnd, OFFSET eventBuffer, numEventsOccurred, OFFSET numEventsRead
	mov ecx, numEventsRead
	mov esi, OFFSET eventBuffer
loopOverEvents:
	cmp (INPUT_RECORD PTR [esi]).EventType, MOUSE_EVENT
	jne notMouse
	cmp (INPUT_RECORD PTR [esi]).Event.dwEventFlags, 1		; 1 is the value of MOUSE_MOVED event
	jne continue
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
	call Crlf
continue:
	test (INPUT_RECORD PTR [esi]).Event.dwButtonState, 1     ; 1 is the value of FROM_LEFT_1ST_BUTTON_PRESSED event
	jz notMouse
	mov edx, OFFSET buttonString
	call WriteString
notMouse:
	add esi, TYPE INPUT_RECORD
	loop loopOverEvents
	jmp appContinue
done:
	ret
MouseClickTest1 ENDP


END main