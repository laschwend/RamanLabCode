%script for calculating first order strains for muscle chip plug holes


syms Ec Ep Lc Lp Fc I nup nuc Dc Dp delta t

BendingEqn = delta == Fc*Lc/3/Ec/I; 
Ieqn = I == Lp*t^3/12; 
HertzEqn = sqrt(Dp^2 - (Dp-delta)^2) == sqrt(4*Fc*((1-nup^2)/Ep + (1-nuc)^2/Ec)/pi/Lp*Dp/2); 

sysEq = [BendingEqn; Ieqn; HertzEqn]; 

sol = solve(sysEq, [Fc delta I]); 

EcVal = 2.9*10^9; %Pa
EpVal = 43*10^6; %Pa
LcVal = 4;%mm 
LpVal = 4;%mm 
nupVal = 0.5; 
nucVal = 0.5; 
DcVal = 1.25; %mm; 
DpVal = 2; %mm; 
tVal = ; %mm

ValArray = [EcVal, EpVal, LcVal, LpVal, nupVal, nucVal, DcVal, DpVal, tVal];

Fc = double(subs(sol.Fc, [Ec Ep Lc Lp nup nuc Dc Dp t], ValArray))
delta = double(subs(sol.delta, [Ec Ep Lc Lp nup nuc Dc Dp t], ValArray))


