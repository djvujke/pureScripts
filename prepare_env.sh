#!/bin/bash

# Install what we need
yum install -y git sshpass bind-utils

# Create disks on flasharray1
username=pureuser
password=pureuser
STRG1=10.0.0.11
STRG2=10.0.0.21

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

# Create replication between STRG1 and STRG2
$SSH $STRG1 purepod create B1POD
$SSH $STRG1 purepgroup create B1POD::B1PG
$SSH $STRG1 purevol add --pgroup B1POD:B1PG B1Data
$SSH $STRG1 purevol add --pgroup B1POD:B1PG B1Log
$SSH $STRG1 purevol add --pgroup B1POD:B1PG B1Path

# On STRG2  
$SSH $STRG2 purepod create B1POD-DR
$SSH $STRG2 purepod demote B1POD-DR

$SSH $STRG2 purepod create B2POD-DR
$SSH $STRG2 purepod demote B2POD-DR

$SSH $STRG2 purepod create B3POD-DR
$SSH $STRG2 purepod demote B3POD-DR

# Create replica link  
$SSH $STRG1 purepod replica-link create B1POD --remote-pod B1POD-DR --remote $STRG2
$SSH $STRG1 purepod replica-link create B2POD --remote-pod B2POD-DR --remote $STRG2
$SSH $STRG1 purepod replica-link create B3POD --remote-pod B3POD-DR --remote $STRG2

$SSH $STRG1 purepod replica-link list

# Create replication between STRG2 and STRG2

$SSH $STRG2 purepod create B2POD
$SSH $STRG2 purepgroup create B2POD::B2PG
$SSH $STRG2 purevol add --pgroup B2POD:B2PG B2Data
$SSH $STRG2 purevol add --pgroup B2POD:B2PG B2Log
$SSH $STRG2 purevol add --pgroup B2POD:B2PG B2Path

$SSH $STRG2 purepod create B2POD
$SSH $STRG2 purepgroup create B2POD::B2PG
$SSH $STRG2 purevol add --pgroup B2POD:B2PG B2Data
$SSH $STRG2 purevol add --pgroup B2POD:B2PG B2Log
$SSH $STRG2 purevol add --pgroup B2POD:B2PG B2Path

$SSH $STRG2 purepod create B2POD
$SSH $STRG2 purepgroup create B2POD::B2PG
$SSH $STRG2 purevol add --pgroup B2POD:B2PG B2Data
$SSH $STRG2 purevol add --pgroup B2POD:B2PG B2Log
$SSH $STRG2 purevol add --pgroup B2POD:B1PG B1Path

