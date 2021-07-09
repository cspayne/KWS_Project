clc;
clear;


ads = audioDatastore(fullfile('Project1_DS', 'Validation','one'),...
'FileExtensions','.wav', ...
    'LabelSource','foldernames');


segmentDuration = 1;
frameDuration = 0.025;
hopDuration = 0.010;
numBands = 40;


X = speechSpectrograms(ads,frameDuration,hopDuration,numBands);
