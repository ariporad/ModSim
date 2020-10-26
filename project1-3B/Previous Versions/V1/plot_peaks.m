function plot_delta_param_sweep(s_0, i_0, r_0, beta, gamma, deltas, weeks)

    nValues = length(deltas);

    % Format the lines for different parameter values
    z = zeros(1, nValues);
    darkest = 0.3;
    colorVals = (((1 - darkest):(1 - darkest):nValues * (1 - darkest)) / nValues) + darkest;
    % if darkest = 0.3 and nValues = 10, this becomes:
    % (0.7 : 0.7 : 7) / 10 + 0.3 = [0.37, 0.44, 0.51, 0.58, 0.65, 0.72, 0.79, 0.86, 0.93, 1.00]

    Sformatting = [z; z; colorVals];
    Iformatting = [colorVals; z; z];
    Rformatting = [z; colorVals; z];

    %%---------------------------------------------------------%%
    clf;
    hold on;
    Slabel = string([]);
    Ilabel = string([]);
    Rlabel = string([]);
    for i = 1:nValues
        delta = deltas(i);

        % Run simulation
        [S, I, R, W] = sir_simulate_noround(s_0, i_0, r_0, beta, gamma, delta, 300);
        [pks, locs] = findpeaks(I);

        myPeak = 2;
        % plot(W, S, 'o', 'Color', Sformatting(:, i));
        y = I(locs(myPeak));
        plot(W(locs(myPeak)), y, '^', 'Color', Iformatting(:, i));

        y_inv = y .^ (-1) * 100;
        plot(W(locs(myPeak)), y_inv, 'o', 'Color', Iformatting(:, i)); % plot the inverses of the points

        % plot(W, R, 's', 'Color', Rformatting(:, i));

        % Slabel(i) = "S" + int2str(i);
        Ilabel(i) = "I" + int2str(i);
        % Rlabel(i) = "R" + int2str(i);

    end

    xlabel("Week")
    ylabel("% of People Infected")
    title("Test")

    labels = reshape([Slabel; Ilabel; Rlabel], 1, length(Slabel) + length(Ilabel) + length(Rlabel));
    lgd = legend(cellstr(num2cell(labels)));
    lgd.NumColumns = 3;
    lgd.Orientation = 'horizontal';

end
