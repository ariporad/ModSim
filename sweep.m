function res = sweep(velocity_range, timespan)
    % Initial Y velocity from ~[-15000, +15000] against ecentricity and
    % height of final orbit.
    % Caluclate final orbit by projecting points onto a polar coordinate
    % system and doing the last full rotation.
    % If a full orbit isn't made, then the height should still be
    % calculated by the excentricity should NaN.
    
    radius_earth = 6371071; % m
    radius_orbit = 257495 + radius_earth; % m
    
    max_heights = zeros(size(velocity_range));
    
    for i=1:length(velocity_range)
        [~, positions_cart, ~] = simulate_launch(timespan, [radius_earth + 1, 0, 0, velocity_range(i)]);
        [thetas, rhos] = cart2pol(positions_cart(:, 1), positions_cart(:, 2));
        
        max_heights(i) = max(rhos);
        
        % Start at the end of theta
        % Store first angle
        % Work backward until a point is found with angle <= the first
        % angle
    end
end