#---------------------------------------------------------------------------#
#   © Copyright 2021 Research Group in Architecture and Cinema (GIRAC)
#   University of Valladolid
#   https://www.girac.es
# 
#	This file is part of Filmcity.
#
#   Filmcity  is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   any later version.
#
#
#   Filmcity  is distributed in the hope that it will be useful,
#	but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with Filmcity. If not, see <https://www.gnu.org/licenses/>.
#
#---------------------------------------------------------------------------#
# 	Written by Rubén Vega Balbás <ruvebal@uva.es>
#   https://orcid.org/0000-0001-6862-9081
#   Postdoctoral researcher
#   2021, December
#---------------------------------------------------------------------------#
#
# 	This Makefile contains all the recipes necesary to build or update 
# 	the database 'filmcity'
# 	including its environment and deployment
#
#---------------------------------------------------------------------------#
#

#---------------------------------------------------------------------------#
# Definitions
#---------------------------------------------------------------------------#
# Use bash instead of sh
SHELL 	:=	/bin/bash
#
# Set the default environment if not assigned via an invocation parameter
# either as prod for production, dev for development, stg for stagement
#
# ENV 	?=	prod
# ENV	?=	stg
ENV 	?=	dev
#
VERSION_FILE = VERSION
CUR_VERSION := $(shell cat ${VERSION_FILE})
#
# Set the default semantic version for the release if not assigned 
# via an invocation parameter
#
#RELEASE ?= release-major
#RELEASE ?= release-minor
RELEASE ?= release-patch
#
# Guess and define the path to this Makfile
SELF_PATH := $(shell cd -P -- '$(shell dirname -- "$0")' && pwd -P)

#---------------------------------------------------------------------------#
# Checking dependencies in $PATH
#
REQUIRED_BINS := docker-compose docker rsync curl
$(foreach bin, $(REQUIRED_BINS), 											\
    $(if 																	\
		$(shell command -v $(bin) 2> /dev/null), 							\
		$(info `Found $(bin)`),												\
		$(error Please install `$(bin)`) 									\
	)																		\
)

#---------------------------------------------------------------------------#
# Defining & parsing the environmental keys=values
#
ENV_FILE := $(SELF_PATH)/etc/$(ENV).env
include $(ENV_FILE)

#---------------------------------------------------------------------------#
# Defining Docker's projec name as e.g. filmcity-dev
#
PROJECT_NAME := $(notdir $(SELF_PATH))-$(ENV)

#---------------------------------------------------------------------------#
# Let's create an arangodb group —if it does not already exist
#
_ARANGO_GRP :=	@$(shell set -e &&											\
						getent group arangodb >/dev/null || 				\
							sudo groupadd -r arangodb  						\
				)

#---------------------------------------------------------------------------#
# Let's create an arangodb system user —if it does not already exist 
# belonging to the previously created group 
#
_ARANGO_USER := @$(shell set -e &&											\
						getent passwd arangodb >/dev/null || 				\
							sudo useradd -r -g arangodb --uid 998 			\
							-s /bin/false -c "ArangoDB Application User" 	\
							arangodb 										\
				)

#---------------------------------------------------------------------------#
# Appended the user to the arangodb group
#
_MY_USER :=	@$(shell														\
					[[ ! " $(shell groups) " =~ ' arangodb ' ]] && 			\
					sudo usermod -a -G arangodb $(shell whoami)				\
			)

#---------------------------------------------------------------------------#
# A function to execute a js script via arangosh into a docker container
# Paramaters can be specified after the .js name in the CL
#
define myarangosh
	sudo docker exec 														\
        -ti ${ARANGO_CONTAINER} 											\
        sh -c "arangosh 													\
                    --server.password ${ARANGO_ROOT_PASSWORD} 				\
                    --console.history false 								\
                    --server.endpoint ${ARANGO_ENDPOINT} 					\
                    --javascript.execute ${1} 								\
        "
endef

#---------------------------------------------------------------------------#
# A function to execute foxx-cli into a docker container
#
define myfoxx
	sudo docker exec 														\
        -ti ${ARANGO_CONTAINER} 											\
        sh -c "/usr/local/bin/foxx ${1}"
endef						

#---------------------------------------------------------------------------#
.PHONY:	all stop start info install setup									\
		release build clean clear test										\
		foxx-server-install foxx-server-remove								\
		foxx foxx-service-install foxx-service-loop							\
		foxx-service-uninstall foxx-service-list
#---------------------------------------------------------------------------#

all:
	$(info Execute this Makefile with a target defined as # make <target>	)
	$(info And assign values if required for params 'ENV' & 'RELEASE'		)
	$(info To override the defaults 										)
	@echo "Any other default recipe to cook, Captain!"

#---------------------------------------------------------------------------#
stop start clean: MYCONTAINER_CHECK=$(shell 								\
							sudo docker inspect -f '{{.State.Running}}' 	\
							${ARANGO_CONTAINER} 2>/dev/null					)

stop: MYCONTAINER_ID=$(shell												\
							sudo docker container ls | 						\
							grep ${ARANGO_CONTAINER} | awk '{print $$1}'	)

stop:
	@if [ "${MYCONTAINER_CHECK}" = "true" ]; 								\
	then																	\
		cd ${SELF_PATH} && 													\
			sudo docker container stop ${MYCONTAINER_ID} &&					\
			sudo docker container rm ${MYCONTAINER_ID};						\
	else																	\
		echo "${ARANGO_CONTAINER} not running";								\
	fi			

start: build
	@if [ "${MYCONTAINER_CHECK}" != "true" ]; 								\
	then																	\
		cd ${SELF_PATH} && 													\
			sudo docker-compose 											\
				--project-name $(PROJECT_NAME)								\
				--env-file $(ENV_FILE) 										\
				--verbose													\
				--log-level DEBUG											\
				up --detach;												\
	else																	\
		echo "${ARANGO_CONTAINER} actually running";						\
	fi

# Only the directory for the current version will be removed
clean:
	@if [ "${MYCONTAINER_CHECK}" != "true" ]; 								\
	then																	\
		sudo rm -fr "./build/${CUR_VERSION}";								\
	else																	\
		echo "${ARANGO_CONTAINER} actually running";						\
		echo "Run previously # make stop ";									\
	fi

# The whole build directory will be cleared
clear: MYBUILD = build/${CUR_VERSION}/arango/${ARANGO_TAG}/
clear:
	@if [ "${MYCONTAINER_CHECK}" != "true" ]; 								\
	then																	\
		sudo rm -fr "${MYBUILD}";											\
	else																	\
		echo "${ARANGO_CONTAINER} actually running";						\
		echo "Run previously # make stop ";									\
	fi

#---------------------------------------------------------------------------#
# Test
#---------------------------------------------------------------------------#
#
test: ROUTE	?= 																\
				_db/filmcity/_api/version									\
				_api/endpoint												\
				/_api/foxx
test:
	@for MYROUTE in ${ROUTE}; 												\
		do																	\
			curl --user root:${ARANGO_ROOT_PASSWORD} 						\
				--header 'accept: application/json' 						\
				--dump - 													\
				$(addsuffix /$$MYROUTE, 									\
					$(subst tcp, http, ${ARANGO_ENDPOINT})					\
				)															\
			;																\
	done

#---------------------------------------------------------------------------#
# Javascripts to execute via Arangosh and setup the DB 
#---------------------------------------------------------------------------#
setup: JS	?=																\
				apis/checkDB.js												\
				apis/createCollections.js									\
				apis/createUsers.js											\
				data/__setup/geoindex.js									\
				data/__setup/schemata.js									\
				data/boundaries/db-boundaries-spain-es.js					\
				data/boundaries/db-boundaries-L2-countries.js				\
				apis/boundariesCinemap.js									\
				apis/createRoutes.js

setup: build var/${JS} 
	@for myJS in ${JS}; 													\
		do                               									\
			case ${ENV} in													\
				dev)														\
					$(call myarangosh, ${APPS_CONTAINER}/$$myJS)			\
				;;															\
			esac															\
	done

#---------------------------------------------------------------------------#
# Javascript to execute via Arangosh and populate the DB with json files
# Collections are passed as parameters from filenames
#---------------------------------------------------------------------------#
populate: JS			:=	apis/populateDB.js
populate: COLLECTIONS	?=													\
							data/archimedia.json							\
							data/cinemas.json								\
							data/edits.json									\
							data/families.json								\
							data/films.json									\
							data/institutions.json							\
							data/people.json								\
							data/pois.json									\
							data/filmmedia.json
#
populate: var/${JS} build
	@$(call myarangosh, ${APPS_CONTAINER}/${JS} ${COLLECTIONS})

#---------------------------------------------------------------------------#
# Releases
#---------------------------------------------------------------------------#
#
## Tag the release and push tag to git
# Recursive make invocation to get the updated VERSION file by #make release
release: usr/sem_ver.sh
	@cd $(SELF_PATH) &&														\
		bash $< $(VERSION_FILE) ${RELEASE}
		$(MAKE) -C ${SELF_PATH} ENV=${ENV} build

#---------------------------------------------------------------------------#
# Building
#---------------------------------------------------------------------------#
build: MYBUILD = build/${CUR_VERSION}/arango/${ARANGO_TAG}/
build:		
	@$(MAKE) -C ${SELF_PATH} --always-make ENV=${ENV} ${MYBUILD}
#
# Expecting only directories
build/%/: var/
	@[[ -d $@ ]] || mkdir -p $@
	@for d in $(ARANGO_VOLUMES); 											\
		do                               									\
			[[ -d $@$$d ]] || 												\
				sudo install -d -m 755 -o arangodb -g arangodb 				\
					$@$$d;													\
			case $$d in														\
				${ARANGO_APPS})												\
					sudo rsync -prog --verbose 								\
						--chown=arangodb:arangodb							\
						--chmod=755											\
						$<													\
						$@$$d												\
				;;															\
			esac															\
	done

#---------------------------------------------------------------------------#
# Foxx MicroServices
#---------------------------------------------------------------------------#
#
# We assume the database name to be the same as the project root directory
# …more precisely the last directory name in the self path
#

foxx: build
	@$(MAKE) 																\
			-C ${SELF_PATH} 												\
			--always-make 													\
			MYSERVER_NAME=${ENV} 											\
				foxx-service-loop

#---------------------------------------------------------------------------#

foxx-server-remove foxx-server-set: DATABASE ?= $(notdir $(SELF_PATH))
foxx-server-remove foxx-server-set: MYSERVER_NAME ?= ${ENV}
foxx-server-remove foxx-server-set: MYSERVER_CHECK = $(shell $(call myfoxx, server list))
foxx-server-remove foxx-server-set: MYFOXX = 							 	\
										--database 	${DATABASE}				\
										--username root 					\
										--password							\
										${MYSERVER_NAME} ${ARANGO_ENDPOINT}	

foxx-server-remove:
	@if [[ "${MYSERVER_NAME}" == "${MYSERVER_CHECK}" ]]; 					\
	then																	\
		echo "Removing Server ${MYSERVER_NAME} as ${MYSERVER_CHECK}.";		\
		$(call myfoxx, server remove ${MYSERVER_NAME});						\
	else																	\
		echo "Server ${MYSERVER_NAME} not set";								\
		echo "Wanna create service? Execute first # make foxx-server-set";	\
	fi

foxx-server-set:
	@if [[ "${MYSERVER_NAME}" == "${MYSERVER_CHECK}" ]]; 					\
	then																	\
		echo "${MYSERVER_NAME} already set.";								\
		echo "Wanna recreate service? Run first # make foxx-server-remove";	\
	else																	\
		echo "Installing Server ${MYSERVER_NAME}";							\
		$(call myfoxx, server set ${MYFOXX});								\
	fi

#---------------------------------------------------------------------------#
foxx-service-install foxx-service-uninstall:	DATABASE ?= $(notdir $(SELF_PATH))
foxx-service-install foxx-service-uninstall:	MYSERVER_NAME ?= ${ENV}
foxx-service-install foxx-service-uninstall:	MYSERVICE ?= 				\
														services/cinemapp
foxx-service-install foxx-service-uninstall:	MYPREFIX ?= 				\
													/$(notdir $(MYSERVICE))

foxx-service-install foxx-service-uninstall:	MYSERVICE_CHECK=			\
									$(shell $(call myfoxx, 					\
										list								\
										--server ${MYSERVER_NAME}	 		\
										--database 	${DATABASE}				\
									))

foxx-service-install foxx-service-uninstall: MYFOXX = 						\
										--username root 					\
										--password							\
										--server ${MYSERVER_NAME}	 		\
										--database 	${DATABASE}				\

foxx-service-list:
	$(eval ${MYSERVICE_CHECK})

foxx-service-install: foxx-server-set
	if [[ "${MYSERVICE_CHECK}" == *"${MYPREFIX}"* ]]; 						\
	then																	\
		echo "Upgrading previously installed ${MYPREFIX}.";					\
		$(call myfoxx,														\
			upgrade ${MYFOXX} ${MYPREFIX} ${APPS_CONTAINER}/${MYSERVICE});	\
	else																	\
		echo "Installing ${MYPREFIX}";										\
		$(call myfoxx,														\
			install ${MYFOXX} ${MYPREFIX} ${APPS_CONTAINER}/${MYSERVICE});	\
	fi

# Run as # make foxx-service-uninstall MYPREFIX=/cinemap 
foxx-service-uninstall:
	if [[ "${MYSERVICE_CHECK}" == *"${MYPREFIX}"* ]]; 						\
	then																	\
		echo "Uninstalling ${MYPREFIX}.";									\
		$(call myfoxx, uninstall ${MYFOXX} ${MYPREFIX}); 					\
	else																	\
		echo "${MYPREFIX} not installed";									\
	fi
#---------------------------------------------------------------------------#

foxx-service-loop: MYSERVER_NAME ?= ${ENV}
foxx-service-loop: MYSERVICES ?=											\
								services/cinemapp

foxx-service-loop: var/${MYSERVICES}
	for MYSERVICE in ${MYSERVICES}; 										\
		do                               									\
			case $$(basename $${MYSERVICE}) in								\
				cinemapp)													\
					MYPREFIX=$$(basename $${MYSERVICE})	&&					\
					/usr/bin/make -C ${SELF_PATH} --always-make 			\
						MYSERVER_NAME=$${MYSERVER_NAME} 					\
						MYSERVICE=$${MYSERVICE} 							\
						MYPREFIX=/$${MYPREFIX} 								\
						foxx-service-install								\
				;;															\
																			\
				*)															\
					MYPREFIX=$$(basename $${MYSERVICE})	&&					\
					/usr/bin/make -C ${SELF_PATH} --always-make 			\
						MYSERVER_NAME=$${MYSERVER_NAME} 					\
						MYSERVICE=$${MYSERVICE} 							\
						MYPREFIX=/$${MYPREFIX} 								\
						foxx-service-install								\
				;;															\
																			\
			esac															\
	done

#---------------------------------------------------------------------------#
# Check prequisites
#---------------------------------------------------------------------------#

usr/sem_ver.sh:
	@[[ -f $@ && -x $@ ]] || exit 1

var%:
	@[[ -d $@ || -f $@ ]] || exit 1
#
#EOFile