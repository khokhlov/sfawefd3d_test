# M8R native implementation of unit testing for sfawefd3d
# run with "scons view"
from rsf.proj import *
import numpy as np

## Experiment set up
par = dict(
    nt = 2048, dt = 0.0008, ot = 0.0, lt='t', ut='s',
    nz = 128, dz = 0.02, oz = 0.0, lz='z', uz='km',
    nx = 128, dx = 0.02, ox = 0.0, lx='x', ux='km',
    ny = 128, dy = 0.02, oy = 0.0, ly='y', uy='km',
    c = 4.0, freq = 5,
    srcLoc = np.array([1.024, 1.536, 1.28]), 
    recLoc = np.array([1.536, 1.024, 1.28]),
    # awefd3d related pars
    verb = 'y', expl = 'n', snap = 'n',
    cden = 'y', sinc = 'y',
    dabc = 'y', hybridbc = 'y', nb = 32,
    fdorder=4, optfd='n',
    free = 'n',
    )

### source function: Ricker wavelet, translated by 0.32 s
Flow('sourceFunc',None,'''
    spike nsp=1 k1=400 n1=%(nt)d d1=%(dt)g o1=%(ot)g label1=%(lt)s unit1=%(ut)s 
    | ricker1 frequency=%(freq)g
    | scale rscale=1000
    ''' % par)
Result('sourceFunc','graph title="Source Wavelet"')

### source density function: used for input to sfawefd3d
par['volume'] = par['dx'] * par['dy'] * par['dz']
Flow('sourceDensityFunc','sourceFunc','''
    math output="input/%(volume)g" 
    | transp plane=12
    ''' % par)

### source / receiver locations
Flow('sou',None,'''
    spike n1=3 nsp=3 k1=1,2,3 mag=%g,%g,%g o1=0 o2=0 o3=0
    ''' % (par['srcLoc'][0], par['srcLoc'][1], par['srcLoc'][2]))

Flow('rec',None,'''
    spike n1=3 nsp=3 k1=1,2,3 mag=%g,%g,%g o1=0 o2=0 o3=0
    ''' % (par['recLoc'][0], par['recLoc'][1], par['recLoc'][2]))

### velocity model: unbounded homogeneous model
Flow('velHomo',None,'''
    math output="%(c)g"
    n1=%(nz)d d1=%(dz)g o1=%(oz)g label1=%(lz)s unit1=%(uz)s
    n2=%(nx)d d2=%(dx)g o2=%(ox)g label2=%(lx)s unit2=%(ux)s
    n3=%(ny)d d3=%(dy)g o3=%(oy)g label3=%(ly)s unit3=%(uy)s
    ''' % par)

######################################################
# unbounded homogeneous example
## Analytic Green's function
par['srDistance'] = np.linalg.norm(par['srcLoc'] - par['recLoc'])
par['traveltime'] = par['srDistance'] / par['c']
par['tshift'] = int(round(par['traveltime'] / par['dt']))
par['pi'] = np.pi
Flow('Ghomo_analytic','sourceFunc','''
    pad beg1=%(tshift)d | window n1=%(nt)d 
    | put d1=%(dt)g o1=%(ot)g
    | math output="input / (4.0 * %(pi)g * %(srDistance)g) "
    ''' % par)
Result('Ghomo_analytic','window | graph title="Green function for homogeneous medium"')

## Numerical solution 
Flow('Ghomo_numeric','sourceDensityFunc velHomo sou rec','''
    awefd3d
    vel=${SOURCES[1]} sou=${SOURCES[2]} rec=${SOURCES[3]}
    verb=%(verb)s expl=%(expl)s snap=%(snap)s
    cden=%(cden)s sinc=%(sinc)s 
    dabc=%(dabc)s hybridbc=%(hybridbc)s nb=%(nb)d
    fdorder=%(fdorder)d optfd=%(optfd)s 
    free=n
    ''' % par)
Result('Ghomo_numeric','window | graph title="Numerical solution for homogeneous medium"')

## Comparison of Green's function and numerical solution
Result('solsHomo_compare','Ghomo_numeric Ghomo_analytic','''
    window | cat axis=2 ${SOURCES[1]}
    | graph title="Comparisons in unbounded case" 
        label2="Amplitude" unit2=""
        label1="Time" unit1="s"
    ''')

######################################################
# fluid halfspace example
## Green's function
par['srcLoc_mirror'] = par['srcLoc'] * np.array([1,1,-1])
par['srDistance_mirror'] = np.linalg.norm(par['srcLoc_mirror'] - par['recLoc'])
par['traveltime_mirror'] = par['srDistance_mirror'] / par['c']
par['tshift_mirror'] = int(round(par['traveltime_mirror'] / par['dt']))
par['pi'] = np.pi
Flow('Ghalf_analytic_mirror','sourceFunc','''
    pad beg1=%(tshift_mirror)d | window n1=%(nt)d 
    | put d1=%(dt)g o1=%(ot)g
    | math output="input / (4.0 * %(pi)g * %(srDistance_mirror)g) "
    ''' % par)
Flow('Ghalf_analytic','Ghomo_analytic Ghalf_analytic_mirror','add scale=1,-1 ${SOURCES[1]}')

## Numerical solution
Flow('Ghalf_numeric','sourceDensityFunc velHomo sou rec','''
    awefd3d
    vel=${SOURCES[1]} sou=${SOURCES[2]} rec=${SOURCES[3]}
    verb=%(verb)s expl=%(expl)s snap=%(snap)s
    cden=%(cden)s sinc=%(sinc)s 
    dabc=%(dabc)s hybridbc=%(hybridbc)s nb=%(nb)d
    fdorder=%(fdorder)d optfd=%(optfd)s 
    free=y
    ''' % par)
Result('Ghalf_numeric','window | graph title="Numerical solution for homogeneous medium"')

## Comparison of Green's function and numerical solution
Result('solsHalf_compare','Ghalf_numeric Ghalf_analytic','''
    window | cat axis=2 ${SOURCES[1]}
    | graph title="Comparisons in halfspace case" 
        label2="Amplitude" unit2=""
        label1="Time" unit1="s"
    ''')

End()
