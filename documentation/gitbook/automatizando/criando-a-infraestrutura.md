# Criando a Infraestrutura

{% tabs %}
{% tab title="Diretório" %}
Vagrant e Puppet: Criação e provisionamento de maquinas virtuais

1. Crie uma pasta, com o nome `wordpress_com_ansible`.

***

2. Copie o arquivo Vagrantfile e coloque na pasta `wordpress_com_ansible`

```yaml
```

***

4. Utilizando o terminal, dentro da pasta `wordpress_com_ansible` execute o comando abaixo:

```bash
vagrant up
```
{% endtab %}

{% tab title="Inventario" %}
1. Crie o arquivo de inventário hosts e comece colocando o IP da máquina virtual,&#x20;
   1. Defina um grupo também:

```bash
[wordpress]
172.17.177.40 ansible_user=vagrant ansible_ssh_password=vagrant
```

***

2. Teste se sua máquina virtual está funcionando, executando o código abaixo:

```bash
ansible -m ping -i host
```

***

3. Rode o comando Ansible abaixo para ter um simples hello world:

```bash
ansible wordpress -u vagrant --private-key .vagrant/machines/wordpress/virtualbox/private_key -i hosts -m shell -a 'echo Hello, World'
```

***

4. Para ter uma saída mais verbosa, utilize o comando abaixo, onde foi incluído o parâmetro `-vvvv`

```bash
ansible -vvvv wordpress -i hosts -m shell -a 'echo Hello, World'
```


{% endtab %}
{% endtabs %}

***

### <mark style="color:red;">Erro UNREACHABLE?</mark>

Você está recebendo um erro UNREACHABLE parecido com a saída abaixo?

> 172.17.177.40 | UNREACHABLE! => {
>
> &#x20;   "changed": false,
>
> &#x20;   "msg": "Failed to connect to the host via ssh: vagrant@172.17.177.40: Permission denied (publickey, password). \r\n",
>
> &#x20;   "unreachable": true
>
> }

{% hint style="info" %}
Se sim, há algum problema com a sua configuração ssh do Vagrant.&#x20;
{% endhint %}

Para resolver esse problema vamos gerar um novo par de chaves ssh e copiar para a VM do Vagrant. Seguem os passos:

{% tabs %}
{% tab title="ssh_key" %}
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

* O comando pergunta onde você gostaria de guardar as chaves e qual será o nome da chave. Defina a pasta `ssh_keys` como destino e como base o nome `vagrant_id_rsa`, por exemplo:

> Enter file in which to save the key (/Users/\<user>/.ssh/id\_rsa):\
> /Users/\<user>/wordpress\_com\_ansible/ssh\_keys/vagrant\_id\_rsa

***

3. Depois digite uma senha vagrant (ou deixe vazio) e repita a senha.
   1. O comando gera dois arquivos, a chave publica `vagrant_id_rsa.pub` e privada `vagrant_id_rsa`
{% endtab %}

{% tab title="Copy SSH" %}
1. Vamos copiar a chave pública gerada para a VM. Para tal digite na pasta `ssh_keys`:

```bash
ssh-copy-id -i vagrant_id_rsa.pub vagrant@172.17.177.40
```

* A senha deve ser vagrant. O comando deve mostrar uma saída parecida com a abaixo:

```bash
vagrant@172.17.177.40's password:
```

***

> Number of key(s) added:     1\
> \
> Now try logging into the machine, with:   "ssh 'vagrant@172.17.177.40'"\
> and check to make sure that only the key(s) you wanted were added.

* Obs: Talvez esteja necessário remover o arquivo \~/.ssh/known\_hosts.
{% endtab %}

{% tab title="Execução" %}
1. Volte para a raiz do seu projeto na pasta `wordpress_com_ansible` e tente executar o comando do Ansible:

```bash
ansible wordpress -i hosts -m ping -m shell -a 'echo Hello, World'
```

***

2. Digite a senha que você usou para gerar a chave:

```bash
Enter passphrase for key '/Users/.../ssh-keys/vagrant_id_rsa': 
```

* Agora deve mostrar:

> 172.17.177.40 | SUCCESS | rc=0 >>\
> Hello, World

Garante que a maquina virtual está rodando (vagrant up). Você pode ver o status (poweroff, running) da VM vagrant status.
{% endtab %}
{% endtabs %}

***
