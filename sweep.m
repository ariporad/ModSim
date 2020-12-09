function res = sweep(velocity_range, timespan)
    % Initial Y velocity from ~[-15000, +15000] against ecentricity and
    % height of final orbit.
    % Caluclate final orbit by projecting points onto a polar coordinate
    % system and doing the last full rotation.
    % If a full orbit isn't made, then the height should still be
    % calculated by the excentricity should NaN.
    
    radius_earth = 6371071; % m
    radius_orbit = 257495 + radius_earth; % m
    
    max_heights = zeros(length(velocity_range), 1);
    
    for i=1:length(velocity_range)
        [~, positions_cart, ~] = simulate_launch(timespan, [radius_earth + 1, 0, 0, velocity_range(i)]);
        [thetas, rhos] = cart2pol(positions_cart(:, 1), positions_cart(:, 2));
        
        thetas = mod(thetas + (2 * pi), 2 * pi);
        
        max_heights(i) = max(rhos);
        
        % Eccentricity calculation
        % Disabled at Zach's suggestion
        
        % Start at the end of theta
        % Store first angle
        % Work backward until a point is found with angle <= the first
        % angle
    
%         first_theta = thetas(end)
%         theta_direction = sign(thetas(end - 1) - first_theta);
%         assert(theta_direction ~= 0);
%         
%         prev_theta = first_theta;
%         theta_lower_bound = length(thetas);
%         fprintf("Pre-Loop %d\n", length(thetas));
%         for j=(length(thetas) - 1):-1:1
%             % This might do nothing 
%             sign_1 = sign(thetas(j) - prev_theta);
%             sign_2 = sign(thetas(j) - (prev_theta - (theta_direction * 2 * pi)));
%            if (sign_1 ~= theta_direction) && sign_1 ~= 0 
%                fprintf("BREAKING_1! s1: %d s2: %d j: %d theta_direction: %d prev_theta: %d theta: %d\n", sign_1, sign_2, j, theta_direction, prev_theta, thetas(j)); 
%                fprintf("NOT_BREAKING_2! s1: %d s2: %d j: %d theta_direction: %d prev_theta - 2*pi: %d theta: %d\n", sign_1, sign_2, j, theta_direction, prev_theta - (theta_direction * 2 * pi), thetas(j));
%            if (sign_2 ~= theta_direction) && sign_2 ~= 0
%            
%                break
%            end
%            end 
%            
%            if (theta_direction == -1 && thetas(j) <= first_theta && prev_theta > first_theta) || (theta_direction == 1 && thetas(j) >= first_theta && prev_theta < first_theta)
%                break
%            end 
%                   
%            prev_theta = thetas(j);
%            theta_lower_bound = j;
%         end
%         
%         thetas_in_last_orbit = thetas(theta_lower_bound:end);
%         
%         polarplot(thetas_in_last_orbit, rhos(theta_lower_bound:end));
%         pax = gca;
%         pax.ThetaAxisUnits = 'radians';
    end
end