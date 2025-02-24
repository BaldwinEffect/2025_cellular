o#!/bin/bash

t1=1
t2=50

for a in {1..1}; do
    echo ""
    echo $a $t1 $t2
    sbatch runFig1.sh $a  1.0 $t1 $t2
done

t1=51
t2=100

for a in {1..1}; do
    echo ""
    echo $a $t1 $t2
    sbatch runFig1.sh $a  1.0 $t1 $t2
done


t1=101
t2=150

for a in {1..1}; do
    echo ""
    echo $a $t1 $t2
    sbatch runFig1.sh $a  1.0 $t1 $t2
done


t1=151
t2=200

for a in {1..1}; do
    echo ""
    echo $a $t1 $t2
    sbatch runFig1.sh $a  1.0 $t1 $t2
done

    
