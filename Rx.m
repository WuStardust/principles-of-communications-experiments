Fs=1e6;
RateSym=1e4;
UpSample=Fs/RateSym;
Rolloff=1;
CoderConstraint = 7;%  Ô¼Êø³¤¶È 

load 'wave.mat'
waveData=wave.data.';
received=reshape(waveData,1,[]);
figure(1)
subplot(1,2,1)
plot(real(received));
subplot(1,2,2)
plot(imag(received));

filterDef=fdesign.pulseshaping(Fs/RateSym,'Square Root Raised Cosine','Nsym,Beta',6,Rolloff);
myFilter = design(filterDef);
myFilter.Numerator=myFilter.Numerator*UpSample;
filtered = conv(myFilter.Numerator,received);

figure(2)
subplot(1,2,1)
plot(real(filtered));
subplot(1,2,2)
plot(imag(filtered));

data = [filtered(1.2e5:1.8e5), zeros(1, 100)];
data2 = [zeros(1, 100), conj(filtered(1.2e5:1.8e5))];

result = real(data .* data2);
figure(3)
plot(result)

result = real(result);
result = result(1.324e4:length(result));

bit = [];
j = 1;
for i=1:100:length(result)
    if(result(i)>20)
        bit(j) = 0;
    elseif(result(i)<-20)
        bit(j) = 1;
    end
    j = j+1;
end

bit = bit(17:443+17);
trel = poly2trellis(CoderConstraint, [171, 133]);
vitResult = vitdec(bit, trel, 2 ,'cont','hard');

numStr = num2str(vitResult.').';
numStr = numStr(3:218);

str = '';
j = 1;
for i=1:8:length(numStr-1)
    str(j) = char(bin2dec(numStr(i:i+7)));
    j = j+1;
end

disp(str)