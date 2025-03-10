# https://wilkinsonj.people.charleston.edu/mmio.html
# https://www.ascii-code.com
.globl main

.data
	DISPLAY_CTRL_R: .word 0xFFFF0008 #Display control register
	DISPLAY_ADDR: .word 0xFFFF000C  # Display address
	KEYBOARD_STATUS: .word 0xFFFF0000  # Address to check IF a key is pressed
	KEYBOARD_DATA: .word 0xFFFF0004    # Address to read THE key pressed
	
	score_label: .asciiz "    Score:"
	score: .byte '0'
	border: .byte '#'
	space: .byte ' '
	player: .byte 'P'
	reward: .byte 'R'
	board: .asciiz "                                                 "
	
.text 
main:
# DATA FUNCTIONS
#=============================================================================================================================================================================================
increase_score:
	lb $t0, score
	addi $t0, $t0, 1
	sb $t0, score

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

	li $a0, 10	# Print newline
	jal dspl_check_and_print
		
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
	la $t1, score_label			# Load the address of string into $t1
	addi $sp, $sp, -4
	sw  $ra, 4($sp)
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
	li $t1, 17	# Load counter in t1
	
	addi $sp, $sp, -4
	sw $ra, 4($sp)
loop_display_top_border:
	
	beqz $t1, exit_loop_display_top_border
	addi $t1, $t1, -1
	
	jal display_border

	j loop_display_top_border
	
exit_loop_display_top_border:
	lw $ra, 4($sp)
	addi $sp, $sp, 4
	jr $ra
	
# Initializes the board display to display from beginning
init_display_board:
	la $s3, board	# Load address of board
display_board:
	li $t9, 1	# Starts a counter to keep track of characters printed
	addi $sp, $sp, -4
	sw $ra, 4($sp)
	
loop_display_board_line:
	jal print_space
	lb $a0, ($s3)		# Stores the according letter value in $a0
	seq $t1, $t9, 7		# If the value is null, the word ended 
	jal dspl_check_and_print
	
	# Goes to next character in array
	addi $s3, $s3, 1
	addi $t9, $t9, 1
	
	bne  $t1, 0, exit_display_board_line	
	
	j loop_display_board_line
	
exit_display_board_line:
	jal print_space
	lw $ra, 4($sp)
	addi $sp, $sp, 4
	jr $ra
	
	
# MAIN DISPLAY FUNCTION
DISPLAY:
	addi $sp, $sp, -4
	sw $ra, 4($sp)
	
	lw $s0, DISPLAY_CTRL_R       # Copy the control register into a CPU register.
	lw $s1, DISPLAY_ADDR	# Load the address of the display into $t0
	
	li $a0, 12
	jal dspl_check_and_print
	
	jal display_score
	jal print_new_line
	
	jal display_top_border
	jal print_new_line
	
	jal display_border
	jal init_display_board
	jal display_border
	jal print_new_line
	
	li $t2, 6
dspl_loop:
	
	beqz $t2, exit_dspl_loop
	addi $t2, $t2, -1
	
	jal display_border
	jal display_board
	jal display_border
	jal print_new_line
	
	j dspl_loop
	
exit_dspl_loop:
	jal display_top_border
	
	lw $ra, 4($sp)
	addi $sp, $sp, 4
	jr $ra
	




# KEYBOARD FUNCTIONS
#============================================================================================================================================================================================







