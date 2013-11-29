function N = ms2samples(t,fs)
% N = ms2samples(t,fs)
%
% Converts the time t into samples (nearest integer) using sampling
% frequency fs
%
% Arguments:
%   t = length in ms
%   fs = sampling frequency [Hz]
%
% Output:
%   N = length in samples
%

N = round(fs*t*1e-3);
end