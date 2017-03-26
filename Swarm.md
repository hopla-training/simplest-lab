# Review Swarm Mode Cluster Configurations

## These are some notes for reviewing Swarm cluster in case you use a preconfigured deployment (Azure, AWS, Vagrant, etc...) .

1. Show swarm nodes:

~~~
    $ docker node ls
    (sample output)
    ID                           HOSTNAME  STATUS  AVAILABILITY  MANAGER STATUS
    gmb6myxkpi7sm9jdqcp902fk4    node4     Ready   Active        Reachable
    rvrttl3cgsxnonzmopv9i7u1s *  node1     Ready   Pause         Leader
    y8vwxmjpsu4st92m057fmh90r    node2     Ready   Active        Reachable
    yey12o796bishtyakixkp6v1p    node3     Ready   Active        

~~~

In this example output, we have a 4 nodes swarm cluster with 3 managers and 1 worker. 

This can be seen reviewing "MANAGER STATUS" column, in this example, __node1__ is the __leader__ and __node2__ and __node4__ are __managers__ too. 

Node __node3__ is a __worker__.

As we can see in this example, node __node1__ is in __"Pause"__ state which means that it can not start tasks.

In this situation, nodes __node2__, __node3__ and __node4__ will only schedule tasks.

* * *
Nodes __"AVAILABILITY"__ can be specified as:
- __Active__ -> It can schedule tasks so any service can be deployed using this node.
- __Pause__ -> It can not schedule any new task. All tasks running on this node will remain, but it can not schedule new ones.
- __Drain__ -> This node will stop all its running tasks and swarm cluster will reschedule them on all other __"Active"__ nodes. 

* * *

2. We can review plugins available on each node using __inspect__:

~~~

    $ docker node inspect node1

    [
        {
            "ID": "rvrttl3cgsxnonzmopv9i7u1s",
            "Version": {
                "Index": 74
            },
            "CreatedAt": "2017-03-25T12:48:46.78289171Z",
            "UpdatedAt": "2017-03-25T18:14:22.933215062Z",
            "Spec": {
                "Role": "manager",
                "Availability": "pause"
            },
            "Description": {
                "Hostname": "node1",
                "Platform": {
                    "Architecture": "x86_64",
                    "OS": "linux"
                },
                "Resources": {
                    "NanoCPUs": 1000000000,
                    "MemoryBytes": 1556623360
                },
                "Engine": {
                    "EngineVersion": "17.03.0-ce",
                    "Plugins": [
                        {
                            "Type": "Network",
                            "Name": "bridge"
                        },
                        {
                            "Type": "Network",
                            "Name": "host"
                        },
                        {
                            "Type": "Network",
                            "Name": "ipvlan"
                        },
                        {
                            "Type": "Network",
                            "Name": "macvlan"
                        },
                        {
                            "Type": "Network",
                            "Name": "null"
                        },
                        {
                            "Type": "Network",
                            "Name": "overlay"
                        },
                        {
                            "Type": "Volume",
                            "Name": "local"
                        }
                    ]
                }
            },
            "Status": {
                "State": "ready",
                "Addr": "127.0.0.1"
            },
            "ManagerStatus": {
                "Leader": true,
                "Reachability": "reachable",
                "Addr": "10.10.10.11:2377"
            }
        }
    ]


~~~