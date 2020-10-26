function [s_n, i_n, r_n] = sir_step(s, i, r, beta, gamma, delta)
% fcn_step Advance an SIR model one timestep
%
% Usage
%   [s_n, i_n, r_n] = fcn_step(s, i, r, beta, gamma)
% 
% Arguments
%   s = current number of susceptible individuals
%   i = current number of infected individuals
%   r = current number of recovered individuals
%   
%   beta = infection rate parameter
%   gamma = recovery rate paramter
% 
% Returns
%   s_n = next number of susceptible individuals
%   i_n = next number of infected individuals
%   r_n = next number of recovered individuals

% compute new infections and recoveries
infected = round(beta * i * s);
recovered =  round(gamma * i); % i - i_2weeks_ago
resusceptible = round(delta * r);

% Enforce invariants
total = s + i + r;
infected = min(s, infected); % Cannot infect more people than current s
% infected = min(total - i - r, infected); % Cannot infect more than total
recovered = min(i, recovered); % Cannot recover more people than current i
% recovered = min(total - r - s, recovered); % Cannot recover more than total
resusceptible = min(r, resusceptible);

% Update state
s_n = s - infected + resusceptible;
i_n = i + infected - recovered;
r_n = r + recovered - resusceptible;

assert(s_n + i_n + r_n == s + i + r, "failed to conserve people! This is a bug with rounding in sir_step")
    
end