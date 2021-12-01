#!/bin/bash

set -ex

user=lmuntje
outdir="/glade/scratch/$user/temp_atm"

#------------------------------------------
# case details
#------------------------------------------
startyear=1
endyear=300

declare -a casenames
casenames=(b.e21.B1850G.f09_g17_gl4.CMIP6-piControl-withism.001)

declare -a varlist
varlist=(TREFHT ICEFRAC PRECT QREFHT CLDTOT LHFLX SHFLX SNOWHLND SNOWHICE)

#indir="/glade/scratch/katec/CESM21-CISM2-JG-BG-Dec2018/archive/"
indir="/glade/scratch/cmip6/archive/b.e21.B1850G.f09_g17_gl4.CMIP6-piControl-withism.bad_topo"
#indir="/glade/scratch/cmip6/archive/"

#oprdir="/glade/work/$user/CESM21-CISM2-JG-BG-Dec2018"
oprdir="/glade/work/$user/CESM2.1/ISMIP6/"




#-----------------------------------------

# make temp dir if not already exists
mkdir -p $outdir

# empty outdir if there's still netcdf files in there
if [ -f "$outdir"/*.nc ]; then
  rm "$outdir"/*.nc
fi



for casename in ${casenames[@]}; do
  echo $casename
  # make folder to put the finished product in 
  opruimdir="$oprdir"/"$casename"/atm/rproc/timeseries/
  mkdir -p $opruimdir
  olddir=$opruimdir/old
  mkdir -p $olddir
  # if there's analyses in the opruimdir, move them to olddir
  if [ -f "$opruimdir"/*.nc ]; then
    mv "$opruimdir"/*.nc $olddir/.
  fi

  for var in ${varlist[@]}; do
    echo $var
    for year in $(seq -f "%04g" $startyear $endyear); do
      for month in $(seq -f "%02g" 1 12); do
#           cdo selvar,"$var" "$indir"/"$casename"/atm/hist/"$casename".cam.h0."$year"-"$month".nc "$outdir"/"$var"_"$casename".cam.h0."$year"-"$month".nc
           cdo selvar,"$var" "$indir"/atm/hist/"$casename".cam.h0."$year"-"$month".nc "$outdir"/"$var"_"$casename".cam.h0."$year"-"$month".nc
      done
    done
    cdo cat "$outdir"/"$var"_"$casename".cam.h0.*.nc "$opruimdir"/"$var"_"$casename".cam.h0."$startyear"-"$endyear".nc
    rm "$outdir"/"$var"_"$casename".cam.h0.*.nc
  done
done

