* num: #num corner: #corner vdd: #vdd temp: #temp

* Include SkyWater sky130 device models
.lib /usr/local/share/pdk/sky130A/libs.tech/combined/sky130.lib.spice #corner
.temp #temp

*.include ../../netlists/ddab.spice
.include ../../../magic/ddab.spice

* Simulation parameters
.param xvdd  = #vdd
.param xvss  = 0
.param xcm   = {#vdd/2}

.param xip =  1
.param xim = -1

.param xci    = 1T
.param xri    = 1T
.param xlf    = 1T
.param xrf    = 1f
.param xcl    = 10p
.param xrl    = 1T

v_vdd vdd 0 dc {xvdd}
v_vss vss 0 dc {xvss}
v_cm  cm  0 dc {xcm}

vx  x  cm 0
bin in cm v = {v(x,cm)*v(x,cm)*v(x,cm)}
*v_in in cm  dc 0     
e_im im cm in cm -1
e_ip ip cm in cm  1

v_bp vdd bp  0
v_bn bn  vss 0

* Design under test
*.subckt ddab ipa ima ipb imb op om bp bn vdd vss
xdut ip im ip im op om bp bn vdd vss ddab

* Simulation control
.save v(op) v(om) v(ip) v(im)

.option rshunt = 1e12
*.param dv   = {50m}
*.param step = {dv/1000}
*.dc v_in  {-dv} {dv} {step}
.param dx = 50m
.dc vx {-pow(dx,1/3)} {pow(dx,1/3)} {pow(dx,1/3)/100}
.control
  run
  let vi = ip-im
  let vo = op-om
  let av = db(deriv(vo)/deriv(vi))
  
  plot vo vs vi
  plot av vs vo

  wrdata ./data/tb_ddab_open_dc_vo.dat#num vi vo
  wrdata ./data/tb_ddab_open_dc_av.dat#num vo av

.endc

.end 
