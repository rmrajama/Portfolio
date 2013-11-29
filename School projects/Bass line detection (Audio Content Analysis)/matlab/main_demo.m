%% Bass line estimation - demo script
%
% This script demonstrates the use of the Bass Line Detection algorithm 
% developed as a project work for the course "Audio Content Analysis".
%
% Authors:
%   Matts Hoeglund
%   Robin Rajamaeki
%
% Date: 26.7.2013
% Version: 1.0

clearvars; close all; clc;

%% Parameters
% These are the main parameters

frame_length = 70;    % [ms]
hop_length = 30;      % [ms]
A4 = 440;             % tuning frequency [Hz]
mode = 2;             % analysis mode (1 = stem, 2 = full mix)

%% Select files to be loaded

foldername = 'data/demo/'; % path to folder with audio/MIDI data
filename ={...             % name of files to be analysed
%     'Coldplay_Clocks_stem'...
    'DannyRich_FortuneTeller_full'...
    };

for i = 1:length(filename) % Loop over all files in 'filenames'

%% Read in data

[x,fs] = wavread([foldername 'Audio/' filename{i} '.wav']);  
curfile = [foldername 'MIDI/' filename{i} '.mid'];           % save path for the MIDI file

%% Main processing
% The main function "BassLineDetector" is called here...

% [f0 t] = BassLineDetector(x, fs);               % ...by using the default parameters...
[f0 t] = BassLineDetector(x, fs,...
    mode, hop_length, frame_length, A4, curfile); % ...or by specifying your own. 

%% Performance calculation (comment this when analysing your own files!)
fl_eval = 10; % MIDI resampling frame length [ms]
hl_eval = 5;  % MIDI resampling hop length [ms]

file_est = [foldername 'MIDI/' filename{i} '.mid']; % estimated MIDI file path
file_gt = [file_est(1:end-4) '_gt.mid'];            % ground truth MIDI file path
Q(i) = calcPerformance(file_est,file_gt,fl_eval,hl_eval,fs,'file');
plotConfusion(file_est,file_gt,fl_eval,hl_eval,fs);
        
end

%% Plot metrics (comment this when analysing your own files!)
[quality metric_label] = struct2mat(Q); % convert struct to matrix
quality_avg = mean(quality,2);          % calculate metric averages
Q_final = [quality quality_avg].';      % combine into one matrix

table = figure;
    uitable(table, 'Data', Q_final, 'ColumnName',metric_label , ...
    'RowName',[filename 'average'],'RowStriping','on','Position',[3 100 555 320],...
    'ColumnWidth',{65},'units','Normalized');
    set(gcf,'Name','Quality evaluation metrics','NumberTitle','off');

    