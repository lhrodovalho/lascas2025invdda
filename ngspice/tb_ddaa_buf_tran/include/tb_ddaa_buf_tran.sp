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

.param xcl = 15p

v_vdd vdd 0 dc {xvdd}
v_vss vss 0 dc {xvss}
v_cm cm vss {#vdd/2}

.param xamp = 1.0
.param xper = 1u
.param xtt  = {xper/1000}
.param xdel = {xper/4}
.param xpw  = {xper/2}

v_in in cm  dc 0 pulse({-xamp/2} {xamp/2} {xdel} {xtt} {xtt} {xpw} {xper})   
e_im im cm in cm -0.5
e_ip ip cm in cm  0.5

v_bp vdd bp  0
v_bn bn  vss 0

* Design under test
*.subckt ddaa ipa ima ipb imb op om bp bn vdd vss
xdut ip im om op op om bp bn vdd vss ddaa
cp op cm {xcl}
cm op cm {xcl}

* Simulation control
.save v(op) v(om) v(ip) v(im) 

.option rshunt = 1e12
.tran {xper/100} {xper}
.control
  run
  
  let vi = ip-im
  let vo = op-om
  
  plot vo vi

  wrdata ./data/tb_ddaa_buf_tran.dat#num vi vo

.endc

.end 
