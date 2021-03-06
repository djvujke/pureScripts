#!/bin/bash

# Install what we need
yum install -y git sshpass bind-utils expect

# Create disks on flasharray1
username=pureuser
password=pureuser
STRG1=10.0.0.11
STRG2=10.0.0.21

#generate ssh key don't ask
ssh-keygen -t rsa -N ''    

# edit hosts file
echo "10.0.0.11  flasharray1" >> /etc/hosts
echo "10.0.0.21  flasharray2" >> /etc/hosts

SSH="/bin/sshpass -p $password ssh -oStrictHostKeyChecking=no -l $username "

# Create test Volumes
$SSH $STRG1 purevol create --size 1G B1Data
$SSH $STRG1 purevol create --size 2G B1Log
$SSH $STRG1 purevol create --size 3G B1Path

$SSH $STRG1 purevol create --size 4G B2Data
$SSH $STRG1 purevol create --size 5G B2Log
$SSH $STRG1 purevol create --size 6G B2Path

$SSH $STRG1 purevol create --size 7G B3Data
$SSH $STRG1 purevol create --size 8G B3Log
$SSH $STRG1 purevol create --size 9G B3Path

$SSH $STRG1 purevol create --size 1G B4Data
$SSH $STRG1 purevol create --size 2G B4Log
$SSH $STRG1 purevol create --size 3G B4Path


# Create replication between STRG1 and STRG2
$SSH $STRG1 purepod create B1POD
$SSH $STRG1 purepgroup create B1POD::B1PG
$SSH $STRG1 purevol move B1Data B1POD
$SSH $STRG1 purevol move B1Log B1POD
$SSH $STRG1 purevol move B1Path B1POD
$SSH $STRG1 purevol add --pgroup B1POD::B1PG B1POD::B1Data
$SSH $STRG1 purevol add --pgroup B1POD::B1PG B1POD::B1Log
$SSH $STRG1 purevol add --pgroup B1POD::B1PG B1POD::B1Path

$SSH $STRG1 purepod create B2POD
$SSH $STRG1 purepgroup create B2POD::B2PG
$SSH $STRG1 purevol move B2Data B2POD
$SSH $STRG1 purevol move B2Log B2POD
$SSH $STRG1 purevol move B2Path B2POD
$SSH $STRG1 purevol add --pgroup B2POD::B2PG B2POD::B2Data
$SSH $STRG1 purevol add --pgroup B2POD::B2PG B2POD::B2Log
$SSH $STRG1 purevol add --pgroup B2POD::B2PG B2POD::B2Path

$SSH $STRG1 purepod create B3POD
$SSH $STRG1 purepgroup create B3POD::B3PG
$SSH $STRG1 purevol move B3Data B3POD
$SSH $STRG1 purevol move B3Log B3POD
$SSH $STRG1 purevol move B3Path B3POD
$SSH $STRG1 purevol add --pgroup B3POD::B3PG B3POD::B3Data
$SSH $STRG1 purevol add --pgroup B3POD::B3PG B3POD::B3Log
$SSH $STRG1 purevol add --pgroup B3POD::B3PG B3POD::B3Path

# CLI command to connect 2 flasharrays for replication purpose
ConnKey=$($SSH $STRG2 purearray list --connection-key|cut -d " " -f 3)
echo $ConnKey | $SSH $STRG1 purearray connect --management-address $STRG2 --type async-replication --connection-key

# On STRG2  
$SSH $STRG2 purepod create B1POD-DR
$SSH $STRG2 purepod demote B1POD-DR

$SSH $STRG2 purepod create B2POD-DR
$SSH $STRG2 purepod demote B2POD-DR

$SSH $STRG2 purepod create B3POD-DR
$SSH $STRG2 purepod demote B3POD-DR

# Create replica link  
# $SSH $STRG1 purepod replica-link create B1POD --remote-pod B1POD-DR --remote $STRG2
# $SSH $STRG1 purepod replica-link create B2POD --remote-pod B2POD-DR --remote $STRG2
# $SSH $STRG1 purepod replica-link create B3POD --remote-pod B3POD-DR --remote $STRG2
# $SSH $STRG1 purepod replica-link list
