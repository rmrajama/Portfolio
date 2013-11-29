function installBLD()
% Install the bass line detector packages from the MATLAB path. The 
% function is based on the GUILayout Toolbox installer by MathWorks ltd.
%
% About:
%       author      - Robin Rajamaeki 
%       last update - 25th July 2013

% Add the folders to the path
thisdir = fileparts( mfilename( 'fullpath' ) );

dirs = {
    thisdir
    fullfile( thisdir, 'functions' )
    fullfile( thisdir, 'functions','evaluation')
    fullfile( thisdir, 'functions','MIDI_toolbox' )
    fullfile( thisdir, 'functions','other' )
    fullfile( thisdir, 'functions','pitch_detection' )
    fullfile( thisdir, 'functions','post_processing' )
    fullfile( thisdir, 'functions','pre_processing' )
    };

for dd=1:numel( dirs )
    addpath( dirs{dd} );
    fprintf( '+ Folder added to path: %s\n', dirs{dd} );
end

% Save the changes to make the installation permanent
if savepath()==0
    % Success
    fprintf( '+ Path saved\n' );
else
    % Failure
    fprintf( '- Failed to save path, you will need to re-install when MATLAB is restarted\n' );
end
