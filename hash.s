# Nenhum bug com os testes que realizei

.data
str_first:	.asciiz	"Digite o numero de uma das opcoes a seguir:\n"
str_inserir:	.asciiz	"(1)Inserir elemento na tabela hash\n"
str_remover:	.asciiz	"(2)Remover elemento da tabela hash\n"
str_buscar:	.asciiz	"(3)Buscar por chave\n"
str_exibir:	.asciiz	"(4)Exibir tabela hash\n"
str_sair:	.asciiz	"(0)Sair\n"
str_chave:	.asciiz	"Digite um valor de chave\n"
str_entrada:	.asciiz "A entrada dessa chave no vetor é: "
.align 4
TabelaHash:	.space  64
sep:   		.asciiz " --> "
newline:	.asciiz "\n"

.align 2
.text
.globl main
main:		
		addi $t0, $zero, 0	#t0 = base do vetor
		addi $t1, $zero, -1		#t1 = conteudo a ser gravado
		
popula:		sw   $t1, TabelaHash($t0)
		addi $t0, $t0, 4
		bne  $t0, 64, popula

#aqui começa o do...while do menu
do_while:
		li $t3, 0
		
		li $v0, 4
		la $a0, newline
		syscall
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
		
		j remove
case3:
		j procura
case4:
		li $v0, 4
	        la $a0, newline
	        syscall
	      
		lw  $s0, TabelaHash($t3)
		
		add $t3, $t3, 4
		
		bgt $t3, 64, do_while
		beq $s0, -1, outro_menosum		
		j exibe
case0:
		li $v0, 10
		syscall
		

#Funções começam a partir daqui. 
#---------------------------------------------------------------------------------------------------------------------------#
#---------------------------------------------------------------------------------------------------------------------------#
#função insere
insere:		
		li $v0, 5
		syscall

		add $t2, $zero, $v0		#grava permanentemente o conteúdo escrito do teclado para t2
			
		jal hash
		
		mul $t3, $t3, 4
		
#insere continua normalmente, essa label é apenas para tratar a existencia da chave no vetor	
trata_existencia:
		li  $v0,9             #aloca memória
	        li  $a0,12            #aloca 4 pro conteudo e 8 para 2 ponteiros, um para o proximo e outro para o anterior 
	        syscall
		
		move  $s1, $v0		# $s1 = &(primeiro)
        	sw  $s1, TabelaHash($t3)
        	move  $s0, $s1

                # grava conteúdo passado pelo teclado na memória nos primeiros 4 bytes da memória
	        sw $t2, 0($s1)
	        
	                
loop: 
		li $v0, 4
		la $a0, str_chave
		syscall
		li $v0, 5
		syscall
		
		add $t2, $zero, $v0		#grava permanentemente o conteúdo escrito do teclado para t2
		
		beq $v0, -1, fim
		
		jal hash
		
		#verifica se a chave já existe no vetor, se não existe ele pula pra primeira iteração
		mul $t3, $t3, 4
		lw  $s2, TabelaHash($t3)		#salvando em registrador qualquer
		beq $s2, -1, trata_existencia
 
      		li $v0,9        
	        li $a0,12         
	        syscall        
       
        #aponta para o anterior 
        	sw $s1, 8($v0)			# $s1 = &(anterior)
        # aponta para o próximo
        	sw $v0, 4($s1)        		# $v0 = &(proximo)
        	
	        
        #fazer a nova struct ser a atual
        	move $s1,$v0
        
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
#---------------------------------------------------------------------------------------------------------------------------#
#essa remoção remove o primeiro nó da lista
remove:
		li $v0, 4
		la $a0, str_chave
		syscall
		
		li $v0, 5
		syscall
		
		beq $v0, -1, do_while
		
		add $t2, $zero, $v0
		jal hash
		
		mul $t3, $t2, 4
		lw $s0, TabelaHash($t3)
		
		lw $s0, 4($s0)				#capturo os ultimos 4 bytes do primeiro nó referente ao endereço
		sw $s0, TabelaHash($t3)			#gravo este endereço em TabelaHash para que ela aponte para o segundo nó
		j remove	


#---------------------------------------------------------------------------------------------------------------------------#
#---------------------------------------------------------------------------------------------------------------------------#
#função de busca
procura:	
		li $v0, 4
		la $a0, str_chave
		syscall
		
		li $v0, 5
		syscall
		
		add $t2, $zero, $v0
		jal hash
		
		mul $t3, $t3, 4
		
	        lw  $s0,TabelaHash($t3)		#recupera o dado da struct
		
for_interno:	beqz $s0, menosum			# enquanto o ponteiro não for null
	        

	        beq $s0, -1, menosum
        	lw $a0, 0($s0)               
	        
	        beq $a0, $v0, printa_conteudo             
	        	        
	        la $s0,4($s0)         #carrega ponteiro para a proxima struct
		
		j for_interno
		
printa_conteudo:
		li $v0, 1
		la $a0, ($a0)
		syscall
		
		j do_while
		
menosum:	
		li $v0, 1
		li $a0, -1
		syscall

		j do_while


#---------------------------------------------------------------------------------------------------------------------------#
#---------------------------------------------------------------------------------------------------------------------------#
#função que exibe a tabela hash inteira
exibe:		
		beqz $s0, case4			# enquanto o ponteiro não for null
	        
        	li $v0,1				#printa
        	lw  $a0,0($s0)		#recupera o dado da struct
	        syscall                   
	        
	        la $a0,sep            #printa separador
	        li $v0,4              
	        syscall               
	        	        
	        lw $s0,4($s0)         #carrega ponteiro para a proxima struct
	        b exibe
	        
#printa -1 a qualquer custo quando a lista estiver vazia
outro_menosum:
		li $v0,1
        	li  $a0,-1		
	        syscall                              
	        
	        b case4
