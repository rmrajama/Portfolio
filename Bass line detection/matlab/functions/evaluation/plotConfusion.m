function plotConfusion(file_est,file_gt,frame_length,hop_length,fs)
% plotConfusion(fs,hop_length,frame_length,file)
%
% Plots the correctly and falsely estimated bass line notes, along with the
% undetected ones.
%
% Arguments:
%   file_est     = estimated MIDI file name
%   file_gt      = ground truth MIDI file name
%   frame_length = resampling frame length [ms]
%   hop_length   = resampling hop length [ms]
%   fs           = sampling frequency of original data [Hz]

%% Parameters
fsize = 16; % font size
    
%% Resample MIDI
true_midi_struct = readmidi(file_gt);                                   % MIDI struct
true_midi = midiInfo(true_midi_struct,0);                               % MIDI matrix
true_midi_labels = midi2labels(true_midi,fs,frame_length,hop_length,1); % MIDI vector

est_midi_struct = readmidi(file_est);
est_midi = midiInfo(est_midi_struct,0);
est_midi_labels = midi2labels(est_midi,fs,frame_length,hop_length,1);

%% Pre-calculation
[true_midi_labels est_midi_labels] =...
    sameLength(true_midi_labels,est_midi_labels);                          % zero-pad to same length
correct = true_midi_labels == est_midi_labels;                             % indices of correct detections
false = true_midi_labels ~=est_midi_labels;                                % indices of false detections
t = frameTime(ms2samples(frame_length,fs),ms2samples(hop_length,fs),...
    length(true_midi_labels),fs);                                          % time vector

%% Plot confusion
figure;
    plot(t(correct),est_midi_labels(correct),'gs');hold on; % true
    plot(t(false),est_midi_labels(false),'rs')              % false
    plot(t(false),true_midi_labels(false),'bs')                  % undetected
    grid on;
    xlabel('Time [s]','FontSize',fsize); ylabel('MIDI number','FontSize',fsize); 
    title(file_est,'FontSize',fsize,'Interpreter','none')
    legend('correct','false','undetected','Location','SouthEast');
    set(gca,'FontSize',fsize-2);
    axis([0 t(end) 0 60])
    
end