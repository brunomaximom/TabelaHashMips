.data
str_first:	.asciiz	"Digite o numero de uma das opcoes a seguir:\n"
str_inserir:	.asciiz	"(1)Inserir elemento na tabela hash\n"
str_remover:	.asciiz	"(2)Remover elemento da tabela hash\n"
str_buscar:	.asciiz	"(3)Buscar elemento na tabela hash\n"
str_exibir:	.asciiz	"(4)Exibir tabela hash\n"
str_sair:	.asciiz	"(0)Sair\n"
str_chave:	.asciiz	"Digite um valor de chave\n"
.align 4
TabelaHash:	.space  64
sep:   		.asciiz " --> "

.align 2
.text
.globl main
main:		li $t8, 4		#resolvedor de erros de load/store no trabalho inteiro :P 
		addi $t0, $zero, 0	#t0 = base do vetor
		addi $t1, $zero, -1		#t1 = conteudo a ser gravado
		
popula:		sw   $t1, TabelaHash($t0)
		addi $t0, $t0, 4
		bne  $t0, 64, popula

#aqui começa o do...while do menu
do_while:
		li $v0, 4
		la $a0, str_first
		syscall
		li $v0, 4
		la $a0, str_inserir
		syscall
		li $v0, 4
		la $a0, str_remover
		syscall
		li $v0, 4
		la $a0, str_buscar
		syscall
		li $v0, 4
		la $a0, str_exibir
		syscall
		li $v0, 4
		la $a0, str_sair
		syscall
		li $v0, 5	#v0 se torna a opção do switch
		syscall

#começo do switch
		addi $t1, $zero, 1
		beq   $v0, $t1, case1
		addi $t1, $zero, 2
		beq   $v0, $t1, case2
		addi $t1, $zero, 3
		beq   $v0, $t1, case3
		addi $t1, $zero, 4
		beq   $v0, $t1, case4
		addi $t1, $zero, 0
		beq   $v0, $t1, case0
		
case1:		
		li $v0, 4
		la $a0, str_chave
		syscall
		j insere
case2:
		li $v0, 4
		la $a0, str_chave
		syscall
		li $v0, 5
		syscall
		j do_while
case3:
		li $v0, 4
		la $a0, str_chave
		syscall
		li $v0, 5
		syscall
		j do_while
case4:
		j exibe
case0:
		li $v0, 10
		syscall
		

#Funções começam a partir daqui. 
#---------------------------------------------------------------------------------------------------------------------------#
insere:		
		li $v0, 5
		syscall
#insere continua normalmente, essa label é apenas para tratar a existencia da chave no vetor	
trata_existencia:
		add $t2, $zero, $v0		#grava permanentemente o conteúdo escrito do teclado para t2
			
		jal hash
		mul $t3, $t3, $t8
		li  $v0,9             #aloca memória
	        li  $a0,8             
	        syscall
		
		move  $s1, $v0		# $s1 = &(primeiro)
        	sw  $s1, TabelaHash($t3)
        	move  $s0, $s1

                # grava conteúdo passado pelo teclado na memória nos primeiros 4 bytes da memória
	        sw $t2, 0($s1)
	        
	        li $s2, 2             # counter = 2
	        
	                
loop: 
		li $v0, 4
		la $a0, str_chave
		syscall
		li $v0, 5
		syscall
		
		add $t2, $zero, $v0		#grava permanentemente o conteúdo escrito do teclado para t2

		li $t9, -1			#condição de parada
		beq $v0, $t9, fim
		
		#verifica se a chave já existe no vetor, se não existe ele pula pra primeira iteração
		la  $s1, TabelaHash($v0)		#salvando em registrador qualquer
		beq $t9, $s1, trata_existencia
		
		jal hash
 
		mul $t3, $t3, $t8
      		li $v0,9        
	        li $a0,8            
	        syscall        
        
        # aponta para o próximo
        	sw $v0,4($s1)        # $s1 = &(proximo)
	        
        #fazer a nova struct ser a atual
        	move $s1,$v0
        	sw $s1, TabelaHash($t3)
        	
        #inicializa a struct
	        sw $t2,0($s1)

        	addi $s2,$s2,1         #counter++
	        b loop
        
fim:
		sw $zero,4($s1)		# coloca null
		lw $s0, TabelaHash($t3)
	        j do_while           


#---------------------------------------------------------------------------------------------------------------------------#
hash:					#t3 retornará a posição da tabela
		li $a1, 16		#carrego 16 em a1 só para a divisão
		div $t2, $a1		#divido t2 por a1 e gravo em t2
		mfhi $t3		#recupero o resto da divisão que fica em hi
		jr $ra


#---------------------------------------------------------------------------------------------------------------------------#
remove:

		j do_while	


#---------------------------------------------------------------------------------------------------------------------------#
procura:	


#---------------------------------------------------------------------------------------------------------------------------#
exibe:
		beq $s0, $t9, do_while			# enquanto o ponteiro não for null
	        
        	li $v0,1				#printa
        	lw  $a0,TabelaHash($t3)		#recupera o dado da struct
	        syscall                   
	        
	        la $a0,sep            #printa separador
	        li $v0,4              
	        syscall               
	        	        
	        la $s0,4($s0)         #carrega ponteiro para a proxima struct
	        b case0
