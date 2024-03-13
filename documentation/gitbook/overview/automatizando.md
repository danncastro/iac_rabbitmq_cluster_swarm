# Automatizando

### <mark style="color:red;">Criando a Infraestrutura para automatizações</mark>

Vagrant e Puppet: Criação e provisionamento de maquinas virtuais

1. Crie uma pasta, com o nome `wordpress_com_ansible`.

***

2. Copie o arquivo Vagrantfile e coloque na pasta `wordpress_com_ansible`

```yaml
```

***

3. Utilizando o terminal, dentro da pasta `wordpress_com_ansible` execute o comando abaixo:

```bash
vagrant up
```

***

4. Crie o arquivo de inventário hosts e comece colocando o IP da máquina virtual,&#x20;
   1. Defina um grupo também:

```bash
[wordpress]
172.17.177.40 ansible_user=vagrant ansible_ssh_password=vagrant
```

***

5. Teste se sua máquina virtual está funcionando, executando o código abaixo:

```bash
vagrant ssh
```

* Utilize o atalho CTRL + C para deslogar da máquina virtual.

***

6. Rode o comando Ansible abaixo para ter um simples hello world:

```bash
ansible wordpress -u vagrant --private-key .vagrant/machines/wordpress/virtualbox/private_key -i hosts -m shell -a 'echo Hello, World'
```

***

7. Para ter uma saída mais verbosa, utilize o comando abaixo, onde foi incluído o parâmetro -vvvv

```bash
ansible -vvvv wordpress -u vagrant --private-key .vagrant/machines/wordpress/virtualbox/private_key -i hosts -m shell -a 'echo Hello, World'
```

***

### <mark style="color:red;">Erro UNREACHABLE?</mark>

Você está recebendo um erro UNREACHABLE parecido com a saída abaixo?

```bash
172.17.177.40 | UNREACHABLE! => {
    "changed": false,
    "msg": "Failed to connect to the host via ssh: vagrant@172.17.177.40: Permission denied (publickey,password).\r\n",
    "unreachable": true
}
```

{% hint style="info" %}
Se sim, há algum problema com a sua configuração ssh do Vagrant.&#x20;
{% endhint %}

Para resolver esse problema vamos gerar um novo par de chaves ssh e copiar para a VM do Vagrant. Seguem os passos:

1. Na pasta do seu projeto `wordpress_com_ansible`, crie uma nova pasta `ssh_keys` para guardar as chaves ssh e entre na pasta:

```bash
mkdir ssh-keys
cd ssh-keys
```

***

2. Depois gere as chaves com o comando:

```bash
ssh-keygen -t rsa
```

O comando pergunta onde você gostaria de guardar as chaves e qual será o nome da chave. Defina a pasta `ssh_keys` como destino e como base o nome `vagrant_id_rsa`, por exemplo:

```bash
Enter file in which to save the key (/Users/<usuario>/.ssh/id_rsa):
/Users/<seu-usuario>/wordpress_com_ansible/ssh-keys/vagrant_id_rsa
```

***

3. Depois digite uma senha vagrant (ou deixe vazio) e repita a senha.
   1. O comando gera dois arquivos, a chave publica `vagrant_id_rsa.pub` e privada `vagrant_id_rsa`

***

4. Garanta que o Vagrant subiu a VM

```bash
vagrant up
```

5. Vamos copiar a chave pública gerada para a VM. Para tal digite na pasta `ssh_keys`:

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

***

6. Volte para a raiz do seu projeto (na pasta `wordpress_com_ansible`) e tente executar o comando do Ansible:

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

Garante que a maquina virtual está rodando (vagrant up). Você pode ver o status (poweroff, running) da VM vagrant status.

***

### <mark style="color:red;">Provisionando aplicação</mark>

{% tabs %}
{% tab title="world.txt" %}
1. Dentro do pasta do projeto crie o arquivo de Playbook, chamado `provisioning.yml` e escreva o conteúdo abaixo. Repare nos 3 hífens iniciais:

```bash
---
- hosts: all
  tasks:
    - shell: 'echo hello > /vagrant/world.txt'
```

***

2. Abra o diretório `wordpress_com_ansible` no terminal e execute o comando abaixo para utilizar o Playbook criado:

```bash
ansible-playbook provisioning.yml -u vagrant -i hosts --private-key .vagrant/machines/wordpress/virtualbox/private_key
```

***

3. Teste se o script funcionou logando na máquina virtual, e execute o comandos:

```bash
vagrant ssh
```

```bash
ls /vagrant/
```

* Verifique se o arquivo `world.txt` foi criado.
{% endtab %}

{% tab title="PHP8" %}
1. Modifique o arquivo `provisioning.yml:`

```bash
---
- hosts: all
  tasks:
    - name: 'Instala o PHP8'
      apt:
        name: php8
        state: latest
      become: yes
```

***

2. Execute o rode o Playbook:

```bash
ansible-playbook -i hosts provisioning.yml
```
{% endtab %}

{% tab title="Apache2" %}
1. Adicione no seu `provisioning.yml` a instalação do apache2 e do `modphp`.

```bash
---
- hosts: all
  tasks:
    - name: 'Instala o PHP8'
      apt:
        name: php8
        state: latest
      become: yes
    - name: 'Instala o Apache2'
      apt:
        name: apache2
        state: latest
      become: yes
    - name: 'Instala o modphp'
      apt:
        name: libapache2-mod-php8
        state: latest
      become: yes
```

***

2. Teste se está tudo funcionando acessando o IP da máquina virtual, deverá exibir uma mensagem do Apache2!
{% endtab %}

{% tab title="with_items" %}
1. Adicionando dependências no playbook através \{{ item \}} e with\_items:

```yaml
- name: 'Instala pacotes do sistema operacional'
  apt:
    name: '{{ item }}'
    state: latest
  become: yes
  with_items:
    - php8
    - apache2
    - libapache2-mod-php8
```

As versões mais recentes do Ansible descontinuaram (deprecated) essa forma de laço a favor de um nova sintaxe mais enxuta. Abaixo o exemplo do mesmo laço mas agora listando os pacotes pelo name:

```yaml
- name: 'Instala pacotes do sistema operacional'
  apt:
    name:
    - php5
    - apache2
    - libapache2-mod-php5
    state: latest
  become: yes
```

***

2. A variável item está ali para reduzir o número de blocos que você precisa criar.&#x20;

```yaml
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
{% endtab %}

{% tab title="MySql" %}
1. Depois de todo o bloco que você já criou para a instalação das dependências, crie uma base de dados MySQL. Seus parâmetros indicam o nome do banco, o login do MySQL (que por padrão, no Ubuntu, é root) e o state, que nesse caso indica uma criação de banco:

```yaml
- name: 'Cria o banco do MySQL'
  mysql_db:
    name: wordpress_db
    login_user: root
    state: present
```

***

2. Em seguida, adicione outra task, mas para criar um usuário do MySQL. Seus parâmetros indicam o usuário que será utilizado para autenticar, o nome do usuário a ser criado, a sua senha, seus privilégios e o state, que nesse caso indica uma criação de usuário:

```yaml
- name: 'Cria o usuário do MySQL'
  mysql_user:
    login_user: root
    name: wordpress_user
    password: 12345
    priv: 'wordpress_db.*:ALL'
    state: present
```
{% endtab %}
{% endtabs %}

***
