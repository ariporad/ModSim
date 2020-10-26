beta = 0.01; % Infection rate (New / Susceptible / Infected / day)
gamma = 0.5; % Recovery rate (1 / day)
delta = 0.4;
i_0 = .1;       % Initial count of infected persons
s_0 = 100 - i_0;
r_0 = 0;

weeks = 600;

global dInfected;
global dRecovered;
global dResusceptible;
dInfected = [];
dRecovered = [];
dResusceptible = [];

[S, I, R, W] = sir_simulate_noround(s_0, i_0, r_0, beta, gamma, delta, weeks);

dValues = [dInfected; dRecovered; dResusceptible];

clf;
hold on;

plot(W, S)
plot(W, I)
plot(W, R)

plot(linspace(1, weeks, 100), zeros(1, 100) + 50)





% x = linspace(1, weeks);
% y = x .^ (-1);
% plot_peaks(s_0, i_0, r_0, beta, gamma, deltas, weeks)
% plot(x, y, 'k-')