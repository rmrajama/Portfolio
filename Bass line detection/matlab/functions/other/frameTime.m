function t = frameTime(frame_size,hop_size,N_frames,fs)
% t = frameTime(frame_size,hop_size,N_frames,fs)
% 
% Calculates the time vector for consecutive frames.
%
% Arguments:
%   frame_size = frame length [samples]
%   hop_size   = non-overlapping frame length [samples]
%   N_block    = number of frames
%   fs         = sampling frequency [Hz]
%
% Output:
%   t          = time vector quantized to frame middle-point [s]

t = (frame_size/2+(hop_size)*(0:N_frames-1).')/fs; % create time vector

end