# Simplest Application Lab from HoplaSoftware

## This Lab will guide you to create a simple multi-service application using docker-compose and docker stacks.


* * *
__NOTES:__
- __This lab doesn't use secrets for password management__. It's quite easy add this feature, you will have to modify database service and application backend because nginx load balancer isn't using any password or authentication. Notice that you should change postgreSQL 'hits' database creation script.

* * *

1. First be sure that you have docker engine >=1.13 (17.03) and docker-compose >=1.11

* * *

2. Once all requirements are meet, we can deploy this lab on Docker Swarm using __"docker stack"__ or use __"docker-compose"__. 
Both have incompatible options but will be ignored when deploying.

* * *

3. Download this lab using git clone or downloading zip file options:

~~~
    git clone https://github.com/hopla-training/simplest-lab.git

~~~

or

~~~
    wget https://github.com/hopla-training/simplest-lab/archive/master.zip

    unzip master.zip 
    cd simplest-lab-master

~~~

* * *

4. Build Images:

~~~
    $ docker-compose -f simplest-lab.V3.yml build

~~~

This will build all required images for this lab.
- hopla/simplest-lab:simplestlb --> Loadbalancer used as application frontend. It will listen on port 8080 so we could use [http://localhost:8080](http://localhost:8080) as application endpoint, using only one host or even using a swarm envroment, thanks to __"routing mesh"__. Everytime we request this frontend page, NGINX will query DNS will asking for new DNS entries acting as application backend (forced DNS Round Robin, instead of Docker built-in DNSRR).

- hopla/simplest-lab:simplestdb --> Database for storing backend hits data. We should use persistent volumes (we can use __'docker storage plugins'__ to ensure data across swarm hosts).

- hopla/simplest-lab:simplestapp --> Nodejs application that will act as backend. Everytime a request gets each backend, an insert will be send to database with its own IP. This way backend IPs will populate database and each new request will grow up its number of hits.

* * *

5. Check if images were correctly built.

~~~
   $ docker image ls --format "{{.Repository}}"|grep hopla
    hopla/simplest-lab
    hopla/simplest-lab
    hopla/simplest-lab

~~~

* * *

6. Check what services will be created during deployment.

~~~ 
    $ docker-compose --f simplest-lab.V3.yml -p lab  config --services
    db
    lb
    app

~~~

We have used 'lab' as projectname. When deploying this application with docker-compose, services will be renamed to "<PROJECT_NAME>_<SERVICE_NAME>", so we will have 
- lab_db
- lab_lb
- lab_app

In docker-compose file (updated version V3) we have defined a network called 'simplestlab'. This is the network for our application, if we omit this definition, a network name will be created using project name.

When using docker stacks, we will need to specify a "stack name". Services will be prefixed with this name.


* * *

7. Deploy the application stack.

- Using docker-compose:

~~~
    $ docker-compose --f simplest-lab.V3.yml -p lab up -d

~~~

Some warnings may appear because version 3 is valid for docker stacks or docker-compose deployments, but syntax isn't compatible yet.

- Using docker stack

~~~

$ docker stack deploy --compose-file simplest-lab.V3.yml lab
Ignoring unsupported options: build

Creating network lab_simplestlab
Creating service lab_app
Creating service lab_lb
Creating service lab_db


~~~

* * *

8. We now review deployments

- Using docker-compose

~~~

$ docker-compose --f simplest-lab.V3.yml -p lab  ps
  Name                 Command               State          Ports         
-------------------------------------------------------------------------
lab_app_1   node simplestapp.js 3000         Up      3000/tcp             
lab_db_1    /docker-entrypoint.sh postgres   Up      5432/tcp             
lab_lb_1    /entrypoint.sh /bin/sh -c  ...   Up      0.0.0.0:8080->80/tcp

~~~~

- Using docker stack

~~~

$ docker stack ls
NAME  SERVICES
lab   3

$ docker stack services lab
ID            NAME     MODE        REPLICAS  IMAGE
e2wxwmt2brcl  lab_lb   replicated  1/1       hopla/simplest-lab:simplestlb
w9i5rwrb1xde  lab_app  replicated  1/1       hopla/simplest-lab:simplestapp
xonw8tpdkpv3  lab_db   replicated  1/1       hopla/simplest-lab:simplestdb

$ docker stack ps lab
ID            NAME       IMAGE                           NODE   DESIRED STATE  CURRENT STATE               ERROR  PORTS
s5d117nz0sva  lab_db.1   hopla/simplest-lab:simplestdb   hopla1  Running        Running about a minute ago         
ta016cws1rpm  lab_lb.1   hopla/simplest-lab:simplestlb   hopla2  Running        Running about a minute ago         
hq3gxnrowy5x  lab_app.1  hopla/simplest-lab:simplestapp  hopla1  Running        Running about a minute ago         

~~~

* * *

9. Let's take a look around lab environment

![Sample1](https://github.com/hopla-training/simplest-lab/raw/master/pictures/sample1.png)

* * *

10. Scale up application backend !!

- Using docker-compose

~~~

$ docker-compose --f simplest-lab.V3.yml -p lab scale app=10
Creating and starting lab_app_2 ... done
Creating and starting lab_app_3 ... done
Creating and starting lab_app_4 ... done
Creating and starting lab_app_5 ... done
Creating and starting lab_app_6 ... done
Creating and starting lab_app_7 ... done
Creating and starting lab_app_8 ... done
Creating and starting lab_app_9 ... done
Creating and starting lab_app_10 ... done


$ docker-compose --f simplest-lab.V3.yml -p lab ps
   Name                 Command               State          Ports         
--------------------------------------------------------------------------
lab_app_1    node simplestapp.js 3000         Up      3000/tcp             
lab_app_10   node simplestapp.js 3000         Up      3000/tcp             
lab_app_2    node simplestapp.js 3000         Up      3000/tcp             
lab_app_3    node simplestapp.js 3000         Up      3000/tcp             
lab_app_4    node simplestapp.js 3000         Up      3000/tcp             
lab_app_5    node simplestapp.js 3000         Up      3000/tcp             
lab_app_6    node simplestapp.js 3000         Up      3000/tcp             
lab_app_7    node simplestapp.js 3000         Up      3000/tcp             
lab_app_8    node simplestapp.js 3000         Up      3000/tcp             
lab_app_9    node simplestapp.js 3000         Up      3000/tcp             
lab_db_1     /docker-entrypoint.sh postgres   Up      5432/tcp             
lab_lb_1     /entrypoint.sh /bin/sh -c  ...   Up      0.0.0.0:8080->80/tcp 

~~~

- Using docker stack

$ docker service ls
ID            NAME     MODE        REPLICAS  IMAGE
e2wxwmt2brcl  lab_lb   replicated  1/1       hopla/simplest-lab:simplestlb
w9i5rwrb1xde  lab_app  replicated  1/1       hopla/simplest-lab:simplestapp
xonw8tpdkpv3  lab_db   replicated  1/1       hopla/simplest-lab:simplestdb

$ docker service scale lab_app=10

lab_app scaled to 10

$ docker service ls
ID            NAME     MODE        REPLICAS  IMAGE
e2wxwmt2brcl  lab_lb   replicated  1/1       hopla/simplest-lab:simplestlb
w9i5rwrb1xde  lab_app  replicated  10/10     hopla/simplest-lab:simplestapp
xonw8tpdkpv3  lab_db   replicated  1/1       hopla/simplest-lab:simplestdb


* * *

11. Review Lab Environment

![Sample2](https://github.com/hopla-training/simplest-lab/raw/master/pictures/sample2.png)

* * *

12. Scale down !!!

- Using docker-compose

~~~

$ docker-compose --f simplest-lab.V3.yml -p lab scale app=4
Stopping and removing lab_app_5 ... done
Stopping and removing lab_app_6 ... done
Stopping and removing lab_app_7 ... done
Stopping and removing lab_app_8 ... done
Stopping and removing lab_app_9 ... done
Stopping and removing lab_app_10 ... done

$ docker-compose --f simplest-lab.V3.yml -p lab ps
  Name                 Command               State          Ports         
-------------------------------------------------------------------------
lab_app_1   node simplestapp.js 3000         Up      3000/tcp             
lab_app_2   node simplestapp.js 3000         Up      3000/tcp             
lab_app_3   node simplestapp.js 3000         Up      3000/tcp             
lab_app_4   node simplestapp.js 3000         Up      3000/tcp             
lab_db_1    /docker-entrypoint.sh postgres   Up      5432/tcp             
lab_lb_1    /entrypoint.sh /bin/sh -c  ...   Up      0.0.0.0:8080->80/tcp 

~~~

- Using docker stack

~~~

$ docker service scale lab_app=4

lab_app scaled to 4


$ docker service ls
ID            NAME     MODE        REPLICAS  IMAGE
e2wxwmt2brcl  lab_lb   replicated  1/1       hopla/simplest-lab:simplestlb
w9i5rwrb1xde  lab_app  replicated  4/4       hopla/simplest-lab:simplestapp
xonw8tpdkpv3  lab_db   replicated  1/1       hopla/simplest-lab:simplestdb

~~~

* * *

13. Review Lab Environment


* * *

14. What happens if things go wrong?

- Using docker-compose:
Now we kill one application backend container

~~~

$ docker ps
CONTAINER ID        IMAGE                            COMMAND                  CREATED             STATUS              PORTS                  NAMES
096e180f3375        hopla/simplest-lab:simplestapp   "node simplestapp...."   10 minutes ago      Up 10 minutes       3000/tcp               lab_app_4
a9ea31ada395        hopla/simplest-lab:simplestapp   "node simplestapp...."   10 minutes ago      Up 10 minutes       3000/tcp               lab_app_3
f3c4e378b286        hopla/simplest-lab:simplestapp   "node simplestapp...."   10 minutes ago      Up 10 minutes       3000/tcp               lab_app_2
d025e01b2f8d        hopla/simplest-lab:simplestapp   "node simplestapp...."   22 minutes ago      Up 22 minutes       3000/tcp               lab_app_1
3c9231e6c850        hopla/simplest-lab:simplestdb    "/docker-entrypoin..."   22 minutes ago      Up 22 minutes       5432/tcp               lab_db_1
5aab697d0921        hopla/simplest-lab:simplestlb    "/entrypoint.sh /b..."   22 minutes ago      Up 22 minutes       0.0.0.0:8080->80/tcp   lab_lb_1

$ docker kill d025e01b2f8d
d025e01b2f8d

$ docker-compose --f simplest-lab.V3.yml -p lab ps
  Name                 Command                State            Ports         
----------------------------------------------------------------------------
lab_app_1   node simplestapp.js 3000         Exit 137                        
lab_app_2   node simplestapp.js 3000         Up         3000/tcp             
lab_app_3   node simplestapp.js 3000         Up         3000/tcp             
lab_app_4   node simplestapp.js 3000         Up         3000/tcp             
lab_db_1    /docker-entrypoint.sh postgres   Up         5432/tcp             
lab_lb_1    /entrypoint.sh /bin/sh -c  ...   Up         0.0.0.0:8080->80/tcp 

~~~

As shown in this example resilience using docker-compose in a non-swarmed environment is different and worse. We must specify what to do in case of failure.


- Using docker stacks

~~~
On one of the hosts we will kill one task/container
$ docker ps
CONTAINER ID        IMAGE                            COMMAND                  CREATED             STATUS              PORTS               NAMES
820e2b3b3330        hopla/simplest-lab:simplestapp   "node simplestapp...."   About an hour ago   Up About an hour    3000/tcp            lab_app.6.sn4mlb79calm86efwg7bxixoc
66b3f2bfce09        hopla/simplest-lab:simplestapp   "node simplestapp...."   About an hour ago   Up About an hour    3000/tcp            lab_app.7.x44y5slo94dsb0enmudmh8oju
4d0c15ce2a02        hopla/simplest-lab:simplestapp   "node simplestapp...."   About an hour ago   Up About an hour    3000/tcp            lab_app.5.jwy8359y1zqjlplmmb6vnngqb
6be9e040e300        hopla/simplest-lab:simplestapp   "node simplestapp...."   About an hour ago   Up About an hour    3000/tcp            lab_app.4.lun86eua2ygtgq2r75kpehrir
07be4730416f        hopla/simplest-lab:simplestdb    "/docker-entrypoin..."   About an hour ago   Up About an hour    5432/tcp            lab_db.1.s5d117nz0sva1o3f39qod4o32
786cd12c4caf        hopla/simplest-lab:simplestlb    "/entrypoint.sh /b..."   About an hour ago   Up About an hour    80/tcp              lab_lb.1.ta016cws1rpmwey0k5nep8fm5

$ docker kill 820e2b3b3330

$ docker service ls
ID            NAME     MODE        REPLICAS  IMAGE
e2wxwmt2brcl  lab_lb   replicated  1/1       hopla/simplest-lab:simplestlb
w9i5rwrb1xde  lab_app  replicated  3/4       hopla/simplest-lab:simplestapp
xonw8tpdkpv3  lab_db   replicated  1/1       hopla/simplest-lab:simplestdb

But some seconds after, if we review stack services we notice that service status is recovered, with the previously defined number of instances.

$ docker service ls
ID            NAME     MODE        REPLICAS  IMAGE
e2wxwmt2brcl  lab_lb   replicated  1/1       hopla/simplest-lab:simplestlb
w9i5rwrb1xde  lab_app  replicated  4/4       hopla/simplest-lab:simplestapp
xonw8tpdkpv3  lab_db   replicated  1/1       hopla/simplest-lab:simplestdb

~~~


Docker Swarm is prepared for resilience oout-of-box. We can define how many tries to recover the number of instances but services are ready for resilience.

* * *

15. Remove everything

- Using docker-compose

~~~

$ docker-compose --f simplest-lab.V3.yml -p lab down
Stopping lab_app_4 ... done
Stopping lab_app_3 ... done
Stopping lab_app_2 ... done
Stopping lab_db_1 ... done
Stopping lab_lb_1 ... done
Removing lab_app_4 ... done
Removing lab_app_3 ... done
Removing lab_app_2 ... done
Removing lab_app_1 ... done
Removing lab_db_1 ... done
Removing lab_lb_1 ... done
Removing network lab_simplestlab

$ docker-compose --f simplest-lab.V3.yml -p lab ps
Name   Command   State   Ports 
------------------------------

~~~

- Using docker stacks

~~~

$ docker stack ls
NAME  SERVICES
lab   3

$ docker stack remove lab
Removing service lab_lb
Removing service lab_app
Removing service lab_db
Removing network lab_simplestlab

$ docker stack ls
NAME  SERVICES

~~~

