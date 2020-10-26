beta = 0.01; % Infection rate (New / Susceptible / Infected / day)
gamma = 0.25; % Recovery rate (1 / day)
deltas = (1:10) * 0.03 + 0.0
delta = 0.1;
i_0 = .1;       % Initial count of infected persons
s_0 = 100 - i_0;
r_0 = 0;
weeks = 600;
onlyInfections = false;

stepFunction = @sir_step_noround;


% [S, I, R, W] = sir_simulate(s_0, i_0, r_0, beta, gamma, delta, weeks)
plot_delta_param_sweep(s_0, i_0, r_0, beta, gamma, deltas, weeks, onlyInfections)
% plot_peaks(s_0, i_0, r_0, beta, gamma, deltas, weeks)

% add function to determine max delta value that produces second peaks for
% a given value of beta (most important) and gamma (independent)