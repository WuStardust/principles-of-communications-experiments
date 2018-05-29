clear

Fs=1e6;
RateSym=1e4;
f1 = RateSym;
f2 = 2*f1;
UpSample=Fs/RateSym;
Rolloff=1;
CoderConstraint = 7;%  约束长度 

load('wave_fsk.mat')
waveData=wave.data.';
received=reshape(waveData,1,[]);

figure(1)
subplot(1,2,1)
plot(real(received));
subplot(1,2,2)
plot(imag(received));

% 10kHz带通滤波
hd = design(fdesign.bandpass('N,F3dB1,F3dB2',2,f1/2,(f2-f1)/2+f1,Fs),'butter');
received2_10 = filter(hd,received);

% 20kHz带通滤波
hd2 = design(fdesign.bandpass('N,F3dB1,F3dB2',2,(f2-f1)/2+f1,(f2-f1)/2+f2,Fs),'butter');
received2_20 = filter(hd2,received);

% 包络检波
received3_10 = hilbert(real(received2_10));
received3_20 = hilbert(real(received2_20));
received3 = abs(received3_10) - abs(received3_20);
figure(2)
plot(received3)
received3 = received3(9.683e5:1.223e6);
figure(3)
plot(received3)

DownSample=Fs/RateSym;
received4=zeros(1,round(length(received3)/DownSample));
for k=1:length(received3)/DownSample-1
    if received3(k*DownSample) >=0
        received4(k)=0;
    else
        received4(k)=1;
    end
end

figure(4)
plot(received4);

bit = received4(19:600);

trel = poly2trellis(CoderConstraint, [171, 133]);
vitResult = vitdec(bit, trel, 2 ,'cont','hard');

numStr = num2str(vitResult.').';
numStr = numStr(3:290);

str = '';
j = 1;
for i=1:8:length(numStr-1)
    str(j) = char(bin2dec(numStr(i:i+7)));
    j = j+1;
end

disp(str)