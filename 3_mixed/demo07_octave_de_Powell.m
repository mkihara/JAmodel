% The MIT License (MIT)
%
% Copyright (c) 2016 Roman Szewczyk
%
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in all
% copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
% SOFTWARE.
% 
%
% DESCRIPTION:
% Demonstration of identification of parameters of Jiles-Atherton model of four hysteresis loops with increase of magnetizing field amplitude
% Optimisation method - cascade: differential evolution DE first, Powell next
% 
% AUTHOR: Roman Szewczyk, rszewczyk@onet.pl
%
% RELATED PUBLICATION(S):
% [1] Jiles D. C., Atherton D. "Theory of ferromagnetic hysteresis” Journal of Magnetism and Magnetic Materials 61 (1986) 48.
% [2] Biedrzycki R., Jackiewicz D., Szewczyk R. "Reliability and Efficiency of Differential Evolution Based Method of Determination 
%     of Jiles-Atherton Model Parameters for X30Cr13 Corrosion Resisting Martensitic Steel" Journal of Automation, Mobile Robotics and Intelligent Systems 8 (2014) 63-68.
%
% USAGE:
% demo07_octave_differential_evolution
% 
% IMPORTANT: Demo requires "odepkg", "struct" and "optim" packages installed and loaded  
%

clear all
clc

page_screen_output(0);
page_output_immediately(1);  % print immediately at the screen


fprintf('\n\nDemonstration of identification of Jiles-Atherton models parameters for three hysteresis loops.');
fprintf('\nDemonstration optimized for OCTAVE. Differential evolution for MATLAB is not implemented yet. ');
fprintf('\nDemonstration requires odepkg, struct and optim packages installed.\n\n');


% check if odepkg is installed. Load odepkg if installed, but not loaded.
ChkPkg('odepkg');

% check if struct is installed. Load odepkg if installed, but not loaded.
ChkPkg('struct');

% check if optim is installed. Load odepkg if installed, but not loaded.
ChkPkg('optim');

% Load measured B(H) characterisitcs of Mn-Zn ferrite

cd ('Characterisitcs_mixed_mat');
load('H_M130_27s.mat');
load('B_M130_27s.mat');
cd ('..');
 
fprintf('Load measured B(H) characterisitcs of M130-27s electrical steel... done\n\n');

% prepare starting point for optimisation

mi0=4.*pi.*1e-7;

JApoint0=[1 1 1 1 1 1 1 1];

SolverType=4;       % solver ode23()
FixedStep=1;

func = @(JApointn) JAn_loops_target( [JApointn 0], JApoint0, HmeasT, BmeasT, SolverType, FixedStep);

ctl.XVmin = [2 2 0 max(max(BmeasT))./mi0.*0.8 1e-10 10 0];
ctl.XVmax = [100 100 1 max(max(BmeasT))./mi0.*1.6 1e-3 1000 1];
ctl.refresh = 1;
ctl.maxnfe = 1000;
ctl.constr = 0;

% Range of parameters of Jiles-Atherton model for optimisation

fprintf('Optimization process started... \n\n');

tic

[JApoint_res, obj_value, nfeval, convergence] = de_min (func, ctl);

toc

fprintf('\n\nOptimiation process done.\n\n');

Ftarget=func(JApoint_res);

BsimT = JAn_loops(JApoint0(1).*JApoint_res(1), JApoint0(2).*JApoint_res(2), JApoint0(3).*JApoint_res(3), ...
 JApoint0(4).*JApoint_res(4), JApoint0(5).*JApoint_res(5), JApoint0(6).*JApoint_res(6), JApoint0(7).*JApoint_res(7),0, HmeasT, SolverType, FixedStep );

fprintf('Results of optimisation:\n'); 
fprintf('Target function value: Ftarget=%f\n',Ftarget);
fprintf('JA model params: a=%f(A/m), k=%f(A/m), c=%f, Ms=%e(A/m), alpha=%e, Kan=%e, psi=0, t=%f \n\n',  ...
 JApoint0(1).*JApoint_res(1), JApoint0(2).*JApoint_res(2), JApoint0(3).*JApoint_res(3), ...
 JApoint0(4).*JApoint_res(4), JApoint0(5).*JApoint_res(5), JApoint0(6).*JApoint_res(6),JApoint0(7).*JApoint_res(7) );

fprintf('Optimisation DE done.\n\n');

plot(HmeasT, BmeasT,'or',HmeasT,BsimT,'k');
xlabel('H (A/m)');
ylabel('B (T)');
grid;

JApoint_optim=JApoint0.*[JApoint_res 0];

save -v7 demo07_results_DE.mat JApoint_optim JApoint0 JApoint_res

fprintf('Optimisation POWEL...\n\n');

o=optimset('MaxIter',500);

[JApoint_resPowell, y_min, conv, iters, nevs]=powell(func, JApoint_res, o)

JApoint_optimPowell=JApoint0.*[JApoint_resPowell 0];

save -v7 demo07_resultsPowell.mat JApoint_optimPowell JApoint0 JApoint_resPowell

Ftarget=func(JApoint_resPowell)


