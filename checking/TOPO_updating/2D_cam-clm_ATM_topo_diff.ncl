load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "/gpfs/u/home/lmuntje/analysis/ncl/libs/maps.ncl"
load "/gpfs/u/home/lmuntje/analysis/ncl/vars/clm.ncl"
;************************************************
begin
;************************************************


 err = NhlGetErrorObjectId()
 setvalues err
  "errLevel" : "Fatal"          ; only report Fatal errors
 end setvalues

;===============
; Details about run

;= status of the simulation, and the years requested. I.e. are they in archive of in the run directory.
; options: "archive", "running"
 status = status

;= experiment simulation details   # CAM restart file
 run    = run1
 shortn = short1
 period = period1


;= control simulation details       # CLM hist. file
 run_ctrl       = run2
 shortn_ctrl    = short2
 period_ctrl	= period2



;===============


 varlist = (/"ATM_TOPO"/)
 CONST_G       = 9.80616   ; ../cime/src/share/util/shr_const_mod.F90:   real(R8),parameter :: SHR_CONST_G       = 9.80616_R8      ! acceleration of gravity ~ m/s^2

 if ( status .eq. "archive" ) then
    fname      =scratch+"archive/"+run+"/rest/"+period+"-01-01-00000/"+run+".cam.r."+period+"-01-01-00000.nc"
    fname_ctrl =scratch+"archive/"+run_ctrl+"/lnd/hist/"+run_ctrl+".clm2.h0."+period_ctrl+"-12.nc"
 else if ( status .eq. "running" ) then
    fname      =scratch+"/"+run+"/"+run+".cam.r."+period+"-01-01-00000.nc"
    fname_ctrl =scratch+"/"+run_ctrl+"/"+run_ctrl+".clm2.h0."+period_ctrl+"-12.nc"
 else
    print("Provide whether the year is in the 'archive' or in the 'running' directory of the simulation ")
 end if
 end if




 print(fname)
 print(fname_ctrl)
 f = addfile(fname,"r")
 f_ctrl = addfile(fname_ctrl,"r")


  data = f->PHIS(:,:)/CONST_G   ; PHIS is the Surface geopotential height. This is topography multiplied by the gravity potential (topo x g). If you divide by 9.81 you get it in meters.
  data_ctrl = f_ctrl->ATM_TOPO(0,:,:)


  dims = dimsizes(data)



   data_anom = data - data_ctrl

   data!0 = "lat"
   data!1 = "lon"
   data&lat = data_ctrl&lat
   data&lon = data_ctrl&lon

   data_ctrl!0 = "lat"
   data_ctrl!1 = "lon"

   data_anom!0 = "lat"
   data_anom!1 = "lon"
   data_anom&lat = data_ctrl&lat
   data_anom&lon = data_ctrl&lon
   copy_VarAtts(data,data_anom)


  ; start plotting -----------------------------


   map_area = "greenland"
   pvalue_test = 0.01
   wks_type = "png"
   wks_type@wkWidth = 3000
   wks_type@wkHeight = 3000


   ; the script places the figure right in the local plots folder
   figname = "plots/" + map_area +"_"+ run +"_ATM_TOPO_diff_" + period1 + ".r.CAM-" + period2 + ".h0.01.CLM"


   map = map_specs(map_area)


   maxes = (/ min(data({map@minlat:map@maxlat},{map@minlon:map@maxlon})), max(data({map@minlat:map@maxlat},{map@minlon:map@maxlon})), min(data_ctrl({map@minlat:map@maxlat},{map@minlon:map@maxlon})), max(data_ctrl({map@minlat:map@maxlat},{map@minlon:map@maxlon})) /)

   wks = gsn_open_wks(wks_type, figname)
   res                         = True

   res@gsnDraw                 = False
   res@gsnFrame                = False
   res@cnFillOn                = True
   res@cnFillMode              = "RasterFill"
   res@cnLinesOn               = False
   res@cnLineLabelsOn          = False
   res@lbOrientation           = "horizontal"
   res@lbBoxEndCapStyle        = "TriangleBothEnds"
   res@mpFillOn                = True
   res@mpFillDrawOrder         = "PostDraw"
   res@mpLandFillColor         = "Transparent"
   res@mpOceanFillColor        = "Grey"
   res@mpInlandWaterFillColor  = "Grey"
   res@mpGridMaskMode          = "MaskFillArea"
   res@mpProjection            = map@projection
   res@mpLimitMode             = map@limitmode
   res@mpMaxLatF               = map@maxlat
   res@mpMinLatF               = map@minlat
   res@mpMaxLonF               = map@maxlon
   res@mpMinLonF               = map@minlon
   res@mpCenterLonF            = map@centerlon
   res@mpDataBaseVersion       = "MediumRes"
   res@tmXTOn                  = False
   res@tmXBOn                  = False
   res@tmYLOn                  = False
   res@tmYROn                  = False
   res@tmXBLabelsOn            = False
   res@tmXTLabelsOn            = False
   res@tmYLLabelsOn            = False
   res@tmYRLabelsOn            = False

   res@tiYAxisString           = shortn
   plot_data = gsn_csm_contour_map(wks,data,res)

   res@tiYAxisString           = shortn_ctrl
   plot_data_ctrl = gsn_csm_contour_map(wks,data_ctrl,res)


   res@tiYAxisString           = shortn + " - " + shortn_ctrl
   res@cnFillPalette           = "cmocean_balance"
   res@cnLevelSelectionMode    = "ExplicitLevels"
   maxes2 = abs((/ min(data_anom), max(data_anom)/))
   delete(res@cnLevels)
   ;res@cnLevels			=(/ -200.0, -150., -125., -100., -75., -50., -40., -30., -20., -10., 0, 10., 20., 30., 40., 50., 75., 100., 125., 150., 200. /)
   ;res@cnLevels			=(/-1.0, -0.8,  -0.6, -0.5, -0.4, -0.3, -0.25, -0.2, -0.15, -0.1, -0.05, 0, 0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 0.4, 0.5, 0.6, 0.8, 1.0 /)
   res@cnLevels                 =(/ -64., -32., -16., -8., -4., -2., -1., -0.5, -0.25, -0.1, 0., 0.1, 0.25, 0.5, 1., 2., 4., 8., 16., 32., 64./)
   plot_data_anom = gsn_csm_contour_map(wks,data_anom,res)



   plots = (/ plot_data, plot_data_ctrl, plot_data_anom /)

   pres                       = True
   gsn_panel(wks,plots,(/1,3/),pres)



end
