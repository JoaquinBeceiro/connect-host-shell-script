#!/bin/sh

# USAGE:
# execute script ./connectHost.sh or ./connectHost.sh ui [Terminal]
# select host and connect
# EXAMPLE: ./connectHost.sh ui iTerm

ui=${1:-none}
term=${2:-Terminal}

if [ $ui = "none" ]; then
    printf "\n\e[31m*************************************\n"
    printf "*      WELCOME TO SSH CONNECT       *\n"
    printf "*************************************\n"
    printf "\n\e[32m"

    echo "Select a domain from list or create new one"

    options=($(cat ~/.ssh/config | grep "Host " | sed "s/Host //g" | sed "s/ //g" | sed -e 's/^/"/g' -e 's/$/"/g' | tr '\n' ' '))

    echo "*************************************"
    echo "*         Choose an option:         *"
    echo "*************************************"

    select opt in "${options[@]}"; do

        if [ "$opt" = "" ]; then
            echo "No option selected. Bye bye"
            exit
        fi

        temp="${opt%\"}"
        temp="${temp#\"}"
        HOST=$temp
        printf "\n\e[31m"
        echo $HOST selected...
        printf "\n\e[32m"
        break
    done

    bash -c 'ssh '$HOST
fi

function hostPrompt() {
osascript <<EOT
    tell app "System Events"
    choose from list {$options} with title "SSH CONNECT" with prompt "Select HOST" OK button name "OK"
    end tell
EOT
}

function connectSSH() {
    if [ $term = "Terminal" ]; then
osascript <<EOT
    tell application "Terminal"
        activate
        set shell to do script "ssh $1" in window 1
    end tell
EOT
    else
osascript <<EOT
    tell application "$term"
        set win to (create window with default profile)
        set sesh to (current session of win)
        tell sesh to write text "ssh $1"
    end tell
EOT
    fi
}

if [ $ui = "ui" ]; then
    options=($(cat ~/.ssh/config | grep "Host " | sed "s/Host //g" | sed "s/ //g" | sed -e 's/^/"/g' -e 's/$/"/g' | tr '\n' ',' | rev | cut -c 2- | rev))

    # GET HOST
    selectedHost="$(hostPrompt)"
    if [ $selectedHost = false ]; then
        exit
    fi

    $(connectSSH $selectedHost)

fi