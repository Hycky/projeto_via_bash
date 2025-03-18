#!/bin/bash

# Nome do projeto (passado como argumento)
PROJECT_NAME=$1

# Verifica se o nome foi fornecido
if [ -z "$PROJECT_NAME" ]; then
    echo "Uso: ./setup_project.sh <nome_do_projeto>"
    exit 1
fi

# Criando a estrutura de pastas
mkdir -p $PROJECT_NAME/{.github/workflows,src,pipelines,tests/{unit,integration},docker,notebooks,data/{raw,processed},docs}

# Criando arquivos básicos
touch $PROJECT_NAME/{README.md,.gitignore,setup.py,.pre-commit-config.yaml,.env}
touch $PROJECT_NAME/src/{main.py,__init__.py}
touch $PROJECT_NAME/tests/{test_main.py,__init__.py}
touch $PROJECT_NAME/tests/integration/__init__.py
touch $PROJECT_NAME/tests/unit/__init__.py
touch $PROJECT_NAME/docker/Dockerfile
touch $PROJECT_NAME/.github/workflows/{ci-cd.yml,deploy.yml,test.yml}

# Criando um README básico
echo "# $PROJECT_NAME" > $PROJECT_NAME/README.md
echo "Projeto criado automaticamente com um script Bash." >> $PROJECT_NAME/README.md

# Criando um .gitignore básico
cat <<EOL > $PROJECT_NAME/.gitignore
# Arquivos e diretórios do Python
__pycache__/
*.pyc
*.pyo
*.pyd

# Ambiente virtual (Python)
.venv/
.env
*.env

# Diretórios de configuração e arquivos sensíveis
secrets/
*.log
*.tmp
*.swp

# Arquivos específicos de sistemas operacionais
.DS_Store  # macOS

# Diretórios do Git 
.git/

# Checkpoints de Jupyter Notebook
.ipynb_checkpoints/

# Diretórios de dados (ajuste conforme necessidade)
data/raw/
data/processed/

# Arquivos gerados por editores de código
.vscode/
.idea/
*.code-workspace
EOL

# Criando um arquivo de pre-commit configurado (exemplo)
cat <<EOL > $PROJECT_NAME/.pre-commit-config.yaml
repos:
  - repo: local
    hooks:
      - id: pytest
        name: Run tests with pytest
        entry: poetry run task test
        language: system
        pass_filenames: false

      - id: black
        name: Format code with Black
        entry: poetry run black
        language: system
        types: [python]
        args: ['--line-length=88']
        pass_filenames: true

      - id: isort
        name: Sort imports with isort
        entry: poetry run isort
        language: system
        types: [python]
        args: ['--profile', 'black'] 
        pass_filenames: true

      - id: flake8
        name: Lint code with Flake8
        entry: poetry run flake8
        language: system
        types: [python]
        args: ['--max-line-length=88']
        pass_filenames: true

      - id: mypy
        name: Type check with MyPy
        entry: poetry run mypy
        language: system
        types: [python]
        pass_filenames: true

      # - id: safety
      #   name: Check dependencies for security issues
      #   entry: poetry run safety check --full-report --file=requirements.txt --file=requirements_dev.txt
      #   language: system
      #   pass_filenames: false

      - id: check-added-large-files
        name: Prevent large files in repo
        entry: >
          poetry run python -c "import sys, os;
          [print(f'File too large: {f}') or sys.exit(1) for f in sys.argv[1:] if os.path.getsize(f) > 500 * 1024]"
        language: system
        pass_filenames: true

      - id: bandit
        name: Security analysis with Bandit
        entry: poetry run bandit -r src/
        language: system
        pass_filenames: false

      - id: detect-secrets
        name: Detect secrets in code
        entry: poetry run detect-secrets-hook --baseline .secrets.baseline || poetry run detect-secrets scan > .secrets.baseline
        language: system
        pass_filenames: false

      - id: debug-statements
        name: Remove debug statements (print, pdb)
        entry: poetry run flake8 --select=T20
        language: system
        pass_filenames: true
EOL

# Criando o ambiente Poetry
cd $PROJECT_NAME
poetry init --no-interaction
poetry add dotenv
poetry add --group dev pytest black pre-commit mkdocs taskipy pre-commit-hooks isort flake8 mypy safety bandit detect-secrets pylint taskipy poetry-plugin-export
poetry config warnings.export false

# Exportando as dependências para os arquivos requirements.txt e requirements_dev.txt
poetry export --without-hashes --without=dev -o requirements.txt
poetry export --without-hashes --with=dev -o requirements_dev.txt

# Adicionando Taskipy ao pyproject.toml
cat <<EOL >> pyproject.toml

[tool.taskipy.tasks]
install = "poetry install"
run = "poetry run python src/main.py"
test = "poetry run pytest tests/"
lint = "poetry run black src/ tests/"
precommit = "poetry run pre-commit run --all-files"
EOL

# Criando o arquivo de configuração do MkDocs
cat <<EOL > mkdocs.yml
site_name: $PROJECT_NAME
nav:
  - Home: index.md
theme: readthedocs
EOL

# Criando a estrutura de documentação
mkdir -p docs
echo "# Documentação do $PROJECT_NAME" > docs/index.md

# Criando um arquivo .editorconfig para padronizar formatação do código
cat <<EOL > .editorconfig
root = true

[*]
charset = utf-8
end_of_line = lf
indent_style = space
indent_size = 4
trim_trailing_whitespace = true
insert_final_newline = true
EOL

# Criando um Makefile para facilitar o uso do projeto
cat <<EOL > Makefile
install:
	poetry install

run:
	poetry run python src/main.py

test:
	poetry run pytest tests/

lint:
	poetry run black src/ tests/

precommit:
	poetry run pre-commit run --all-files

# make install    # Instala dependências
# make run        # Roda o app
# make test       # Executa testes
# make lint       # Formata o código
# make precommit  # Executa pre-commit 
EOL


# Criando um Dockerfile básico
cat <<EOL > docker/Dockerfile
# Imagem base
FROM python:3.10

# Define o diretório de trabalho no container
WORKDIR /app

# Copia apenas os arquivos necessários primeiro (melhora cache do Docker)
COPY requirements.txt requirements_dev.txt ./

# Instala apenas as dependências de produção
RUN pip install --no-cache-dir -r requirements.txt

# Copia todo o código do projeto para o container
COPY . .

# Comando para rodar o programa
CMD ["python", "src/main.py"]
EOL

# Criando um .dockerignore para evitar arquivos desnecessários no Docker
cat <<EOL > .dockerignore
# Ignorar diretórios e arquivos do Poetry
poetry.lock
pyproject.toml

# Ignorar diretórios de cache e compilação do Python
__pycache__/
*.pyc
*.pyo
*.pyd

# Ignorar o ambiente virtual (caso tenha um .venv)
.venv/

# Ignorar credenciais e arquivos sensíveis
.env
*.env
secrets/

# Ignorar dependências já exportadas
requirements.txt
requirements_dev.txt

# Ignorar logs e arquivos temporários
*.log
*.tmp
*.swp
.DS_Store

# Ignorar arquivos do Git
.git/
.gitignore

# Ignorar arquivos do Docker (exceto o Dockerfile)
.dockerignore

# Ignorar cache do Jupyter Notebook (se estiver usando)
.ipynb_checkpoints/

# Ignorar dados brutos e processados (se não forem necessários no container)
data/raw/
data/processed/
EOL

# Inicializa um repositório Git e faz o primeiro commit
git init
git add .
git commit -m "Initial commit - Projeto $PROJECT_NAME configurado automaticamente"
git branch -M main

# Instalar e ativar pre-commit
poetry run pre-commit install

# Abrir o projeto no VSCode automaticamente
code .

# Mensagem final
echo "Projeto $PROJECT_NAME criado com sucesso!"
