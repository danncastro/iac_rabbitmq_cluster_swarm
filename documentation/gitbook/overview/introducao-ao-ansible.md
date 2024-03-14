# Introdução ao Ansible

### <mark style="color:red;">Instalação</mark>

{% tabs %}
{% tab title="Ubuntu" %}
1. Para instalar no Ubuntu, utilize o comando abaixo:

```bash
sudo apt-get install ansible
```
{% endtab %}

{% tab title="MacOS" %}
1. Para instalar no MacOs, instale o brew através do comando abaixo:

```bash
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

***

2. Execute o comando abaixo para instalar o Python e o Ansible:

```bash
brew install python@2 ansible@2.0
```

***

3. Após a instalação execute os comandos de validação&#x20;

```bash
python -V
```

```bash
ansible --version
```

* Devo mostrar algo parecido com a saída abaixo:

```bash
ansible --version
ansible 2.6.5
  config file = None
  configured module search path = [u'/Users/nico/.ansible/plugins/modules', u'/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/local/Cellar/ansible/2.6.5/libexec/lib/python2.7/site-packages/ansible
  executable location = /usr/local/bin/ansible
  python version = 2.7.15 (default, Oct  2 2018, 11:47:18) [GCC 4.2.1 Compatible Apple L
```
{% endtab %}

{% tab title="Windows" %}
{% hint style="warning" %}
Ansible não tem suporte para Windows.
{% endhint %}

#### <mark style="color:yellow;">Requisitos automatizar processos no Windows com Ansible</mark>

* Powershell 3++
* Netframwork 4.0
* winrm
{% endtab %}
{% endtabs %}

***

### <mark style="color:red;">O que é Ansible?</mark>

* Ansible é uma ferramenta de automação de TI de código aberto, desenvolvida pela Red Hat.
* Ela permite automatizar tarefas de provisionamento, configuração e gerenciamento de infraestrutura de TI.

***

### <mark style="color:red;">Por que Ansible?</mark>

* **Facilidade de uso**: Ansible adota uma abordagem simples e legível, baseada em YAML, facilitando a compreensão e a escrita de Playbooks.
* **Sem agentes**: Ao contrário de outras ferramentas de automação, Ansible não requer agentes em nós gerenciados, o que simplifica a implementação e a manutenção.
* **Infraestrutura como código**: Ansible permite que você defina a configuração de infraestrutura em arquivos de texto, o que facilita a automação, a manutenção e a colaboração.

***

### <mark style="color:red;">Componentes do Ansible</mark>

1. **Inventário**: Lista de hosts que o Ansible gerencia. Pode ser estático ou dinâmico e é definido em arquivos YAML ou scripts de inventário.
2. **Playbooks**: Arquivos YAML que descrevem uma série de tarefas a serem executadas em hosts gerenciados. Eles permitem a automação de processos e a definição do estado desejado da infraestrutura.
3. **Módulos**: Pequenos programas executáveis que realizam tarefas em hosts gerenciados. Ansible possui uma ampla biblioteca de módulos para realizar diversas operações, como instalação de pacotes, manipulação de arquivos, gerenciamento de serviços, etc.
4. **Roles**: Abstração de tarefas, variáveis e arquivos em uma estrutura reutilizável. Roles facilitam a organização e a reutilização de código em diferentes projetos.
5. **Handlers**: Handlers são tarefas que são executadas apenas se uma determinada condição for atendida. Eles são úteis para reiniciar serviços ou executar ações específicas somente quando necessário.
6. **Templates**: Templates são arquivos que permitem a criação de configurações personalizadas com base em modelos. Eles são usados para gerar arquivos de configuração dinâmicos, incorporando variáveis e lógica de programação.
   1. Para trabalhar com os templates, o Ansible usa um outro framework que se chama Jinja. Ele faz parte dos template engines (ou template processor). Um template engine combina um template (HTML, XML, ou qualquer outro arquivo, configurações etc) com um modelo de dados para gerar um novo documento: [Template Engine Jinja.](http://jinja.pocoo.org/)

***

### <mark style="color:red;">Como o Ansible funciona?</mark>

1. **Conexão SSH**: Ansible se comunica com os nós gerenciados via SSH, utilizando chaves públicas/privadas para autenticação. Isso garante uma comunicação segura entre o controlador Ansible e os hosts gerenciados.
2. **Execução de tarefas**: Ansible executa tarefas definidas nos Playbooks em ordem sequencial. Ele verifica o estado atual dos hosts e aplica as alterações necessárias para garantir que eles correspondam ao estado definido no Playbook.
3. **Estado desejado**: Ansible segue o paradigma de "infraestrutura como código", garantindo que o estado dos sistemas seja sempre definido conforme descrito nos Playbooks, facilitando a manutenção e a consistência da infraestrutura.

***

### <mark style="color:red;">**Estrutura básica de uma playbook**</mark>

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

{% tabs %}
{% tab title="Exemplo básico" %}
```yaml
---
- name: Configurar servidor web
  hosts: webservers
  tasks:
    - name: Instalar Apache
      yum:
        name: httpd
        state: present

    - name: Copiar arquivo de configuração do Apache
      template:
        src: /caminho/do/arquivo/template/httpd.conf.j2
        dest: /etc/httpd/conf/httpd.conf
      notify: reiniciar apache

  handlers:
    - name: reiniciar apache
      service:
        name: httpd
        state: restarted

```

***

1. Rode a playbook executando:

```sh
ansible-playbook caminho/nome_da_playbook.yml
```
{% endtab %}

{% tab title="Help" %}
#### Documentação Ansible

```bash
ansible-doc --help
```
{% endtab %}
{% endtabs %}

***

#### <mark style="color:yellow;">Estrutura básica de um arquivo de inventário:</mark>

{% tabs %}
{% tab title="Linux" %}
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
{% endtab %}

{% tab title="Windows" %}
```sh
[nomeGrupo:nomeVars]
ansible_port=port
ansible_connection=winrm
ansible_winrm_server_cert_valiation=ignore
```
{% endtab %}
{% endtabs %}

***

#### <mark style="color:yellow;">**Palavras-chaves do Ansible e os seus usos**</mark>

`become:` É um booleano e indica se a task será executada com ou sem privilégios administrativos.

`hosts:` Indica para qual grupo ou host do arquivo de inventário o Ansible vai aplicar as tarefas.

`tasks:` Lista principal de comandos a serem executados nos hosts selecionados.

`with_items:` No with\_items, passamos o nome **(name)** dos pacotes das tasks que desejamos instalar, copiar ou qualquer outra ação.

* O parâmetro **with\_items** fica no nível da task, ou seja, não faz parte da task.&#x20;

`item:` Palavra reservada do Ansible e com ela conseguimos fazer uma referência a todos os elementos inclusos em uma lista de dependências.

***

### <mark style="color:red;">Vantagens do Ansible</mark>

* **Automatização eficiente**: Ansible simplifica e automatiza tarefas de gerenciamento de infraestrutura, reduzindo o tempo e os erros humanos.
* **Redução de erros**: Automatizar tarefas com Ansible reduz a probabilidade de erros humanos, garantindo consistência e confiabilidade na configuração da infraestrutura.
* **Infraestrutura como código**: Ansible permite que você defina a configuração da infraestrutura em arquivos de texto, o que facilita a colaboração, o controle de versão e a reprodução do ambiente.
* **Grande comunidade e suporte**: Ansible possui uma comunidade ativa de usuários e desenvolvedores, oferecendo suporte, documentação e uma ampla variedade de recursos prontos para uso.

***
