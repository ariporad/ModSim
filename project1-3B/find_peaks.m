function peaks = find_peaks(S, I, R, W)
	% We add a -Inf to the front and end so that if the first or last data point is a peak we properly
	% catch it.
	tempI = [-Inf I -Inf];

	peaks = []

	for i=2:(length(tempI) - 1)
		% Must be greater than the previous element but greater than or equal to the next element.
		% This ensures that we catch the case where a peak has two equal points exactly once.
		if tempI(i) > tempI(i - 1) & tempI(i) >= tempI(i + 1)
			peaks(:, end + 1) = [tempI(i); W(i - 1)] % W(i - 1) because tempI has an additional item at the beginning (-Inf) that we need to account for
		end
	end
end