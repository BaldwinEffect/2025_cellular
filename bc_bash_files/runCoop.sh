#!/bin/bash 

#SBATCH --mem=10000M
#SBATCH --partition=cpu
#SBATCH --job-name=ca
#SBATCH --time=23:00:00
#SBATCH --nodes=1
#SBATCH --account COSC016682

module purge
module add languages/julia/1.10.3


cd "${SLURM_SUBMIT_DIR}"

julia cooperate.jl $1 $2 $3 $4 $5

hostname
