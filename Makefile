clean:
	docker-compose -f mentorsday-lab.yml -p demo stop
	docker-compose -f mentorsday-lab.yml -p demo rm -f

demo:
	docker-compose -f mentorsday-lab.yml -p demo up -d

build:
	docker build -t hopla/mentorsday-lab:simplestapp -f simplestapp/Dockerfile simplestapp
	docker build -t hopla/mentorsday-lab:simplestlb -f simplestlb/Dockerfile simplestlb
	docker build -t hopla/mentorsday-lab:simplestdb -f simplestdb/Dockerfile simplestdb

push:
	docker push hopla/mentorsday-lab:simplestapp
	docker push hopla/mentorsday-lab:simplestlb
	docker push hopla/mentorsday-lab:simplestdb

scale:
	docker-compose -f simplest-demo.yml -p demo scale app=5

hits:
	while :;do curl -s http://0.0.0.0:8080 >/dev/null;sleep 2;done

debug:
	docker network rm db 2>/dev/null|| true
	docker network create db 2>/dev/null|| true
	docker rm -fv simplestlb simplestdb simplestapp 2>/dev/null|| true
	docker run -net=db  -e "APPLICATION_ALIAS=simplestapp" -e "APPLICATION_PORT=3000" -d --name simplestlb  hopla/mentorsday-lab:simplestlb
	docker run --net=db -e "POSTGRES_PASSWORD=changeme" -d --name simplestdb hopla/mentorsday-lab:simplestdb

	docker run --rm --name simplestapp --net=db -ti \
	-e dbhost=simplestdb -e dbname=demo -e dbuser=demo -e dbpasswd=d3m0 -e dbpool=true \
	-v ${PWD}/simplestapp/simplestapp.js:/APP/simplestapp.js \
	-v ${PWD}/simplestapp/simplestapp.html:/APP/simplestapp.html -p 8080:3000 hopla/mentorsday-lab:simplestapp node simplestapp.js 3000

