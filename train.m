dataFolder = fullfile('Project1_DS');
%create training datastore
ads = audioDatastore(fullfile(dataFolder, 'Training'), ...
    'IncludeSubfolders',true, ...
    'FileExtensions','.wav', ...
    'LabelSource','foldernames');

commands = categorical(["up","down","one","two","three","four","five","six","seven","eight","nine"]); 
isCommand = ismember(ads.Labels,commands);
isUnknown = ~isCommand;

includeFraction = 0.2;
mask = rand(numel(ads.Labels),1) < includeFraction;
isUnknown = isUnknown & mask;
ads.Labels(isUnknown) = categorical("unknown");
adsTrain = subset(ads,isCommand|isUnknown);

%create validation datastore
ads = audioDatastore(fullfile(dataFolder, 'Validation'), ...
    'IncludeSubfolders',true, ...
    'FileExtensions','.wav', ...
    'LabelSource','foldernames');

isCommand = ismember(ads.Labels,commands);
isUnknown = ~isCommand;

includeFraction = 0.2;
mask = rand(numel(ads.Labels),1) < includeFraction;
isUnknown = isUnknown & mask;
ads.Labels(isUnknown) = categorical("unknown");

adsValidation = subset(ads,isCommand|isUnknown);

%reduce dataset?
reduceDataset = true;
if reduceDataset
    numUniqueLabels = numel(unique(adsTrain.Labels));
    % Reduce the dataset by a factor of 20
    adsTrain = splitEachLabel(adsTrain,round(numel(adsTrain.Files) / numUniqueLabels / 20));
    adsValidation = splitEachLabel(adsValidation,round(numel(adsValidation.Files) / numUniqueLabels / 20));
end

%Compute spectrograms
fs = 16e3; % Known sample rate of the data set.

segmentDuration = 1;
frameDuration = 0.025;
hopDuration = 0.010;

segmentSamples = round(segmentDuration*fs);
frameSamples = round(frameDuration*fs);
hopSamples = round(hopDuration*fs);
overlapSamples = frameSamples - hopSamples;

FFTLength = 512;
numBands = 50;

afe = audioFeatureExtractor( ...
    'SampleRate',fs, ...
    'FFTLength',FFTLength, ...
    'Window',hann(frameSamples,'periodic'), ...
    'OverlapLength',overlapSamples, ...
    'melSpectrum',true);
setExtractorParams(afe,'melSpectrum','NumBands',numBands,'WindowNormalization',false);

%read files
x = read(adsTrain);
numSamples = size(x,1);
numToPadFront = floor( (segmentSamples - numSamples)/2 );
numToPadBack = ceil( (segmentSamples - numSamples)/2 );

xPadded = [zeros(numToPadFront,1,'like',x);x;zeros(numToPadBack,1,'like',x)];
features = extract(afe,xPadded);
[numHops,numFeatures] = size(features);

numTrain = length(adsTrain.Files);
xTrain = zeros(numHops,numBands,1,numTrain);
reset(adsTrain); 
for i = 1:numTrain
    x = read(adsTrain); 
    xPadded = [zeros(floor((segmentSamples-size(x,1))/2),1);x;zeros(ceil((segmentSamples-size(x,1))/2),1)];
    xTrain(:,:,:,i) = extract(afe,xPadded); 
end

numValidation = length(adsValidation.Files);
for ii = 1:numValidation
    x = read(adsValidation); 
    xPadded = [zeros(floor((segmentSamples-size(x,1))/2),1);x;zeros(ceil((segmentSamples-size(x,1))/2),1)];
    xValidation(:,:,:,ii) = extract(afe,xPadded); 
end

yTrain = removecats(adsTrain.Labels);
yValidation = removecats(adsValidation.Labels);

%CNN setup
numClasses = numel(categories(yTrain));

layers = [
    imageInputLayer([numHops numBands])
    
    convolution2dLayer([3 3],32,"Name","conv_1","Padding","same")
    reluLayer
    maxPooling2dLayer([5 5],"Name","maxpool_1","Padding","same")
    convolution2dLayer([3 3],32,"Name","conv_2","Padding","same")
    reluLayer("Name","relu_2")
    maxPooling2dLayer([5 5],"Name","maxpool_2","Padding","same")
    convolution2dLayer([3 3],32,"Name","conv_3","Padding","same")
    reluLayer("Name","relu_3")
    fullyConnectedLayer(numClasses)
    softmaxLayer
    classificationLayer];

%Train 
miniBatchSize = 128;
validationFrequency = floor(numel(yTrain)/miniBatchSize);
options = trainingOptions('adam', ...
    'InitialLearnRate',3e-4, ...
    'MaxEpochs',25, ...
    'MiniBatchSize',miniBatchSize, ...
    'Shuffle','every-epoch', ...
    'Plots','training-progress', ...
    'Verbose',false, ...
    'LearnRateSchedule','piecewise', ...
    'LearnRateDropFactor',0.1, ...
    'LearnRateDropPeriod',20);

trainedNet = trainNetwork(xTrain,yTrain,layers,options);

%Evaluate Data
yValPred = classify(trainedNet,xValidation);
validationError = mean(yValPred ~= yValidation);
yTrainPred = classify(trainedNet,xTrain);
trainError = mean(yTrainPred ~= yTrain);
disp("Training error: " + trainError*100 + "%")
disp("Validation error: " + validationError*100 + "%")

figure('Units','normalized','Position',[0.2 0.2 0.5 0.5]);
cm = confusionchart(yValidation,yValPred);
cm.Title = 'Confusion Matrix for Validation Data';
cm.ColumnSummary = 'column-normalized';
cm.RowSummary = 'row-normalized';
sortClasses(cm, [commands,"unknown"])

figure('Units','normalized','Position',[0.2 0.2 0.5 0.5]);
cm = confusionchart(yTrain,yTrainPred);
cm.Title = 'Confusion Matrix for Training Data';
cm.ColumnSummary = 'column-normalized';
cm.RowSummary = 'row-normalized';
sortClasses(cm, [commands,"unknown"])

figure('Units','normalized','Position',[0.2 0.2 0.5 0.5]);
cm = confusionchart(yValidation,yValPred);
cm.Title = 'Confusion Matrix for Validation Data';
cm.ColumnSummary = 'column-normalized';
cm.RowSummary = 'row-normalized';
sortClasses(cm, [commands,"unknown"])

