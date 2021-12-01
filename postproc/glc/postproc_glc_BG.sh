#!/bin/bash

set -ex

user=lmuntje

# set temp dir
tempdir=/glade/scratch/"$user"/temp_glc
# set dir where the data is
indir=/glade/scratch/"$user"/archive/
# set dir where to move the merged files
outdir=/glade/work/"$user"/CESM2.1/ISMIP6/


# make tempdir if not already exists
if [ -d "$tempdir" ]; then
    echo "$tempdir exists."
else 
    echo "$tempdir does not exist."
    mkdir -p "$tempdir"
fi
# empty tempdir if there's still netcdf files in there
if [[ -f "$tempdir"/*.nc ]]; then
  rm "$tempdir"/*.nc
fi

# provide casenames list
declare -a casenames
casenames=(b.e21.B1850G.f09_g17_gl4.CMIP6-1pctCO2to4x-withism.001)
#casenames=(b.e21.B1850G.f09_g17_gl4.CMIP6-1pctCO2to4x-withism.bad_topo.0719 b.e21.B1850G.f09_g17_gl4.CMIP6-piControl-withism.bad_topo)

# provide variable list 
declare -a varnames1
declare -a varnames2
varnames1=(iarea ivol total_bmb_flux_tavg total_calving_flux_tavg total_smb_flux_tavg)
varnames2=(iarea ivol total_bmb_flux_tavg total_calving_flux_tavg total_smb_flux_tavg mass_balance)

# work: create timeseries 
for casename in ${casenames[@]} ; do
  casedir="$indir"/"$casename"/glc/hist/
  opruimdir="$outdir"/"$casename"/glc/postproc/timeseries/

  # set/make directories where to put the created data
  if [ -d "$opruimdir" ]; then
      echo "$opruimdir exists."
  else 
      echo "$opruimdir does not exist."
      mkdir -p $opruimdir
  fi
  olddir="$opruimdir"/old
  if [ -d "$olddir" ]; then
      echo "$olddir exists."
  else 
      echo "$olddir does not exist."
      mkdir -p $olddir
  fi
  # if there's analyses in the opruimdir, move them to olddir
  if [[ -f "$opruimdir"/*.nc ]]; then
    mv "$opruimdir"/*.nc $olddir/.
  fi

  for var in "${varnames1[@]}"; do
    for file in `ls "$casedir"/"$case".cism.h.*`; do
       #1. take variable (-v) from infile, and create (-C) outfile
       ncks -C -v $var $file "$tempdir"/"$var"_`basename $file`
    done

    # concatenate timeslices into timeseries
    cdo cat "$tempdir"/"$var"_*.cism.h.*.nc "$opruimdir"/"$casename".cism.h.timeseries."$var".nc
    #mv "$tempdir"/*"$casename"*timeseries* "$opruimdir"/.
  done

  # compute MB
  for file in `ls "$casedir"/"$case".cism.h.*`; do
    cdo -expr,"mass_balance=total_smb_flux_tavg+total_bmb_flux_tavg+total_calving_flux_tavg" $file "$tempdir"/mass_balance_`basename $file`
  done
  cdo cat "$tempdir"/mass_balance_"$casename".cism.h.*.nc "$opruimdir"/"$casename".cism.h.timeseries.mass_balance.nc

  # running mean SMB and MB
  nts=10
  cdo runmean,$nts $opruimdir/"$casename".cism.h.timeseries.total_smb_flux_tavg.nc $opruimdir/"$nts"yr-runmean_"$casename".cism.h.timeseries.total_smb_flux_tavg.nc


  # empty tempdir
  rm "$tempdir"/*.nc
done
