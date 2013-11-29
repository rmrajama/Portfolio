function y = mixdown(x)
% y = mixdown(x)
%
% Averages the columns of x into one column y (i.e. stereo/multi-channel to
% mono conversion)
%
% Arguments:
%   x = multi-channel (column) matrix
%
% Output:
%   y = channel averaged column vector

if size(x,2) ~= 1
    y = mean(x,2);
end
