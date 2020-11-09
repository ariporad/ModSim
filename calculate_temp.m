function [temp] = calculate_temp(time)
%{
Params:
    - time: Seconds from the start of the year

Output:
    - temp: temperature at given time in Kelvins
%}

temp_day_of_year_offset = -10 * cos((time * 2 * pi) / (365 * 24 * 60 * 60)) + 10;
temp = temp_day_of_year_offset + -4 * cos((time * 2 * pi)/(24 * 60 * 60));

temp = temp + 273.15; % Convert to Kelvin
end
