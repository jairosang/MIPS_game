# Imported functions:
# INIT_UTILITIES_ADDRS, INIT_DISPLAY, GET_KEYBOARD, dspl_check_and_print
# update_p_up, update_p_left, update_p_down, update_p_right
.text
jal INIT_UTILITIES_ADDRS

main:	
	
	jal INIT_DISPLAY

input_loop:
	jal GET_KEYBOARD
	beq $v0, 119, move_p_up
	beq $v0, 97, move_p_left
	beq $v0, 115, move_p_down
	beq $v0, 100, move_p_right
	
move_p_up:
	jal update_p_up
	j main
	
move_p_left:
	jal update_p_left
	j main

move_p_down:
	jal update_p_down
	j main

move_p_right:
	jal update_p_right
	j main
	
