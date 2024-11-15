* num: #num corner: #corner vdd: #vdd temp: #temp

* Include SkyWater sky130 device models
.lib /usr/local/share/pdk/sky130A/libs.tech/combined/sky130.lib.spice #corner
.temp #temp

*.include ../../netlists/ddaa.spice
.include ../../../magic/ddaa.spice

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

v_in in cm  dc 0     
e_im im cm in cm -0.5
e_ip ip cm in cm  0.5

v_bp vdd bp  0
v_bn bn  vss 0

* Design under test
*.subckt ddaa ipa ima ipb imb op om bp bn vdd vss
xdut ip im xp xm op om bp bn vdd vss ddaa
.param xr   = 1e4
.param gain = 2
.param k    = {gain - 1}
rfp op xm {k*xr}
rfm om xp {k*xr}
rcp xp cm {xr}
rcm xm cm {xr}

* Simulation control
.save v(op) v(om) v(ip) v(im)

.option rshunt = 1e12
.param dv   = {xvdd}
.param step = {dv/100}
.dc v_in  {-dv} {dv} {step}
.control
  run
  let vi = ip-im
  let vo = op-om
  let av = deriv(vo)/deriv(vi)
  
  plot vo vs vi
  plot av vs vo xlimit -1.8 1.8 ylimit -0.5 2.5

  wrdata ./data/tb_ddaa_ina_dc_vo.dat#num vi vo
  wrdata ./data/tb_ddaa_ina_dc_av.dat#num vo av

.endc

.end 
