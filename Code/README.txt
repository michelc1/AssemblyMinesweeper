Members: Darrien Kennedy, Chris Michel, and Alex Robbins

Lines of code: 2077

Unfixed bugs: (everything works)

Roles:
Darrien:
Created the GUI for the game board with the corresponding colors to make it seem as close to the original 1989 release while remaining in the computer console. Implemented win conditions for the game, which results in a loss when clicking on a mine and is constantly checking whether the game has been won. The way this is performed is checking the unclicked or flagged elements in the board array and breaking when an unclicked tile does not have a mine under it.

Chris:
Worked on getting clicking to work properly (only registering mouseup vs mousedown). Researched and implemented clickability which did not require the user to install something to get the clicking to work the way that we wanted. Also set up the "validclicks" which assigned every character location on the console where a clickable tile was, and also so that you could click on both the smiley face and different buttons found within our program. Implemented rightclicking to result in either placing or removing a flag and negating the flag counter.

Alex:
Generated two game boards, a 9x9 with 10 mines and a 15x15 with 35 mines. The mines were placed according to the first click, (a mine cannot be in the location of the first click or any of the adjacent tiles to that first click), and a mine is only placed in a location where a mine does not already exist. Also implemented "floodclicking" which is performed when the tile that the player clicks on has an adjacency of zero. Implemented the help screen and the menu screen and also the timer's funcionality.
