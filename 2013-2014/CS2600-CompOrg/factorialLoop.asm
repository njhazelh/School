# Factorial Program with loop instead of recursion.
# Author: Nicholas Jones
# Date: 9/12/2013
# Computer Organization
.globl main
         .data
prompt:  .asciiz "Enter an  positive integer: "
result1: .asciiz "Result of factorial("
result2: .asciiz ") is: "

         .text
main:
        # print  prompt
        li $v0, 4
        la $a0, prompt
        syscall
	
        # read integer
        li $v0, 5
        syscall
	
        # store input
        add $sp, $sp, -4
        sw $v0, 0($sp)
        
        # do factorial
        move $a0, $v0
        jal fact
        move $t0, $v0
	
	# print 1st part for result string
	la $a0, result1
	li $v0, 4
	syscall
	
	# print input number
	li $v0, 1
	lw $a0, 0($sp)
	add $sp, $sp, 4
	syscall
	
	# print rest of result string
	li $v0, 4
	la $a0, result2
	syscall
	
	# print result of fact
	li $v0, 1
	move $a0, $t0
	syscall
	
	# exit
	li $v0, 10
	syscall


fact:
	move $t0, $a0
	li $t1, 1
loop:	blez $t0, endloop
	mult $t0, $t1
	addi $t0, $t0, -1
	mflo $t1
	b loop
endloop:
	move $v0, $t1
	jr $ra
