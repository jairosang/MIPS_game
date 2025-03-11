v0.0.5 [GAME OVER][]

[] - 

v0.0.4 [PROPER PLAYER LOCATION UPDATES] []

Figured out ANSI escape codes

[] - Updating player position by cursor and not display refresh to be more efficient
[] - Check the value in the new position of the character
[] - Clear screen and display game over if value in new cursor location is hash sign



v0.0.3 [PROPER GRID ARRAY] []

[] - Storing grid as a .space array instead of ASCII (now that I know the first bug was because of the ASCII values)
[] - Creating a function to initialize the .space into the value of ' '


CURRENT
v0.0.2 [KEYBOARD INPUTS] [X]

[X] - Creating keyboard get character function
[X] - Polling keyboard control register
[X] - Getting character from keyboard data register
[X] - Validating input is WASD  
[X] - Updating PLAYER position
[X] - FOR TESTING: 

FUTURE BUG: Cannot assess if character is out of bounds



v0.0.1 [DISPLAY FUNCTIONS] [X]

[X] - Create function to display grid (structure the grid)
[X] - Figure out polling
[X] - Create function to poll and display individual characters

[X] - BUG: Cannot print variable numbers in the MMIO display
    - FIX: (Grid is stored as a string to simplify printing and understanding) (Score value is also stored as a string)

