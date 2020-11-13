% [T, Y, debug] = house_simulate(timespan, max_timestep, height_aperture, width_aperture, area_floor, floor_thickness, insulation_thickness)
% NOTE: unlike house_simulate, floor_thicknesses and insulation_thicknesses should be ranges/vectors.
function cumulative_errors = house_sweep(timespan, height_aperture, width_aperture, area_floor, floor_thicknesses, insulation_thicknesses, ideal_temp)
    %% Setup State
    total_timer_ref = tic;
    timestamp = now();
    num_simulations_total = length(floor_thicknesses) * length(insulation_thicknesses);
    % cumulative_errors has rows of floor thicknesses, columns of
    % insulation thicknesses, and values of cumulative errors.
    cumulative_errors = zeros(length(floor_thicknesses), length(insulation_thicknesses));
    % Time Estimates
    default_run_time_estimate = 1.5; % seconds
    actual_run_times = ones(1, num_simulations_total) * default_run_time_estimate;
    
    % Allow passing [1 45 180] * (24 * 60 * 60) to timespan to simulate
    % from 1 to 180 days but skipping the first 45 (inclusive) for analysis
    start_time_to_skip = 0;
    if length(timespan) == 3
        start_time_to_skip = timespan(2);
        timespan = timespan([1, 3]);
    end   
    
    %% Setup UI
    fprintf("Running a parameter sweep with %1.0f simulations...\n", num_simulations_total);
    progress_bar = waitbar(0, sprintf("Running %1.0f simulations...", num_simulations_total), "Name", "Sweep Progress", 'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
    setappdata(progress_bar, 'canceling', 0);
    progress_bar_pos = get(progress_bar, 'Position');
    progress_bar_pos(4) = 100;
    set(progress_bar, 'Position', progress_bar_pos);
    
    
    %% Run the Simulations
    num_simulations_completed = 0;
    for floor_idx=1:length(floor_thicknesses)
        for insulation_idx=1:length(insulation_thicknesses)
            %% Check for clicked cancel button
            if getappdata(progress_bar,'canceling')
                delete(progress_bar);
                assert(false, "Cancel button clicked! Sweep aborted!");
            end
            
            %% Setup Simulation
            floor_thickness = floor_thicknesses(floor_idx);
            insulation_thickness = insulation_thicknesses(insulation_idx);
            
            %% Run It
            timer_ref = tic;
            [T, Y, debug] = house_simulate(timespan, height_aperture, width_aperture, area_floor, floor_thickness, insulation_thickness);
            run_time = toc(timer_ref);
            
            num_simulations_completed = num_simulations_completed + 1;
            actual_run_times(num_simulations_completed) = run_time;
            
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
            %fprintf("Simulation %1.0f took %1.2f seconds, for floor=%1.2f and insulation=%1.2f.\n\tcumulative_error=%1.2f", num_simulations_completed, time_taken, floor_thickness, insulation_thickness, cumulative_error);
            waitbar( ...
                num_simulations_completed / num_simulations_total, ...
                progress_bar, ...
                sprintf( ...
                    "Run %1.0f/%1.0f (f=%1.2fm, i=%1.2fm) done in %1.2fs (%1.0fs total). %1.0fs left...\n", ...
                    num_simulations_completed, num_simulations_total, floor_thickness, insulation_thickness, run_time, toc(total_timer_ref), mean(actual_run_times) * (num_simulations_total - num_simulations_completed) ...
                ) ...
            );
            
            %save(sprintf("raw_data/simulation_results_inprogress_%1.0f_floor_%1.0f_insul_%1.0f.mat", timestamp, floor_thickness * 100, insulation_thickness * 100), "floor_thickness", "insulation_thickness", "num_simulations_completed", "T", "Y", "debug", "time_taken");
        end
    end
    
    %% Cleanup
    delete(progress_bar);
    fprintf("Done with sweep! Ran %1.0f simulations! Took %1.2f seconds (avg %1.2fs each).\n", num_simulations_completed, toc(total_timer_ref), mean(actual_run_times));
end

