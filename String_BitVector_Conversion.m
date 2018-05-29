function StrInBit = String_BitVector_Conversion(StrInput)
% Input: StrInput; Output: StrInBit

% StrInput = 'This message is for test only';

StrInAscii = abs(StrInput);   %输入字符串的ASCII码

StrInBit1 = dec2bin(StrInAscii,8);
StrInBit2 = StrInBit1.';
StrInBit3 = StrInBit2(:);   
StrInBit = str2num(StrInBit3(:)).';  %输入字符串的bit流

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
% end                             %输入比特流转化为ASCII码
% 
% % BitInAscii = int16(BitInAscii);
% 
% StrOutput = char(BitInAscii);  %输入比特流转化为字符串
% disp(StrOutput);   %打印字符串