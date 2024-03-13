# Comandos

#### Executando comandos através de modulos em um IP especifico

**Linux** ansible ip -m(modulo) -u(usuario) -k(Key) ansible ip -m(modulo) -u(usuario) --ask-pass **Windows** ansible nomeGrupo -m apt win\_comando --ask-pass

***

#### Executando comandos em um grupo de hosts

**Linux** ansible nomeGrupo -m ping -u ansible --ask-pass **Windows** ansible nomeGrupo -m apt win\_ping --ask-pass

***

#### Instalando aplicações através do ansible

**Linux** ansible nomeGrupo -a "sudo apt-get install apache2" -u ansible --ask-pass --become **Windows** ansible nomeGrupo -m apt win\_chocolatey --ask-pass

***

#### Configuração arquivos de inventario

**LINUX** ansible.cfg

```conf
[defaults]
interpreter_python = auto_legacy_silent
sudo_user = root
```

***

#### ansible-vault

**Para encryptar a senha criada dentro do arquivo de hosts**

```conf
ansible-vault encrypt hosts
```

**Executando o camando utilizando o arquivo encrypt**

```conf
ansible nomeGrupo -m ping --ask-vault-pass
```

**Para editar o arquivo encryptado com o vault**

```conf
ansible-vault edite arquivo
```

**Acessando através de uma porta diferente da padrão**

```conf
[servidor_exemplo1]
nome_variavel ansible_ssh_host=ip ansible_ssh_user=user ansible_ssh_pass=key ansible_ssh_port=port
```

**Para desincryptar a senha criada dentro do arquivo**

```conf
ansible-vault encrypt arquivo
```





### Comando restart no Zabbix

```conf
curl -s -k -X POST -H "Authorization: Bearer jHPd236UT4RlqALnrzSQk9DWujBAe7" -H "Content-Type: application/json" http://awx.endpoint.com/api/v2/job_templates/id_templante/launch/
```

Versões usadas Nesse curso usamos o Ansible na versão 2.x com Python na versão 2.x. Aconselhamos instalar o ambiente no seu computador o mais perto possível disso para evitar erros de incompatibilidade.
