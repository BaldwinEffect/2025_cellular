o#!/bin/bash

t1=99
t2=99

for a in {4..4}; do
    echo ""
    echo $a $t1 $t2
    sbatch runFig2.sh $a 0.0 $t1 $t2
done

t1=100
t2=100

for a in {4..4}; do
    echo ""
    echo $a $t1 $t2
    sbatch runFig2.sh $a 0.0 $t1 $t2
done
