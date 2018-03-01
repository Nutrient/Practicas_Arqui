.data
torre_A: .word 8 7 6 5 4 3 2 1
torre_B: .word 0 0 0 0 0 0 0 0
torre_C: .word 0 0 0 0 0 0 0 0
.text

main:
	addi $t7, $zero, 268500992
	
	#la $a1, torre_A #Start  
	#la $a2, torre_C #End
	#la $a3, torre_B #Aux
	ori $a1, $t7, 0  #Start
	ori $a2, $t7, 64 #End 
	ori $a3, $t7, 32 #Aux
	addi $a0, $zero, 8 #counter
	add $s2, $zero, $a0 #sub counter
	sll $s1, $a0, 2
	add $a1, $a1, $s1
	addi $a1, $a1, -4
	
	
	
	jal hanoi
	j end
	
hanoi:
	
	beq $a0, 1, if	
else:
	addi $sp, $sp, -20
	sw $ra, 0($sp)
	sw $a0, 4($sp)
	#sw $a1, 8($sp)
	#sw $a2, 12($sp)
	#sw $a3, 16($sp)
	
	addi $a0, $a0, -1
	
	addi $t0, $a3, 0 #change memory from AUX -> END  | A C B
	addi $a3, $a2, 0
	addi $a2, $t0, 0
	
	jal hanoi
	#addi $a2, $a2, +4
	#addi $a1, $a1, -4
	#move from Start to End (now located in aux)
	
	lw $s1, 0($a1) #MOVE START
	sw $s1, 0($a3)
	sw $zero, 0($a1)
	addi $a3, $a3, +4
	addi $a1, $a1, -4
	

		
	#enter hanoi again
	addi $t0, $a1, 0 #change memory from START -> AUX  | B C A
	addi $a1, $a3, 0
	addi $a3, $t0, 0
	
	addi $t0, $a1, 0 #change memory from END -> START | C B A
	addi $a1, $a2, 0
	addi $a2, $t0, 0
	
	addi $a1, $a1, -4 
	addi $a3, $a3, 4
	jal hanoi
	addi $a1, $a1, 4
	addi $a3, $a3, -4
	
	addi $t0, $a1, 0
	addi $a1, $a3, 0
	addi $a3, $t0, 0
	
	lw $ra, 0($sp)
	lw $a0, 4($sp)
	#lw $a1, 8($sp)
	#lw $a2, 12($sp)
	#lw $a3, 16($sp)
	addi $sp, $sp, 20
	jr $ra
	

if: #if n == 1
	lw $s1, 0($a1) #MOVE START
	sw $s1, 0($a2)
	sw $zero, 0($a1)
	addi $a2, $a2, +4
	addi $a1, $a1, -4
	jr $ra

end:	
	
