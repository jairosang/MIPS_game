v0.0.5 [THE REWARD][]

[X] - Add a reward variable with current reward position
[X] - Create a randomly placed reward
[X] - Check for player collision with reward
[X] - Increase the score when collision is detected with reward
[X] - Reallocate reward
[] - Make sure reward cannot appear in the current player position

v0.0.4 [PROPER PLAYER LOCATION UPDATES] [X]

1.Figured out ANSI escape codes
2.Figured out ANSI escape codes do not work in MIPS MMIO
3.Figured out cursor location can be controlled with (x,y) values 
4.Removed array

[X] - Updating player position by cursor and not display refresh to be more efficient
[X] - Add game over condition function
[X] - Apply game over to border collision


v0.0.3 [PROPER GRID ARRAY] []
SKIPPED
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

