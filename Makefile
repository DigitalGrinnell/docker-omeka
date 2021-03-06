
SHELL=/bin/bash

# NOCACHE=--no-cache
NOCACHE=

OMEKA_TAG=erochest/omeka
OMEKA_NAME=omeka
DOCKER_TAG=2.5

MYSQL_TAG=mysql
MYSQL_NAME=mysql

MYSQL_ROOT_PASS=rootpass

build:
	docker build ${NOCACHE} -t ${OMEKA_TAG} .

run:
	docker-compose up

mysql:
	docker run -it --link ${MYSQL_NAME}:mysql --rm mysql sh -c 'exec mysql -h"$$MYSQL_PORT_3306_TCP_ADDR" -P"$$MYSQL_PORT_3306_TCP_PORT" -uroot -p"$$MYSQL_ENV_MYSQL_ROOT_PASSWORD"'

createdb:
	mysql -h`docker inspect ${MYSQL_NAME} | grep IPAddress | sed -e 's/.*: "\(.*\)",/\1/'` -uroot -p${MYSQL_ROOT_PASS} < files/create.sql

pull:
	docker pull ${MYSQL_TAG}
	docker pull ${OMEKA_TAG}

push: build
	docker tag `docker images --format {{.ID}} ${OMEKA_TAG}:latest` ${OMEKA_TAG}:${DOCKER_TAG}
	docker push ${OMEKA_TAG}

stop:
	docker-compose stop

start: run

clean: stop
	docker rm ${OMEKA_NAME}
	docker rm ${MYSQL_NAME}

distclean: clean
	docker rmi ${OMEKA_TAG}

status:
	docker ps

details:
	docker inspect ${OMEKA_NAME}

rebuild:
	make distclean
	make build
	make start
	sleep 5
	make createdb

go:
	make pull
	make start
	sleep 5
	make createdb

.PHONY: build run copysql mysql createdb stop start clean distclean status details rebuild pull go boot2go boot2db
