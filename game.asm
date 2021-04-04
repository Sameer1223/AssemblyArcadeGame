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
.eqv 	END		0x10009FFC
.eqv	KBD_BASE	0xffff0000
.eqv	WIDTH		64 # in "units"
.eqv	HEIGHT		32 # in "units"
.eqv	ROW_SHIFT	8 # 64 units * 4 bytes per pixel = 256 = 2^8
.eqv	REFRESH_RATE	40
.eqv 	BLACK		0x00000000

.data
W:	.asciiz		"w"
A:	.asciiz		"a"
S:	.asciiz		"s"
D:	.asciiz		"d"
exit:	.asciiz		"Exiting Game!"
.text
.globl SETUP

SETUP: 	li $t0, BASE_ADDRESS	# $t0 stores the base address for display
	li $t9, KBD_BASE	# $t9 stores the keyboard base address
	addi $s0, $s0, 0	# set $s0 to counter for loops
	
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
	# Print W String
	li $v0, 4
	la $a0, W
	syscall
	
	addi $t0, $t0, -256
	j RESET
	
A_PRESS:
	# Print A String
	li $v0, 4
	la $a0, A
	syscall
	
	addi $t0, $t0, -4
	j RESET
	
S_PRESS:
	# Print S String
	li $v0, 4
	la $a0, S
	syscall
	
	addi $t0, $t0, 256
	j RESET
	
D_PRESS:
	# Print D String
	li $v0, 4
	la $a0, D
	syscall
	
	addi $t0, $t0, 4
	j RESET
	
RESET:	li $s1, END		# Load end location
	beq $s2, $s1, SHIP	# Check if reset has reached end, jump to ship if it has
	li $t1, BLACK		# Load in black colour
	sw $t1, 0($s2)		# Set pixel to black
	addi $s2, $s2, 4	# Add 4 to pixel count
	j RESET			# Loop to reset

SHIP:	li $t1, 0xede7f6	# $t1 stores the gray
	li $t2, 0x837cc2	# $t2 stores the purple
	li $t3, 0xff5252	# $t3 stores the red
	li $t4, 0x42a5f5	# $t4 stores the blue
	
	sw $t1, 0($t0)

#	sw $t1, 8($t0)		 
#	sw $t1, 12($t0)
#	
#	sw $t3, 256($t0)
#	sw $t2, 260($t0)
#	sw $t1, 264($t0)
#	sw $t4, 268($t0)
#	sw $t1, 272($t0)
#	
#	sw $t3, 512($t0)
#	sw $t2, 516($t0)
#	sw $t1, 520($t0)
#	sw $t4, 524($t0)
#	sw $t1, 528($t0)
#	
#	sw $t1, 776($t0)		 
#	sw $t1, 780($t0)
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
