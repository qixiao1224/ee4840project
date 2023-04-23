% weight1=load("C:\Users\teren\Desktop\weight_bias\weight1.mat");
% weight2=load("C:\Users\teren\Desktop\weight_bias\weight2.mat");
% weight3=load("C:\Users\teren\Desktop\weight_bias\weight3.mat");
% 
% bias1=load("C:\Users\teren\Desktop\weight_bias\bias1.mat");
% bias2=load("C:\Users\teren\Desktop\weight_bias\bias2.mat");
% bias3=load("C:\Users\teren\Desktop\weight_bias\bias3.mat");

weight_bias = load("data/weight_bias.mat");

wordlength = 16; %total number of bits
fractionlength = 7; %bits assigned for fraction

F16 = fimath();
F16.ProductMode = 'SpecifyPrecision';
F16.ProductWordLength = wordlength;
F16.ProductFractionLength = fractionlength;
F16.SumMode = 'SpecifyPrecision';
F16.SumWordLength = wordlength;
F16.SumFractionLength = fractionlength;

img0 = load("data/img0.mat").data;
img1 = load("data/img1.mat").data;
img2 = load("data/img2.mat").data;
img3 = load("data/img3.mat").data;
img4 = load("data/img4.mat").data;
img5 = load("data/img5.mat").data;
img6 = load("data/img6.mat").data;
img7 = load("data/img7.mat").data;
img8 = load("data/img8.mat").data;
img9 = load("data/img9.mat").data;

%data ending in "f": fixed point data
img0f = fi(img0, 1, wordlength, fractionlength, F16);
img1f = fi(img1, 1, wordlength, fractionlength, F16);
img2f = fi(img2, 1, wordlength, fractionlength, F16);
img3f = fi(img3, 1, wordlength, fractionlength, F16);
img4f = fi(img4, 1, wordlength, fractionlength, F16);
img5f = fi(img5, 1, wordlength, fractionlength, F16);
img6f = fi(img6, 1, wordlength, fractionlength, F16);
img7f = fi(img7, 1, wordlength, fractionlength, F16);
img8f = fi(img8, 1, wordlength, fractionlength, F16);
img9f = fi(img9, 1, wordlength, fractionlength, F16);

photof = zeros(16,16,10);
photof(:,:,1) = img0f;
photof(:,:,2) = img1f;
photof(:,:,3) = img2f;
photof(:,:,4) = img3f;
photof(:,:,5) = img4f;
photof(:,:,6) = img5f;
photof(:,:,7) = img6f;
photof(:,:,8) = img7f;
photof(:,:,9) = img8f;
photof(:,:,10) = img9f;

photos_labels = [0,1,2,3,4,5,6,7,8,9];

weight1 = weight_bias.weight1;
weight2 = weight_bias.weight2;
weight3 = weight_bias.weight3;
bias1 = weight_bias.bias1;
bias2 = weight_bias.bias2;
bias3 = weight_bias.bias3;


weight1f = fi(weight1, 1, wordlength, fractionlength, F16);
weight2f = fi(weight2, 1, wordlength, fractionlength, F16);
weight3f = fi(weight3, 1, wordlength, fractionlength, F16);
bias1f = fi(bias1, 1, wordlength, fractionlength, F16);
bias2f = fi(bias2, 1, wordlength, fractionlength, F16);
bias3f = fi(bias3, 1, wordlength, fractionlength, F16);

test_images = fi(load("data/test_images.mat").data, 1, wordlength, fractionlength);
test_imagef = fi(load("data/test_images.mat").data, 1, wordlength, fractionlength, F16);
test_labels = load("data/test_labels.mat").data;

x = predict(img2s, weight1s, weight2s, weight3s, bias1s, bias2s, bias3s, wordlength, fractionlength);

test_images = permute(test_images,[2,3,1]);
test_imagef = permute(test_imagef,[2,3,1]);
predicted_labels = zeros( 10000 );
predicted_photos_labels = zeros( 10 );


% test the accuracy on training dataset
count = 0;

for i = 1:length(test_images)
    
    
    predicted_labels(i) = predict(test_imagef(:,:,i), weight1f, weight2f, ...
        weight3f, bias1f, bias2f, bias3f, wordlength, fractionlength);

    if predicted_labels(i) == test_labels(i)
        count = count + 1;
    end

end
accuracy = count/length(test_labels)
count



% test the accuracy on handwritten data

count = 0;

for i = 1:10
    
    
    predicted_photos_labels(i) = predict(photof(:,:,i), weight1f, weight2f, ...
        weight3f, bias1f, bias2f, bias3f, wordlength, fractionlength);

    if predicted_photos_labels(i) == photos_labels(i)
        count = count + 1;
    end

end
accuracy = count/length(photos_labels);
count;