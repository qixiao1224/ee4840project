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
img_start = 0;
img_end = 0;
image_recognition_result = zeros(img_end+1,1);        %array used to store the final recognition result
image_recognition_result(:,1) = 404;                  %error code, meaning this index is not processed

for img_index = img_start:img_end
imagefile = strcat("data/imgs/img",string(img_index),".txt");
img_f8(:,:,1) = fi(load(imagefile),1,wordlength8,fractionlength8,F8);                %digitized as f8, using F8 operation policy (same for others)
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
               %conv2d2_weight_2D_f8(j,k,i,h)  = conv2d2_weight_f8(h,i,1,(j-1)*3+k);
               conv2d2_weight_2D_f8(j,k,i,h)  = conv2d2_weight_f8(i,h,1,(j-1)*3+k);
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
               %conv2d3_weight_2D_f8(j,k,i,h)  = conv2d3_weight_f8(h,i,1,(j-1)*3+k);
               conv2d3_weight_2D_f8(j,k,i,h)  = conv2d3_weight_f8(i,h,1,(j-1)*3+k);
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%perform the convolution and max pooling process
conv2d1_result = conv2d(img_f8, conv2d1_weight_2D_f8,conv2d1_bias_f8,F8,wordlength8,fractionlength8, 1);      %first convolution
pooling1_result = maxpooling2by2(conv2d1_result,F8,wordlength8,fractionlength8);                            %first max pooling

conv2d2_result = conv2d(pooling1_result,conv2d2_weight_2D_f8,conv2d2_bias_f8,F8,wordlength8,fractionlength8,1); %second convolution
pooling2_result = maxpooling2by2(conv2d2_result,F8,wordlength8,fractionlength8);                              %second max pooling

conv2d3_result = conv2d(pooling2_result,conv2d3_weight_2D_f8,conv2d3_bias_f8,F8,wordlength8,fractionlength8,1); %third convolution

flatten_result = flatten(conv2d3_result,F8,wordlength8,fractionlength8);                                         %flattening

dense1_result = dense(flatten_result,dense1_weight_f8,dense1_bias_f8,F8,wordlength8,fractionlength8,1);           %first fully connected layer

dense2_result = dense(dense1_result,dense2_weight_f8,dense2_bias_f8,F8,wordlength8,fractionlength8,0);           %second fully connected layer

max_index = find(dense2_result == max(dense2_result),1,'first'); %find the index of the maximum value for the first occurance
image_recognition_result(img_index+1,1) = max_index-1;                   %-1 to match with the index from tensorflow that starts from 0

end
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
      pixel = img_f8(2*(i-1)+1,2*(j-1)+1);
      pixel_binary = num2bin(q,double(pixel));
      fprintf(img_file,'%s',pixel_binary(1:wordlength8));          %write top left pixel
      fprintf(img_file,'%d\n','');
      
      pixel = img_f8(2*(i-1)+1,2*(j-1)+2);
      pixel_binary = num2bin(q,double(pixel));
      fprintf(img_file,'%s',pixel_binary(1:wordlength8));          %write top right pixel
      fprintf(img_file,'%d\n','');
      
      pixel = img_f8(2*(i-1)+2,2*(j-1)+1);
      pixel_binary = num2bin(q,double(pixel));
      fprintf(img_file,'%s',pixel_binary(1:wordlength8));          %write bottom left pixel
      fprintf(img_file,'%d\n','');
      
      pixel = img_f8(2*(i-1)+2,2*(j-1)+2);
      pixel_binary = num2bin(q,double(pixel));
      fprintf(img_file,'%s',pixel_binary(1:wordlength8));          %write bottom right pixel
      fprintf(img_file,'%d\n','');
   end
end

fclose(img_file);
disp("image file created successfully");
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
disp("weight and bias file for conv2d1 created successfully");
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%File 3: Result file for pooling1 (z sequence)
pooling_result_file = fopen('./output/pooling1_result_z.txt','w');

for k = 1:32
    conv_result_temp = pooling1_result(:,:,k);

    for i = 1:7
       for j = 1:7
          pixel = conv_result_temp(2*(i-1)+1,2*(j-1)+1);
          pixel_binary = num2bin(q,double(pixel));
          fprintf(pooling_result_file,'%s',pixel_binary(1:wordlength8));          %write top left pixel
          fprintf(pooling_result_file,'%d\n','');

          pixel = conv_result_temp(2*(i-1)+1,2*(j-1)+2);
          pixel_binary = num2bin(q,double(pixel));
          fprintf(pooling_result_file,'%s',pixel_binary(1:wordlength8));          %write top right pixel
          fprintf(pooling_result_file,'%d\n','');

          pixel = conv_result_temp(2*(i-1)+2,2*(j-1)+1);
          pixel_binary = num2bin(q,double(pixel));
          fprintf(pooling_result_file,'%s',pixel_binary(1:wordlength8));          %write bottom left pixel
          fprintf(pooling_result_file,'%d\n','');

          pixel = conv_result_temp(2*(i-1)+2,2*(j-1)+2);
          pixel_binary = num2bin(q,double(pixel));
          fprintf(pooling_result_file,'%s',pixel_binary(1:wordlength8));          %write bottom right pixel
          fprintf(pooling_result_file,'%d\n','');
       end
    end
end
fclose(pooling_result_file);
disp("pooling1 result file created successfully");
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%File 4:weight and bias file for conv2d2 (1 bias+ 3*3*32 weight)*32
conv2d2_bias_binary = num2bin(q,double(conv2d2_bias_f8));
weight_file = fopen('./output/weight_bias_conv2d2.txt','w');

for i = 1:32                                                                %get one filter
   fprintf(weight_file,'%s',conv2d2_bias_binary(i,1:wordlength8));          %write 1 bias 
   fprintf(weight_file,'%d\n','');
   for k = 1:32                                                             %get one depth
       weight_binary = num2bin(q,double(conv2d2_weight_2D_f8(:,:,k,i)'));   %get one depth (3*3) for one filter
       for j=1:9
            fprintf(weight_file,'%s',weight_binary(j,1:wordlength8));      %write 9 weights
            fprintf(weight_file,'%d\n','');
       end
   end
end

fclose(weight_file);
disp("weight and bias file for conv2d2 created successfully");
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%File 5: Result file for pooling2 (z sequence)
pooling_result_file = fopen('./output/pooling2_result_z.txt','w');

for k = 1:32
    conv_result_temp = pooling2_result(:,:,k);

    for i = 1:3
       for j = 1:3
          pixel = conv_result_temp(2*(i-1)+1,2*(j-1)+1);
          pixel_binary = num2bin(q,double(pixel));
          fprintf(pooling_result_file,'%s',pixel_binary(1:wordlength8));          %write top left pixel
          fprintf(pooling_result_file,'%d\n','');

          pixel = conv_result_temp(2*(i-1)+1,2*(j-1)+2);
          pixel_binary = num2bin(q,double(pixel));
          fprintf(pooling_result_file,'%s',pixel_binary(1:wordlength8));          %write top right pixel
          fprintf(pooling_result_file,'%d\n','');

          pixel = conv_result_temp(2*(i-1)+2,2*(j-1)+1);
          pixel_binary = num2bin(q,double(pixel));
          fprintf(pooling_result_file,'%s',pixel_binary(1:wordlength8));          %write bottom left pixel
          fprintf(pooling_result_file,'%d\n','');

          pixel = conv_result_temp(2*(i-1)+2,2*(j-1)+2);
          pixel_binary = num2bin(q,double(pixel));
          fprintf(pooling_result_file,'%s',pixel_binary(1:wordlength8));          %write bottom right pixel
          fprintf(pooling_result_file,'%d\n','');
       end
    end
end
fclose(pooling_result_file);
disp("pooling2 result file created successfully");
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%File 6:weight and bias file for conv2d3 (1 bias+ 3*3*32 weight)*32
conv2d3_bias_binary = num2bin(q,double(conv2d3_bias_f8));
weight_file = fopen('./output/weight_bias_conv2d3.txt','w');

for i = 1:32                                                                %get one filter
   fprintf(weight_file,'%s',conv2d3_bias_binary(i,1:wordlength8));          %write 1 bias 
   fprintf(weight_file,'%d\n','');
   for k = 1:32                                                             %get one depth
       weight_binary = num2bin(q,double(conv2d3_weight_2D_f8(:,:,k,i)'));   %get one depth (3*3) for one filter
       for j=1:9
            fprintf(weight_file,'%s',weight_binary(j,1:wordlength8));      %write 9 weights
            fprintf(weight_file,'%d\n','');
       end
   end
end

fclose(weight_file);
disp("weight and bias file for conv2d3 created successfully");
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%File 7: Result file for conv2d3 (normal sequence)
pooling_result_file = fopen('./output/conv2d3_flatten_result.txt','w');

for k = 1:32
    conv_result_temp = conv2d3_result(:,:,k);
    for i = 1:4
       for j = 1:4
          pixel = conv_result_temp(i,j);
          pixel_binary = num2bin(q,double(pixel));
          fprintf(pooling_result_file,'%s',pixel_binary(1:wordlength8));
          fprintf(pooling_result_file,'%d\n','');
       end
    end
end
fclose(pooling_result_file);
disp("conv2d3/flattened result file created successfully");
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%File 8:weight and bias file for dense1 (1 bias+ 512 weight)*32
%Format of dense1_weight_f8: each column (512) for a neuron, in each column
%each 32 values correspond to one depth from conv2d3_result

dense1_bias_binary = num2bin(q,double(dense1_bias_f8));
weight_file = fopen('./output/weight_bias_dense1.txt','w');

for i = 1:32                                                                %get one filter
   fprintf(weight_file,'%s',dense1_bias_binary(i,1:wordlength8));          %write 1 bias 
   fprintf(weight_file,'%d\n','');
   for k = 1:32
       for j = 1:16
           weight_binary = num2bin(q,double(dense1_weight_f8((j-1)*32+k,i)));
           fprintf(weight_file,'%s',weight_binary);      
           fprintf(weight_file,'%d\n','');
       end
   end
end

fclose(weight_file);
disp("weight and bias file for dense1 created successfully");
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%File 9: Result file for dense1 (normal sequence)
pooling_result_file = fopen('./output/dense1_result.txt','w');

for i = 1:32
     pixel = dense1_result(1,i);
     pixel_binary = num2bin(q,double(pixel));
     fprintf(pooling_result_file,'%s',pixel_binary(1:wordlength8));
     fprintf(pooling_result_file,'%d\n','');
end
fclose(pooling_result_file);
disp("dense1 result file created successfully");
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%File 10:weight and bias file for dense2 (1 bias+ 32 weight)*10
%Format of dense2_weight_f8: regular sequence

dense2_bias_binary = num2bin(q,double(dense2_bias_f8));
weight_file = fopen('./output/weight_bias_dense2.txt','w');

for i = 1:10                                                                %get one filter
   fprintf(weight_file,'%s',dense2_bias_binary(i,1:wordlength8));          %write 1 bias 
   fprintf(weight_file,'%d\n','');
   for k = 1:32
        weight_binary = num2bin(q,double(dense2_weight_f8(k,i)));
        fprintf(weight_file,'%s',weight_binary);      
        fprintf(weight_file,'%d\n','');
   end
end

fclose(weight_file);
disp("weight and bias file for dense2 created successfully");
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%File 11: Result file for conv2d3 (z sequence)
pooling_result_file = fopen('./output/conv2d3_flatten_result_z.txt','w');

for k = 1:32
    conv_result_temp = conv2d3_result(:,:,k);

    for i = 1:2
       for j = 1:2
          pixel = conv_result_temp(2*(i-1)+1,2*(j-1)+1);
          pixel_binary = num2bin(q,double(pixel));
          fprintf(pooling_result_file,'%s',pixel_binary(1:wordlength8));          %write top left pixel
          fprintf(pooling_result_file,'%d\n','');

          pixel = conv_result_temp(2*(i-1)+1,2*(j-1)+2);
          pixel_binary = num2bin(q,double(pixel));
          fprintf(pooling_result_file,'%s',pixel_binary(1:wordlength8));          %write top right pixel
          fprintf(pooling_result_file,'%d\n','');

          pixel = conv_result_temp(2*(i-1)+2,2*(j-1)+1);
          pixel_binary = num2bin(q,double(pixel));
          fprintf(pooling_result_file,'%s',pixel_binary(1:wordlength8));          %write bottom left pixel
          fprintf(pooling_result_file,'%d\n','');

          pixel = conv_result_temp(2*(i-1)+2,2*(j-1)+2);
          pixel_binary = num2bin(q,double(pixel));
          fprintf(pooling_result_file,'%s',pixel_binary(1:wordlength8));          %write bottom right pixel
          fprintf(pooling_result_file,'%d\n','');
       end
    end
end
fclose(pooling_result_file);
disp("conv2d3 result file in z sequence created successfully");
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%File 12:weight and bias file for dense1 (1 bias+ 512 weight)*32
%Format of dense1_weight_f8: each column (512) for a neuron, in each column
%each 32 values correspond to one depth from conv2d3_result
%This version is in reverse z format

dense1_bias_binary = num2bin(q,double(dense1_bias_f8));
weight_file = fopen('./output/weight_bias_dense1_z_r.txt','w');
counter = 1;

%use this for loop to generate the weight normal sequence first
for i = 1:32                                                                %get one filter
   for k = 1:32
       for j = 1:16
           weight_binary = num2bin(q,double(dense1_weight_f8((j-1)*32+k,i)));
           dense1_weight_bias_normal(counter,:) = weight_binary;
           counter = counter +1;
       end
   end %weight_bias_dense1
end


%use this for loop to generate and output the weight and bias in reverse z
%format
for i = 1:32
    fprintf(weight_file,'%s',dense1_bias_binary(i,1:wordlength8));          %write 1 bias 
    fprintf(weight_file,'%d\n','');
    for j=1:32
       for m = 1:2
           for n= 1:2
             weight_binary =  dense1_weight_bias_normal((i-1)*512+(j-1)*16+(m-1)*8+(n-1)*2+6,:);
             fprintf(weight_file,'%s',weight_binary);      
             fprintf(weight_file,'%d\n','');
             
             weight_binary =  dense1_weight_bias_normal((i-1)*512+(j-1)*16+(m-1)*8+(n-1)*2+5,:);
             fprintf(weight_file,'%s',weight_binary);      
             fprintf(weight_file,'%d\n','');
             
             weight_binary =  dense1_weight_bias_normal((i-1)*512+(j-1)*16+(m-1)*8+(n-1)*2+2,:);
             fprintf(weight_file,'%s',weight_binary);      
             fprintf(weight_file,'%d\n','');
             
             weight_binary =  dense1_weight_bias_normal((i-1)*512+(j-1)*16+(m-1)*8+(n-1)*2+1,:);
             fprintf(weight_file,'%s',weight_binary);      
             fprintf(weight_file,'%d\n','');
           end
       end  
    end
end

fclose(weight_file);
disp("weight and bias file for dense1 in reverse z format created successfully");
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%File 13:weight and bias file for dense1 (1 bias+ 512 weight)*32
%Format of dense1_weight_f8: each column (512) for a neuron, in each column
%each 32 values correspond to one depth from conv2d3_result
%This version is in reverse z format

dense1_bias_binary = num2bin(q,double(dense1_bias_f8));
weight_file = fopen('./output/weight_bias_dense1_z_r_group4.txt','w');
counter = 1;

%use this for loop to generate the weight normal sequence first
for i = 1:32                                                                %get one filter
   for k = 1:32
       for j = 1:16
           weight_binary = num2bin(q,double(dense1_weight_f8((j-1)*32+k,i)));
           dense1_weight_bias_normal(counter,:) = weight_binary;
           counter = counter +1;
       end
   end
end

%use this for loop to generate and output the weight and bias in reverse z
%format
counter = 1;
for i = 1:32
    for j=1:32
       for m = 1:2
           for n= 1:2
             weight_binary =  dense1_weight_bias_normal((i-1)*512+(j-1)*16+(m-1)*8+(n-1)*2+6,:);
             dense1_weight_reverse_z(counter,:)=weight_binary;
             counter = counter +1;
             
             weight_binary =  dense1_weight_bias_normal((i-1)*512+(j-1)*16+(m-1)*8+(n-1)*2+5,:);
             dense1_weight_reverse_z(counter,:)=weight_binary;
             counter = counter +1;
             
             weight_binary =  dense1_weight_bias_normal((i-1)*512+(j-1)*16+(m-1)*8+(n-1)*2+2,:);
             dense1_weight_reverse_z(counter,:)=weight_binary;
             counter = counter +1;
             
             weight_binary =  dense1_weight_bias_normal((i-1)*512+(j-1)*16+(m-1)*8+(n-1)*2+1,:);
             dense1_weight_reverse_z(counter,:)=weight_binary;
             counter = counter +1;%weight_bias_dense1
           end
       end  
    end
end

%reorganize the reverse z format into four group
for i = 1:8
    fprintf(weight_file,'%s',dense1_bias_binary(4*(i-1)+1,1:wordlength8));          %write 1 bias 
    fprintf(weight_file,'%d\n','');
    fprintf(weight_file,'%s',dense1_bias_binary(4*(i-1)+2,1:wordlength8));          %write 1 bias 
    fprintf(weight_file,'%d\n','');
    fprintf(weight_file,'%s',dense1_bias_binary(4*(i-1)+3,1:wordlength8));          %write 1 bias 
    fprintf(weight_file,'%d\n','');
    fprintf(weight_file,'%s',dense1_bias_binary(4*(i-1)+4,1:wordlength8));          %write 1 bias 
    fprintf(weight_file,'%d\n','');
   for j = 1:512
          weight_binary =  dense1_weight_reverse_z((i-1)*2048+j,:);
          fprintf(weight_file,'%s',weight_binary);      
          fprintf(weight_file,'%d\n','');
          
          weight_binary =  dense1_weight_reverse_z((i-1)*2048+j+512,:);
          fprintf(weight_file,'%s',weight_binary);      
          fprintf(weight_file,'%d\n','');
          
          weight_binary =  dense1_weight_reverse_z((i-1)*2048+j+1024,:);
          fprintf(weight_file,'%s',weight_binary);      
          fprintf(weight_file,'%d\n','');
          
          weight_binary =  dense1_weight_reverse_z((i-1)*2048+j+1536,:);
          fprintf(weight_file,'%s',weight_binary);      
          fprintf(weight_file,'%d\n','');
   end
end

fclose(weight_file);
disp("weight and bias file for dense1 in reverse z format in four groups created successfully");
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%The section for observing the output results and comparing NPU results
%with TF theoretical results. RMS error computed for each layer

layer0_output = fi(load("verification/layer0_output.mat").output,1,wordlength8,fractionlength8,F8);
%run this for loop in debugging mode
rms_error = zeros(32,1);
for i = 1:32
    layer0_output_1 = reshape(layer0_output(:,:,:,:,i),[28 28]);     %first depth, theoretical result from TF
    conv2d1_result_1 = conv2d1_result(:,:,i);                        %computed results from NPU
    rms_error(i,1) = sqrt(sum(sum((layer0_output_1-conv2d1_result_1).^2)));
end
avg_layer0_rms = sum(rms_error)/32.0/28/28;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
layer1_output = fi(load("verification/layer1_output.mat").output,1,wordlength8,fractionlength8,F8);
%run this for loop in debugging mode
for i = 1:32
    layer1_output_1 = reshape(layer1_output(:,:,:,:,i),[14 14]);     %first depth
    pooling1_result_1 = pooling1_result(:,:,i);
    rms_error(i,1) = sqrt(sum(sum((layer1_output_1-pooling1_result_1).^2)));
end
avg_layer1_rms = sum(rms_error)/32.0/14/14;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%run this for loop in debugging mode
layer2_output = fi(load("verification/layer2_output.mat").output,1,wordlength8,fractionlength8,F8);
for i = 1:32
    layer2_output_1 = reshape(layer2_output(:,:,:,:,i),[12 12]);     %first depth
    conv2d2_result_1 = conv2d2_result(:,:,i);
    rms_error(i,1) = sqrt(sum(sum((layer2_output_1-conv2d2_result_1).^2)));
end
avg_layer2_rms = sum(rms_error)/32.0/12/12;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
layer3_output = fi(load("verification/layer3_output.mat").output,1,wordlength8,fractionlength8,F8);
%run this for loop in debugging mode
for i = 1:32
    layer3_output_1 = reshape(layer3_output(:,:,:,:,i),[6 6]);     %first depth
    pooling2_result_1 = pooling2_result(:,:,i);
    rms_error(i,1) = sqrt(sum(sum((layer3_output_1-pooling2_result_1).^2)));
end
avg_layer3_rms = sum(rms_error)/32.0/6/6;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%run this for loop in debugging mode
layer4_output = fi(load("verification/layer4_output.mat").output,1,wordlength8,fractionlength8,F8);
for i = 1:32
    layer4_output_1 = reshape(layer4_output(:,:,:,:,i),[4 4]);     %first depth
    conv2d3_result_1 = conv2d3_result(:,:,i);
    rms_error(i,1) = sqrt(sum(sum((layer4_output_1-conv2d3_result_1).^2)));
end
avg_layer4_rms = sum(rms_error)/32.0/4/4;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
layer5_output = fi(load("verification/layer5_output.mat").output,1,wordlength8,fractionlength8,F8);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
layer6_output = fi(load("verification/layer6_output.mat").output,1,wordlength8,fractionlength8,F8);
%run this for loop in debugging mode
for i = 1:32
    rms_error(i,1) = sqrt(sum(sum((dense1_result(1,i)-layer6_output(:,:,i)).^2)));
end
avg_layer6_rms = sum(rms_error)/32;        %the depth is 1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
layer7_output = fi(load("verification/layer7_output.mat").output,1,wordlength8,fractionlength8,F8);
%run this for loop in debugging mode
for i = 1:10
    rms_error(i,1) = sqrt(sum(sum((dense2_result(1,i)-layer7_output(:,:,i)).^2)));
end
avg_layer7_rms = sum(rms_error)/10;        %the depth is 1

%conv2d2_pixel_1 = sum(sum(sum(pooling1_result(1:3,1:3,:) .* conv2d2_weight_2D_f8(:,:,:,1))));

%%
%this section is for plotting the confusion matrix
%image_recognition_result = load("output/recognition_result.txt");
true_image_label = load("data/imgs/img_label.txt");
confusion_mat = confusionmat(true_image_label, image_recognition_result);
confusionchart(confusion_mat,{'T-shirt/top', 'Trouser', 'Pullover', 'Dress', 'Coat','Sandal', 'Shirt', 'Sneaker', 'Bag', 'Ankle boot'});