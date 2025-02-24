#!/bin/bash

for t1 in {1,11,21,31,41,51,61,71,81,91}; do
	  t2=$((t1+9))
	      echo ""
	      echo 4 $t1 $t2
	      sbatch runFig4.sh 4 0.0 $t1 $t2


done
