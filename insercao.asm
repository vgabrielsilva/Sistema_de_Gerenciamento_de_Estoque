.data
arquivo_temporario: .asciiz "temporario.txt"  
arquivo_produtos: .asciiz "produtos.txt" 
arquivo_status: .asciiz "status.txt"     
linha: .space 80
tamanho_linha:  .word 80                 
string_produto: .asciiz "; PRODUTO: "
cod_string: .asciiz "COD: "
espaco_branco: .byte 32
quebra_linha:   .byte '\n'  
pipe:           .byte '|'  
string_status:  .asciiz "PRODUTO INSERIDO"               

.text
.globl main

main:
    lw $t7, tamanho_linha # Carrega o tamanho de uma linha (arbitrario)

    li $t0,11             #Registrador o qual comportará o tamanho da linha que será escrita(; PRODUTO: ) 11 bytes
    addi $t0,$t0,5      # (COD: ) 5 bytes
    
    jal recolher_produto_inserir
    
    add $t0,$t0,$t1      # soma com a quantidade de bytes lidos do arquivo temporário
    move $s1,$t1         #fez uma cópia da quantidade bytes lidos
    jal criar_codigo     # já possui o código a ser escrito armazena em $t1
    
    move $t5,$t1      # copia o valor do código para descobrir grandeza

    jal descobrir_grandeza  # a grandeza fica armazenada em $t2 (100 = 3 numeros, 11 = 2 numeros, ...)
    
    add $t0,$t0,$t2         # adiciona a grandeza

    jal descobrir_espaco_branco # número de caracteres em branco a adicionar para completar 80 caracteres

    jal escrever_cod_string     # escreve a string ("COD: ")
    
    li $t5,10
    move $t2, $zero
    jal converter_numero    
    
                   
    
      
    
    jal escrever_string_produto   # Escrever (; PRODUTO: )
    
    jal escrever_produto          #Escrever o produto a ser adicionado
    
    jal escrever_espacos_branco   # Escrever os espacos em branco
    
    
      

    li $v0,10
    syscall





    
   
escrever_espacos_branco:
   
   li $t0,0
    
   li $v0,13
   la $a0,arquivo_produtos
   li $a1,9
   syscall
   move $s0,$v0


loop:
   li $v0,15
   move $a0,$s0
   la $a1, espaco_branco
   li $a2,1
   syscall
   beq $t0,$t6, fim_espacos_branco
   
   addi $t0,$t0,1
   j loop
 
fim_espacos_branco:

   li $v0,15
   move $a0,$s0
   la $a1, quebra_linha
   li $a2,1
   syscall

    li $v0,16
    move $a0,$s0
    syscall
    jr $ra







escrever_produto:

    li $v0,13
    la $a0,arquivo_temporario
    li $a1,0
    syscall
    move $s0,$v0



    li $v0,14
    move $a0,$s0
    la $a1, linha       #---Lê o produto e salva quantos bytes foram lidos
    move $a2,$s1
    syscall
    

    li $v0,16
    move $a0,$s0
    syscall


    li $v0,13
    la $a0,arquivo_produtos
    li $a1,9
    syscall
    move $s0,$v0

    li $v0,15
    move $a0,$s0
    la $a1,linha
    move $a2,$s1
    syscall
    

    li $v0,15
    move $a0,$s0
    la $a1,pipe
    li $a2,1
    syscall


    li $v0,16
    move $a0,$s0
    syscall

    jr $ra





escrever_string_produto:

    li $v0,13
    la $a0,arquivo_produtos
    li $a1,9
    syscall
    move $s0,$v0

    li $v0,15
    move $a0,$s0
    la $a1,string_produto
    li $a2,11
    syscall
    

    li $v0,16
    move $a0,$s0
    syscall
    
    

    jr $ra







converter_numero:
   
    beqz $t1, escrever_numero_caracter
    
    div $t1, $t5
    mflo $t1
    mfhi $t3

    addi $t3, $t3, 48   # Converter ASCII
    sub $sp, $sp, 4 # Aumenta a pilha
    sb $t3, 0($sp)
    addi $t2, $t2, 1
    
    j converter_numero
    

escrever_numero_caracter:

    beqz $t2, fim
    
    li $v0,13
    la $a0,arquivo_produtos
    li $a1,9                   #abertura para adicionar no final
    syscall
    move $s0, $v0

    la $a1, 0($sp)
    addi $sp, $sp, 4    # Desempilha
    subi $t2, $t2, 1    # Decrementa contador da pilha
    
    li $v0,15
    move $a0,$s0
    li $a2,1
    syscall

    li $v0,16
    move $a0,$s0
    syscall

    j escrever_numero_caracter
    

fim:

    jr $ra



escrever_cod_string:

    li $v0,13
    la $a0,arquivo_produtos
    li $a1,9                        #Abre o arquivo para escrever no final
    syscall
    move $s0,$v0


    li $v0,15
    move $a0,$s0
    la $a1,cod_string
    li $a2, 5
    syscall


    li $v0,16
    move $a0,$s0
    syscall

    jr $ra



descobrir_espaco_branco:

    sub $t6,$t7,$t0
    subi $t6,$t6,3
    

    jr $ra







descobrir_grandeza:     # 123     123 /10 = R1= 12 R2 = 3  123 /10 = 12.3
  
    #$t2 é o contador da grandeza
    li $t2,1

loop_grandeza:

    div $t5,$t5,10
    mflo $t3

    beq $t3, $zero, fim_procura
    addi $t2,$t2,1
    move $t5,$t3

    j loop_grandeza
    

fim_procura:
    
    jr $ra




criar_codigo:
    li $t1,1    #inicializa o contador com 1
    
    li $v0,13
    la $a0,arquivo_produtos
    li $a1,0
    syscall
    
    move $s0,$v0


ler_linha:

    li $v0,14
    move $a0,$s0                  
    la $a1,linha
    move $a2,$t7
    syscall
    beq $v0,$zero,fim_do_arquivo
    addi $t1,$t1,1           # toda linha tem 80 caracteres, logo há a quebra de linha
    j ler_linha
    

fim_do_arquivo:
    li $v0,16
    move $a0,$s0
    syscall
    jr $ra
    
     

recolher_produto_inserir:
     


    li $v0,13
    la $a0,arquivo_temporario
    li $a1,0
    syscall
    move $s0,$v0        #salva o descritor do arquivo em $s0
     

    



    li $v0, 14
    move $a0,$s0
    la $a1,linha
    move $a2,$t7       # define que o espaço máximo para ler é 80
    syscall 
    move $t1,$v0        # move para $t1 a quantidade de bytes lidos

    

    li $v0,16
    move $a0,$s0
    syscall             #fecha o arquivo

    

    jr $ra
   
    
