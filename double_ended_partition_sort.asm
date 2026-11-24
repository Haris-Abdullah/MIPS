.data

array: .word 5, 1, 5, 3, 1, 5, 3, 3, 1

INT_MAX: .word 0x7fffffff
INT_MIN: .word 0x80000000

end_line: .asciiz "\n"

status: .asciiz "\nStatus: "

.text

li $s0, 9     # N = 9
la $s1, array # byte* ptr

la $s2, INT_MAX
lw $s2, 0($s2) # min = INT_MAX

la $s3, INT_MIN
lw $s3, 0($s3) # max = INT_MIN

move $t0, $zero # i = 0
move $t1, $s1   # byte* ptr

get_min_max_loop:

slt $t2, $t0, $s0 # while (i < N)
beq $t2, $zero, end_of_get_min_max_loop

lw $t2, 0($t1) # *(word*)ptr

slt $t3, $t2, $s2 # if (*(word*)ptr < min)
beq $t3, $zero, skip_min_update

move $s2, $t2 # min = *(word*)ptr

skip_min_update:

slt $t3, $s3, $t2 # if (*(word*)ptr > max)
beq $t3, $zero, skip_max_update

move $s3, $t2 # max = *(word*)ptr

skip_max_update:

addi $t1, $t1, 4 # ptr += sizeof(word)
addi $t0, $t0, 1 # i++

j get_min_max_loop

end_of_get_min_max_loop:

move $t0, $zero # low
move $t1, $zero # mid
move $t2, $s0   # high

sort_loop:

slt $t3, $t1, $t2 # while (mid < high)
beq $t3, $zero, end_of_sort_loop

la $t3, INT_MAX
lw $t3, 0($t3) # next_min = INT_MAX

la $t4, INT_MIN
lw $t4, 0($t4) # next_max = INT_MIN

place_min_max_loop:

slt $t5, $t1, $t2 # while (mid < high)
beq $t5, $zero, end_of_place_min_max_loop

sll $t5, $t1, 2
add $t5, $s1, $t5 # array + mid * sizeof(word)
lw $t6, 0($t5)    # *(word*)(array + mid * sizeof(word)): ((word*)array)[mid]

bne $t6, $s2, not_equal_to_min # if (((word*)array)[mid] == min)

sll $t7, $t0, 2
add $t7, $s1, $t7 # array + low * sizeof(word)
lw $t8, 0($t7)    # *(word*)(array + low * sizeof(word)): ((word*)array)[low]

sw $t8, 0($t5)
sw $t6, 0($t7)

addi $t0, $t0, 1 # low++
addi $t1, $t1, 1 # mid++

j end_if

not_equal_to_min:

bne $t6, $s3, not_equal_to_max # else if (((word*)array)[mid] == max)

addi $t2, $t2, -1 # high--

sll $t7, $t2, 2
add $t7, $s1, $t7 # array + high * sizeof(word)
lw $t8, 0($t7)    # *(word*)(array + high * sizeof(word)): ((word*)array)[high]

sw $t8, 0($t5)
sw $t6, 0($t7)

j end_if

not_equal_to_max: # else

slt $t7, $t6, $t3 # if (((word*)array)[mid] < next_min)
beq $t7, $zero, skip_next_min_update

move $t3, $t6 # next_min = ((word*)array)[mid]

skip_next_min_update:

slt $t7, $t4, $t6 # if (((word*)array)[mid] > next_max)
beq $t7, $zero, skip_next_max_update

move $t4, $t6 # next_max = ((word*)array)[mid]

skip_next_max_update:

addi $t1, $t1, 1 # mid++

end_if:

j place_min_max_loop

end_of_place_min_max_loop:

move $s2, $t3 # min = next_min
move $s3, $t4 # max = next_max
move $t1, $t0 # mid = low

j sort_loop

end_of_sort_loop:

move $t0, $zero # i = 0
move $t1, $s1   # byte* ptr

display_loop:

slt $t2, $t0, $s0 # while (i < N)
beq $t2, $zero, end_of_display_loop

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

end_of_display_loop:

li $t0, 1       # i = 1
move $t1, $s1   # byte* ptr
move $t5, $zero # not_sorted = false: sorted = true

test_loop:

slt $t2, $t0, $s0 # while (i < N)
beq $t2, $zero, end_of_test_loop

addi $t2, $t1, 4 # array + i * sizeof(word)

lw $t3, 0($t1) # *(word*)(array + (i - 1) * sizeof(word)): ((word*)array)[i - 1]
lw $t4, 0($t2) # *(word*)(array + i * sizeof(word)): ((word*)array)[i]

slt $t5, $t4, $t3 # if (((word*)array)[i] < ((word*)array)[i - 1])
bne $t5, $zero, end_of_test_loop

addi $t1, $t1, 4 # ptr += sizeof(word)
addi $t0, $t0, 1 # i++

j test_loop

end_of_test_loop:

la $a0, status
li $v0, 4 # print the status string
syscall

xori $a0, $t5, 1
li $v0, 1 # print the flag negated
syscall

li $v0, 10 # exit
syscall