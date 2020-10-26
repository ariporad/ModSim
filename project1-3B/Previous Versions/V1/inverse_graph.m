beta = 0.01; % Infection rate (New / Susceptible / Infected / day)
gamma = 0.5; % Recovery rate (1 / day)
deltas = (1:10) * 0.01;
i_0 = 2;       % Initial count of infected persons
s_0 = 100 - i_0;
r_0 = 0;

weeks = 300;
x = linspace(1, weeks);
y = x .^ (-1);

plot_peaks(s_0, i_0, r_0, beta, gamma, deltas, weeks)
plot(x, y, 'k-')