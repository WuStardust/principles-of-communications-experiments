Fs=200000;
RateSym=10000;
UpSample=Fs/RateSym;
CoderConstraint = 7;%  约束长度 
Rolloff=1;
FreqCarrier=0; % Hz
Preamble=[1,0,1,0,1,1,0,0,1,0,1,0,1,1,0,0];
MsgLength=216;
PilotCarrerFreq=RateSym*2;
PilorCarrerPeriod=Fs/PilotCarrerFreq;

msg = StrInBit;%  the hidden message
% msg = randint(1, MsgLength, 2, 123);%  长度为MsgLength的随机消息序列 

%----------调用matlab库函数生成(2,1,7)卷积码编码结果----------
trel = poly2trellis(CoderConstraint, [171, 133]);
msgWithTail = [msg, zeros(size(1 : CoderConstraint - 1))];%  结尾处理, 在消息的结尾添加 coder_constraint-1 个零
code = convenc(msgWithTail, trel);%  调用库函数所生成卷积码

%----------add preamble-------------
data=[Preamble,code];

%----------dpsk coding----------
dpskBits=zeros(1,length(data)+1);
for iBit=1:length(data)
    dpskBits(iBit+1)=xor(dpskBits(iBit),data(iBit));
end

%----------mapping 0 to +1; 1 to -1
dpskBits=1-2*dpskBits;

%----------upsampling ----------
dpskBitsUp=zeros(1,length(dpskBits)*UpSample);
for iBits=1:length(dpskBits)
    dpskBitsUp(UpSample*iBits)=dpskBits(iBits);
end

%------------RRC and filtering
filterDef=fdesign.pulseshaping(Fs/RateSym,'Square Root Raised Cosine','Nsym,Beta',6,Rolloff);
myFilter = design(filterDef);
myFilter.Numerator=myFilter.Numerator*UpSample;
filtered = conv(myFilter.Numerator,dpskBitsUp);

%------------modulate to carrier-----------------
indexSig=(0:1:length(filtered)-1)/Fs;
carrier=exp(1i*2*pi*FreqCarrier*indexSig);
modulated=filtered.*carrier;
modulated=[zeros(1,100*UpSample), modulated];

%------------pilot carrier-----------------
lengthNew=floor(length(modulated)/PilorCarrerPeriod)*PilorCarrerPeriod;
lengthToCut=length(modulated)-lengthNew;  % cut the signal so that it have integer number of period for the pilot carrier
if lengthToCut>0
    modulatedCut=modulated(1,lengthToCut+1:length(modulated));
else
    modulatedCut=modulated;
end
iSample=0:1:length(modulatedCut)-1;
pilotCarrier=exp(1i*2*pi*iSample/PilorCarrerPeriod);


%-----------add up the modulated and pilot carrier----------------
signalAddup=modulatedCut+pilotCarrier;
signalAddup=0.3*signalAddup;  % scale the signal so that it's below magnitude 1

% --------------产生二进制文件------------
I=real(signalAddup);
Q=imag(signalAddup);
len=length(signalAddup);
for k=1:len;
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

fid=fopen('wave.bin', 'w');
fwrite(fid, waveData, 'int16','b');%%%b关于字节序的问题，b这个参数表示big Endian：低地址存放最高有效字节
fclose(fid);


