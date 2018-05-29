function StrInBit = String_BitVector_Conversion(StrInput)
% Input: StrInput; Output: StrInBit

% StrInput = 'This message is for test only';

StrInAscii = abs(StrInput);   %�����ַ�����ASCII��

StrInBit1 = dec2bin(StrInAscii,8);
StrInBit2 = StrInBit1.';
StrInBit3 = StrInBit2(:);   
StrInBit = str2num(StrInBit3(:)).';  %�����ַ�����bit��

end
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Input: StrInBit; Output: StrOutput
% BitInLen = length(StrInBit)/8;
% StrInBit4 = num2str(StrInBit.').';
% 
% BitInAscii = zeros(1,BitInLen);
% for loop = 1:BitInLen
%     OneChar = StrInBit4(8*loop-7:8*loop);
%     BitInAscii(loop) = bin2dec(OneChar);    
% end                             %���������ת��ΪASCII��
% 
% % BitInAscii = int16(BitInAscii);
% 
% StrOutput = char(BitInAscii);  %���������ת��Ϊ�ַ���
% disp(StrOutput);   %��ӡ�ַ���