
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
	strTime db "000",0
	strCount db "000",0
	strFace db ":)",0
	Space db " "
	strSpace db " ",0
	ShowArray db 100 DUP(254)
	CountArray db 100 DUP(0)
	MineLocations db 10 DUP(?) 
	SpaceCount db 0
.code
main PROC
	call Randomize				; So we can get random numbers for mine location generation
	STARTX = 45					; The X coordinate of the top left corner of the board
	STARTY = 7					; The Y coordinate of the top left corner of the board
	BOARDSIZE = 10				; Width of board (will need to make this changeable in game somehow...)

	call FillBoard
	;call DrawBoard
	call DrawBoardSkeleton

	
	Invoke ExitProcess, 0
main ENDP

;----------------------------------
; DrawBoardSkeleton
; Draws the board layout to the console 
; Recieves: Nothing
; Returns: An empty minesweeper board
; Uses: eax ecx edx
;----------------------------------
DrawBoardSkeleton PROC USES eax ecx edx
	
	mov esi, offset CountArray
	mov eax, red + (gray * 16)
	call SetTextColor
	mov edx, offset strCount
	call WriteString
	mov edx, offset strSpace
	mov ecx, 7
Spaces1:
	call WriteString
	loop Spaces1

	mov eax, yellow + (gray * 16)
	call SetTextColor
	mov edx, offset strFace
	call WriteString
	
	mov edx, offset strSpace
	mov ecx, 8
Spaces2:
	call WriteString
	loop Spaces2

	mov eax, red + (gray * 16)
	call SetTextColor
	mov edx, offset strTime
	call WriteString
	call Crlf

	mov eax, lightgray + (gray * 16)
	call SetTextColor
	mov edx, offset strSpace

	mov eax, topLeft
	call WriteChar

	mov ecx, 21
	mov eax, horizontal
Top:
	call WriteChar
	loop Top
	
	mov eax, topRight
	call WriteChar
	call Crlf

	mov ecx, 10


Contents:
	mov eax, vertical
	call WriteChar
	push ecx
	
	call PrintContents

	pop ecx
	mov eax, vertical
	call WriteChar
	call Crlf
	loop Contents
	
	mov eax, bottomLeft
	call WriteChar
	mov eax, horizontal
	mov ecx, 21
Bottom:
	call WriteChar
	loop Bottom

	mov eax, bottomRight
	call WriteChar
	call Crlf

	mov eax, lightgray
	call SetTextColor

	ret
DrawBoardSkeleton ENDP


;-------------------------------
; PrintContents
; Prints the contents of the array within the the vertical bars
; Recieves: offset of board array in esi
; Returns: Output on screen
;-------------------------------
PrintContents PROC
	mov ecx, 10
	call WriteString

Inner:
	call CharSet

Blam:
	call WriteChar
	call WriteString
	inc esi
	mov eax, lightgray + (gray * 16)
	call SetTextColor

	loop Inner
	ret
PrintContents ENDP


;-----------------------------
; CharSet
; Sets the text color and character for eax based on the value in eax
; Recieves: a value in the board array
; Returns: eax with the correspoding character and color
;-----------------------------
CharSet PROC
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
CharSet ENDP


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
	mov [esi], eax							; Put the random number into our MineLocations array

	; Check to make sure the random number generated wasnt a duplicate (Each mine must be in a unique location)
	cmp ecx, 10					; if ecx == 10, jump to SkipFirst (the first time around, we dont need to check because theres nothing to check against)
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
	add edx, 100					; edx will go from 0 to 99

	mov esi, offset CountArray
	add esi, edx
	mov al, [esi]
	cmp al, 0FFh
	je ENDPutNums					; If the current space is a mine, we dont care about it.
	
	mov esi, offset CountArray
	add esi, edx					; esi will now point at the space directly above the current space

	; DIRECTLY ABOVE
	cmp edx, 9
	jle SkipUpper
		; If we get here, it means we are not on the top row of the board, and so we can check AT LEAST the space directly above the current space
	sub esi, 10
	mov bl, [esi]
	cmp bl, 0FFh				; Check for a mine 
	jne NoMineAbove
	inc SpaceCount			; If mine was found, increment the counter
NoMineAbove:

	; ABOVE AND TO THE LEFT
	mov ax, dx					; edx will always be smaller than a word so this is fine
	mov bl, 10
	div bl						; Divide our current position by 10
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
	sub ax, 9					; Because the right column will always be 19-99
	mov bl, 10
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
	add esi, 10					; esi will now point to our original location no matter what
SkipUpper:

	; CHECK LEFT
	mov ax, dx					; edx will always be smaller than a word so this is fine
	mov bl, 10
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
	mov bl, 10
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
	cmp edx, 90
	jge SkipLower
		; If we get here, it means we are not on the bottom row of the board, and so we can check AT LEAST the space directly below the current space
	add esi, 10					; esi will now point at the space directly below the current space
	mov bl, [esi]
	cmp bl, 0FFh				; Check for a mine 
	jne NoMineBelow
	inc SpaceCount				; If mine was found, increment the counter
NoMineBelow:

	; BELOW AND TO THE LEFT
	mov ax, dx					; edx will always be smaller than a word so this is fine
	mov bl, 10
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
	mov bl, 10
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
	sub esi, 10					; esi will now point to our original location no matter what
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
; DrawBoard:
; Draws the board
; Receives: Assumes STARTY, STARTX, BOARDSIZE, and ShowArray exist
; Returns: nothing
;---------------------------------------------------------------
DrawBoard PROC
	mov eax, 0					; Initialize
	mov edx, 0					; Initialize
	mov dh, STARTY				; dh is the Y coordinate for GoToXY Procedure
	mov dl, STARTX				; dl is the X coordinate for GoToXY Procedure

	mov ecx, BOARDSIZE			; The board will need 'BOARDSIZE' number of rows
	mov esi, offset CountArray  ; *********FOR TESTING********* Should really be printarray 

; Do the actual printing

PrintBoardOuter:
	mov ebx, ecx				; Save the outer counter
	mov ecx, BOARDSIZE			; Each row will need 'BOARDSIZE' number of columns
PrintBoardInner:
	call GoToXY					; Go to the coordinates that this particular square will be printed in
	mov al, [esi]				; Load the character to be printed

	; FOR TESTING!!!
	cmp al, 0
	jl Donezooo
	cmp al, 8
	jg Donezooo
	add al, 48
	
Donezooo:
	inc esi						; Go to the next character
	call writeChar				; Print the character that goes in a space
	inc dl						; Get ready to go to the next space...

	call GoToXY					; Go to the next space over...
	mov al, Space				; Load a space character (only used to make the board look neater)
	call writeChar				; Print the space
	inc dl						; Get ready to go to the next location...
	loop PrintBoardInner

	inc dh						; After each full row, increment to the next column...
	mov dl, STARTX				; And reset the row start location
	mov ecx, ebx				; Get our counter back
	loop PrintBoardOuter

	ret
DrawBoard ENDP

END MAIN