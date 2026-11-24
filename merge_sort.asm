.data

array: .word 19, -7, 88, -97, 400, 63, -24, 41, 11, -11, -7, 63

end_line: .asciiz "\n"

.text

main:

la $s0, array # byte* array
li $s1, 12    # N = 12

sll $s2, $s1, 2   # N * sizeof(word)
sub $sp, $sp, $s2 # stack_alloc(N * sizeof(word))
move $t0, $sp     # byte* tmp

addi $sp, $sp, -16 # stack_alloc(4 * sizeof(word))

sw $s1, 12($sp)  # ub: N
sw $zero, 8($sp) # lb: 0
sw $t0, 4($sp)   # tmp
sw $s0, 0($sp)   # array

jal merge_sort   # merge_sort(array, tmp, 0, N)

move $a0, $s0 # ptr
move $a1, $s1 # N
jal display   # display(ptr, N)

add $sp, $sp, $s2 # stack_dealloc(N * sizeof(word))

j end_of_program

merge_sort: # void merge_sort(array, tmp, lb, ub)

lw $t0, 12($sp) # ub
lw $t1, 8($sp)  # lb

sub $t2, $t0, $t1 # ub - lb
li $t3, 1

slt $t4, $t3, $t2 # if (!(1 < ub - lb))
beq $t4, $zero, deallocate_and_return

lw $t2, 4($sp)  # tmp
lw $t3, 0($sp)  # array

sub $t4, $t0, $t1
srl $t4, $t4, 1
add $t4, $t1, $t4 # lb + (ub - lb) / 2: mid

addi $sp, $sp, -4 # stack_alloc(sizeof(word))
sw $t4, 0($sp)    # mid

addi $sp, $sp, -4 # stack_alloc(sizeof(word))
sw $ra, 0($sp)    # return address

addi $sp, $sp, -16 # stack_alloc(4 * sizeof(word))

sw $t4, 12($sp) # mid
sw $t1, 8($sp)  # lb
sw $t2, 4($sp)  # tmp
sw $t3, 0($sp)  # array

jal merge_sort # merge_sort(array, tmp, lb, mid): chunk [lb, mid)

lw $t0, 20($sp) # ub
lw $t1, 4($sp)  # mid
lw $t2, 12($sp) # tmp
lw $t3, 8($sp)  # array

addi $sp, $sp, -16 # stack_alloc(4 * sizeof(word))

sw $t0, 12($sp) # ub
sw $t1, 8($sp)  # mid
sw $t2, 4($sp)  # tmp
sw $t3, 0($sp)  # array

jal merge_sort # merge_sort(array, tmp, mid, ub): chunk [mid, ub)

lw $t0, 20($sp) # ub
lw $t1, 16($sp) # lb
lw $t2, 12($sp) # tmp
lw $t3, 8($sp)  # array
lw $t4, 4($sp)  # mid

move $t5, $t1 # l = lb
move $t6, $t4 # r = mid

addi $sp, $sp, -4 # stack_alloc(sizeof(word))
sw $s0, 0($sp)    # callee saved

merge_loop:

slt $t7, $t5, $t4 # l < mid
beq $t7, $zero, end_of_merge_loop
slt $t7, $t6, $t0 # r < ub
beq $t7, $zero, end_of_merge_loop

sll $t7, $t5, 2   # l * sizeof(word)
add $t7, $t3, $t7 # array + l * sizeof(word)
lw $t7, 0($t7)    # *(word*)(array + l * sizeof(word)): ((word*)array)[l]

sll $t8, $t6, 2   # r * sizeof(word)
add $t8, $t3, $t8 # array + r * sizeof(word)
lw $t8, 0($t8)    # *(word*)(array + r * sizeof(word)): ((word*)array)[r]

sub $t9, $t6, $t4
add $t9, $t5, $t9 # l + r - mid
sll $t9, $t9, 2   # (l + r - mid) * sizeof(word)
add $t9, $t2, $t9 # tmp + (l + r - mid) * sizeof(word)

slt $s0, $t8, $t7 # if (!(((word*)array)[r] < ((word*)array)[l]))
beq $s0, $zero, update_left_chunk_pointer

sw $t8, 0($t9)   # ((word*)tmp)[l + r - mid] = ((word*)array)[r]
addi $t6, $t6, 1 # r++

j end_of_update

update_left_chunk_pointer:

sw $t7, 0($t9)   # ((word*)tmp)[l + r - mid] = ((word*)array)[l]
addi $t5, $t5, 1 # l++

end_of_update:

j merge_loop

end_of_merge_loop:

flush_left_chunk_loop:

slt $t7, $t5, $t4 # l < mid
beq $t7, $zero, end_of_flush_left_chunk_loop

sll $t7, $t5, 2   # l * sizeof(word)
add $t7, $t3, $t7 # array + l * sizeof(word)
lw $t7, 0($t7)    # *(word*)(array + l * sizeof(word)): ((word*)array)[l]

sub $t8, $t6, $t4
add $t8, $t5, $t8 # l + r - mid
sll $t8, $t8, 2   # (l + r - mid) * sizeof(word)
add $t8, $t2, $t8 # tmp + (l + r - mid) * sizeof(word)

sw $t7, 0($t8)   # ((word*)tmp)[l + r - mid] = ((word*)array)[l]
addi $t5, $t5, 1 # l++

j flush_left_chunk_loop

end_of_flush_left_chunk_loop:

flush_right_chunk_loop:

slt $t7, $t6, $t0 # r < ub
beq $t7, $zero, end_of_flush_right_chunk_loop

sll $t7, $t6, 2   # r * sizeof(word)
add $t7, $t3, $t7 # array + r * sizeof(word)
lw $t7, 0($t7)    # *(word*)(array + r * sizeof(word)): ((word*)array)[r]

sub $t8, $t6, $t4
add $t8, $t5, $t8 # l + r - mid
sll $t8, $t8, 2   # (l + r - mid) * sizeof(word)
add $t8, $t2, $t8 # tmp + (l + r - mid) * sizeof(word)

sw $t7, 0($t8)   # ((word*)tmp)[l + r - mid] = ((word*)array)[r]
addi $t6, $t6, 1 # r++

j flush_right_chunk_loop

end_of_flush_right_chunk_loop:

move $t5, $t1 # i = lb

copy_loop:

slt $t6, $t5, $t0 # while (i < ub)
beq $t6, $zero, end_of_copy_loop

sll $t6, $t5, 2   # i * sizeof(word)
add $t6, $t2, $t6 # tmp + i * sizeof(word)
lw $t6, 0($t6)    # *(word*)(tmp + i * sizeof(word)): ((word*)tmp)[i]

sll $t7, $t5, 2   # i * sizeof(word)
add $t7, $t3, $t7 # array + i * sizeof(word)
sw $t6, 0($t7)    # ((word*)array)[i] = ((word*)tmp)[i]

addi $t5, $t5, 1 # i++

j copy_loop

end_of_copy_loop:

lw $ra, 4($sp) # retrieve the return address
lw $s0, 0($sp)

addi $sp, $sp, 12 # stack_dealloc(3 * sizeof(word))

deallocate_and_return:

addi $sp, $sp, 16 # stack_dealloc(4 * sizeof(word))

jr $ra

display: # void display(ptr, N)

li $t0, 0 # i = 0

display_loop:

slt $t1, $t0, $a1 # while (i < N)
beq $t1, $zero, end_of_display_loop

move $t1, $a0 # ptr

lw $a0, 0($t1)
li $v0, 1 # integer print syscall
syscall

la $a0, end_line
li $v0, 4 # string print syscall
syscall

addi $a0, $t1, 4 # ptr += sizeof(word)
addi $t0, $t0, 1 # i++

j display_loop

end_of_display_loop:

jr $ra

end_of_program:

li $v0, 10 # program exit syscall
syscall