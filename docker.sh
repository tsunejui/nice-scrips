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

function screen () { #cmd Connect into docker's vm
    # src: https://stackoverflow.com/questions/63445657/why-i-am-getting-screen-is-terminating-error-in-macos/63595817#63595817
	docker run -it --privileged --pid=host debian nsenter -t 1 -m -u -n -i sh
}

function df () { #cmd Show docker disk usage
	# src: https://docs.docker.com/engine/reference/commandline/system_df/
	docker system df
}

function prune () { #cmd Remove all unused containers, networks, images
	# src: https://docs.docker.com/engine/reference/commandline/system_prune/
	docker system prune -a
}

function sort-images () { #cmd sort your docker images by size
	# src: https://stackoverflow.com/questions/58065875/how-to-sort-my-docker-images-by-size-with-docker-images-command
	docker images --format "{{.ID}}\t{{.Size}}\t{{.Repository}}" | sort -k 2 -h
}

function find-id () { #cmd inspect docker id
	docker ps -q | xargs docker inspect --format '{{.State.Pid}}, {{.Id}}, {{.Name}}, {{.GraphDriver.Data.WorkDir}}' | grep $@
}

if [ $# -eq 0 ] ; then
	usage
else
	export COMPOSE_HTTP_TIMEOUT=600
	CMD=$1
	shift
	$CMD $@
fi