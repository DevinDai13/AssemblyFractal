# The following format is required for all submissions in CMPUT 229
#
# The following copyright notice does not apply to this file
# It is included here because it should be included in all
# solutions submitted by students.
#
#----------------------------------------------------------------
# Copyright 2017 <Devin Dai>
#
# Redistribution is forbidden in all circumstances. Use of this software
# without explicit authorization from the author is prohibited.
#
# This software was produced as a solution for an assignment in the course
# CMPUT 229 - Computer Organization and Architecture I at the University of
# Alberta, Canada. This solution is confidential and remains confidential 
# after it is submitted for grading.
#
# Copying any part of this solution without including this copyright notice
# is illegal.
#
# If any portion of this software is included in a solution submitted for
# grading at an educational institution, the submitter will be subject to
# the sanctions for plagiarism at that institution.
#
# If this software is found in any public website or public repository, the
# person finding it is kindly requested to immediately report, including 
# the URL or other repository locating information, to the following email
# address:
#
#          wdai@ualberta.ca
#
#---------------------------------------------------------------
# Lab:                  2
# Due Date:             October,10,2017
# Name:                 Devin Dai
# Student ID:           1501722
# Lecture Section:      A1
# Instructor:           Jose Nelson
# Lab Section:          D05
# Teaching Assistant:   Rong Feng
#---------------------------------------------------------------

#---------------------------------------------------------------
# The set_size function sets the boundaries and the step sizes used by the 
# map_coords function so that it properly maps coordinates to the desired 
# portion of the complex plane.

# Register Usage (argeuments): 

#	$f12 = maximum imaginary value being rendered, set max_i to this value.
#	$f14 = minimum imaginary value being rendered
#	$f16 = maximum real value being rendered
#	$f18 = minimum real value being rendered, set min_r to this value.
#	$a0 = number of rows in the screen
#	$a1 = number of columns in the screen
#	$ra = return register
#---------------------------------------------------------------


#---------------------------------------------------------------
# The calculate_escape function:
# Given a complex number c and a maximum number of iterations, determine if 
# c escapes within the specified number of iterations. If 
# c does escape, also return the number of iterations until the recursion escaped
#
#
# Register Usage:
#	Arguments:
#	$a0 = the max number of iterations.
#	$f0 = x_0: Initial real value of the complex number
#	$f2 = y_0: Initial imaginary value of the complex number
#
#	Return Values:
#	$v0 = 1 if the number escaped before the max number of iterations. other wise 0.
#	$v1 = The number of iterations the algorithm went through before stopping. 
#       
#	others:
#	$t0 = iteration counter
#	$t1 = max iteration (storage)
#	$ra = return register
#---------------------------------------------------------------


#---------------------------------------------------------------
# The render function uses two lists and three variables pre-defined in the  
# common.s file to print each tile in the screen.
#	
# Register Usage:
#
#       $s2 = number of Rows in screen
#	$s3 = number of Columns in the screen
#	$s4 = max number of iterations
#	$s0 = row counter
#	$s1 = col counter
#	$s5 = color at position
#	$s6 = symbol at position
#	$ra = return register
#---------------------------------------------------------------

.text
set_size:
	#li.d $f12, 5.0
	#li.d $f18, 1.0
	#li $a1, 4

	mtc1 $a0, $f4       	# copy row to temp reg
	cvt.d.w $f6, $f4    	# convert int to double
	sub.d $f8, $f12, $f14
	div.d $f10, $f8, $f6
	s.d $f10, step_i
	
	
	mtc1 $a1, $f4       	# copy column to temp reg
	cvt.d.w $f6, $f4    	# convert int to double
	sub.d $f8, $f16, $f18
	div.d $f10, $f8, $f6
	s.d $f10, step_r
	
	s.d $f12, max_i 	# store to max_i

	s.d $f18, min_r 	# store to min_r
	
	jr $ra
	
	
.text
calculate_escape:
	l.d $f0, x_0
	l.d $f2, y_0
	mov.d $f4, $f0 	# x = x_0
	mov.d $f6,$f2	# y = y_0
	li $t0, 0
	move $t1, $a0		# move max iteration to t1

while:
	mul.d $f8, $f4, $f4	# x^2
	mul.d $f10, $f6, $f6	# y^2
	add.d $f12, $f10, $f8	# x^2 + y^2
	li.d $f14, 4.0
	c.lt.d $f12, $f14	#(x^2 + y^2) < 4
	bc1f escape


	sub.d $f12, $f8, $f10	# x^2 - y^2
	add.d $f12, $f12, $f0	#(x^2 - y^2) + x_0
	mul.d $f14, $f4, $f6	# x*y
	li.d $f16, 2.0
	mul.d $f16, $f16, $f14	# x*y*2
	add.d $f6,  $f16, $f2	# (x*y*2) + y_0
	
	mov.d $f4, $f12		# x = xtemp

	addi $t0, $t0, 1	# iteration + 1

	beq $t0, $t1, not_escape
	
	j while

escape:
	li $v0, 1
	move $v1, $t0
	
	jr $ra

not_escape:
	li $v0, 0
	move $v1, $t1

	jr $ra

.text
render:
	
	addi, $sp, $sp, -32	# initialize stack by 
	sw $s6, 28($sp)		# sotring value from before
	sw $s5, 24($sp)
	sw $ra, 20($sp)
	sw $s0, 16($sp)
	sw $s1, 12($sp)
	sw $s2, 8($sp)
	sw $s3, 4($sp)
	sw $s4, 0($sp)
	

	li $s0, -1		# row counter
	li $s1, -1		# col counter 
	addi $s2, $a0, 0	# row
	addi $s3, $a1, 0	# col
	addi $s4, $a2, 0	# max iteration
	j row_loop

	
row_loop:
	li $s1, -1		# col counter to -1 since it's at the begining
	addi $s0, $s0, 1
	beq $s0, $s2, quit
	j col_loop

col_loop:
	addi $s1, $s1, 1 	# increament col counter
	beq $s3, $s1, row_loop

	addi $a0, $s0, 0	#row counter for map coord
	addi $a1, $s1, 0	#col counter for map coord
	jal map_coords
	
	addi $a0, $s4, 0	# max interation for escape
	s.d $f0, x_0		# put f0 value from map coord to label for escape
	s.d $f2, y_0		# put f2 value from map coord to label for escape
	jal calculate_escape

	beq $v0, $zero, false
	beq $v0, 1, not_false


false:
	lb $s5, inSetColor   	# s5 has insetcolor		
	la $s6, inSetSymbol  	# s6 has insetsymbol
			
	j continue

not_false:
	lw $t8, paletteSize
	rem $t8, $v1, $t8
	
	la $s5, colors		# la color into s5
	add $s5, $s5, $t8 	# mod + address = position
	lbu $s5, 0($s5) 	# color at position
	
	sll $t8, $t8, 1		# multipy mod by 2
	la $s6, symbols		# load symbol address
	add $s6, $s6, $t8	# add that to address of symbol to get the final address
		

continue:
	li $a1, 0      		# $a1 = 0 setting background
	addi $a0, $s5, 0        # $a0 = selected color code from before
	
	jal setColor

	addi $a1, $s0, 0        # $a1 = row counter
	addi $a2, $s1, 0        # $a2 = col counter
	addi $a0, $s6, 0        # $a0 = address of string to print
	
	jal printString
	

	j col_loop
	

quit:
	lw $s6, 28($sp)
	lw $s5, 24($sp)
	lw $ra, 20($sp)
	lw $s0, 16($sp)
	lw $s1, 12($sp)
	lw $s2, 8($sp)
	lw $s3, 4($sp)
	lw $s4, 0($sp)
	addi, $sp, $sp, 32	# restore the stack values after using
	
	jr $ra	



































