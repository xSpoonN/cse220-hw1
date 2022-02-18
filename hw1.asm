################# Kevin Tao #################
################# ktao #################
################# 170154879 #################

################# DO NOT CHANGE THE DATA SECTION #################

.data
arg1_addr: .word 0
arg2_addr: .word 0
num_args: .word 0
invalid_arg_msg: .asciiz "One of the arguments is invalid\n"
args_err_msg: .asciiz "Program requires exactly two arguments\n"
invalid_hand_msg: .asciiz "Loot Hand Invalid\n"
newline: .asciiz "\n"
zero: .asciiz "Zero\n"
nan: .asciiz "NaN\n"
inf_pos: .asciiz "+Inf\n"
inf_neg: .asciiz "-Inf\n"
mantissa: .asciiz ""
.text
.globl hw_main
hw_main:
    sw $a0, num_args
    sw $a1, arg1_addr
    addi $t0, $a1, 2
    sw $t0, arg2_addr
    j start_coding_here

start_coding_here:
	lw $s0 num_args                              # Loads num args into $s0
	li $t0 2                                     # initialises $t0 to 2
	bne $t0 $s0 argserrmsg                       # if $t0 not equal to $s0 jump to argserrmsg, terminate
	
	lw $s2 arg1_addr                             # loads value of arg1_addr to register s1
	lhu $s1 0($s2)                               # loads the argument into $s1
	
	li $t7 0x0044
	beq $s1 $t7 correctD                         # Checks for each valid case
	li $t7 0x004f
	beq $s1 $t7 correctOSTI
	li $t7 0x0053
	beq $s1 $t7 correctOSTI
	li $t7 0x0054
	beq $s1 $t7 correctOSTI
	li $t7 0x0049
	beq $s1 $t7 correctOSTI
	li $t7 0x0046
	beq $s1 $t7 correctF
	li $t7 0x004c
	beq $s1 $t7 correctL
	j invalidargmsg
	
correctD:                                        # if input is correct
	lw $s1 arg2_addr                             # load second arg address
	lbu $t8 0($s1)                               # load first char into t8
	li $s5 0x2D                                  # 2D = 45 = ASCII - (hyphen)
	beq $s5 $t8 negative                         # if first char is negative, go to negative loop
	li $t2 1                                     # base 10 counter
	li $t3 0                                     # final value
	li $s7 10                                    # constant 10
	li $t9 1                                     # constant 1
	
	loopi:                                       # initial loop to get to end of string
		beq $t8 $0 preloop                       # if reached end, jump to loop
		addi $s1 $s1 1                           # increment counter
		lbu $t8 0($s1)                           # increment address counter
		j loopi
		
	preloop:
		addi $s1 $s1 -1                          # decrement counter
		lbu $t8 0($s1)                           # decrement address counter
		j loop
		
	loop:
		beqz $t8 terminateprint                  # if loop is done, terminate
		li $t6 0x30                              # load dec48/hex30 into $t6
		sub $t1 $t8 $t6                          # subtract dec48/hex30 from the char to turn it into a usable number, avoids lengthy switch case
		li $t5 9                                 # set t5 to 9
		slt $t4 $t5 $t1                          # check if 9 is less than the result
		bnez $t4 invalidargmsg                   # if its greater than 9, terminate with error
		slt $t4 $t1 $0                           # check if 0 is less than the result
		beq $t4 $t9 invalidargmsg                # if its less than 0, terminate with error
		mult $t2 $t1                             # base 10 multiplier
		mflo $s6
		add $t3 $t3 $s6                          # add value to final result
		mult $t2 $s7                             # account for base 10 multiplier (x10)
		mflo $t2                                 # loads the result back into t2
		addi $s1 $s1 -1                          # decrement counter
		lbu $t8 0($s1)                           # decrement address counter
		j loop
		
	negative:                                    # instead of adding, subtract for the final value, end at hyphen instead of 0. ###################
		li $t2 1                                 # base 10 counter
		li $t3 0                                 # final value
		li $s7 10                                # constant 10
		li $t9 1                                 # constant 1
	
	nloopi:                                      # initial loop to get to end of string
		beq $t8 $0 npreloop                      # if reached end, jump to loop
		addi $s1 $s1 1                           # increment counter
		lbu $t8 0($s1)                           # increment address counter
		j nloopi
		
	npreloop:
		addi $s1 $s1 -1                          # decrement counter
		lbu $t8 0($s1)                           # decrement address counter
		j nloop
		
	nloop:
		beq $t8 $s5 terminateprint               # if loop is done, terminate
		addi $t1 $t8 -48                         # subtract 48 from the char to turn it into a usable number, avoids lengthy switch case
		li $t5 9                                 # set t5 to 9
		slt $t4 $t5 $t1                          # check if the 9 is less than the result
		bnez $t4 invalidargmsg                   # if its greater than 9, terminate with error
		slt $t4 $t1 $0                           # check if 0 is less than the result
		beq $t4 $t9 invalidargmsg                # if its less than 0, terminate with error
		mult $t2 $t1                             # base 10 multiplier
		mflo $s6
		sub $t3 $t3 $s6                          # subtract value from final result
		mult $t2 $s7                             # account for base 10 multiplier (x10)
		mflo $t2                                 # loads the result back into t2
		addi $s1 $s1 -1                          # decrement counter
		lbu $t8 0($s1)                           # decrement address counter
		j nloop

correctOSTI:
	lw $s1 arg2_addr                             # load second arg address
	lhu $t8 0($s1)                               # load first half word into t8
	li $s1 0x7830                                # 3078 = 48 120 = "0x"
	bne $s1 $t8 invalidargmsg                       # if the first 2 chars aren't 0x, terminate with error
	lw $s1 arg2_addr                             # load second arg address
	addi $s1 $s1 2                               # increment counter
	li $t1 0                                     # length counter
	li $s2 8                                     # constant 8
	li $s3 1                                     # constant 1
	oloopo:                                      # initial loop to get to end of string
		beq $t8 $0 oloopend                      # if reached end, jump to loop
		addi $t1 $t1 1                           # increment length counter
		addi $s1 $s1 1                           # increment counter
		lbu $t8 0($s1)                           # increment address counter
		j oloopo
	oloopend: 
		slt $t4 $t1 $s3                          # check if length is less than 1
		beq $t4 $s3 invalidargmsg                   # if its less than 1, error
		slt $t4 $s2 $t1                          # check if length is greater than 8
		beq $t4 $s3 invalidargmsg                   # if its greater than 8, error
		lw $s1 arg2_addr                         # load second arg address
		addi $s1 $s1 2                           # goes to hex start
		lbu $t8 0($s1)                           # load char
		sub $t9 $s2 $t1                          # subtract length from 8, use t9 as counter
		move $t6 $s1                             # second counter for memory placement
		opreloop:
			 beq $t9 $0 oloopsecond              # if the counter reaches 0, break loop
			 addi $t9 $t9 -1                     # decrement counter
			 addi $t6 $t6 1                      # increment string counter
			 j opreloop
	oloopsecond:
		beq $t8 $0 oendloop                      # if it reaches the end of the string, end.
		li $t2 47
		slt $t4 $t2 $t8                          # check if 47 is less than the char (0)
		li $t2 58
		slt $t3 $t8 $t2                          # check if the char is less than 58 (9)
		beq $t3 $t4 onumber                      # check if both conditions are true
		li $t2 64
		slt $t4 $t2 $t8                          # check if 64 is less than the char (A)
		li $t2 71
		slt $t3 $t8 $t2                          # check if the char is less than 71 (F)
		beq $t3 $t4 oletter                      # check if both conditions are true
		j argserrmsg                             # if not, error
		onumber: 
			addi $t7 $t8 -48                     # subtract 48 from char, results in a usable number
			sb $t7 200($t6)                      # store the extracted decimal number into a separate place in memory.
			addi $s1 $s1 1                       # increment counter
			addi $t6 $t6 1                       # increment memory counter
			lbu $t8 0($s1)                       # update t8 to next character
			j oloopsecond
		oletter:
			addi $t7 $t8 -55                     # subtract 55 from char, results in a usable decimal number
			sb $t7 200($t6)                      # store the extracted decimal number into a separate place in memory.
			addi $s1 $s1 1                       # increment counter
			addi $t6 $t6 1                       # increment memory counter
			lbu $t8 0($s1)                       # update t8 to next character
			j oloopsecond
	oendloop:
		li $s6 8                                 # constant 8, a counter for how many times to loop.
		li $s2 0x100100e0                        # memory address for binary conversion.
		li $s1 0x100100cc                        # jump to memory address where hex string is stored.
	oendloop2:
		beq $s6 $0 afterOSTI                     # when done with all 8 values terminate
		lbu $t1 0($s1)                           # load 4-piece to be printed into t1
		li $t7 4                                 # counter 4 for each bit of the value
		move $t6 $t1                             # clone t6 into t1 
	oendloop3: 
		beq $t7 $0 oendloops                     # once counter reaches 0, every bit has been processed
		li $s4 0x00000008                        # bit mask (....1000) printing from the left of the bit, since it is reversed.
		and $s5 $s4 $t6                          # and mask, gets rid of everything except first bit
		li $t3 8                                 # constant 8
		beq $t3 $s5 oone                         # if 8 (1000) is equal, that means the bit is one. If so jump to the "one" branch
		beq $0 $s5 ozero                         # otherwise zero
		ozero:
			sb $0 0($s2)                         # saves a 0 to memory
			addi $s2 $s2 1                       # increment memory counter
			addi $t7 $t7 -1                      # decrements counter for remaining bits to be processed
			sll $t6 $t6 1                        # shift 1 to the right, move onto next bit
			j oendloop3
		oone:
			sb $s3 0($s2)                        # save 1 to memory
			addi $s2 $s2 1                       # increment memory counter
			addi $t7 $t7 -1                      # decrements counter for remaining bits to be processed
			sll $t6 $t6 1                        # shift 1 to the right, move onto next bit
			j oendloop3
	oendloops:
		addi $s1 $s1 1                           # increment s1 (memory pointer counter)
		addi $s6 $s6 -1                          # decrement counter for remaining bytes to be processed.
		j oendloop2
		
	afterOSTI:
		lw $s2 arg1_addr                         # loads value of arg1_addr to register s1
		lhu $s1 0($s2)                           # loads the argument into $s1
		li $t9 0                                 # final decimal output
		li $t2 1                                 # binary multiplier
		li $t4 2                                 # constant 2
		li $t5 1                                 # constant 1
		li $s2 0x100100e0                        # memory address for binary conversion.
		li $t7 0x004f                            # Checks for each valid case.
		beq $s1 $t7 OSTIO
		li $t7 0x0053
		beq $s1 $t7 OSTIS
		li $t7 0x0054
		beq $s1 $t7 OSTIT
		li $t7 0x0049
		beq $s1 $t7 OSTII
	OSTIO:
		li $t1 6                               # counter for first 6 bits.
		add $s2 $s2 $t1                          # goes to end of section to be processed
		addi $s2 $s2 -1
		ostiloop:
			beq $t1 $0 OSTIEND
			lbu $s1 0($s2)                       # loads a bit into register
			mult $t2 $s1                         # multiplies by bit to determine whether or not to add value.
			mflo $t3                             # move product to t3
			mult $t3 $s1                         # multiply by binary multiplier
			mflo $t3
			add $t9 $t9 $t3                      # adds to final decimal value.
			mul $t2 $t2 $t4                      # x2 binary multiplier
			addi $s2 $s2 -1                      # decrements memory pointer
			addi $t1 $t1 -1                      # decrements remaining bits counter
			j ostiloop
	OSTIS:
		li $t1 5                                 # counter for 7th to 11th bits.
		addi $s2 $s2 10                          # goes to end of section to be processed
		j ostiloop
	OSTIT:
		li $t1 5                                 # counter for 12th to 16th bits.
		addi $s2 $s2 15                          # goes to end of section to be processed
		j ostiloop
	OSTII:
		li $t1 15                                # counter for 16th to 32nd bits.
		addi $s2 $s2 16                          # goes to first bit
		lbu $s1 0($s2)                           # loads 16th bit into s1
		addi $s2 $s2 15                          # goes to last bit
		beq $t5 $s1 ostinegative                 # if first bit is signed, negative number.
		j ostiloop
		ostinegative:
			li $t9 -32768                        # account for two's complement
			j ostiloop
	OSTIEND:
		li $v0 1
		move $a0 $t9
		syscall
		j terminate
correctF: 
	lw $s1 arg2_addr                             # load second arg address
	lbu $t8 0($s1)                               # load char into t8
	li $t1 0                                     # length counter
	li $s2 8                                     # constant 8
	li $s3 1                                     # constant 1
	floopo:                                      # initial loop to get to end of string
		beq $t8 $0 floopend                      # if reached end, jump to loop
		addi $t1 $t1 1                           # increment length counter
		addi $s1 $s1 1                           # increment counter
		lbu $t8 0($s1)                           # increment address counter
		j floopo
	floopend: 
		bne $s2 $t1 invalidargmsg                # if its not equal to 8, error
		lw $s1 arg2_addr                         # load second arg address
		lbu $t8 0($s1)                           # load char
		sub $t9 $s2 $t1                          # subtract length from 8, use t9 as counter
		li $t6 0x10000000                        # hex multiplier
	floopsecond:
		beq $t8 $0 fendloop                      # if it reaches the end of the string, end.
		li $t2 47
		slt $t4 $t2 $t8                          # check if 47 is less than the char (0)
		li $t2 58
		slt $t3 $t8 $t2                          # check if the char is less than 58 (9)
		beq $t3 $t4 fnumber                      # check if both conditions are true
		li $t2 64
		slt $t4 $t2 $t8                          # check if 64 is less than the char (A)
		li $t2 71
		slt $t3 $t8 $t2                          # check if the char is less than 71 (F)
		beq $t3 $t4 fletter                      # check if both conditions are true
		j invalidargmsg                             # if not, error
		fnumber: 
			addi $t7 $t8 -48                     # subtract 48 from char, results in a usable number
			mult $t6 $t7                         # multiply by hex
			mflo $t5
			add $t9 $t9 $t5                      # add to final result. = $t9
			li $t2 16                            # constant 16
			div $t6 $t2                          # update hex multiplier
			mflo $t6
			addi $s1 $s1 1                       # increment counter
			lbu $t8 0($s1)                       # update t8 to next character
			j floopsecond
		fletter:
			addi $t7 $t8 -55                     # subtract 55 from char, results in a usable decimal number
			mult $t6 $t7                         # multiply by hex
			mflo $t5
			add $t9 $t9 $t5                      # add to final result. = $t9
			li $t2 16                            # constant 16
			div $t6 $t2                          # update hex multiplier
			mflo $t6
			addi $s1 $s1 1                       # increment counter
			lbu $t8 0($s1)                       # update t8 to next character
			j floopsecond
	fendloop:
		li $t1 0x80000000                        # constant ieee 0
		beq $t9 $t1 zeroterminate                # if equal to 0, print zero
		beq $t9 $0 zeroterminate
		li $t1 0xFF800000                        # constant ieee -neg inf
		beq $t9 $t1 infnegterminate              # if equal to negative infinity, terminate
		li $t2 0xFFFFFFFF
		slt $t3 $t9 $t2                          # if less than 0xFFFFFFFF
		slt $t4 $t1 $t9                          # if greater than 0xFF800000
		beq $t3 $t4 nanterminate                 # nan
		beq $t9 $t2 nanterminate
		li $t1 0x7F800000                        # constant ieee -neg inf
		beq $t9 $t1 infposterminate              # if equal to negative infinity, terminate
		li $t2 0x7FFFFFFF
		slt $t3 $t9 $t2                          # if less than 0x80000000
		slt $t4 $t1 $t9                          # if greater than 0x7F800000
		beq $t3 $t4 nanterminate                 # nan
		beq $t9 $t2 nanterminate
		
		li $t1 0x80000000                        # constant 0x80000000
		and $t2 $t9 $t1                          # extract first bit
		la $t3 mantissa                          # loads mantissa addresses
		beq $t1 $t2 fneg                         # checks for sign bit.
		j fpos                                   # otherwise, positive number.
		fneg:
			li $t4 45                            # ascii 45 = "-"
			sb $t4 0($t3)                        # stores negative sign into mantissa
			addi $t3 $t3 1                       # increments memory
		fpos:
			li $t4 49                            # ascii 49 = "1"
			sb $t4 0($t3)                        # stores 1 into memory
			addi $t3 $t3 1                       # increments memory
			li $t4 46                            # ascii 46 = "."
			sb $t4 0($t3)                        # stores . into memory
			addi $t3 $t3 1                       # increments memory
			li $t7 0x7FFFFFFF                    # constant 0x7FFFFFFF for bit mask
			and $t9 $t9 $t7                      # removing the sign bit.
			srl $a0 $t9 23                       # removes mantissa,  stores this exponent value into a0
			addi $a0 $a0 -127                    # accounts for 127 bias
			li $t1 23                            # counter for the 23 mantissa bits
			li $t2 0x00400000                    # 10th bit
			fstoreloop:
				beq $t1 $0 fstoreend             # when counter is done, end
				and $s1 $t9 $t2                  # extracts 10th bit.
				beq $s1 $t2 fone                 # if equal, jump to one
				j fzero                          # else, zero
				fone: 
					li $t4 49                    # ascii 49 = "1"
					sb $t4 0($t3)                # store 1 into memory
					sll $t9 $t9 1                # shift left
					addi $t3 $t3 1               # increments memory
					addi $t1 $t1 -1              # decrements counter
					j fstoreloop
				fzero:
					li $t4 48                    # ascii 48 = "0"
					sb $t4 0($t3)                # store 0 into memory
					sll $t9 $t9 1                # shift left
					addi $t3 $t3 1               # increments memory
					addi $t1 $t1 -1              # decrements counter
					j fstoreloop
			fstoreend:
				la $a1 mantissa                  # puts mantissa address into a1
				j terminate
	j terminate
correctL: 
	li $s1 0                                     # length counter
	li $s2 13                                    # constant 13, for checking invalid length
	li $s3 77                                    # ascii 77 = "M"
	li $s4 80                                    # ascii 80 = "P"
	lw $s5 arg2_addr                             # loads second arg address
	li $s6 0                                     # merchant counter
	li $s7 0                                     # pirate counter
	lbu $t1 0($s5)                               # load char into t1
	Lvalidate:
		beq $t1 $0 Lvalidateend                  # reaches end of arg
		beq $s1 $s2 invalidhandmsg                # if length > 12, error
		beq $t1 $s3 LM                           # if M
		beq $t1 $s4 LP                           # if P
		j invalidhandmsg                          # if neither, error
		LM:
			addi $s6 $s6 1                       # increment merchant counter
			addi $s1 $s1 1                       # increment length counter
			addi $s5 $s5 1                       # increment memory
			lbu $t1 0($s5)                       # loads into t1
			addi $t2 $t1 -48                     # subtract 48
			li $t3 2                             # constant 2
			li $t4 9                             # constant 9
			slt $t5 $t3 $t2                      # check if greater than 2
			beqz $t5 invalidhandmsg
			slt $t5 $t2 $t4                      # check if less than 9
			beqz $t5 invalidhandmsg
			addi $s5 $s5 1                       # increments memory
			addi $s1 $s1 1                       # increment length counter
			lbu $t1 0($s5)                       # loads into t1
			j Lvalidate
		LP:
			addi $s7 $s7 1                       # increment merchant counter
			addi $s1 $s1 1                       # increment length counter
			addi $s5 $s5 1                       # increment memory
			lbu $t1 0($s5)                       # loads into t1
			addi $t2 $t1 -48                     # subtract 48
			li $t4 5                             # constant 5
			slt $t5 $0 $t2                       # check if greater than 0
			beqz $t5 invalidhandmsg
			slt $t5 $t2 $t4                      # check if less than 5
			beqz $t5 invalidhandmsg
			addi $s5 $s5 1                       # increments memory
			addi $s1 $s1 1                       # increment length counter
			lbu $t1 0($s5)                       # loads into t1
			j Lvalidate

	Lvalidateend:
		li $s2 12                                # constant 12
		bne $s1 $s2 invalidhandmsg                # if input is not exactly 12 chars, error
		sll $s6 $s6 3                            # shift merchant counter left 3
		or $s6 $s6 $s7                           # combine the two
		move $a0 $s6                             # prints, then terminates
		li $v0 1
		syscall
		j terminate
	
nanterminate:
	li $v0 4                                     # If input is not valid, error msg, then terminate
	la $a0 nan
	syscall
	j terminate
infnegterminate:
	li $v0 4                                     # If input is not valid, error msg, then terminate
	la $a0 inf_neg
	syscall
	j terminate
infposterminate:
	li $v0 4                                     # If input is not valid, error msg, then terminate
	la $a0 inf_pos
	syscall
	j terminate
zeroterminate:
	li $v0 4                                     # If input is not valid, error msg, then terminate
	la $a0 zero
	syscall
	j terminate
terminateprint:
	move $a0 $t3                                 # prints, then terminates
	li $v0 1
	syscall
	j terminate
terminate:                                       # terminate
	li $v0 10
	syscall
invalidargmsg:
	li $v0 4                                     # If input is not valid, error msg, then terminate
	la $a0 invalid_arg_msg
	syscall
	j terminate
invalidhandmsg:
	li $v0 4                                     # If input is not valid, error msg, then terminate
	la $a0 invalid_hand_msg
	syscall
	j terminate
argserrmsg:                                      # argserrmsg
	li $v0 4
	la $a0 args_err_msg                          # send argserrmsg
	syscall
	li $v0 10                                    # terminate
	syscall
