# https://wilkinsonj.people.charleston.edu/mmio.html
# https://gist.github.com/fnky/458719343aabd01cfb17a3a4f7296797
# https://www.ascii-code.com

# RESERVED $s0, $s1 FOR DISPLAY
# RESERVED $s2, $s3 FOR KEYBOARD
# RESERVED $s7 FOR ARRAY DISPLAY
.data
	# Constants
	DISPLAY_CTRL_R: .word 0xFFFF0008 #Display control register
	DISPLAY_ADDR: .word 0xFFFF000C  # Display address
	KEYBOARD_STATUS: .word 0xFFFF0000  # Address to check IF a key is pressed
	KEYBOARD_DATA: .word 0xFFFF0004    # Address to read THE key pressed
	
	# Board elements
	gameOverMessage: .asciiz "GAME OVER"
	scoreLabel: .asciiz "Score:"
	score: .byte 0
	border: .byte '#'
	space: .byte ' '
	player: .byte 'P'
	reward: .byte 'R'
	
	# Board info
	boardWidth: .byte 15
	boardHeight: .byte 6
	
	# Data 
	playerX: .byte 0
	playerY: .byte 0
	rewardX: .byte 0
	rewardY: .byte 0
	rewardSeed: .word 300
	
	
.text 
.globl INIT_UTILITIES_ADDRS, INIT_CHARACTER, INIT_REWARD, DISPLAY, GET_KEYBOARD, dspl_check_and_print, update_p_up, update_p_left, update_p_down, update_p_right, cursor_go_to, collision_player_border, collision_player_reward, game_won

INIT_UTILITIES_ADDRS:
	addi $sp, $sp, -4
	sw $ra, 4($sp)


	lw $s0, DISPLAY_CTRL_R       	# Load the address of the display control resgister.
	lw $s1, DISPLAY_ADDR		# Load the address of the display data register
	lw $s2, KEYBOARD_STATUS		# Load the address of the keyboard control register.
	lw $s3, KEYBOARD_DATA		# Load the address of the keyboard data register
	
	# Generate number for seed
	lw $a1, rewardSeed
	li $a0, 0
	li $v0, 42
	syscall
	
	# Set seed to number
	sw $a0, rewardSeed
	add $a1, $a0, $zero
	li $a0, 0
	li  $v0, 40
	syscall
	
	lw $ra, 4($sp)
	addi $sp, $sp, 4
	jr $ra
	
# GAME CONDITIONS
#=============================================================================================================================================================================================
player_gets_reward:
	addi $sp, $sp, -4
	sw $ra, 4($sp)
	
	jal increase_score
	jal update_score_displayed
	jal INIT_REWARD
	
	lw $ra, 4($sp)
	addi $sp, $sp, 4
	jr $ra

game_over:
	# Clear Screen
	li $a0, 12
	jal dspl_check_and_print
	
	jal display_score_label
	jal over_score_update
	
	li $a0, 0
	li $a1, 1
	jal cursor_go_to
	
	
	la $t1, gameOverMessage
loop_game_over_msg:
	lb $a0, 0($t1)
	beqz $a0, exit_loop_game_over_msg
	
	jal dspl_check_and_print
	
	addi $t1, $t1, 1

	j loop_game_over_msg
	
exit_loop_game_over_msg:	
	li $v0, 10
	syscall
	
	
# CHECK FUNCTIONS
#=============================================================================================================================================================================================
game_won:
	lb $t0, score
	beq $t0, 100, game_over
	
	jr $ra
	

collision_player_border:
	lb $t0, playerX
	lb $t1, playerY
	lb $t2, boardWidth
	lb $t3, boardHeight
	
	addi $t2, $t2, 1
	addi $t3, $t3, 2
	
	bgt $t0, $t2, game_over
	blt $t0, 1, game_over
	bgt $t1, $t3, game_over
	blt $t1, 2, game_over

	jr $ra

collision_player_reward:
	addi $sp, $sp, -4
	sw $ra, 4($sp)
	
	lb $t0, playerX
	lb $t1, playerY
	lb $t2, rewardX
	lb $t3, rewardY
	
	bne $t0, $t2, exit_collision_player_reward
	bne $t1, $t3, exit_collision_player_reward
	j player_gets_reward
	
exit_collision_player_reward:
	lw $ra, 4($sp)
	addi $sp, $sp, 4
	jr $ra
	
		
# DATA FUNCTIONS
#=============================================================================================================================================================================================
increase_score:
	lb $t0, score
	addi $t0, $t0, 5
	sb $t0, score

	jr $ra
	
update_seed:
# Args, a1: number to change seed by
	li $a0, 0
	lw $t0, rewardSeed
	
	add $a1, $a1, $t0
	sw $a1, rewardSeed
	li $v0, 40
	
	jr $ra
	
# CURSOR FUNCTIONS
#=============================================================================================================================================================================================
cursor_go_to:
	# Args a0 = X axis, a1 = Y axis
	addi $sp, $sp, -4
	sw $ra, 4($sp)
	
	
	sll $a0, $a0, 12
	andi $a1, $a1, 0xFFF
	or $a0, $a0, $a1

	sll $a0, $a0, 8
	
	ori $a0, $a0, 7
	
cursor_check:

	lw $t0, 0($s0)
        andi $t0, $t0, 1       
        
        beq $t0, $zero, cursor_check
        
        sw $a0, 0($s1)
	
	lw $ra, 4($sp)
	addi $sp, $sp, 4
	jr $ra
	
# REWARD FUNCTIONS
#=============================================================================================================================================================================================
INIT_REWARD:
	addi $sp, $sp, -4
	sw $ra, 4($sp)
	
generate_reward:
	la $t0, rewardX
	la $t1, rewardY
	
	# Generate random X in board (accounting for borders)
	lb $a1, boardWidth	
	addi $a1, $a1, 1  # Add one to account for exclusivity
	li $a0, 0
	li $v0, 42
	syscall                 # Make the syscall to generate random number
	
	addi $a0, $a0, 1	# Add 1 to ensure reward spawns between borders (1 to width-2)
	sb $a0, ($t0)
	
	# Generate random Y in board (accounting for borders and score)
	lb $a1, boardHeight	
	addi $a1, $a1, 1  # Add one to account for exclusivity
	li $a0, 0
	li $v0, 42
	syscall                 # Make the syscall to generate random number
	
	addi $a0, $a0, 2	# Add 2 to account for score display and top border
	sb $a0, ($t1)
	
	# Load the reward coordinates for cursor positioning
	lb $a0, rewardX
	lb $a1, rewardY
	lb $t0, playerX
	lb $t1, playerY

	# Check if new reward is in the same position as player
	bne $t0, $a0, exit_reward_generation
	bne $t1, $a1, exit_reward_generation
	j generate_reward
	
exit_reward_generation:
	# Locate the reward
	jal cursor_go_to
	
	lb $a0, reward
	jal dspl_check_and_print
	
	lw $ra, 4($sp)
	addi $sp, $sp, 4
	jr $ra
	
	
# CHARACTER FUNCTIONS
#=============================================================================================================================================================================================
INIT_CHARACTER:
	addi $sp, $sp, -4
	sw $ra, 4($sp)

	la $t0, playerX
	la $t1, playerY
	
	# Generate random number between 1 and width-2 of board (accounting for borders)
	lb $a1, boardWidth	
	addi $a1, $a1, 1  # Subtract 2 to account for both borders
	li $a0, 0
	li $v0, 42
	syscall                 # Make the syscall to generate random number
	
	addi $a0, $a0, 1	# Add 1 to ensure player spawns between borders (1 to width-2)
	sb $a0, ($t0)
	
	# Generate random number between 2 and height-1 of board (accounting for borders and score)
	lb $a1, boardHeight	
	addi $a1, $a1, 1  # Subtract 4 to account for both borders
	li $a0, 0
	li $v0, 42
	syscall                 # Make the syscall to generate random number
	
	addi $a0, $a0, 2	# Add 2 to account for score display and top border
	sb $a0, ($t1)
	
	# Load the player coordinates for cursor positioning
	lb $a0, playerX
	lb $a1, playerY
	
	# Locate the player in random location
	jal cursor_go_to
	
	lb $a0, player
	jal dspl_check_and_print
	
	lw $ra, 4($sp)
	addi $sp, $sp, 4
	jr $ra
	
clear_player_space:
	addi $sp, $sp, -4
	sw $ra, 4($sp)
	
	# Load the player coordinates for cursor positioning
	lb $a0, playerX
	lb $a1, playerY
	
	# Locate the player in random location
	jal cursor_go_to
	
	# Remove player from location
	lb $a0, space
	jal dspl_check_and_print
	
	lw $ra, 4($sp)
	addi $sp, $sp, 4
	jr $ra
	
update_p_up:
	addi $sp, $sp, -4
	sw $ra, 4($sp)
	
	jal clear_player_space
	
	li $a1, 3
	jal update_seed
	
	# Load the player coordinates for cursor positioning
	lb $a0, playerX
	lb $a1, playerY
	
	# Update player Y axis to -1 
	addi $a1, $a1, -1
	sb $a1, playerY
	
	# Go to player new location
	jal cursor_go_to
	
	# Print player
	lb $a0, player
	jal dspl_check_and_print
	

	lw $ra, 4($sp)
	addi $sp, $sp, 4
	jr $ra

update_p_left:
	addi $sp, $sp, -4
	sw $ra, 4($sp)
	
	jal clear_player_space
	
	li $a1, 3
	jal update_seed
	
	# Load the player coordinates for cursor positioning
	lb $a0, playerX
	lb $a1, playerY
	
	# Update player X axis to -1 
	addi $a0, $a0, -1
	sb $a0, playerX
	
	# Go to player new location
	jal cursor_go_to
	
	# Print player
	lb $a0, player
	jal dspl_check_and_print
	

	lw $ra, 4($sp)
	addi $sp, $sp, 4
	jr $ra

update_p_down:
	addi $sp, $sp, -4
	sw $ra, 4($sp)
	
	jal clear_player_space
	
	li $a1, -3
	jal update_seed
	
	# Load the player coordinates for cursor positioning
	lb $a0, playerX
	lb $a1, playerY
	
	# Update player Y axis to +1 
	addi $a1, $a1, 1
	sb $a1, playerY
	
	# Go to player new location
	jal cursor_go_to
	
	# Print player
	lb $a0, player
	jal dspl_check_and_print
	

	lw $ra, 4($sp)
	addi $sp, $sp, 4
	jr $ra
	
update_p_right:
	addi $sp, $sp, -4
	sw $ra, 4($sp)
	
	jal clear_player_space
	
	li $a1, -3
	jal update_seed
	
	# Load the player coordinates for cursor positioning
	lb $a0, playerX
	lb $a1, playerY
	
	# Update player X axis to +1 
	addi $a0, $a0, 1
	sb $a0, playerX
	
	# Go to player new location
	jal cursor_go_to
	
	# Print player
	lb $a0, player
	jal dspl_check_and_print
	

	lw $ra, 4($sp)
	addi $sp, $sp, 4
	jr $ra


# DISPLAY FUNCTIONS
#=============================================================================================================================================================================================
# Will ready the display and print the character in a0
dspl_check_and_print:

	lw $t0, 0($s0)
        andi $t0, $t0, 1        # Mask off (turn to zero) all of the bits in $t0 except the ready bit.
                                # At this point the value in $t0 is zero if the ready bit was clear or nonzero if it was set.
        beq $t0, $zero, dspl_check_and_print      # Test $t0 against $zero and branch back to step 1 if they are equal.
	
	
	sb $a0, 0($s1)		# Stores the letter in the display
	jr $ra

# Prints a new line in the MMIO
print_new_line:
	addi $sp, $sp, -4
	sw $ra, 4($sp)

	# Increase the current line by one
	addi $t3, $t3, 1
	
	li $a0, 0		# Load X value to 0
	add $a1, $t3, $zero	# Load Y to next line
	jal cursor_go_to
	
	lw $ra, 4($sp)
	addi $sp, $sp, 4
	jr $ra

# Prints a space in the MMIO
print_space:
	addi $sp, $sp, -4
	sw $ra, 4($sp)

	lb $a0, space	# Print newline
	jal dspl_check_and_print
		
	lw $ra, 4($sp)
	addi $sp, $sp, 4
	jr $ra

# Displays a single border element
display_border:
	addi $sp, $sp, -4
	sw $ra, 4($sp)
	
	lb $a0, border
	jal dspl_check_and_print

	
	lw $ra, 4($sp)
	addi $sp, $sp, 4
	jr $ra


# Loops to display the word "Score:"
display_score_spaces:
	addi $sp, $sp, -4
	sw  $ra, 4($sp)

	lb $a0, boardWidth
	div $a0, $a0, 2
	addi $a0, $a0, -2
	
	li $a1, 0
	jal cursor_go_to
	
	la $t1, scoreLabel			# Load the address of string into $t1
	j loop_display_score
	
# Displays the label of the score
display_score_label:
	addi $sp, $sp, -4
	sw  $ra, 4($sp)
	
	la $t1, scoreLabel			# Load the address of string into $t1
	
loop_display_score:
	lb $a0, ($t1)					# Stores the according letter value in $a0
	beq $a0, $zero, exit_display_score_label	#If the value is null, the word ended 
	jal dspl_check_and_print
	
	# Goes to character address in string
	addi $t1, $t1, 1	
	
	j loop_display_score
exit_display_score_label:
	lw $ra, 4($sp)
	addi $sp, $sp, 4
	jr $ra
	
# Displays the top or bottom line of border
display_top_border:
	addi $sp, $sp, -4
	sw $ra, 4($sp)

	lb $t1, boardWidth	# Load counter in t1
	addi $t1, $t1, 2 	# Account for extra side borders
	
loop_display_top_border:
	jal display_border
	
	beqz $t1, exit_loop_display_top_border
	addi $t1, $t1, -1

	j loop_display_top_border
	
exit_loop_display_top_border:
	lw $ra, 4($sp)
	addi $sp, $sp, 4
	jr $ra
	
# Displays a line of the board
display_board_line:
	addi $sp, $sp, -4
	sw $ra, 4($sp)

	lb $t1, boardWidth	# Load counter in t1
	
loop_display_board_line:
	
	jal print_space
	
	beqz $t1, exit_display_board_line
	addi $t1, $t1, -1

	j loop_display_board_line
exit_display_board_line:
	lw $ra, 4($sp)
	addi $sp, $sp, 4
	jr $ra

# Score Updating
# ============
# Updates the number displayed as a score when game is over
over_score_update:
	addi $sp, $sp, -4
	sw $ra, 4($sp)
	
	# Load coordinates of score number
	li $a0, 6
	li $a1, 0
	jal cursor_go_to
	
	j update_score_jump

# Updates the number displayed as a score
update_score_displayed:
	addi $sp, $sp, -4
	sw $ra, 4($sp)
	
	lb $a0, boardWidth
	div $a0, $a0, 2
	addi $a0, $a0, 4
	
	li $a1, 0
	jal cursor_go_to

update_score_jump:	
	# Get score value and initialize
	lb $t0, score
	
	# Divide score by 100
	li $t1, 100
	div $t0, $t1
	mflo $t2        # Hundreds digit
	mfhi $t0        # Remainder
	
	# Print hundreds if non-zero
	beqz $t2, check_tens
	addi $a0, $t2, 48
	jal dspl_check_and_print
	
	#Print leading 0s for 100
	li $a0, 48
	jal dspl_check_and_print
	jal dspl_check_and_print
	
	lw $ra, 4($sp)
	addi $sp, $sp, 4
	jr $ra
		
check_tens:
	li $t1, 10
	div $t0, $t1
	mflo $t3        # Tens digit
	mfhi $t4        # Ones digit

	# Print tens if non-zero or if hundreds was printed
	beqz $t3, print_ones
	addi $a0, $t3, 48
	jal dspl_check_and_print

print_ones:
	# Always print ones digit
	addi $a0, $t4, 48
	jal dspl_check_and_print

	lw $ra, 4($sp)
	addi $sp, $sp, 4
	jr $ra
# ============

						
# MAIN DISPLAY FUNCTION
DISPLAY:
	addi $sp, $sp, -4
	sw $ra, 4($sp)
	
	# Reset cursor to 0,0
	li $a0, 7
	jal dspl_check_and_print
	
	# Init current line to 0
	li $t3, 0
	
	jal display_score_spaces
	jal update_score_displayed
	jal print_new_line
	
	jal display_top_border
	jal print_new_line
	
	lb $t2, boardHeight
dspl_loop:
	
	jal display_border
	jal display_board_line
	jal display_border
	jal print_new_line
	
	beqz $t2, exit_dspl_loop
	addi $t2, $t2, -1
	j dspl_loop
	
exit_dspl_loop:
	jal display_top_border
	
	lw $ra, 4($sp)
	addi $sp, $sp, 4
	jr $ra
	


# KEYBOARD FUNCTIONS
#============================================================================================================================================================================================
# MAIN KEYBOARD FUNCTION
GET_KEYBOARD:
keyboard_check_and_get:

	lw $t0, 0($s2)
        andi $t0, $t0, 1        # Mask off (turn to zero) all of the bits in $t0 except the ready bit.
                                # At this point the value in $t0 is zero if the ready bit was clear or nonzero if it was set.
        beq $t0, $zero, keyboard_check_and_get
	
	lw $v0, 0($s3) # GET CHARACTER
	jr $ra
