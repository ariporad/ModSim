function [air_temp, ground_temp] = calculate_temp(time)
%{
Params:
    - time: Seconds from the start of the year

Output:
    - temp: temperature at given time in Kelvins
%}

ground_temp = -10 * cos((time * 2 * pi) / (365 * 24 * 60 * 60)) + 10 + 273.15;
air_temp = ground_temp + -4 * cos((time * 2 * pi)/(24 * 60 * 60));
end
