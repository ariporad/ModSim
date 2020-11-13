% [T, Y, debug] = house_simulate(timespan, max_timestep, height_aperture, width_aperture, area_floor, floor_thickness, insulation_thickness)
% NOTE: unlike house_simulate, floor_thicknesses and insulation_thicknesses should be ranges/vectors.
function cumulative_errors = house_sweep(timespan, max_timestep, height_aperture, width_aperture, area_floor, floor_thicknesses, insulation_thicknesses, ideal_temp)
    %% Setup State
    total_timer_ref = tic;
    timestamp = now();
    num_simulations_total = length(floor_thicknesses) * length(insulation_thicknesses);
    % cumulative_errors has rows of floor thicknesses, columns of
    % insulation thicknesses, and values of cumulative errors.
    cumulative_errors = zeros(length(floor_thicknesses), length(insulation_thicknesses));
    
    % Allow passing [1 45 180] * (24 * 60 * 60) to timespan to simulate
    % from 1 to 180 days but skipping the first 45 (inclusive) for analysis
    start_time_to_skip = 0;
    if length(timespan) == 3
        start_time_to_skip = timespan(2);
        timespan = timespan([1, 3]);
    end   
    
    %% Setup UI
    fprintf("Running a parameter sweep with %2.0f simulations.\n", num_simulations_total);
    progress_bar = waitbar(0, sprintf("Running %2.0f simulations...", num_simulations_total));
    
    %% Run the Simulations
    num_simulations_completed = 0;
    for floor_idx=1:length(floor_thicknesses)
        for insulation_idx=1:length(insulation_thicknesses)
            %% Setup Simulation
            floor_thickness = floor_thicknesses(floor_idx);
            insulation_thickness = insulation_thicknesses(insulation_idx);
            
            %% Run It
            timer_ref = tic;
            [T, Y, debug] = house_simulate(timespan, max_timestep, height_aperture, width_aperture, area_floor, floor_thickness, insulation_thickness);
            time_taken = toc(timer_ref);
            
            num_simulations_completed = num_simulations_completed + 1;
            
            %% Analysis
            % this is a logical array of mapping to values of T to include
            T_without_start_mask = T >= start_time_to_skip;
            % this is just a trimmed-down version of T
            T_without_start = T(T_without_start_mask);
            
            duration = range(T_without_start);
            air_temps = Y(T_without_start_mask, 1);
            
            cumulative_error = trapz(T_without_start, abs(ideal_temp - air_temps)) / duration;
            cumulative_errors(floor_idx, insulation_idx) = cumulative_error;
            
            %% Update UX
            fprintf("Simulation %1.0f took %1.2f seconds, for floor=%2.2f and insulation=%2.2f.\n\tcumulative_error=%1.2f", num_simulations_completed, time_taken, floor_thickness, insulation_thickness, cumulative_error);
            waitbar( ...
                num_simulations_completed / num_simulations_total, ...
                progress_bar, ...
                sprintf( ...
                    "Ran Simulation %1.0f/%1.0f (floor=%2.2fm, insulation=%2.2fm) in %2.2fs, %1.0f/%1.0f to go...", ...
                    num_simulations_completed, num_simulations_total, floor_thickness, insulation_thickness, time_taken, (num_simulations_total - num_simulations_completed), num_simulations_total ...
                ) ...
            );
            
            save(sprintf("raw_data/simulation_results_inprogress_%1.0f_floor_%1.0f_insul_%1.0f.mat", timestamp, floor_thickness * 100, insulation_thickness * 100), "floor_thickness", "insulation_thickness", "num_simulations_completed", "T", "Y", "debug", "time_taken");
        end
    end
    
    %% Cleanup
    close(progress_bar);
    fprintf("Done with sweep! Ran %1.0f simulations! Took %2.2f seconds.", num_simulations_completed, toc(total_timer_ref));
end

