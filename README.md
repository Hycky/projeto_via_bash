# 📌 Setup do Projeto Python com `setup_project.sh`

## 📖 Visão Geral

O script `setup_project.sh` é uma ferramenta para automatizar a criação de um projeto Python padronizado, incluindo:

- Estrutura organizada de diretórios e arquivos.
- Configuração automática do `Poetry` e `Taskipy`.
- Inicialização de um repositório Git com commit inicial.
- Configuração do `pre-commit` para controle de qualidade do código.
- Criação de um `Dockerfile` e `.dockerignore` otimizados.
- Geração de `requirements.txt` e `requirements_dev.txt` a partir do Poetry.
- Abertura automática do projeto no VSCode ao final da execução.

## 🔧 Requisitos

Antes de executar o script, certifique-se de ter instalado:

- **Python**: Versão **3.11.9 ~ 3.12**.
- **Poetry**: Versão **2.0 ou superior**.
- **Git**: Para inicialização do repositório.
- **VSCode** (opcional): Para abrir automaticamente o projeto ao final.

## 🚀 Como Usar

### 1️⃣ Como Usar o Script

Considere que você possui uma pasta dedicada para organizar seus projetos, como `workspace`, onde diferentes projetos (exemplo: `projeto1`, `projeto2`) estão armazenados. O arquivo `setup_project.sh` deve ser salvo nessa pasta (`workspace`).

### 2️⃣ Tornar o Script Executável

Dê permissão de execução ao script:

```bash
chmod +x setup_project.sh
```

### 3️⃣ Executar o Script

Execute o script fornecendo o nome do projeto como argumento:

```bash
./setup_project.sh nome_do_projeto
```

Isso criará uma estrutura completa para seu projeto dentro do diretório `nome_do_projeto`.

## 📂 Estrutura Criada

O script criará a seguinte estrutura de diretórios:

```
nome_do_projeto/
│── .github/workflows/
│── src/
│── pipelines/
│── tests/
│   ├── unit/
│   ├── integration/
│── docker/
│── notebooks/
│── data/
│   ├── raw/
│   ├── processed/
│── docs/
│── README.md
│── .gitignore
│── .pre-commit-config.yaml
│── .env
│── setup.py
│── Dockerfile
│── Makefile
│── pyproject.toml
│── mkdocs.yml
```

## 🛠️ Comandos Disponíveis

O script configurará **Makefile** e **Taskipy** para facilitar a execução de comandos:

### 🔹 Comandos do Makefile

```bash
make install     # Instala dependências
make run         # Executa o programa
make test        # Executa testes
make lint        # Formata o código
make precommit   # Executa o pre-commit
```

### 🔹 Comandos com Taskipy

Se preferir usar o `Taskipy`, utilize:

```bash
poetry run task install    # Instala dependências
poetry run task run        # Executa o programa
poetry run task test       # Executa testes
poetry run task lint       # Formata o código
poetry run task precommit  # Executa o pre-commit
```

## 🐳 Docker

O script também cria um `Dockerfile` e um `.dockerignore` otimizados para rodar o projeto em contêineres. Para construir e rodar o contêiner:

```bash
docker build -t nome_do_projeto .
docker run --rm nome_do_projeto
```

## 🔗 Git e Pre-Commit

O repositório será inicializado automaticamente:

```bash
git init
git add .
git commit -m "Initial commit - Projeto nome_do_projeto configurado automaticamente"
git branch -M main
```

O `pre-commit` será instalado automaticamente e ativado no repositório.

## 🖥️ Abrindo no VSCode

Ao final, o script abrirá automaticamente o VSCode na pasta do projeto:

```bash
code .
```

Caso o VSCode não abra automaticamente, pode abri-lo manualmente:

```bash
cd nome_do_projeto && code .
```

## 🎯 Conclusão

Esse script automatiza a configuração inicial de um projeto Python, garantindo padronização e boas práticas desde o início. Se precisar de ajustes, basta modificar o `setup_project.sh` conforme suas necessidades!

---


