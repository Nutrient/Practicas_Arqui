.data
torre_A: .word 8 7 6 5 4 3 2 1
torre_B: .word 0 0 0 0 0 0 0 0
torre_C: .word 0 0 0 0 0 0 0 0
.text
main:
	la $a1, torre_A #Start
	la $a2, torre_C #Aux
	la $a3, torre_B #End
	addi $a0, $zero, 8
	mul $s1, $a0, 4
	add $a1, $a1, $s1
	addi $a1, $a1, -4
	jal hanoi
	j end
	
#Hanoi(N $a0, Start $a1, End $a2, Aux $a3)
hanoi:


	beq $a0, 1, if	

else:
	addi $sp, $sp, -20
	sw $ra, 0($sp)
	sw $a0, 4($sp)
	sw $a1, 8($sp)
	sw $a2, 12($sp)
	sw $a3, 16($sp)
	
	addi $a0, $a0, -1
	
	
	la $t0, ($a3) #change memory from AUX -> END  | A C B
	la $a3, ($a2)
	la $a2, ($t0)
	
	jal hanoi
	
	addi $a1, $a1, -4
	addi $a2, $a2, +4
	#move from Start to End (now located in aux)
	
	lw $s1, 0($a1) #MOVE START
	sw $s1, 0($a3)
	sw $zero, 0($a1)
	addi $a3, $a3, +4
	addi $a1, $a1, -4
	
	
		
	#enter hanoi again
	la $t0, ($a1) #change memory from START -> AUX  | B C A
	la $a1, ($a3)
	la $a3, ($t0)
	
	la $t0, ($a1) #change memory from END -> START | C B A
	la $a1, ($a2)
	la $a2, ($t0)
	
	
	jal hanoi
	
	
	
	
	addi $sp, $sp, +20
	lw $ra, 0($sp)
	lw $a0, 4($sp) 
	lw $a1, 8($sp)
	lw $a2, 12($sp)
	lw $a3, 16($sp)
	jr $ra

if: #if n == 1
	lw $s1, 0($a1) #MOVE START
	sw $s1, 0($a2)
	sw $zero, 0($a1)
	
	jr $ra

endHanoi:



	

end:	