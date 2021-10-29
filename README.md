# Shell Scripts

## catatudo.sh

A execução deste script analisará o host em que for executado, trazendo informações de hardware, softwares, sistema instalados com suas versões, serviços em execução, portas de comunicação abertas internamente, containers docker em execução ou não, imagens dockers, usuários existentes, usuários logados, processos e carga de sistema.

## Como usar?

Em seu terminal Linux:

```
sh catatudo.sh > $(hostname).md
```

O com isto, teremos um relatório em um arquivo markdown com o nome do host com as informações extraídas do sistema.
