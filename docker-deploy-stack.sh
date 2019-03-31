#!/bin/sh
export SWARM_MASTER_IP=`terraform output -json swarm_masters_ips | python -c "import sys, json; print json.load(sys.stdin)['value'][0]"`
ssh -o StrictHostKeyChecking=no ubuntu@${SWARM_MASTER_IP} docker info
scp docker-compose.yml ubuntu@${SWARM_MASTER_IP}:/home/ubuntu
ssh ubuntu@${SWARM_MASTER_IP} docker stack deploy --compose-file=/home/ubuntu/docker-compose.yml test-stack

#Please dont laugh at me for this. For some reason after first stack deploy there is no internet access from containers
sleep 15
ssh -o StrictHostKeyChecking=no ubuntu@${SWARM_MASTER_IP} docker stack rm test-stack

ssh ubuntu@${SWARM_MASTER_IP} docker stack deploy --compose-file=/home/ubuntu/docker-compose.yml test-stack
ssh ubuntu@${SWARM_MASTER_IP} docker service logs -f test-stack_tomcat
