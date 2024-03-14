# Criando a máquina do WordPress sem MySQL

Ainda em `provisioning.yml`, remova todos os comandos relacionados à instalação de banco de dados da máquina wordpress:

{% tabs %}
{% tab title="provisioning" %}
```yaml
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
{% endtab %}

{% tab title="Wordpress" %}
1. Feito isso, destrua essa máquina, crie uma nova e configure-a, executando no terminal:

```bash
vagrant destroy -f wordpress
vagrant up wordpress
ansible-playbook -i hosts provisioning.yml
```

***

2. No arquivo de configuração do WordPress, é preciso informar o host do banco de dados, alterando o valor localhost para o IP da máquina onde está rodando o banco de dados

```yaml
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
{% endtab %}

{% tab title="Database" %}
1. Por padrão, a instalação do MySQL não aceita conexões que de outros IPs que não sejam localhost e os usuários criados só possuem permissão local, então essas duas informações precisam ser modificadas.&#x20;
2. Então, no host database, quando o usuário do MySQL é criado, adicione uma lista de hosts possíveis de se conectar com o banco de dados:

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

***

3. Para que o serviço do MySQL aceite conexões remotas, altere o seu arquivo de configuração.&#x20;
4. Execute os comandos abaixo para realizar a conexão com a máquina e visualizar o conteúdo do arquivo `my.cnf`. Ao visualizá-lo, copie o seu conteúdo:

```bash
vagrant ssh mysql
cat /etc/mysql/my.cnf
```

***

5. Copiado o conteúdo do arquivo `my.cnf,` dentro do seu projeto, na pasta files, crie um novo arquivo também com o nome `my.cnf`, e cole o conteúdo copiado anteriormente.&#x20;
6. Colado o conteúdo, altere o valor da propriedade `bind-address` para `0.0.0.0`:

```bash
bind-address        = 0.0.0.0
```

***

7. Agora, é preciso informar o Ansible para fazer a cópia deste arquivo:

```yaml
- name: 'Configura MySQL para aceitar conexões remotas'
   copy:
     src: 'files/my.cnf'
     dest: '/etc/mysql/my.cnf'
   become: yes
   notify:
     - restart mysql
```

***

8. Para isso funcionar, é necessário reiniciar o serviço do MySQL, então crie um handler para tal e reinicie o serviço. Ao final, o host ficará assim:

```yaml
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

* Apesar dos ajustes, ele não vai conseguir copiar novamente o arquivo `my.cnf`, porque ele já existe.&#x20;

***

9. Para que ele possa chamar o handler, faremos uma pequena alteração no arquivo, incluindo \* após Basic Settings:

```bash
[mysqld]
#
# * Basic Settings * 
#
```

***

10. Por fim, rode o Playbook:

```bash
ansible-playbook -i hosts provisioning.yml
```
{% endtab %}

{% tab title="Organização" %}
1. Para deixar o código mais organizado, crie uma variável para substituir o nome do banco, usuário, senha, diretório de instalação do Wordpress, IP do host e do banco de dados

***

* `wp_db_name`
* `wp_username` &#x20;
* `wp_user_password`
* `wp_installation_dir` &#x20;
* `wp_host_ip`&#x20;
* `wp_db_ip`&#x20;

***

2. No momento de utilizar essas variáveis no Playbook, lembre-se de utilizar chaves e aspas duplas, por exemplo: `"{{ wp_db_name }}"`

***

3. Na pasta raiz do projeto, crie a pasta `group_vars` e dentro dela o arquivo `all.yml`.
4. Dentro desse arquivo, declare as variáveis gerais:

```bash
---
wp_username: wordpress_user
wp_db_name: wordpress_db
wp_user_password: 12345
wp_installation_dir: '/var/www/wordpress'
```

***

5. Como o IP do host é importante para o banco de dados, crie também o arquivo `group_vars/database.yml`, com a declaração dessa variável:

```bash
---
wp_host_ip: '172.17.177.40'
```

***

Mesma coisa para o IP do banco de dados, que é importante para o WordPress, então crie o arquivo `group_vars/wordpress.yml`, com a declaração dessa variável:

```bash
---
wp_db_ip: '172.17.177.42'
```

***

6. Utilize a variável do diretório de instalação do WordPress também no arquivo `files/000-default.conf`, na propriedade `DocumentRoot`:

```bash
DocumentRoot /var/www/wordpress
```
{% endtab %}

{% tab title="Template" %}
1. Para que o arquivo de configuração do Apache também possa utilizar as variáveis, ele precisa ser um template.&#x20;
2. Então, na pasta raiz, crie a pasta `templates`, mova o arquivo `000-default.conf` da pasta `files` para dentro desta nova pasta e adicione a extensão `j2` ao arquivo de configuração.&#x20;
3. Além disso, no Playbook, substitua a cópia de arquivo para utilizar o template:

```yaml
- name: 'Configura Apache para servir o Wordpress'
  template:
    src: 'templates/000-default.conf.j2'
    dest: '/etc/apache2/sites-available/000-default.conf'
  become: yes
  notify:
    - restart apache
```

***

4. Por fim, rode o Playbook:

```bash
ansible-playbook -i hosts provisioning.yml
```



***
{% endtab %}
{% endtabs %}

***
