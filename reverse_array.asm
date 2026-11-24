.data

array: .word -7, 15, 3, -1, 7, 2, -11, 9

end_line: .asciiz "\n"

.text

li $s0, 8     # N = 8
la $s1, array # byte* ptr

move $t0, $zero # i = 0

loop:

sll $t1, $t0, 1
addi $t1, $t1, 1

slt $t1, $t1, $s0 # while (2 * i + 1 < N)
beq $t1, $zero, end_loop

addi $t1, $s0, -1
sub $t1, $t1, $t0 # (N - 1) - i

sll $t2, $t0, 2
add $t2, $s1, $t2 # array + i * sizeof(word)
lw $t3, 0($t2)    # *(word*)(array + i * sizeof(word))

sll $t4, $t1, 2
add $t4, $s1, $t4 # array + ((N - 1) - i) * sizeof(word)
lw $t5, 0($t4)    # *(word*)(array + ((N - 1) - i) * sizeof(word))

sw $t3, 0($t4)
sw $t5, 0($t2)

addi $t0, $t0, 1 # i++

j loop

end_loop:

move $t0, $zero # i = 0
move $t1, $s1   # byte* ptr

display_loop:

slt $t2, $t0, $s0 # while (i < N)
beq $t2, $zero, end_display_loop

lw $t2, 0($t1) # *(word*)ptr

move $a0, $t2
li $v0, 1 # print *(word*)ptr
syscall

la $a0, end_line
li $v0, 4 # print end_line
syscall

addi $t1, $t1, 4 # ptr += sizeof(word)
addi $t0, $t0, 1 # i++

j display_loop

end_display_loop:

li $v0, 10
syscall