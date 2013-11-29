function [ labels ] = midi2labels( M, fs, frame_length, hop_length, q )
% function [ labels ] = midi2labels( M, fs, frame_length, hop_length, q )
%
%   Tranforms midi file to label vector quality calculation.
%
% Arguments:
%   M               = MIDI matrix [N x 6]
%   fs              = Sampling frequenzy [Hz]
%   frame_length    = Frame length [ms]
%   hop_length      = Hop length [ms]
%   q               = 1 (true) for quantifisation to closest frame, 0 if
%                       MIDI tones are synced with hop length
%
% Output:
%   labels          = Label vector with estimates [M x 1]
 

if nargin < 5
    q = 0;
end

% Precalculation
frame_size = ms2samples(frame_length,fs); % [samples]
hop_size = ms2samples(hop_length,fs);     % [samples]
N_x = fs*M(end,6);                         % number of samples in audio file 
max_frames = ceil(N_x/hop_size);          % the maximum number of iterations possible

% Initialize array
labels = zeros(1,max_frames);
current_tone = 1;
t = (hop_length/1e3)*(0:max_frames-1).';    % time vector with values in [ms]
tol = 1e-6;                                 % tolerance for correct recognition of 0
for i = 1:size(M,1)
    if ~q
        start_sample = find(abs(t-M(current_tone,5)) < tol);
        
        if i == size(M,1)  % if last last tone
            end_sample = find(t == t(end));
            labels(start_sample:end_sample) = M(current_tone,3); % Append tone to label array
            continue
        end
        
        end_sample = find(abs(t-M(current_tone,6)) < tol);
        labels(start_sample:end_sample) = M(current_tone,3);    % Append tone to label array
        current_tone = current_tone+1;
        continue;
    end
    
    temp = find((decimalRound(t,5)-decimalRound(M(current_tone,5),5)) >= -tol); % find closest start_sample by quantifying up
    
    if isempty(temp)
        temp = length(t);
    end
    
    start_sample = temp(1);
    
    if i == size(M,1)
        end_sample = find(t == t(end));
        labels(start_sample:end_sample) = M(current_tone,3);
        continue
    end
    temp = find((decimalRound(t,5)-decimalRound(M(current_tone,6),5)) <= tol); % find closest end_sample by quantifying down
    end_sample = temp(end);

    labels(start_sample:end_sample) = M(current_tone,3); % write to labels
    current_tone = current_tone+1;
end

