* num: #num corner: #corner vdd: #vdd temp: #temp

* Include SkyWater sky130 device models
.lib /usr/local/share/pdk/sky130A/libs.tech/combined/sky130.lib.spice #corner
.temp #temp

*.include ../../netlists/ddaa.spice
.include ../../../magic/ddaa.spice

* Simulation parameters
.param xvdd  = #vdd
.param xvss  = 0
.param xcm   = {xvdd/2}

.param xip =  1
.param xim = -1

.param xcl    = 15p

v_vdd vdd 0 dc {xvdd}
v_vss vss 0 dc {xvss}
v_cm  cm  0 dc {xcm}

.param xamp  = 1.4
.param xfreq = 100k
.param xper  = {1/xfreq}

v_in in cm  dc 0 sine(0 {xamp/2} {xfreq})
e_im im cm in cm -0.5
e_ip ip cm in cm  0.5

v_bp vdd bp  0
v_bn bn  vss 0

* Design under test
*.subckt ddaa ipa ima ipb imb op om bp bn vdd vss
xdut ip im xp xm op om bp bn vdd vss vss ddaa
.param xr   = 1e4
.param gain = 2
.param k    = {gain - 1}
rfp op xm {k*xr}
rfm om xp {k*xr}
rcp xp cm {xr}
rcm xm cm {xr}
cp op cm {xcl}
cm om cm {xcl}

* Simulation control
.save v(op) v(om) v(ip) v(im)

.option rshunt = 1e12

.tran {xper/100} {5*xper} {xper}
.control
  run

  let vi = ip-im
  let vo = op-om
  
  plot vi vo
  
  wrdata ./data/tb_ddaa_ina_tran.dat#num vi vo
  
  fourier 100k v(op,om)

.endc

.end 
