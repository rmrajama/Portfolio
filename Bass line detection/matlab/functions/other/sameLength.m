function [ arr1 arr2 ] = sameLength( arr1, arr2 )
% function [ arr1 arr2 ] = sameLength( arr1, arr2 )
%
%   Zero-pad arrays to same length

if size(arr1,2) ~= size(arr2,2)
    [~,choice] = max([size(arr1,2)  size(arr2,2)]);
    if choice-1
        arr1 = [arr1 zeros(1,(length(arr2)-length(arr1)))];
    else
        arr2 = [arr2 zeros(1,(length(arr1)-length(arr2)))];
    end
end
end

