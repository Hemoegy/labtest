#!/bin/bash
PS3='Choose your NGROK Region (type 1 or 2 then Enter): '
foods=("US" "AP")
select fav in "${foods[@]}"; do
    case $fav in
        "US")
            wget https://raw.githubusercontent.com/cloudshell123/labtest/master/ngrok-us-linux.sh
            chmod +x ngrok-us-linux.sh    
	    ./ngrok-us-linux.sh 33899
            break
            ;;
        "AP")
            wget https://raw.githubusercontent.com/cloudshell123/labtest/master/ngrok-ap-linux.sh
            chmod +x ngrok-ap-linux.sh    
	    ./ngrok-ap-linux.sh 33899
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done
