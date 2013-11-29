function f0 = WACF(x,fs)

% function [f0] = WACF(x,fs)
%
% Finds the fundamental frequency of the sample block using the ADMF weighted ACF.
%
% Arguments:
%   x          = input vector
%   fs         = sampling rate [Hz]
%
% Output:
%   f0         = fundamental frequency [Hz]

%% Parameters
k = 1;                          % function denominator coefficient
th = 0.3;                       % center clipping threshold (1/100 % of block maximum)

%% --------------- pre-processing ---------------------
x_a = abs(x); x(x_a<th*max(x_a)) = 0; % center-clipping

%% Weighted ACF calculation
acf = xcorr(x,'biased');        % Auto Correlation Function
acf = acf(length(x):end);       % truncate to single-sided
amdf = xamdf(x,'biased');       % Average Magnitude Difference Function
wacf = acf./(amdf+k);           % AMDF-weighted ACF

%% Finding the fundamental frequency:
i_mi = find(diff(wacf)>=0,1,'first'); % first local minimum
[~, i_ma] = max(wacf(i_mi:end));      % second global maximum
N = i_mi+i_ma-1;                      % actual index

% Output
f0 = fs/(N-1);                        % fundamental frequency estimate [Hz]

% No f0 found
if isempty(f0)
    f0 = 0;
end

% plot(wacf);%hold on; plot(i_ma,d(i_ma),'ro'); % debugging
    
end
