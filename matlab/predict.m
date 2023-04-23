function prediction = predict(img, weight_1, weight_2, weight_3, bias_1, bias_2, bias_3, wordlength, fractionlength)
    
    flattened = reshape(img.',1,[]);
    
    temp1 = (weight_1.' * flattened.') + bias_1.';
    temp1 = max(temp1, 0);
    %temp1 = fi(temp1, 1, wordlength, fractionlength);

    temp2 = (weight_2.' * temp1) + bias_2.';
    temp2 = max(temp2, 0);
    %temp2 = fi(temp2, 1, wordlength, fractionlength);


    temp3 = (weight_3.' * temp2) + bias_3.';
    %temp3 = fi(temp3, 1, wordlength, fractionlength);
    %temp3 = softmax(double(temp3));
    [~, prediction] = max(temp3);
    
    prediction = prediction - 1;
   

end