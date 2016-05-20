##################
# Seccion de datos
	.data

#Cadenas del programa
$str1:
	.asciiz "\n"
$str2:
	.asciiz "igual"
$str3:
	.asciiz "distinto"
$str4:
	.asciiz "mayor"
$str5:
	.asciiz "menor"
$str6:
	.asciiz "mayorigual"
$str7:
	.asciiz "menorigual"
$str8:
	.asciiz "complejo"
$str9:
	.asciiz "incomplejo"

#Variables globales
_a:
	.word 0
_b:
	.word 0
_c:
	.word 0
###################
# Seccion de codigo
	.text

	.globl main
main:
	# Aqui comienzan las instrucciones del programa
	li $t0, 1
	sw $t0, _a
	li $t0, 0
	sw $t0, _b
	li $t0, 3
	sw $t0, _c
	lw $t0, _a
	xori $t0, $t0, 1
	beqz $t0, $l1
	lw $t1, _a
	move $a0, $t1
	li $v0, 1
	syscall
	la $a0, $str1
	li $v0, 4
	syscall
$l1:
	lw $t0, _a
	lw $t1, _b
	seq $t2, $t0, $t1
	beqz $t2, $l2
	la $a0, $str2
	li $v0, 4
	syscall
	la $a0, $str1
	li $v0, 4
	syscall
$l2:
	lw $t0, _a
	lw $t1, _b
	sne $t2, $t0, $t1
	beqz $t2, $l3
	la $a0, $str3
	li $v0, 4
	syscall
	la $a0, $str1
	li $v0, 4
	syscall
$l3:
	lw $t0, _a
	lw $t1, _b
	sgt $t2, $t0, $t1
	beqz $t2, $l4
	la $a0, $str4
	li $v0, 4
	syscall
	la $a0, $str1
	li $v0, 4
	syscall
$l4:
	lw $t0, _b
	lw $t1, _a
	slt $t2, $t0, $t1
	beqz $t2, $l5
	la $a0, $str5
	li $v0, 4
	syscall
	la $a0, $str1
	li $v0, 4
	syscall
$l5:
	lw $t0, _a
	lw $t1, _b
	sge $t2, $t0, $t1
	beqz $t2, $l6
	la $a0, $str6
	li $v0, 4
	syscall
	la $a0, $str1
	li $v0, 4
	syscall
$l6:
	lw $t0, _b
	lw $t1, _a
	sle $t2, $t0, $t1
	beqz $t2, $l7
	la $a0, $str7
	li $v0, 4
	syscall
	la $a0, $str1
	li $v0, 4
	syscall
$l7:
	lw $t0, _a
	lw $t1, _b
	add $t2, $t0, $t1
	xori $t2, $t2, 1
	lw $t0, _c
	xori $t0, $t0, 1
	sgt $t1, $t2, $t0
	beqz $t1, $l8
	la $a0, $str8
	li $v0, 4
	syscall
	la $a0, $str1
	li $v0, 4
	syscall
	b $l9
$l8:
	la $a0, $str9
	li $v0, 4
	syscall
	la $a0, $str1
	li $v0, 4
	syscall
$l9:
