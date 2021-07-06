function Y = speechSpectrograms(ads,segmentDuration,frameDuration,hopDuration,numBands)
disp("Computing speech spectrograms..");

numHops = ceil(segmentDuration - frameDuration)/hopDuration;
numFiles = length(ads.Files);
Y = zeros([numBands,numHops,1,numFiles],'single');

for ii = 1:numFiles
    [y,info] = read(ads);
    fs= 16000;
    frameLength = round(frameDuration*fs);
    hopLength = round(hopDuration*fs);
    
    spectro = melSpectrogram(y,fs, 'WindowLength',frameLength,...
    'OverlapLength',frameLength-hopLength,'FFTLength',512,'NumBands',...
    numBands, 'FrequencyRange',[50 7000]);

saveas(gcf,+ ii + ".png");


width = size(spectro,2);
L = floor((numHops-width)/2) + 1;
index = L:L+width-1;
Y(:,index,1,ii) = spectro;

if mod(ii,1000) == 0
    disp(" Processed " + ii + " files out of " + numFiles)
end

end

