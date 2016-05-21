##################
# Seccion de datos
	.data

#Cadenas del programa
$str1:
	.asciiz "not"
$str2:
	.asciiz "\n"
$str3:
	.asciiz "igual"
$str4:
	.asciiz "distinto"
$str5:
	.asciiz "mayor"
$str6:
	.asciiz "menor"
$str7:
	.asciiz "mayorigual"
$str8:
	.asciiz "menorigual"
$str9:
	.asciiz "complejo"
$str10:
	.asciiz "incomplejo"
$str11:
	.asciiz "Bucle hacer "

#Variables globales
_a:
	.word 0
_b:
	.word 0
_c:
	.word 0
_i:
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
	li $t0, 0
	sw $t0, _i
$l10:
	lw $t1, _i
	li $t2, 2
	slt $t3, $t1, $t2
	beqz $t3, $l11
	lw $t1, _a
	xori $t1, $t1, 1
	beqz $t1, $l1
	la $a0, $str1
	li $v0, 4
	syscall
	la $a0, $str2
	li $v0, 4
	syscall
$l1:
	lw $t1, _c
	lw $t2, _b
	seq $t5, $t1, $t2
	beqz $t5, $l2
	la $a0, $str3
	li $v0, 4
	syscall
	la $a0, $str2
	li $v0, 4
	syscall
$l2:
	lw $t1, _a
	lw $t2, _b
	sne $t5, $t1, $t2
	beqz $t5, $l3
	la $a0, $str4
	li $v0, 4
	syscall
	la $a0, $str2
	li $v0, 4
	syscall
$l3:
	lw $t1, _a
	lw $t2, _b
	sgt $t5, $t1, $t2
	beqz $t5, $l4
	la $a0, $str5
	li $v0, 4
	syscall
	la $a0, $str2
	li $v0, 4
	syscall
$l4:
	lw $t1, _b
	lw $t2, _a
	slt $t5, $t1, $t2
	beqz $t5, $l5
	la $a0, $str6
	li $v0, 4
	syscall
	la $a0, $str2
	li $v0, 4
	syscall
$l5:
	lw $t1, _a
	lw $t2, _b
	sge $t5, $t1, $t2
	beqz $t5, $l6
	la $a0, $str7
	li $v0, 4
	syscall
	la $a0, $str2
	li $v0, 4
	syscall
$l6:
	lw $t1, _b
	lw $t2, _a
	sle $t5, $t1, $t2
	beqz $t5, $l7
	la $a0, $str8
	li $v0, 4
	syscall
	la $a0, $str2
	li $v0, 4
	syscall
$l7:
	lw $t1, _a
	lw $t2, _b
	add $t5, $t1, $t2
	lw $t1, _c
	sgt $t2, $t5, $t1
	beqz $t2, $l8
	la $a0, $str9
	li $v0, 4
	syscall
	la $a0, $str2
	li $v0, 4
	syscall
	b $l9
$l8:
	la $a0, $str10
	li $v0, 4
	syscall
	la $a0, $str2
	li $v0, 4
	syscall
$l9:
	la $a0, $str2
	li $v0, 4
	syscall
	li $t1, 0
	sw $t1, _a
	li $t1, 4
	sw $t1, _b
	lw $t1, _i
	li $t2, 1
	add $t4, $t1, $t2
	sw $t4, _i
	b $l10
$l11:
$l13:
	la $a0, $str11
	li $v0, 4
	syscall
	lw $t1, _a
	move $a0, $t1
	li $v0, 1
	syscall
	la $a0, $str2
	li $v0, 4
	syscall
	lw $t1, _a
	li $t2, 1
	add $t3, $t1, $t2
	sw $t3, _a
	lw $t1, _a
	li $t2, 2
	slt $t3, $t1, $t2
	bnez $t3, $l13

###################
# Fin
	jr $ra