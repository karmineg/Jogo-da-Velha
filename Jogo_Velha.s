.data
	msg: .asciiz "Jogo da velha\n"
	msg2: .asciiz ">> Insira posicao y (0, 1 ou 2): "
	msg3: .asciiz ">> Insira posicao x (0, 1 ou 2): "
	msg4: .asciiz "*** PARABENS!!! Jogador "
	msg5: .asciiz " venceu!! ***"
	msg6: .asciiz ">> Escolha um para comecar (digite o numero)\n - O: 1\n - X: 2\n"
	msg7: .asciiz "\n>> Agora e a vez do jogador "
	msg8: .asciiz "*** NENHUM jogador venceu!! DEU VELHA!! ***"
	msg9: .asciiz "!!! ERRO: Valor NAO pode ser negativo !!!\n\n"
	msg10: .asciiz "!!! ERRO: Valor NAO pode ser MAIOR que dois !!!\n\n"
	msg11: .asciiz "!!! ERRO: Posicao inserida JA FOI MARCADA... Escolha outra !!!\n\n"
	msg12: .asciiz "!!! ERRO: Valor NAO pode ser NULO ou NEGATIVO !!!\n\n"
	C: .asciiz "-XO\n"
	V: .word 0:9
	S: .word 0:8
.text
	.globl main
main:
	# CONSTANTES FUNDAMENTAIS DO PROGRAMA
	LADO = 3
	TOTAL = 9
	TOTAL_BYTE = 36
	SEQ_BYTE = 32

	# USUÁRIO INSERE SEMENTE PARA PROGRAMA
	li $v0, 4
	la $a0, msg
	syscall
	
	li $t0, 0 # Contador (de 0 a 8)
	li $s0, 0 # 0: "-", 1: "X" ou 2: "O"

SETAR_V:
	sw $s0, V($t0)
	add $t0, $t0, 4
	beq $t0, TOTAL_BYTE, PREPARAR_SETAR_S
	j SETAR_V

PREPARAR_SETAR_S:
	li $t0, 0
	j SETAR_S

SETAR_S:
	sw $s0, S($t0)
	add $t0, $t0, 4
	beq $t0, SEQ_BYTE, ESCOLHER_X_O
	j SETAR_S


ESCOLHER_X_O:
	la $a0, msg6
	syscall
	
	li $v0, 5
	syscall
	
	ble $v0, $zero, X_O_MENOR
	bge $v0, LADO, X_O_MAIOR
	j PREPARAR_MOSTRAR_ANT
	

X_O_MENOR:
	li $v0, 4
	la $a0, msg12
	syscall
	j ESCOLHER_X_O
	

X_O_MAIOR:
	li $v0, 4
	la $a0, msg10
	syscall
	j ESCOLHER_X_O

	
PREPARAR_MOSTRAR_ANT:

	move $s0, $v0
	li $t4, 0 # Contador de jogadas
	j PREPARAR_MOSTRAR


PREPARAR_MOSTRAR:
	mul $s0, $s0, -1
	add $s0, $s0, 3
	
	li $v0, 4
	la $a0, msg7
	syscall
	
	li $v0, 11
	lb $a0, C($s0)
	syscall
	li $t0, 3
	lb $a0, C($t0)
	syscall
	
	
	li $t0, 0 # Contador de linha (de 0 a 2)
	li $t2, 0 # Contador de itens (de 0 a 8)
	
	li $t3, 3
	lb $a0, C($t3)
	syscall
	j MOSTRAR_LINHA
	

MOSTRAR_LINHA:
	add $t0, $t0, 1
	li $t1, 0 # Contador de colunas (de 0 a 2)
	j MOSTRAR_ITEM


MOSTRAR_ITEM:
	add $t1, $t1, 1
	
	lw $t3, V($t2)
	lb $a0, C($t3)
	syscall
	
	add $t2, $t2, 4
	beq $t1, LADO, NOVA_LINHA
	j MOSTRAR_ITEM
	
	
NOVA_LINHA:
	li $t3, 3 # Quebra de linha (posição em byte)
	lb $a0, C($t3)
	syscall

	beq $t0, LADO, INSERIR_X
	blt $t0, LADO, MOSTRAR_LINHA


INSERIR_X:
	li $v0, 4
	la $a0, msg2
	syscall
	
	li $v0, 5
	syscall
	
	blt $v0, $zero, MENSAGEM_X_NEG
	bge $v0, LADO, MENSAGEM_X_G
	j PREPARAR_INSERIR_Y
	
	
MENSAGEM_X_NEG:

	li $v0, 4
	la $a0, msg9
	syscall
	j INSERIR_X


MENSAGEM_X_G:

	li $v0, 4
	la $a0, msg10
	syscall
	j INSERIR_X
	
	
PREPARAR_INSERIR_Y:
	
	move $t0, $v0 # t0: Coordenada "x"
	j INSERIR_Y

	
INSERIR_Y:

	li $v0, 4
	la $a0, msg3
	syscall
	
	li $v0, 5
	syscall
	
	blt $v0, $zero, MENSAGEM_Y_NEG
	bge $v0, LADO, MENSAGEM_Y_G
	j PREPARAR_ANALISAR_V


MENSAGEM_Y_NEG:

	li $v0, 4
	la $a0, msg9
	syscall
	j INSERIR_Y
	

MENSAGEM_Y_G:
	
	li $v0, 4
	la $a0, msg10
	syscall
	j INSERIR_Y
	

PREPARAR_ANALISAR_V:
	move $t1, $v0 # t1: Coordenada "y"
	j ANALISAR_V


ANALISAR_V:
	# t0 = 3*t0 + t1
	# t1 = 4*t0 = 4*(3*t0 + t1)
	
	mul $t0, $t0, 3 # 3*t0
	add $t0, $t0, $t1 # 3*t0 + t1
	mul $t1, $t0, 4 # t1 = 4*(3*t0 + t1)
	
	lw $s6, V($t1)
	bgt $s6, $zero, POSICAO_JA_INSERIDA
	j MUDAR_V
	
	
POSICAO_JA_INSERIDA:

	li $v0, 4
	la $a0, msg11
	syscall
	j INSERIR_X
	
	
MUDAR_V:
	
	sw $s0, V($t1)
	
	# Linha
	div $s3, $t0, 3
	
	# Coluna
	rem $s4, $t0, 3
	add $s4, $s4, 3
	
	mul $s3, $s3, 4
	mul $s4, $s4, 4
	
	# Diagonal (cima para baixo) (6)
	rem $s5, $t0, 4
	
	# Diagonal (baixo para cima) (7)
	rem $s6, $t0, 2
	
	# Múltiplo de 8
	rem $s7, $t0, 8
	
	
	# "X": 1; "O": -1
	mul $s1, $s0, -2
	add $s1, $s1, 3
	
	
	# Atualizando linha
	lw $s2, S($s3)
	add $s2, $s2, $s1
	sw $s2, S($s3)
	
	# Atualizando coluna
	lw $s2, S($s4)
	add $s2, $s2, $s1
	sw $s2, S($s4)
	
	beq $s5, $zero, DIAGONAL_CB
	beq $s6, $zero, DIAGONAL_BC
	j MOSTRAR_VALOR
	
	
DIAGONAL_CB:
	li $s5, 24
	lw $s2, S($s5)
	add $s2, $s2, $s1
	sw $s2, S($s5)
	
	beq $s6, $zero, DIAGONAL_BC
	j MOSTRAR_VALOR
	

DIAGONAL_BC:
	beq $s7, $zero, MOSTRAR_VALOR
	
	li $s6, 28
	lw $s2, S($s6)
	add $s2, $s2, $s1
	sw $s2, S($s6)
	
	j MOSTRAR_VALOR
	
	
MOSTRAR_VALOR:
	
	li $v0, 11
	li $t3, 3
	lb $a0, C($t3)
	syscall
	
	li $t0, 0
	j MOSTRAR_SEQ
	
	
MOSTRAR_SEQ:
	lw $a0, S($t0)
	blt $a0, $zero, VIRAR_POSITIVO
	beq $a0, LADO, ACABOU
	j MOSTRAR_SEQ_2
	
	
VIRAR_POSITIVO:
	mul $a0, $a0, -1
	beq $a0, LADO, ACABOU
	j MOSTRAR_SEQ_2
	
	
MOSTRAR_SEQ_2:
	add $t0, $t0, 4
	beq $t0, SEQ_BYTE, PROX_JOGADA
	j MOSTRAR_SEQ

PROX_JOGADA:
	add $t4, $t4, 1
	beq $t4, TOTAL, VELHA
	j PREPARAR_MOSTRAR

VELHA:
	li $v0, 4
	la $a0, msg8
	syscall
	j FINAL

ACABOU:
	li $v0, 4
	la $a0, msg4
	syscall
	
	li $v0, 11
	lb $a0, C($s0)
	syscall
	
	li $v0, 4
	la $a0, msg5
	syscall
	
FINAL: