# Quests

Temos o seguinte código:

```bash
- name: 'x'
  get_url: 
    url: 'https://endereco.com/x.zip'
    dest: '/tmp/y.zip'
```

O Ansible baixará o arquivo da URL definida na propriedade url, gravando-o na pasta indicada na propriedade dest, com o nome que definirmos. Alternativa correta! Na propriedade url, é definida a URL que o Ansible utilizará para baixar o arquivo, que será gravado na pasta indicada na propriedade dest, com o nome que definirmos.

***

Temos o seguinte trecho de código do Playbook:

```bash
- copy:
    src: '/var/www/wordpress/wp-config-sample.php'
    dist: '/var/www/wordpress/wp-config.php'
    remote_src: yes
  become: yes
```

Quantos erros há no trecho de código acima? 1 erro Alternativa correta! Há apenas um erro: a propriedade não é dist, é dest.

***

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

***

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
