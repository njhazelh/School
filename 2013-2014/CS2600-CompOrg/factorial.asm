#########################################
# Factorial Program
# Author: Nicholas Jones
# Date: 9/12/2013
# Computer Organization
#
# int factorial(int n) {
#     if (n <= 0)
#         return 1;
#     else
#         return n * factorial(--n);
# }
#
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
	
	# if (n == 0)
	blez  $t0, else
	
	#begin prologue
	addi $sp, $sp, -8
	sw   $ra, 0($sp)
	sw   $t0, 4($sp)
	# end prologue
	
	# recursive call
	addi $t0, $t0, -1
	move $a0, $t0
	jal  fact
	
	lw   $t0, 4($sp) # get n from call frame
	move $t1, $v0    # get result of recursion
	mult $t0, $t1    # n * recursive-result
	mflo $t0         # move result to $t0
	move $v0, $t0    # set as return value
	
	# begin epilogue
	lw   $ra, 0($sp)
	addi $sp, $sp, 8
	# end epilogue
	
	j    endif
else:
	li $v0, 1 # else return 1;
endif:
	jr $ra #return
