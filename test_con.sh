#!/bin/bash

# Função para limpar a tela
clear_screen() {
    clear
}

# Função para mostrar o menu principal
show_main_menu() {
    clear_screen
    echo "=================================================="
    echo "1. Teste com local conhecido"
    echo "2. Teste de locais"
    echo "0. Sair"
    echo "=================================================="
    
    read -p "Escolha uma opcao (0-2): " op
    
    case $op in
        1)
            test_ping1
            read -p "Pressione Enter para continuar"
            show_main_menu
            ;;
        2)
            test_connection2
            read -p "Pressione Enter para continuar"
            show_main_menu
            ;;
        0)
            echo "Encerrando..."
            exit 0
            ;;
        *)
            echo "Opcao invalida"
            sleep 2
            show_main_menu
            ;;
    esac
}

# Função para testar ping em um local específico
test_ping1() {
    clear_screen
    read -p "Insira a base EX: 192.168 " base
    read -p "Insira o local: " local
    
    # Criar nome do arquivo de log com data e hora
    timestamp=$(date +"%d-%m-%Y_%H-%M")
    logfile="ping_log_${local}_${timestamp}.log"
    
    # Adicionar cabeçalho ao arquivo de log
    echo "Teste de ping realizado em $(date)" > "$logfile"
    echo "Local: $local" >> "$logfile"
    echo "------------------------------------------------" >> "$logfile"
    
    for i in $(seq 1 254); do
        ip="${base}.${local}.${i}"
        echo -n "Testando $ip"
        
        # Usar ping com timeout de 1 segundo e apenas 1 pacote
        if ping -c 1 -W 1 "$ip" > /dev/null 2>&1; then
            # Tentar resolver o nome do host
            hostname=$(host "$ip" 2>/dev/null | grep "domain name pointer" | cut -d " " -f 5)
            
            if [ -z "$hostname" ]; then
                hostname="Sem nome registrado"
            else
                # Remover o ponto final que o comando host adiciona
                hostname=${hostname%.}
            fi
            
            echo -e " - \e[32mConectado - Host: $hostname\e[0m"
            echo "$ip - Conectado - Host: $hostname" >> "$logfile"
        else
            echo -e " - \e[31mDesconectado\e[0m"
            echo "$ip - Desconectado" >> "$logfile"
        fi
    done
    
    echo -e "\nResultados salvos em: \e[33m$logfile\e[0m"
}

# Função para testar ping em várias subredes
test_connection2() {
    clear_screen
    read -p "Insira a base EX: 192.168 " base
    
    # Criar nome do arquivo de log com data e hora
    timestamp=$(date +"%d-%m-%Y_%H-%M")
    logfile="ping_subredes_${base}_${timestamp}.log"
    
    # Adicionar cabeçalho ao arquivo de log
    echo "Teste de ping em subredes realizado em $(date)" > "$logfile"
    echo "Base: $base" >> "$logfile"
    echo "------------------------------------------------" >> "$logfile"
    
    for i in $(seq 1 254); do
        ip="${base}.${i}.1"
        echo -n "Testando $ip"
        
        if ping -c 1 -W 1 "$ip" > /dev/null 2>&1; then
            echo -e " - \e[32mConectado\e[0m"
            echo "$ip - Conectado" >> "$logfile"
        else
            echo -e " - \e[31mDesconectado\e[0m"
            echo "$ip - Desconectado" >> "$logfile"
        fi
    done
    
    echo -e "\nResultados salvos em: \e[33m$logfile\e[0m"
}

# Iniciar o programa
show_main_menu