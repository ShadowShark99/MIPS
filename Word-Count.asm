# Word Count
# Files: /Users/kaden/documents/MIPS/hsperfdata_kaden/CS2340-Asg7-kwc220000/TopCoder.txt
#	/Users/kaden/documents/MIPS/hsperfdata_kaden/CS2340-Asg7-kwc220000/T2.txt
	.data
fPrompt:	.asciiz	"\nEnter file: "
fError:	.asciiz	"\nFile not found"
newLine:	.asciiz	"\n"
space:	.asciiz	"           "
comma:	.asciiz	", "
testW:	.asciiz	"THESE WORDS ARE EQUAL"

	.eqv	SysPrintInt 	1	# Syscalls
	.eqv	SysPrintFloat 	2
	.eqv	SysPrintDouble	3
	.eqv	SysPrintString	4
	.eqv	SysReadInt	5
	.eqv	SysReadFloat	6
	.eqv	SysReadDouble	7
	.eqv	SysReadString	8
	.eqv	SysAlloc		9
	.eqv	SysExit		10
	.eqv	SysPrintChar	11
	.eqv	SysReadChar	12
	.eqv	SysOpenFile	13
	.eqv	SysReadFile	14
	.eqv	SysWriteFile	15
	.eqv	SysCloseFile	16
	.eqv	SysExitValue	17
	
	.eqv	FD	$s0		# File Descriptor is $s0
	.eqv	LN	$s1		# Line Number
	.eqv	WL	$s2		# holds address of first list
	.eqv	WS	4		# word size
	.eqv	DS	8		# double size
	.eqv	NEXT	12		# address of next node within heap space
	.eqv	QWS	16		# quadruple word size
	.eqv	BUFFSIZE	512		# buffer sizes
	.eqv	FNSIZE	256		
	.eqv	READ	0		# FLAGS
	.eqv	WRITE	1
	
	.eqv	BMASK	31		# 11111 bitmask
	
buffer:	.space	BUFFSIZE			# create buffers
fName:	.space	FNSIZE	
word0:	.space	BUFFSIZE
		
	.text
main:
	la	$a0, fPrompt	# load file prompt
	li	$v0, SysPrintString	# print file prompt
	syscall
	
	la	$a0, fName	# load file buffer
	li	$a1, FNSIZE	# load number of characters to read
	li	$v0, SysReadString	# read file name from user
	syscall
	
	jal	remNL		# remove newLine character
	
	li	$a1, READ		# read mode
	li	$a2, 0		# ignore mode
	li	$v0, SysOpenFile	# open file, get file descriptor
	syscall
	
	addi	LN, $0, 1		# instantiate line number
	
	bge	$v0, $0, validF	# valid vile name
	
	la	$a0, fError	# load file not found message
	li	$v0, SysPrintString	# print file not found message
	syscall
	
	j	main		# retry a different file
validF:
	add	FD, $v0, $0 	# save file descriptor in $s0
	add	WL, $0, $0	# declare word List
	la	$t3, word0	# load address of word in $t3
	add	$t5, $0, $0	# length of word
	
readF:
	add	$a0, FD, $0	# load file descriptor
	la	$a1, buffer	# load buffer
	li	$a2, BUFFSIZE	# set number of bytes to read
	li	$v0, SysReadFile	# set read file
	syscall
	
	beq	$v0, $0, eof	# 0 bytes read -> eof
	add	$t0, $0, $0	# index variable
	addi	$t2, $0, '\n'	# new line character
	add	$t6, $v0, $0	# temp hold number of bytes to allocate

readB:
	bge	$t0, $t6, eoB	# reached end of block
	add	$s4, LN, $0	# temp line number variable
	lb	$t1, ($a1)	# load byte in block
	
	# TESTING PRINT WORDS
	add	$a0, $0, $t1	
	li	$v0, SysPrintChar
	syscall
	#END TESTING PRINT
	addi	$t0, $t0, 1	# increment index variable
	addi	$t4, $0, ' '	# load characters to check end of word
	beq	$t1, $t4, eoW	# branch if reach end of word
	addi	$t4, $0, ','	# load characters to check end of word
	beq	$t1, $t4, eoW	# branch if reach end of word
	addi	$t4, $0, '.'	# load characters to check end of word
	beq	$t1, $t4, eoW	# branch if reach end of word
	addi	$t4, $0, ':'	# load characters to check end of word
	beq	$t1, $t4, eoW	# branch if reach end of word
	addi	$t4, $0, ';'	# load characters to check end of word
	beq	$t1, $t4, eoW	# branch if reach end of word
	addi	$t4, $0, '\n'	# load characters to check end of word
	beq	$t1, $t4, eoWnL	# branch if reach end of word
	
# sussy sussy sussy sussy sussy sussy sussy sussy not end of word
addChar:
	sb	$t1, ($t3)	# store char in temp word
	addi	$t3, $t3, 1	# increment address of temp word
	addi	$t5, $t5, 1	# increment word length
	addi	$a1, $a1, 1	# increment word index
	b	readB		# scan next character
eoWnL:
	addi	$s4, LN, 1	# line number to switch to after updating word list
eoW:
	add	$t9, $t5, $0	# temp hold word length
	add	$t5, $0, $0	# reset word length
	addi	$a1, $a1, 1	# increment word index
	bne	$t9, $0, keepR	# skip searching for word if length is 0
	
	add	LN, $s4, $0	# unpause line number
	b	readB		# search next word without going through list
keepR:
	# TESTING CODE
#	la	$a0, word0
#	li	$v0, SysPrintString
#	syscall
#	
#	add	$v0, $0, $t6	
	# TESTING END
	add	$s3, $s2, $0	# get address of current Node
	add	$s6, $s3, $0	# ^^^^^
	add	$s7, $s3, $0	# ^^^^^
findW:
	beq	$s3, $0, newNode	# reached null node
#	la	$s3, ($s3)	# load block of data
#	la	$s6, ($s3)	# load node (block of data)
	lw	$t7, ($s3)	# load word length
#	addi	$s3, $s3, WS	# increment address to word count section
	jal	eqW		# check to see if words are equal
	addi	$s3, $s3, WS	# increment Node to word count section
	beq	$v1, $0, nEqW	# branch if words are not equal
# words are equal
	lw	$t7, ($s3)	# load word for word count
	addi	$t7, $t7, 1	# increment word count
	sw	$t7, ($s3)	# store new word
	addi	$s3, $s3, WS	# increment to address of line number list
# add line number to the list
	lw	$t7, ($s3)	# load address of line number list
	add	$s5, $0, $s3	# get curr Node for line list
addLN:
	beq	$t7, $0, doneALN	# reached a nullptr, found where to add LN.
	add	$s5, $t7, $0	# get next node
	lw	$t8, ($s5)	# get line number
	beq	LN, $t8, foundLN	# found existing line number
	addi	$s5, $s5, WS	# increment address
	lw	$t7, ($s5)	# load address of next node
	b	addLN		# search next number
doneALN:
	li	$a0, DS		# allocate 8 bytes on the heap
	li	$v0, SysAlloc	
	syscall
	
	sw	$v0, ($s5)	# save address of allocated space
	add	$s5, $v0, $0	# access space
	sw	LN, ($s5)		# store line number into  memory
	addi	$s5, $s5, WS	# increment address
	sw	$0, ($s5)		# store nullptr into next node
foundLN:
#	addi	$s3, $s3, -WS	# go back to word count address
	add	LN, $s4, $0	# unpause line number
	jal	clrWord		# reset buffer for next word 
	b	readB		# scan next word
nEqW:
	addi	$s3, $s3, DS	# increment address to reach address of next node
	add	$s6, $s3, $0	# keep track of address of next node
	lw	$s3, ($s3)	# load address of next node
#	add	LN, $s4, $0	# unpause line number from temp line numbeer
	b	findW		# search next node for word
	
newNode:
	
	addi	$a0, $t9, QWS	# number of bytes to allocate
	li	$v0, SysAlloc	# allocate space on the heap
	syscall
	
	bne	$s2, $0, notNull	# word list is not null
	add	$s2, $v0, $0	# address of first node
	b	fillNode		# go make Node
notNull:	
	sw	$v0, ($s6)	# store address of end node to prev node
fillNode:
#	la	$v0, ($v0)	# load space of new node
	sw	$t9, ($v0)	# store the word length in first word
	addi	$s7, $v0, QWS	# get space where word is stored
	addi	$v0, $v0, WS	# increment address of new Node to word count
	la	$t3, word0	# load word to add to list
	add	$t4, $0, $0	# index for word
addWord:
	bge	$t4, $t9, doneAW	# finished addingword
	lb	$t1, ($t3)	# load char
	sb	$t1, ($s7)	# store char into Node word space
	addi	$t3, $t3, 1	# increment word0 address
	addi	$t4, $t4, 1	# increment inndex
	addi	$s7, $s7, 1	# increment new Node address
	b	addWord		# add next char
doneAW:
	addi	$t4, $0, 1	# temp value 1
	sw	$t4, ($v0)	# instantiate word count to 1
	addi	$v0, $v0, WS	# increment Node address to line list
	add	$v1, $v0, $0	# move address over to $v1
	
	addi	$a0, $0, DS	# set number of bytes to allocate
	li	$v0, SysAlloc	# allocate number of bytes
	syscall
	
	sw	$v0, ($v1)	# store address of first line list node
	sw	LN, ($v0)		# store line number
	addi	$v0, $v0, WS	# icrement line list address
	sw	$0, ($v0)		# store nullptr
	
	add	LN, $s4, $0	# unpause line number from temp line numbeer
	
	add	$v0, $v1, $0	# restore address of first line list node in new Node
	addi	$v0, $v0, WS	# get address of next node
	sw	$0, ($v0)		# store nullptr
	jal	clrWord		# reset buffer for next word
	b	readB		# scan next word
	
	
eoB:
	b	readF		# scan next byte
eof:
	add	$s3, $s2, $0	# get curr Node pointer
printN:
	beq	$s3, $0, donePN	# done printing nodes
#	la	$s3, ($s3)	# load byte space for Node
	lw	$t2, ($s3)	# load char length
	add	$t0, $0, $0	# index variable for word
	addi	$s7, $s3, QWS	# address of node word space
	addi	$s3, $s3, WS	# increment Node address to word count
printW:
	beq	$t0, $t2, donePW	# reached end of word
	
	lb	$a0, ($s7)	# load char in word
	li	$v0, SysPrintChar	# print char
	syscall
	
	addi	$s7, $s7, 1	# increment Node address
	addi	$t0, $t0, 1	# increment index
	b	printW		# print next char
donePW:
	la	$a0, space	# load space to print
	li	$v0, SysPrintString	# print space
	syscall
	
	lw	$a0, ($s3)	# load word count
	li	$v0, SysPrintInt	# print word count
	syscall
	
	la	$a0, space	# load space to print
	li	$v0, SysPrintString	# print space
	syscall
	
	addi	$s3, $s3, WS	# increment Node addess to line list
	lw	$s4, ($s3)	# get address of linelist
printL:
#	la	$s4, ($s4)	# load address of number in line list - MAYBE WRONG way to load address
	
	lw	$a0, ($s4)	# get line number
	li	$v0, SysPrintInt	# print line number
	syscall 
	
	addi	$s4, $s4, WS	# increment to address of next line number
	lw	$s4, ($s4)	# get address of next line number
	beq	$s4, $0, donePL	# reached nullptr
	
	la	$a0, comma	# load comma + space
	li	$v0, SysPrintString	# print comma + space
	syscall
	
	b	printL		# print next line Number
donePL:
	la	$a0, newLine	# load new line to print
	li	$v0, SysPrintString	# print new line
	syscall
	
	addi	$s3, $s3, WS	# increment to address of next Node
	lw	$s3, ($s3)	# load address of next Node
	b	printN		# print next node

donePN:
	
	li	$v0	SysExit	# finished printing nodes
	syscall
	
	
# removes the new line character in the string buffer in $a0
remNL:
	add	$t0, $a0, $0	# get address of string buffer
	addi	$t2, $0, '\n'	# get value of newline character
findNL:
	lb	$t1, ($t0)	# load first char
	beq	$t1, $t2,foundNL	# newLine was found
	beq	$t1, $0, noNL	# newLine was not found
	addi	$t0, $t0, 1	# increment character index
	j	findNL		# search next character
foundNL:
	sb	$0, ($t0)		# set newLine character to null terminator
noNL:
	jr	$ra		# newLine removed
	
# check to see if the words is equal
eqW:
	add	$v1, $0, $0	# return 1 
	addi	$s7, $s3, QWS	# jump to word portion
	bne	$t9, $t7, notSame	# length of word not equal
	add	$t7, $0, $0	# index 
	la	$t3, word0	# loadword to check
scanW:
	beq	$t7, $t9, doneSW	# finished scanning
	lb	$t8, ($t3)	# load char of word0
	lb	$a3, ($s7)	# load char of word in list
	addi	$t7, $t7, 1	# increment index variable
	addi	$t3, $t3, 1	# increment address of word0
	addi	$s7, $s7, 1	# increment address of word in list
	andi	$t8, $t8, BMASK	# get last 5 bits
	andi	$a3, $a3, BMASK	# get last 5 bits
	bne	$t8, $a3, notSame	# different character
	b	scanW		# scan next character
	
doneSW:
	addi	$v1, $0, 1	# words are equal
	# TEST IF EQUAL
#	la	$a0, testW	
#	li	$v0, SysPrintString
#	syscall
	# END TEST EQUAL
	
notSame:
#	sub	$t7, $t5, $t7	# get remaining chars to increment through
#	add	$s3, $s3, $t7	# increment through word part of node
	# TEST HOW MANY MATCHED
#	add	$a0, $t7, $0
#	li	$v0, SysPrintInt
#	syscall
	#END MATCH TEST
	la	$t3, word0	# reset $t3 to beginning of word0
	jr	$ra	# $v1 is equal to 1 if equal and 0 if not equal
	
clrWord:
	li	$a2, BUFFSIZE	# size of word0
	add	$t8, $0, $0	# index var
	la	$t3, word0	# get first index of word0
set0:
	bge	$t8, $a2, doneS0	# finished setting 0s
	sb	$0, ($t3)		# set 0
	addi	$t3, $t3, 1	# increment word0 address
	addi	$t8, $t8, 1	# increment index
	b	set0		# set next char to 0
doneS0:
	la	$t3, word0	# reset to beginning of word0
	jr	$ra		# word0 buffer is reset
