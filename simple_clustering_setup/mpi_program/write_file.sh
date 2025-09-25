#!/bin/bash

if [[ "$(hostname)" == "node1" || "$(hostname)" == "node2" ]]; then
  echo "Clustered Node $(hostname) says hello at $(date)" >> /home/mpiuser/shared/output.txt
else
  echo "Node $(hostname) is observing the file:"
  cat /home/mpiuser/shared/output.txt
fi