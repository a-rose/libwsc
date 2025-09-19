SHELL = bash

image=libwsc
version=latest
container=libwsc
platform=linux/amd64

tmp=/tmp
usr_tmp=/root/tmp
shell_audio=/root/audio
export .EXPORT_ALL_VARIABLES:

DOCKER_BUILDKIT:=1


#######################################################
# Docker params
#######################################################

BUILD_PARAMS:=--ssh=default \
			  --progress=plain \
			  --network host \
			  --platform=${platform}

RUN_PARAMS:=-d \
			--name=${container} \
			--net=host \
			--platform=${platform} \
			-v ${tmp}:/tmp \
			-v ${usr_tmp}:/usr/tmp

SHELL_PARAMS:=${RUN_PARAMS} \
			-it \
			--entrypoint /bin/bash \
			-v ${PWD}:/usr/local/src/libwsc \
			-v ${shell_audio}:/opt/audio

#######################################################
# Docker targets
#######################################################

build:
	@docker build ${BUILD_PARAMS} -f Dockerfile -t ${image}:${version} .
	@docker tag ${image}:${version} ${image}:latest

run: pre-run
	@docker run ${RUN_PARAMS} ${image}-build:${version}

run-shell: pre-run
	@docker run ${SHELL_PARAMS} ${image}:${version}

push:
	@docker push ${image}:${version}

#######################################################
# Commands for interacting with a running container
#######################################################

attach:
	@docker exec -it ${container} bash
stop:
	@docker stop ${container}

kill:
	@docker kill ${container}

rm:
	@docker rm ${container}

commit:
	@echo -n "This will overwrite ${image}-build:${version}. Are you sure? [y/N] " && read ans && [ $${ans:-N} = y ]
	@docker commit ${container} ${image}-build:${version}

#######################################################
# Internal tasks
#######################################################

rm-silent:
	@docker rm ${container} 2> /dev/null || true

pre-run: rm-silent

env:
	@$(foreach V, \
		$(sort $(.VARIABLES)), \
		$(if \
			$(filter-out environment% default automatic, $(origin $V)), \
			$(if \
				$(filter-out print_%_variables check_%, $V), \
				$(warning $V=$($V) ($(origin $V))) \
			) \
		) \
	)