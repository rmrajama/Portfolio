function uninstallBLD()
% Uninstall remove the bass line detector packages from the MATLAB path. The 
% function is based on the GUILayout Toolbox installer by MathWorks ltd.
%
% About:
%       author      - Robin Rajamaeki 
%       last update - 25th July 2013

thisdir = fileparts( mfilename( 'fullpath' ) );

rmpath( thisdir );
rmpath( fullfile( thisdir, 'functions' ) );
rmpath( fullfile( thisdir, 'functions','evaluation') );
rmpath( fullfile( thisdir, 'functions','MIDI_toolbox' ) );
rmpath( fullfile( thisdir, 'functions','other' ) );
rmpath( fullfile( thisdir, 'functions','pitch_detection' ) );
rmpath( fullfile( thisdir, 'functions','post_processing' ) );
rmpath( fullfile( thisdir, 'functions','pre_processing' ) );

savepath();