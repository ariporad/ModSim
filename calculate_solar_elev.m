% Calculate the elevation of the sun from the horizon
% `seconds` should be the number of seconds since the start of the year (00:00:00 on Jan 1). 
% `utc_offset` should be a positive or negative integer of hours (ex. -5 for EST, -9 for PDT).
%
% NOTE: this function is fundementally an approximation, and so will be somewhat inaccurate. For
%       most circumstances (ex. not in the artic circle), I think it won't be too inacurate (±~5deg)
%
% PROTIP: here are reasonable values for the paramaters:
%	- `seconds`: generally a large number between 10^5 and 10^8
%	- `lat`:  -180 to 180, generally between ~-70 and ~-125 (NB: negative) for the continential US.
%	- `long`: -180 to 180, generally between ~25 and ~45 (NB: positive) for the continential US.
%	- `utc_offset`: with a few exceptions, integers -12 to +12. -9 to -5 for the continential US.
%
% SEE ALSO: helpful resources for understanding:
%	- https://www.pveducation.org/pvcdrom/properties-of-sunlight/elevation-angle
%		- This one is *really* good (easy to understand, helpful, thorough), as is the other article	
%		  on that site (linked by this article) about solar time and HRA.
%	- https://en.wikipedia.org/wiki/Solar_zenith_angle
%	- https://www-sciencedirect-com.olin.idm.oclc.org/topics/engineering/solar-declination
%	- https://www.ncdc.noaa.gov/gridsat/docs/Angle_Calculations.pdf (less helpful than it looks)
%
% SEE ALSO: calculators for validating--won't line up exactly because it's an approximation
%	- https://www.esrl.noaa.gov/gmd/grad/solcalc/calcdetails.
%	- https://www.esrl.noaa.gov/gmd/grad/antuv/SolarCalc.jsp
function elev = calculate_solar_elev(seconds, lat, long, utc_offset)
	SECONDS_PER_DAY = 60 * 60 * 24;

	day_of_year = ceil(seconds / SECONDS_PER_DAY); % days (day of year)
	fractional_time = mod(seconds, SECONDS_PER_DAY) / 3600; % hours (time of day as fractional hours)

	hour_angle = calculate_hour_angle(lat, long, day_of_year, fractional_time, utc_offset);

	% (Solar) Declination is a representation of the tilt of the Earth and how it affects the
	% position of the Sun. (I'm not sure of the exact details.)
	% NOTE: I found three possible formulas for calculating declination. I don't know which is best,
	%       but they're all pretty similar (but, frusturatingly, not the same). I've chosen one at
	%       random, but left the rest here for when I invariably discover that I was wrong at some
	%       point in the future.

	% declination = -23.45 * cosd((360 * day_of_year / 365) + (3600 / 365)) % Original
	% declination = -23.44 * cosd(360/365 * (day_of_year + 10)) % Lila
	declination = -23.45 * sind((360/365) * (284 + day_of_year)); % Paper

	% Solar Elevation: the elevation of the sun relative to the horizon. If this is 90deg, then a
	% vertical stick won't cast a shadow.
	elev = acosd( ... % deg
		(sind(lat) * sind(declination)) + ...
		(cosd(lat) * cosd(declination) * cosd(hour_angle)) ...
	);
end

% Calculate the hour angle, which is a value used in computing the elevation of the sun.
% I'm not 100% exactly what it is.
function hra = calculate_hour_angle(lat, long, day_of_year, local_time, utc_offset)
	% Meridian (longitude) of the local time zone
	% NOTE: this is going to have edge case related bugs around the international date line (in
	%       particular, for timezones with greater than 12h offsets).
	local_standard_time_meridian = 15 * utc_offset; % deg

	% Not sure exactly what this is, but it's used to calculate equation_of_time
	unknown_eot_value = (360 / 365) * (day_of_year - 81); % deg

	% "Equation of Time" (not my name) is a number used to correct for solar time's variation across
	% the year.
	% This is an imperical approximation, so these numbers are rough measurements. They're also
	% (AFAICT) are averages across the whole year, so they're inaccurate for any given day. In my
	% testing, this inaccuracy is not significant enough to be an issue.
	equation_of_time = ... % unitless?
		(9.87 * sind(2 * unknown_eot_value)) - ...
		(7.53 * cosd(unknown_eot_value)) - (1.5 * sind(unknown_eot_value)); 

	% Now, we can adjust the local time to local solar time
	time_correction = 4 * (long - local_standard_time_meridian) + equation_of_time; % min
	local_solar_time = local_time + (time_correction / 60); % hours

	% Finally, we can compute the hour angle
	hra = 15 * (local_solar_time - 12); % deg, negative in AM and positive in PM
end