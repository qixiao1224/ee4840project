function temp1= predict2(img, weight_1, bias_1, wordlength, fractionlength)

    temp1 = (weight_1.' * img.') + bias_1.';
    temp1 = max(temp1, 0);
    %temp1 = fi(temp1, 1, wordlength, fractionlength);

end