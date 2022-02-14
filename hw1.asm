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
args: .asciiz "D" "-2147483648" ##############################################Delete
.text
.globl hw_main
hw_main:
	################
	li $a0 2
	################
    sw $a0, num_args
	################
	la $a1 args
	################
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
	beq $s1 $t7 correctO
	li $t7 0x0053
	beq $s1 $t7 correctS
	li $t7 0x0054
	beq $s1 $t7 correctT
	li $t7 0x0049
	beq $s1 $t7 correctI
	li $t7 0x0046
	beq $s1 $t7 correctF
	li $t7 0x004c
	beq $s1 $t7 correctL
	j invalidargmsg
	
invalidargmsg:
	li $v0 4                                     # If input is not valid, error msg, then terminate
	la $a0 invalid_arg_msg
	syscall
	j terminate
	
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
		sub $s1 $s1 $t9                          # decrement counter
		lbu $t8 0($s1)                           # decrement address counter
		j loop
		
	loop:
		beqz $t8 terminateprint                  # if loop is done, terminate
		li $t6 0x30                              # load dec48/hex30 into $t6
		sub $t1 $t8 $t6                          # subtract dec48/hex30 from the char to turn it into a usable number, avoids lengthy switch case
		li $t5 9                                 # set t5 to 9
		slt $t4 $t5 $t1                          # check if 9 is less than the result
		bnez $t4 invalidargmsg                   # if its greater than 9, terminate with error
		slt $t4 $t1 $0                            # check if 0 is less than the result
		beq $t4 $t9 invalidargmsg                # if its less than 0, terminate with error
		#####
		mult $t2 $t1                             # base 10 multiplier
		mflo $s6
		add $t3 $t3 $s6                          # add value to final result
		mult $t2 $s7                             # account for base 10 multiplier (x10)
		mflo $t2                                 # loads the result back into t2
		sub $s1 $s1 $t9                          # decrement counter
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
		sub $s1 $s1 $t9                          # decrement counter
		lbu $t8 0($s1)                           # decrement address counter
		j nloop
		
	nloop:
		beq $t8 $s5 terminateprint               # if loop is done, terminate
		li $t6 0x30                              # load dec48/hex30 into $t6
		sub $t1 $t8 $t6                          # subtract dec48/hex30 from the char to turn it into a usable number, avoids lengthy switch case
		li $t5 9                                 # set t5 to 9
		slt $t4 $t5 $t1                          # check if the 9 is less than the result
		bnez $t4 invalidargmsg                   # if its greater than 9, terminate with error
		slt $t4 $t1 $0                           # check if 0 is less than the result
		beq $t4 $t9 invalidargmsg                # if its less than 0, terminate with error
		#####
		mult $t2 $t1                             # base 10 multiplier
		mflo $s6
		sub $t3 $t3 $s6                          # subtract value from final result
		mult $t2 $s7                             # account for base 10 multiplier (x10)
		mflo $t2                                 # loads the result back into t2
		sub $s1 $s1 $t9                          # decrement counter
		lbu $t8 0($s1)                           # decrement address counter
		j nloop

correctO:                                        # if you're reading this, i'm so sorry everything is named loop
	lw $s1 arg2_addr                             # load second arg address
	lhu $t8 0($s1)                               # load first half word into t8
	li $s1 0x7830                                # 3078 = 48 120 = "0x"
	bne $s1 $t8 argserrmsg                       # if the first 2 chars aren't 0x, terminate with error
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
		beq $t4 $s3 argserrmsg                   # if its less than 1, error
		slt $t4 $s2 $t1                          # check if length is greater than 8
		beq $t4 $s3 argserrmsg                   # if its greater than 8, error
		#######################Convert each char to decimal, and store that decimal into seperate memory bytes.
		#####if between 48-57, subtract 48, if between  65-70, then subtract 55.
		lw $s1 arg2_addr                         # load second arg address
		addi $s1 $s1 2                           # goes to hex start
		lbu $t8 0($s1)                           # load char
		sub $t9 $s2 $t1                          # subtract length from 8, use t9 as counter
		move $t6 $s1                             # second counter for memory placement
		opreloop:
			 beq $t9 $0 oloopsecond              # if the counter reaches 0, break loop
			 sub $t9 $t9 $s3                     # decrement counter
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
			li $s4 48                            # constant 48
			sub $t7 $t8 $s4                      # subtract 48 from char, results in a usable number
			sb $t7 20($t6)                       # store the extracted decimal number into a separate place in memory.
			addi $s1 $s1 1                       # increment counter
			addi $t6 $t6 1                       # increment memory counter
			lbu $t8 0($s1)                       # update t8 to next character
			j oloopsecond
			
		oletter:
			li $s4 55                            # constant 55
			sub $t7 $t8 $s4                      # subtract 55 from char, results in a usable decimal number
			sb $t7 20($t6)                       # store the extracted decimal number into a separate place in memory.
			addi $s1 $s1 1                       # increment counter
			addi $t6 $t6 1                       # increment memory counter
			lbu $t8 0($s1)                       # update t8 to next character
			j oloopsecond
	
	oendloop:
		li $s6 8                                 # constant 8, a counter for how many times to loop.
		li $s1 0x1001009a                        # jump to memory address where hex string is stored.

	oendloop2:
		beq $s6 $0 terminate                     # when done with all 8 values termiante
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
			li $a0 0                             # prints zero
			li $v0 1 
			syscall
			sub $t7 $t7 $s3                      # decrements counter for remaining bits to be processed
			sll $t6 $t6 1                        # shift 1 to the right, move onto next bit
			j oendloop3
			
		oone:                                    # prints one
			li $a0 1
			li $v0 1
			syscall
			sub $t7 $t7 $s3                      # decrements counter for remaining bits to be processed
			sll $t6 $t6 1                        # shift 1 to the right, move onto next bit
			j oendloop3
		
	oendloops:
		addi $s1 $s1 1                           # increment s1 (memory pointer counter)
		sub $s6 $s6 $s3                          # decrement counter for remaining bytes to be processed.
		j oendloop2
		
	j terminate
correctS: 
	j terminate
correctT: 
	j terminate
correctI: 
	j terminate
correctF: 
	j terminate
correctL: 
	j terminate
	
terminateprint:
	move $a0 $t3                                 # prints, then terminates
	li $v0 1
	syscall
	j terminate
	
terminate:                                       # terminate
	li $v0 10
	syscall
	
argserrmsg:                                      # argserrmsg
	li $v0 4
	la $a0 args_err_msg                          # send argserrmsg
	syscall

	li $v0 10                                    # terminate
	syscall






