.data 
.text
main:
	jal DISPLAY
	
	jal increase_score
	
	jal DISPLAY
	
	
	li $v0, 10
	syscall