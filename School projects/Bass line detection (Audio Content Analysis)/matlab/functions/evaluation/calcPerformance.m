function [ quality ] = calcPerformance( detected_midi, gt_midi, frame_length, hop_length, fs, mode  )
% function [ quality ] = calcPerformance( detected_midi, true_midi, frame_length, hop_length, fs, mode  )
%
%   Compares and calculates quality of detection with respect to the ground
%   truth
%
% Arguments:
%   detected_midi   = URL to detected midi file (.mid) or MIDI matrix (see
%                     argument 'mode')
%   gt_midi         = URL to ground truth version .mid file
%   frame_length    = length of frame [ms]
%   hop_length      = length of non-overlapping hop between frames [ms]
%   fs              = sampling rate [Hz]
%   mode            = 'file' if detected midi is given as URL and 'matrix'
%                     if given as MIDI matrix
%
% Output:
%   quality         = Struct with the following calculated quality
%                     measures: Accuracy,error rate, precision, recall,
%                     over tone rate, onset error and offset error

quality = struct('accuracy',-1,'error_rate',-1,'precision',-1,'recall',-1,'ot_rate',-1,'onset_error',-1,'offset_error',-1);

if strcmp(mode,'file')
    % Read MIDI files to MIDI struct
    detected_midi_struct = readmidi(detected_midi);
    true_midi_struct = readmidi(gt_midi);
    
    % MIDI structs to MIDI matrix
    detected_midi = midiInfo(detected_midi_struct,0);
    detected_midi_labels = midi2labels(detected_midi,fs,frame_length,hop_length,1);    
    
    gt_midi = midiInfo(true_midi_struct,0);
    gt_midi_labels = midi2labels(gt_midi,fs,frame_length,hop_length,1);
elseif strcmp(mode,'matrix')
    true_midi_struct = readmidi(gt_midi);
    gt_midi = midiInfo(true_midi_struct,0);
    gt_midi_labels = midi2labels(gt_midi,fs,frame_length,hop_length,1);
end

% Array of all possible tones (labels)
classes = unique(gt_midi_labels);

%% Calculate qualities
[quality.accuracy quality.error_rate quality.precision quality.recall quality.ot_rate] = calcQuality(detected_midi_labels,gt_midi_labels,classes);
[quality.onset_error, quality.offset_error] = calcIntervalError(gt_midi,detected_midi,0.1,0.5);



