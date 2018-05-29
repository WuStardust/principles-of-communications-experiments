%% ----------start up params----------
Fs=200000;
RateSym=10000;
UpSample=Fs/RateSym;
CoderConstraint = 7;%  约束长度 
Rolloff=1;
FreqCarrier=0; % Hz
Preamble=[1,0,1,0,1,1,0,0,1,0,1,0,1,1,0,0];
MsgLength=216;

%% ----------encode----------
bitV = String_BitVector_Conversion('B:Information Theory is interesting');
trel = poly2trellis(CoderConstraint, [171, 133]);
msgWithTail = [bitV, zeros(size(1 : CoderConstraint - 1))];% add coder_constraint-1 zeros to the end
code = convenc(msgWithTail, trel);%  generate encoding result
data=[Preamble,code]; % add preamble

%% ----------fsk coding----------
fskCode = data + 1;
t = 0:(1/(20-1)):1;
fskBits1 = [];
fskBits2 = [];
for bit=1:length(fskCode)
   fskBits1 = [fskBits1, exp(1i*2*pi*fskCode(bit)*t)];
   fskBits2 = [fskBits2, cos(2*pi*fskCode(bit)*t)];
end
figure(1)
subplot(3,2,1)
plot(real(fskBits1))
title('指数函数(实部)')
subplot(3,2,2)
plot(abs(fftshift(fft(fskBits1))))
title('指数函数(频域)')
subplot(3,2,3)
plot(abs(fskBits1))
title('指数函数(模)')
subplot(3,2,5)
plot(fskBits2)
title('三角函数')
subplot(3,2,6)
plot(abs(fftshift(fft(fskBits2))))
title('三角函数(频域)')

fskBits = [zeros(1, 500), fskBits1, zeros(1, 500)];

% fskBits = [];
% [M,N] = size(data);
% for i=1:N
%     if data(i)==0
%         for j=1:UpSample
%             k = (i-1)*UpSample+j;
%             fskBits(k) = exp(1i*2*pi*1*j/Fs);
%         end
%     else
%         for j=1:UpSample
%             k = (i-1)*UpSample+j;
%             fskBits(k) = exp(1i*2*pi*2*j/Fs);
%         end
%     end
% end

plot(real(fskBits))

%% ------------RRC and filtering------------
% filterDef=fdesign.pulseshaping(Fs/RateSym,'Square Root Raised Cosine','Nsym,Beta',6,Rolloff);
% myFilter = design(filterDef);
% myFilter.Numerator=myFilter.Numerator*UpSample;
% filtered = conv(myFilter.Numerator,fskBits);
% 
signalToSend = fskBits;
save 'signalToSend.mat' signalToSend

figure(2)
fftR = fft(signalToSend, Fs);
plot(abs(fftshift(fftR)))
%% ------------modulate to carrier-----------------
% indexSig=(0:1:length(filtered)-1)/Fs;
% carrier=exp(1i*2*pi*FreqCarrier*indexSig);
% modulated=filtered.*carrier;
% modulated=[zeros(1,100*UpSample), modulated];
% 
% signalToSend=0.3*modulated;  % scale the signal so that it's below magnitude 1

%% ------------generate bin-----------------
I=real(signalToSend);
Q=imag(signalToSend);
len=length(signalToSend);
for k=1:len
    j=2*k;
    waveData(j)=Q(k);
    waveData(j-1)=I(k);
end
 for n=2:10
     for m=((n-1)*(len*2)+1):n*(len*2)
         waveData(m)= waveData(m-(n-1)*(len*2));
     end
 end
waveData=waveData*(2^15);
waveData = round(waveData);

fid=fopen('wave_B.bin', 'w');
fwrite(fid, waveData, 'int16','b');%%%b关于字节序的问题，b这个参数表示big Endian：低地址存放最高有效字节
fclose(fid);
