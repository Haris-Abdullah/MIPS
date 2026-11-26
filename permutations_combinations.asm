.data

n: .word 9
r: .word 4

nCr: .space 4
nPr: .space 4

.text

main:

la $t0, n
lw $t0, 0($t0) # n

la $t1, r
lw $t1, 0($t1) # r

addi $sp, $sp, -8 # alloc(2 * sizeof(word))

sw $t0, 0($sp) # n
sw $t1, 4($sp) # r

jal comb # comb(n, r)

lw $t0, 0($sp)
la $t1, nPr
sw $t0, 0($t1)

lw $t0, 4($sp)
la $t1, nCr
sw $t0, 0($t1)

addi $sp, $sp, 8 # dealloc(2 * sizeof(word))

j end_of_program

comb: # comb(n, r)

addi $sp, $sp, -4 # alloc(sizeof(word))
sw $ra, 0($sp)

lw $t0, 4($sp) # n
lw $t1, 8($sp) # r

addi $sp, $sp, -8 # alloc(2 * sizeof(word))

sw $t0, 0($sp) # n
sw $t1, 4($sp) # r

jal perm # perm(n, r)

lw $t0, 12($sp) # r

addi $sp, $sp, -4 # alloc(sizeof(word))
sw $t0, 0($sp)

jal fact # fact(r)

lw $t0, 0($sp) # fact(r)
lw $t1, 4($sp) # perm(n, r)

div $t2, $t1, $t0 # comb(n, r) = perm(n, r) / fact(r)

lw $ra, 8($sp)

addi $sp, $sp, 20 # dealloc(5 * sizeof(word))

addi $sp, $sp, -8 # alloc(2 * sizeof(word))

sw $t1, 0($sp) # perm(n, r)
sw $t2, 4($sp) # comb(n, r)

jr $ra

perm: # perm(n, r)

addi $sp, $sp, -4 # alloc(sizeof(word))
sw $ra, 0($sp)

lw $t0, 4($sp) # n

addi $sp, $sp, -4 # alloc(sizeof(word))
sw $t0, 0($sp)

jal fact # fact(n)

lw $t0, 8($sp)  # n
lw $t1, 12($sp) # r

sub $t0, $t0, $t1 # n - r

addi $sp, $sp, -4 # alloc(sizeof(word))
sw $t0, 0($sp)

jal fact # fact(n - r)

lw $t0, 0($sp) # fact(n - r)
lw $t1, 4($sp) # fact(n)

div $t0, $t1, $t0 # fact(n) / fact(n - r)

lw $ra, 8($sp)

addi $sp, $sp, 20 # dealloc(5 * sizeof(word))

addi $sp, $sp, -4 # alloc(sizeof(word))
sw $t0, 0($sp)

jr $ra

fact: # fact(n)

li $t0, 1 # i = 1
li $t1, 1 # res = 1

lw $t2, 0($sp) # n

loop:

slt $t3, $t2, $t0 # while (!(n < i))
bne $t3, $zero, end_of_loop

mul $t1, $t1, $t0 # res *= i

addi $t0, $t0, 1 # i++

j loop

end_of_loop:

addi $sp, $sp, 4 # dealloc(sizeof(word))

addi $sp, $sp, -4 # alloc(sizeof(word))
sw $t1, 0($sp)

jr $ra

end_of_program:

li $v0, 10 # program exit syscall
syscall