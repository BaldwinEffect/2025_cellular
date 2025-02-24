#!/bin/bash 

#SBATCH --mem=10000M
#SBATCH --partition=cpu
#SBATCH --job-name=fig1
#SBATCH --time=23:00:00
#SBATCH --nodes=1
#SBATCH --account COSC016682

module purge
module add languages/julia/1.10.3


cd "${SLURM_SUBMIT_DIR}"

julia fig4.jl $1 $2 $3 $4 

hostname
