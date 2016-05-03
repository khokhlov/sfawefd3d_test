#!/bin/bash

h=5
nx=200
ny=200
nz=200
ox=-502.5
oy=-502.5
oz=2.5

sfmath > vel.rsf output=4000 n1=$nz n2=$nx n3=$ny d1=$h d2=$h d3=$h o2=$ox o3=$oy o1=$oz
sfmath > den.rsf output=2500 n1=$nz n2=$nx n3=$ny d1=$h d2=$h d3=$h o2=$ox o3=$oy o1=$oz

< vel.rsf sfput label1=Depth unit1=m label2=Distance unit2=m | sfgrey allpos=y scalebar=y color=j minval=2000 maxval=5000 title="velocity model" xinch=10 yinch=3| jpegpen > vel.jpg

# source
sfspike n1=3 nsp=3 k1=1,2,3 mag=0,0,50 o1=0 o2=0 o3=0 > sou.rsf

# survey
./gen_survey.py > rec.txt
echo in=rec.txt n1=3 n2=40 data_format=ascii_float | sfdd form=native > rec.rsf

#echo in=pulse.dat n1=1 n2=2000 data_format=ascii_float | sfdd form=native | sfput n1=1 n2=2000 d2=0.002 o1=0 label1="Time" unit1="s" > impulse1.rsf
#echo in=impulse_0.00005_80000.dat n1=1 n2=80000 data_format=ascii_float | sfdd form=native | sfput n1=1 n2=80000 d2=0.00005 o1=0 label1="Time" unit1="s" > impulse1.rsf
echo in=impulse_0.0004_10000.dat n1=1 n2=10000 data_format=ascii_float | sfdd form=native | sfput n1=1 n2=10000 d2=0.0004 o1=0 label1="Time" unit1="s" > impulse1.rsf
#echo in=impulse_0.0004_2000.dat n1=1 n2=2000 data_format=ascii_float | sfdd form=native | sfput n1=1 n2=2000 d2=0.0004 o1=0 label1="Time" unit1="s" > impulse1.rsf
sfspike nsp=1 n1=10000 d1=0.0004 k1=1000 | sfricker1 frequency=5 | sfscale dscale=200 | sftransp > impulse.rsf
sfdisfil > impulse.asc col=1 format="%e " number=n < impulse.rsf

#< impulse1.rsf sfwindow | sfgraph title='Ricker' unit2= label2=amplitude | sfpen

fawefd3d < impulse1.rsf vel=vel.rsf sou=sou.rsf rec=rec.rsf den=den.rsf > dat.rsf verb=y free=y expl=n snap=y dabc=y den=den.rsf jdata=1 jsnap=80000 nbell=1 sinc=n

#echo 'label1=z unit1=m label2=x unit2=m' >> wfl.rsf
#< wfl.rsf sfgrey gainpanel=a pclip=99 color=j scalebar=y | sfpen
#< dat.rsf sfwindow | sfgraph title='Data recorded at receiver' unit2= label2=amplitude | sfpen

sfdisfil > dat.asc col=40 format="%e " number=n < dat.rsf
< dat.rsf sftransp | sfsegyheader  > out.rsf n1=40 d1=2000
< dat.rsf sftransp | sfsegywrite tfile=out.rsf tape=dat.segy

