%dense layer operation
%Format of input_mat:    1D array representing the input matrix (only one row)
%Format of weight:       2D array representing the weight matrix 
%Format of bias:         1D array representing the bias matrix (only one row) 
%Format of output_mat_f: 1D array representing the output matrix (only one row)
%Format of policy   : a fimath() object

function output_mat_f = dense(input_mat,weight,bias,policy,wordlength8, fractionlength8, en_relu)

    [weight_row weight_col] = size(weight);
 
    % Initialize the output matrix
    output_mat_col = weight_col;
    output_mat = zeros(1,output_mat_col);
    output_mat_f = fi(output_mat,1,wordlength8,fractionlength8,policy);
    
    %output_mat_f = input_mat * weight + bias;    
    %built-in cross product will cause the output matrix to deviate from 8bit
    %representation for unknown reason, thus abandoned
    
    weight = weight';
    for i = 1:output_mat_col
       output_mat_f(1,i) = sum(input_mat .* weight(i,:)) + bias(1,i);
       if (en_relu) output_mat_f(1,i)= max(output_mat_f(1,i),0); end %use ReLU function or not
    end
