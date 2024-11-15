* num: #num corner: #corner vdd: #vdd temp: #temp

* Include SkyWater sky130 device models
.lib /usr/local/share/pdk/sky130A/libs.tech/combined/sky130.lib.spice #corner
.temp #temp

.include ../../netlists/array.spice
.include ../../netlists/inv.spice
*.include ../../../magic/ddaa.spice

.include ../../netlists/invbias.spice

* Simulation parameters
.param xvdd  = #vdd
.param xvss  = 0
.param xcm   = {#vdd/2}

v_vdd vdd 0 dc {xvdd}
v_vss vss 0 dc {xvss}
v_cm cm vss {#vdd/2}

e_ref ref vss vdd vss 0.5

vbp vdd bp  0
vbn bn  vss 0

v_in in ref  dc 0     

* Design under test
xdut in out bp bn vdd vss inv1p1
vo out ref dc 0

* Simulation control
.dc v_in {-#vdd/2} {#vdd/2} 10m
.option rshunt = 1e12
.control
  run

  let vi = in-ref
  let io = i(vo)
  let gm = deriv(io)/deriv(vi)
  
  plot io vs vi
  plot gm vs vi

  wrdata ./data/tb_inv_gm_io.dat#num vi io
  wrdata ./data/tb_inv_gm_gm.dat#num vi gm

.endc

.end 
