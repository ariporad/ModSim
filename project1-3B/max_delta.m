gamma = 0.5; % Recovery rate (1 / day)
i_0 = .1;       % Initial count of infected persons
s_0 = 100 - i_0;
r_0 = 0;
weeks = 600;
onlyInfections = false;
stepFunction = @sir_step_noround;

clf;
hold on;

betas = (1:100) * 0.01 + 0.0; % beta values to test
delta_increment = 0.01;
for b = 1:length(betas)
    beta = betas(b);

    delta = 0 + delta_increment;
    while delta <= 1

        [S, I, R, W] = sir_simulate(s_0, i_0, r_0, beta, gamma, delta, weeks, stepFunction);
        [pks, locs] = findpeaks(I);%, 'MinPeakProminence', 0.002);

        myPeak = 2;
        if length(locs) < myPeak
            fprintf("FOUND A PEAK: %d @ %d\n", beta, delta);
            break;
        end

        if delta > .32
            a = 1; % put a breakpoint here
        end

        delta = delta + delta_increment;
    end
    if delta < 1
        plot(beta, delta, 'bx');
    end
    xlabel("beta");
    ylabel("maximum delta value with more than one peak");
end