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
collision:	.asciiz	"Collision!"
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
	
	# Counter variables
	add $s6, $s6, $zero	# Update spawn time
	add $s0, $s0, $zero	# Delay collision
	
	j SHIP
	
MAIN:	lw $t8, 0($t9)
	beq $t8, 1, KEY
	li $s2, BASE_ADDRESS	# $s1 stores the base address for display for reset purposes
	
	j SHIP
	
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
	
W_MOVE:	
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
	
A_MOVE:	
	addi $t6, $zero, -4
	j RESET_SHIP
	
S_PRESS:
	# Calculate row
	sub $t3, $t0, $s2	# Pixel - Base Address = pixel location
	div $t3, $t3, WIDTH	# Row * 4 = pixel location / width
	div $t3, $t3, 4		# Row = pixel location / width
	
	bne $t3, 28, S_MOVE
	j END_LOOP
	
S_MOVE:	
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
	
D_MOVE:	
	addi $t6, $zero, 4
	j RESET_SHIP

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

CALL_OBSTACLE:
	# Move obstacle 1
	la $t8, ($s3)
	jal OBSTACLE_COL
	la $s3, ($t8)
	blt $s6, 15, STAGGER
	
	# Move obstacle 2
	la $t8, ($s4)
	jal OBSTACLE_COL
	la $s4, ($t8)
	blt $s6, 30, STAGGER
	
	# Move obstacle 3
	la $t8, ($s5)
	jal OBSTACLE_COL
	la $s5, ($t8)

CALL_COLLISION:
	# Load in necessary parameters
	la $t4, SHIP_ARRAY
	li $t6, 0
	li $t7, SHIP_SIZE
	li $t1, 0
	li $t2, 0x6e5f29
	
	# Call Function
	jal COLLISION_LOOP
	j END_LOOP

STAGGER: 
	addi $s6, $s6, 1
	j END_LOOP

#=========================
# OBSTACLE FUNCTION
#=========================
OBSTACLE_COL:
	# Calculate obstacle column
	sub $t3, $t8, $s2	# Pixel - Base Address = pixel location
	div $t3, $t3, 4		# pixel location / 4
	div $t4, $t3, WIDTH	# pixel location / width 
	addi $t5, $zero, WIDTH	# set $t5 to width for use of multiplication
	mult $t4, $t5		# (pixel location / width) * width
	mflo $t4		# access calculation
	sub $t3, $t3, $t4	# Col = pixel location - calculation

RESET_OBSTACLE:
	li $t1, BLACK
	sw $t1, 4($t8)
	sw $t1, 8($t8)
	
	sw $t1, 256($t8)
	sw $t1, 260($t8)
	sw $t1, 264($t8)
	sw $t1, 268($t8)
	
	sw $t1, 512($t8)
	sw $t1, 516($t8)
	sw $t1, 520($t8)
	sw $t1, 524($t8)
	
	sw $t1, 772($t8)
	sw $t1, 776($t8)
	
	sub $t8, $t8, 4
	
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
	li $t8, OBSTACLE_START
	add $t8, $t8, $a0

OBSTACLE:
	li $t1, 0xcaa368	# $t1 stores the gold
	li $t2, 0x6e5f29	# $t2 stores the brown

	sw $t2, 4($t8)
	sw $t2, 8($t8)
	
	sw $t2, 256($t8)
	sw $t1, 260($t8)
	sw $t1, 264($t8)
	sw $t2, 268($t8)
	
	sw $t2, 512($t8)
	sw $t1, 516($t8)
	sw $t1, 520($t8)
	sw $t2, 524($t8)
	
	sw $t2, 772($t8)
	sw $t2, 776($t8)
	
	jr $ra

#=========================
# COLLISION FUNCTION
#=========================
COLLISION_LOOP:
	beq $t6, $t7, END_COL
	add $t3, $t4, $t6	# addr(A) + i
	#add $t3, $t3, $t0	# account for base address
	lw $s1, 0($t3)		# $s1 = A[i]
	lw $t3, ($t0)
	add $t3, $s1, $t0
	lw $t3, 0($t3)
	
	beq $t3, $t2, SHOW_COLLISION
	addi $t6, $t6, 4
	j COLLISION_LOOP
	
SHOW_COLLISION:
	bgt $s0, 0, WAIT_COL

	li $v0, 4
	la $a0, collision
	syscall
	
	addi $s0, $s0, 1
	j END_COL

WAIT_COL:
	addi $s0, $s0, 1
	bgt $s0, 4, RESET_COL
	j END_COL

RESET_COL:
	li $s0, 0

END_COL:
	jr $ra

#=========================
# END LOOP AND RESET
#=========================
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
