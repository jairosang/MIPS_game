# Imported initializers:
# INIT_UTILITIES_ADDRS, INIT_CHARACTER, INIT_REWARD, INIT_ENEMY, INIT_DISPLAY

# Imported get and print functions: GET_KEYBOARD, dspl_check_and_print
# Imported functions: update_p_up, update_p_left, update_p_down, update_p_right, cursor_go_to, move_enemy

# Imported checks: COLLISION_CHECKS
# Vars: playerX, playerY
.text
.globl main
main:	
	jal INIT_UTILITIES_ADDRS
	jal INIT_DISPLAY
	jal INIT_CHARACTER
	jal INIT_ENEMY
	jal INIT_REWARD
	
input_loop:
	jal COLLISION_CHECKS
	jal GET_KEYBOARD
	
	# Keyboard input conditions
	beq $v0, 119, move_p_up
	beq $v0, 97, move_p_left
	beq $v0, 115, move_p_down
	beq $v0, 100, move_p_right
	
	# If the incorrect key is pressed ignore and check again for input
	j input_loop
	
move_p_up:
	li $a0, -1
	li $a1, 3
	la $a2, playerY
	jal update_p
	jal move_enemy
	j input_loop
	
move_p_left:
	li $a0, -1
	li $a1, 3
	la $a2, playerX
	jal update_p
	jal move_enemy
	j input_loop

move_p_down:
	li $a0, 1
	li $a1, -3
	la $a2, playerY
	jal update_p
	jal move_enemy
	j input_loop

move_p_right:
	li $a0, 1
	li $a1, -3
	la $a2, playerX
	jal update_p
	jal move_enemy
	j input_loop
	
