# Provisionando aplicação básica

{% tabs %}
{% tab title="world.txt" %}
1. Dentro do pasta do projeto crie o arquivo de Playbook, chamado `provisioning.yml` e escreva o conteúdo abaixo. Repare nos 3 hífens iniciais:

```yaml
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
{% endtabs %}

{% tabs %}
{% tab title="MySQL" %}
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

***

3. Por fim, rode o Playbook:

```bash
ansible-playbook -i hosts provisioning.yml
```
{% endtab %}

{% tab title="Wordpress" %}
1. Comece editando o arquivo provisioning.yml para que o download do WordPress seja feito. Adicione no final do arquivo:

```yaml
- name: 'Baixa o arquivo de instalacao do Wordpress'
  get_url: 
    url: 'https://wordpress.org/latest.tar.gz'
    dest: '/tmp/wordpress.tar.gz'
```

***

2. Agora adicione no seu `provisioning.yml` o código abaixo, para a descompactação do arquivo que será baixado acima:

```yaml
- name: 'Descompacta o Wordpress'
  unarchive: 
    src: '/tmp/wordpress.tar.gz'
    dest: '/var/www/'
    remote_src: yes
  become: yes
```

***

3. Para copiar o arquivo de configuração do WordPress, adicione o código o seguinte no arquivo provisioning.yml:

```yaml
- copy:
    src: '/var/www/wordpress/wp-config-sample.php'
    dest: '/var/www/wordpress/wp-config.php'
    remote_src: yes
  become: yes
```

***

4. Utilize a estratégia de Regex para alterar as variáveis, no final do arquivo provisioning.yml, adicione o seguinte código:

```yaml
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

***

5. Feitas as modificações, execute seu Playbook executando o comando abaixo no terminal:

```bash
ansible-playbook -i hosts provisioning.yml
```
{% endtab %}

{% tab title="VM" %}
1. Entre na sua máquina virtual e utilize o comando abaixo:

```bash
vagrant ssh
```

```bash
cat /etc/apache2/sites-available/000-default.conf
```

* Copie todo o conteúdo deste arquivo, exibido no terminal.
* Crie uma cópia local, para isso crie o diretório files e nomeie esse arquivo de 000-default.conf, conforme o original.

***

2. Feita a cópia, procure pelo trecho que indica o caminho e modifique, veja abaixo:

```vim
ServerAdmin webmaster@localhost
DocumentRoot /var/www/wordpress
```

* Salve o arquivo.

***

3. Volte para o `provisioning.yml` e configure o Apache, copiando o arquivo local para dentro da máquina:

```yaml
- name: 'Configura Apache para servir Wordpress'
  copy:
    src: 'files/000-default.conf'
    dest: '/etc/apache2/sites-available/000-default.conf'
  become: yes
  notify:
    - restart apache
```
{% endtab %}

{% tab title="Handler" %}
1. No topo do seu código, logo abaixo de hosts adicione o handler para reiniciar o Apache:

```yaml
---
- hosts: all
  handlers:
     - name: restart apache
       service:
         name: apache2
         state: restarted
  become: yes
```

***

2. Por fim, execute seu Playbook com o comando abaixo:

```bash
ansible-playbook -i hosts provisioning.yml
```
{% endtab %}

{% tab title="Segmentar" %}
1. Para separar o banco de dados da aplicação, primeiramente crie duas máquinas virtuais, alterando o Vagrantfile:

```ruby
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

***

2. Em hosts, adicione a máquina nova, separando em um novo grupo, o grupo database:

```bash
[wordpress]
172.17.177.40 ansible_user=vagrant ansible_ssh_password=vagrant

[database]
172.17.177.42 ansible_user=vagrant ansible_ssh_password=vagrant
```

***

3. Feito isso, crie a máquina virtual nova, executando o seguinte comando no terminal:

```bash
vagrant up mysql
```
{% endtab %}
{% endtabs %}

***

{% tabs %}
{% tab title="provisioning.yml" %}
1. Em provisioning.yml, separe os comandos, pois agora você terá um servidor especializado no banco de dados e um servidor especializado na aplicação.&#x20;
2. Então, crie um grupo de hosts novo, com o mesmo nome do grupo colocado no arquivo hosts.&#x20;
3. Nesse grupo, você instalará os pacotes `mysql-server-5.6` e `python-mysqldb`, e configurará o banco de dados, criando o database e o usuário do MySQL:

```yaml
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
{% endtab %}

{% tab title="Database" %}
1. Os comandos de instalação do PHP, WordPress e Apache não devem ser executados nessa máquina. Então, modifique o hosts all para somente wordpress.

***

2. Agora, rode o Playbook, executando o seguinte comando no terminal:

```bash
ansible-playbook -i hosts provisioning.yml
```

***

3. Para testar se o banco de dados foi instalado na máquina nova, logue-se com o usuário criado no banco de dados

```bash
vagrant ssh mysql
mysql -u wordpress_user -p12345
```

***

4. Veja os databases através do comando show databases e veja a base de dados criada

```bash
show databases;
```

***
{% endtab %}
{% endtabs %}

***
