function midi = f0toMidi( f0, t, A4, varargin)
% midi = f0toMidi( f0, t, A4 )
% midi = f0toMidi( f0, t, A4, filepath )
%
% Converts the f0 vector to MIDI (struct and file if path is given).
%
% Arguments:
%   f0         = input vector [N_samples x 1]
%   A4         = tuning frequenzy [Hz]
%   t          = quantized time vector [s]
%   filepath   = (optional) path for saving the results in a .mid-file
%
% Output:
%   midi       = MIDI struct

%% Transform arrays
f0 = f0(:); t = t(:);
nonote = 10e3;                      % MIDI number instead of inf when f0 = 0

f0_midi = round(69+12*log2(f0/A4)); % frequency to midi number
% notes = find(diff(f0_midi)~= 0);    % find changes in notes
f0_midi(isinf(f0_midi)) = nonote;
notes = find(diff([nonote; f0_midi])~= 0); notes = [notes;length(f0_midi)+1]; %notes = notes-[0;ones(length(notes)-1,1)]; % find changes in notes


%% Initialize variables and arrays
N = size(notes,1)-1;            % number of MIDI-notes         
midi_tones = zeros(N,1);            % vector for midi tones
note_on = midi_tones;               % vector for time of note-on
note_off = midi_tones;              % vector for time of note-off
    
%% Create midi info from f0

for i = 1:N
    start_idx = notes(i); %  save new start index for next note
    end_idx = notes(i+1)-1;                 % index of note change 
    midi_tones(i) = f0_midi(start_idx);   % current tone MIDI-value    
    note_on(i) = t(start_idx);          % start time of note
    note_off(i) = t(end_idx);           % end time of note
end

% Remove 0 frequencies
n_inf =  find(midi_tones == nonote);
midi_tones(n_inf) = [];
note_on(n_inf) = [];
note_off(n_inf) = [];
N = length(midi_tones);

%% MIDI output

if N == 0 
    M = [ones(1,2) zeros(1,4)]; % create empty midi matrix
else
    % create MIDI matrix
    M = zeros(N,6);
    M(:,1) = 1;              % all in track 1
    M(:,2) = 1;              % all in channel 1
    M(:,3) = midi_tones;     % note numbers
    M(:,4) = ones(N,1)'*100; % volume
    M(:,5) = note_on;        % note on
    M(:,6) = note_off;       % note off
end
    
% create MIDI struct
midi = matrix2midi(M);
if nargin > 3 && ~strcmp(varargin{1},'')    % write into file if path is given
    writemidi(midi, varargin{1});
end
