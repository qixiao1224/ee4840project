%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%format for 8 bit fixed point number
wordlength = 8;    %total number of bits
fractionlength = 4; %bits assigned for fraction

F8 = fimath();
F8.ProductMode = 'SpecifyPrecision';
F8.ProductWordLength = wordlength;
F8.ProductFractionLength = fractionlength;
F8.SumMode = 'SpecifyPrecision';
F8.SumWordLength = wordlength;
F8.SumFractionLength = fractionlength;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
a = [0.5,0.5,1;0.5,0.5,1;0.5,0.5,1];
a_f = fi(a,1,wordlength,fractionlength,F8);

b = [1,2;1,2];
b_f = fi(b,1,wordlength,fractionlength,F8);

c = [0.5,0.5,1;0.5,0.5,1;0.5,0.5,1];
c_f = fi(c,1,wordlength,fractionlength,F8);

d = [1,1;1,1];
d_f = fi(d,1,wordlength,fractionlength,F8);

conv_result1 = conv2d(a_f,b_f);
conv_result2 = conv2d(c_f,d_f);

stack(:,:,1) = conv_result1;
stack(:,:,2) = conv_result2;

d = maxpooling2by2(stack);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%format for 16 bit fixed point number
wordlength16 = 16;    %total number of bits
fractionlength16 = 8; %bits assigned for fraction

F16 = fimath();
F16.ProductMode = 'SpecifyPrecision';
F16.ProductWordLength = wordlength16;
F16.ProductFractionLength = fractionlength16;
F16.SumMode = 'SpecifyPrecision';
F16.SumWordLength = wordlength16;
F16.SumFractionLength = fractionlength16;
