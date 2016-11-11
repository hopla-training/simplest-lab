
	docker-compose -f mentorsday-lab.yml -p demo up -d 
	
	docker-compose -f mentorsday-lab.yml -p demo stop

	docker-compose -f mentorsday-lab.yml -p demo down


Configured Services for the Demo Environment



networks:
  simplestdemo: {}
services:
  app:
    depends_on:
    - lb
    - db
    environment:
      dbhost: simplestdb
      dbname: demo
      dbpasswd: d3m0
      dbuser: demo
    expose:
    - 3000
    image: hopla/mentorsday-lab:simplestapp
    networks:
      simplestdemo:
        aliases:
        - simplestapp
    restart:
      MaximumRetryCount: 0
      Name: unless-stopped
  db:
    container_name: simplestdb
    environment:
      POSTGRES_PASSWORD: changeme
    expose:
    - 5432
    image: hopla/mentorsday-lab:simplestdb
    networks:
      simplestdemo:
        aliases:
        - simplestdb
    restart:
      MaximumRetryCount: 0
      Name: unless-stopped
  lb:
    container_name: simplestlb
    environment:
      APPLICATION_ALIAS: simplestapp
      APPLICATION_PORT: '3000'
    image: hopla/mentorsday-lab:simplestlb
    networks:
      simplestdemo:
        aliases:
        - simplestlb
    ports:
    - 8080:80
    restart:
      MaximumRetryCount: 0
      Name: unless-stopped
version: '2.0'
volumes: {}

