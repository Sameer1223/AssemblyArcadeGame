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
# 1. Smooth Graphics
# 2. Game Difficulty Increases Over Time (Asteroid Speed)
# 3. Scoring
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
.eqv	REFRESH_RATE	40
.eqv	LOW_REFRESH	10
.eqv 	BLACK		0x00000000
.eqv	SHIP_SIZE	40
.eqv	OBSTACLE_SIZE	32
.eqv	HEALTH_ADDRESS	0x10009E08
.eqv	HEALTH_SIZE	5

.data
SHIP_ARRAY:    		.word    8, 12, 256, 260, 272, 512, 516, 528, 776, 780
OBSTACLE_ARRAY:    	.word    4, 8, 256, 268, 512, 524, 772, 776
exit:	.asciiz		"Exiting Game!"
restart:	.asciiz	"Restarting!"
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
	add $s7, $s7, $zero	# Collision count
	
	j SHIP
	
MAIN:	lw $t8, 0($t9)
	beq $t8, 1, KEY
	li $s2, BASE_ADDRESS	# $s1 stores the base address for display for reset purposes
	
	j SHIP
	
KEY:	lw $t2, 4($t9) # this assumes $t9 is set to 0xfff0000 from before
	beq $t2, 0x77, W_PRESS # ASCII code of 'w' is 0x77
	beq $t2, 0x61, A_PRESS # ASCII code of 'a' is 0x61
	beq $t2, 0x73, S_PRESS # ASCII code of 's' is 0x73
	beq $t2, 0x64, D_PRESS # ASCII code of 'd' is 0x64
	beq $t2, 0x78, EXIT
	j CALC_REFRESH
	
W_PRESS:
	# Calculate row
	sub $t3, $t0, $s2	# Pixel - Base Address = pixel location
	div $t3, $t3, WIDTH	# Row * 4 = pixel location / width
	div $t3, $t3, 4		# Row = pixel location / width
	
	bne $t3, 0, W_MOVE
	j CALC_REFRESH
	
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
	j CALC_REFRESH
	
A_MOVE:	
	addi $t6, $zero, -4
	j RESET_SHIP
	
S_PRESS:
	# Calculate row
	sub $t3, $t0, $s2	# Pixel - Base Address = pixel location
	div $t3, $t3, WIDTH	# Row * 4 = pixel location / width
	div $t3, $t3, 4		# Row = pixel location / width
	
	bne $t3, 28, S_MOVE
	j CALC_REFRESH
	
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
	j CALC_REFRESH
	
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
	
	blt $s6, 1500, TIME_TRACK
	addi $s6, $s6, 1

CALL_COLLISION:
	# Load in necessary parameters
	la $t4, SHIP_ARRAY
	li $t6, 0
	li $t7, SHIP_SIZE
	li $t1, 0
	li $t2, 0x6e5f29
	
	# Call Function
	jal COLLISION_LOOP
	j HEALTHBAR

STAGGER: 
	addi $s6, $s6, 1
	j HEALTHBAR

TIME_TRACK:
	addi $s6, $s6, 1
	j CALL_COLLISION

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
	addi $s7, $s7, 1	# Add weighted collision
	
	li $t1, 0xff0000
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
	
	addi $s0, $s0, 1	# Add delay for collision
	j END_COL

# Delay collision
WAIT_COL:
	addi $s0, $s0, 1
	bgt $s0, 4, RESET_COL
	j END_COL

RESET_COL:
	li $s0, 0

END_COL:
	jr $ra

#=========================
# HEALTHBAR
#=========================
HEALTHBAR:
	# Load in parameters
	li $t1, 0x5dcbc0	# $t1 stores the green
	li $t3, 0
	li $t4, HEALTH_ADDRESS
	li $t5, HEALTH_SIZE
	sub $t5, $t5, $s7
	
	# Game over screen
	beq $t5, 0, GAME_OVER
	# If game not over show health remaining
	jal SHOWBAR
	
	# Show health bar
	li $t3, 0
	li $t1, 0xfa4454
	jal RESET_BAR
	
	j CALC_REFRESH

SHOWBAR:
	# Show green colour for health remaining
	sw $t1, 0($t4)
	addi $t4, $t4, 4
	addi $t3, $t3, 1
	bne $t3, $t5, SHOWBAR
	jr $ra

RESET_BAR:
	# Show red for missing health
	beq $t3, $s7, END_BAR
	sw $t1, 0($t4)
	addi $t4, $t4, 4
	addi $t3, $t3, 1
	bne $t3, $s7, RESET_BAR

END_BAR:
	jr $ra

#=========================
# GAME OVER
#=========================
GAME_OVER:
	li $t1, BASE_ADDRESS
	li $t2, END
	li $t3, 0xfcdb03
	
SCREEN_RESET:
	sw $t3, 0($t1)
	addi $t1, $t1, 4
	bne $t1, $t2, SCREEN_RESET
	
GAME_OVER_SCREEN:
	li $t1, BASE_ADDRESS
	li $t2, 0x000000
	
	# G LETTER
	sw $t2, 260($t1)
	sw $t2, 264($t1)
	sw $t2, 268($t1)
	sw $t2, 272($t1)
	
	sw $t2, 516($t1)
	
	sw $t2, 772($t1)
	sw $t2, 780($t1)
	sw $t2, 784($t1)
	
	sw $t2, 1028($t1)
	sw $t2, 1040($t1)
	
	sw $t2, 1284($t1)
	sw $t2, 1288($t1)
	sw $t2, 1292($t1)
	sw $t2, 1296($t1)
	
	# A LETTER
	sw $t2, 280($t1)
	sw $t2, 284($t1)
	sw $t2, 288($t1)
	sw $t2, 292($t1)
	
	sw $t2, 536($t1)
	sw $t2, 548($t1)
	
	sw $t2, 792($t1)
	sw $t2, 804($t1)
	
	sw $t2, 1048($t1)
	sw $t2, 1052($t1)
	sw $t2, 1056($t1)
	sw $t2, 1060($t1)
	
	sw $t2, 1304($t1)
	sw $t2, 1316($t1)
	
	# M LETTER
	sw $t2, 300($t1)
	sw $t2, 316($t1)
	
	sw $t2, 556($t1)
	sw $t2, 560($t1)
	sw $t2, 568($t1)
	sw $t2, 572($t1)
	
	sw $t2, 812($t1)
	sw $t2, 820($t1)
	sw $t2, 828($t1)
	
	sw $t2, 1068($t1)
	sw $t2, 1084($t1)
	
	sw $t2, 1324($t1)
	sw $t2, 1340($t1)
	
	# E LETTER
	sw $t2, 324($t1)
	sw $t2, 328($t1)
	sw $t2, 332($t1)
	sw $t2, 336($t1)
	
	sw $t2, 580($t1)
	
	sw $t2, 836($t1)
	sw $t2, 840($t1)
	sw $t2, 844($t1)
	
	sw $t2, 1092($t1)
	
	sw $t2, 1348($t1)
	sw $t2, 1352($t1)
	sw $t2, 1356($t1)
	sw $t2, 1360($t1)
	
	# O LETTER
	sw $t2, 6836($t1)
	sw $t2, 6840($t1)
	
	sw $t2, 7088($t1)
	sw $t2, 7100($t1)
	
	sw $t2, 7344($t1)
	sw $t2, 7356($t1)
	
	sw $t2, 7600($t1)
	sw $t2, 7612($t1)
	
	sw $t2, 7860($t1)
	sw $t2, 7864($t1)
	
	# V LETTER
	sw $t2, 6852($t1)
	sw $t2, 6864($t1)
	
	sw $t2, 7108($t1)
	sw $t2, 7120($t1)
	
	sw $t2, 7364($t1)
	sw $t2, 7376($t1)
	
	sw $t2, 7620($t1)
	sw $t2, 7632($t1)
	
	sw $t2, 7880($t1)
	sw $t2, 7884($t1)
	
	# E LETTER 
	sw $t2, 6872($t1)
	sw $t2, 6876($t1)
	sw $t2, 6880($t1)
	sw $t2, 6884($t1)
	
	sw $t2, 7128($t1)
	
	sw $t2, 7384($t1)
	sw $t2, 7388($t1)
	sw $t2, 7392($t1)
	
	sw $t2, 7640($t1)
	
	sw $t2, 7896($t1)
	sw $t2, 7900($t1)
	sw $t2, 7904($t1)
	sw $t2, 7908($t1)
	
	# R LETTER
	sw $t2, 6892($t1)
	sw $t2, 6896($t1)
	sw $t2, 6900($t1)
	sw $t2, 6904($t1)
	
	sw $t2, 7148($t1)
	sw $t2, 7160($t1)
	
	sw $t2, 7404($t1)
	sw $t2, 7416($t1)
	
	sw $t2, 7660($t1)
	sw $t2, 7664($t1)
	sw $t2, 7668($t1)
	
	sw $t2, 7916($t1)
	sw $t2, 7928($t1)

DRAW_SCORE:
	li $t1, 0x10009A04
	li $t2, 0x1f61b8
	
	# Divide by 1000 to find thousanth digit
	div $t3, $s6, 1000
	jal CHECK_DIGIT
	addi $t1, $t1, 16
	li $t4, 1000
	mult $t3, $t4
	mflo $t4
	sub $s6, $s6, $t4
	
	# Divide by 100 to find hundreth digit
	div $t3, $s6, 100
	jal CHECK_DIGIT
	addi $t1, $t1, 16
	li $t4, 100
	mult $t3, $t4
	mflo $t4
	sub $s6, $s6, $t4
	
	# Divide by 10 to find tenth digit
	div $t3, $s6, 10
	jal CHECK_DIGIT
	addi $t1, $t1, 16
	li $t4, 10
	mult $t3, $t4
	mflo $t4
	sub $s6, $s6, $t4
	
	# Divide by 1 to find ones digit
	la $t3, ($s6)
	jal CHECK_DIGIT
	
	j RESTART

CHECK_DIGIT:
	# Draw respective digit
	beq $t3, 0, DRAW_ZERO
	beq $t3, 1, DRAW_ONE
	beq $t3, 2, DRAW_TWO
	beq $t3, 3, DRAW_THREE
	beq $t3, 4, DRAW_FOUR
	beq $t3, 5, DRAW_FIVE
	beq $t3, 6, DRAW_SIX
	beq $t3, 7, DRAW_SEVEN
	beq $t3, 8, DRAW_EIGHT
	beq $t3, 9, DRAW_NINE

DRAW_ZERO:
	# Draws zero
	sw $t2, 0($t1)
	sw $t2, 4($t1)
	sw $t2, 8($t1)
	
	sw $t2, 256($t1)
	sw $t2, 264($t1)
	
	sw $t2, 512($t1)
	sw $t2, 520($t1)
	
	sw $t2, 768($t1)
	sw $t2, 776($t1)
	
	sw $t2, 1024($t1)
	sw $t2, 1028($t1)
	sw $t2, 1032($t1)
	
	jr $ra

DRAW_ONE:
	# Draws one
	sw $t2, 8($t1)

	sw $t2, 264($t1)
	
	sw $t2, 520($t1)
	
	sw $t2, 776($t1)
	
	sw $t2, 1032($t1)

	jr $ra
	
DRAW_TWO:
	# Draws two
	sw $t2, 0($t1)
	sw $t2, 4($t1)
	sw $t2, 8($t1)
	
	sw $t2, 264($t1)
	
	sw $t2, 512($t1)
	sw $t2, 516($t1)
	sw $t2, 520($t1)
	
	sw $t2, 768($t1)
	
	sw $t2, 1024($t1)
	sw $t2, 1028($t1)
	sw $t2, 1032($t1)
	
	jr $ra
	
DRAW_THREE:
	# Draws three
	sw $t2, 0($t1)
	sw $t2, 4($t1)
	sw $t2, 8($t1)
	
	sw $t2, 264($t1)
	
	sw $t2, 512($t1)
	sw $t2, 516($t1)
	sw $t2, 520($t1)
	
	sw $t2, 776($t1)
	
	sw $t2, 1024($t1)
	sw $t2, 1028($t1)
	sw $t2, 1032($t1)
	
	jr $ra
	
DRAW_FOUR:
	# Draws four
	sw $t2, 0($t1)
	sw $t2, 8($t1)
	
	sw $t2, 256($t1)
	sw $t2, 264($t1)
	
	sw $t2, 512($t1)
	sw $t2, 516($t1)
	sw $t2, 520($t1)
	
	sw $t2, 776($t1)
	
	sw $t2, 1032($t1)
	
	jr $ra

DRAW_FIVE:
	# Draws five
	sw $t2, 0($t1)
	sw $t2, 4($t1)
	sw $t2, 8($t1)
	
	sw $t2, 256($t1)
	
	sw $t2, 512($t1)
	sw $t2, 516($t1)
	sw $t2, 520($t1)
	
	sw $t2, 776($t1)
	
	sw $t2, 1024($t1)
	sw $t2, 1028($t1)
	sw $t2, 1032($t1)
	
	jr $ra
	
DRAW_SIX:
	# Draws six
	sw $t2, 0($t1)
	sw $t2, 4($t1)
	sw $t2, 8($t1)
	
	sw $t2, 256($t1)
	
	sw $t2, 512($t1)
	sw $t2, 516($t1)
	sw $t2, 520($t1)
	
	sw $t2, 768($t1)
	sw $t2, 776($t1)
	
	sw $t2, 1024($t1)
	sw $t2, 1028($t1)
	sw $t2, 1032($t1)
	
	jr $ra

DRAW_SEVEN:
	# Draws seven
	sw $t2, 0($t1)
	sw $t2, 4($t1)
	sw $t2, 8($t1)
	
	sw $t2, 264($t1)
	
	sw $t2, 520($t1)
	
	sw $t2, 776($t1)
	
	sw $t2, 1032($t1)
	
	jr $ra
	
DRAW_EIGHT:
	# Draws eight
	sw $t2, 0($t1)
	sw $t2, 4($t1)
	sw $t2, 8($t1)
	
	sw $t2, 256($t1)
	sw $t2, 264($t1)
	
	sw $t2, 512($t1)
	sw $t2, 516($t1)
	sw $t2, 520($t1)
	
	sw $t2, 768($t1)
	sw $t2, 776($t1)
	
	sw $t2, 1024($t1)
	sw $t2, 1028($t1)
	sw $t2, 1032($t1)
	
	jr $ra

DRAW_NINE:
	# Draws nine
	sw $t2, 0($t1)
	sw $t2, 4($t1)
	sw $t2, 8($t1)
	
	sw $t2, 256($t1)
	sw $t2, 264($t1)
	
	sw $t2, 512($t1)
	sw $t2, 516($t1)
	sw $t2, 520($t1)
	
	sw $t2, 776($t1)
	
	sw $t2, 1032($t1)
	
	jr $ra

#=========================
# RESTART GAME
#=========================
RESTART:
	lw $t8, 0($t9)
	beq $t8, 1, P_KEY
	
	j END_RESTART
	
P_KEY:	lw $t2, 4($t9) # this assumes $t9 is set to 0xfff0000 from before
	beq $t2, 0x70, P_PRESS # ASCII code of 'P' is 0X70
	beq $t2, 0x78, EXIT
	j END_RESTART

P_PRESS:
	li $v0, 4
	la $a0, restart
	syscall
	j RESET

END_RESTART:
	# SLEEP 20 MILLISECOND
	li $v0, 32
	li $a0, REFRESH_RATE  # Wait REFRESH_RATE amount of seconds
	syscall
	j RESTART
	
#=========================
# END LOOP AND RESET
#=========================
RESET: 	li $t1, BASE_ADDRESS
	li $t2, END
	li $t3, 0x000000
	li $s0, 0
	li $s6, 0
	li $s7, 0
	
RESET_BACKGROUND:
	sw $t3, 0($t1)
	addi $t1, $t1, 4
	bne $t1, $t2, RESET_BACKGROUND
	j SETUP

CALC_REFRESH:
	# Increase refresh rate periodically
	li $t3, REFRESH_RATE
	bgt $s6, 1500, LOWEST_REFRESH	# Limit how low the refresh rate can go
	
	subi $t1, $s6, 30
	
	div $t4, $t1, 50
	sub $t3, $t3, $t4
	
	j END_LOOP

LOWEST_REFRESH:
	# If refresh has hit small enough number limit it
	li $t3, LOW_REFRESH	

END_LOOP:
	# SLEEP 20 MILLISECOND
	li $v0, 32
	la $a0, ($t3)  # Wait REFRESH_RATE amount of seconds
	syscall
	j MAIN

EXIT:	
	# Print Exit String
	li $v0, 4
	la $a0, exit
	syscall
	
	# Terminate program
	li $v0, 10
	syscall
