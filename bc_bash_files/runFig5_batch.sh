#!/bin/bash

for t1 in {1,3,5,7,9,11}; do
	  t2=$((t1+1))
	      echo ""
	      echo 4 $t1 $t2
	      sbatch runFig5.sh 4 1.0 $t1 $t2

done
