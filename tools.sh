#!/bin/bash
set -e
DIR=$( cd $(dirname $0) ; pwd -P )

function usage () {
	cat <<EOS
To execute pre-defined command in containers.
Usage:
	$(basename $0) <Command> [args...]
Command:
EOS
	egrep -o "^\s*function.*#cmd.*" $DIR/$(basename $0) | sed "s/^[ \t]*function//" | sed "s/[ \t\(\)\{\}]*#cmd//" | awk '{CMD=$1; $1=""; printf "\t%-16s%s\n", CMD, $0}'
}

function zu () { #cmd solve the unpop zhuyin frame
	killall TCIM_Extension
}

if [ $# -eq 0 ] ; then
	usage
else
	export COMPOSE_HTTP_TIMEOUT=600
	CMD=$1
	shift
	$CMD $@
fi