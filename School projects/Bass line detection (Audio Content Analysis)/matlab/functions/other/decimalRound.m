function [ n_rounded ] = decimalRound( n, num_dig )
% function [ n_rounded ] = decimalRound( n, num_dig )
%   
%   Round number to decimal
%
% Arguments:
%   n             = Number
%   num_dig       = Number of decimals
%
% Output:
%   n_rounded     = Rounded number
%


n_rounded = round(n*(10^num_dig))/(10^num_dig);
end

