function X = SpectrogramToPNG(ads,frameDuration,hopDuration,numBands)
% numFiles = length(ads.Files);
for ii = 1:10 %switch 10 to numFiles
    [y,info] = read(ads);
    fs= 16000;
    frameLength = round(frameDuration*fs);
    hopLength = round(hopDuration*fs);
    
 melSpectrogram(y,fs, 'WindowLength',frameLength,...
    'OverlapLength',frameLength-hopLength,'FFTLength',512,'NumBands',...
    numBands);

saveas(gcf, + ii + ".png");
end

