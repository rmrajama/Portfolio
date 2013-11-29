function f0 = errorCorrection(f0,fc_l,fc_u,A4,mode,energy, hop_length,min_length)
% f0 = errorCorrection(f0,fc_l,fc_u,A4,mode,energy, hop_length,min_length)
%
% Attempts to correct errors in the bassline fundamental frequency estimates.
%
% Arguments:
%   f0         = (column) matrix or vector containing the bassline fundamental [Hz]
%   fc_l       = lower cutoff frequency for valid f0 range [Hz] 
%   fc_u       = upper cutoff frequency for valid f0 range [Hz] 
%   A4         = tuning frequency [Hz] (usually 440 Hz)
%   energy     = energy vector
%   hop_length = inter-estimate time [ms]
%   min_length = the minimum length of a continuous f0 trajectory 
%                (shorter trajectories are deleted ) [ms]
%
% Output:
%   f0      = corrected fundamental matrix/vector [Hz]

%% Parameters:
n = [100 175]; % median filter window size [ms]

%% Operation 1: Delete outlier estimates

f0(f0 < fc_l | f0 > fc_u) = 0;  % overwrite

%% Operation 2: Delete too short notes

n_min = ms2samples(min_length,1/hop_length*1e3); % min number of same neighbours needed to not be deleted
if n_min > 0
    f0_q = 2.^(round(12*log2(f0/A4))/12)*A4;     % quantized f0
    
    counter = 0;                    % holds number of same notes in a row
    f0_prev = f0_q(1); 
    for i = 1:length(f0_q)
        if (f0_q(i) == f0_prev)     % increment counter for continuous trajectory 
            counter = counter + 1;
        elseif counter > n_min      % don't do anything if trajectory is long enough
            counter = 1;            % reset counter
        else                        % delete trajectories shorter than the minimum length
            f0(i-counter:i-1) = 0;  % overwrite
            counter = 1;            % reset counter
        end
        f0_prev = f0_q(i);          % update previous value holder
    end
end

%% Operation 3: Median filtering

n = ms2samples(n,1/hop_length*1e3); % convert window size to [samples]
f0 = medianfilt(f0,n(mode));        % apply median filtering

%% Operation 4: Extend note durations to beginning of next (slow mode only)

if mode == 2
    N = length(f0);
    for i = 2:N-1                         % for all but first and last elements
        f0_cur = f0(i);
        f0_prev = f0(i-1);
        if ~f0_cur                        % leave no gaps
            f0(i) = f0_prev;
        end
    end
    f0(N) = f0(N-1);
    f0 = energyThreshold(f0,energy,mode); % delete notes from sections where the BL isn't playing
end

end
