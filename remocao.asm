.data
produto_removido: .asciiz "REMOVIDO                                                                       \n" #string para representar a remoção do produto
arquivo_produtos: .asciiz "produtos.txt"  # Arquivo de produtos
arquivo_temporario: .asciiz "temporario.txt"  # Arquivo temporário com a string a ser removida
arquivo_auxiliar: .asciiz "auxiliar.txt"  # Arquivo auxiliar para escrita
produto_remover: .space 80 # Buffer para armazenar a string a ser removida
linha_procura: .space 80 # Buffer para armazenar cada linha do arquivo de produtos
linha: .space 80 #buffer para armazenar de volta o arquivo de produtos
nda: .ascii ""
produto_nao_encontrado: .asciiz "PRODUTO NAO ENCONTRADO"
produto_encontrado: .asciiz "PRODUTO REMOVIDO"
removido_string:    .asciiz "REMOVIDO"

.text 
.globl main

main:
    li $t5,0                      # flag para informar se o produto foi encontrado ou não
   
   jal recolher_produto_remover   # recolhe o endereço do produto que deseja ser removido
   jal procurar_produto           # escreve no arquivo auxiliar todos os produtos exceto o removido
   jal limpa_arquivo_produtos    # limpa o conteúdo de produtos.txt para adicionar o conteúdo atualizado
   jal escrever_arquivo_produtos  # escreve o conteúdo do arquivo auxiliar no arquivo de produtos
   jal limpa_arquivo_auxiliar    # # limpa o conteúdo de auxiliar.txt para adicionar o conteúdo atualizado
   
     
    li $v0,10
    syscall







escrever_arquivo_produtos:

    li $v0,13
    la $a0,arquivo_auxiliar
    li $a1,0
    syscall
    move $s0,$v0

loop_escrita:

    li $v0,14
    move $a0,$s0
    la $a1,linha
    li $a2,80
    syscall
    
    beq $v0,$zero,fim_escrita
    
    li $v0,13
    la $a0,arquivo_produtos
    li $a1,9
    syscall
    move $s1,$v0

    li $v0,15
    move $a0,$s1
    la $a1,linha
    li $a2,80
    syscall

    li $v0,16
    move $a0,$s1
    syscall
    j loop_escrita

fim_escrita:

    li $v0,16
    move $a0,$s0
    syscall 
    jr $ra













limpa_arquivo_produtos:
    li $v0,13
    la $a0,arquivo_produtos
    li $a1,1
    syscall
    move $s0,$v0


    li $v0,15
    move $a0,$s0
    la $a1,nda
    li $a2,0
    syscall

    li $v0,16
    move $a0,$s0
    syscall
    jr $ra


limpa_arquivo_auxiliar:
    li $v0,13
    la $a0,arquivo_auxiliar
    li $a1,1
    syscall
    move $s0,$v0


    li $v0,15
    move $a0,$s0
    la $a1,nda
    li $a2,0
    syscall

    li $v0,16
    move $a0,$s0
    syscall
    jr $ra





recolher_produto_remover:

    li $v0,13
    la $a0,arquivo_temporario
    li $a1,0
    syscall
    move $s0,$v0
    
    li $v0,14
    move $a0,$s0
    la $a1,produto_remover
    li $a2,80
    syscall
    
    move $s1,$a1   #endereço do produto que será removido
    move $t0,$v0   #número de bytes que o produto a ser removido possui

    li $v0,16
    move $a0,$s0
    syscall

    jr $ra



procurar_produto:
    li $v0,13
    la $a0,arquivo_produtos     
    li $a1,0
    syscall
    move $s0,$v0

    leitura_linha:
    la $t7,removido_string
    lb $t6,0($t7)
    li $s5,0

        move $t4,$s1
        li $t3,0    # contador para comparar com $t0, que contem o tamanho do produto do arq temporario
        li $v0,14
        move $a0,$s0
        la $a1, linha_procura
        li $a2, 80
        syscall
        move $s4,$v0        #caracteres lidos veririca se chegou no final
        beq $s4,$zero,fim_verificacao
        
        
        move $s2, $a1       # move para $s2 o endereço da linha a ser analisada
        move $s6,$s2        # move para $s6 para escrever no auxiliar 
        
        beq $t5,1,escrever_restante
        
        ajuste_inicial_ponteiro: # verifica se o byte está posicionado para ler o nome do produto
            
            lb $t2,0($s2)   
            beq $t2, 59, fim_ajuste_inicial_ponteiro
            beq $t6,$t2,contar_removido
            addi $s2, $s2, 1
                 
            
            j ajuste_inicial_ponteiro
        contar_removido:
            addi $s5,$s5,1
            beq $s5,8,escrever_auxiliar
            addi $t7,$t7,1
            lb $t6,0($t7)
            j ajuste_inicial_ponteiro
        fim_ajuste_inicial_ponteiro:
            
           

            addi $s2, $s2, 11    # "; PRODUTO: COCA COLA|" Posiciona no primeiro caracter do nome do produto 
          

        loop_comparacao_produto:                       
            lb $t1,0($t4)
            lb $t2,0($s2)
            
           
            
            bne $t1,$t2,escrever_auxiliar
            
            addi $t4,$t4,1
            addi $s2,$s2,1
            addi $t3,$t3,1
            
            bne $t0,$t3,loop_comparacao_produto
             


            addi $s2,$s2,0
            lb $t2,0($s2)
            beq $t2,124,escrever_removido
            j escrever_auxiliar

        escrever_removido:
             
         
        addi $t5,$t5,1

            li $v0,13
            la $a0,arquivo_auxiliar
            li $a1,9
            syscall
            move $s7,$v0


            li $v0,15
            move $a0,$s7
            la $a1,produto_removido
            li $a2,80
            syscall

            li $v0,16
            move $a0,$s7
            syscall

            

            j leitura_linha
        

        escrever_auxiliar:

        

            li $v0,13
            la $a0,arquivo_auxiliar
            li $a1,9
            syscall
            move $s7,$v0

            
            li $v0,15
            move $a0,$s7
            move $a1,$s6
            li $a2,80
            syscall

            li $v0,16
            move $a0,$s7
            syscall

            
            j leitura_linha


        fim_verificacao:

            li $v0,16
            move $a0,$s0
            syscall 
            jr $ra

       escrever_restante:

            li $v0,13
            la $a0,arquivo_auxiliar
            li $a1,9
            syscall
            move $s7,$v0

            
            li $v0,15
            move $a0,$s7
            move $a1,$s6
            li $a2,80
            syscall

            li $v0,16
            move $a0,$s7
            syscall

            
            j leitura_linha