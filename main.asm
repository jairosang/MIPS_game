# Imported initializers:
# INIT_UTILITIES_ADDRS, INIT_CHARACTER, INIT_REWARD, DISPLAY

# Imported get and print functions: GET_KEYBOARD, dspl_check_and_print
# Imported functions: update_p_up, update_p_left, update_p_down, update_p_right, cursor_go_to

# Imported checks: 
# collission_player_border, collision_player_reward
.text
jal INIT_UTILITIES_ADDRS
jal DISPLAY

main:	
	jal INIT_CHARACTER
	jal INIT_REWARD
	
input_loop:
	jal collission_player_border
	jal collision_player_reward
	jal GET_KEYBOARD
	
	
	# Keyboard input conditions
	beq $v0, 119, move_p_up
	beq $v0, 97, move_p_left
	beq $v0, 115, move_p_down
	beq $v0, 100, move_p_right
	
	# If the incorrect key is pressed ignore and check again for input
	j input_loop
	
move_p_up:
	jal update_p_up
	j input_loop
	
move_p_left:
	jal update_p_left
	j input_loop

move_p_down:
	jal update_p_down
	j input_loop

move_p_right:
	jal update_p_right
	j input_loop
	
