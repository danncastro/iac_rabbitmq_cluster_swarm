# Cases

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
