%2D convolution function
%compatible with 2D and 3D filter
%compatible with multiple filters (index)
%function assumes that the depth of input matrix and each filter is same
%Format of input_mat: 3D array representing the input matrix (width, height, depth)
%Format of kernel   : 4D array (width ,height, depth,index)
%Format of bias     : 2D array (1,bias)
%Format of policy   : a fimath() object
%Format of output_mat_f: 3D array representing the output matrix (width, height, depth)

function output_mat_f = conv2d(input_mat,kernel,bias, policy,wordlength8, fractionlength8,en_relu)
    [input_mat_row, input_mat_col, input_mat_depth] = size(input_mat);
    [kernel_row, kernel_col,kernel_depth,kernel_num] = size(kernel);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
           
    %perform valid convolution    
    % Initialize the output matrix
    output_mat_row = input_mat_row-kernel_row+1;
    output_mat_col = input_mat_col-kernel_col+1;
    output_mat_depth = kernel_num;
    output_mat = zeros(output_mat_row, output_mat_col,output_mat_depth);
    output_mat_f = fi(output_mat,1,wordlength8,fractionlength8,policy); %the output result is still 8bit wide, but both the multiply and accumulate are done in 16-bit precision
    
    region = zeros(kernel_row,kernel_col,kernel_depth);
    region_f = fi(region,1,wordlength8,fractionlength8,policy);     %current region for convolution in input matrix

    
    % Perform convolution using nested for loops
    for k = 1 : output_mat_depth
        for i = 1 : output_mat_row
            for j = 1 : output_mat_col
                % Apply kernel to the corresponding input matrix region
                region_f = input_mat(i:i+kernel_col-1,j:j+kernel_row-1 , :);
                output_mat_f(i,j,k) = sum(sum(sum(region_f .* kernel(:,:,:,k))))+bias(1,k);   %convolve to kernel index k + bias
                if (en_relu) output_mat_f(i,j,k) = max(output_mat_f(i,j,k),0);   end             %apply ReLu function or not
            end
        end
    end