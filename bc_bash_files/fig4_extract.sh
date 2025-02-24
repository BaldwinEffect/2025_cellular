#!/bin/bash

for t1 in {1,11,21,31,41,51,61,71,81,91}; do
	  t2=$((t1+9))

	  grep "10000" < 2025-02-20_fig4_0.0_${t1}_${t2}.txt >> fig4_extract.txt

done
