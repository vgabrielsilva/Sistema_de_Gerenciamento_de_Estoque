.data
arquivo_produtos: .asciiz "produtos.txt"
arquivo_temporario: .asciiz "temporario.txt"
arquivo_auxiliar: .asciiz "auxiliar.txt"
arquivo_status: .asciiz "status.txt" 
codigo: .space 80
nome: .space 80
linha: .space 80
linha_modificada: .space 80
string_codigo: .asciiz  "COD: "
string_produto: .asciiz "; PRODUTO: "
pipe: .byte '|'
espaco_branco: .byte ' '
quebra_linha: .byte '\n'
nda: .ascii ""

.text

.globl main

main:
     
    li $s7,0    # Flag para informar se encontrou o produto
    
    jal separar_codigo_nome # Separa o codigo e o nome
    jal calcular_espacos_brancos    # Conta quantos espacos em branco precisa para completar os 80 bytes da linha
    jal preparar_linha_modificada   # prepara a linha para substituir
    jal procurar_codigo_e_modificar # procura o codigo no arquivo de produtos e adicionar no auxiliar
    jal limpar_arquivo_produtos      # limpa o arquivo dos produtos para ser atualizado
    jal escrever_arquivo_produtos # adicionar a versao atualizada no arquivo de produtos
    jal limpar_arquivo_auxiliar # Limpa o arquivo auxiliar para a proxima execucao
    
 
    li $v0,10
    syscall




#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

separar_codigo_nome:    # Separa o codigo, coloca codigo na variavel "codigo" e nome na variavel "nome"

    li $v0,13   # Abre arquivo temporario
    la $a0,arquivo_temporario
    li $a1,0
    syscall
    move $t0,$v0


    li $v0,14   # Leitura do arquivo temporario
    move $a0,$t0
    la $a1,linha
    li $a2,80
    syscall
    

    li $v0,16
    move $a0,$t0
    syscall
    
    la $t1,codigo

    li $s0,0    # Contador codigo
    li $s1,0    # Contador nome

separar_codigo:    # Adicionar codigo na variavel "codigo"
   
    lb $t0,0($a1)

    beq $t0,59,separar_nome  # Final do codigo

    sb $t0,0($t1)

    addi $a1,$a1,1
    addi $t1,$t1,1
    addi $s0,$s0,1

    j separar_codigo
    
    
separar_nome:   # Adicionar nome na variavel "nome"

    sb $zero,0($t1)    # Coloca o valor de $zero no final da variavel "codigo"

    addi $a1,$a1,1
    
    la $t1,nome

    separar_nome_loop:

        lb $t0,0($a1)
        
        beq $t0,$zero,fim_separacao

        sb $t0,0($t1)

        addi $a1,$a1,1
        addi $t1,$t1,1
        addi $s1,$s1,1
        
        j separar_nome_loop
    
fim_separacao:

    sb $zero,0($t1)    # Coloca o valor de $zero no final da variavel "nome"

    jr $ra

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

calcular_espacos_brancos:   #COD: ; PRODUTO: |
    
    li $t0,80
    li $s2,0

    addi $s2,$s2,5  # "COD: "
    add $s2,$s2,$s0    # Contador digitos codigo
    addi $s2,$s2,11 # "; PRODUTO: "
    add $s2,$s2,$s1    # Contador letras nome
    addi $s2,$s2,1  # |
    addi $s2,$s2,1  # \n
    sub $s2,$t0,$s2    # $s2 <- quantidade de espacos em branco necessarios

    jr $ra

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

preparar_linha_modificada:

    la $t0,linha_modificada

    la $t1,string_codigo

    li $t3, 5   # Contador string_codigo
    
loop_escrever_string_cod:

    lb $t2,0($t1)
    sb $t2,0($t0)

    addi $t0,$t0,1
    addi $t1,$t1,1
    subi $t3,$t3,1

    beq $t3, $zero, escrever_codigo
    
    j loop_escrever_string_cod

escrever_codigo:

    la $t1,codigo
    
    move $t3,$s0
    
    loop_escrever_codigo:
        
        lb $t2,0($t1)
        sb $t2,0($t0)

        addi $t0,$t0,1
        addi $t1,$t1,1
        subi $t3,$t3,1

        beq $t3, $zero, escrever_string_produto

        j loop_escrever_codigo
    
escrever_string_produto:

    la $t1,string_produto
    
    li $t3,11

    loop_escrever_string_produto:

        lb $t2,0($t1)
        sb $t2,0($t0)

        addi $t0,$t0,1
        addi $t1,$t1,1
        subi $t3,$t3,1

        beq $t3, $zero, escrever_nome

        j loop_escrever_string_produto

escrever_nome:

    la $t1,nome

    move $t3,$s1

    loop_escrever_nome:

        lb $t2,0($t1)
        sb $t2,0($t0)

        addi $t0,$t0,1
        addi $t1,$t1,1
        subi $t3,$t3,1

        beq $t3,$zero,escrever_pipe_espaco_quebra_linha

        j loop_escrever_nome

escrever_pipe_espaco_quebra_linha:

    la $t1,pipe
    
    lb $t2,0($t1)
    sb $t2,0($t0)

    addi $t0,$t0,1

    la $t1,espaco_branco   # espaco branco

    move $t3,$s2

    lb $t2,0($t1)

    loop_espacos:

        sb $t2,0($t0)

        addi $t0,$t0,1
        subi $t3,$t3,1

        beq $t3,$zero,escrever_quebra_linha
        
        j loop_espacos

    escrever_quebra_linha:

        la $t1,quebra_linha

        lb $t2,0($t1) 
        sb $t2,0($t0)
    
    jr $ra

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

procurar_codigo_e_modificar:

    li $v0,13
    la $a0,arquivo_produtos
    li $a1,0
    syscall
    
    move $t0,$v0                  #Move o descritodo arquivo para o registrador $t0

leitura_linha:   

    li $v0,14
    move $a0,$t0
    la $a1,linha
    li $a2,80
    syscall

    beq $v0,$zero,encerrar_procura

    la $s1,linha
    la $s2,linha_modificada

    addi $s1,$s1,5  # Sincronizar codigos
    addi $s2,$s2,5  # Sincronizar codigos
    
    loop:

        lb $t1,0($s1)
        lb $t2,0($s2)
        
        bne $t1,$t2,escrever_auxiliar

        beq $t1,59,escrever_linha_modificada

        addi $s1,$s1,1 
        addi $s2,$s2,1 

        j loop                          

    escrever_auxiliar:

        la $s1, linha

        li $v0,13
        la $a0,arquivo_auxiliar
        li $a1,9
        syscall
        move $t1,$v0

        li $v0,15
        move $a0,$t1
        move $a1,$s1
        li $a2,80
        syscall

        li $v0,16
        move $a0,$t1
        syscall
        
        j leitura_linha
        
    escrever_linha_modificada:
        addi $s7,$s7,1
        la $s1,linha_modificada

        li $v0,13
        la $a0,arquivo_auxiliar
        li $a1,9
        syscall
        move $t1,$v0

        li $v0,15
        move $a0,$t1
        move $a1,$s1
        li $a2,80
        syscall

        li $v0,16
        move $a0,$t1
        syscall
        
        j leitura_linha

encerrar_procura:

    li $v0, 16
    move $a0, $t0
    syscall

    jr $ra

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

limpar_arquivo_produtos:

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

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   

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

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

limpar_arquivo_auxiliar:
    
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
    
    #%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   