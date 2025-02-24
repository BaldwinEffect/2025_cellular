o#!/bin/bash

t1=1
t2=51
sbatch runCoop.sh "1" "false" 1.0 "1" "25"
sbatch runCoop.sh "1" "false" 1.0 "26" "50"
sbatch runCoop.sh "1" "false" 1.0 "51" "75"
sbatch runCoop.sh "1" "false" 1.0 "75" "100"
sbatch runCoop.sh "1" "false" 1.0 "101" "125"
sbatch runCoop.sh "1" "false" 1.0 "126" "150"
sbatch runCoop.sh "1" "false" 1.0 "151" "175"
sbatch runCoop.sh "1" "false" 1.0 "175" "200"


 
