dataFolder = fullfile('Project1_DS');
%create training datastore
ads = audioDatastore(fullfile(dataFolder, 'Training'), ...
    'IncludeSubfolders',true, ...
    'FileExtensions','.wav', ...
    'LabelSource','foldernames');

commands = categorical(["up","down","one","two","three","four","five","six","seven","eight","nine"]); 
isCommand = ismember(ads.Labels,commands);
isUnknown = ~isCommand;

%includeFraction = 0.2;
%mask = rand(numel(ads.Labels),1) < includeFraction;
%isUnknown = isUnknown & mask;
ads.Labels(isUnknown) = categorical("unknown");
adsTrain = subset(ads,isCommand|isUnknown);

%create validation datastore
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
xAM = AM_Processing(xPadded, fs); 
%features = extract(afe,xAM);
%[numHops,numFeatures] = size(features);
numTrain = length(adsTrain.Files);
xTrain = zeros(4e3,12,1,numTrain);
reset(adsTrain); 
for i = 1:numTrain
    fprintf('Training Dataset: %d out of %d \n',i,numTrain)
    x = read(adsTrain); 
    xPadded = [zeros(floor((segmentSamples-size(x,1))/2),1);x;zeros(ceil((segmentSamples-size(x,1))/2),1)];
    xAM = AM_Processing(xPadded,fs); 
    xTrain(:,:,1,i) = xAM; 
end
%epsil = 1e-6;
%xTrain = log10(xTrain + epsil);
numValidation = length(adsValidation.Files);
xValidation = zeros(4e3,12,1,numValidation);
for ii = 1:numValidation
    fprintf('Validation Dataset: %d out of %d \n',ii,numValidation)
    x = read(adsValidation); 
    xPadded = [zeros(floor((segmentSamples-size(x,1))/2),1);x;zeros(ceil((segmentSamples-size(x,1))/2),1)];
    xAM = AM_Processing(xPadded,fs); 
    xValidation(:,:,1,ii) = xAM; 
end

%xValidation = log10(xValidation + epsil);
yTrain = removecats(adsTrain.Labels);
yValidation = removecats(adsValidation.Labels);

%CNN setup


classWeights = 1./countcats(yTrain);
classWeights = classWeights'/mean(classWeights);
numClasses = numel(categories(yTrain));
classes = (categories(yTrain));
layers = [
    imageInputLayer([4e3 12])
    convolution2dLayer([3 3],32,"Name","conv_1","Padding","same")
    batchNormalizationLayer
    reluLayer
    maxPooling2dLayer([5 5],"Name","maxpool_1","Padding","same")
    convolution2dLayer([3 3],32,"Name","conv_2","Padding","same")
    batchNormalizationLayer
    reluLayer("Name","relu_2")
    maxPooling2dLayer([5 5],"Name","maxpool_2","Padding","same")
    convolution2dLayer([3 3],32,"Name","conv_3","Padding","same")
    batchNormalizationLayer
    reluLayer("Name","relu_3")
    dropoutLayer
    fullyConnectedLayer(numClasses)
    softmaxLayer
    classificationLayer('Classes',classes,'ClassWeights',classWeights)];

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
    'ValidationData',{xValidation,yValidation}, ...
    'ValidationFrequency',validationFrequency, ...
    'LearnRateSchedule','piecewise', ...
    'LearnRateDropFactor',0.1, ...
    'LearnRateDropPeriod',20);

trainedNet = trainNetwork(xTrain,yTrain,layers,options);
save trainedNet


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