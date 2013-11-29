function [ onTimeError, offTimeError ] = calcIntervalError( gt_midi, detected_midi, pre_th, post_th )
% function [ onTimeError, offTimeError ] = calcIntervalError( gt_midi, detected_midi, th )
%
%   Calculates onset and offset errors betwen ground truth and detected
%   MIDI file within given threshold
%
% Arguments:
%   detected_midi   = URL to detected midi file (.mid) or MIDI matrix (see
%                     argument 'mode')
%   gt_midi         = URL to ground truth version .mid file
%   pre_th          = Threshold for on/offsets before true on/offset taken into
%                     acount
%   post_th         = Threshold for on/offsets after true on/offset taken into
%                     acount
%
% Output:
%   onTimeError     = Mean aboslute ontime error [s]
%   offTimeError    = Mean absolute offtime error [s]

%% Initialize
N = size(gt_midi,1);
onTimeErrors = [];
offTimeErrors = [];

%% Loop thorugh all true tones in ground truth file
for j = 1:N
    tone = gt_midi(j,3);
    onset = gt_midi(j,5);
    offset = gt_midi(j,6);
    
    i = find(detected_midi(:,3) == tone);
    temp_onset = detected_midi(i,5);
    temp_offset = detected_midi(i,6);
    
    idx = find((temp_onset > onset-pre_th) & (temp_onset < post_th +onset)); % find indices where onset it within pre threshold
    
    if ~isempty(idx)
        onTimeErrors(end+1) = abs(onset-temp_onset(idx(1))); % write closest onset error to array
    end

    idx = find((temp_offset > offset-pre_th) & (temp_offset < post_th +offset)); % find indices where offset it within pre threshold
    
    if ~isempty(idx)
        offTimeErrors(end+1) = abs(offset-temp_offset(idx(1))); % write closest offset error to array
    end
end

%% Post processing if arrays are empty
if isempty(onTimeErrors)
    onTimeErrors = -1;
elseif isempty(offTimeErrors)
    offTimeErrors = -1;
end

%% Return
onTimeError = mean(onTimeErrors);
offTimeError = mean(offTimeErrors);

end

