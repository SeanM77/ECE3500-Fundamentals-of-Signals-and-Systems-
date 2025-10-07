% Open up a webcam stream
cam = webcam; 
alpha = 0.05; 
h = alpha * [0, 1, 0; 1, -4, 1; 0, 1, 0]; 
recordTime = 15; 
figure; 
tic; 

while toc < recordTime 
  
    im = snapshot(cam); 

    
    im = double(im) / 255; 
    original_im = im; 

    % Use Gaussian kernel for blurring
    N = 40; % Set the kernel size for the Gaussian filter.
    sigma = 500; % Define the standard deviation for the Gaussian filter.
    h = fspecial('gaussian', N, sigma); % Create a 2D Gaussian filter with given parameters.

    % Convert the Gaussian kernel to the frequency domain
    H = fft2(h, size(im, 1), size(im, 2)); % Compute the 2D FFT of the Gaussian kernel.


    BlurredOriginal = zeros(size(im)); 

    
    for c = 1:3 
        ImF = fft2(im(:, :, c)); % Compute the 2D FFT of the current image channel.
        BlurredOriginal(:, :, c) = ifft2(ImF .* H); % Multiply in frequency domain and transform back.
    end

    
    BlurredOriginal = min(max(BlurredOriginal, 0), 1);

    % Estimate noise variance for Wiener deconvolution
    noise_var = 0.001; 

    % Wiener deconvolution using FFT2
    DeblurredImage = zeros(size(im)); % Initialize the deblurred image array.
    for c = 1:3 
        B_F = fft2(BlurredOriginal(:, :, c)); 

        
        WienerFilter = conj(H) ./ (abs(H).^2 + noise_var); % Design the Wiener filter.

        
        Deconvolved_F = B_F .* WienerFilter; % Multiply in frequency domain to deblur.
        DeblurredImage(:, :, c) = ifft2(Deconvolved_F); % Transform back to the spatial domain.
    end

    
    sharp_filter = fspecial('unsharp'); % Create an unsharp mask filter.
    DeblurredImage = imfilter(DeblurredImage, sharp_filter); % Apply the filter to enhance details.

    
    DeblurredImage = min(max(DeblurredImage, 0), 1); 

    
    subplot(1, 2, 1), imshow(BlurredOriginal), title('Blurred Image'); % Show the blurred image.
    subplot(1, 2, 2), imshow(DeblurredImage), title('Deblurred Image'); % Show the deblurred image.

end
