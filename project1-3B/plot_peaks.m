% function plot_peaks(s_0, i_0, r_0, beta, gamma, deltas, weeks)

beta = 0.01; % Infection rate
gamma = 0.5; % Recovery rate
deltas = (1:100) * 0.01 + 0.0 % delta cannot exceed 0.33 for beta = 0.01 and gamma = 0.5 and @sir_step_const
delta = 0.4;
i_0 = .1;
s_0 = 100 - i_0;
r_0 = 0;
weeks = 600;

stepFunction = @sir_step_noround;


nValues = length(deltas);

%%---------------------------------------------------------%%
clf;
hold on;

PeakTime = [];
PeakHeight = [];

for i = 1:nValues
    delta = deltas(i);
    [S, I, R, W] = sir_simulate(s_0, i_0, r_0, beta, gamma, delta, 300, stepFunction);
    [pks, locs] = findpeaks(I);
    if length(locs) < 1
        a = 1; % breakpoint
    end

    myPeak = 2;
    PeakTime(i) = W(locs(myPeak));
    PeakHeight(i) = I(locs(myPeak));
end

plot(PeakTime / 200, PeakHeight, 'go')
hold on;
plot(deltas, PeakTime, 'gx');
plot(deltas, PeakHeight, 'rx');

xlabel("Values of delta (x), or week # (o)")
ylabel("2nd Peak Height (red) or week # (green)")
title("2nd Peak height in red, and time in green")