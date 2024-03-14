---
description: >-
  Playbook simples para instalar o servidor web Apache em um conjunto de
  servidores.
---

# Hands-on

### <mark style="color:red;">Preparação do ambiente</mark>

Certifique-se de ter o Ansible instalado em sua máquina local. Você pode fazer isso seguindo as instruções na documentação oficial do Ansible.

***

### <mark style="color:red;">Execução da Playbook</mark>

{% tabs %}
{% tab title="Inventário" %}
Crie um arquivo chamado `inventory.ini` e adicione os endereços IP dos servidores onde deseja instalar o Apache. Por exemplo:

```bash
vim inventory.ini
```

```ini
[servidores_web]
192.168.0.10
192.168.0.11

```

***
{% endtab %}

{% tab title="Playbook" %}
Crie um arquivo chamado `install_apache.yaml` com o seguinte conteúdo:

```yaml
---
- name: Instalar e iniciar o serviço Apache
  hosts: servidores_web
  become: yes  # Permite executar comandos como usuário root

  tasks:
    - name: Instalar o Apache
      yum:
        name: httpd
        state: present

    - name: Iniciar o serviço Apache
      service:
        name: httpd
        state: started
        enabled: yes  # Garante que o Apache seja iniciado

```

***
{% endtab %}

{% tab title="Execução" %}
1. Abra um terminal e navegue até o diretório onde você salvou os arquivos `inventory.ini` e `install_apache.yaml`.&#x20;
2. Em seguida, execute o Playbook usando o comando `ansible-playbook`:

```bash
ansible-playbook -i inventory.ini install_apache.yaml
```

* O Ansible irá conectar-se aos servidores listados no arquivo de inventário, instalar o Apache e iniciar o serviço.

***
{% endtab %}
{% endtabs %}

***

### <mark style="color:red;">Verificar se o Apache está funcionando</mark>

1. Após a execução do Playbook, verifique se o Apache está funcionando corretamente em cada servidor acessando seus endereços IP em um navegador da web.&#x20;
2. Você deve ver a página padrão do Apache se a instalação foi bem-sucedida.
