import platform
import tkinter as tk
import subprocess
import os
from tkinter import ttk, messagebox

# Caminho para o ícone
icone_path = os.path.join(os.getcwd(), "icone.ico")

# Caminho para arquivos temporários
temporario_path = os.path.join(os.getcwd(), "temporario.txt")

# Caminhos para os scripts de inserção, modificação e remoção
if platform.system() == "Windows":
    insercao_path = os.path.join(os.getcwd(), "Windows", "insercao.bat")
    modificar_path = os.path.join(os.getcwd(), "Windows", "modificar.bat")
    remocao_path = os.path.join(os.getcwd(), "Windows", "remocao.bat")
elif platform.system() == "Linux":
    insercao_path = os.path.join(os.getcwd(), "Linux", "insercao")
    modificar_path = os.path.join(os.getcwd(), "Linux", "modificar")
    remocao_path = os.path.join(os.getcwd(), "Linux", "remocao")

def definir_icone(janela, icone_path):
    if platform.system() == "Windows":
        janela.iconbitmap(icone_path)
    else:
        try:
            icone = tk.PhotoImage(file=icone_path)
            janela.tk.call('wm', 'iconphoto', janela._w, icone)
        except Exception as e:
            print(f"Erro ao definir ícone: {e}")


def centralizar_janela(janela, lar, alt):
    a = janela.winfo_screenwidth()
    b = janela.winfo_screenheight()

    x = (a / 2) - (lar / 2)
    y = (b / 2) - (alt / 2)

    janela.geometry(f'{lar}x{alt}+{int(x)}+{int(y)}')

def abrir_janela_adicionar(tree_produtos, root):
    janela_adicionar = tk.Toplevel(root)

    janela_adicionar.after(100, lambda: definir_icone(janela_adicionar, icone_path))
    janela_adicionar.title("Adicionar Produto")
    janela_adicionar.resizable(False, False)
    centralizar_janela(janela_adicionar, 300, 150)

    ttk.Label(janela_adicionar, text="Nome:", font=('Arial', 10)).pack(pady=(21, 5))
    entry_descricao = ttk.Entry(janela_adicionar, width=30, font=('Arial', 10))
    entry_descricao.pack(pady=5)

    def converter_maiusculas(*args):
        texto = entry_descricao.get().upper()
        entry_descricao.delete(0, tk.END)
        entry_descricao.insert(0, texto)

    entry_descricao.bind('<KeyRelease>', converter_maiusculas)

    def adicionar():
        descricao = entry_descricao.get().strip().upper()

        if not descricao:
            messagebox.showwarning("Atenção", "Por favor, preencha o nome corretamente!")
            return

        if any(caractere.isdigit() for caractere in descricao):
            messagebox.showwarning("Atenção", "A descrição não pode conter números!")
            return abrir_janela_adicionar(tree_produtos, root)
        
        try:

            with open(temporario_path, 'w', encoding='utf-8') as arquivo:
                arquivo.write(descricao.replace(' ', ' '))
            
            if platform.system() == "Windows":
                subprocess.Popen(insercao_path, shell=True)
            elif platform.system() == "Linux":
                subprocess.Popen(insercao_path, shell=True)

            exibir_produtos(tree_produtos)
            
            messagebox.showinfo("Sucesso", "Produto adicionado com sucesso!")
        except Exception as e:
            messagebox.showerror("Erro", f"Erro ao executar insercao.bat: {str(e)}")
        
        exibir_produtos(tree_produtos)
        janela_adicionar.destroy()
        exibir_produtos(tree_produtos)

    btn_adicionar = ttk.Button(janela_adicionar, text="Adicionar", command=adicionar)
    btn_adicionar.pack(pady=10)

def abrir_janela_modificar(tree_produtos, root):
    selected_item = tree_produtos.selection()
    
    if not selected_item:
        messagebox.showwarning("Atenção", "Selecione um produto para modificar.")
        return
    
    janela_modificar = tk.Toplevel(root)

    janela_modificar.after(100, lambda: definir_icone(janela_modificar, icone_path))
    janela_modificar.title("Modificar Produto")
    janela_modificar.geometry("300x150")
    centralizar_janela(janela_modificar, 300, 150)
    janela_modificar.resizable(False, False)

    valores_atual = tree_produtos.item(selected_item[0])['values']

    ttk.Label(janela_modificar, text="Novo Produto:", font=('Arial', 10)).pack(pady=(21, 5))
    entry_novo_produto = ttk.Entry(janela_modificar, width=30, font=('Arial', 10))
    entry_novo_produto.pack(pady=5)
    entry_novo_produto.insert(0, valores_atual[1])

    def converter_maiusculas(*args):
        texto = entry_novo_produto.get().upper()
        entry_novo_produto.delete(0, tk.END)
        entry_novo_produto.insert(0, texto)

    entry_novo_produto.bind('<KeyRelease>', converter_maiusculas)

    def modificar():
        novo_produto = entry_novo_produto.get().strip().upper()
        
        if novo_produto:

            with open(temporario_path, 'w', encoding='utf-8') as arquivo:
                arquivo.write(f"{valores_atual[0]};{novo_produto.replace(' ', ' ')}")
            
            try:
                if platform.system() == "Windows":
                    subprocess.Popen(modificar_path, shell=True)
                elif platform.system() == "Linux":
                    if os.path.exists(modificar_path):
                        subprocess.Popen(modificar_path, shell=True)
                    else:
                        messagebox.showerror("Erro", "Script 'modificar' não encontrado!")

                exibir_produtos(tree_produtos)
                messagebox.showinfo("Sucesso", "Produto modificado com sucesso!")
            except Exception as e:
                messagebox.showerror("Erro", f"Erro ao executar modificar.bat: {str(e)}")
                
            exibir_produtos(tree_produtos)
            janela_modificar.destroy()
            exibir_produtos(tree_produtos)
        else:
            messagebox.showwarning("Atenção", "Por favor, preencha a descrição!")

    btn_modificar = ttk.Button(janela_modificar, text="Modificar", command=modificar)
    btn_modificar.pack(pady=10)

def remover_produto(tree_produtos):
    selected_item = tree_produtos.selection()
    
    if not selected_item:
        messagebox.showwarning("Atenção", "Selecione um produto para remover.")
        return

    resposta = messagebox.askyesno("Confirmação", "Tem certeza que deseja remover este produto?")
    
    if resposta:
        valores_produto = tree_produtos.item(selected_item[0])['values']
        codigo = valores_produto[0]
        produto_selecionado = valores_produto[1]

        try:
            with open(temporario_path, 'w', encoding='utf-8') as arquivo:
                arquivo.write(produto_selecionado.lstrip())
            
            if platform.system() == "Windows":
                subprocess.Popen(remocao_path, shell=True)
            elif platform.system() == "Linux":
                subprocess.Popen(remocao_path, shell=True)

            exibir_produtos(tree_produtos)
            messagebox.showinfo("Sucesso", "Produto removido com sucesso!")
            exibir_produtos(tree_produtos)
        
        except Exception as e:
            messagebox.showerror("Erro", f"Erro ao remover produto: {str(e)}")

def exibir_produtos(tree_produtos):
    #limpa a árvore
    for item in tree_produtos.get_children():
        tree_produtos.delete(item)

    try:
        with open('produtos.txt', 'r', encoding='utf-8') as arquivo:
            linhas = arquivo.readlines()
            
        for linha in linhas:
            if 'COD:' in linha and 'REMOVIDO' not in linha:
                partes = linha.strip().split(';')
                codigo = partes[0].split(':')[1].strip()
                produto = partes[1].split(':')[1].strip('|')
                
                tree_produtos.insert("", "end", values=(codigo, produto))
    
    except FileNotFoundError:
        messagebox.showerror("Erro", "Arquivo 'produtos.txt' não encontrado!")
    except Exception as e:
        messagebox.showerror("Erro", f"Erro ao ler o arquivo: {str(e)}")

def main():
    root = tk.Tk()
    root.title("Sistema de Estoque")
    root.configure(bg='#f0f0f0')
    centralizar_janela(root, 700, 500)

    root.after(100, lambda: definir_icone(root, icone_path))
    root.resizable(False, False)
    
    main_container = ttk.Frame(root, padding="20 20 20 20")
    main_container.pack(fill=tk.BOTH, expand=True)
    
    style = ttk.Style()
    style.configure("Custom.TLabelframe", font=('Arial', 10, 'bold'))
    style.configure("TButton", font=('Arial', 10))

    list_frame = ttk.LabelFrame(main_container, text="Lista de Produtos", style="Custom.TLabelframe")
    list_frame.pack(fill=tk.BOTH, expand=True)
    
    tree_produtos = ttk.Treeview(list_frame, columns=("codigo", "descricao"), show="headings", height=10)
    
    tree_produtos.heading("codigo", text="Código")
    tree_produtos.heading("descricao", text="Descrição")
    
    tree_produtos.column("codigo", width=100, anchor="center")
    tree_produtos.column("descricao", width=400)
    
    scrollbar = ttk.Scrollbar(list_frame, orient="vertical", command=tree_produtos.yview)
    tree_produtos.configure(yscrollcommand=scrollbar.set)
    tree_produtos.pack(side="left", fill="both", expand=True, padx=(0, 10))
    scrollbar.pack(side="right", fill="y")

    btn_frame = ttk.Frame(main_container)
    btn_frame.pack(pady=5)
    
    btn_style = {'width': 15, 'style': 'TButton'}

    btn_credito = ttk.Button(
        btn_frame, 
        text="©", 
        width=3, 
        command=lambda: messagebox.showinfo(
            "Créditos", 
            "Contribuidores\n\n"
            "Gabriel Vinícius Souza da Silva\n"
            "Igor Augusto Silva Santos\n"
            "Kauan Felipe Brilhante Resende\n"
            "Leandro Mendonça Carvalho\n"
            "Matheus Andrade de Souza Calixto\n"
            "Paulo Henrique Oliveira Santos"
        )
    )
    btn_credito.pack(side=tk.RIGHT, padx=5)
    
    style = ttk.Style()
    style.configure("Custom.TButton", foreground="blue")
    
    btn_adicionar = ttk.Button(btn_frame, text="Adicionar", command=lambda: abrir_janela_adicionar(tree_produtos, root), **btn_style)
    btn_adicionar.pack(side=tk.LEFT, padx=5)
    
    btn_modificar = ttk.Button(btn_frame, text="Modificar", command=lambda: abrir_janela_modificar(tree_produtos, root), **btn_style)
    btn_modificar.pack(side=tk.LEFT, padx=5)

    btn_remover = ttk.Button(btn_frame, text="Remover", command=lambda: remover_produto(tree_produtos), **btn_style)
    btn_remover.pack(side=tk.LEFT, padx=5)

    btn_exibir = ttk.Button(btn_frame, text="Exibir", command=lambda: exibir_produtos(tree_produtos), style="Custom.TButton")
    btn_exibir.pack(side=tk.LEFT, padx=5)

    exibir_produtos(tree_produtos)

    root.mainloop()

if __name__ == "__main__":
    main()