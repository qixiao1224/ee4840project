%maxpooling layer operation
%only support input dimension even by even
%Format of input_mat: 3D array representing the input matrix (width, height, depth)
%Format of output_mat_f: 3D array representing the output matrix (width, height, depth)
%Format of policy   : a fimath() object

function output_mat_f = maxpooling2by2(input_mat,policy,wordlength8, fractionlength8)
    [input_mat_row, input_mat_col, input_mat_depth] = size(input_mat);
    
    % Initialize the output matrix
    output_mat_row = input_mat_row/2;
    output_mat_col = input_mat_col/2;
    output_mat_depth = input_mat_depth;
    output_mat = zeros(output_mat_row, output_mat_col,output_mat_depth);
    output_mat_f = fi(output_mat,1,wordlength8,fractionlength8,policy);
    
    region_f = fi(zeros(2,2),1,wordlength8,fractionlength8,policy);
   
    % Perform convolution using nested for loops
    for k = 1 : output_mat_depth
        for i = 1 : output_mat_row
            for j = 1 : output_mat_col
                % Apply kernel to the corresponding input matrix region
                region_f = input_mat(2*(i-1)+1:2*(i-1)+2,2*(j-1)+1:2*(j-1)+2,k);
                output_mat_f(i,j,k) = max(max(region_f));
            end
        end
    end
