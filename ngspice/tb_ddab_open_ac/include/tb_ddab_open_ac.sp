* num: #num corner: #corner vdd: #vdd temp: #temp

* Include SkyWater sky130 device models
.lib /usr/local/share/pdk/sky130A/libs.tech/combined/sky130.lib.spice #corner
.temp #temp

.include ../../../magic/ddab.spice

* Simulation parameters
.param xvdd  = #vdd
.param xvss  = 0
.param xcm   = {#vdd/2}

.param xip =  1
.param xim = -1

.param xin_ac  = 1
.param xcm_ac  = 0
.param xvdd_ac = 0

.param xci    = 1T
.param xri    = 1T
.param xlf    = 1T
.param xrf    = 1f
.param xcl    = 15p
.param xrl    = 1T

v_vdd vdd 0 dc {xvdd} ac {xvdd_ac} 
v_vss vss 0 dc {xvss}
v_cm  cm  0 dc {xcm}  ac {xcm_ac}
v_in in cm  dc 0      ac {xin_ac}
e_im im cm in cm -1
e_ip ip cm in cm  1

v_bp vdd bp  0
v_bn bn  vss 0

* Design under test
*xdut ipa ima ipb imb op om bp bn vdd vss ddab
xdut xp xm xp xm op om bp bn vdd vss vss ddab

cp_l op cm 'xcl' m=1 
lp_f op xm 'xlf' m=1 
cm_i xm im 'xci' m=1 
rm_i xm im 'xri' m=1 

cm_l om cm 'xcl' m=1 
lm_f om xp 'xlf' m=1 
cp_i xp ip 'xci' m=1 
rp_i xp ip 'xri' m=1 

* Simulation control
.save v(op) v(om) v(ip) v(im) i(v_vdd)

.option rshunt = 1e12
.control
  * differential input
  alter v_in  ac=1
  alter v_cm  ac=0
  alter v_vdd ac=0

  op
  ac dec 100 100 10G

  * common-mode input
  alter v_in  ac=0
  alter v_cm  ac=1
  alter v_vdd ac=0

  ac dec 100 100 10G

  * power supply
  alter v_in  ac=0
  alter v_cm  ac=0
  alter v_vdd ac=1

  ac dec 100 100 10G

  let vos  = op.v(op) - op.v(om)
  let vocm = (op.v(op) + op.v(om))/2
  let idd  = op.i(v_vdd)
  let av   = db(ac1.op-ac1.om)-db(ac1.ip-ac1.im)
  let ph   = cphase(ac1.op-ac1.om)*180/pi+180
  let cmrr = av - (db(ac2.op)+db(ac2.om))/2
  let psrr = av - (db(ac3.op)+db(ac3.om))/2

  meas ac av100hz find av at=100
  meas ac gbw when av=0
  meas ac pm find ph at=gbw

  meas ac cmrr100hz find cmrr at=100
  meas ac psrr100hz find psrr at=100

  plot av cmrr psrr
  plot ph
  print idd vos vocm

  echo "num,corner,vdd,temp,gbw,pm,av100hz,cmrr100hz,psrr100hz,idd,vos,vocm" > ./meas/tb_ddab_open_ac.meas#num
  echo "#num,#corner,#vdd,#temp,$&gbw,$&pm,$&av100hz,$&cmrr100hz,$&psrr100hz,$&idd,$&vos,$&vocm" >> ./meas/tb_ddab_open_ac.meas#num

  wrdata ./data/tb_ddab_open_ac_av.dat#num av
  wrdata ./data/tb_ddab_open_ac_ph.dat#num ph
  wrdata ./data/tb_ddab_open_ac_cmrr.dat#num cmrr
  wrdata ./data/tb_ddab_open_ac_psrr.dat#num psrr

.endc

.end 