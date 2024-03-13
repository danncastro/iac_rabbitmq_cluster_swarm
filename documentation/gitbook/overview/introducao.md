# Introdução

### <mark style="color:red;">Instalação</mark>

Para instalar no Ubuntu, utilize o comando abaixo:

```bash
sudo apt-get install ansible
```

Para instalar no MacOs, instale o brew através do comando abaixo:

```bash
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

E logo após, execute o comando abaixo para instalar o Python e o Ansible:

```bash
brew install python@2 ansible@2.0
```

```bash
python -V
```

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
  python version = 2.7.15 (default, Oct  2 2018, 11:47:18) [GCC 4.2.1 Compatible Apple L
```

{% hint style="warning" %}
Ansible não tem suporte para Windows.
{% endhint %}

#### <mark style="color:yellow;">Requisitos automatizar processos no Windows com Ansible</mark>

* Powershell 3++
* Netframwork 4.0
* winrm

***

### <mark style="color:red;">Estrutura básica:</mark>

* <mark style="color:red;">**Playbook:**</mark>  Arquivo yaml com as **"receitas de bolo"** do que queremos fazer.
* <mark style="color:red;">**Arquivo de inventário:**</mark>  Lista todas as máquinas que serão utilizadas na configuração.
* <mark style="color:red;">**Roles:**</mark> Representam uma forma de encapsular tarefas, variáveis e handlers para facilitar o reuso.
* <mark style="color:red;">**Templates:**</mark>  Para trabalhar com os templates, o Ansible usa um outro framework que se chama Jinja. Ele faz parte dos template engines (ou template processor). Um template engine combina um template (HTML, XML, ou qualquer outro arquivo, configurações etc) com um modelo de dados para gerar um novo documento: [Template Engine Jinja.](http://jinja.pocoo.org/)

***

#### <mark style="color:yellow;">**Estrutura básica de uma playbook**</mark>

Existem algumas regras que devemos considerar na hora de declarar uma variável (como em qualquer outra ferramenta ou linguagem de programação).

Por exemplo, uma variável não deve ter um ponto, espaço ou hífen no nome.&#x20;

Todas as declarações abaixo são inválidas:

```bash
foo-var: 'nao_pode_ter_hifen'
foo var: 'nem ter espaco'
foo.var: 'tambem.nao.pode.ter.pontos'
12foovar: '1nao_pode.ter numero_no_inicio'
```

{% hint style="info" %}
Todos os detalhes sobre as declarações e muito mais se encontra da documentação do Ansible: [Documentação sobre Variáveis.](http://docs.ansible.com/ansible/latest/playbooks\_variables.html#what-makes-a-valid-variable-name)
{% endhint %}

#### Execução da playbook

```sh
ansible-playbook caminho/nome_da_playbook.yml
```

#### Documentação Ansible

```conf
ansible-doc --help
```

***

#### <mark style="color:yellow;">Estrutura básica de um arquivo de inventário:</mark>

<pre class="language-sh"><code class="lang-sh"><strong>[servidores_um]
</strong>nome_variavel ansible_ssh_host=ip ansible_ssh_user=user ansible_ssh_pass=key

[servidor_exemplo1]
deb ansible_ssh_host=10.20.20.110 ansible_ssh_user=ansible ansible_ssh_pass=Senha123

[servidor_exemplo2]
deb ansible_ssh_host=10.20.20.120 ansible_ssh_user=ansible ansible_ssh_pass=Senha123

[nomeGrupo:nomeVars]
servidor_exemplo1
servidor_exemplo2
</code></pre>

```sh
# WINDOWS

[nomeGrupo:nomeVars]
ansible_port=port
ansible_connection=winrm
ansible_winrm_server_cert_valiation=ignore
```

***

#### <mark style="color:yellow;">**Palavras-chaves do Ansible e os seus usos**</mark>

`become:` É um booleano e indica se a task será executada com ou sem privilégios administrativos.

`hosts:` Indica para qual grupo ou host do arquivo de inventário o Ansible vai aplicar as tarefas.

`tasks:` Lista principal de comandos a serem executados nos hosts selecionados.

`with_items:` No with\_items, passamos o nome **(name)** dos pacotes das tasks que desejamos instalar, copiar ou qualquer outra ação.

* O parâmetro **with\_items** fica no nível da task, ou seja, não faz parte da task.&#x20;

`item:` Palavra reservada do Ansible e com ela conseguimos fazer uma referência a todos os elementos inclusos em uma lista de dependências.

***
