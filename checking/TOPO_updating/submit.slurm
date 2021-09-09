#!/bin/tcsh

#SBATCH -J ATM_topo
#SBATCH -n 1
#SBATCH --ntasks-per-node=1
#SBATCH -t 01:00:00
#SBATCH -p dav
#SBATCH -e job-name.err.%J
#SBATCH -o job-name.out.%J


setenv TMPDIR /glade/scratch/$USER/temp
mkdir -p $TMPDIR

module load ncl

./run_ATM_topo_check.sh
