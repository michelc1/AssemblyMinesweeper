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
	welcome1 db "     __      __  ___   _       ___    ___    __  __   ___     _____    ___  ", 0
	welcome2 db "     \ \    / / | __| | |     / __|  / _ \  |  \/  | | __|   |_   _|  / _ \ ", 0
	welcome3 db "      \ \/\/ /  | _|  | |__  | (__  | (_) | | |\/| | | _|      | |   | (_) |", 0
	welcome4 db "       \_/\_/   |___| |____|  \___|  \___/  |_|  |_| |___|     |_|    \___/ ", 0
	minesweeper1 db "    __  ___ ____ _   __ ______ _____ _       __ ______ ______ ____   ______ ____ ", 0
	minesweeper2 db "   /  |/  //  _// | / // ____// ___/| |     / // ____// ____// __ \ / ____// __ \", 0
	minesweeper3 db "  / /|_/ / / / /  |/ // __/   \__ \ | | /| / // __/  / __/  / /_/ // __/  / /_/ /", 0
	minesweeper4 db " / /  / /_/ / / /|  // /___  ___/ / | |/ |/ // /___ / /___ / ____// /___ / _, _/ ", 0
	minesweeper5 db "/_/  /_//___//_/ |_//_____/ /____/  |__/|__//_____//_____//_/    /_____//_/ |_|  ", 0
	difficulty0 db "               Choose Difficulty:", 0
	difficulty1 db "               ",218, 24 DUP(196), 191," ",218, 24 DUP(196), 191, 0
	difficulty2 db "               |                        | |                        |", 0
	
	difficulty3 db "               |          ", 0
	difficulty4 db "EASY", 0
	difficulty5 db "          | |          ", 0
	difficulty6 db "HARD", 0
	difficulty7 db "          |", 0
	
	difficulty8 db "               ",192, 24 DUP(196), 217," ",192, 24 DUP(196), 217, 0
	createdBy db "Created by: Darrien Kennedy, Chris Michel and Alex Robbins", 0

	youWin1 db "           __   __ ___   _   _  __      __ ___  _  _  _ ", 0
	youWin2 db "           \ \ / // _ \ | | | | \ \    / /|_ _|| \| || |", 0
	youWin3 db "            \ V /| (_) || |_| |  \ \/\/ /  | | | .` ||_|", 0
	youWin4 db "             |_|  \___/  \___/    \_/\_/  |___||_|\_|(_)", 0

	youLose1 db "           __   __ ___   _   _   _     ___   ___  ___ ", 0
	youLose2 db "           \ \ / // _ \ | | | | | |   / _ \ / __|| __|", 0
	youLose3 db "            \ V /| (_) || |_| | | |__| (_) |\__ \| _| ", 0
	youLose4 db "             |_|  \___/  \___/  |____|\___/ |___/|___|", 0

	helpInfo1 db "HELP:", 0
	helpInfo2 db "-Left-click spaces to reveal a number or a mine", 0
	helpInfo3 db "-Right-click to place flags on spaces you think are safe", 0
	helpInfo4 db "-Right-click a flag again to remove it", 0
	helpInfo5 db "-Numbers or dots indicate the number of mines adjacent", 0
	helpInfo52 db "   to a space (dots are equal to 0)", 0
	helpInfo6 db "-Left-Clicking a mine will end the game in a loss", 0
	helpInfo7 db "-Win by clearing all the spaces that are not mines", 0
	helpInfo8 db "-Click the smiley face to start a new game", 0
	helpInfo9 db "Good Luck!", 0

	timerDigit0 db '0'		; Used to display timer
	timerDigit1 db '0'		; Used to display timer
	timerDigit2 db '0'		; Used to display timer
	strTime db "000",0		; Used to INITIALLY display timer
	strCount db "000",0		; Used to INITIALLY display flag count
	strFace db ":)",0
	msgNewGame db "Play Again? (Y/N): ",0
	Space db " "
	strSpace db " ",0
	ShowArray db 225 DUP(254)
	CountArray db 225 DUP(0)
	
	SpaceCheckStack dd 225 DUP(0)	; Used to clear spaces on the board after a click
	SpaceCheckStackSize db 0		; Same^
	StackValFound db 0
	
	MineLocations db 35 DUP(?) 
	SpaceCount db 0
	currentY db ?
	Xcord db 32,34,36,38,40,42,44,46,48,50,52,54,56,58,60		; All valid X coordinates of the 9x9/15x15 board
	Ycord db 8,9,10,11,12,13,14,15,16,17,18,19,20,21,22		; All valid Y coordinates of the 9x9/15x15 board

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

	Score		db 10		; score (flag count)
	GameOver	db 0		; 1 if the game just finished, 0 if not

	; These are all used for the timer
	initialTime dd 0			; Time when the program starts
	lastTimeSeconds dd 0		; Last time that was put onto the clock (in seconds)

	BOARDSIZE_B db 0			; BYTE
	BOARDSIZE_D dd 0			; DWORD
	BOARDSIZESQUARED dd 0		; DWORD
	BOARDSIZETEMP dd 0			; DWORD
	NUMOFMINES dd 0				; DWORD

	splashScreenTimer dd 100	; The first time the game opens, the splash screen will move slow. After that it will be fast

	winCount db 0

	helpIsDisplayed db 0			; Whether or not the help page is displayed
	helpButton1 db " ", 218, 6 DUP(196), 191, 0
	helpButton2 db " | HELP |", 0
	helpButton3 db " ", 192, 6 DUP(196), 217, 0

	hideButton db " | HIDE |", 0

	SmileReset db 0			; Indicates if the smiley has been pressed to reset the game

.code
main PROC
	invoke SetConsoleTitle, OFFSET CMDTitle		; Sets the title of the console window

	call InitMouse			; initialize the mouse

	call Randomize				; So we can get random numbers for mine location generation
	STARTX = 30					; The X coordinate of the top left corner of the board
	STARTY = 6					; The Y coordinate of the top left corner of the board

StartGame:
	mov eax, 0
	call SetTextColor		; So screen will clear as black
	call clrScr

	invoke GetStdHandle, STD_OUTPUT_HANDLE
	invoke SetConsoleCursorInfo, eax, OFFSET cursorInfo		; Make the cursor invisible (no more ugly blinky thing)

	mov showClock, 0

	call SplashScreen
WaitForSplashScreenClick:
	call GetMouseClick
	call SplashScreenClick
	cmp eax, 0
	je WaitForSplashScreenClick
	cmp eax, 1
	jne ChoseHard
	mov BOARDSIZE_B, 9
	mov BOARDSIZE_D, 9
	mov BOARDSIZESQUARED, 81
	mov NUMOFMINES, 10 
	jmp GameModeMade
ChoseHard:
	mov BOARDSIZE_B, 15
	mov BOARDSIZE_D, 15
	mov BOARDSIZESQUARED, 225
	mov NUMOFMINES, 35 
GameModeMade:
	mov eax, 0
	call SetTextColor		; So screen will clear as black
	call ClrScr
	
	call GetMseconds		; Initialize the timer
	mov initialTime, eax
		
	call initializeGame

TryAgain:	
	call DrawBoard
	call PrintScore					; print current score
	call GetMouseClick				; Pause until the first click is received
	call ValidClicks

	cmp SmileReset, 1			; Reset the game if smiley is clicked
	je StartGame

	cmp eax, 1
	jne TryAgain
	cmp rightClick, 1				; If the 1st click was a right click, the board will not be made	
	je SkipFillBoard	
	call FillBoard
	;;;call TestProc					; *******UNCOMMENT FOR TESTING*******
SkipFillBoard:	
	call ClearSpace	
	cmp rightClick, 1				; We only want to make the board once a valid left click is received
	je TryAgain

	mov showClock, 1				; show clock

	call DrawBoard
MainLoop:
	call PrintScore				; print current score
								; Wait for mouse click. This is where the program will sit for most of the time it is running. Because of this, the GetMouseClick procedure also controls the clock.
	call GetMouseClick			; Gets mouse click and puts the X-coord in XClick, and Y-coord YClick

	call ValidClicks
	
	cmp SmileReset, 1			; Reset the game if smiley is clicked
	je StartGame

	cmp eax,0			; check if the user clicked a valid position
	je	MainLoop		; if he didn't, then keep waiting
	call ClearSpace	

	call DrawBoard
	call IsGameOver

	cmp GameOver, 0			; Has the game been lost
	je MainLoop				; If not play game

	cmp GameOver, 1
	jne GameWonDontShowMines
	call showMines			; Game is now over lets show the mines
	call YouLoseDisplay
	jmp GameWasLostSkipWonMsg
GameWonDontShowMines:
	call YouWinDisplay
GameWasLostSkipWonMsg:
	mov eax, white + (black* 16) ; set the color of playagain 
	call SetTextColor

playAgain:
	mov dl,0
	mov dh,23
	call GotoXY

	mov edx,offset msgNewGame		; prompts the user for a new game
	call WriteString

	call ReadChar

	cmp al,'y'
	je StartGame
	cmp al,'Y'
	je StartGame
	cmp al,'n'
	je byebyeMain
	cmp al,'N'
	je byebyeMain
	jmp playAgain
byebyeMain:
	call ClrScr
	Invoke ExitProcess, 0
main ENDP

;----------------------------------
; IsGameOver
; Checks to see if the game has been won
; Receives: nothing
; Returns: 2 in GameOver if game was won
;----------------------------------
IsGameOver PROC uses eax ebx ecx edx edi esi
	mov ebx, 0
	mov esi, offset ShowArray
	mov ecx, BOARDSIZESQUARED
	mov eax, 0
	mov winCount, 0


EndGameCheck:
	mov bl, [esi]
	cmp bl, 0Fh
	je WinCheck
	cmp bl, 254
	je WinCheck
	jmp BotOfEndGameLoop

WinCheck:
	mov edi, offset MineLocations
	push ecx
	mov edx, esi
	sub edx, offset showArray
	mov ecx, NUMOFMINES
MineInLocationCheck:
	mov bl, [edi]
	cmp dl, bl		; check if a mine occupies the position
	je MineUnder
	inc edi
	loop MineInLocationCheck

	pop ecx			; take from the stack so the program doesn't crash
	ret				; if a tile has not been cleared and does not have a mine under
					; then continue the game

MineUnder:
	pop ecx			; take the ecx value from the stack

BotOfEndGameLoop:
	inc esi
	loop EndGameCheck

Win:
	mov GameOver, 2

	ret
IsGameOver ENDP


;----------------------------------
; initializeGame
; Initializes every variable used by the program
; nothing 
; iitailazes values 
;----------------------------------
initializeGame PROC 


; garabage previous games values so now we are going to make sure everthing is initialized properly 

	mov timerDigit0,'0'
	mov timerDigit1,'0'
	mov timerDigit2,'0'

	mov ecx, lengthof ShowArray		; Always want to clear the whole thing
	mov edi, offset ShowArray
	mov al, 254
l1:
	mov [edi],al
	inc edi
	loop l1

	mov ecx, lengthof CountArray		; Always want to clear the whole thing
	mov edi,offset CountArray
	mov al,0
l2:
	mov [edi],al
	inc edi
	loop l2
	
	mov ecx, lengthof SpaceCheckStack	; Always want to clear the whole thing
	mov edi,offset SpaceCheckStack
	mov al,0
l3:
	mov [edi],al
	inc edi
	loop l3
	
	mov SpaceCheckStackSize,0		
	mov StackValFound,0
	
	mov ecx, lengthof MineLocations		; Always want to clear the whole thing
	mov edi,offset MineLocations 
	mov al,0
l4:
	mov [edi],al
	inc edi
	loop l4

	mov SpaceCount,0

	mov showClock,0

	mov helpIsDisplayed, 0

	mov SmileReset, 0

	mov al, BYTE PTR NUMOFMINES
	mov Score,al		
	mov GameOver,0

	mov initialTime,0
	mov lastTimeSeconds,0
	ret
initializeGame ENDP


;----------------------------------
; DrawBoard
; Draws the board layout to the console 
; Recieves: Nothing
; Returns: An empty minesweeper board
; Uses: eax ecx edx
;----------------------------------
DrawBoard PROC USES eax ecx edx
	mov dx, 0100h
	call GoToXY
	mov eax, lightGray
	call SetTextColor
	mov edx, offset helpButton1
	call WriteString
	call crlf

	mov edx, offset hideButton
	cmp helpIsDisplayed, 1
	je CloseHelpPage
	mov edx, offset helpButton2
CloseHelpPage:
	call WriteString
	call crlf

	mov edx, offset helpButton3
	call WriteString
	call crlf


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
	cmp BOARDSIZE_D, 9
	je Spaces1
	add ecx, 6
Spaces1:
	call WriteString
	loop Spaces1

	mov eax, yellow + (gray * 16)
	call SetTextColor
	mov edx, offset strFace
	call WriteString
	
	mov edx, offset strSpace
	mov ecx, 7
	cmp BOARDSIZE_D, 9
	je Spaces2
	add ecx, 6
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
	
	mov eax, BOARDSIZE_D
	mov BOARDSIZETEMP, eax
	add BOARDSIZETEMP, eax
	inc BOARDSIZETEMP
	mov ecx, BOARDSIZETEMP	; BOARDSIZE*2 + 1
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

	mov ecx, BOARDSIZE_D

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
	mov ecx, BOARDSIZETEMP	; hasnt changed yet, so its still BOARDSIZE*2 + 1
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
	mov ecx, BOARDSIZE_D
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
	mov ecx, NUMOFMINES						; We need as many mines as the length of our MineLocations array 
	mov edx, 0
GetNums:
	mov eax, BOARDSIZESQUARED				; Get a random number that corresponds with a space on the board
	call randomRange
	mov [esi], al							; Put the random number into our MineLocations array

	; Check to make sure the random number generated wasnt the location of the first click or any space around it (First click MUST be a 0 space)
	push eax
	call GetMouseClickOffset
	mov edx, eax
	pop eax

	cmp eax, edx			; Check space
	je GetNums

	sub edx, BOARDSIZE_D
	cmp eax, edx			; Check above space
	je GetNums	
	
	dec edx
	cmp eax, edx			; Check above and to left of space
	je GetNums	

	add edx, 2
	cmp eax, edx			; Check above and to right of space
	je GetNums	

	add edx, BOARDSIZE_D
	cmp eax, edx			; Check to right of space
	je GetNums

	sub edx, 2
	cmp eax, edx			; Check to left of space
	je GetNums	

	add edx, BOARDSIZE_D
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
	mov edx, NUMOFMINES			
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
	mov ecx, NUMOFMINES					; Will need to be some sort of variable indicating the number of mines to make
PutMines:									  
	mov edi, offset CountArray				; Starting element of board numbers array
	mov bl, [esi]
	add edi, ebx							; Move to the Nth element in the board numbers array (where the first mine will go)
	mov al, 0FFh							; Indicates a mine
	mov [edi], al
	inc esi									; Go to the next mine location
	loop PutMines

	; Now we need to go through each remaining location in the count-array and count how many mines are around them

	mov ecx, BOARDSIZESQUARED
	mov eax, 0						; Will hold offset of space around current space (above, below...) to be checked
	mov ebx, 0						; Will hold what is in that (^) space 
	mov edx, 0						; Will be used to find row/col #	
PutNums:
	mov SpaceCount, 0				; This will be our running count for the space (starts at 0 for each iteration of the loop)

	mov edx, ecx
	neg edx
	push ecx
	mov ecx, BOARDSIZESQUARED
	add edx, ecx		; edx will go from 0 to 99
	pop ecx

	mov esi, offset CountArray
	add esi, edx
	mov al, [esi]
	cmp al, 0FFh
	je ENDPutNums					; If the current space is a mine, we dont care about it.
	
	mov esi, offset CountArray
	add esi, edx					; esi will now point at the space directly above the current space

	; DIRECTLY ABOVE
	push ebx
	mov ebx, BOARDSIZE_D
	mov BOARDSIZETEMP, ebx
	dec BOARDSIZETEMP
	pop ebx
	cmp edx, BOARDSIZETEMP
	jle SkipUpper
		; If we get here, it means we are not on the top row of the board, and so we can check AT LEAST the space directly above the current space
	sub esi, BOARDSIZE_D
	mov bl, [esi]
	cmp bl, 0FFh				; Check for a mine 
	jne NoMineAbove
	inc SpaceCount			; If mine was found, increment the counter
NoMineAbove:

	; ABOVE AND TO THE LEFT
	mov ax, dx					; edx will always be smaller than a word so this is fine
	mov bl, BOARDSIZE_B
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
	mov bl, BOARDSIZE_B
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
	add esi, BOARDSIZE_D		; esi will now point to our original location no matter what
SkipUpper:

	; CHECK LEFT
	mov ax, dx					; edx will always be smaller than a word so this is fine
	mov bl, BOARDSIZE_B
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
	mov bl, BOARDSIZE_B
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
	push ebx
	mov ebx, BOARDSIZESQUARED
	sub ebx, BOARDSIZE_D
	mov BOARDSIZETEMP, ebx
	pop ebx
	cmp edx, BOARDSIZETEMP		; compare to ((BOARDSIZE*BOARDSIZE) - BOARDSIZE)
	jge SkipLower
		; If we get here, it means we are not on the bottom row of the board, and so we can check AT LEAST the space directly below the current space
	add esi, BOARDSIZE_D		; esi will now point at the space directly below the current space
	mov bl, [esi]
	cmp bl, 0FFh				; Check for a mine 
	jne NoMineBelow
	inc SpaceCount				; If mine was found, increment the counter
NoMineBelow:

	; BELOW AND TO THE LEFT
	mov ax, dx					; edx will always be smaller than a word so this is fine
	mov bl, BOARDSIZE_B
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
	mov bl, BOARDSIZE_B
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
	sub esi, BOARDSIZE_D		; esi will now point to our original location no matter what
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
	; Check to see if smiley was clicked
	cmp YClick, STARTY
	jne NotSmile
	mov ax, STARTX + 9											
	cmp BOARDSIZE_D, 9
	je boardIsSmallS
	add ax, 6
boardIsSmallS:
	cmp XClick, ax
	jl NotSmile
	inc ax
	cmp XClick, ax
	jg NotSmile

	mov SmileReset, 1

	mov eax, 0
	ret

NotSmile:
	; Check to see if help was clicked
	cmp YClick, 1
	jl NotHelpOrSmile
	cmp YClick, 3
	jg NotHelpOrSmile
	cmp XClick, 1
	jl NotHelpOrSmile
	cmp XClick, 8
	jg NotHelpOrSmile
	XOR helpIsDisplayed, 1
	
	call DisplayHelp

	mov eax, 0
	ret

	
NotHelpOrSmile:
	; Check to see if board space was clicked
	mov esi, offset Xcord		; array of vaild X cord 
	mov edi, offset Ycord		; array of vaild Y cord 
	mov ecx, BOARDSIZE_D   

searchXcord:

	mov ax, XClick  
	cmp al, [esi]      ; we are going to check if the X cord click is within our vaild click list
	je yValid		   ; if it is we are going to search the Y cord 

	inc esi
	Loop searchXcord 

	mov eax, 0
	ret				   ; if X cord was not found, we are going to stop search for vaild, we know it does not exist 

yValid:
	mov ecx, BOARDSIZE_D
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
	cmp BOARDSIZE_D, 9
	je EasyClock
	add dl, 12
EasyClock:
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
	
	mov cx, WORD PTR BOARDSIZE_D
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
	
	inc Score				; increment the number of flags, we hae a new one 
	
	ret
TryPlaceFlag:	
	cmp [edi], bl
	je PlaceFlag
	ret
PlaceFlag:
	mov bl, 0Fh

	cmp Score,0					; check if we have used all the flags
	je  byebye				; if so, we just return
	dec Score					; since we've set a flag, we decrement how many flags we have

	mov [edi], bl			; Indicates a flag
byebye:		
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
	mov GameOver,1
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
	push ebx
	mov ebx, BOARDSIZE_D
	mov BOARDSIZETEMP, ebx
	dec BOARDSIZETEMP
	pop ebx
	cmp edx, BOARDSIZETEMP		; compare to (BOARDSIZE - 1)
	jle SkipUpper
		; If we get here, it means we are not on the top row of the board, and so we can look at AT LEAST the space directly above the current space
	sub esi, BOARDSIZE_D
	
	call CheckStackForVal	
	cmp StackValFound, 1    
	je AboveAlreadyOnStack  

	mov [ecx], esi
	add ecx, 4
	inc SpaceCheckStackSize
AboveAlreadyOnStack:

	; ABOVE AND TO THE LEFT
	mov ax, dx					; edx will always be smaller than a word so this is fine
	mov bl, BOARDSIZE_B
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
	mov bl, BOARDSIZE_B
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
	add esi, BOARDSIZE_D					; esi will now point to our original location no matter what
SkipUpper:

	; CHECK LEFT
	mov ax, dx					; edx will always be smaller than a word so this is fine
	mov bl, BOARDSIZE_B
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
	mov bl, BOARDSIZE_B
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
	push ebx
	mov ebx, BOARDSIZESQUARED
	sub ebx, BOARDSIZE_D
	mov BOARDSIZETEMP, ebx
	pop ebx
	cmp edx, BOARDSIZETEMP		; compare to ((BOARDSIZE*BOARDSIZE) - BOARDSIZE)
	jge SkipLower
		; If we get here, it means we are not on the bottom row of the board, and so we can check AT LEAST the space directly below the current space
	add esi, BOARDSIZE_D			; esi will now point at the space directly below the current space
	
	call CheckStackForVal	
	cmp StackValFound, 1    
	je BelowAlreadyOnStack  
	
	mov [ecx], esi
	add ecx, 4
	inc SpaceCheckStackSize
BelowAlreadyOnStack:

	; BELOW AND TO THE LEFT
	mov ax, dx					; edx will always be smaller than a word so this is fine
	mov bl, BOARDSIZE_B
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
	mov bl, BOARDSIZE_B
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
	sub esi, BOARDSIZE_D			; esi will now point to our original location no matter what
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
	mov eax, lightCyan
	call SetTextColor
	
	mov eax, splashScreenTimer	

	mov edx, offset welcome1
	call WriteString
	call crlf
	call Delay
	mov edx, offset welcome2
	call WriteString
	call crlf
	call Delay
	mov edx, offset welcome3
	call WriteString
	call crlf
	call Delay
	mov edx, offset welcome4
	call WriteString
	call crlf
	call Delay

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
	call crlf

	mov eax, lightGray
	call SetTextColor	
	mov eax, splashScreenTimer	

	mov edx, offset difficulty0
	call WriteString
	call crlf
	call Delay
	mov edx, offset difficulty1
	call WriteString
	call crlf
	call Delay
	mov edx, offset difficulty2
	call WriteString
	call crlf
	call Delay
	mov edx, offset difficulty2
	call WriteString
	call crlf
	call Delay
	mov edx, offset difficulty2
	call WriteString
	call crlf
	call Delay

	mov edx, offset difficulty3
	call WriteString
	mov eax, lightGreen
	call SetTextColor
	mov edx, offset difficulty4 ;e
	call WriteString
	mov eax, lightgray
	call SetTextColor
	mov edx, offset difficulty5
	call WriteString
	mov eax, lightRed
	call SetTextColor
	mov edx, offset difficulty6 ;h
	call WriteString
	mov eax, lightgray
	call SetTextColor
	mov edx, offset difficulty7
	call WriteString

	mov eax, splashScreenTimer		; Because we messed up eax when we switched colors

	call crlf
	call Delay
	mov edx, offset difficulty2
	call WriteString
	call crlf
	call Delay
	mov edx, offset difficulty2
	call WriteString
	call crlf
	call Delay
	mov edx, offset difficulty2
	call WriteString
	call crlf
	call Delay
	mov edx, offset difficulty8
	call WriteString
	call crlf
	call Delay

	call crlf
	call crlf
	call crlf
	call crlf
	call crlf

	mov eax, lightmagenta
	call SetTextColor	

	mov edx, offset createdBy
	call WriteString
	call crlf

	mov splashScreenTimer, 0	; After the initial opening of the game, the splash screen should load quick so the user doesnt have to keep waiting every time they play

	ret
SplashScreen ENDP

;--------------------------------------------
; SplashScreenClick
; Checks to see if the users click on the splash
;  screen was valid (either easy or hard)
; Receives: X/Y coords in XClick and YClick
; Returns: 1 in eax for easy
;		   2 in eax for hard
;          0 in eax for invalid click
;--------------------------------------------
SplashScreenClick PROC
	cmp YClick, 11				; Top
	jl NotValidSplashClick
	cmp YClick, 19				; Bottom
	jg NotValidSplashClick
	cmp XClick, 15				; Left
	jl NotValidSplashClick
	cmp XClick, 67				; Right
	jg NotValidSplashClick

	; It was a valid click. Now get which one was chosen
	cmp XClick, 40				; Middle
	jle SetEasy
	cmp XClick, 42
	jl NotValidSplashClick
	mov eax, 2		; Hard
	ret
SetEasy:
	mov eax, 1		; Easy
	ret
NotValidSplashClick:
	mov eax, 0		; Invalid
	ret
SplashScreenClick ENDP

;***********************************************************************
;--------------------------------------------------------
; TEST DISPLAY!!!
;
; TestProc
; This is for testing purposes only. It prints a copy of
;  the board (without tiles) to the right of the real board.
;  it is used for debugging purposes so you dont have to guess
;  or actually play the game when testing.
; Receives: nothing
; Returns: nothing
;--------------------------------------------------------
;***********************************************************************
TestProc PROC USES eax ecx edx
	
	mov esi, offset CountArray
	mov eax, red + (gray * 16)
	call SetTextColor

	mov currentY, STARTY
	mov dh, currentY
	mov dl, STARTX + 40
	call GotoXY

	mov edx, offset strCount
	call WriteString
	mov edx, offset strSpace
	mov ecx, 6
	cmp BOARDSIZE_D, 9
	je Spaces1
	add ecx, 6
Spaces1:
	call WriteString
	loop Spaces1

	mov eax, yellow + (gray * 16)
	call SetTextColor
	mov edx, offset strFace
	call WriteString
	
	mov edx, offset strSpace
	mov ecx, 7
	cmp BOARDSIZE_D, 9
	je Spaces2
	add ecx, 6
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
	mov dl, STARTX + 40
	call GotoXY

	mov eax, lightgray + (gray * 16)
	call SetTextColor
	mov edx, offset strSpace

	mov eax, topLeft
	call WriteChar

	mov eax, BOARDSIZE_D
	mov BOARDSIZETEMP, eax
	add BOARDSIZETEMP, eax
	inc BOARDSIZETEMP
	mov ecx, BOARDSIZETEMP	; BOARDSIZE*2 + 1
	mov eax, horizontal
Top:
	call WriteChar
	loop Top
	
	mov eax, topRight
	call WriteChar
	
	inc currentY
	mov dh, currentY
	mov dl, STARTX + 40
	call GotoXY

	mov ecx, BOARDSIZE_D


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
	mov dl, STARTX + 40
	call GotoXY

	loop Contents
	
	mov eax, bottomLeft
	call WriteChar
	mov eax, horizontal
	mov ecx, BOARDSIZETEMP	; hasnt changed yet, so its still BOARDSIZE*2 + 1
Bottom:
	call WriteChar
	loop Bottom

	mov eax, bottomRight
	call WriteChar
	
	inc currentY
	mov dh, currentY
	mov dl, STARTX + 40
	call GotoXY

	mov eax, lightgray
	call SetTextColor

	ret
TestProc ENDP


;--------------------------------------------------------
; PrintScore 
; Print the score at the top left of the board
; Count of number of flags that have not been used
; nothing
;--------------------------------------------------------
PrintScore PROC
	mov dl, STARTX				; go to the top left (3,3)
	mov dh, STARTY				; 
	call Gotoxy					

	mov eax, red + (gray * 16)	; set same color as the board
	call SetTextColor
	mov edx, offset strCount
	call WriteString
	mov dl, STARTX				; go to the top left (3,3)
	mov dh, STARTY				; 


	movsx eax,Score				; lets move our current flag score into ax 
	cmp eax, 10					; 10 is going to tell us we need two digits, otherwise only one digit needs to be printed 
	jl  onedigit
	add dl, 1					; if the number is >=10, there is only going to be one zero in the third placeholder 
	jmp move
onedigit:
    add dl, 2					; if the number is <10, there is going to be two zero in the first two placeholders, since we are only dealing with one digit
move:
	call Gotoxy					; move the cursor
	call WriteDec				; write the digit 
	ret
PrintScore ENDP

;--------------------------------------------------------
; ShowMines 
; we are going to show all the mines on game over 
; nothing 
; nothing 
;--------------------------------------------------------
ShowMines PROC
	mov eax, red + (gray*16)
	call SetTextColor
	mov esi, offset MineLocations			; we are going to point at the fitst location in MineLocations array
	          ;every byte in the array represents one position from 0 to 81
	mov ecx, lengthof MineLocations			; get the number of mines that we have MineLocations array 
	mov bl,BOARDSIZE_B ; the width of our board 
showM:
                  ; to find the remaining postions of the mine 
				  ; we will take in the number read in from the array  and divide it by the width of our board 
				  ; that way we can get postion x and y ( ah and al), where the postions will be from 0 - 8
	mov ah,0
	
	mov al, [esi] 
	div bl  ; we divide the number from the array by width to get the x and y coordinates 
	mov dh,al  ; y coordinate 
	mov dl,ah  ; x coordinate 
	mov al,2	
	mul dl		; multiply x (in dl) position by 2
	mov dl,al	; save result of multiplication again in dl
	add dl,STARTX+2 ; ; get the real X location on the board
	add dh,STARTY+2  ;; get the real y location on the board 
	call GotoXY 
	mov al,'*'  ; lets print it at the location 
	call WriteChar
	inc esi ; move to the next location 
	loop showM
	ret
ShowMines ENDP

;-----------------------------------
; YouWinDisplay
; Displays "You Win" in block letters
; Receives: nothing
; Returns: nothing
;-----------------------------------
YouWinDisplay PROC
	mov eax, lightGreen
	call SetTextColor

	mov dx, 0
	call GoToXY

	mov edx, offset youWin1
	call WriteString
	call crlf
	mov edx, offset youWin2
	call WriteString
	call crlf
	mov edx, offset youWin3
	call WriteString
	call crlf
	mov edx, offset youWin4
	call WriteString
	
	mov dh, STARTY
	mov dl, STARTX + 9											
	cmp BOARDSIZE_D, 9
	je boardIsSmallW
	add dl, 6
boardIsSmallW:
	call GoToXY
	mov eax, yellow + (gray*16)
	call SetTextColor
	mov eax, 'B'
	call WriteChar

	ret
YouWinDisplay ENDP

;-----------------------------------
; YouLoseDisplay
; Displays "You Lose" in block letters
; Receives: nothing
; Returns: nothing
;-----------------------------------
YouLoseDisplay PROC
	mov eax, lightRed
	call SetTextColor

	mov dx, 0
	call GoToXY

	mov edx, offset youLose1
	call WriteString
	call crlf
	mov edx, offset youLose2
	call WriteString
	call crlf
	mov edx, offset youLose3
	call WriteString
	call crlf
	mov edx, offset youLose4
	call WriteString

	mov dh, STARTY
	mov dl, STARTX + 9											
	cmp BOARDSIZE_D, 9
	je boardIsSmallL
	add dl, 6
boardIsSmallL:
	call GoToXY
	mov eax, yellow + (gray*16)
	call SetTextColor
	mov eax, 'X'
	call WriteChar
	mov eax, '('
	call WriteChar

	ret
YouLoseDisplay ENDP

;----------------------------------
; DisplayHelp
; Displays or hides the help window
; Receives: 0 or 1 in helpIsDisplayed
; Returns: nothing
;----------------------------------
DisplayHelp PROC USES eax ebx ecx edx
	mov eax, lightGray
	call SetTextColor

	mov dh, 1
	mov dl, 64
	call GoToXY
	cmp helpIsDisplayed, 1
	jne HideHelpPage

	mov bx, dx
	mov edx, offset helpInfo1
	call WriteString
	mov dx, bx
	add dh, 2
	mov dl, 64
	call GoToXY
	mov bx, dx
	mov edx, offset helpInfo2
	call WriteString
	mov dx, bx
	inc dh
	mov dl, 64
	call GoToXY
	mov bx, dx
	mov edx, offset helpInfo3
	call WriteString
	mov dx, bx
	inc dh
	mov dl, 64
	call GoToXY
	mov bx, dx
	mov edx, offset helpInfo4
	call WriteString
	mov dx, bx
	inc dh
	mov dl, 64
	call GoToXY
	mov bx, dx
	mov edx, offset helpInfo5
	call WriteString
	mov dx, bx
	inc dh
	mov dl, 64
	call GoToXY
	mov bx, dx
	mov edx, offset helpInfo52
	call WriteString
	mov dx, bx
	inc dh
	mov dl, 64
	call GoToXY
	mov bx, dx
	mov edx, offset helpInfo6
	call WriteString
	mov dx, bx
	inc dh
	mov dl, 64
	call GoToXY
	mov bx, dx
	mov edx, offset helpInfo7
	call WriteString
	mov dx, bx
	inc dh
	mov dl, 64
	call GoToXY
	mov bx, dx
	mov edx, offset helpInfo8
	call WriteString
	mov dx, bx
	add dh, 2
	mov dl, 64
	call GoToXY
	mov bx, dx
	mov edx, offset helpInfo9
	call WriteString

	call DrawBoard

	ret

HideHelpPage:

	mov eax, ' '
	mov ecx, 12
HelpOuterLoop:
	push ecx
	mov ecx, 56
HelpInnerLoop:
	call WriteChar
	loop HelpInnerLoop
	inc dh
	mov dl, 64
	call GoToXY
	pop ecx
	loop HelpOuterLoop

	call DrawBoard

	ret
DisplayHelp ENDP

END MAIN
