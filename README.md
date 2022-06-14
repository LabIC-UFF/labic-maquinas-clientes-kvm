# maquinas-clientes


## Parte 0: configuração do host com Ubuntu 22.04 server

1. Instale o Ubuntu 22.04 server
   * Utilize DHCP ou IP estático na instalação
   * Atualize o instalador (via snap) durante a instalação
   * Instale o driver na NVIDIA durante a instalação (se possível)
1. Após instalação, ajuste a senha de root
   * `sudo su`
   * `passwd`
1. Configure o SSH para acesso remoto de root
   * Edite: `/etc/ssh/sshd_config`
      -  Modifique: `#PermitRootLogin prohibit-password` para `PermitRootLogin yes`
1. Instale os drivers da NVIDIA através do ubuntu
   * `sudo ubuntu-drivers install nvidia`
1. Execute o comando `nvidia-smi`
   * Caso não funcione, reinicie, e tente novamente. Só continue quando funcionar.


## Parte 1-3: Configuração Multipass + libvirt + ufw + port forwarding

> O objetivo é configurar o hospedeiro (host) com Multipass e biblioteca libvirt, oferecendo maior controle das VMs convidadas (guests), também configurando firewall ufw com encaminhamento de portas via nat.

### Base Técnica
Para essa parte, considere os três textos de referência:
- https://multipass.run/docs/using-libvirt
- https://www.arubacloud.com/tutorial/how-to-manage-and-forward-ports-with-ufw-on-ubuntu-18-04.aspx
- FUNDAMENTAL: https://hackernoon.com/understanding-ufw-8d70d5d8f9d2
- FUNDAMENTAL: https://www.cyberciti.biz/faq/kvm-forward-ports-to-guests-vm-with-ufw-on-linux/

### Parte 1/3: configurando Multipass com libvirt

1. Instale o libvirt daemon
   * `sudo apt install libvirt-daemon-system`
1. Instale o Multipass
   * `sudo snap install multipass`
1. Conecte o libvirt com multipass
   * `sudo snap connect multipass:libvirt`
1. Teste o multipass (I)
   * `multipass list`
   * Se der erro, verifique antes de prosseguir!
1. Pare o multipass e configure o libvirt
   * `multipass stop --all`
   * `sudo multipass set local.driver=libvirt`
1. Teste o multipass (II)
   * `multipass launch`
   * `multipass list`
   * Se der erro, verifique antes de prosseguir!
1. Teste o virsh e apague a vm de teste
   * `virsh list`
   * `multipass delete NOME_VM --purge`
1. Ajuste o serviço de DHCP do libvirt
   * `virsh net-edit default`
      - Rede: `10.1.0.0/24`
      - Intervalo: `10.1.0.1` - `10.1.0.10`
   * `virsh net-destroy default`
   * `virsh net-start default`
   * `ip addr` (verifique `virbr0`)
   

> Observação: libvirt+multipass NÃO suporta modo bridge (até 2022 pelo menos...)! O comando `multipass networks` deve dar erro! Portanto, o DHCP será necessário para as VMs, bem como o encaminhamento de portas com NAT para acesso externo.

### Parte 2/3: lançando a VM personalizada com NFS+LDAP

1. Monte o `/home` via NFS do servidor `192.168.91.2` na hospedeira
   * Edite `/etc/fstab` e adicione:
      - > 192.168.91.2:/home                          /home           nfs     soft,intr,async,cto,bg,auto,retry=2
   * `mount /home`
1. Copie a chave SSH pública do multipass para o usuário `ubuntu` (padrão de todas VMs)
   * `ssh-keygen -y -f /var/snap/multipass/common/data/multipassd/ssh-keys/id_rsa >> my_id_rsa.pub`
   * `cat my_id_rsa.pub >> /home/ubuntu/.ssh/authorized_keys`
1. Desmonte o `/home` na hospedeira
   * `umount /home`
1. Edite o arquivo `labic-auto-launch.sh`
   * Ajuste a linha `CPUS=16`
   * Ajuste a linha `MEM=15G`
   * Ajuste demais linhas de configuração
1. Lance a máquina convidada `mpvirtual01` (ajuste o nome)
   * `./labic-auto-launch.sh mpvirtual01`
   * **Verifique atentamente se existem erros no processo!**
1. Verifique o acesso à máquina `mpvirtual01` criada
   * `multipass list`
      - `multipass shell mpvirtual01`
      - `exit` para sair
   * `virsh list`
      - `virsh console mpvirtual01`
      - `Ctrl`+`]` para sair
1. Verifique o IP da máquina criada
   * `virsh net-dhcp-leases default`

### Parte 3/3: configurando o firewall ufw e encaminhamento de portas

1. Instale o `ufw`
   * `sudo apt install ufw`
1. Libere o acesso ao `ssh` **(IMPORTANTE!)**
   * `sudo ufw allow ssh`
   * `sudo ufw allow OpenSSH`
1. Verifique os acessos liberados
   * `ufw show added`
   * `ufw status`
   * Se não tiver SSH liberado, não prossiga!
1. Habilite o firewall `ufw`
   * `ufw enable`
1. Verifique os status gerais e defaults
   * `ufw status verbose`
      - Padrão esperado: `Default: deny (incoming), allow (outgoing), deny (routed)`
1. Libere o acesso de encaminhamento `NEW` para a VM convidada (guest) no libvirt
   * Crie o arquivo de hook `qemu` **(precisa ser esse nome!)**
      - Observação: consideramos rede convidada `10.1.0.0/24` e rede externa do hospedeiro `192.168.0.0/16`
   * `nano /etc/libvirt/hooks/qemu`
      - > #!/bin/bash
      - > v=$(/sbin/iptables -L FORWARD -n -v | /usr/bin/grep 192.168.0.0/16 | /usr/bin/wc -l)
      - > [ $v -le 2 ] && /sbin/iptables -I FORWARD 1 -o virbr0 -m state -s 192.168.0.0/16 -d 10.1.0.0/24 --state NEW,RELATED,ESTABLISHED -j ACCEPT
      - > exit 0
   * Dê permissão de execução no script `qemu`
      - `chmod +x /etc/libvirt/hooks/qemu`
1. Crie uma regra de encaminhamento NAT para a porta desejada (no caso, 2222 do hospedeiro para 22 no convidado)
   * Considere a interface hospedeira `enp2s0` e IP convidado `10.1.0.6`
   * Edite o arquivo: `/etc/ufw/before.rules`
      - Escreva ANTES do `*filter`:
      - > *nat
      - > :PREROUTING ACCEPT [0:0]
      - > -A PREROUTING -i enp2s0 -p tcp --dport 2222 -j DNAT --to-destination 10.1.0.7:22
      - > COMMIT
1. Recarregue o firewall ou reinicie
    * `bash /etc/libvirt/hooks/qemu`
    * `ufw reload`
    * OU
    * `reboot` (somente se achar necessário... deveria funcionar sem isso!)
1. Teste acesso externo fora do hospedeiro
    * `ssh usuario@hospedeiro -p 2222`
    * Deveria cair dentro da VM convidada no hospedeiro
    * Caso não funcione, volte ao hospedeiro e confira as operações
        - `ssh root@hospedeiro` (cenário básico que deveria estar funcionando)
    * Verifique mais detalhes em: https://www.cyberciti.biz/faq/kvm-forward-ports-to-guests-vm-with-ufw-on-linux/
1. Parabéns! A VM está acessível externamente!

### Parte 4: configurando passthrough do driver NVIDIA para VM convidada

TODO.

No momento, estamos evitando passthrough e utilizando nativamente as GPUs, para evitar (MAIS) problemas. Mas é possível aparentemente.

Algumas dicas, caso queira tentar:
- https://github.com/lateralblast/kvm-nvidia-passthrough

