* num: #num corner: #corner vdd: #vdd temp: #temp

* Include SkyWater sky130 device models
.lib /usr/local/share/pdk/sky130A/libs.tech/combined/sky130.lib.spice #corner
.param mc_mm_switch=1
.temp #temp

*.include ../../netlists/ddaa.spice
.include ../../../magic/ddaa.spice

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
.param xcl    = 10p
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
*xdut ipa ima ipb imb op om bp bn vdd vss ddaa
xdut xp xm xp xm op om bp bn vdd vss vss ddaa

cp_l op cm 'xcl' m=1 
lp_f op xm 'xlf' m=1 
cm_i xm im 'xci' m=1 
rm_i xm im 'xri' m=1 

cm_l om cm 'xcl' m=1 
lm_f om xp 'xlf' m=1 
cp_i xp ip 'xci' m=1 
rp_i xp ip 'xri' m=1 

* Simulation control
*.save v(op) v(om) v(ip) v(im)

.option rshunt = 1e12
.control

  echo "num,corner,vdd,temp,gbw,pm,av1khz,cmrr1khz,psrr1khz,idd,vos,vocm" > ./meas/tb_ddaa_mc.meas#num  
  let run = 1
  dowhile run <= 10
  echo
  echo ">>> run $&run"
  echo
  reset


  * differential input
  alter v_in  ac=1
  alter v_cm  ac=0
  alter v_vdd ac=0

  op
  ac dec 10 1k 10G

  * common-mode input
  alter v_in  ac=0
  alter v_cm  ac=1
  alter v_vdd ac=0

  ac dec 10 1k 10G

  * power supply
  alter v_in  ac=0
  alter v_cm  ac=0
  alter v_vdd ac=1

  ac dec 10 1k 10G

  let vos  = op.v(op) - op.v(om)
  let vocm = (op.v(op) + op.v(om))/2
  let idd  = op.i(v_vdd)
  let av   = db(ac1.op-ac1.om)-db(ac1.ip-ac1.im)
  let ph   = cphase(ac1.op-ac1.om)*180/(4*atan(1))
  let cmrr = av - (db(ac2.op)+db(ac2.om))/2
  let psrr = av - (db(ac3.op)+db(ac3.om))/2

  meas ac av1khz find av at=1k
  meas ac gbw when av=0
  meas ac pm_ find ph at=gbw
  let pm = 180+pm_
  print pm
  
  meas ac cmrr1khz find cmrr at=1k
  meas ac psrr1khz find psrr at=1k

  print idd vos vocm

  echo "#num,#corner,#vdd,#temp,$&gbw,$&pm,$&av1khz,$&cmrr1khz,$&psrr1khz,$&idd,$&vos,$&vocm" >> ./meas/tb_ddaa_mc.meas#num

  destroy all
  let run = run+1
  end

.endc

.end 
