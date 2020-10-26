function [T, M] = hiv_euler(func, dt, tRange, initVals)
    T=tRange(1):dt:tRange(2);
    T=T';
    
    vals = initVals;
    
    for i=2:(length(T) + 1)
        lastVals = vals(i - 1, :);
        changes = func(T(i - 1), lastVals);
        
        changes = changes' .* dt;
        
        vals(i, :) = lastVals + changes;
    end
    

    M = vals(2:end, :);
end

