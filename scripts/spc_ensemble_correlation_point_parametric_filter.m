
% Add paths
addpath correlation_algorithms/
addpath filtering/
addpath phase_unwrapping/
addpath jobfiles/

% Input data directory
input_dir = '/Users/matthewgiarra/Desktop/schlieren';

% Input data base name
% input_base_name = 'mng-2-069-E_';
input_base_name = 'schlieren_test_06_';

% Input data number format
num_format = '%06d';

% Input data extension
input_extension = '.tif';

% Grid point location (just a single grid point)
grid_row = 570;
grid_col = 550;

% Start image
start_image = 400;

% End image
end_image = 499;

% Frame step
frame_step = 1;

% Correlation step
correlation_step = 1;

% Region size
region_height = 64;
region_width = 64;

% Minimum dimension
min_dim = min([region_width, region_height]);

% Window fractions
window_fraction = [0.5, 0.5];

% Correlation method
correlation_method = 'scc';

% Coordinates
[x, y] = meshgrid(1 : region_width, 1 : region_height);

% Centroid
xc = region_height / 2 + 1;
yc = region_width  / 2 + 1;

% Angular coordinates
[~, r] = cart2pol(x - xc, y - yc);

% First image numbers
image_numbers_01 = start_image : frame_step : end_image;

% Second image numbers
image_numbers_02 = image_numbers_01 + correlation_step;

% Number of images
num_images = length(image_numbers_01);

% Region rows
region_rows = grid_row + [-region_height/2 : region_height/2 - 1];

% Region columns
region_cols = grid_col +  [-region_width/2 : region_width/2 - 1];

% Create a region window
region_window = gaussianWindowFilter([region_height, region_width], ...
    window_fraction, 'fraction');

% Allocate a correlation plane
cross_correlation = zeros(region_height, region_width, 'double');

% Make file paths
for k = 1 : num_images
   
    % File name of the first images
    file_name_01 = [input_base_name num2str(image_numbers_01(k), num_format) input_extension];
    
    % File name of the second images
    file_name_02 = [input_base_name num2str(image_numbers_02(k), num_format) input_extension];
    
    % File paths
    file_path_01{k} = fullfile(input_dir, file_name_01);
    file_path_02{k} = fullfile(input_dir, file_name_02);
   
end

% Do the correlations
for k = 1 : num_images
   
    % Check existence of both filepaths
    if exist(file_path_01{k}, 'file') && exist(file_path_02{k}, 'file')
        
        % Inform the user
        fprintf('Processing image %d of %d...\n', k, num_images);
        
        % Read the first image
        img_01 = double(imread(file_path_01{k}));
        
        % Read the second image
        img_02 = double(imread(file_path_02{k}));
        
        % Extract the parts of the image used in the correlation
        region_01_raw = img_01(region_rows, region_cols); 
        region_02_raw = img_02(region_rows, region_cols);
        
        % Zero-mean
        region_01 = region_01_raw - mean(region_01_raw(:));
        region_02 = region_02_raw - mean(region_02_raw(:));
        
        % Take the FFT of both regions
        ft_01 = fftn(region_01 .* region_window , [region_height, region_width]);
        ft_02 = fftn(region_02.* region_window, [region_height, region_width]);
        
        % Conjugate-multiply the regions' Fourier Transforms 
        % to produce the complex cross correlation
        cross_correlation = cross_correlation + ft_01 .* conj(ft_02);
          
    end
    
end

    
% Extract the phase from the ensemble cross correlation plane
spectral_phase_plane = (phaseOnlyFilter(cross_correlation));

% SCC plane
scc_plane = fftshift(abs(real(ifft2(cross_correlation))));

% % Loop over the filters
% for k = 0 : 1 : round(max(r(:)))
%     
%     % Weighting filter
%     plane_fit_weights = zeros(size(x));
% 
%     % Cutoff radius
%     r_cutoff = max(r(:)) - k;
% 
%     % Plane fit weights
%     plane_fit_weights(r < r_cutoff) = 1;
% 
%     % Filtered phase plane
%     spectral_phase_plane_filtered = ...
%         fftshift(plane_fit_weights) .* spectral_phase_plane;
%     
%     % GCC plane
%     gcc_plane = fftshift(abs(real(ifft2(spectral_phase_plane_filtered))));
%  
% %     % Extract the phase angle from the phase plane
% %     phase_angle_plane = fftshift(angle(spectral_phase_plane_filtered));
% 
% %     % svd_plane
% %     svd_plane = fftshift(angle(...
% %         svd_phase_filter_2D(spectral_phase_plane_filtered, 1)));
%     
%     % Plots
%     subplot(1, 2, 1)
%     imagesc(fftshift(angle(spectral_phase_plane_filtered)));
%     axis image;
%     title('Phase angle', 'FontSize', 20);
%     
%     subplot(1, 2, 2); 
%     mesh(gcc_plane ./ max(gcc_plane(:)), 'edgecolor', 'black');
%     title('GCC', 'FontSize', 20');
%     pbaspect([1, 1, 0.6]);
%     set(gca, 'view', [-29.5000   12.0000]);
%     
%     pause(0.25);
%     
% 
% end


% GCC plane
gcc_plane = fftshift(abs(real(ifft2(spectral_phase_plane))));

% Extract the phase angle from the phase plane
phase_angle_plane = fftshift(angle(spectral_phase_plane));

% svd_plane
svd_plane = fftshift(angle(...
    svd_phase_filter_2D(spectral_phase_plane, 1)));

figure(1);
% Plot them
subplot(2, 2, 1);
mesh(scc_plane ./ max(scc_plane(:)), 'edgecolor', 'black');
title('SCC', 'FontSize', 20');
pbaspect([1, 1, 0.6]);
set(gca, 'view', [-29.5000   12.0000]);

subplot(2, 2, 2); 
mesh(gcc_plane ./ max(gcc_plane(:)), 'edgecolor', 'black');
title('GCC', 'FontSize', 20');
pbaspect([1, 1, 0.6]);
set(gca, 'view', [-29.5000   12.0000]);

subplot(2, 2, 3)
imagesc(phase_angle_plane);
axis image;
title('Phase angle', 'FontSize', 20);

subplot(2, 2, 4)
mesh(svd_plane, 'edgecolor', 'black');
pbaspect([1, 1, 0.6]);
set(gca, 'view', [-29.5000   12.0000]);
title('Phase angle (SVD)', 'FontSize', 20);


% % Zero the parts of the phase plane that are outsize the cutoff radius
% spectral_phase_plane(r > rc_outer) = 0;


% 
% % % Calculate the displacement from the SPC plane fit
% % [v_spc, u_spc, coeffs] = spc_plane_fit(angle(spectral_phase_plane), ...
% %     plane_fit_weights);
% % 
% % z = polyval2(coeffs,x,y);
% 
% figure(1);
% % Plot the phase angle plane
% imagesc(phase_angle_plane); 
% axis image
% 
% % Invert FT the phase and plot
% spatial_phase_plane = fftshift(abs(ifft2(spectral_phase_plane)));
% 
% % Plot the spatial phase plane
% figure(2)
% mesh(spatial_phase_plane ./ max(spatial_phase_plane(:)));
% 
% 
% 
% 





figure(2);
% Plot them
mesh(scc_plane ./ max(scc_plane(:)), 'edgecolor', 'black');
pbaspect([1, 1, 0.6]);
set(gca, 'view', [-29.5000   12.0000]);
axis off

figure_name = sprintf('schlieren_ensemble_row_%d_col_%d.eps',grid_row,grid_col);
figure_path = fullfile('~/Desktop', figure_name);
print(2, '-deps', figure_path);














