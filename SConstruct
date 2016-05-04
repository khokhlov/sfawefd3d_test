from rsf.proj import *
from rsf.recipes import fdmod
import math

h=10
par = { 'ox':-500.0,'dx':h,'nx':201,'lx':"x",'ux':"m",
        'oy':-500.0,'dy':h,'ny':201,'lz':"z","uz":"m",
        'oz':   0,'dz':h,'nz':100,'lt':"t","ut":"s",
        'ot':  0.,'dt':0.001,'nt':1000,
        'f0':5
  }

fdmod.param(par)

Flow('wav',None,'spike n1=%(nt)d o1=%(ot)g d1=%(dt)g nsp=1 k1=241 |ricker1 frequency=%(f0)g |scale axis=123|transp'%par)


Flow('vel',None,'math n1=%(nz)d d1=%(dz)g o1=%(oz)g n2=%(nx)d d2=%(dx)g o2=%(ox)g n3=%(ny)d d3=%(dy)g o3=%(oy)g output="4000"'%par)
Flow('den','vel','math output="2500"'%par)



def gf(xs,xr,wav,vel,gf,free=True): 
  [sx,sy,sz] = xs
  [rx,ry,rz] = xr
 
  iR = 1./math.sqrt((sx-rx)**2+(sy-ry)**2+(sz-rz)**2)
  t0 = (1./iR)/vel 
  
  if free: 
    iRf =  1./math.sqrt((sx-rx)**2+(sy-ry)**2+(sz+rz)**2)
    t1 = (1./iRf)/vel
  else: 
    t1=0.0
    iRf=0.0
  Flow(gf,wav,
    '''
    fft1 |math output="input*%g*exp(-I*(2*acos(-1)*x1)*%g)-input*%g*exp(-I*(2*acos(-1)*x1)*%g)" |
    fft1 inv=y|
    math output="input/(4.0*acos(-1))"
    '''%(iR,t0,iRf,t1))


Flow('wav1d','wav','window ')

src = (0,0,50)
rvr = (100,0,50)

gf(src,rvr,'wav1d',4000,'GF',False)
gf(src,rvr,'wav1d',4000,'GF_free',True)



Flow('sou',None,'spike n1=3 nsp=3 k1=1,2,3 mag=%g,%g,%g o1=0 o2=0 o3=0 '%src)
Flow('rec',None,'spike n1=3 nsp=3 k1=1,2,3 mag=%g,%g,%g o1=0 o2=0 o3=0 '%rvr)



def finite_difference(gf,s,r,free='n'):
  Flow(gf,['wav','vel',s,r],
  '''
  awefd3d vel=${SOURCES[1]}  sou=${SOURCES[2]} rec=${SOURCES[3]} 
  verb=y free=n expl=n snap=n dabc=y  hybridbc=y nb=30 
  jdata=1 sinc=y 
  '''+' free='+free)




finite_difference('mdat','sou','rec',free='n')
finite_difference('mdatfree','sou','rec',free='y')


Plot('GF','scale axis=123|graph title="Green Function, infinite space "  min2=-.8 max2=1 ')
Plot('GF_free','scale axis=123|graph title="Green Function, half space "  min2=-.8 max2=1')

Plot('GF_fd','mdat','window |scale axis=123|graph title="Green Function, infinite space FD " min2=-.8 max2=1 ')
Plot('GF_free_fd','mdatfree','window |scale axis=123|graph title="Green Function, half space FD " min2=-.8 max2=1 ')


Plot('GF_overlayed',['mdat','GF'],'window |cat ${SOURCES[1]} |scale axis=1 |window |graph title="Green Function free space overlayed "')
Plot('GF_free_overlayed',['mdatfree','GF_free'],'window |cat ${SOURCES[1]} |scale axis=1 |window |graph title="Green Function free space overlayed "')








End()
