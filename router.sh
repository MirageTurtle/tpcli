#!/usr/bin/env bash
trap "exit 1" TERM
TOP_PID=$$


ROUTER_IP="192.168.1.1"
HEADER="User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/113.0.0.0 Safari/537.36"

encrypt() {
    a=$1
    b=RDpbLfCPsJZ7fiv
    c=yLwVl0zKqws7LgKPRQ84Mdt708T1qQ3Ha7xv3H7NyU84p21BriUWBU43odz3iP4rBL3cD02KZciXTysVXiV8ngg6vL48rPJyAUw0HurW20xqxv9aYb4M9wK1Ae0wlro510qXeU07kV57fQMc8L6aLgMLwygtc0F10a0Dg70TOoouyFhdysuRMO51yY5ZlOZZLEal1h0t9YQW0Ko7oBwmCAHoic4HYbUyVeU3sfQ1xtXcPcf1aT303wAQhv66qzW

    d=''
    f=${#a}
    g=${#b}
    h=${#c}
    if [[ f -gt g ]]; then
	e=$f
    else
	e=$g
    fi
    for i in $(seq 0 $((e-1))); do
	m=187
	k=187
	if [[ $i -ge $f ]]; then
	    m=${b:$i:1}
	    m=$(printf %d \'"$m")
	elif [[ $i -ge $g ]]; then
	    k=${a:$i:1}
	    k=$(printf %d \'"$k")
	else
	    k=${a:$i:1}
	    k=$(printf %d \'"$k")
	    m=${b:$i:1}
	    m=$(printf %d \'"$m")
	fi
	idx=$(((k ^ m) % h))
	d+=${c:$idx:1}
    done
    echo -n $d
}

login() {
    read -r -s -p "Please input administrator password: " password
    password=$(encrypt "$password")
    data="{\"method\":\"do\",\"login\":{\"password\":\"$password\"}}"
    resp=$(curl -s -X POST -H "$HEADER" -d "$data" $ROUTER_IP)
    error_code=$(echo "$resp" | jq ".error_code" | xargs echo)
    if [[ error_code -ne 0 ]]; then
	# echo "ERROR"
	kill -s TERM $TOP_PID
    else
	stok=$(echo "$resp" | jq ".stok" | xargs echo)
	echo -n "$stok"
    fi
}

redirect_query() {
    stok=$1
    data='{"firewall":{"table":"redirect"},"method":"get"}'
    resp=$(curl -s -X POST -H "$HEADER" -d "$data" "$ROUTER_IP/stok=$stok/ds")
    error_code=$(echo "$resp" | jq ".error_code" | xargs echo)
    if [[ error_code -ne 0 ]]; then
	# echo -n "ERROR"
	kill -s TERM $TOP_PID
    fi
    redirect_list=$(echo "$resp" | jq ".firewall|.redirect")
    echo "$redirect_list"
}

redirect_add() {
    stok=$1
    redirect_list=$(redirect_query "$stok")
    name=$(echo "$redirect_list" | jq ".[]|keys[]" | sed -E /'^"redirect_[0-9]+"$'/s/'^"redirect_([0-9]+)"$'/'\1'/ | sort -n -r | head -n1 | xargs -I{} echo {}+1 | bc | xargs -I{} echo redirect_{})
    read -r -p "Source port(router port): " src_dport
    # echo -n "Source port(router port): "
    # read -r src_dport
    read -r -p "Destination IP: " dest_ip
    # echo -n "Destination IP: "
    # read -r dest_ip
    read -r -p "Destination Port: " dest_port
    # echo -n "Destination Port: "
    # read -r dest_port
    data="{\"firewall\":{\"table\":\"redirect\",\"name\":\"$name\",\"para\":{\"proto\":\"all\",\"src_dport_start\":$src_dport,\"src_dport_end\":$src_dport,\"dest_ip\":\"$dest_ip\",\"dest_port\":$dest_port}},\"method\":\"add\"}"
    resp=$(curl -s -X POST -H "$HEADER" -d "$data" "$ROUTER_IP/stok=$stok/ds")
    error_code=$(echo "$resp" | jq ".error_code" | xargs echo)
    if [[ error_code -ne 0 ]]; then
	# echo -n "ERROR"
	kill -s TERM $TOP_PID
    fi
    echo "Success."
}

redirect_del() {
    stok=$1
    # echo -n "Name: "
    # read -r name
    read -r -p "Name: " name
    data="{\"firewall\":{\"name\":[\"$name\"]},\"method\":\"delete\"}"
    resp=$(curl -s -X POST -H "$HEADER" -d "$data" "$ROUTER_IP/stok=$stok/ds")
    error_code=$(echo "$resp" | jq ".error_code" | xargs echo)
    if [[ error_code -ne 0 ]]; then
	# echo -n "ERROR"
	kill -s TERM $TOP_PID
    fi
    echo "Success."
}

redirect_menu() {
    stok=$(login)
    menu="\n1. Query\n2. Add\n3. Delete"
    echo -e "$menu"
    read -r -p "What do you want to do?" option
    case $option in
	1)
	    redirect_query "$stok"
	    return
	    ;;
	2)
	    redirect_add "$stok"
	    return
	    ;;
	3)
	    redirect_del "$stok"
	    return
	    ;;
	*)
	    echo "Please input correct number."
	    exit 2
	    ;;
    esac
}

if ! command -v jq > /dev/null 2>&1; then
    echo "Install jq first please."
    exit 4
fi
redirect_menu
