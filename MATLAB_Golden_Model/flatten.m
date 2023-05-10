%function for flattening layer
%Format of input_mat: 3D array representing the input matrix (width, height, depth)
%Format of output_mat_f: 1D array representing the output matrix (only row)
%Format of policy   : a fimath() object

function output_mat_f = flatten(input_mat,policy,wordlength8, fractionlength8)
    [input_mat_row, input_mat_col, input_mat_depth] = size(input_mat);
      
    % Initialize the output matrix
    output_mat_col = input_mat_row*input_mat_col*input_mat_depth;
    output_mat = zeros(1,output_mat_col);
    output_mat_f = fi(output_mat,1,wordlength8,fractionlength8,policy);
    
    % flatten the input 3D matrix

    for i = 1 : input_mat_row
        for j = 1 : input_mat_col
            for k = 1 : input_mat_depth
                index = (i-1)*input_mat_depth*input_mat_col + (j-1)*input_mat_depth + k;
                output_mat_f(1,index) = input_mat(i,j,k);
            end
        end
    end