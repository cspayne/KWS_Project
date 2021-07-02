dataFolder = fullfile('Project1_DS');

%set up adsTest
ads = audioDatastore(fullfile(dataFolder, 'Testing'), ...
    'IncludeSubfolders',true, ...
    'FileExtensions','.wav', ...
    'LabelSource','foldernames');

commands = categorical(["up","down","one","two","three","four","five","six","seven","eight","nine"]);
isCommand = ismember(ads.Labels,commands);
isUnknown = ~isCommand;

%use commented section for less unknown audio files

%includeFraction = 0.2;
%mask = rand(numel(ads.Labels),1) < includeFraction;
%isUnknown = isUnknown & mask;
ads.Labels(isUnknown) = categorical("unknown");

adsTest = subset(ads,isCommand|isUnknown);

%set up adsTrain
ads = audioDatastore(fullfile(dataFolder, 'Training'), ...
    'IncludeSubfolders',true, ...
    'FileExtensions','.wav', ...
    'LabelSource','foldernames');

isCommand = ismember(ads.Labels,commands);
isUnknown = ~isCommand;

%includeFraction = 0.2;
%mask = rand(numel(ads.Labels),1) < includeFraction;
%isUnknown = isUnknown & mask;
ads.Labels(isUnknown) = categorical("unknown");

adsTrain = subset(ads,isCommand|isUnknown);

%set up adsValidate
ads = audioDatastore(fullfile(dataFolder, 'Validation'), ...
    'IncludeSubfolders',true, ...
    'FileExtensions','.wav', ...
    'LabelSource','foldernames');

isCommand = ismember(ads.Labels,commands);
isUnknown = ~isCommand;

%includeFraction = 0.2; 
%mask = rand(numel(ads.Labels),1) < includeFraction;
%isUnknown = isUnknown & mask;
ads.Labels(isUnknown) = categorical("unknown");

adsValidate = subset(ads,isCommand|isUnknown);

countEachLabel(adsTrain)
countEachLabel(adsValidate)
countEachLabel(adsTest)

YTrain = removecats(adsTrain.Labels);
YValidation = removecats(adsValidate.Labels);
YTest = removecats(adsTest.Labels);

figure('Units','normalized','Position',[0.2 0.2 0.5 0.5])

subplot(3,1,1)
histogram(YTrain)
title("Training Label Distribution")

subplot(3,1,2)
histogram(YValidation)
title("Validation Label Distribution")

subplot(3,1,3)
histogram(YTest)
title("Testing Label Distribution")