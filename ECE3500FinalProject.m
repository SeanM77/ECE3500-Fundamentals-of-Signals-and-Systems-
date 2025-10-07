% Read an image
im = imread('picture1.jpg');
im = double(im) / 255;  % Normalize to [0, 1]

original_im = im;

% Modify the red channel
modified_im = im;  
modified_im(:, :, 1) = modified_im(:, :, 1) * 1.5;  
modified_im(:, :, 1) = min(modified_im(:, :, 1), 1);  

% Use Gaussian kernel for blurring
N = 40;  
sigma = 500; % Sigma = standard deviation
h = fspecial('gaussian', N, sigma);  % Create Gaussian filter
% Convert the kernel to frequency domain
H = fft2(h, size(im, 1), size(im, 2));  

% Initialize the blurred image
BlurredOriginal = zeros(size(im));

% Apply the Gaussian blur to each color channel using FFT2
for c = 1:3  
    ImF = fft2(im(:, :, c));  % Fourier transform of the image channel
    BlurredOriginal(:, :, c) = ifft2(ImF .* H); % IFFT2 = 2-D inverse fast Fourier transform
end

% Clip values to ensure they are within [0, 1]
BlurredOriginal = min(max(BlurredOriginal, 0), 1);

% Estimate noise variance for Wiener deconvolution
noise_var = 0.001;

% Wiener deconvolution using FFT2
DeblurredImage = zeros(size(im));
for c = 1:3
    B_F = fft2(BlurredOriginal(:, :, c));  
   
    WienerFilter = conj(H) ./ (abs(H).^2 + noise_var);  
    Deconvolved_F = B_F .* WienerFilter;
    DeblurredImage(:, :, c) = ifft2(Deconvolved_F);  
end

% Apply sharpening to enhance details
sharp_filter = fspecial('unsharp');
DeblurredImage = imfilter(DeblurredImage, sharp_filter);

% Clip values to ensure they are within [0, 1]
DeblurredImage = min(max(DeblurredImage, 0), 1);

% Display the results
figure;
subplot(2, 2, 1), imshow(original_im), title('Original Image');
subplot(2, 2, 2), imshow(modified_im), title('Modified Red Channel');
subplot(2, 2, 3), imshow(BlurredOriginal), title('Blurred Image');
subplot(2, 2, 4), imshow(DeblurredImage), title('Deblurred Image');
