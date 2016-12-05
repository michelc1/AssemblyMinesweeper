
INCLUDE Irvine32.inc

topLeft = 201
topRight = 187
bottomLeft = 200
bottomRight = 188
horizontal = 205
vertical = 186
tile = 35
mines = 10


;-------------------------------
; Colors for each number
; 1 = Blue
; 2 = Green
; 3 = Red
; 4 = Purple
; 5 = Maroon
; 6 = Turquoise
; 7 = Black
; 8 = Gray
;-------------------------------

.data
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
	SpaceCheckStack db 81 DUP(0)	; Used to clear spaces on the board after a click
	SpaceCheckStackSize db 0		; Same^
	MineLocations db 10 DUP(?) 
	SpaceCount db 0
	currentY db ?
	Xcord db 32,34,36,38,40,42,44,46,48		; All valid X coordinates of the 9x9 board
	Ycord db 8,9,10,11,12,13,14,15,16		; All valid Y coordinates of the 9x9 board
	msgNotFound db "This is not a vaild click X Cord  " , 0		;FOR TESTING CLICKS******
	msgNotFound1 db "This is not a vaild click Y Cord  " , 0	; FOR TESTING CLICKS******
	msgVaildClick db "Congrats, this is a vaild click  ", 0		; FOR TESTING CLICKS******

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

	Score		db 10		; score 
	scoreArray	db 91 DUP(0); array for saving the current state of the flags

	; These are all used for the timer
	initialTime dd 0			; Time when the program starts
	lastTimeSeconds dd 0		; Last time that was put onto the clock (in seconds)
	clockMax dd 100				; What the clock will start at

	clrLine db "          ",0	;;;; used only to debug the mouse position

.code
main PROC
	invoke SetConsoleTitle, OFFSET CMDTitle		; Sets the title of the console window
	
	invoke GetStdHandle, STD_OUTPUT_HANDLE
	invoke SetConsoleCursorInfo, eax, OFFSET cursorInfo		; Make the cursor invisible (no more ugly blinky thing)

	call InitMouse  ; initialize the mouse

	; Initialize the timer
	call GetMseconds
	mov initialTime, eax
		
	call Randomize				; So we can get random numbers for mine location generation
	STARTX = 30					; The X coordinate of the top left corner of the board
	STARTY = 6					; The Y coordinate of the top left corner of the board
	BOARDSIZE = 9				; Width of board (will need to make this changeable in game somehow...)
	NUMOFMINES = 10

	; Wait here for first mouse click... Once clicked, capture it, start the clock and continue	
	call FillBoard		;*****Need to update this to not alow mines on first click location
	call DrawBoard
	call PrintScore					; print current score
	mov showClock, 0				; hides clock
	call GetMouseClick				; pause until a click is received

	;**********JUST HERE FOR TESTING***********************
	mov edx, 0				;
	call Gotoxy				;
	mov edx,offset clrLine	;
	call WriteString		;
	mov edx, 0				;
	call Gotoxy				;
	movzx eax,XClick		;
	call WriteDec			;
	mov al,','				;
	call WriteChar			;
	movzx eax,YClick		;
	call WriteDec			;
	mov al,':'				;
	call WriteChar			;
	movzx eax,rightClick	;
	call WriteDec			;
	;;;;;;;;;; }
	call crlf
	call ValidClicks
	;*********************************

	mov showClock, 1				; show clock
	

MainLoop:
	call DrawBoard
	call PrintScore				; print current score
								; Wait for mouse click. This is where the program will sit for most of the time it is running. Because of this, the GetMouseClick procedure also controls the clock.
	call GetMouseClick			; Gets mouse click and puts the X-coord in XClick, and Y-coord YClick

	;*************Used only for debugging the mouse position get the x and y coord. *************
	mov edx, 0				;
	call Gotoxy				;
	mov edx,offset clrLine	;
	call WriteString		;
	mov edx, 0				;
	call Gotoxy				;
	movzx eax,XClick		;
	call WriteDec			;
	mov al,','				;
	call WriteChar			;
	movzx eax,YClick		;
	call WriteDec			;
	mov al,':'				;
	call WriteChar			;
	movzx eax,rightClick	;
	call WriteDec			;
	call crlf 
	;*************************************

	call ValidClicks
	
	cmp eax,0			; check if the user clicked on a valid position
	je	notValid		; if he didn't, then keep waiting
	cmp rightClick,1	; otherwise, check if the user did a right click
	jne notValid		; if not, keep waiting
	call updateScore	; otherwise, update flags
notValid:
	; ***TODO*** Update ShowArray based on users click
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
	
	mov esi, offset CountArray
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
	call AssignColor

	call WriteChar
	call WriteString
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
	cmp al, 255
	je MineSet
	cmp al, 0
	je ZeroSet
	cmp al, 1
	je OneSet
	cmp al, 2
	je TwoSet
	cmp al, 3
	je ThreeSet
	cmp al, 4
	je FourSet
	cmp al, 0
	jl CharIsSet
	cmp al, 8
	jg CharIsSet
	add al, 48
	jmp CharIsSet

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

MineSet:
	mov eax, black + (gray * 16)
	call SetTextColor
	mov al, 42
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



;---------------------------------------------------------------
; DrawBoardTest:
; Draws the board
; Receives: Assumes STARTY, STARTX, BOARDSIZE, and ShowArray exist
; Returns: nothing
;---------------------------------------------------------------
;DrawBoardTest PROC
;	mov eax, 0					; Initialize
;	mov edx, 0					; Initialize
;	mov dh, STARTY				; dh is the Y coordinate for GoToXY Procedure
;	mov dl, STARTX				; dl is the X coordinate for GoToXY Procedure
;
;	mov ecx, BOARDSIZE			; The board will need 'BOARDSIZE' number of rows
;	mov esi, offset CountArray  ; *********FOR TESTING********* Should really be printarray 
;
;; Do the actual printing
;
;PrintBoardOuter:
;	mov ebx, ecx				; Save the outer counter
;	mov ecx, BOARDSIZE			; Each row will need 'BOARDSIZE' number of columns
;PrintBoardInner:
;	call GoToXY					; Go to the coordinates that this particular square will be printed in
;	mov al, [esi]				; Load the character to be printed
;
;	; FOR TESTING!!!
;	cmp al, 0
;	jl Donezooo
;	cmp al, 8
;	jg Donezooo
;	add al, 48
;	
;Donezooo:
;	inc esi						; Go to the next character
;	call writeChar				; Print the character that goes in a space
;	inc dl						; Get ready to go to the next space...
;
;	call GoToXY					; Go to the next space over...
;	mov al, Space				; Load a space character (only used to make the board look neater)
;	call writeChar				; Print the space
;	inc dl						; Get ready to go to the next location...
;	loop PrintBoardInner
;
;	inc dh						; After each full row, increment to the next column...
;	mov dl, STARTX				; And reset the row start location
;	mov ecx, ebx				; Get our counter back
;	loop PrintBoardOuter
;
;	ret
;DrawBoardTest ENDP

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
; Returns: Nothing
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

jmp notFound     ; if X cord was not found, we are going to stop search for vaild, we know it does not exist 

yValid:
mov ecx, lengthof Ycord
searchYcord:

	mov ax, YClick 
	cmp al, [edi]     ; we are going to check if the Y cord click is within our vaild click list
	je found          ; if it is we know we have a vaild click 

	inc edi
Loop searchYcord 

mov edx, offset msgNotFound1      ; if not there are no vaild clicks
call writestring
mov ax, Yclick 
call writedec
call crlf 
mov eax,0			; click was not valid
jmp byebye

Found:

mov edx, offset msgVaildClick     
call writestring
mov eax,1			; click was valid

jmp byebye      ; once we have vaild click we are done

notFound:
mov edx, offset msgNotFound
call writestring
mov ax, Xclick 
call writedec
call crlf 
mov eax,0			;  click was not valid
jmp byebye   ; no vaild clicks we are done 

byebye:
ret
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

	;cmp eax, clockMax
	;je END THE GAME BECAUSE TIME IS UP!!

NoUpdate:
	ret
ClockFunc ENDP

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
	;SpaceCheckStack db 81 DUP(0)
	;SpaceCheckStackSize db 0
	;XClick dw ?
	;YClick	dw ?
	
	mov esi, offset CountArray
	mov edi, offset ShowArray
	mov eax, 0
	mov ebx, 0
	mov ecx, 0
	mov edx, 0

	ret
ClearSpace ENDP

;--------------------------------------------------------
; Update Score
; Updates the flag score based upon click
; X-coordinate and Y coordinate
; New updated Score 
;--------------------------------------------------------
UpdateScore PROC
	mov eax,BOARDSIZE			; load the board width
	mov bx,YClick			; get Y location of the click
	                        
							


	sub bx,STARTY+2			

	                         ; then lets change it to the postion in the array instead 
							 ; positiony= (YClik-STARTY-2)

	mul ebx						; multiply new Y coordinate in the array *BOARDSIZE

	mov ebx,eax					; store in ebx

	mov ax,XClick			; get X location of the click

	sub ax,STARTX+2			   ; then lets change it to the postion in the array instead 
							 ; positionx= (XClik-STARTX-2)

	shr eax,1					; positionx= (XClik-STARTX-2)/2
	                             ; we can do the division by sifting the bit 

	add ebx,eax					; then we have to add the X location to get the offset in the scoreArray

	mov al,scoreArray[ebx]		; get the score
	cmp al,1					; is there a flag already placed ?
	je clearFlag				; if click is made on a lcation where there is already a score
	                            ; we are going to clear it 

setFlag:						; otherwise, set a flag
	cmp Score,0					; do we hace flags left?
	je  byebye				; if so, bye 

	inc al						; if no, increment so we get al=1

	mov scoreArray[ebx],al		;  now we set the flag
	dec Score					; we used a flag, score gets decreased 
	jmp byebye				; byebye 

clearFlag:
	dec al						; decrement so we get al=0
	mov scoreArray[ebx],al		; clear the flag
	inc Score					; since we've cleared a flag, we increment the count	
byebye:
	ret
UpdateScore ENDP

;--------------------------------------------------------
; Print the score at the top left of the board
; Receives: Number of non used flags in Score
; Returns:  Nothing
;--------------------------------------------------------
PrintScore PROC
	mov dl, STARTX				; go to the top left (3,3)
	mov dh, STARTY				; 
	call Gotoxy					;
	mov eax, red + (gray * 16)	; set same color as the board
	call SetTextColor
	mov edx,offset strCount
	call WriteString
	mov dl, STARTX				; go to the top left (3,3)
	mov dh, STARTY				; 
	movzx eax,Score				; get the current score into eax
	cmp eax,10					; check if we need to print 1 or 2 digits
	jl  onedig
	add dl,1					; if the number is >=10, we leave one zero intact in the 3 digit count
	jmp movecur
onedig:
    add dl,2					; if the number is <10, we leave two zeros intact in the 3 digit count
movecur:
	call Gotoxy					; move the cursor
	call WriteDec				; display it
	ret
PrintScore ENDP

;--------------------------------------------------------
; TEST TEST TEST TEST TEST TEST
;--------------------------------------------------------
TestProc PROC
	mov eax, 0
	mov esi, offset Xcord
	mov ecx, lengthof Xcord
LBLBLBLBLBL:
	mov al, [esi]
	call WriteInt
	inc esi
	loop LBLBLBLBLBL
	ret
TestProc ENDP

END MAIN
