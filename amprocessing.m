%colors for visualizations
c1 = [1 .57 .91];
c2 = [1 .28 .84];
c3 = [.78 0 .78];
c4 = [.58 .01 .58];

%set up ads
dataFolder = fullfile('Mini_DS');
ads = audioDatastore(fullfile(dataFolder), ...
    'IncludeSubfolders',true, ...
    'FileExtensions','.wav', ...
    'LabelSource','foldernames');

commands = categorical(["up","down"]);
isCommand = ismember(ads.Labels,commands);
isUnknown = ~isCommand;

ads.Labels(isUnknown) = categorical("unknown");

ads = subset(ads,isCommand|isUnknown);

%variables
fs = 16e3; % Known sample rate of the data set.
ts = 1/fs;
t = 0:ts:1-ts;
y = logspace(2.3,3.903,5); %log-spaced frequency cutoffs between 200 and 8000 hz

x = read(ads);
%sound(x, fs); %play audio file

%filter design
bpFilt1 = designfilt('bandpassfir','FilterOrder',20, ...
         'CutoffFrequency1',y(1), 'CutoffFrequency2',y(2), ...
         'SampleRate',fs);
%fvtool(bpFilt1);
bpFilt2 = designfilt('bandpassfir','FilterOrder',20, ...
         'CutoffFrequency1',y(2), 'CutoffFrequency2',y(3), ...
         'SampleRate',fs);
%fvtool(bpFilt2);
bpFilt3 = designfilt('bandpassfir','FilterOrder',20, ...
         'CutoffFrequency1',y(3), 'CutoffFrequency2',y(4), ...
         'SampleRate',fs);
%fvtool(bpFilt3);
bpFilt4 = designfilt('bandpassfir','FilterOrder',20, ...
         'CutoffFrequency1',y(4), 'CutoffFrequency2',y(5), ...
         'SampleRate',fs);
%fvtool(bpFilt4);

xfilter1 = filter(bpFilt1,x);
xfilter2 = filter(bpFilt2,x);
xfilter3 = filter(bpFilt3,x);
xfilter4 = filter(bpFilt4,x);

%plot filtered bands
%{
figure
subplot(4,1,1)
plot(t, xfilter1, 'color', c1)
axis tight
ylim([-1.5,1.5])
title('199.5 - 502.1 hz')
subplot(4,1,2)
plot(t, xfilter2, 'color', c2)
axis tight
ylim([-1.5,1.5])
title('502.1 - 1263.3 hz')
subplot(4,1,3)
plot(t, xfilter3, 'color', c3)
axis tight
ylim([-1.5,1.5])
title('1263.3 - 3178.7 hz')
subplot(4,1,4)
plot(t, xfilter4, 'color', c4)
axis tight
ylim([-1.5,1.5])
title('3178.7 - 7998.3 hz')
sgtitle('Contiguous Bands of Audio Signal')
%}
clear bpFilt1 bpFilt2 bpFilt3 bpFilt4;

%envelope extraction
h1 = hilbert(xfilter1);
env1 = abs(h1);
h2 = hilbert(xfilter2);
env2 = abs(h2);
h3 = hilbert(xfilter3);
env3 = abs(h3);
h4 = hilbert(xfilter4);
env4 = abs(h4);

%plot envelopes
%{
figure
plot(t,xfilter1, 'color', c1)
hold on
plot(t,env1, 'k')
hold off
xlim([0 0.04])
title('Hilbert Envelope of Band 1')

figure
plot(t,xfilter2, 'color', c2)
hold on
plot(t,env2, 'k')
hold off
xlim([0 0.04])
title('Hilbert Envelope of Band 2')

figure
plot(t,xfilter3, 'color', c3)
hold on
plot(t,env3, 'k')
hold off
xlim([0 0.04])
title('Hilbert Envelope of Band 3')

figure
plot(t,xfilter4, 'color', c4)
hold on
plot(t,env4, 'k')
hold off
xlim([0 0.04])
title('Hilbert Envelope of Band 4')
%}
clear xfilter1 xfilter2 xfilter3 xfilter4;
clear h1 h2 h3 h4; 


%modulation and synthesis of signals
f1 = sqrt(y(2)*y(1)); %geometric mean to find center frequency
signal1 = cos(2*pi*f1*t);
signal1 = signal1'; 
add1 = env1.*signal1;

f2 = sqrt(y(3)*y(2)); 
signal2 = cos(2*pi*f1*t);
signal2 = signal2';
add2 = env2.*signal2;

f3 = sqrt(y(4)*y(3)); 
signal3 = cos(2*pi*f1*t);
signal3 = signal3';
add3 = env3.*signal3;

f4 = sqrt(y(5)*y(4)); 
signal4 = cos(2*pi*f1*t);
signal4 = signal4';
add4 = env4.*signal4;

finalsignal = add1 + add2 + add3 + add4; 
clear add1 add2 add3 add4; 

%plot final signal
figure
plot(t,finalsignal, 'color', c4)
title('Signal Synthesis')

figure
melSpectrogram(finalsignal, fs)