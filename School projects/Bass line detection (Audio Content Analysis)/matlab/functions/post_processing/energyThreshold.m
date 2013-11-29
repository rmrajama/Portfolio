function [f0 energy_s] = energyThreshold(f0,energy,mode)
% Energy thresholding for silence detection. 
%
% Arguments:
%   f0        = fundamental frequency [Hz]
%   energy    = energy vector
%
% Output:
%   f0        = corrected fundamental frequency [Hz] (= 0, else unchanged)
%   energy_s  = smoothed energy vector
%   mode      = analysis mode (1 = fast, 2 = slow)

%% Parameters
                         
alpha = [0.5 0.9];                  % LP-filter feedback coefficient
th = [0.2 0.25];                    % relative energy threshold (%/100)

%% Pre-processing

% LP-filtering
b = 1-alpha(mode);                  % numerator coefficient
a = [1 -alpha(mode)];               % denominator coefficients
energy_s = filter(b,a,energy);      % smoothed energy vector

%% Energy thresholding

f0(energy_s < th(mode)*max(energy_s)) = 0;  % overwrite

end