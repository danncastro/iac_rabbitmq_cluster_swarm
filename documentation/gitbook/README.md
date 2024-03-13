# Ansible

### <mark style="color:red;">**Ansible e Infraestrutura sobre código:**</mark>

Infraestrutura como código é a base da cultura DevOps, encurtando assim o ciclo de feedback entre os times de desenvolvimento e os de infraestrutura.&#x20;

* É a partir da máquina de controle com o Ansible instalado que gerenciamos outras máquinas.
* As máquinas gerenciadas pelo Ansible só precisam do Python  e de um servidor SSH instalados.

{% hint style="info" %}
Segue o link da documentação do Ansible (v2.6) com a lista de todos os módulos de banco de dados:&#x20;

**Database module**

[https://docs.ansible.com/ansible/2.6/modules/list\_of\_database\_modules.html](broken-reference)

**MySQL DB Module**

[https://docs.ansible.com/ansible/2.6/modules/mysql\_db\_module.html](broken-reference)
{% endhint %}

***





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
