#!/bin/bash

set -ex

user=lmuntje

# provide location of data (history files)
#indir=/glade/collections/cdg/timeseries-cmip6/b.e21.B1850G.f09_g17_gl4.CMIP6-piControl-withism.001/lnd/proc/tseries/month_1/
indir=/glade/scratch/lmuntje/CESM21_ctrl_landdata

# make opruimdir
opruimdir=/glade/work/$user/CESM2.1/ISMIP6/b.e21.B1850G.f09_g17_gl4.CMIP6-piControl-withism.001/lnd/
# make opruimdir if not already exists
if [ -d "$opruimdir" ]; then
    echo "$opruimdir exists."
else 
    echo "$opruimdir does not exist."
    mkdir -p "$opruimdir"
fi


# 1) provide variable list 
declare -a varnames
#varnames=(EFLX_LH_TOT EFLX_LH_TOT_ICE FSDS FSR FSR_ICE FSA QICE_MELT FLDS FLDS_ICE FIRE FIRE_ICE FSH FSH_ICE)
#varnames=(RAIN RAIN_ICE SNOW SNOW_ICE QSNOFRZ QSNOFRZ_ICE QSNOMELT_ICE QSNOMELT QICE QICE_MELT QICE_FRZ QSOIL QSOIL_ICE)
#varnames=(EFLX_LH_TOT_ICE FSDS FSR FSR_ICE FSA QICE_MELT FLDS FLDS_ICE FIRE FIRE_ICE FSH FSH_ICE RAIN RAIN_ICE SNOW SNOW_ICE QSNOFRZ QSNOFRZ_ICE QSNOMELT_ICE QSNOMELT QICE QICE_MELT QICE_FRZ QSOIL QSOIL_ICE SNOW_PERSISTENCE SNOW_DEPTH SNOWDP H2OSNO TG TG_ICE TSA TSA_ICE ATM_TOPO FIRA SNOWICE SNOWICE_ICE SNOWLIQ SNOWLIQ_ICE)
varnames=(ICE_MODEL_FRACTION PCT_LANDUNIT)


# 2) make timeseries
for var in "${varnames[@]}"; do
  file1="$indir"/b.e21.B1850G.f09_g17_gl4.CMIP6-piControl-withism.001.clm2.h0."$var".000101-005012.nc
  echo $file1
  file2="$indir"/b.e21.B1850G.f09_g17_gl4.CMIP6-piControl-withism.001.clm2.h0."$var".005101-010012.nc
  file3="$indir"/b.e21.B1850G.f09_g17_gl4.CMIP6-piControl-withism.001.clm2.h0."$var".010101-015012.nc
  file4="$indir"/b.e21.B1850G.f09_g17_gl4.CMIP6-piControl-withism.001.clm2.h0."$var".015101-020012.nc
  file5="$indir"/b.e21.B1850G.f09_g17_gl4.CMIP6-piControl-withism.001.clm2.h0."$var".020101-025012.nc
  file6="$indir"/b.e21.B1850G.f09_g17_gl4.CMIP6-piControl-withism.001.clm2.h0."$var".025101-030012.nc

  fullfile="$opruimdir"/b.e21.B1850G.f09_g17_gl4.CMIP6_CTRL_full.001.clm2.h0."$var".nc
  ncrcat -O $file1 $file2 $file3 $file4 $file5 $file6 $fullfile

  echo $fullfile

done
