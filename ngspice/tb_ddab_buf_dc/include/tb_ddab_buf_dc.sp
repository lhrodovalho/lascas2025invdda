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

v_vdd vdd 0 dc {xvdd}
v_vss vss 0 dc {xvss}
v_cm cm vss {#vdd/2}

v_in in cm  dc 0     
e_im im cm in cm -0.5
e_ip ip cm in cm  0.5

v_bp vdd bp  0
v_bn bn  vss 0

* Design under test
*.subckt ddab ipa ima ipb imb op om bp bn vdd vss
xdut ip im om op op om bp bn vdd vss vss ddab

* Simulation control
*.save v(op) v(om) v(ip) v(im)

.option rshunt = 1e12
.control
  dc v_in -2.0 2.0 10m
  let df_vi = ip-im
  let df_vo = op-om
  let df_av = db(deriv(df_vo)/deriv(df_vi))
  
  plot df_vo vs df_vi df_vi vs df_vi
  plot df_av vs df_vo

  wrdata ./data/tb_ddab_buf_dc_df_vo.dat#num df_vi df_vo df_av

  dc v_cm 0 #vdd 10m
  let cm_vi = (ip+im)/2
  let cm_vo = (op+om)/2
  let cm_av = db(abs(deriv(cm_vo)/deriv(cm_vi)))
  
  plot cm_vo vs cm_vi cm_vi vs cm_vi
  plot cm_av vs cm_vi

  wrdata ./data/tb_ddab_buf_dc_cm.dat#num cm_vi cm_vo cm_av

.endc

.end 
