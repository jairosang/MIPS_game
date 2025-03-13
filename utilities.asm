# https://wilkinsonj.people.charleston.edu/mmio.html
# https://gist.github.com/fnky/458719343aabd01cfb17a3a4f7296797
# https://www.ascii-code.com

# RESERVED $s0, $s1 FOR DISPLAY
# RESERVED $s2, $s3 FOR KEYBOARD
# RESERVED $s7 FOR ARRAY DISPLAY
.data
	DISPLAY_CTRL_R: .word 0xFFFF0008 #Display control register
	DISPLAY_ADDR: .word 0xFFFF000C  # Display address
	KEYBOARD_STATUS: .word 0xFFFF0000  # Address to check IF a key is pressed
	KEYBOARD_DATA: .word 0xFFFF0004    # Address to read THE key pressed
	
	scoreLabel: .asciiz "Score:"
	score: .byte '0'
	border: .byte '#'
	space: .byte ' '
	player: .byte 'P'
	reward: .byte 'R'
	
	boardWidth: .byte 15
	boardHeight: .byte 6
	playerX: .byte 0
	playerY: .byte 0
	
.text 
.globl INIT_UTILITIES_ADDRS, INIT_CHARACTER, DISPLAY, GET_KEYBOARD, dspl_check_and_print, update_p_up, update_p_left, update_p_down, update_p_right, cursor_go_to
INIT_UTILITIES_ADDRS:
	addi $sp, $sp, -4
	sw $ra, 4($sp)


	lw $s0, DISPLAY_CTRL_R       # Copy the control register into a CPU register.
	lw $s1, DISPLAY_ADDR	# Load the address of the display into $s1
	lw $s2, KEYBOARD_STATUS
	lw $s3, KEYBOARD_DATA
	
	
	lw $ra, 4($sp)
	addi $sp, $sp, 4
	jr $ra
	
# DATA FUNCTIONS
#=============================================================================================================================================================================================
increase_score:
	lb $t0, score
	addi $t0, $t0, 1
	sb $t0, score

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
	

# CHARACTER FUNCTIONS
#=============================================================================================================================================================================================
INIT_CHARACTER:
	addi $sp, $sp, -4
	sw $ra, 4($sp)

	la $t0, playerX
	la $t1, playerY
	
	# Generate random number between 0 and width of board
	lb $a0, boardWidth	
	addi $a0, $a0, -1
	li $v0, 42
	syscall                 # Make the syscall to generate random number
	
	addi $a0, $a0, 1	# Store player X and account for border
	sb $a0, ($t0)
	
	# Generate random number between 0 and height of board
	lb $a0, boardHeight	
	addi $a0, $a0, -1
	li $v0, 42
	syscall                 # Make the syscall to generate random number
	
	addi $a0, $a0, 2	# Store player Y and account for border
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
	
update_p_up:
	addi $sp, $sp, -4
	sw $ra, 4($sp)
	


	lw $ra, 4($sp)
	addi $sp, $sp, 4
	jr $ra

update_p_left:
	addi $sp, $sp, -4
	sw $ra, 4($sp)
	
	
	lw $ra, 4($sp)
	addi $sp, $sp, 4
	jr $ra

update_p_down:
	addi $sp, $sp, -4
	sw $ra, 4($sp)
		
	
	lw $ra, 4($sp)
	addi $sp, $sp, 4
	jr $ra
	
update_p_right:
	addi $sp, $sp, -4
	sw $ra, 4($sp)
	

		
	lw $ra, 4($sp)
	addi $sp, $sp, 4
	jr $ra
	
game_over:
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


# Loops to display the word "Score: "
display_score:
	addi $sp, $sp, -4
	sw  $ra, 4($sp)

	lb $t2, boardWidth
	div $t2, $t2, 2
	addi $t2, $t2, -2
	
loop_space_display_score:
	jal print_space
	
	beqz $t2, exit_loop_space_display_score
	addi $t2, $t2, -1
	
	j loop_space_display_score
	
exit_loop_space_display_score:
	la $t1, scoreLabel			# Load the address of string into $t1
	
loop_display_score:
	lb $a0, ($t1)				# Stores the according letter value in $a0
	beq $a0, $zero, exit_display_score	#If the value is null, the word ended 
	jal dspl_check_and_print
	
	# Goes to character address in string
	addi $t1, $t1, 1	
	
	j loop_display_score
	
exit_display_score:
	# Display score number
	lb $a0, score

	jal dspl_check_and_print
	
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
	
# Initializes the board display to display from beginning
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
	
	
# MAIN DISPLAY FUNCTION
DISPLAY:
	addi $sp, $sp, -4
	sw $ra, 4($sp)
	
	# Reset cursor to 0,0
	li $a0, 7
	jal dspl_check_and_print
	
	# Init current line to 0
	li $t3, 0
		
	jal display_score
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



