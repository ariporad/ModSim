function [S, I, R, W] = sir_simulate(s_0, i_0, r_0, beta, gamma, delta, weeks, stepFunction)
% fcn_simulate Simulate a SIR model
%
% Usage
%   [S, I, R, W] = fcn_simulate(s_0, i_0, r_0, beta, gamma, weeks)
%
% Arguments
%   s_0 = initial number of susceptible individuals
%   i_0 = initial number of infected individuals
%   r_0 = initial number of recovered individuals
%
%   beta = infection rate
%   gamma = recovery rate
%   delta = resusceptibility rate
%
%   weeks = number of simulation steps to simulate
%
% Returns
%   S = simulation history of susceptible individuals; vector
%   I = simulation history of infected individuals; vector
%   R = simulation history of recovered individuals; vector
%   W = simulation week; vector

% Setup
S = zeros(1, weeks);
I = zeros(1, weeks);
R = zeros(1, weeks);
W = 1 : weeks;

s = s_0;
i = i_0;
r = r_0;

% Store initial values
S(1) = s;
I(1) = i;
R(1) = r;

% Run simulation
for step = 2 : weeks
    [s, i, r] = stepFunction(s, i, r, beta, gamma, delta);
    S(step) = s;
    I(step) = i;
    R(step) = r;
end

end