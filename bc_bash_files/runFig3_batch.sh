#!/bin/bash

for t1 in {1,21,41,61,81}; do
	  t2=$((t1+19))
	  sbatch runFig3.sh 1 1.0 $t1 $t2
	  for a in {2..10}; do
	      echo ""
	      echo $a $t1 $t2
	      sbatch runFig3.sh $a 0.0 $t1 $t2
	      sbatch runFig3.sh $a 1.0 $t1 $t2

	  done
done
