# ansible

### **Ansible e Infraestrutura sobre código:**

Infraestrutura como código é a base da cultura DevOps, encurtando assim o ciclo de feedback entre os times de desenvolvimento e os de infraestrutura. É a partir da máquina de controle com o Ansible instalado que gerenciamos outras máquinas. As máquinas gerenciadas pelo Ansible só precisam do Python e de um servidor SSH instalados.

Segue o link da documentação do Ansible (v2.6) com a lista de todos os módulos de banco de dados: **Database module**

[https://docs.ansible.com/ansible/2.6/modules/list\_of\_database\_modules.html](broken-reference)

**MySQL DB Module**

[https://docs.ansible.com/ansible/2.6/modules/mysql\_db\_module.html](broken-reference)

***

#### **Podemos afirmar que:**

* O Ansible é uma ferramenta que auxilia no processo de infraestrutura como código.
* `Arquivo de inventário:` Lista todas as máquinas que serão utilizadas na configuração.
* `Playbook:` Arquivo com as **"receitas de bolo"** do que queremos fazer.

***

#### **Casos de uso**

1.  Ricardo está começando a estudar Ansible. Ele já subiu a sua máquina com o Vagrant, criou o arquivo de inventário hosts com o grupo groupA, com o IP 10.0.0.1, e resolveu fazer um teste, imprimindo o famoso Hello, World, através do seguinte comando:

    ```bash
    ansible groupA -u vagrant -i hosts -m shell -a 'echo Hello, World'
    ```

    O comando acima não será executado, pois o Ansible não conseguirá fazer a autenticação para executar um comando na máquina. Para fazer a autenticação, uma chave precisa ser passada, o próprio Vagrant cria:

    ```bash
    ansible wordpress -u vagrant --private-key .vagrant/machines/wordpress virtualbox/private_key -i hosts -m shell -a 'echo Hello, World'
    ```
2.  Ana quer criar uma Playbook que gere um arquivo txt com o seu nome dentro do arquivo _/vagrant/nome.txt_ e a task deve funcionar para todos os hosts configurados.

    ```bash
    ---
    - hosts: all
      tasks:
        - shell: "echo Ana > /vagrant/nome.txt"
    ```

    * A primeira linha do Playbook são três hífens;
    * O primeiro elemento são os hosts que o Ansible vai trabalhar
    * Após isso são escritos os comandos a serem executados, que são uma lista de tasks. Para escrever o nome em um arquivo, utilizamos o módulo shell, executando o comando echo em seguida.
3.  Tendo como referência o Playbook abaixo, podemos dizer:\`

    ```bash
    ---
    - hosts: all
        - name: 'Instala o PHP5'
            name: php5
            state: latest
          become: yes
    ```

    O arquivo possui 2 erros: faltou colocar a dependência na lista de tasks e declarar o módulo a ser utilizado, `apt`. O arquivo correto seria:

    ```bash
    ---
    - hosts: all
      tasks:
        - name: 'Instala o PHP5'
          apt:
            name: php5
            state: latest
          become: yes
    ```
4.  Realiza a criação de uma base de dados **MySQL** utilizando a sintaxe `state: present`, chamada _bancoteste_.

    ```bash
    - name: 'Cria o banco do MySQL'
      mysql_db:
        name: bancoteste
        login_user: root
        state: present
    ```
5. O usuário do MySQL também possui alguns privilégios, que são configurados no parâmetro priv.

*   Nesta alternativa, o usuário teria permissão de fazer todas as operações comuns em todas as tabelas de todas as bases de dados.

    ```bash
    priv: '*.*:ALL'
    ```

O formato da string de privilégio é: base\_de\_dados.tabela:privilegio. Como a base de dados é alura\_ansible, as tabelas são todas (logo, utiliza-se _) e para ter todos os privilégios de banco de dados usa-se ALL, logo: priv: 'alura\_ansible._:ALL'

priv: 'alura\_ansible.\*:ALL' Alternativa correta! O formato da string de privilégio é: base\_de\_dados.tabela:privilegio. A base de dados é alura\_ansible, as tabelas são todas (logo, utiliza-se \*) e para o usuário poder fazer todas as operações comuns no banco de dados, usa-se ALL.

priv: 'ALL.\*:alura\_ansible' Alternativa errada! O formato da string de privilégio é: base\_de\_dados.tabela:privilegio. A base de dados é alura\_ansible, as tabelas são todas (logo, utiliza-se _) e para ter todos os privilégios de banco de dados usa-se ALL, logo: priv: 'alura\_ansible._:ALL'

***

#### **Palavras-chaves do Ansible e os seus usos**

`become:` É um booleano e indica se a task será executada com ou sem privilégios administrativos.

`hosts:` Indica para qual grupo ou host do arquivo de inventário o Ansible vai aplicar as tarefas.

`tasks:` Lista principal de comandos a serem executados nos hosts selecionados.

`with_items:` O parâmetro **with\_items** fica no nível da task, ou seja, não faz parte da task. No with\_items, passamos o nome **(name)** dos pacotes das tasks que desejamos que ele contene.

`item:` Palavra reservada do Ansible e com ela conseguimos fazer uma referência a todos os elementos inclusos em uma lista de dependências.

***

Tendo como referência a task abaixo de criação de um usuário do MySQL, podemos dizer:

```bash
- name: 'Cria o usuário do MySQL'
  mysql_user:
    login: root
    alias: wordpress_user
    pass: 12345
    priv: 'wordpress_db.*:ALL'
    state: present
```

Ela possui 3 erros. Alternativa correta! A task possui 3 erros: o usuário que será utilizado para fazer a autenticação não é passado no parâmetro login, e sim no parâmetro login\_user; o usuário a ser criado não é passado no parâmetro alias, e sim no parâmetro name; e por fim, a senha do usuário não é passada no parâmetro pass, e sim no parâmetro password. O três parâmetros incorretos sequer existem.

Temos o seguinte código:

```bash
- name: 'x'
  get_url: 
    url: 'https://endereco.com/x.zip'
    dest: '/tmp/y.zip'
```

O Ansible baixará o arquivo da URL definida na propriedade url, gravando-o na pasta indicada na propriedade dest, com o nome que definirmos. Alternativa correta! Na propriedade url, é definida a URL que o Ansible utilizará para baixar o arquivo, que será gravado na pasta indicada na propriedade dest, com o nome que definirmos.

Temos o seguinte trecho de código do Playbook:

```bash
- copy:
    src: '/var/www/wordpress/wp-config-sample.php'
    dist: '/var/www/wordpress/wp-config.php'
    remote_src: yes
  become: yes
```

Quantos erros há no trecho de código acima? 1 erro Alternativa correta! Há apenas um erro: a propriedade não é dist, é dest.

Tendo como referência o handler abaixo para reiniciar o Apache2, podemos dizer:

```bash
handlers:
  - name: restart apache
      name: apache2
      state: restarted
    become: yes
```

Ele possui 1 erro. Alternativa correta! Ele possui um erro: faltou a declaração do serviço, através de service. O correto seria: handlers:

* name: restart apache service: name: apache2 state: restarted become: yes

Segue uma parte do provisioning.yml com a configuração do handler que reinicia o Apache2:

```bash
- hosts: wordpress
  handlers:
    - name: restart apache
      service:
        name: apache2
        state: restarted
      become: yes
...
```

Como garantimos que esse handler realmente será chamado após execução de uma tarefa? Handlers serão chamados automaticamente após a execução das tasks. Alternativa errada! Sempre devemos notificar o handler no final da task, usando: notify:

* restart apache

No final da task, usando: notify:

* restart apache Alternativa correta! Através do notify podemos "avisar" o handler.

Criando uma task específica: tasks:

* name: restart apache Alternativa errada! Basta notificar o handler no final da task, usando: notify:
* restart apache

O Ansible nos permite executar comandos contra uma lista arbitrária de hosts remotos através do arquivo de inventário, que podem estar divididos em diferentes grupos. Dito isso, dado o arquivo de inventário abaixo, qual seria o retorno do comando ansible groupA -i hosts -m ping?

```bash
[groupA]
10.0.0.1
10.0.0.2

[groupB]
10.0.0.3
10.0.0.4

[groupC]
10.0.0.5
10.0.0.6
```

10.0.0.1 | SUCCESS => { "changed": false, "failed": false, "ping": "pong" } 10.0.0.2 | SUCCESS => { "changed": false, "failed": false, "ping": "pong" } Alternativa correta! O comando informado recebeu os seguintes parâmetros : -i \<inventário> -m \<módulo>. O grupo informado foi o groupA, que de acordo com o arquivo de inventário fornecido é formado pelos hosts 10.0.0.1 e 10.0.0.2. Dessa forma, quando rodamos o comando ansible informando o grupo groupA, o módulo solicitado será executado apenas contra os hosts desse grupo. Para maiores detalhes, você pode ler a documentação [aqui](https://docs.ansible.com/ansible/latest/inventory\_guide/intro\_patterns.html).

Sobre declaração de variáveis, temos as seguintes afirmativas:

A) Utilizamos variáveis declaradas através de '\{{ nome\_da\_variavel \}}'.

B) Não há limite no número de variáveis declaradas.

C) Uma variável só pode ser definida na linha de comando.

Podemos dizer que: Apenas a afirmativa B é falsa. Alternativa errada! Realmente não há limite no número de variáveis declaradas.1

Apenas a afirmativa A é falsa. Alternativa errada! As variáveis são utilizadas através de '\{{ nome\_da\_variavel \}}' ou "\{{ nome\_da\_variavel \}}", com aspas duplas.

Apenas a afirmativa C é falsa. Alternativa correta! As variáveis também podem ser definidas em arquivos.

Aprendemos sobre templates nesta aula. Das afirmações abaixo, qual a correta? Os templates são manipulados por um módulo de mesmo nome, template. Você pegou um projeto Ansible do colega de trabalho e começou a analisar a estrutura. No projeto, dentro da pasta group\_vars tem o arquivo server.yml, com a declaração da variável:

```bash
server_ip: '172.17.177.40'
```

Essa variável é válida para o grupo server. Alternativa correta! Repare que o arquivo se chama server.yml, ou seja, é válida para o grupo server. Para ser válido em todos os grupos, o arquivo precisa se chamar all.yml.

Existem algumas regras que devemos considerar na hora de declarar uma varíavel (como em qualquer outra ferramenta ou linguagem de programação). Por exemplo, uma variável não deve ter um ponto, espaço ou hífen no nome. Todas as declarações abaixo são inválidas:

```bash
foo-var: 'nao_pode_ter_hifen'
foo var: 'nem_ter_espaco'
foo.var: 'tambem_nao_pode_ter_ponto'
12foovar: 'nao_pode_ter_numero_no_inicio'
```

Todos os detalhes sobre as declarações e muito mais se encontra da documentação do Ansible: [Documentação sobre Variáveis.](http://docs.ansible.com/ansible/latest/playbooks\_variables.html#what-makes-a-valid-variable-name)

No curso você já aprendeu como usar templates e qual é a sintaxe para declarar uma variável. Para trabalhar com os templates, o Ansible usa um outro framework que se chama Jinja.

Ele faz parte dos template engine's (ou template processor). Um template engine combina um template (HTML, XML, ou qualquer outro arquivo, configurações etc) com um modelo de dados para gerar um novo documento: [Template Engine Jinja.](http://jinja.pocoo.org/)

Isso é muito utilizado no desenvolvimento web para gerar páginas HTML dinamicamente. Por isso o Jinja é o template engine padrão do Flask, um micro framework web também escrito em Python: \[Python Flask Web Framework]\(Python Flask Web Framework)

Se tiver interessado em aprender Flask, na Alura também temos cursos dedicados. Vale conferir: [Cursos Flask na Alura.](https://cursos.alura.com.br/search?query=flask)

Vimos na aula que os roles representam uma forma de encapsular tarefas, variáveis e handlers para facilitar o reuso.

Sabendo disso, qual é a estrutura mínima para definir uma tarefa de instalação no role server? Usando o main.yml, dentro do diretório roles/server/tasks/ e dentro deste arquivo fica a task de instalação. Alternativa correta! Dentro do diretório roles/server/tasks/_, criamos o arquivo main.yml_ e dentro dele fica a task\* de instalação.

Já avançamos bastante no nosso projeto e declaramos as nossas roles. Sobre as roles, marque todas as declarações verdadeiras:

As dependências são declaradas no arquivo meta/main.yml. Correto! No arquivo meta/main.yml nós declaramos as dependências.

As tasks são declaradas no arquivo tasks/main.yml. Correto! No arquivo tasks/main.yml nós declaramos as tasks.

Os handlers são declarados no arquivo handlers.yml. Errado! O nome do arquivo é sempre main.yml, nesse caso dentro da pasta handlers: handlers/main.yml.

As variáveis são declaradas no arquivo defaults/main.yml. Correto! No arquivo defaults/main.yml nós declaramos as variáveis.

#### Executando comandos através de modulos em um IP especifico

**Linux** ansible ip -m(modulo) -u(usuario) -k(Key) ansible ip -m(modulo) -u(usuario) --ask-pass **Windows** ansible nomeGrupo -m apt win\_comando --ask-pass

***

#### Executando comandos em um grupo de hosts

**Linux** ansible nomeGrupo -m ping -u ansible --ask-pass **Windows** ansible nomeGrupo -m apt win\_ping --ask-pass

***

#### Instalando aplicações através do ansible

**Linux** ansible nomeGrupo -a "sudo apt-get install apache2" -u ansible --ask-pass --become **Windows** ansible nomeGrupo -m apt win\_chocolatey --ask-pass

***

#### Configuração arquivos de inventario

**LINUX** ansible.cfg

```conf
[defaults]
interpreter_python = auto_legacy_silent
sudo_user = root
```

***

hosts

```conf
[servidores_um]
nome_variavel ansible_ssh_host=ip ansible_ssh_user=user ansible_ssh_pass=key

[servidor_exemplo1]
deb ansible_ssh_host=10.20.20.110 ansible_ssh_user=ansible ansible_ssh_pass=Senha123

[servidor_exemplo2]
deb ansible_ssh_host=10.20.20.120 ansible_ssh_user=ansible ansible_ssh_pass=Senha123

[nomeGrupo:nomeVars]
servidor_exemplo1
servidor_exemplo2
```

***

**WINDOWS**

```conf
[nomeGrupo:nomeVars]
ansible_port=port
ansible_connection=winrm
ansible_winrm_server_cert_valiation=ignore
```

#### ansible-vault

**Para encryptar a senha criada dentro do arquivo de hosts**

```conf
ansible-vault encrypt hosts
```

**Executando o camando utilizando o arquivo encrypt**

```conf
ansible nomeGrupo -m ping --ask-vault-pass
```

**Para editar o arquivo encryptado com o vault**

```conf
ansible-vault edite arquivo
```

**Acessando através de uma porta diferente da padrão**

```conf
[servidor_exemplo1]
nome_variavel ansible_ssh_host=ip ansible_ssh_user=user ansible_ssh_pass=key ansible_ssh_port=port
```

**Para desincryptar a senha criada dentro do arquivo**

```conf
ansible-vault encrypt arquivo
```

#### Requisitos automatizar processos no Windows com ansible

* Powershell 3++
* Netframwork 4.0
* winrm

#### Ansible Playbook

```conf
ansible-playbook caminho/nome_da_playbook.yml
```

#### Documentação Ansible

```conf
ansible-doc --help
```

### Comando restart no Zabbix

```conf
curl -s -k -X POST -H "Authorization: Bearer jHPd236UT4RlqALnrzSQk9DWujBAe7" -H "Content-Type: application/json" http://awx.endpoint.com/api/v2/job_templates/id_templante/launch/
```

Versões usadas Nesse curso usamos o Ansible na versão 2.x com Python na versão 2.x. Aconselhamos instalar o ambiente no seu computador o mais perto possível disso para evitar erros de incompatibilidade.

Instalando Ansible Ubuntu

Para instalar no Ubuntu, utilize o comando abaixo:

```bash
sudo apt-get install ansible
```

MacOS Para instalar no MacOs, instale o brew através do comando abaixo:

```bash
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

E logo após, execute o comando abaixo para instalar o Python e o Ansible:

```bash
brew install python@2 ansible@2.0
```

Windows Conforme dito no vídeo, o Ansible não tem suporte para Windows. Após tudo concluido, execute os comandos abaixo para checar se deu tudo certo:

```bash
python -V
```

E:

```bash
ansible --version
```

Devo mostrar algo parecido com a saída abaixo:

```bash
ansible --version
ansible 2.6.5
  config file = None
  configured module search path = [u'/Users/nico/.ansible/plugins/modules', u'/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/local/Cellar/ansible/2.6.5/libexec/lib/python2.7/site-packages/ansible
  executable location = /usr/local/bin/ansible
  python version = 2.7.15 (default, Oct  2 2018, 11:47:18) [GCC 4.2.1 Compatible Apple LLVM 10.0.0 (clang-1000.11.45.2)]
```

Instalando Vagrant e VirtualBox Acesse o site do Vagrant e do VirtualBox, faça o download para seu sistema operacional e instale seguindo as suas instruções.

Duvidas sobre Vagrant?? Temos um curso dedicado ao Vagrant (com Puppet que é uma alternativa ao Ansible) na Alura. Segue o link:

Vagrant e Puppet: Criação e provisionamento de maquinas virtuais

1. Crie uma pasta, conforme no curso, com o nome wordpress\_com\_ansible.
2. Baixe aqui o arquivo Vagrantfile usado no curso e coloque na pasta wordpress\_com\_ansible.
3. Utilizando o terminal, dentro da pasta **wordpress\_com\_ansible** execute o comando abaixo:

```bash
vagrant up
```

4. Crie o arquivo de inventário hosts e comece colocando o IP da máquina virtual, defina um grupo também (no curso, demos o nome de wordpress):

```bash
[wordpress]
172.17.177.40
```

5. Teste se sua máquina virtual está funcionando, executando o código abaixo:

```bash
vagrant ssh
```

Utilize o atalho CTRL + C para deslogar da máquina virtual. 6) Rode o comando Ansible abaixo para ter um simples hello world:

```bash
ansible wordpress -u vagrant --private-key .vagrant/machines/wordpress/virtualbox/private_key -i hosts -m shell -a 'echo Hello, World'
```

7. Para ter uma saída mais verbosa, utilize o comando abaixo, onde foi incluído o parâmetro -vvvv

```bash
ansible -vvvv wordpress -u vagrant --private-key .vagrant/machines/wordpress/virtualbox/private_key -i hosts -m shell -a 'echo Hello, World'
```

### Erro UNREACHABLE?

Você está recebendo um erro UNREACHABLE parecido com a saída abaixo?

```bash
172.17.177.40 | UNREACHABLE! => {
    "changed": false,
    "msg": "Failed to connect to the host via ssh: vagrant@172.17.177.40: Permission denied (publickey,password).\r\n",
    "unreachable": true
}
```

Se sim, há algum problema com a sua configuração ssh do Vagrant. Para resolver esse problema vamos gerar um novo par de chaves ssh e copiar para a VM do Vagrant. Seguem os passos:

1. Na pasta do seu projeto (wordpress\_com\_ansible), crie uma nova pasta ssh-keys para guardar as chaves ssh e entre na pasta:

```bash
mkdir ssh-keys
cd ssh-keys
```

Depois gere as chaves com o comando:

```bash
ssh-keygen -t rsa
```

O comando pergunta onde você gostaria de guardar as chaves e qual será o nome da chave. Defina a pasta ssh-keys como destino e como base o nome vagrant\_id\_rsa, por exemplo:

```bash
Enter file in which to save the key (/Users/<usuario>/.ssh/id_rsa):
/Users/<seu-usuario>/wordpress_com_ansible/ssh-keys/vagrant_id_rsa
```

Depois digite uma senha vagrant (ou deixe vazio) e repita a senha.

O comando gera dois arquivos, a chave publica (vagrant\_id\_rsa.pub) e privada (vagrant\_id\_rsa)

2. Garanta que o Vagrant subiu a VM (vagrant up).
3. Vamos copiar a chave pública gerada para a VM. Para tal digite na pasta ssh-keys:

```bash
ssh-copy-id -i vagrant_id_rsa.pub vagrant@172.17.177.40
```

A senha deve ser vagrant. O comando deve mostrar uma saída parecida com a abaixo:

```bash
vagrant@172.17.177.40's password:

Number of key(s) added:        1

Now try logging into the machine, with:   "ssh 'vagrant@172.17.177.40'"
and check to make sure that only the key(s) you wanted were added.
```

Obs: Talvez esteja necessário remover o arquivo \~/.ssh/known\_hosts.

5. Volte para a raiz do seu projeto (na pasta wordpress\_com\_ansible) e tente executar o comando do Ansible:

```bash
ansible wordpress -i hosts -u vagrant --private-key ssh-keys/vagrant_id_rsa -m ping -m shell -a 'echo Hello, World'
```

Digite a senha que você usou para gerar a chave:

```bash
Enter passphrase for key '/Users/.../ssh-keys/vagrant_id_rsa': 
```

Agora deve mostrar:

```bash
172.17.177.40 | SUCCESS | rc=0 >>
Hello, World
```

1. Garante que a maquina virtual está rodando (vagrant up). Você pode ver o status (poweroff, running) da VM vagrant status.
2. Dentro do pasta do projeto crie o arquivo de Playbook, chamado provisioning.yml e escreva o conteúdo abaixo, repare nos 3 hífens iniciais:

```bash
---
- hosts: all
  tasks:
    - shell: 'echo hello > /vagrant/world.txt'
```

3. Abra o diretório do curso no terminal e execute o comando abaixo para utilizar o Playbook criado:

```bash
ansible-playbook provisioning.yml -u vagrant -i hosts --private-key .vagrant/machines/wordpress/virtualbox/private_key
```

4. Teste se o script funcionou logando na máquina virtual:

```bash
vagrant ssh
```

E execute o comando:

```bash
ls /vagrant/
```

Verifique se o arquivo world.txt foi criado. Execute o atalho CTRL + C para deslogar. 5) Modifique o arquivo provisioning.yml, deixando-o conforme abaixo:

```bash
---
- hosts: all
  tasks:
    - name: 'Instala o PHP5'
      apt:
        name: php5
        state: latest
      become: yes
```

Obs: Na versão mais recente do Ubuntu o PHP5 não está mais disponível. Neste caso você pode instalar o PHP 7 (php) junto com o php-fpm.

Execute o rode o Playbook:

```bash
ansible-playbook provisioning.yml -u vagrant -i hosts --private-key .vagrant/machines/wordpress/virtualbox/private_key
```

6. Adicione no seu provisioning.yml a instalação do apache2 e do modphp. Veja o resultado abaixo:

```bash
---
- hosts: all
  tasks:
    - name: 'Instala o PHP5'
      apt:
        name: php5
        state: latest
      become: yes
    - name: 'Instala o Apache2'
      apt:
        name: apache2
        state: latest
      become: yes
    - name: 'Instala o modphp'
      apt:
        name: libapache2-mod-php5
        state: latest
      become: yes
```

7. Teste se está tudo funcionando acessando o IP da máquina virtual, deverá exibir uma mensagem do Apache2!

Na aula aprendemos como definir varias dependências no playbook através \{{ item \}} e with\_items. Exemplo com with\_items:

```bash
    - name: 'Instala pacotes do sistema operacional'
      apt:
        name: '{{ item }}'
        state: latest
      become: yes
      with_items:
        - php5
        - apache2
        - libapache2-mod-php5
```

As versões mais recentes do Ansible descontinuaram (deprecated) essa forma de laço a favor de um nova sintaxe mais enxuta. Abaixo o exemplo do mesmo laço mas agora listando os pacotes pelo name:

```bash
    - name: 'Instala pacotes do sistema operacional'
      apt:
        name:
        - php5
        - apache2
        - libapache2-mod-php5
        state: latest
      become: yes
```

1. Comece editando o provisioning.yml. Dentro do bloco de tasks, junte todas as dependências em uma task só: os já conhecidos:

```bash
- name: 'Instala pacotes de dependencia do sistema operacional'
      apt:
        name: "{{ item }}"
        state: latest
      become: yes
      with_items:
        - php5
        - apache2
        - libapache2-mod-php5
```

A variável item está ali para reduzir o número de blocos que você precisa criar. 2) Em seguida, adicione mais dependências:

```bash
- name: 'Instala pacotes de dependencia do sistema operacional'
      apt:
        name: "{{ item }}"
        state: latest
    become: yes
      with_items:
        - php5
        - apache2
        - libapache2-mod-php5
        - php5-gd
        - libssh2-php
        - php5-mcrypt
        - mysql-server-5.6
        - python-mysqldb
        - php5-mysql
```

Agora que há uma lista de dependências, a variável item representará cada um dos elementos dessa lista. 3) Agora, no arquivo hosts, do lado do IP, adicione as variáveis de usuário e chave privada:

```bash
[wordpress]
172.17.177.40 ansible_user=vagrant ansible_ssh_private_key_file="/Users/marcoscropalato/wordpress_com_ansible/.vagrant/machines/wordpress/virtualbox/private_key"
```

1. Depois de todo o bloco que você já criou para a instalação das dependências, crie uma base de dados MySQL. Seus parâmetros indicam o nome do banco, o login do MySQL (que por padrão, no Ubuntu, é root) e o state, que nesse caso indica uma criação de banco:

```bash
- name: 'Cria o banco do MySQL'
  mysql_db:
    name: wordpress_db
    login_user: root
    state: present
```

2. Em seguida, adicione outra task, mas para criar um usuário do MySQL. Seus parâmetros indicam o usuário que será utilizado para autenticar, o nome do usuário a ser criado, a sua senha, seus privilégios e o state, que nesse caso indica uma criação de usuário:

```bash
- name: 'Cria o usuário do MySQL'
  mysql_user:
    login_user: root
    name: wordpress_user
    password: 12345
    priv: 'wordpress_db.*:ALL'
    state: present
```

Há também diversas outras opções e combinações que podemos fazer, tudo está disponível na documentação do ansible[http://docs.ansible.com/ansible/latest/index.html](broken-reference) do Ansible.

3. Por fim, rode o Playbook:

```bash
ansible-playbook -i hosts provisioning.yml
```

1. Comece editando o arquivo provisioning.yml para que o download do WordPress seja feito. Adicione no final do arquivo:

```bash
- name: 'Baixa o arquivo de instalacao do Wordpress'
  get_url: 
    url: 'https://wordpress.org/latest.tar.gz'
    dest: '/tmp/wordpress.tar.gz'
```

2. Agora adicione no seu provisioning.yml o código abaixo, para a descompactação do arquivo que será baixado acima:

```bash
- name: 'Descompacta o Wordpress'
  unarchive: 
    src: '/tmp/wordpress.tar.gz'
    dest: '/var/www/'
    remote_src: yes
  become: yes
```

3. Para copiar o arquivo de configuração do WordPress, adicione o código o seguinte no arquivo provisioning.yml:

```bash
- copy:
    src: '/var/www/wordpress/wp-config-sample.php'
    dest: '/var/www/wordpress/wp-config.php'
    remote_src: yes
  become: yes
```

4. Utilize a estratégia de Regex para alterar as variáveis, no final do arquivo provisioning.yml, adicione o seguinte código:

```bash
- name: 'Configura o wp-config com as entradas do banco de dados'
  replace:
    path: '/var/www/wordpress/wp-config.php'
    regexp: "{{ item.regex }}"
    replace: "{{ item.value }}"
  with_items:
   - { regex: 'database_name_here', value: 'wordpress_db' }
   - { regex: 'username_here', value: 'wordpress_user' }
   - { regex: 'password_here', value: '12345' }
  become: yes
```

5. Feitas as modificações, execute seu Playbook executando o comando abaixo no terminal:

```bash
ansible-playbook -i hosts provisioning.yml
```

6. Entre na sua máquina virtual:

```bash
vagrant ssh
```

E utilize o comando abaixo:

```bash
cat /etc/apache2/sites-available/000-default.conf
```

E copie todo o conteúdo deste arquivo, exibido no terminal.

7. Crie uma cópia local, para isso crie o diretório files e nomeie esse arquivo de 000-default.conf, conforme o original.
8. Feita a cópia, procure pelo trecho que indica o caminho e modifique, veja abaixo:

```bash
ServerAdmin webmaster@localhost
DocumentRoot /var/www/wordpress
```

Salve o arquivo.

9. Volte para o provisioning.yml e configure o Apache, copiando o arquivo local para dentro da máquina:

```bash
- name: 'Configura Apache para servir Wordpress'
  copy:
    src: 'files/000-default.conf'
    dest: '/etc/apache2/sites-available/000-default.conf'
  become: yes
  notify:
    - restart apache
```

10. No topo do seu código, logo abaixo de hosts adicione o handler para reiniciar o Apache:

```bash
---
- hosts: all
  handlers:
     - name: restart apache
       service:
         name: apache2
         state: restarted
  become: yes
```

11. Por fim, execute seu Playbook com o comando abaixo:

```bash
ansible-playbook -i hosts provisioning.yml
```

1. Para separar o banco de dados da aplicação, primeiramente crie duas máquinas virtuais, alterando o Vagrantfile:

```bash
Vagrant.configure("2") do |config|

  config.vm.box = "ubuntu/trusty64"

  config.vm.provider "virtualbox" do |v|
    v.memory = 1024
  end

  config.vm.define "wordpress" do |m|
    m.vm.network "private_network", ip: "172.17.177.40"
  end

  config.vm.define "mysql" do |m|
    m.vm.network "private_network", ip: "172.17.177.42"
  end

end
```

2. Em hosts, adicione a máquina nova, separando em um novo grupo, o grupo database:

```bash
[wordpress]
172.17.177.40 ansible_user=vagrant ansible_ssh_private_key_file="/Users/marcoscropalato/wordpress_com_ansible/.vagrant/machines/wordpress/virtualbox/private_key"

[database]
172.17.177.42 ansible_user=vagrant ansible_ssh_private_key_file="/Users/marcoscropalato/wordpress_com_ansible/.vagrant/machines/mysql/virtualbox/private_key"
```

3. Feito isso, crie a máquina virtual nova, executando o seguinte comando no terminal:

```bash
vagrant up mysql
```

4. Em provisioning.yml, separe os comandos, pois agora você terá um servidor especializado no banco de dados e um servidor especializado na aplicação. Então, crie um grupo de hosts novo, com o mesmo nome do grupo colocado no arquivo hosts. Nesse grupo, você instalará os pacotes mysql-server-5.6 e python-mysqldb, e configurará o banco de dados, criando o database e o usuário do MySQL:

```bash
- hosts: database
  tasks:

    - name: 'Instala pacotes de dependencia do sistema operacional'
      apt:
        name: "{{ item }}"
        state: latest
      become: yes
      with_items:
        - mysql-server-5.6
        - python-mysqldb

    - name: 'Cria o banco do MySQL'
      mysql_db:
        name: wordpress_db
        login_user: root
        state: present

    - name: 'Cria o usuário do MySQL'
      mysql_user:
        login_user: root
        name: wordpress_user
        password: 12345
        priv: 'wordpress_db.*:ALL'
        state: present
```

5. Os comandos de instalação do PHP, WordPress e Apache não devem ser executados nessa máquina. Então, modifique o hosts all para somente wordpress.
6. Agora, rode o Playbook, executando o seguinte comando no terminal:

```bash
ansible-playbook -i hosts provisioning.yml
```

7. Para testar se o banco de dados foi instalado na máquina nova, logue-se com o usuário criado no banco de dados

```bash
vagrant ssh mysql
mysql -u wordpress_user -p12345
```

8. Veja os databases através do comando show databases e veja a base de dados criada

Criando a máquina do WordPress sem MySQL 9) Ainda em provisioning.yml, remova todos os comandos relacionados à instalação de banco de dados da máquina wordpress:

```bash
- hosts: wordpress
  handlers:
    - name: restart apache
      service:
        name: apache2
        state: restarted
      become: yes

  tasks:
    - name: 'Instala pacotes de dependencia do sistema operacional'
      apt:
        name: "{{ item }}"
        state: latest
      become: yes
      with_items:
        - php5
        - apache2
        - libapache2-mod-php5
        - php5-gd
        - libssh2-php
        - php5-mcrypt
        - php5-mysql

    - name: 'Baixa o arquivo de instalacao do Wordpress'
      get_url:
        url: 'https://wordpress.org/latest.tar.gz'
        dest: '/tmp/wordpress.tar.gz'

    - name: 'Descompacta o wordpress'
      unarchive:
        src: '/tmp/wordpress.tar.gz'
        dest: /var/www/
        remote_src: yes
      become: yes

    - copy:
        src: '/var/www/wordpress/wp-config-sample.php'
        dest: '/var/www/wordpress/wp-config.php'
        remote_src: yes
      become: yes

    - name: 'Configura o wp-config com as entradas do banco de dados'
      replace:
        path: '/var/www/wordpress/wp-config.php'
        regexp: "{{ item.regex }}"
        replace: "{{ item.value }}"
      with_items:
        - { regex: 'database_name_here', value: 'wordpress_db'}
        - { regex: 'username_here', value: 'wordpress_user'}
        - { regex: 'password_here', value: '12345'}
      become: yes

    - name: 'Configura Apache para servir o Wordpress'
      copy:
        src: 'files/000-default.conf'
        dest: '/etc/apache2/sites-available/000-default.conf'
      become: yes
      notify:
        - restart apache
```

10. Feito isso, destrua essa máquina, crie uma nova e configure-a, executando no terminal:

```bash
vagrant destroy -f wordpress
vagrant up wordpress
ansible-playbook -i hosts provisioning.yml
```

11. No arquivo de configuração do WordPress, é preciso informar o host do banco de dados, alterando o valor localhost para o IP da máquina onde está rodando o banco de dados

```bash
- name: 'Configura o wp-config com as entradas do banco de dados'
  replace:
    path: '/var/www/wordpress/wp-config.php'
    regexp: "{{ item.regex }}"
    replace: "{{ item.value }}"
  with_items:
    - { regex: 'database_name_here', value: 'wordpress_db'}
    - { regex: 'username_here', value: 'wordpress_user'}
    - { regex: 'password_here', value: '12345'}
    - { regex: 'localhost', value: '172.17.177.42'}
  become: yes
```

12. Por padrão, a instalação do MySQL não aceita conexões que de outros IPs que não sejam localhost e os usuários criados só possuem permissão local, então essas duas informações precisam ser modificadas. Então, no host database, quando o usuário do MySQL é criado, adicione uma lista de hosts possíveis de se conectar com o banco de dados:

```bash
- name: 'Cria o usuário do MySQL'
  mysql_user:
    login_user: root
    name: wordpress_user
    password: 12345
    priv: 'wordpress_db.*:ALL'
    state: present
    host: "{{ item }}"
  with_items:
    - 'localhost'
    - '127.0.0.1'
    - '172.17.177.40'
```

13. Para que o serviço do MySQL aceite conexões remotas, altere o seu arquivo de configuração. Execute os comandos abaixo para realizar a conexão com a máquina e visualizar o conteúdo do arquivo my.cnf. Ao visualizá-lo, copie o seu conteúdo:

```bash
vagrant ssh mysql
cat /etc/mysql/my.cnf
```

Copiado o conteúdo do arquivo my.cnf, dentro do seu projeto, na pasta files, crie um novo arquivo também com o nome my.cnf, e cole o conteúdo copiado anteriormente. Colado o conteúdo, altere o valor da propriedade bind-address para 0.0.0.0:

```bash
bind-address        = 0.0.0.0
```

14. Agora, é preciso informar o Ansible para fazer a cópia deste arquivo:

```bash
- name: 'Configura MySQL para aceitar conexões remotas'
   copy:
     src: 'files/my.cnf'
     dest: '/etc/mysql/my.cnf'
   become: yes
   notify:
     - restart mysql
```

15. Para isso funcionar, é necessário reiniciar o serviço do MySQL, então crie um handler para tal e reinicie o serviço. Ao final, o host ficará assim:

```bash
- hosts: database
  handlers:
    - name: restart mysql
      service:
        name: mysql
        state: restarted
      become: yes

  tasks:
    - name: 'Instala pacotes de dependencia do sistema operacional'
      apt:
        name: "{{ item }}"
        state: latest
      become: yes
      with_items:
        - mysql-server-5.6
        - python-mysqldb

    - name: 'Cria o banco do MySQL'
      mysql_db:
        name: wordpress_db
        login_user: root
        state: present

    - name: 'Cria o usuário do MySQL'
      mysql_user:
        login_user: root
        name: wordpress_user
        password: 12345
        priv: 'wordpress_db.*:ALL'
        state: present
        hosts: "{{ item }}"
      with_items:
        - 'localhost'
        - '127.0.0.1'
        - '172.17.177.40'

    - name: 'Configura MySQL para aceitar conexões remotas'
      copy:
        src: 'files/my.cnf'
        dest: '/etc/mysql/my.cnf'
      become: yes
      notify:
        - restart mysql
```

16. Apesar dos ajustes, ele não vai conseguir copiar novamente o arquivo my.cnf, porque ele já existe. Para que ele possa chamar o handler, faremos uma pequena alteração no arquivo, incluindo \* após Basic Settings:

```bash
[mysqld]
#
# * Basic Settings * 
#
```

17. Por fim, rode o Playbook:

```bash
ansible-playbook -i hosts provisioning.yml
```

1. Para deixar o código mais organizado, crie uma variável para substituir o nome do banco (wp\_db\_name), uma para o seu usuário (wp\_username), uma para sua senha (wp\_user\_password), uma para o diretório de instalação do WordPress (wp\_installation\_dir), uma para o IP do host (wp\_host\_ip) e outra para o IP do banco de dados (wp\_db\_ip). No momento de utilizar essas variáveis no Playbook, lembre-se de utilizar chaves e aspas duplas, por exemplo: "\{{ wp\_db\_name \}}".
2. Na pasta raiz do projeto, crie a pasta group\_vars e dentro dela o arquivo all.yml. Dentro desse arquivo, declare as variáveis gerais:

```bash
---
wp_username: wordpress_user
wp_db_name: wordpress_db
wp_user_password: 12345
wp_installation_dir: '/var/www/wordpress'
```

3. Como o IP do host é importante para o banco de dados, crie também o arquivo group\_vars/database.yml, com a declaração dessa variável:

```bash
---
wp_host_ip: '172.17.177.40'
```

4. Mesma coisa para o IP do banco de dados, que é importante para o WordPress, então crie o arquivo group\_vars/wordpress.yml, com a declaração dessa variável:

```bash
---
wp_db_ip: '172.17.177.42'
```

5. Utilize a variável do diretório de instalação do WordPress também no arquivo files/000-default.conf, na propriedade DocumentRoot:

```bash
DocumentRoot /var/www/wordpress
```

6. Para que o arquivo de configuração do Apache também possa utilizar as variáveis, ele precisa ser um template. Então, na pasta raiz, crie a pasta templates, mova o arquivo 000-default.conf da pasta files para dentro desta nova pasta e adicione a extensão j2 ao arquivo de configuração. Além disso, no Playbook, substitua a cópia de arquivo para utilizar o template:

```bash
- name: 'Configura Apache para servir o Wordpress'
  template:
    src: 'templates/000-default.conf.j2'
    dest: '/etc/apache2/sites-available/000-default.conf'
  become: yes
  notify:
    - restart apache
```

7. Por fim, rode o Playbook:

```bash
ansible-playbook -i hosts provisioning.yml
```

1. Agora que você já tem o Ansible configurado, você precisa pensar em como melhorar o código para aumentar o seu reuso. Reorganize-o em roles, para isso crie um diretório roles com 3 subdiretórios: mysql, webserver e wordpress.
2. A primeira role vai lidar com o MySQL, crie o arquivo no seguinte caminho: roles/mysql/tasks/main.yml. Nele, coloque o trecho de código específico dessa role:

```bash
---
- name: 'Instala pacotes de dependencia do sistema operacional'
  apt:
    name: "{{ item }}"
    state: latest
  become: yes
  with_items:
    - mysql-server-5.6
    - python-mysqldb

- name: 'Cria o banco do MySQL'
  mysql_db:
    name: "{{ wp_db_name }}"
    login_user: root
    state: present

- name: 'Cria o usuário do MySQL'
  mysql_user:
    login_user: root
    name: "{{ wp_username }}"
    password: "{{ wp_user_password }}"
    priv: "{{ wp_db_name }}.*:ALL"
    state: present
    host: "{{ item }}"
  with_items:
   - 'localhost'
   - '127.0.0.1'
   - "{{ wp_host_ip }}"

- name: 'Configura MySQL para aceitar conexões remotas'
  copy:
    src: 'files/my.cnf'
    dest: '/etc/mysql/my.cnf'
  become: yes
  notify:
    - restart mysql
```

3. O handler dessa role ficará em roles/mysql/handlers/main.yml, com o seguinte conteúdo:

```bash
---
- name: restart mysql
  service:
    name: mysql
    state: restarted
  become: yes
```

4. Feito isso, em provisioning.yml, apague esses trechos que foram externalizados nos dois arquivos anteriores e invoque a role criada para o database:

```bash
---
- hosts: database
  roles:
    - mysql

# Outros HOSTS omitidos
```

5. Depois da primeira role implementada, faça de maneira análoga para webserver.

Crie o arquivo roles/webserver/tasks/main.yml com o conteúdo a seguir. Perceba que esse e todos o conteúdos desse exercício já haviam sido definidos em provisioning.yml, basta copiá-lo e removê-lo do arquivo de origem:

```bash
---
- name: 'Instala pacotes de dependencia do sistema operacional'
  apt:
    name: "{{ item }}"
    state: latest
  become: yes
  with_items:
    - php5
    - apache2
    - libapache2-mod-php5
    - php5-gd
    - libssh2-php
    - php5-mcrypt
    - php5-mysql
```

Feito isso, inclua essa role dentro de provisioning.yml:

```bash
# código anterior omitido...
- hosts: wordpress
  handlers:
    # código do handler omitido...
  roles:
    - webserver
```

6. Agora, cuide da instalação do WordPress em uma nova role. Dentro de roles/wordpress/tasks/main.yml, você terá o seguinte conteúdo:

```bash
---
- name: 'Baixa o arquivo de instalacao do Wordpress'
  get_url:
    url: 'https://wordpress.org/latest.tar.gz'
    dest: '/tmp/wordpress.tar.gz'

- name: 'Descompacta o wordpress'
  unarchive:
    src: '/tmp/wordpress.tar.gz'
    dest: /var/www/
    remote_src: yes
  become: yes

- copy:
    src: "{{ wp_installation_dir }}/wp-config-sample.php"
    dest: "{{ wp_installation_dir }}/wp-config.php"
    remote_src: yes
  become: yes

- name: 'Configura o wp-config com as entradas do banco de dados'
  replace:
    path: "{{ wp_installation_dir}}/wp-config.php"
    regexp: "{{ item.regex }}"
    replace: "{{ item.value }}"
  with_items:
    - { regex: 'database_name_here', value: "{{ wp_db_name }}"}
    - { regex: 'username_here', value: "{{ wp_username }}"}
    - { regex: 'password_here', value: "{{ wp_user_password }}"}
    - { regex: 'localhost', value: "{{ wp_db_ip }}"}
  become: yes

- name: 'Configura Apache para servir Wordpress'
  template:
    src: 'templates/000-default.conf.j2'
    dest: '/etc/apache2/sites-available/000-default.conf'
  become: yes
  notify:
    - restart apache
```

7. Você precisará do handler para essa role. Crie o arquivo roles/wordpress/handlers/main.yml com o seguinte conteúdo:

```bash
---
- name: restart apache
  service:
    name: apache2
    state: restarted
  become: yes
```

8. Agora, proviosning.yml ficará como a seguir:

```bash
---
- hosts: database
  roles:
    - mysql

- hosts: wordpress
  roles:
    - webserver
    - wordpress
```

9. Para melhorar ainda mais, coloque templates e files dentro das roles. Embora esteja funcionando sem esse cuidado, essa prática de deixar esses arquivos no nível do projeto não facilitará o reuso em projetos futuros.

Então, mova o arquivo files/my.cnf para o diretório (que deve ser criado) roles/mysql/files.

10. Mova também o template templates/000-default.conf.j2 para o diretório (que também deve ser criado) roles/wordpress/templates
11. Delete os diretórios que ficaram vazios: files e templates
12. Para deixar ainda mais expressivo e evitar problemas da dependência do WordPress com a role do webserver crie o arquivo roles/wordpress/meta/main.yml com o seguinte conteúdo:

```bash
---
dependencies:
  - webserver
```

E remova essa role do provisoning.yml, que terá como conteúdo final:

```bash
---
- hosts: database
  roles:
    - mysql

- hosts: wordpress
  roles:
    - wordpress
```

13. Para melhorar ainda mais, defina valores padrões para as roles. Para isso, externalize os IPs liberados para acesso ao MySQL em um arquivo main.yml, que ficará em roles/mysql/defaults, e terá o seguinte conteúdo:

```bash
---
wp_host_ip:
  - localhost
  - '127.0.0.1'
```

Lembre-se de remover esses dois IPs de roles/mysql/tasks/main.yml:

```bash
- name: 'Cria o usuário do MySQL'
  mysql_user:
    login_user: root
    name: "{{ wp_username }}"
    password: "{{ wp_user_password }}"
    priv: "{{ wp_db_name }}.*:ALL"
    state: present
    host: "{{ item }}"
  with_items:
   - "{{ wp_host_ip }}"
```

14. Por fim, rode o Playbook:

```bash
ansible-playbook -i hosts provisioning.yml
```

##

## yum remove docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras

## rm -rf /var/lib/docker

## rm -rf /var/lib/containerd

## Precisa fechar conexão nas port :

## 4369

## 5672

## 22

## https://etcd.dev/2021/10/04/como-construir-um-cluster-rabbitmq-no-ubuntu-20-04/

## Garante a sincronização geral de todas as queus

## sudo rabbitmqctl set\_policy ha-all ".\*" '{"ha-mode":"all"}'

## Garante a sincronização de queus iniciadas com 'uh-office'

## sudo rabbitmqctl set\_policy uh-office-provisioner "^uh-office." '{"ha-mode":"exactly","ha-params":2,"ha-sync-mode":"automatic"}'

## Garante a sincronização de dados entre clusters

## sudo rabbitmqctl set\_policy ha-nodes "^nodes." '{"ha-mode":"nodes","ha-params":\["rabbit@rabbitmq02", "rabbit@rabbitmq03"]}'

\######################################Configurando um usuário administrador para RabbitMQ################################################

## Cria um usuário admin

### sudo rabbitmqctl add\_user dgutierres UserPassRabbitMQ

## Define (set\_user\_tags) o novo usuário (admin) como administrator para o cluster RabbitMQ.

### sudo rabbitmqctl set\_user\_tags dgutierres administrator

## Execute o comando abaixo para set\_permissionso adminusuário com o seguinte:

## Permite ( -p /) adminque o usuário acesse todos os vhosts no cluster RabbitMQ.

## Primeiro ".\*"– Permite ao usuário configurar a permissão para cada entidade e vhosts.

## Segundo ".\*"– Habilita permissão de gravação para o usuário para todas as entidades e vhosts.

## Terceiro ".\*"– Habilita permissão de leitura para o usuário para todas as entidades e vhosts.

### sudo rabbitmqctl set\_permissions -p / dgutierres "._" "._" ".\*"

## Excluir (delete\_user) o usuário padrão (guest) do cluster RabbitMQ.

## sudo rabbitmqctl delete\_user guest

## Listar todos os usuários disponíveis (list\_users) no cluster RabbitMQ.

### sudo rabbitmqctl list\_users

\##################################Criando um host virtual e um novo usuário administrador no RabbitMQ####################################

## Criar um novo vhost (add\_vhost) chamado app-qa1.

### sudo rabbitmqctl add\_vhost app-qa1

## Criar um novo usuário (add\_user) e marque o usuário como administrator

### sudo rabbitmqctl add\_user dgutierres UserPassRabbitMQ

## set a tag administrator for user dgutierres

### sudo rabbitmqctl set\_user\_tags dgutierres administrator

\################################## definir permissões para o usuário dgutierres gerenciar vhost app-qa1.################################ ########### Essas permissões permitem que o usuário dgutierres configure, leia e grave todas as entidades no vhost app-qa1 #############

## set up permission for user dgutierres

### sudo rabbitmqctl set\_permissions dgutierres --vhost app-qa1 "._" "._" ".\*"

## Listar os vhosts (list\_vhosts) disponíveis no cluster RabbitMQ e as permissões (list\_user\_permissions) do novo usuário administrador

### sudo rabbitmqctl list\_vhosts

## check permissions for user dgutierres

### sudo rabbitmqctl list\_user\_permissions dgutierres

\#################### Criar uma nova troca no RabbitMQ chamada test\_exchange sob o vhost app-qa1 e o usuário dgutierres. ################

## Podemos especificar o tipo de troca com a opção type, que é direct para esta demonstração.

## Create new exchange test\_exchange

### sudo rabbitmqadmin -u admin -p UserPassRabbitMQ -V / declare exchange name=disponibility type=direct

## Cria novas filas no RabbitMQ. Criará o padrão classic(test\_classic) e a fila quorum chamada test\_quorum.

## create quorum queue with option queue\_type=quorum

### sudo rabbitmqadmin -u admin -p UserPassRabbitMQ -V / declare queue name=disponibility\_queue\_quorum durable=true queue\_type=quorum

## create default classic queue

### sudo rabbitmqadmin -u dgutierres -p UserPassRabbitMQ -V app-qa1 declare queue name=test\_classic durable=true

\###########################################Cria ligação para as filas test\_classic e test\_quorum. ########################################

## Cada ligação é diferente routing\_key, mas ainda é executada na mesma troca (test\_exchange).

### sudo rabbitmqadmin -u dgutierres -p UserPassRabbitMQ -V app-qa1 declare binding source="test\_exchange" destination\_type="queue" destination="test\_quorum" routing\_key="routing\_key\_quorum"

## create binding for test\_classic

### sudo rabbitmqadmin -u dgutierres -p UserPassRabbitMQ -V app-qa1 declare binding source="test\_exchange" destination\_type="queue" destination="test\_classic" routing\_key="routing\_key\_classic"

\############################################## Publisha mensagem hello world para o arquivo test\_exchange. ############################ #################################################### Certifique-se de definir o routing\_key correto . ###################################

## publish message for the test\_quorum queue

### sudo rabbitmqadmin -u dgutierres -p UserPassRabbitMQ -V app-qa1 publish exchange=test\_exchange routing\_key=routing\_key\_quorum payload="hello world, Quorum Queue"

## publish message for the test\_classic queue

### sudo rabbitmqadmin -u dgutierres -p UserPassRabbitMQ -V app-qa1 publish exchange=test\_exchange routing\_key=test\_routing\_key\_classic payload="hello world, Classic Queue"

\##################################### get a mensagem hello, world das filas test\_quorum e test\_classic. #################################

## retrieve the message from test\_quorum queue

### sudo rabbitmqadmin -u dgutierres -p UserPassRabbitMQ -V app-qa1 get queue=test\_quorum

## retrieve the message from test\_classic queue

### sudo rabbitmqadmin -u dgutierres -p UserPassRabbitMQ -V app-qa1 get queue=test\_classic

\######################################### Obtem a mensagem “hello world” da fila test\_classic. ##########################################

## Este comando fará cinco solicitações à fila test\_classic usando o Bash loop.

## setup temporary environment variable CLASSIC

### export CLASSIC="sudo rabbitmqadmin -u dgutierres -p UserPassRabbitMQ -V app-qa1 get queue=test\_classic"

\############################################# Recuperar a mensagem “hello world” da fila test\_quorum. ##################################

## Semelhante ao teste da fila test\_classic, esse comando faz cinco solicitações à fila test\_quorum,

## mas, desta vez, receberá a mensagem “hello world” mesmo que node01 esteja inoperante.

## Por que? A fila test\_quorum é replicada/espelhada automaticamente para os servidores node02 ou node03.

## setup temporary environment variable QUORUM

### export QUORUM="sudo rabbitmqadmin -u dgutierres -p UserPassRabbitMQ -V app-qa1 get queue=test\_quorum"

## retrieve message from `test_quorum` queue 5 times using bash loop

### for i in {1..5}; do $QUORUM; done

## https://adamtheautomator.com/rabbitmq-cluster/

yum install -y yum-utils yum-config-manager\
\--add-repo\
https://download.docker.com/linux/centos/docker-ce.repo

yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

systemctl start docker systemctl enable docker

yum install git

docker info && docker compose version

git clone https://github.com/rabbitmq/rabbitmq-server.git cd rabbitmq-server/deps/rabbitmq\_prometheus/docker

docker compose -f docker-compose-metrics.yml up -d docker compose -f docker-compose-overview.yml up -d

http://localhost:3000/dashboards

rabbitmq-plugins enable rabbitmq\_prometheus curl -v -H "Accept:text/plain" "http://localhost:15692/metrics"

Este exportador oferece suporte às seguintes opções por meio de um conjunto de prometheus.\*chaves de configuração:

## these values are defaults

prometheus.return\_per\_object\_metrics = false prometheus.path = /metrics prometheus.tcp.port = 15692

curl -v -H "Accept:text/plain" "http://localhost:15692/metrics/per-object"

https://www.centos.org/download/mirrors/

curl 'http://mirrorlist.centos.org/?release=7\&arch=x86\_64\&repo=os\&infra=container'

https://aristides.dev/monitorando-seus-servidores-com-grafana-e-prometheus/

https://rafaelchiavegatto.com.br/2016/10/11/utilizando-o-ansible-para-provisionar-ambientes/

## rabbitmqctl add\_vhost app-qa1

## rabbitmqctl set\_permissions mqadmin --vhost app-qa1 "._" "._" ".\*"

## rabbitmqadmin -u mqadmin -p Admin123XX\_ -V app-qa1 declare exchange name=test\_exchange type=direct

## rabbitmqadmin -u mqadmin -p Admin123XX\_ -V app-qa1 declare queue name=test\_quorum durable=true queue\_type=quorum

## rabbitmqadmin -u mqadmin -p Admin123XX\_ -V app-qa1 declare binding source="test\_exchange" destination\_type="queue" destination="test\_quorum" routing\_key="routing\_key\_quorum"

## rabbitmqadmin -u mqadmin -p Admin123XX\_ -V app-qa1 publish exchange=test\_exchange routing\_key=routing\_key\_quorum payload="hello world, Quorum Queue1"

## rabbitmqadmin -u mqadmin -p Admin123XX\_ -V app-qa1 get queue=test\_quorum
