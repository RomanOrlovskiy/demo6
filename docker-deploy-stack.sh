#!/bin/sh
export SWARM_MASTER_IP=`terraform output -json swarm_masters_ips | python -c "import sys, json; print json.load(sys.stdin)['value'][0]"`
ssh -o StrictHostKeyChecking=no ubuntu@${SWARM_MASTER_IP} docker info
scp -r -o StrictHostKeyChecking=no docker-compose.yml ubuntu@${SWARM_MASTER_IP}:/home/ubuntu/
ssh -o StrictHostKeyChecking=no ubuntu@${SWARM_MASTER_IP} docker stack deploy --compose-file=/home/ubuntu/docker-compose.yml test-stack
