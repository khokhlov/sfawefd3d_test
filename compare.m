function MadagascarBenchmark

    %Comparison of half-space solution with that of Madagascar, z=50 m

    normalized = false; %normalize each trace by its mac value;

    madagascar_file = 'dat.asc';

    

    clf;

 

    %Madagascar

    traces2 = load(madagascar_file,'ascii');

    t2=(0:9999)*0.0004-0.24;

    NR=5;

   

    %Time-domain Green's function

    traces3 =[];

    t3=(0:9999)*0.0004-0.24;

    for nr=1:NR

        c=4000;

        Rs=[0,0,50];

        Rr=[100*nr,0,50];

        type=1;

        y=GreenFunction( t3, 0.0, 5.0,c, Rs,Rr, type);

        traces3(:,nr) = y.';

    end

   

    for nr=1:NR

        y2= traces2(:,nr);

        y3 = traces3(:,nr);

    if normalized

            y2=y2/max(y2);

            y3=y3/max(y3);

            shift = 1;

        else

            shift = 0.00005;

            c = 4000; %wave speed at the source position

            h = 5;%cell size at the source position

            factor =c^2/h^3;%<--- factor

            y2=y2 * factor;

        end

       

        c2=plot(t2,shift*(nr-1) + y2,'-r');

        hold on;

       

        c3=plot(t3,shift*(nr-1) + y3,'-g');  

        hold on;

    end

 

    legend([c2;c3],{'sfawefd3d', 'Green`s function'});

    xlabel('time, s');

    ylabel('Re(p)');

    grid on;

   

    

    

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ y] = GreenFunction( t, t0, f0,c, Rs,Rr, type)

%GREENFUNCTIONTD Summary of this function goes here

%   Detailed explanation goes here

%c - speed of sound

%t0 - time shift

%f0 - Ricker main freq

%Rs - source position, 3-element attay

%Rr - receiver position,3-element attay

%type: 0 - free space, 1 - half space

N=length(t);

T = t(end);

dt = t(2)-t(1);

y=zeros(N,1);

for n=1:N

    dx = Rs(1)-Rr(1);

    dy = Rs(2)-Rr(2);

    dz = Rs(3)-Rr(3);

    dz2= Rs(3)+Rr(3);

   

    d1 = sqrt(dx*dx+dy*dy+dz*dz);

    d2 = sqrt(dx*dx+dy*dy+dz2*dz2);

   

    tau = t(n) - d1/c;

    val = Ricker(tau, f0);

   

    y(n) = val/(4*pi*d1);

   

    if(type == 1)

        tau = t(n) - d2/c;

        val = Ricker(tau, f0);

        y(n) = y(n) - val/ (4*pi*d2);

    end

end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ r ] = Ricker(t,f0)

    %RICKER Ricker wavelet in time domain

    %   f0 in Hz, t in s.

    %max is 1.0

    w0=2*pi*f0;

    v = w0^2*t.^2;

    r = (1-0.5*v).*exp(-0.25*v);

end


