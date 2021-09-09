#!/bin/bash

set -ex

# script to check the TOPO-updating in the ISMIP simulations
# produces: - a figure with CISM thickness differences of two files that are 9 years apart
#							i.e. one right at the moment of CAM topo updating, and one 9 years earlier just after the previous topo-updating.
#			- a figure with the ATM_TOPO in CLM before the topo_updating and the PHIS/9.81 from the CAM.r. restart file after the updating, and the differences
#
#
# user input:
# 	- casename
casename="b.e21.B1850G.f09_g17_gl4.CMIP6-ssp534os-withism.001"  # provide casename between " "

#   - location of data (scratch folder usually)
scratch="/glade/scratch/katec/"  # provide the scratch directory where the data is
state_sim="archive" 		# "archive" of "running"

# 	- restart year
yearCAM=2060 			# this is the year of the CAM restart file --- after TOPO-updating

#   - choose to plot either the CAM of the CISM difference fields by
#plot="glc" 			# plot CISM ("glc") or plot CLM/CAM ("atmlnd")
plot="atmlnd"			# can be 1 at the time




# --------- END of user edit section -----------------------------------------------------------


mkdir -p ./plots

if [ $casename == "b.e21.B1850G.f09_g17_gl4.CMIP6-piControl-withism.001" ] ; then
    short="piControl-withism"
elif [ $casename == "b.e21.B1850G.f09_g17_gl4.CMIP6-1pctCO2to4x-withism.001" ] ; then
    short="1pctCO2to4x-withism"
elif [ $casename == "b.e21.B1850G.f09_g17_gl4.CMIP6-ssp534os-withism.001" ] ; then
    short="SSP534os-withism"
else short=casename;
fi


printf -v yearCAMr "%04d" $yearCAM
yearCLM=$(expr $yearCAM - 1)					# get the CLM file 1 year prior, before the topo updating

printf -v yearCLMh "%04d" $yearCLM
echo "CLM year is: " $yearCLMh
echo "CAM year is: " $yearCAMr

yearCISMe=$(expr $yearCAM - 9 )				# get the CISM file 9 year prior, just after the previous topo updating
#yearCISMe=$(expr $yearCAM - 1 )                        # testing only
printf -v yearCISM "%04d" $yearCISMe

echo "CISM early year is: " $yearCISM
echo "CISM current year is: " $yearCAMr

short1="$short".CAM."$yearCAMr"
short2="$short".CLM."$yearCLMh"

short3="$short".CISM."$yearCAMr"
short4="$short".CISM."$yearCISM"

echo " plot is: " $plot
if [ $plot == "atmlnd" ] ; then
      ncl   "run1=\"${casename}\""    "short1=\"${short1}\""  "period1=\"${yearCAMr}\""  \
            "run2=\"${casename}\""    "short2=\"${short2}\""  "period2=\"${yearCLMh}\""  \
            "status=\"${state_sim}\"" \
            2D_cam-clm_ATM_topo_diff.ncl
elif [ $plot == "glc" ] ; then
     ncl   "cism2=\"${casename}\""    "case2=\"${short3}\"" "period2=\"${yearCAMr}\""  \
       	   "cism1=\"${casename}\""    "case1=\"${short4}\"" "period1=\"${yearCISM}\""  \
           2D_CISM_thk_diff.ncl
else echo "nothing to plot";
fi
