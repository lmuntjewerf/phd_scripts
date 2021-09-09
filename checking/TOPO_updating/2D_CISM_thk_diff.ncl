;*************************************************
; gland_1.ncl
;
; Concepts illustrated:
;   - Plotting Greenland merged data
;   - Using projection data on the file 
;   - Use side-by-side paneling to examine the mapping difference
;   - draw via panels
;*****************************************************
; 
; NCL's mapping software operates in spherical space, but WGS84 
; and systems like it describe an ellipsoid not a sphere. 
; As a result, there are some slight differences from the
; native projection (left) and the map using lat2d/lon2d.
;*****************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"    

  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

  load "/glade/u/home/lvank/analysis/libncl/monthly_to_season.ncl"
  load "/glade/u/home/lvank/analysis/libncl/get_racmo_data.ncl"
  ;load "/glade/u/home/lvank/analysis/libncl/map_greenland.ncl"
 
  load "/glade/u/home/lmuntje/analysis/CISM/map_greenland.ncl"
 
  load "/gpfs/u/home/lmuntje/analysis/CISM/resources.ncl"
 

;************************************************
; get env variables 
;************************************************


  cism1=cism1
  case1=case1
  period1=period1

  
  cism2=cism2
  case2=case2
  period2=period2



begin 

;************************************************
; read in netCDF file
;************************************************

  ;scratch="/glade/scratch/cmip6/"
  scratch="/glade/scratch/katec/"

  file1		=scratch+"archive/"+cism1+"/glc/hist/"+cism1+".cism.h."+period1+"-01-01-00000.nc"
  file2		=scratch+"archive/"+cism2+"/glc/hist/"+cism2+".cism.h."+period2+"-01-01-00000.nc"
  
  
  
;  file1		="/glade/scratch/lmuntje/archive/ig.e20.IHISTCLM50BGCG.f09_g17.B003forcing_eigencalv_PDinit/glc/hist/ig.e20.IHISTCLM50BGCG.f09_g17.B003forcing_eigencalv_PDinit.cism.h.0050-01-01-00000.nc"
;  file2		="/glade/scratch/lmuntje/archive/ig.e20.IHISTCLM50BGCG.f09_g17.B003forcing_eigencalv_PDinit_cism60/glc/hist/ig.e20.IHISTCLM50BGCG.f09_g17.B003forcing_eigencalv_PDinit_cism60.cism.h.0050-01-01-00000.nc" 
;  restfile	="/glade/scratch/lmuntje/archive/ig.e20.IHISTCLM50BGCG.f09_g17.B003forcing_eigencalv_PDinit/rest/0051-01-01-00000/ig.e20.IHISTCLM50BGCG.f09_g17.B003forcing_eigencalv_PDinit.cism.r.0051-01-01-00000.nc"

;  file1 = "/glade/scratch/lmuntje/archive/ig.e20.IHISTCLM50BGCG.f09_g17.B003forcing_eigencalv_PDinit_Tinit_63/glc/hist/ig.e20.IHISTCLM50BGCG.f09_g17.B003forcing_eigencalv_PDinit_Tinit_63.cism.h.0031-01-01-00000.nc"
;  file2 = "/glade/scratch/lmuntje/archive/ig.e20.IHISTCLM50BGCG.f09_g17.test.4.noTinit_63/glc/hist/ig.e20.IHISTCLM50BGCG.f09_g17.test.4.noTinit_63.cism.h.0031-01-01-00000.nc"
; restfile = "/glade/scratch/lmuntje/archive/ig.e20.IHISTCLM50BGCG.f09_g17.B003forcing_eigencalv_PDinit_Tinit_63/rest/0031-01-01-00000/ig.e20.IHISTCLM50BGCG.f09_g17.B003forcing_eigencalv_PDinit_Tinit_63.cism.r.0031-01-01-00000.nc"

;  file1		="/glade/scratch/sbradley/archive/alphagr4_T1850G/glc/hist/alphagr4_T1850G.cism.h.9901-01-01-00000.nc"
;  file2		="/glade/scratch/lmuntje/archive/tg.e20.T1850G.f09_g17.testing.012/glc/hist/tg.e20.T1850G.f09_g17.testing.012.cism.h.9901-01-01-00000.nc"
;  restfile	="/glade/scratch/lmuntje/archive/b.e20.BHIST.f09_g17.testing.003/rest/1964-01-03-00000/b.e20.BHIST.f09_g17.testing.001e.cism.r.1964-01-03-00000.nc"
  restfile="/glade/p/cesm/liwg/JG_BG_setup_and_initial_conditions/archivebkup_Dec2018/BG_iteration_1/rest/0002-01-01-00000/BG_iteration_1.cism.r.0002-01-01-00000.nc"

  fili1 = addfile(file1,"r")
  fili2 = addfile(file2,"r")
  fili3 = addfile(restfile,"r")

  lat = fili3->lat
  lon = fili3->lon

  thk1 = fili1->thk
  thk1 = thk1 * thk1@scale_factor
  thk1@_FillValue = default_fillvalue(typeof(thk1))
  thk2 = fili2->thk
  thk2 = thk2 * thk2@scale_factor
  thk2@_FillValue = default_fillvalue(typeof(thk2))
  diff = thk2 - thk1


  topg1 = fili1->topg
  topg1 = topg1 * topg1@scale_factor
  topg1 = topg1
  topg2 = fili2->topg
  topg2 = topg2 * topg2@scale_factor

  topo1 = topg1 + thk1
  topo1 :=rm_single_dims(topo1)
  topo2 = topg2 + thk2
  topo2 :=rm_single_dims(topo2)


  topo1@_FillValue = default_fillvalue(typeof(topo1))
  topo2@_FillValue = default_fillvalue(typeof(topo2))

  lon := rm_single_dims(lon)
  lat := rm_single_dims(lat)

  thk1 := rm_single_dims(thk1)
  thk1@lat2d = lat
  thk1@lon2d = lon

  thk2 := rm_single_dims(thk2)
  thk2@lat2d = lat
  thk2@lon2d = lon

  diff := rm_single_dims(diff)
  diff@lat2d = lat
  diff@lon2d = lon


  topo1@lat2d = lat
  topo1@lon2d = lon
  
  topo2@lat2d = lat
  topo2@lon2d = lon



;************************************************
; read variables; plot 
;************************************************

  map_area="greenland"
  outname = "plots/" + map_area +"_"+ cism1 +"_THK_diff_" + period1 + ".CISM-" + period2 + ".CISM"
  wks = gsn_open_wks("png",outname)


   ; panel plotting 
   resat1 = True
   resat2 = True
   resat3 = True
   resat1@gsnMaximize         = True
   resat2@gsnMaximize         = True
   resat3@gsnMaximize         = True


   ; -----------------------------------------------------------------------------
   ; -----------------------------------------------------------------------------


   pres = True
   pres@gsnPanelMainString = "Thickness"


   label1 = case1 
   label2 = case2 
   label_diff = "difference [b - a]"

   res@gsnCenterString            = label1
   res2@gsnCenterString           = label2
   res4@gsnCenterString           = label_diff

   my_levels            	   := (/ 1, 25, 50, 100, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 1250, 1500, 1750, 2000, 2500, 3000 /)  ;19 colors
   res@cnFillPalette		   = "rh_19lev"
   res2@cnFillPalette		   = "rh_19lev"
   res@lbTitleString   	           = "thickness [m]"
   res4@lbTitleString              = "diff thickness [m]"

   setLevels(my_levels)


   print("plotting " +res@lbTitleString)

   pplot := new(3, graphic)
	pplot(0) = getGreenlandMap(wks)
	pplot(1) = getGreenlandMap(wks)
	pplot(2) = getGreenlandMap(wks)


   overlayLeftLabelbar(wks, pplot(0), thk1, res)
   overlayNoLabelbar(wks, pplot(1), thk2, res2)

   ;my_diff_levels                       := (/ -1500, -1000, -800, -600, -400, -200, -100, -50, -25, 0, 25, 50, 100, 200, 400, 600, 800, 1000, 1500 /)
   ;my_diff_levels			:= (/ -750, -500, -375, -250, -175, -100, -50, -25, -10, 0, 10, 25, 50, 100, 175, 250, 375, 500, 750 /)    		; 19 colors
   ;my_diff_levels 			:=(/-400,-200,-100,-50,-35, -20,-10,-5,-1,0,1,5,10, 20, 35, 50, 100,200, 400/)
   my_diff_levels                 =(/ -64., -32., -16., -8., -4., -2., -1., -0.5, -0.25, -0.1, 0., 0.1, 0.25, 0.5, 1., 2., 4., 8., 16., 32., 64./)

   setLevels(my_diff_levels)
   res4@cnFillPalette       = "cmocean_balance"
   overlayLeftLabelbar(wks, pplot(2), diff, res4)
   
;   overlayHeight(wks, pplot(0), topo1)
;   overlayHeight(wks, pplot(1), topo2)
   overlayCoast(wks, pplot(0))
   overlayCoast(wks,pplot(1))
   overlayCoast(wks,pplot(2))
   
   gsn_panel(wks, (/pplot(0),pplot(1),pplot(2)/), (/1,3/),pres)

end








