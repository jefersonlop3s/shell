#!/bin/bash
## Author: Jeferson Lopes <jefersonlopes.br@gmail.com>
## Data: 04/02/2021
## Análise de Hosts Linux

# Execução como root, verificação de usuário
echo "Data de Execução: `date +'%d/%m/%Y %H:%M'` "
echo "Host: "`hostname`

if [ $(id -u) != 0 ] ; then
    echo "Para execução deste script, deve-se estar logado como super-usuário"
    exit 1 ;
fi


if [ -f "/usr/bin/apt-get" ] ; then
echo "Iniciando verificação de gerenciador de pacotes de software..."
    echo "APT encontrado, Debian based'... instalando utilitários necessários "
    apt -y install pciutils lsscsi usbutils util-linux nilfs-tools net-tools nmap iproute2 ca-certificates apt-transport-https curl software-properties-common neofetch parted dmidecode
    echo "Utilitários de sistema instalados, iniciando próxima verficação..."
    echo " "
    echo "Verificando atualizações de sistema" 
    apt update | egrep -v '(Fail|Faul|Fal)'
    echo " "
    echo "**Lista de pacotes a atualizar:** "
    apt list --upgradable
    echo " "
elif [ -f "/usr/bin/yum" ] ; then
    echo "Sistema não baseado em Debian, iniciado próxima verificação..."
        echo " "
        echo "YUM/DNF encontrado. RedHat based... instalando utilitários necessários "
        yum -y install pciutils lsscsi usbutils util-linux nilfs-utils net-tools nmap iproute ca-certificates curl neofetch parted dmidecode
        echo "Utilitários de sistema instalados, iniciando próxima verficação..."
        echo " "
        echo "Verificando atualizações de sistema" 
        echo " "
        echo "**Lista de pacotes a atualizar:** "
        yum check-update
        echo " "
else
        echo "Não foi possível verificar este sistema. Verifique se sua Distribuição é baseada em Debian ou RedHat ou modifique este script"
        echo " "
fi
echo " "
neofetch
echo "#Análise de host Linux: "`hostname`" - " 
echo " "
# Hostname
echo "**Hostname:** " `hostname || cat /etc/hostname`
echo " "

# Distribuição
echo "**Sistema Operacional:**" 
echo " "
if [ -f "/etc/redhat-release " ] ; then 
    cat /etc/redhat-release 
elif [ -f "/etc/os-release" ] ; then 
    egrep '(NAME|VERSION)' /etc/os-release | grep -v '_' 
elif [ -f "/etc/lsb-release" ] ; then
    cat /etc/lsb-release 
else
    lsb_release 
fi

echo " "
# Kernel
echo "**Kernel:** " `uname -r`
# Arquitetura
echo "**Arquitetura:** " `uname -m`
echo " "
echo "________________________________________________________________________________ "
echo " "

## Rede
echo "## Configurações de Rede: "
echo " "
# Interfaces
echo "**Principais Interfaces de Rede:** "
ip link | grep UP | awk '{print $2}' | egrep -v '(lo|vi|br|do|ve)' | egrep '(eth|en|wl)' ||  ifconfig | grep flags | egrep -v '(lo|vi|br|do|ve)' | awk '{print $1}' | egrep '(eth|en|wl)'
echo " "
# IP Address
echo "**Endereços IPs:** "
ip address show | grep inet | awk '{print $2}' | egrep -v '(lo|vi|br|do|ve)' | egrep '(eth|en|wl)' ||  ifconfig | grep 'inet' | awk '{print $2}' |  egrep -v '(lo|vi|br|do|ve)' | egrep '(eth|en|wl)'
echo " "
# MAC Address
echo "**MAC Address:** " 
ip link show | grep ether -B 1 | awk 'NR % 2 {print $2; getline; print $2}' | awk 'ORS=NR%2?" ":"\n"' | egrep -v '(lo|vi|br|do|ve)' | egrep '(eth|en|wl)' || ifconfig | grep ether | awk '{print $2}' | egrep -v '(lo|vi|br|do|ve)' | egrep '(eth|en|wl)'
echo " "
# Route | Gateway
echo "**Gateway padrão:** " `ip route | egrep -v '(lo|vi|br|do|ve)'`
echo " "
echo "Rotas: " 
route -n || netstat -r -n
echo " "
# DNS Servers
echo "**DNS (/etc/resolv.conf):** " 
grep "nameserver" /etc/resolv.conf
echo " "
echo "**DNS Externo:** " `dig +short myip.opendns.com @resolver1.opendns.com`
echo " "
echo "**DNS's registrados:** " 
HSTN=`hostname`
dig $HSTN
echo " "
# Hosts
echo "**Hosts:** " 
cat /etc/hosts | egrep -v '(v6|ipv6|V6|IPV6|ip6-)'
echo " "
echo "________________________________________________________________________________ "
echo " "

# Portas abertas
echo " "
echo "** Portas abertas no host: ** "
nmap -sTU -O localhost
echo " "
# Hardware
# Processador
echo "**Processador:** "
dmidecode -t processor | egrep 'Processor|(Version):|(Max|Current) Speed:' | egrep -v "Type"  
echo "**Modelo:** " `cat /proc/cpuinfo | head -n 31 | grep 'model name'  | cut -d : -f2`
echo "**Velocidade atual:** " `cat /proc/cpuinfo | head -n 31 | grep 'cpu MHz' | cut -d : -f2 | cut -d . -f1` "MHz"
#echo "Cache: " `cat /proc/cpuinfo | head -n 31 | grep 'cache size' | cut -d : -f2` 
echo " "
echo "**Vulnerabilidades de HW na fabricação do Processador :** "
cat /proc/cpuinfo | grep bugs | awk 'END {print}'
echo " "
# Memória
echo "**Memória:** "
dmidecode -t memory | egrep 'Memory (Array|Device)|Maximum Capacity:|Number Of Devices:|Size:|Type:.*[A-MO-Z]'
echo " "
# BIOS
echo "**BIOS:** "
dmidecode -t bios | egrep 'BIOS I|Release|(Vendor|Version):'
echo " "
# Placa-mãe:
echo "**Placa-mãe:** "
dmidecode -t baseboard | egrep 'Base Board|(Manufacturer|Product Name):'
echo " "
# Placas adicionais:
echo "**Placas adicionais e periféricos:** "
echo "PCI"
lspci; 
echo "USB"
lsusb
echo " "
# Discos e partições
echo " "
echo "**Discos:** "
dblock=`fdisk -l | grep Disco | cut -d" " -f2 | cut -d"/" -f3| sed 's/://g'| egrep '(sd|hd|fd|mmcblk|nvme)'`
for parts in $dblock 
    do 
        echo "Disco :" $parts
        size=`parted /dev/$parts print | grep $parts | cut -d" " -f3 `
        type=`parted /dev/$parts print | egrep -v '(File|Disk|model|Sector|Partition)' | cut -d" " -f14`
        echo " "" ""  "" - Tamanho: " $size 
        echo " "" ""  "" - Tipo: " $type
        echo " "
    done
echo " "
echo "**Pontos de montagem:** "
echo "/etc/fstab"
cat /etc/fstab | egrep -v '(See|fstab|devices)' 
echo " "
echo "df -h"
df -h
echo "________________________________________________________________________________ "
echo " "
## Sistema
# Tempo de Sistema e carga
echo "## Sistema"
echo "**Uptime - Tempo, carga de sistema:** "
uptime
echo " "
# Módulos do Kernel
echo "**Drivers/Módulos de Sistema/Kernel carregados:** "
lsmod
echo " "
# Mémória e Swap
echo "**Memória RAM e Swap em uso :** "
free -m
echo " "
# Status de Serviços 
echo "**Serviços de Sistema:** "
echo "**Estatus dos serviços**"
systemctl status --no-pager 
echo " "
echo "**Serviços ativos:** "
systemctl list-units --all --state=active --type=service --no-pager || rc-status
echo " "
# Processos em execução
echo "**Processos, serviços em execução:** "
echo "Verficação no uso de Prioridades do agendador: "
ps -aelfx
echo " "
echo "Verificação no uso de CPU e Memória"
ps -aeufx
echo " "
echo "________________________________________________________________________________ "
echo " "
# Usuários
echo "**Usuários:** "
 echo "/etc/passwd:"
 cat /etc/passwd
 echo " "
 echo "/home:"
 ls -lha /home/
 echo " "
 echo "lastlog: "
 lastlog | grep -v "*"
 echo " "
 echo "loginctl:"
 loginctl --all --no-pager
echo " "
echo "________________________________________________________________________________ "
echo " "
# Docker: Verificação de status, containers, imagens, networks, volumes e processos:
if [ -f /usr/bin/docker  ] ; then 
    echo "**Docker: Verificação de status, containers, imagens, networks, volumes e processos:** "
    echo "**Imagens:** "
    docker images
    echo "**Networks: **"
    for i in $(docker network ls | awk '{print $2}' | grep -v "ID"); do docker inspect $i; done | egrep '(Name|Scope|Driver|Subnet|Containers)'
    echo "**Volumes:** "
    docker volume inspect $(docker volume ls | awk '{print $2}' | egrep -v "VOLUME")
    echo "**Containers: **"
    docker ps -a 
    echo "**Analise dos containers: **"
    for i in $(docker ps -a | awk '{print $1}' | grep -v 'CONTAINER'); do docker inspect $i; done | egrep -v '("",|null)' | egrep '(Args|StartedAt|FinishedAt|Status|Image|Name|NetworkMode|PortBindings|ExposedPorts|tcp|udp|HostIp|HostPort|Env|=|Mounts|User|IPAddress|Source|Destination)'  
else
    echo "**Não existem processos Docker neste sistema**"
fi
echo "________________________________________________________________________________ "
echo "Análises Finalizadas "
