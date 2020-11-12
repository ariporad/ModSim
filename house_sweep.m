% [T, Y, debug] = house_simulate(timespan, max_timestep, height_aperture, width_aperture, area_floor, floor_thickness, insulation_thickness)
% NOTE: unlike house_simulate, floor_thicknesses and insulation_thicknesses should be ranges/vectors.
function cumulative_errors = house_sweep(timespan, max_timestep, height_aperture, width_aperture, area_floor, floor_thicknesses, insulation_thicknesses, ideal_temp)
    total_timer_ref = tic;
    
    ROLLING_RANGE_LENGTH = 24 * 60 * 60;
    
    num_simulations_total = length(floor_thicknesses) * length(insulation_thicknesses);
    
    fprintf("Running a parameter sweep with %2.0f simulations.\n", num_simulations_total);
    
    progress_bar = waitbar(0, sprintf("Running %2.0f simulations...", num_simulations_total));
    
    timestamp = now();
    
    % cumulative_errors has rows of floor thicknesses, columns of insulation thickness, and values of cumulative errors
    cumulative_errors = zeros(length(floor_thicknesses), length(insulation_thicknesses), 3);
    
    num_simulations_completed = 0;
    for floor_idx=1:length(floor_thicknesses)
        for insulation_idx=1:length(insulation_thicknesses)
            floor_thickness = floor_thicknesses(floor_idx);
            insulation_thickness = insulation_thicknesses(insulation_idx);
            
            timer_ref = tic;
            [T, Y, debug] = house_simulate(timespan, max_timestep, height_aperture, width_aperture, area_floor, floor_thickness, insulation_thickness);
            time_taken = toc(timer_ref);
            
            num_simulations_completed = num_simulations_completed + 1;
            
            waitbar( ...
                num_simulations_completed / num_simulations_total, ...
                progress_bar, ...
                sprintf( ...
                    "Ran Simulation %1.0f/%1.0f (floor=%2.2fm, insulation=%2.2fm) in %2.2fs, %1.0f/%1.0f to go...", ...
                    num_simulations_completed, num_simulations_total, floor_thickness, insulation_thickness, time_taken, (num_simulations_total - num_simulations_completed), num_simulations_total ...
                ) ...
            );
        
            TRIM_AMOUNT = 45 * 24 * 60 * 60;
            
            t_without_start_mask = T >= (TRIM_AMOUNT);
            t_without_start = T(t_without_start_mask);

            air_temps = Y(t_without_start_mask, 1);
            rolling_range_length = length(air_temps) / (range(t_without_start) / ROLLING_RANGE_LENGTH);
            
            avg_dist_from_ideal = mean(abs(ideal_temp - air_temps));
            avg_range = mean(movmax(air_temps, rolling_range_length) - movmin(air_temps, rolling_range_length));
            avg_integral = trapz(t_without_start, abs(ideal_temp - air_temps));
            
            cumulative_errors(floor_idx, insulation_idx, 1) = avg_dist_from_ideal;
            cumulative_errors(floor_idx, insulation_idx, 2) = avg_range;
            cumulative_errors(floor_idx, insulation_idx, 3) = avg_integral;

            
            
            fprintf("Simulation %1.0f took %1.2f seconds, for floor=%2.2f and insulation=%2.2f.\n\tavg_dist_from_ideal=%1.2f\tavg_range=%1.2f\tavg_integral=%1.2f\n\n", num_simulations_completed, time_taken, floor_thickness, insulation_thickness, avg_dist_from_ideal, avg_range, avg_integral);
            
            
            save(sprintf("raw_data/simulation_results_inprogress_%1.0f_floor_%1.0f_insul_%1.0f.mat", timestamp, floor_thickness * 100, insulation_thickness * 100), "floor_thickness", "insulation_thickness", "num_simulations_completed", "T", "Y", "debug", "time_taken");
        end
    end
    
    close(progress_bar);
    
    fprintf("Done with sweep! Ran %1.0f simulations! Took %2.2f seconds.", num_simulations_completed, toc(total_timer_ref));
end

