#####################################################################
#
# CSCB58 Winter2021 Assembly Final Project
# University of Toronto, Scarborough
#
# Student: Sameer Khan, 1006104430, khans295
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8 (update this as needed)
# - Unit height in pixels: 8 (update this as needed)
# - Display width in pixels: 512 (update this as needed)
# - Display height in pixels: 256 (update this as needed)
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestones have been reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 1/2/3/4 (choose the one the applies)## Which approved features have been implementedfor milestone 4?
# (See the assignment handout for the list of additional features)
# 1. (fill in the feature, if any)
# 2. (fill in the feature, if any)
# 3. (fill in the feature, if any)
#... (add more if necessary)
#
# Link to video demonstration for final submission:
# - (insert YouTube / MyMedia / other URL here). Make sure we can view it!
#
# Are you OKwith us sharing the video with people outside course staff?
# - yes / no/ yes, and please share this project githublink as well!
#
# Any additional information that the TA needs to know:
# - (write here, if any)
######################################################################

.eqv	BASE_ADDRESS	0x10008000
.eqv 	END		0x1000A000
.eqv	OBSTACLE_START	0x100080F0
.eqv	KBD_BASE	0xffff0000
.eqv	WIDTH		64 # in "units"
.eqv	HEIGHT		32 # in "units"
.eqv	ROW_SHIFT	8 # 64 units * 4 bytes per pixel = 256 = 2^8
.eqv	REFRESH_RATE	20
.eqv 	BLACK		0x00000000
.eqv	SHIP_SIZE	40
.eqv	OBSTACLE_SIZE	32

.data
W:	.asciiz		"w"
A:	.asciiz		"a"
S:	.asciiz		"s"
D:	.asciiz		"d"
SHIP_ARRAY:    		.word    8, 12, 256, 260, 272, 512, 516, 528, 776, 780
OBSTACLE_ARRAY:    	.word    4, 8, 256, 268, 512, 524, 772, 776
exit:	.asciiz		"Exiting Game!"
.text
.globl SETUP

SETUP: 	li $t0, BASE_ADDRESS	# $t0 stores the base address for display
	li $t9, KBD_BASE	# $t9 stores the keyboard base address
	addi $s0, $s0, 0	# set $s0 to counter for loops
	
	#OBSTACLE 1:
	li $v0, 42
	li $a0, 0
	li $a1, 28
	syscall
	
	addi $t2, $zero, 256
	mult $a0, $t2
	mflo $a0
	li $s3, OBSTACLE_START
	add $s3, $s3, $a0
	
	#OBSTACLE 2:
	li $v0, 42
	li $a0, 0
	li $a1, 28
	syscall
	
	addi $t2, $zero, 256
	mult $a0, $t2
	mflo $a0
	li $s4, OBSTACLE_START
	add $s4, $s4, $a0
	
	#OBSTACLE 3:
	li $v0, 42
	li $a0, 0
	li $a1, 28
	syscall
	
	addi $t2, $zero, 256
	mult $a0, $t2
	mflo $a0
	li $s5, OBSTACLE_START
	add $s5, $s5, $a0
	
	j SHIP
	
MAIN:	lw $t8, 0($t9)
	beq $t8, 1, KEY
	li $s2, BASE_ADDRESS	# $s1 stores the base address for display for reset purposes
	
	j SHIP
	#j RESET
	
KEY:	lw $t2, 4($t9) # this assumes $t9 is set to 0xfff0000from before
	beq $t2, 0x77, W_PRESS # ASCII code of 'w' is 0x77
	beq $t2, 0x61, A_PRESS # ASCII code of 'a' is 0x61
	beq $t2, 0x73, S_PRESS # ASCII code of 's' is 0x73
	beq $t2, 0x64, D_PRESS # ASCII code of 'd' is 0x64
	beq $t2, 0x78, EXIT
	j END_LOOP
	
W_PRESS:
	# Calculate row
	sub $t3, $t0, $s2	# Pixel - Base Address = pixel location
	div $t3, $t3, WIDTH	# Row * 4 = pixel location / width
	div $t3, $t3, 4		# Row = pixel location / width
	
	bne $t3, 0, W_MOVE
	j END_LOOP
	
W_MOVE:	#addi $t0, $t0, -256
	addi $t6, $zero, -256
	j RESET_SHIP
	
A_PRESS:
	# Calculate col
	sub $t3, $t0, $s2	# Pixel - Base Address = pixel location
	div $t3, $t3, 4		# pixel location / 4
	div $t4, $t3, WIDTH	# pixel location / width 
	addi $t5, $zero, WIDTH	# set $t5 to width for use of multiplication
	mult $t4, $t5		# (pixel location / width) * width
	mflo $t4		# access calculation
	sub $t3, $t3, $t4	# Col = pixel location - calculation
	
	bne $t3, 0, A_MOVE
	j END_LOOP
	
A_MOVE:	#addi $t0, $t0, -4
	addi $t6, $zero, -4
	j RESET_SHIP
	
S_PRESS:
	# Calculate row
	sub $t3, $t0, $s2	# Pixel - Base Address = pixel location
	div $t3, $t3, WIDTH	# Row * 4 = pixel location / width
	div $t3, $t3, 4		# Row = pixel location / width
	
	bne $t3, 28, S_MOVE
	j END_LOOP
	
S_MOVE:	#addi $t0, $t0, 256
	addi $t6, $zero, 256
	j RESET_SHIP
	
D_PRESS:
	# Calculate col
	sub $t3, $t0, $s2	# Pixel - Base Address = pixel location
	div $t3, $t3, 4		# pixel location / 4
	div $t4, $t3, WIDTH	# pixel location / width 
	addi $t5, $zero, WIDTH	# set $t5 to width for use of multiplication
	mult $t4, $t5		# (pixel location / width) * width
	mflo $t4		# access calculation
	sub $t3, $t3, $t4	# Col = pixel location - calculation

	bne $t3, 59, D_MOVE
	j END_LOOP
	
D_MOVE:	#addi $t0, $t0, 4
	addi $t6, $zero, 4
	j RESET_SHIP
	
#RESET:	li $s1, END		# Load end location
#	beq $s2, $s1, SHIP	# Check if reset has reached end, jump to ship if it has
#	li $t1, BLACK		# Load in black colour
#	sw $t1, 0($s2)		# Set pixel to black
#	addi $s2, $s2, 4	# Add 4 to pixel count
#	j RESET			# Loop to reset

RESET_SHIP:	
	li $t1, BLACK
	sw $t1, 8($t0)		 
	sw $t1, 12($t0)
	
	sw $t1, 256($t0)
	sw $t1, 260($t0)
	sw $t1, 264($t0)
	sw $t1, 268($t0)
	sw $t1, 272($t0)
	
	sw $t1, 512($t0)
	sw $t1, 516($t0)
	sw $t1, 520($t0)
	sw $t1, 524($t0)
	sw $t1, 528($t0)
	
	sw $t1, 776($t0)		 
	sw $t1, 780($t0)
	add $t0, $t0, $t6

SHIP:	li $t1, 0xede7f6	# $t1 stores the gray
	li $t2, 0x837cc2	# $t2 stores the purple
	li $t3, 0xff5252	# $t3 stores the red
	li $t4, 0x42a5f5	# $t4 stores the blue

	sw $t1, 8($t0)		 
	sw $t1, 12($t0)
	
	sw $t3, 256($t0)
	sw $t2, 260($t0)
	sw $t1, 264($t0)
	sw $t4, 268($t0)
	sw $t1, 272($t0)
	
	sw $t3, 512($t0)
	sw $t2, 516($t0)
	sw $t1, 520($t0)
	sw $t4, 524($t0)
	sw $t1, 528($t0)
	
	sw $t1, 776($t0)		 
	sw $t1, 780($t0)

#=========================
# OBSTACLE 1
#=========================
OBSTACLE_COL:
	# Calculate obstacle column
	sub $t3, $s3, $s2	# Pixel - Base Address = pixel location
	div $t3, $t3, 4		# pixel location / 4
	div $t4, $t3, WIDTH	# pixel location / width 
	addi $t5, $zero, WIDTH	# set $t5 to width for use of multiplication
	mult $t4, $t5		# (pixel location / width) * width
	mflo $t4		# access calculation
	sub $t3, $t3, $t4	# Col = pixel location - calculation

RESET_OBSTACLE:
	li $t1, BLACK
	sw $t1, 4($s3)
	sw $t1, 8($s3)
	
	sw $t1, 256($s3)
	sw $t1, 260($s3)
	sw $t1, 264($s3)
	sw $t1, 268($s3)
	
	sw $t1, 512($s3)
	sw $t1, 516($s3)
	sw $t1, 520($s3)
	sw $t1, 524($s3)
	
	sw $t1, 772($s3)
	sw $t1, 776($s3)
	
	sub $s3, $s3, 4
	
	beqz $t3, SPAWN_OBSTACLE
	j OBSTACLE

SPAWN_OBSTACLE:	
	li $v0, 42
	li $a0, 0
	li $a1, 28
	syscall
	
	addi $t2, $zero, 256
	mult $a0, $t2
	mflo $a0
	li $s3, OBSTACLE_START
	add $s3, $s3, $a0

OBSTACLE:
	li $t1, 0xcaa368	# $t1 stores the gold
	li $t2, 0x6e5f29	# $t2 stores the brown

	sw $t2, 4($s3)
	sw $t2, 8($s3)
	
	sw $t2, 256($s3)
	sw $t1, 260($s3)
	sw $t1, 264($s3)
	sw $t2, 268($s3)
	
	sw $t2, 512($s3)
	sw $t1, 516($s3)
	sw $t1, 520($s3)
	sw $t2, 524($s3)
	
	sw $t2, 772($s3)
	sw $t2, 776($s3)

#=========================
# OBSTACLE 2
#=========================
OBSTACLE_COL2:
	# Calculate obstacle column
	sub $t3, $s4, $s2	# Pixel - Base Address = pixel location
	div $t3, $t3, 4		# pixel location / 4
	div $t4, $t3, WIDTH	# pixel location / width 
	addi $t5, $zero, WIDTH	# set $t5 to width for use of multiplication
	mult $t4, $t5		# (pixel location / width) * width
	mflo $t4		# access calculation
	sub $t3, $t3, $t4	# Col = pixel location - calculation

RESET_OBSTACLE2:
	li $t1, BLACK
	sw $t1, 4($s4)
	sw $t1, 8($s4)
	
	sw $t1, 256($s4)
	sw $t1, 260($s4)
	sw $t1, 264($s4)
	sw $t1, 268($s4)
	
	sw $t1, 512($s4)
	sw $t1, 516($s4)
	sw $t1, 520($s4)
	sw $t1, 524($s4)
	
	sw $t1, 772($s4)
	sw $t1, 776($s4)
	
	sub $s4, $s4, 4
	
	beqz $t3, SPAWN_OBSTACLE2
	j OBSTACLE2

SPAWN_OBSTACLE2:	
	li $v0, 42
	li $a0, 0
	li $a1, 28
	syscall
	
	addi $t2, $zero, 256
	mult $a0, $t2
	mflo $a0
	li $s4, OBSTACLE_START
	add $s4, $s4, $a0

OBSTACLE2:
	li $t1, 0xcaa368	# $t1 stores the gold
	li $t2, 0x6e5f29	# $t2 stores the brown

	sw $t2, 4($s4)
	sw $t2, 8($s4)
	
	sw $t2, 256($s4)
	sw $t1, 260($s4)
	sw $t1, 264($s4)
	sw $t2, 268($s4)
	
	sw $t2, 512($s4)
	sw $t1, 516($s4)
	sw $t1, 520($s4)
	sw $t2, 524($s4)
	
	sw $t2, 772($s4)
	sw $t2, 776($s4)

#=========================
# OBSTACLE 3
#=========================
OBSTACLE_COL3:
	# Calculate obstacle column
	sub $t3, $s5, $s2	# Pixel - Base Address = pixel location
	div $t3, $t3, 4		# pixel location / 4
	div $t4, $t3, WIDTH	# pixel location / width 
	addi $t5, $zero, WIDTH	# set $t5 to width for use of multiplication
	mult $t4, $t5		# (pixel location / width) * width
	mflo $t4		# access calculation
	sub $t3, $t3, $t4	# Col = pixel location - calculation

RESET_OBSTACLE3:
	li $t1, BLACK
	sw $t1, 4($s5)
	sw $t1, 8($s5)
	
	sw $t1, 256($s5)
	sw $t1, 260($s5)
	sw $t1, 264($s5)
	sw $t1, 268($s5)
	
	sw $t1, 512($s5)
	sw $t1, 516($s5)
	sw $t1, 520($s5)
	sw $t1, 524($s5)
	
	sw $t1, 772($s5)
	sw $t1, 776($s5)
	
	sub $s5, $s5, 4
	
	beqz $t3, SPAWN_OBSTACLE3
	j OBSTACLE3

SPAWN_OBSTACLE3:	
	li $v0, 42
	li $a0, 0
	li $a1, 28
	syscall
	
	addi $t2, $zero, 256
	mult $a0, $t2
	mflo $a0
	li $s5, OBSTACLE_START
	add $s5, $s5, $a0

OBSTACLE3:
	li $t1, 0xcaa368	# $t1 stores the gold
	li $t2, 0x6e5f29	# $t2 stores the brown

	sw $t2, 4($s5)
	sw $t2, 8($s5)
	
	sw $t2, 256($s5)
	sw $t1, 260($s5)
	sw $t1, 264($s5)
	sw $t2, 268($s5)
	
	sw $t2, 512($s5)
	sw $t1, 516($s5)
	sw $t1, 520($s5)
	sw $t2, 524($s5)
	
	sw $t2, 772($s5)
	sw $t2, 776($s5)

#	la $s6, SHIP_ARRAY
#	la $s7, OBSTACLE_ARRAY
#	addi $t6, $t6, -4
#	add $t7, $t7, $zero

#COLLISION_LOOP:
#	addi $t6, $t6, 4
#	beq $t6, SHIP_SIZE, END_LOOP
#	j COLLISION_INNER

#COLLISION_INNER:
#	beq $t7, OBSTACLE_SIZE, COLLISION_LOOP
#	add $t1, $s6, $t6	# addr(A) + i
#	add $t2, $s7, $t7	# arrd(B) + i
#	
#	lw $t3, 0($t1)		# $t3 = A[i]
#	lw $t4, 0($t2)		# $t4 = B[i]
#	
#	add $t3, $t3, $t0	# account for base address
#	add $t4, $t4, $s3	# account for base address
#	
#	beq $t3, $t4, SHOW_COLLISION
#	
#	addi $t7, $t7, 4
#	j COLLISION_LOOP
#
#SHOW_COLLISION:
#	li $t1, 0xff0000
#	sw $t1, 0($t0)
#	
END_LOOP:

	# SLEEP 1 SECOND
	li $v0, 32
	li $a0, REFRESH_RATE  # Wait REFRESH_RATE amount of seconds
	syscall
	j MAIN
	
EXIT:	# Print Exit String
	li $v0, 4
	la $a0, exit
	syscall
	
	# Terminate program
	li $v0, 10
	syscall
