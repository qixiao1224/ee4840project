clear all;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%operation policy for 8 bit fixed point number
F8 = fimath();
F8.ProductMode = 'SpecifyPrecision';
F8.ProductWordLength = 16;
F8.ProductFractionLength = 8;
F8.SumMode = 'SpecifyPrecision';
F8.SumWordLength = 16;
F8.SumFractionLength = 8;
F8.OverflowAction = 'Saturate';
F8.RoundingMethod = 'Nearest';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
wordlength8 = 8;            %number of bits for the entire word
fractionlength8 = 4;        %number of bits for the fraction
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%image reading
img0_f8(:,:,1) = fi(load("data/imgs/img2.txt"),1,wordlength8,fractionlength8,F8);                %digitized as f8, using F8 operation policy (same for others)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%weights and bias reading and conversion for conv2d1
%weight storage format: (width, height, depth, index)

% Iterate over the weights from 1 to 9, construct a 4D array
for i = 1:9
    weight1_temp = load("data/conv2d1_weight.mat").(sprintf('weight%d', i));
    conv2d1_weight_f8(:,:,1,i) = fi(weight1_temp,1,wordlength8,fractionlength8,F8); 
end

conv2d1_bias_f8 = fi(load("data/conv2d1_bias.mat").bias,1,wordlength8,fractionlength8,F8);  %digitized as f8

%re-organize the weight into 2D format, still stored as 4D array
for i = 1:32
    for j= 1:3
        for k = 1:3
           conv2d1_weight_2D_f8(j,k,1,i)  = conv2d1_weight_f8(1,i,1,(j-1)*3+k);
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%weights and bias reading and conversion for conv2d2
for i = 1:9
    weight2_temp = load("data/conv2d2_weight.mat").(sprintf('weight%d', i));
    conv2d2_weight_f8(:,:,1,i) = fi(weight2_temp,1,wordlength8,fractionlength8,F8); 
end

conv2d2_bias_f8 = fi(load("data/conv2d2_bias.mat").bias,1,wordlength8,fractionlength8,F8);  %digitized as f8

%re-organize the weight into 4D format
for h = 1:32
    for i = 1:32
        for j= 1:3
            for k = 1:3
               conv2d2_weight_2D_f8(j,k,i,h)  = conv2d2_weight_f8(h,i,1,(j-1)*3+k);
            end
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%weights and bias reading and conversion for conv2d3
for i = 1:9
    weight3_temp = load("data/conv2d3_weight.mat").(sprintf('weight%d', i));
    conv2d3_weight_f8(:,:,1,i) = fi(weight3_temp,1,wordlength8,fractionlength8,F8); 
end

conv2d3_bias_f8 = fi(load("data/conv2d3_bias.mat").bias,1,wordlength8,fractionlength8,F8);  %digitized as f8

%re-organize the weight into 4D format
for h = 1:32
    for i = 1:32
        for j= 1:3
            for k = 1:3
               conv2d3_weight_2D_f8(j,k,i,h)  = conv2d3_weight_f8(h,i,1,(j-1)*3+k);
            end
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%weights and bias reading and conversion for dense1
dense1_weight_f8 = fi(load("data/dense1_weight.mat").weight,1,wordlength8,fractionlength8,F8);  %digitized as f8
dense1_bias_f8 = fi(load("data/dense1_bias.mat").bias,1,wordlength8,fractionlength8,F8);  %digitized as f8
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%weights and bias reading and conversion for dense2
dense2_weight_f8 = fi(load("data/dense2_weight.mat").weight,1,wordlength8,fractionlength8,F8);  %digitized as f8
dense2_bias_f8 = fi(load("data/dense2_bias.mat").bias,1,wordlength8,fractionlength8,F8);  %digitized as f8
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%perform the convolution and max pooling process
conv2d1_result = conv2d(img0_f8, conv2d1_weight_2D_f8,conv2d1_bias_f8,F8,wordlength8,fractionlength8, 1);      %first convolution
pooling1_result = maxpooling2by2(conv2d1_result,F8,wordlength8,fractionlength8);                            %first max pooling

conv2d2_result = conv2d(pooling1_result,conv2d2_weight_2D_f8,conv2d2_bias_f8,F8,wordlength8,fractionlength8,1); %second convolution
pooling2_result = maxpooling2by2(conv2d2_result,F8,wordlength8,fractionlength8);                              %second max pooling

conv2d3_result = conv2d(pooling2_result,conv2d3_weight_2D_f8,conv2d3_bias_f8,F8,wordlength8,fractionlength8,1); %third convolution

flatten_result = flatten(conv2d3_result,F8,wordlength8,fractionlength8);                                         %flattening

dense1_result = dense(flatten_result,dense1_weight_f8,dense1_bias_f8,F8,wordlength8,fractionlength8,1);           %first fully connected layer

dense2_result = dense(dense1_result,dense2_weight_f8,dense2_bias_f8,F8,wordlength8,fractionlength8,0);           %second fully connected layer
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%quantize everything in the end for FPGA calculation
q=quantizer([wordlength8 fractionlength8]);                 %create a quantizer object to define the quantized formats
%weight_binary = num2bin(q,double(conv2d1_weight_2D_f8(:,:,1,1)'));
%conv_result_binary = num2bin(q,double(conv_result));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%save the files as txt for FPGA read
%File 1: img file (z sequence)
img_file = fopen('./output/img0_z.txt','w');

for i = 1:15
   for j = 1:15
      pixel = img0_f8(2*(i-1)+1,2*(j-1)+1);
      pixel_binary = num2bin(q,double(pixel));
      fprintf(img_file,'%s',pixel_binary(1:wordlength8));          %write top left pixel
      fprintf(img_file,'%d\n','');
      
      pixel = img0_f8(2*(i-1)+1,2*(j-1)+2);
      pixel_binary = num2bin(q,double(pixel));
      fprintf(img_file,'%s',pixel_binary(1:wordlength8));          %write top right pixel
      fprintf(img_file,'%d\n','');
      
      pixel = img0_f8(2*(i-1)+2,2*(j-1)+1);
      pixel_binary = num2bin(q,double(pixel));
      fprintf(img_file,'%s',pixel_binary(1:wordlength8));          %write bottom left pixel
      fprintf(img_file,'%d\n','');
      
      pixel = img0_f8(2*(i-1)+2,2*(j-1)+2);
      pixel_binary = num2bin(q,double(pixel));
      fprintf(img_file,'%s',pixel_binary(1:wordlength8));          %write bottom right pixel
      fprintf(img_file,'%d\n','');
   end
end

fclose(img_file);
disp("image file created successfully");

%File 2:weight and bias file for conv2d1 (1 bias+ 9 weight)*32
conv2d1_bias_binary = num2bin(q,double(conv2d1_bias_f8));
weight_file = fopen('./output/weight_bias_conv2d1.txt','w');

for i = 1:32
   fprintf(weight_file,'%s',conv2d1_bias_binary(i,1:wordlength8));          %write 1 bias 
   fprintf(weight_file,'%d\n','');
   weight_binary = num2bin(q,double(conv2d1_weight_2D_f8(:,:,1,i)'));
   for j=1:9
        fprintf(weight_file,'%s',weight_binary(j,1:wordlength8));      %write 9 weights
        fprintf(weight_file,'%d\n','');
   end
end

fclose(weight_file);
disp("weight and bias file created successfully");

%File 3: Result file for conv2d1 (z sequence)
conv2d1_result_file = fopen('./output/conv2d1_result.txt','w');

conv_result_temp = pooling1_result(:,:,1);

for i = 1:7
   for j = 1:7
      pixel = conv_result_temp(2*(i-1)+1,2*(j-1)+1);
      pixel_binary = num2bin(q,double(pixel));
      fprintf(conv2d1_result_file,'%s',pixel_binary(1:wordlength8));          %write top left pixel
      fprintf(conv2d1_result_file,'%d\n','');
      
      pixel = conv_result_temp(2*(i-1)+1,2*(j-1)+2);
      pixel_binary = num2bin(q,double(pixel));
      fprintf(conv2d1_result_file,'%s',pixel_binary(1:wordlength8));          %write top right pixel
      fprintf(conv2d1_result_file,'%d\n','');
      
      pixel = conv_result_temp(2*(i-1)+2,2*(j-1)+1);
      pixel_binary = num2bin(q,double(pixel));
      fprintf(conv2d1_result_file,'%s',pixel_binary(1:wordlength8));          %write bottom left pixel
      fprintf(conv2d1_result_file,'%d\n','');
      
      pixel = conv_result_temp(2*(i-1)+2,2*(j-1)+2);
      pixel_binary = num2bin(q,double(pixel));
      fprintf(conv2d1_result_file,'%s',pixel_binary(1:wordlength8));          %write bottom right pixel
      fprintf(conv2d1_result_file,'%d\n','');
   end
end

fclose(conv2d1_result_file);
disp("conv2d1 result file created successfully");
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
layer0_output = fi(load("verification/layer0_output.mat").output,1,wordlength8,fractionlength8,F8);
%run this for loop in debugging mode
for i = 1:32
    layer0_output_1 = reshape(layer0_output(:,:,:,:,i),[28 28]);     %first depth
    conv2d1_result_1 = conv2d1_result(:,:,i);
end

%run this for loop in debugging mode
for i = 1:32
    layer2_output = fi(load("verification/layer2_output.mat").output,1,wordlength8,fractionlength8,F8);
    layer2_output_1 = reshape(layer2_output(:,:,:,:,i),[12 12]);     %first depth
    conv2d2_result_1 = conv2d2_result(:,:,i);
end

conv2d2_pixel_1 = sum(sum(sum(pooling1_result(1:3,1:3,:) .* conv2d2_weight_2D_f8(:,:,:,1))));