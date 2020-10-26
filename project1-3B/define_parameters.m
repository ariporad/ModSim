beta = 0.01; % Infection rate (New / Susceptible / Infected / day)
gamma = 0.5; % Recovery rate (1 / day)
deltas = (1:10) * 0.005 + 0.30
delta = 0.4;
i_0 = .1;       % Initial count of infected persons
s_0 = 100 - i_0;
r_0 = 0;
weeks = 600;


% [S, I, R, W] = sir_simulate(s_0, i_0, r_0, beta, gamma, delta, weeks)
plot_delta_param_sweep(s_0, i_0, r_0, beta, gamma, deltas, weeks)
% plot_peaks(s_0, i_0, r_0, beta, gamma, deltas, weeks)