.data
torre_A: .word 8 7 6 5 4 3 2 1
torre_B: .word 0 0 0 0 0 0 0 0
torre_C: .word 0 0 0 0 0 0 0 0
.text

main:

	la $t0, torre_A #origen
	la $t1, torre_C #aux
	la $t2, torre_B #fin
	addi $t3, $zero, 8 
	add $s0, $zero, $t3
	mul $s1, $t3, 4
	add $t0, $t0, $s1
	addi $t0, $t0, -4

	add $a0, $zero, $t3 
	
	
	#t4 sera el auxiliar para intercambiar valores de variables
	jal Hanoi
	j end

Hanoi:	
	addi $sp, $sp, -8
	sw $ra, 0($sp)
	sw $t3, 4($sp)
	
	add $t3, $zero, $a0
	#checamos si estamos hasta el tope
	beq $a0, 1, Move
	addi $a0, $t3, -1 
	#hanoi
	
	#add $t0, $t0, 4
	la $t4, ($t2)
	la $t2, ($t1)
	la $t1, ($t4)
	jal Hanoi
	#move
	lw $s1, 0($t0)
	
	
	sw $s1, 0($t2)
	sw $zero, 0($t0)
	addi $t2, $t2, +4
	addi $t0, $t0, -4	
	
	
	#hanoi
	la $t4, ($t0)
	la $t0, ($t2)
	la $t2, ($t4)
	
	la $t4, ($t0)
	la $t0, ($t1)
	la $t1, ($t4)
	
	jal Hanoi
	
	
	
exit: 	
	
	addi $sp, $sp, +8
	lw $ra, 0($sp)
	lw $t3, 4($sp)	  
	jr $ra
Move:	

	lw $s1, 0($t0)
	sw $s1, 0($t1)
	sw $zero, 0($t0)
	addi $t1, $t1, +4
	addi $t0, $t0, -4	

	j exit
	
end:
