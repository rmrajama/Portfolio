function [f0, t] = BassLineDetector(x, fs, varargin)
% [f0 t] = BassLineDetector(x, fs)
% [f0 t] = BassLineDetector(x, fs, mode, hop_length, frame_length, A4, curfile)
%
% Estimates the bassline fundamental frequency blockwise for the input 
% vector x.
%
% Arguments:
%   x            = input vector [N_samples x N_channels]
%   fs           = sampling rate [Hz]
%   mode         = analysis mode 
%                   1 = fast: good note separation, but requires high SNR
%                             (usually performs better on stems)
%                   2 = slow: robust against noise, but poor temporal
%                             resolution (usually performs better on full mixes)
%   hop_length   = length of non-overlapping hop between frames [ms]
%   frame_length = length of frame [ms]
%   A4           = tuning frequency [Hz]
%   file_path    = path to MIDI file
%
% Output:
%   f0           = bassline fundamental frequency [Hz]
%   t            = time vector [s]

%%%%%%%%%%%%%%%%%%%%%%%%%% Input handling %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Mode selection
if nargin > 2
    mode = varargin{1};
else 
    mode = 2; % default
end

% Hop length selection
if nargin > 3
    hop_length = varargin{2};
else 
    hop_length = 30; % default [ms]
end

% Frame length selection
if nargin > 4
    frame_length = varargin{3};
else 
    frame_length = 70; % default [ms]
end

% Tuning frequency selection
if nargin > 5
    A4 = varargin{4};
else 
    A4 = 440; % default [Hz]
end

% Path into which the MIDI file is written
if nargin > 6
    file_path = varargin{5};  % MIDI file path
else
    file_path = '';           % default: do not create MIDI file
end


%%%%%%%%%%%%%%%%%%%%%%%%%% Pre-processing %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Parameters

% Pre-processing filter
fc_u = 300;                   % filter upper cut-off frequency [Hz]
fc_l = 30;                    % filter lower cut-off frequency [Hz]
Ncoeff_LP = 8;                % low-pass filter order

% Time window
window = 'rect';              % window function
% window = 'hamm';
% window = 'hann';

% Post-processing
min_length = 50;              % notes shorter than this will be ignored [ms]

%% Pre-processing

% Mixdown
x = mixdown(x); % convert possible multi-channel signals to mono

% Filtering
[b,a] = butter(Ncoeff_LP,fc_u/fs*2,'low');    % Butterworth IIR LP-filter
x = filtfilt(b,a,x);                          % zero phase IIR filtered signal

% Downsampling
fs_old = fs;            % store old sampling frequency 
M = floor(fs_old/4410); % downsampling factor (chosen so that fs_downsampled >= 4410)
fs = fs_old/M;          % new sampling frequency
x = downsample(x,M);    % downsampled signal

%% Loop initialization

% Precalculation
frame_size = ms2samples(frame_length,fs); % [samples]
hop_size = ms2samples(hop_length,fs);     % [samples]
N_x = length(x);                          % number of samples in audio file 
max_frames = ceil(N_x/hop_size);          % the maximum number of iterations possible

% Initialization
endloop = 0;                              % flag indicating loop exit 
i = 1;                                    % iteration index

% Result and post-processing vectors
f0 = zeros(max_frames,1);                 % preallocate enough memory for results matrix
energy = zeros(max_frames,1);             % energy vector 

% window function calculation
switch window
    case 'hamm'                           % Hamming window
        w = 0.54 -0.46*cos(2*pi*(0:frame_size-1)/(frame_size-1)).';
    case 'hann'                           % von Hann window
        w = 0.5*(1-cos(2*pi*(0:frame_size-1)/(frame_size-1))).';
    otherwise                             % rectangular window as default
        w = ones(frame_size,1);
end

%%%%%%%%%%%%%%%%%%%%%% Blockwise processing %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Blockwise processing

while ~endloop
    
    %% Frame initialization
    
    % Frame boundary
    start_sample = 1 + (i-1) * hop_size;        % start index of current frame [samples]
    end_sample = start_sample + frame_size-1;   % end index of current frame [samples]
    
    % Loop exit
    if end_sample >= N_x
        end_sample = N_x;                       % last frame may be shorter than N_frame
        endloop = 1;                            % end loop after this iteration   
    end
    
    % Current signal block of size: frame_size
    xc = x(start_sample:end_sample); 
    xc = w.*zeropadding(xc, frame_size);        % windowed (and possibly zero-padded) signal block
    
    %% Frame pre-processing
        
    energy(i) = mean(xc.^2);                    % block energy calculation 
              
    %% Pitch tracking

    f0(i) = WACF(xc,fs);
    
    %% Iteration finalization
    
    % other
    i = i+1;                                     % increment iteration index
    multiWaitbar('Processing...',i/max_frames);  % approx. calculation progress
    
end

%%%%%%%%%%%%%%%%%%%%%%%%% Post-processing %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Iteration finalization

% Vector truncation
N_block = i-1;                                    % number of blocks
f0 = f0(1:N_block,:);                             % truncate after true length is known
energy = energy(1:N_block);

% other
t = frameTime(frame_size,hop_size,N_block,fs);    % create time vector
multiWaitbar('CloseAll');                         % close the open waitbar

%% Post-processing

% Tonality detection
[f0 energy_s] = energyThreshold(f0,energy,mode);

% Error correction
f0 = errorCorrection(f0,fc_l,fc_u,A4,mode, energy, hop_length,min_length);

% Convert to midi
f0toMidi(f0,t-frame_length*1e-3/2,A4,file_path);  % quantization to frame beginning

%% Plot with estimated f0's and spectrogram
fsize = 16;
figure;
    plot(t,f0,'k*');                                                   % plot estimate vector
    hold on;
%     a_max = 100;plot(t,energy_s/max(energy_s)*a_max,'b--')             % plot smoothed energy vector
    [~,F,T,P] = spectrogram(x,frame_size,frame_size-hop_size,2500,fs); % calculate spectrogram
    i_fu = find(F>fc_u,1,'first');                                     % truncate spectrogram
    surf(T,F(1:i_fu),10*log10(P(1:i_fu,:)),'edgecolor','none');        % plot spectrogram
    axis tight;view(0,90);
    title('Spectrogram with estimates','FontSize',fsize);
    xlabel('Time [s]','FontSize',fsize); 
    ylabel('Hz','FontSize',fsize);
    legend('f0_{hat}')
    set(gca,'FontSize',fsize-2); axis([0 inf fc_l fc_u]);
