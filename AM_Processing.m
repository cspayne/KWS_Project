function xAM = AM_Processing(x,fs)
    %variables
    ts = 1/fs;
    t = 0:ts:1-ts;
    
    %change last number to number of bands + 1 when changing bands
    y = logspace(2.3,3.903,13); %log-spaced frequency cutoffs between 200 and 8000 hz
    %change last number to number of bands + 1 when changing bands

    %filter design
    bpFilt1 = designfilt('bandpassfir','FilterOrder',20, ...
         'CutoffFrequency1',y(1), 'CutoffFrequency2',y(2), ...
         'SampleRate',fs);

    bpFilt2 = designfilt('bandpassfir','FilterOrder',20, ...
         'CutoffFrequency1',y(2), 'CutoffFrequency2',y(3), ...
         'SampleRate',fs);
     
    bpFilt3 = designfilt('bandpassfir','FilterOrder',20, ...
         'CutoffFrequency1',y(3), 'CutoffFrequency2',y(4), ...
         'SampleRate',fs);

    bpFilt4 = designfilt('bandpassfir','FilterOrder',20, ...
         'CutoffFrequency1',y(4), 'CutoffFrequency2',y(5), ...
         'SampleRate',fs);
     
     bpFilt5 = designfilt('bandpassfir','FilterOrder',20, ...
         'CutoffFrequency1',y(5), 'CutoffFrequency2',y(6), ...
         'SampleRate',fs);
     
     bpFilt6 = designfilt('bandpassfir','FilterOrder',20, ...
         'CutoffFrequency1',y(6), 'CutoffFrequency2',y(7), ...
         'SampleRate',fs);
     
     bpFilt7 = designfilt('bandpassfir','FilterOrder',20, ...
         'CutoffFrequency1',y(7), 'CutoffFrequency2',y(8), ...
         'SampleRate',fs);
     
     bpFilt8 = designfilt('bandpassfir','FilterOrder',20, ...
         'CutoffFrequency1',y(8), 'CutoffFrequency2',y(9), ...
         'SampleRate',fs);
     
     bpFilt9 = designfilt('bandpassfir','FilterOrder',20, ...
         'CutoffFrequency1',y(9), 'CutoffFrequency2',y(10), ...
         'SampleRate',fs);
     
     bpFilt10 = designfilt('bandpassfir','FilterOrder',20, ...
         'CutoffFrequency1',y(10), 'CutoffFrequency2',y(11), ...
         'SampleRate',fs);
     
     bpFilt11 = designfilt('bandpassfir','FilterOrder',20, ...
         'CutoffFrequency1',y(11), 'CutoffFrequency2',y(12), ...
         'SampleRate',fs);
     
     bpFilt12 = designfilt('bandpassfir','FilterOrder',20, ...
         'CutoffFrequency1',y(12), 'CutoffFrequency2',y(13), ...
         'SampleRate',fs);

    xfilter1 = filter(bpFilt1,x);
    xfilter2 = filter(bpFilt2,x);
    xfilter3 = filter(bpFilt3,x);
    xfilter4 = filter(bpFilt4,x);
    xfilter5 = filter(bpFilt5,x);
    xfilter6 = filter(bpFilt6,x);
    xfilter7 = filter(bpFilt7,x);
    xfilter8 = filter(bpFilt8,x);
    xfilter9 = filter(bpFilt9,x);
    xfilter10 = filter(bpFilt10,x);
    xfilter11 = filter(bpFilt11,x);
    xfilter12 = filter(bpFilt12,x);
    
    clear bpFilt1 bpFilt2 bpFilt3 bpFilt4 bpFilt5 bpFilt6 bpFilt7 bpFilt8 bpFilt9 bpFilt10 bpFilt11 bpFilt12; 
        
    %envelope extraction
    h1 = hilbert(xfilter1);
    env1 = abs(h1);
    h2 = hilbert(xfilter2);
    env2 = abs(h2);
    h3 = hilbert(xfilter3);
    env3 = abs(h3);
    h4 = hilbert(xfilter4);
    env4 = abs(h4);
    h5 = hilbert(xfilter5);
    env5 = abs(h5);
    h6 = hilbert(xfilter6);
    env6 = abs(h6);
    h7 = hilbert(xfilter7);
    env7 = abs(h7);
    h8 = hilbert(xfilter8);
    env8 = abs(h8);
    h9 = hilbert(xfilter9);
    env9 = abs(h9);
    h10 = hilbert(xfilter10);
    env10 = abs(h10);
    h11 = hilbert(xfilter11);
    env11 = abs(h11);
    h12 = hilbert(xfilter12);
    env12 = abs(h12);

    clear xfilter1 xfilter2 xfilter3 xfilter4 xfilter5 xfilter6 xfilter7 xfilter8 xfilter9 xfilter10 xfilter11 xfilter12;
    clear h1 h2 h3 h4 h5 h6 h7 h8 h9 h10 h11 h12;
    
    %modulation and synthesis of signals
    f1 = sqrt(y(2)*y(1)); %geometric mean to find center frequency
    signal1 = cos(2*pi*f1*t);
    signal1 = signal1'; 
    add1 = env1.*signal1;
    clear f1 signal1; 
    
    f2 = sqrt(y(3)*y(2)); 
    signal2 = cos(2*pi*f2*t);
    signal2 = signal2';
    add2 = env2.*signal2;
    clear f2 signal2; 

    f3 = sqrt(y(4)*y(3)); 
    signal3 = cos(2*pi*f3*t);
    signal3 = signal3';
    add3 = env3.*signal3;
    clear f3 signal3; 
    
    f4 = sqrt(y(5)*y(4)); 
    signal4 = cos(2*pi*f4*t);
    signal4 = signal4';
    add4 = env4.*signal4;
    clear f4 signal4; 
    
    f5 = sqrt(y(6)*y(5)); 
    signal5 = cos(2*pi*f5*t);
    signal5 = signal5';
    add5 = env5.*signal5;
    clear f5 signal5; 
    
    f6 = sqrt(y(7)*y(6)); 
    signal6 = cos(2*pi*f6*t);
    signal6 = signal6';
    add6 = env6.*signal6;
    clear f6 signal6; 
    
    f7 = sqrt(y(8)*y(7)); 
    signal7 = cos(2*pi*f7*t);
    signal7 = signal7';
    add7 = env7.*signal7;
    clear f7 signal7; 
    
    f8 = sqrt(y(9)*y(8)); 
    signal8 = cos(2*pi*f8*t);
    signal8 = signal8';
    add8 = env8.*signal8;
    clear f8 signal8; 
    
    f9 = sqrt(y(10)*y(9)); 
    signal9 = cos(2*pi*f9*t);
    signal9 = signal9';
    add9 = env9.*signal9;
    clear f9 signal9; 
    
    f10 = sqrt(y(11)*y(10)); 
    signal10 = cos(2*pi*f10*t);
    signal10 = signal10';
    add10 = env10.*signal10;
    clear f10 signal10; 
    
    f11 = sqrt(y(12)*y(11)); 
    signal11 = cos(2*pi*f11*t);
    signal11 = signal11';
    add11 = env11.*signal11;
    clear f11 signal11; 
    
    f12 = sqrt(y(13)*y(12)); 
    signal12 = cos(2*pi*f12*t);
    signal12 = signal12';
    add12 = env12.*signal12;
    clear f12 signal12; 
    
    %{
    xAM = zeros(fs,12);
    xAM(:,1) = add1; 
    xAM(:,2) = add2;
    xAM(:,3) = add3;
    xAM(:,4) = add4;
    xAM(:,5) = add5;
    xAM(:,6) = add6;
    xAM(:,7) = add7;
    xAM(:,8) = add8;
    xAM(:,9) = add9;
    xAM(:,10) = add10;
    xAM(:,11) = add11;
    xAM(:,12) = add12;
    %}
    xAM = add1 + add2 + add3 + add4 + add5 + add6 + add7 + add8 + add9 + add10 + add11 + add12; 
end