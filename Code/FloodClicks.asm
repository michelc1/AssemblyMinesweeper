INCLUDE Irvine32.inc

; Constant characters (for building the board)
topLeft = 201
topRight = 187
bottomLeft = 200
bottomRight = 188
horizontal = 205
vertical = 186
tile = 35
mines = 10


;-------------------------------
; Colors for each number (REFERENCE)
; 1 = Blue
; 2 = Green
; 3 = Red
; 4 = Purple
; 5 = Maroon
; 6 = Cyan
; 7 = Black
; 8 = Light Gray
;-------------------------------

.data
	welcome1 db " __      __  ___   _       ___    ___    __  __   ___     _____    ___      ", 0
	welcome2 db " \ \    / / | __| | |     / __|  / _ \  |  \/  | | __|   |_   _|  / _ \     ", 0
	welcome3 db "  \ \/\/ /  | _|  | |__  | (__  | (_) | | |\/| | | _|      | |   | (_) |  _ ", 0
	welcome4 db "   \_/\_/   |___| |____|  \___|  \___/  |_|  |_| |___|     |_|    \___/  ( )", 0
	welcome5 db "                                                                         |/ ", 0
	minesweeper1 db "    __  ___ ____ _   __ ______ _____ _       __ ______ ______ ____   ______ ____ ", 0
	minesweeper2 db "   /  |/  //  _// | / // ____// ___/| |     / // ____// ____// __ \ / ____// __ \", 0
	minesweeper3 db "  / /|_/ / / / /  |/ // __/   \__ \ | | /| / // __/  / __/  / /_/ // __/  / /_/ /", 0
	minesweeper4 db " / /  / /_/ / / /|  // /___  ___/ / | |/ |/ // /___ / /___ / ____// /___ / _, _/ ", 0
	minesweeper5 db "/_/  /_//___//_/ |_//_____/ /____/  |__/|__//_____//_____//_/    /_____//_/ |_|  ", 0
	createdBy db "Created by: Darrien Kennedy, Chris Michel and Alex Robbins", 0

	timerDigit0 db '0'		; Used to display timer
	timerDigit1 db '0'		; Used to display timer
	timerDigit2 db '0'		; Used to display timer
	strTime db "000",0		; Used to INITIALLY display timer
	strCount db "000",0		; Used to INITIALLY display flag count
	strFace db ":)",0
	Space db " "
	strSpace db " ",0
	ShowArray db 81 DUP(254)
	CountArray db 81 DUP(0)
	
	SpaceCheckStack dd 81 DUP(0)	; Used to clear spaces on the board after a click
	SpaceCheckStackSize db 0		; Same^
	StackValFound db 0
	
	MineLocations db 10 DUP(?) 
	SpaceCount db 0
	currentY db ?
	Xcord db 32,34,36,38,40,42,44,46,48		; All valid X coordinates of the 9x9 board
	Ycord db 8,9,10,11,12,13,14,15,16		; All valid Y coordinates of the 9x9 board

	CMDTitle db "Minesweeper", 0		; Console window title
	cursorInfo CONSOLE_CURSOR_INFO <1,0>   ; cursor-size = 1 (irrelevant), cursor-visible = 0/false

	; These are all used to capture mouse clicks
	rHnd HANDLE ?						
	numEventsRead DWORD ?
	numEventsOccurred DWORD ?
	eventBuffer INPUT_RECORD <> ; only do these events one at a time
	XClick dw 0
	YClick dw 0
	rightClick db 0			; After a mouse click occurred, This will be 1 if it was a right click, 0 otherwise
	oldClick db 0			; previous value of the pressed button

	showClock db 0			; if the clock must be shown

	; These are all used for the timer
	initialTime dd 0			; Time when the program starts
	lastTimeSeconds dd 0		; Last time that was put onto the clock (in seconds)

.code
main PROC
	invoke SetConsoleTitle, OFFSET CMDTitle		; Sets the title of the console window
	
	invoke GetStdHandle, STD_OUTPUT_HANDLE
	invoke SetConsoleCursorInfo, eax, OFFSET cursorInfo		; Make the cursor invisible (no more ugly blinky thing)

	call SplashScreen		; So preeettyyyyyyy

	call InitMouse			; initialize the mouse

	call GetMseconds		; Initialize the timer
	mov initialTime, eax
		
	call Randomize				; So we can get random numbers for mine location generation
	STARTX = 30					; The X coordinate of the top left corner of the board
	STARTY = 6					; The Y coordinate of the top left corner of the board
	BOARDSIZE = 9				; Width of board (will need to make this changeable in game somehow...)
	NUMOFMINES = 10

	mov showClock, 0
TryAgain:	
	call DrawBoard
	call GetMouseClick				; Pause until the first click is received
	call ValidClicks
	cmp eax, 1
	jne TryAgain
	cmp rightClick, 1				; If the 1st click was a right click, the board will not be made	
	je SkipFillBoard
	call FillBoard					; Once we get the first click, we can place the mines
	call TestProc	;***FOR TESTING*************************************************************************
SkipFillBoard:
	call ClearSpace
	cmp rightClick, 1				; We only want to make the board once a valid left click is received
	je TryAgain

	mov showClock, 1				; show clock

MainLoop:
	call DrawBoard
		; Wait for mouse click. This is where the program will sit for most of the time it is running. Because of this, the GetMouseClick procedure also controls the clock.
	call GetMouseClick			; Gets mouse click and puts the X-coord in XClick, and Y-coord YClick
	call ValidClicks
	cmp eax, 1
	jne MainLoop
	call ClearSpace

	jmp MainLoop

	Invoke ExitProcess, 0
main ENDP

;----------------------------------
; DrawBoard
; Draws the board layout to the console 
; Recieves: Nothing
; Returns: An empty minesweeper board
; Uses: eax ecx edx
;----------------------------------
DrawBoard PROC USES eax ecx edx
	
	mov esi, offset ShowArray
	mov eax, red + (gray * 16)
	call SetTextColor

	mov currentY, STARTY
	mov dh, currentY
	mov dl, STARTX
	call GotoXY

	mov edx, offset strCount
	call WriteString
	mov edx, offset strSpace
	mov ecx, 6
Spaces1:
	call WriteString
	loop Spaces1

	mov eax, yellow + (gray * 16)
	call SetTextColor
	mov edx, offset strFace
	call WriteString
	
	mov edx, offset strSpace
	mov ecx, 7
Spaces2:
	call WriteString
	loop Spaces2

	cmp lastTimeSeconds, 0			; Only need to draw this the first time. Once the timer is past 0, the ClockFunc will take care of this
	jg DoNotDrawTimer
	mov eax, red + (gray * 16)
	call SetTextColor
	mov edx, offset strTime
	call WriteString
DoNotDrawTimer:
	
	inc currentY
	mov dh, currentY
	mov dl, STARTX
	call GotoXY

	mov eax, lightgray + (gray * 16)
	call SetTextColor
	mov edx, offset strSpace

	mov eax, topLeft
	call WriteChar

	mov ecx, ((2*BOARDSIZE)+1)
	mov eax, horizontal
Top:
	call WriteChar
	loop Top
	
	mov eax, topRight
	call WriteChar
	
	inc currentY
	mov dh, currentY
	mov dl, STARTX
	call GotoXY

	mov ecx, BOARDSIZE


Contents:
	mov eax, vertical
	call WriteChar
	push ecx
	
	call PrintContents

	pop ecx
	mov eax, vertical
	call WriteChar
	
	inc currentY
	mov dh, currentY
	mov dl, STARTX
	call GotoXY

	loop Contents
	
	mov eax, bottomLeft
	call WriteChar
	mov eax, horizontal
	mov ecx, ((2*BOARDSIZE)+1)
Bottom:
	call WriteChar
	loop Bottom

	mov eax, bottomRight
	call WriteChar
	
	inc currentY
	mov dh, currentY
	mov dl, STARTX
	call GotoXY

	mov eax, lightgray
	call SetTextColor

	ret
DrawBoard ENDP


;-------------------------------
; PrintContents
; Prints the contents of the array within the the vertical bars
; Recieves: offset of board array in esi
; Returns: Output on screen
;-------------------------------
PrintContents PROC 

	mov edx, offset strSpace
	mov ecx, BOARDSIZE
	call WriteString

Inner:
	call AssignColor		; Prepares what to print and what color is should be

	call WriteChar			; Prints whatever was prepared by the AssignColor procedure
	call WriteString		; Prints a space (for formatting)
	inc esi

	mov eax, lightgray + (gray * 16)	; Restore the default text color
	call SetTextColor
	loop Inner

	ret
PrintContents ENDP


;-----------------------------
; AssignColor
; Sets the text color and character for eax based on the value in eax
; Recieves: a value in the board array
; Returns: eax with the correspoding character and color
;-----------------------------
AssignColor PROC
	mov al, [esi]
	cmp al, 255		; Mine
	je MineSet
	cmp al, 15		; Flag (becasue 15 = F = Flag...)
	je FlagSet

	cmp al, 0		; Number
	je ZeroSet
	cmp al, 1
	je OneSet
	cmp al, 2
	je TwoSet
	cmp al, 3
	je ThreeSet
	cmp al, 4
	je FourSet
	cmp al, 5
	je FiveSet
	cmp al, 6
	je SixSet
	cmp al, 7
	je SevenSet
	cmp al, 8
	je EightSet

	cmp al, 0		; Other. Do nothing
	jl CharIsSet
	cmp al, 8
	jg CharIsSet
	;add al, 48		; Not needed? (Unreachable)
	;jmp CharIsSet

ZeroSet:
	mov eax, '.'
	jmp CharIsSet

OneSet:
	mov eax, blue + (gray * 16)
	call SetTextColor
	mov eax, '1'
	jmp CharIsSet
TwoSet:
	mov eax, green + (gray * 16)
	call SetTextColor
	mov eax, '2'
	jmp CharIsSet
ThreeSet:
	mov eax, red + (gray * 16)
	call SetTextColor
	mov eax, '3'
	jmp CharIsSet
FourSet:
	mov eax, magenta + (gray * 16)
	call SetTextColor
	mov eax, '4'
	jmp CharIsSet
FiveSet:
	mov eax, lightRed + (gray * 16)
	call SetTextColor
	mov eax, '5'
	jmp CharIsSet
SixSet:
	mov eax, cyan + (gray * 16)
	call SetTextColor
	mov eax, '6'
	jmp CharIsSet
SevenSet:
	mov eax, black + (gray * 16)
	call SetTextColor
	mov eax, '7'
	jmp CharIsSet	
EightSet:
	mov eax, lightGray + (gray * 16)
	call SetTextColor
	mov eax, '8'
	jmp CharIsSet		

MineSet:
	mov eax, black + (gray * 16)
	call SetTextColor
	mov al, 42
	jmp CharIsSet
FlagSet:
	mov eax, white + (gray * 16)
	call SetTextColor
	mov al, 191
	jmp CharIsSet

CharIsSet:
	ret
AssignColor ENDP


;---------------------------------------------------------------
; FillBoard:
; Ramdonly decides the locations of the X number of mines
;	that will be put onto the board, and sets up the 
;	CountArray array to contain the numbers associated with
;	each space on the board as well as the mines on the board
; Receives: nothing
; Returns: CountArray will now be filled ready to use to
;	check the users clicks against
;---------------------------------------------------------------
FillBoard PROC
	mov eax, 0
	mov esi, offset MineLocations			; Get the first location in our MineLocations array
	mov ecx, lengthof MineLocations			; We need as many mines as the length of our MineLocations array 
	mov edx, 0
GetNums:
	mov eax, (BOARDSIZE*BOARDSIZE)			; Get a random number that corresponds with a space on the board
	call randomRange
	mov [esi], al							; Put the random number into our MineLocations array

	; Check to make sure the random number generated wasnt the location of the first click or any space around it (First click MUST be a 0 space)
	push eax
	call GetMouseClickOffset
	mov edx, eax
	pop eax

	cmp eax, edx			; Check space
	je GetNums

	sub edx, BOARDSIZE
	cmp eax, edx			; Check above space
	je GetNums	
	
	dec edx
	cmp eax, edx			; Check above and to left of space
	je GetNums	

	add edx, 2
	cmp eax, edx			; Check above and to right of space
	je GetNums	

	add edx, BOARDSIZE
	cmp eax, edx			; Check to right of space
	je GetNums

	sub edx, 2
	cmp eax, edx			; Check to left of space
	je GetNums	

	add edx, BOARDSIZE
	cmp eax, edx			; Check below and to left of space
	je GetNums

	inc edx
	cmp eax, edx			; Check below space
	je GetNums

	inc edx
	cmp eax, edx			; Check below and to right of space
	je GetNums

	; Check to make sure the random number generated wasnt a duplicate (Each mine must be in a unique location)
	cmp ecx, NUMOFMINES			; if ecx == NUMOFMINES, jump to SkipFirst (the first time around, we dont need to check because theres nothing to check against)
	je SkipFirst
	mov ebx, ecx				; Save our current count in ebx

	 ; We want this inner count to start at 0 and go to 9 (Becasue: for the Nth mine created, we 
	 ;	need to check it against mines 1->(N-1) to make sure it is not a duplicate of any of them)
	mov edx, lengthof MineLocations			
	sub edx, ecx
	mov ecx, edx 

	mov edi, offset MineLocations			; Each time, we will move from the first mine, toward the mine before the one just created
	mov al, [esi]							; Save the current mine location so we can check it against the rest
	CheckDup:
		cmp al, [edi]						; If we find that the mine just created was a duplicate, we need to try again...
		jne NoDup
			; If we get here, it was a duplicate and we must try again
		mov ecx, ebx
		jmp GetNums
	NoDup:
		inc edi
		loop CheckDup
		mov ecx, ebx
SkipFirst:
	inc esi
	loop GetNums

	; Now we have the 10 random mine locations. Put them on the board

	mov esi, offset MineLocations			; Starting element of mines array
	mov eax, 0
	mov ebx, 0
	mov ecx, lengthof MineLocations			; Will need to be some sort of variable indicating the number of mines to make
PutMines:									  
	mov edi, offset CountArray				; Starting element of board numbers array
	mov bl, [esi]
	add edi, ebx							; Move to the Nth element in the board numbers array (where the first mine will go)
	mov al, 0FFh							; Indicates a mine
	mov [edi], al
	inc esi									; Go to the next mine location
	loop PutMines

	; Now we need to go through each remaining location in the count-array and count how many mines are around them

	mov ecx, lengthof CountArray
	mov eax, 0						; Will hold offset of space around current space (above, below...) to be checked
	mov ebx, 0						; Will hold what is in that (^) space 
	mov edx, 0						; Will be used to find row/col #	
PutNums:
	mov SpaceCount, 0				; This will be our running count for the space (starts at 0 for each iteration of the loop)

	mov edx, ecx
	neg edx
	add edx, BOARDSIZE*BOARDSIZE		; edx will go from 0 to 99

	mov esi, offset CountArray
	add esi, edx
	mov al, [esi]
	cmp al, 0FFh
	je ENDPutNums					; If the current space is a mine, we dont care about it.
	
	mov esi, offset CountArray
	add esi, edx					; esi will now point at the space directly above the current space

	; DIRECTLY ABOVE
	cmp edx, (BOARDSIZE - 1)
	jle SkipUpper
		; If we get here, it means we are not on the top row of the board, and so we can check AT LEAST the space directly above the current space
	sub esi, BOARDSIZE
	mov bl, [esi]
	cmp bl, 0FFh				; Check for a mine 
	jne NoMineAbove
	inc SpaceCount			; If mine was found, increment the counter
NoMineAbove:

	; ABOVE AND TO THE LEFT
	mov ax, dx					; edx will always be smaller than a word so this is fine
	mov bl, BOARDSIZE
	div bl						; Divide our current position by BOARDSIZE
	cmp ah, 0					; If there was no remainder, then it was a multiple of 10 and so is on the left side of the board and so has no spaces to the left
	je SkipUpperLeft
		; If we get here, it means we are not on the left column or top row of the board, and so we can check AT LEAST the space above and to the left of the current space
	dec esi
	mov bl, [esi]
	inc esi						; Put esi back to where it was
	cmp bl, 0FFh				; Check for a mine 
	jne NoMineAboveAndToLeft
	inc SpaceCount			; If mine was found, increment the counter
NoMineAboveAndToLeft:
SkipUpperLeft:

	; ABOVE AND TO THE RIGHT
	mov ax, dx					; edx will always be smaller than a word so this is fine
	add ax, 1					; Because the right column will always be 19-99
	mov bl, BOARDSIZE
	div bl						; Divide our current position (minus 9) by 10
	cmp ah, 0					; If there was no remainder, then it was a multiple of 10 and so is on the right side of the board and so has no spaces to the right
	je SkipUpperRight
		; If we get here, it means we are not on the right column or top row of the board, and so we can check AT LEAST the space above and to the right of the current space
	inc esi
	mov bl, [esi]
	dec esi						; Put esi back to where it was
	cmp bl, 0FFh				; Check for a mine 
	jne NoMineAboveAndToRight
	inc SpaceCount				; If mine was found, increment the counter
NoMineAboveAndToRight:
SkipUpperRight:
	add esi, BOARDSIZE					; esi will now point to our original location no matter what
SkipUpper:

	; CHECK LEFT
	mov ax, dx					; edx will always be smaller than a word so this is fine
	mov bl, BOARDSIZE
	div bl						; Divide our current position by 10
	cmp ah, 0					; If there was no remainder, then it was a multiple of 10 and so is on the left side of the board and so has no spaces to the left
	je SkipLeft
		; If we get here, it means we are not on the left column of the board, and so we can check AT LEAST the space to the left of the current space
	dec esi
	mov bl, [esi]
	inc esi						; Put esi back to where it was
	cmp bl, 0FFh				; Check for a mine 
	jne NoMineToLeft
	inc SpaceCount				; If mine was found, increment the counter
NoMineToLeft:
SkipLeft:

	; CHECK RIGHT
	mov ax, dx					; edx will always be smaller than a word so this is fine
	add ax, 1					; Because the right column will always be 19-99
	mov bl, BOARDSIZE
	div bl						; Divide our current position (minus 9) by 10
	cmp ah, 0					; If there was no remainder, then it was a multiple of 10 and so is on the right side of the board and so has no spaces to the right
	je SkipRight
		; If we get here, it means we are not on the right column of the board, and so we can check AT LEAST the space to the right of the current space
	inc esi
	mov bl, [esi]
	dec esi						; Put esi back to where it was
	cmp bl, 0FFh				; Check for a mine 
	jne NoMineToRight
	inc SpaceCount				; If mine was found, increment the counter
NoMineToRight:
SkipRight:

	; DIRECTLY BELOW
	cmp edx, ((BOARDSIZE*BOARDSIZE) - BOARDSIZE)
	jge SkipLower
		; If we get here, it means we are not on the bottom row of the board, and so we can check AT LEAST the space directly below the current space
	add esi, BOARDSIZE			; esi will now point at the space directly below the current space
	mov bl, [esi]
	cmp bl, 0FFh				; Check for a mine 
	jne NoMineBelow
	inc SpaceCount				; If mine was found, increment the counter
NoMineBelow:

	; BELOW AND TO THE LEFT
	mov ax, dx					; edx will always be smaller than a word so this is fine
	mov bl, BOARDSIZE
	div bl						; Divide our current position by 10
	cmp ah, 0					; If there was no remainder, then it was a multiple of 10 and so is on the left side of the board and so has no spaces to the left
	je SkipLowerLeft
		; If we get here, it means we are not on the left column or bottom row of the board, and so we can check AT LEAST the space below and to the left of the current space
	dec esi
	mov bl, [esi]
	inc esi						; Put esi back to where it was
	cmp bl, 0FFh				; Check for a mine 
	jne NoMineBelowAndToLeft
	inc SpaceCount				; If mine was found, increment the counter
NoMineBelowAndToLeft:
SkipLowerLeft:

	; BELOW AND TO THE RIGHT
	mov ax, dx					; edx will always be smaller than a word so this is fine
	add ax, 1					; Because the right column will always be 19-99
	mov bl, BOARDSIZE
	div bl						; Divide our current position (minus 9) by 10
	cmp ah, 0					; If there was no remainder, then it was a multiple of 10 and so is on the right side of the board and so has no spaces to the right
	je SkipLowerRight
		; If we get here, it means we are not on the right column or bottom row of the board, and so we can check AT LEAST the space below and to the right of the current space
	inc esi
	mov bl, [esi]
	dec esi						; Put esi back to where it was
	cmp bl, 0FFh				; Check for a mine 
	jne NoMineBelowAndToRight
	inc SpaceCount				; If mine was found, increment the counter
NoMineBelowAndToRight:
SkipLowerRight:
	sub esi, BOARDSIZE			; esi will now point to our original location no matter what
SkipLower:

	; Put the number in its place
	mov al, SpaceCount
	mov [esi], al
ENDPutNums:
	;loop PutNums	; Cannot do because jump is too far. Replicated with below 2 instructions
	dec ecx
	jnz PutNums

	ret
FillBoard ENDP


;-------------------------------------------
; InitMouse
; Initialize console to receive mouse events
; Receives: Nothing
; Returns: Nothing
;-------------------------------------------
InitMouse PROC
	invoke GetStdHandle, STD_INPUT_HANDLE		; Get a handle to std_input
	mov rHnd, eax								
	mov eax, 0092h								;						02h                    10h                    80h
	invoke SetConsoleMode, rHnd, eax			; 92h comes from (ENABLE_LINE_INPUT OR ENABLE_MOUSE_INPUT OR ENABLE_EXTENDED_FLAGS. These values are declared in Windows.h but for whatever reason, the SmallWin.inc included in the Irvine32.inc does not have them.
	ret
InitMouse ENDP

;-------------------------------------------
; GetMouseClick
; Waits for and captures the users mouse click
; Receives: ebx=1 for showing clock,ebx=0 hides clock
; Returns: X coord of click in XClick
;          Y coord of click in YClick
;-------------------------------------------
GetMouseClick PROC
	mov rightClick, 3	; This will be used to only exit this procedure on a click. NOT on a mouse-movement
appContinue:
	cmp showClock, 1	;  hide or show the clock  
	jl noclock			; ebx=0 => no clock
	call ClockFunc
noclock:

;process 
;event happened 
;mouse event 
;press or release
;right or left 
	invoke GetNumberOfConsoleInputEvents, rHnd, OFFSET numEventsOccurred		; Gets the number of mouse/input events held in the buffer
	cmp numEventsOccurred, 0													; If there were no events raised, we dont need to do anything
	je appContinue	

	; If we are here, there were inputs of some kind
    invoke ReadConsoleInput, rHnd, ADDR eventBuffer, 1, ADDR numEventsRead			; Using addr to get address of local variable 
    movzx eax, eventBuffer.EventType
    cmp eax, MOUSE_EVENT								; We only care about mouse-events
    jne appContinue    

	cmp eventBuffer.Event.dwEventFlags, 0				; lets check to see if the mouse is clicked down or released 
	jne appContinue

    test eventBuffer.Event.dwButtonState, 2				; 2 is the value of RIGHTMOST_BUTTON_PRESSED event
	jz CheckLeftClick

	mov al,rightClick			; set current value as old
	mov oldClick,al
	mov rightClick, 1			; update current status
	jmp CheckClick				; make sure that the user click

CheckLeftClick:
	test eventBuffer.Event.dwButtonState, 1		; 1 is left click
	jz appContinue								; instead lets do, if its not a left click or right click we will continue on 
	mov al,rightClick							; chnage current value as old
	mov oldClick,al
	mov rightClick, 0

CheckClick:
	mov al,oldClick		; get the old click value
	cmp al,rightClick	; was there another button clicked, change?
	je appContinue		; if the user is still pressing the same button, continue * here is the key, if the same button is still pressed do nothing and continue

done:
	mov ax,eventBuffer.Event.dwMousePosition.X	; save current mouse position as the clicked position
	mov XClick, ax
	mov ax,eventBuffer.Event.dwMousePosition.Y
	mov YClick, ax
	ret
GetMouseClick ENDP

;-------------------------------------------
; ValidClicks 
; gets the location of a click on determines if it is on the board
; Receives: Xclick and Yclick
; Returns: 0 in eax for invalid. 1 for valid.
;-------------------------------------------
ValidClicks proc
	mov esi, offset Xcord		; array of vaild X cord 
	mov edi, offset Ycord		; array of vaild Y cord 
	mov ecx, lengthof Xcord   

searchXcord:

	mov ax, XClick  
	cmp al, [esi]      ; we are going to check if the X cord click is within our vaild click list
	je yValid		   ; if it is we are going to search the Y cord 

	inc esi
	Loop searchXcord 

	mov eax, 0
	ret				   ; if X cord was not found, we are going to stop search for vaild, we know it does not exist 

yValid:
	mov ecx, lengthof Ycord
searchYcord:

	mov ax, YClick 
	cmp al, [edi]     ; we are going to check if the Y cord click is within our vaild click list
	je found          ; if it is we know we have a vaild click 

	inc edi
	Loop searchYcord 

	mov eax, 0
	ret				  ; if not there are no vaild clicks

Found:
	mov eax, 1
	ret				  ; once we have vaild click we are done

ValidClicks endp 

;-----------------------------------------------
; ClockFunc
; Updates the clock
; Receives: Nothing
; Returns: Updates the timer
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

	mov dh, 6					; If the time HAS changed, update the clock...
	mov dl, 48
	call GoToXY

	mov ebx, eax				; Set the color of the timer
	mov eax, red + (gray * 16)
	call SetTextColor
	mov eax, ebx

	; Convert time to chars representing the decimal value of the timer
	inc timerDigit0
; Check low bit
	cmp timerDigit0, ':'
	jne AllBitsGood
	mov timerDigit0, '0'
	inc timerDigit1
; Check middle bit
	cmp timerDigit1, ':'
	jne AllBitsGood
	mov timerDigit1, '0'
	inc timerDigit2
; Check high bit
	cmp timerDigit2, ':'
	jne AllBitsGood
	mov timerDigit2, '0'
	mov timerDigit1, '0'
	mov timerDigit0, '0'
AllBitsGood:
	
	; Display the timer on the board
	mov eax, 0
	mov al, timerDigit2
	call GoToXY
	inc dl
	call WriteChar
	mov al, timerDigit1
	call GoToXY
	inc dl
	call WriteChar
	mov al, timerDigit0
	call GoToXY
	call WriteChar

NoUpdate:
	ret
ClockFunc ENDP

;-------------------------------------------
; GetMouseClickOffset
; Get the offset (*index) in the count/show array
;  of the users click. For example: if they clicked
;  on the 3rd element in the first row, this would
;  return 3
; Receives: XClick and YClick are filled
; Returns: Offset in eax
;-------------------------------------------
GetMouseClickOffset PROC USES ebx ecx edx
	mov eax, 0
	mov ebx, 0
	mov ecx, 0
	mov edx, 0
	
	mov bx, YClick					; Get actual row
	sub bx, (StartY + 2) 

	mov ax, XClick					; Get actual column
	sub ax, (StartX + 2)
	mov cx, 2	
	div cx							; Column will now be in ax
	
	mov cx, BOARDSIZE
	xchg ax, bx
	mul cx							; Because we are dealing with small numbers, we can ignore dx and assume the while product is in ax

	add ax, bx						; ax will now contain the offset of the click
	ret
GetMouseClickOffset ENDP

;-------------------------------------------------
; ClearSpace 
; This is what is called when a space is clicked. If the
;  clicked space contains a number (has adjacent mine(s)),
;  then that space and nothing else will be cleared.
; If The space contains a 0 (no adjacent mines), Then the space
;  and all surrounding 0-spaces as well as the surrounding
;  layer of numbered spaces will be cleared.
; If the space contains a mine, the mine will be revealed
;  and the game will end.
;
; Receives: X-coordinate of click in XClick
;			Y-coordinate of click in YClick
; Returns: Clears appopriate spaces on board by filling
;			the ShowArray with the correct values in the
;			the correct locations.
;-------------------------------------------------
ClearSpace PROC ;USES eax ebx ecx edx esi edi

	mov esi, offset CountArray
	mov edi, offset ShowArray
	mov eax, 0
	mov ebx, 0
	mov ecx, 0
	mov edx, 0

	call GetMouseClickOffset		; Gets the offset of the mouse click and puts it in eax

	add esi, eax					; the 'e' part of eax will be zero no matter what so this is ok (we are essentially adding ax to esi)
	add edi, eax

	mov edx, eax					; Will be used to find row/col #
	mov eax, 0						; Re-Clear everything 
	mov ebx, 0
	mov ecx, offset SpaceCheckStack

	; ESI and EDI are now set up and we can begin

	cmp rightClick, 1		; Was it a right click???
	jne CheckIfFlag
	mov bl, 254
	mov al, [edi]
	cmp al, 0Fh
	jne TryPlaceFlag
	mov [edi], bl			; It was already a flag and they right clicked so set it back
	ret
TryPlaceFlag:	
	cmp [edi], bl
	je PlaceFlag
	ret
PlaceFlag:
	mov bl, 0Fh
	mov [edi], bl			; Indicates a flag
	ret
	
CheckIfFlag:
	mov al, [edi]
	cmp al, 0Fh
	jne CheckIfMine
	ret

CheckIfMine:	
	mov al, [esi]
	cmp al, 0FFh
	jne CheckSpaces
	mov bl, 0FFh
	mov [edi], bl
	ret						; GAMEOVER. MINE CLICKED
	
CheckSpaces:
	mov edx, esi
	sub edx, offset CountArray

	mov edi, esi
	sub edi, offset CountArray
	add edi, offset ShowArray

	mov al, [esi]
	cmp al, 0FFh
	je ENDCheckSpaces					; If the current space is a mine, Skip it
	
	mov [edi], al		; It was a number, so put the count array value into show array
	
	cmp al, 0			; If it was a zero, we need to check everything around it. Else we do not
	jne ENDCheckSpaces
	
	
	; DIRECTLY ABOVE
	cmp edx, (BOARDSIZE - 1)
	jle SkipUpper
		; If we get here, it means we are not on the top row of the board, and so we can look at AT LEAST the space directly above the current space
	sub esi, BOARDSIZE
	
	call CheckStackForVal	
	cmp StackValFound, 1    
	je AboveAlreadyOnStack  

	mov [ecx], esi
	add ecx, 4
	inc SpaceCheckStackSize
AboveAlreadyOnStack:

	; ABOVE AND TO THE LEFT
	mov ax, dx					; edx will always be smaller than a word so this is fine
	mov bl, BOARDSIZE
	div bl						; Divide our current position by BOARDSIZE
	cmp ah, 0					; If there was no remainder, then it was a multiple of 10 and so is on the left side of the board and so has no spaces to the left
	je SkipUpperLeft
		; If we get here, it means we are not on the left column or top row of the board, and so we can check AT LEAST the space above and to the left of the current space
	dec esi
	
	call CheckStackForVal	
	cmp StackValFound, 1    
	je AboveAndToLeftAlreadyOnStack  

	mov [ecx], esi
	add ecx, 4
	inc SpaceCheckStackSize
	
AboveAndToLeftAlreadyOnStack:
	inc esi						; Put esi back to where it was
SkipUpperLeft:

	; ABOVE AND TO THE RIGHT
	mov ax, dx					; edx will always be smaller than a word so this is fine
	add ax, 1					; Because the right column will always be 19-99
	mov bl, BOARDSIZE
	div bl						; Divide our current position (minus 9) by 10
	cmp ah, 0					; If there was no remainder, then it was a multiple of 10 and so is on the right side of the board and so has no spaces to the right
	je SkipUpperRight
		; If we get here, it means we are not on the right column or top row of the board, and so we can check AT LEAST the space above and to the right of the current space
	inc esi
	
	call CheckStackForVal	
	cmp StackValFound, 1    
	je AboveAndToRightAlreadyOnStack  
	
	mov [ecx], esi
	add ecx, 4
	inc SpaceCheckStackSize
	
AboveAndToRightAlreadyOnStack:
	dec esi						; Put esi back to where it was
SkipUpperRight:
	add esi, BOARDSIZE					; esi will now point to our original location no matter what
SkipUpper:

	; CHECK LEFT
	mov ax, dx					; edx will always be smaller than a word so this is fine
	mov bl, BOARDSIZE
	div bl						; Divide our current position by 10
	cmp ah, 0					; If there was no remainder, then it was a multiple of 10 and so is on the left side of the board and so has no spaces to the left
	je SkipLeft
		; If we get here, it means we are not on the left column of the board, and so we can check AT LEAST the space to the left of the current space
	dec esi
	
	call CheckStackForVal	
	cmp StackValFound, 1    
	je LeftAlreadyOnStack  
	
	mov [ecx], esi
	add ecx, 4
	inc SpaceCheckStackSize
	
LeftAlreadyOnStack:
	inc esi						; Put esi back to where it was
SkipLeft:

	; CHECK RIGHT
	mov ax, dx					; edx will always be smaller than a word so this is fine
	add ax, 1					; Because the right column will always be 19-99
	mov bl, BOARDSIZE
	div bl						; Divide our current position (minus 9) by 10
	cmp ah, 0					; If there was no remainder, then it was a multiple of 10 and so is on the right side of the board and so has no spaces to the right
	je SkipRight
		; If we get here, it means we are not on the right column of the board, and so we can check AT LEAST the space to the right of the current space
	inc esi
	
	call CheckStackForVal	
	cmp StackValFound, 1    
	je RightAlreadyOnStack  
	
	mov [ecx], esi
	add ecx, 4
	inc SpaceCheckStackSize
	
RightAlreadyOnStack:
	dec esi						; Put esi back to where it was
SkipRight:

	; DIRECTLY BELOW
	cmp edx, ((BOARDSIZE*BOARDSIZE) - BOARDSIZE)
	jge SkipLower
		; If we get here, it means we are not on the bottom row of the board, and so we can check AT LEAST the space directly below the current space
	add esi, BOARDSIZE			; esi will now point at the space directly below the current space
	
	call CheckStackForVal	
	cmp StackValFound, 1    
	je BelowAlreadyOnStack  
	
	mov [ecx], esi
	add ecx, 4
	inc SpaceCheckStackSize
BelowAlreadyOnStack:

	; BELOW AND TO THE LEFT
	mov ax, dx					; edx will always be smaller than a word so this is fine
	mov bl, BOARDSIZE
	div bl						; Divide our current position by 10
	cmp ah, 0					; If there was no remainder, then it was a multiple of 10 and so is on the left side of the board and so has no spaces to the left
	je SkipLowerLeft
		; If we get here, it means we are not on the left column or bottom row of the board, and so we can check AT LEAST the space below and to the left of the current space
	dec esi
	
	call CheckStackForVal	
	cmp StackValFound, 1    
	je BelowAndToLeftAlreadyOnStack  
	
	mov [ecx], esi
	add ecx, 4
	inc SpaceCheckStackSize
	
BelowAndToLeftAlreadyOnStack:
	inc esi						; Put esi back to where it was
SkipLowerLeft:

	; BELOW AND TO THE RIGHT
	mov ax, dx					; edx will always be smaller than a word so this is fine
	add ax, 1					; Because the right column will always be 19-99
	mov bl, BOARDSIZE
	div bl						; Divide our current position (minus 9) by 10
	cmp ah, 0					; If there was no remainder, then it was a multiple of 10 and so is on the right side of the board and so has no spaces to the right
	je SkipLowerRight
		; If we get here, it means we are not on the right column or bottom row of the board, and so we can check AT LEAST the space below and to the right of the current space
	inc esi
	
	call CheckStackForVal	
	cmp StackValFound, 1    
	je BelowAndToRightAlreadyOnStack  
	
	mov [ecx], esi
	add ecx, 4
	inc SpaceCheckStackSize
	
BelowAndToRightAlreadyOnStack:
	dec esi						; Put esi back to where it was
SkipLowerRight:
	sub esi, BOARDSIZE			; esi will now point to our original location no matter what
SkipLower:
ENDCheckSpaces:

	cmp SpaceCheckStackSize, 0
	jle DoneClearingSpace
	
	sub ecx, 4
	mov esi, [ecx]
	mov ebx, 0
	mov [ecx], ebx
	dec SpaceCheckStackSize
	
	jmp CheckSpaces
DoneClearingSpace:
	ret
ClearSpace ENDP

;---------------------------------------
; CheckStackForVal
; Used by the ClearSpace Procedure to see
;  if a given space has already been checked
;  or is schedules to be checked
; Receives: offset of space in esi
;           offset of SpaceCheckStack in ecx
; Returns: 1 in StackValFound if space has been or will be checked
;		   0 otherwise
;---------------------------------------
CheckStackForVal PROC USES eax ebx ecx esi 
	mov eax, esi						; Val we are looking for
	mov esi, offset SpaceCheckStack		; Start of SpaceCheckStack DD array
	mov ecx, 0
	mov cl, SpaceCheckStackSize		; # of elements in SpaceCheckStack DD array
	
	; Check to see if the space is already cleared
	push eax
	sub eax, offset CountArray
	add eax, offset ShowArray
	mov bl, 254
	cmp [eax], bl
	je PreCheckStackLBL
	mov StackValFound, 1	; If the space contains anything besides a 254, it has already been checked and we don't need ot worry about it
	pop eax
	ret

	; Check to see if the space is already on the 'to be checked' stack
PreCheckStackLBL:
	pop eax
	cmp ecx, 0
	jg CheckStackLBL
	mov StackValFound, 0
	ret

CheckStackLBL:
	cmp eax, [esi]
	je ElementFoundOnStack
	add esi, 4
	loop CheckStackLBL
	
	mov StackValFound, 0
	ret	
	
ElementFoundOnStack:
	mov StackValFound, 1
	ret
	
CheckStackForVal ENDP

;----------------------------------------------
; SplashScreen
; Displays a fun splash screen to start the game
; Receives: nothing
; Returns: nothing
;----------------------------------------------
SplashScreen PROC USES eax edx
	mov eax, 100
	mov edx, offset minesweeper1
	call WriteString
	call crlf
	call Delay
	mov edx, offset minesweeper2
	call WriteString
	call crlf
	call Delay
	mov edx, offset minesweeper3
	call WriteString
	call crlf
	call Delay
	mov edx, offset minesweeper4
	call WriteString
	call crlf
	call Delay
	mov edx, offset minesweeper5
	call WriteString
	call crlf
	call Delay

	mov ecx, 20
SplashScreenLBL:
	call crlf
	loop SplashScreenLBL

	mov edx, offset createdBy
	call WriteString
	call crlf
	ret
SplashScreen ENDP

;***********************************************************************
;--------------------------------------------------------
; TEST DISPLAY!!!
;--------------------------------------------------------
;***********************************************************************
TestProc PROC USES eax ecx edx
	
	mov esi, offset CountArray
	mov eax, red + (gray * 16)
	call SetTextColor

	mov currentY, STARTY
	mov dh, currentY
	mov dl, STARTX + 30
	call GotoXY

	mov edx, offset strCount
	call WriteString
	mov edx, offset strSpace
	mov ecx, 6
Spaces1:
	call WriteString
	loop Spaces1

	mov eax, yellow + (gray * 16)
	call SetTextColor
	mov edx, offset strFace
	call WriteString
	
	mov edx, offset strSpace
	mov ecx, 7
Spaces2:
	call WriteString
	loop Spaces2

	cmp lastTimeSeconds, 0			; Only need to draw this the first time. Once the timer is past 0, the ClockFunc will take care of this
	jg DoNotDrawTimer
	mov eax, red + (gray * 16)
	call SetTextColor
	mov edx, offset strTime
	call WriteString
DoNotDrawTimer:
	
	inc currentY
	mov dh, currentY
	mov dl, STARTX + 30
	call GotoXY

	mov eax, lightgray + (gray * 16)
	call SetTextColor
	mov edx, offset strSpace

	mov eax, topLeft
	call WriteChar

	mov ecx, ((2*BOARDSIZE)+1)
	mov eax, horizontal
Top:
	call WriteChar
	loop Top
	
	mov eax, topRight
	call WriteChar
	
	inc currentY
	mov dh, currentY
	mov dl, STARTX + 30
	call GotoXY

	mov ecx, BOARDSIZE


Contents:
	mov eax, vertical
	call WriteChar
	push ecx
	
	call PrintContents

	pop ecx
	mov eax, vertical
	call WriteChar
	
	inc currentY
	mov dh, currentY
	mov dl, STARTX + 30
	call GotoXY

	loop Contents
	
	mov eax, bottomLeft
	call WriteChar
	mov eax, horizontal
	mov ecx, ((2*BOARDSIZE)+1)
Bottom:
	call WriteChar
	loop Bottom

	mov eax, bottomRight
	call WriteChar
	
	inc currentY
	mov dh, currentY
	mov dl, STARTX + 30
	call GotoXY

	mov eax, lightgray
	call SetTextColor

	ret
TestProc ENDP


END MAIN
