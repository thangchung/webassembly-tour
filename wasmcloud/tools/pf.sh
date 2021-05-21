#!/bin/bash

readonly PROGNAME=$(basename $0)

port="${1}"
foreground="false"
stop="false"
environment="default"
quiet="false"
hostport="$1"

usage="${PROGNAME} <port> [-h] [-s] [-f] [-e] [-hp] -- Forwards a docker-machine port so that you can access it locally

where:
    -h, --help		Show this help text
    -s, --stop 		Stop the port forwarding process
    -f, --foreground	Run the docker-machine ssh client in foreground instead of background
    -e, --environment	The name of the docker-machine environment (default is default)
    -q, --quiet		Don't print anything to the console, not even errors    

examples:
	# Port forward port 8047 in docker-machine environment default
	\$ ${PROGNAME} 8047

	# Port forward docker port 8047 to host port 8087 in docker-machine environment default
	\$ ${PROGNAME} 8087:8047

	# Port forward port 8047 in docker-machine dev
	\$ ${PROGNAME} 8047 -e dev

	# Runs in foreground (port forwarding is automatically stopped when process is terminated)
	\$ ${PROGNAME} 8047 -f

	# Stop the port forwarding for this port
	\$ ${PROGNAME} 8047 -s"

if [ $# -eq 0 ]; then
	echo "$usage"
	exit 1
fi

if [ -z "$1" ]; then
    echo "You need to specify the port to forward" >&2
    echo "$usage"
    exit 1
fi

if [ "$#" -ne 0 ]; then
    while [ "$#" -gt 0 ]
    do
		case "$1" in
		-h|--help)
			echo "$usage"
			exit 0
			;;
		-f|--foreground)
			foreground="true"
			;;		
        -s|--stop)
            stop="true"
            ;;
        -e|--environment)
            environment="$2"
            ;;
        -q|--quiet)
            quiet="true"
            ;;
		--)
			break
			;;
		-*)
			echo "Invalid option '$1'. Use --help to see the valid options" >&2
			exit 1
			;;
		# an option argument, continue
		*)  ;;
		esac
		shift
    done
fi

pidport() {
	lsof -n -i4TCP:$1 | grep --exclude-dir={.bzr,CVS,.git,.hg,.svn} LISTEN
}

# Check if port contains ":", if so we should split
if [[ $port == *":"* ]]; then	
	# Split by :
	ports=(${port//:/ })
	if [[ ${#ports[@]} != 2 ]]; then
		if [[ $quiet == "false" ]]; then 
			echo "Port forwarding should be defined as hostport:targetport, for example: 8090:8080"
		fi
		exit 1
	fi


	hostport=${ports[0]}
	port=${ports[1]}
fi


if [[ ${stop} == "true" ]]; then
	result=`pidport $hostport`

	if [ -z "${result}"  ]; then
		if [[ $quiet == "false" ]]; then
			echo "Port $hostport is not forwarded, cannot stop"
		fi		
		exit 1
	fi 

	process=`echo "${result}" | awk '{ print $1 }'`
	if [[ $process != "ssh" ]]; then
		if [[ $quiet == "false" ]]; then 
			echo "Port $hostport is bound by process ${process} and not by docker-machine, won't stop"
		fi
		exit 1
	fi

	pid=`echo "${result}" | awk '{ print $2 }'` &&
	kill $pid &&
	echo "Stopped port forwarding for $hostport"		
else
	docker-machine ssh $environment `if [[ ${foreground} == "false" ]]; then echo "-f -N"; fi` -L $hostport:localhost:$port && 
	if [[ $quiet == "false" ]] && [[ $foreground == "false" ]]; then
		printf "Forwarding port $port"
		if [[ $hostport -ne $port ]]; then
			printf " to host port $hostport"
		fi
		echo " in docker-machine environment $environment."
	fi
fi