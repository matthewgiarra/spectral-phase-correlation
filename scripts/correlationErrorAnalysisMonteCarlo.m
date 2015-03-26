function  correlationErrorAnalysisMonteCarlo(MONTE_CARLO_PARAMETERS); 

% Parse the input structure
JobFile = MONTE_CARLO_PARAMETERS.JobFile;
results_save_path = MONTE_CARLO_PARAMETERS.Save_Path;
image_file_path = MONTE_CARLO_PARAMETERS.Image_File_Path;
parameters_file_path = MONTE_CARLO_PARAMETERS.Image_Parameters_path;

% Suppress messages?
suppress_messages = JobFile.JobOptions.SuppressMessages;

% Start and end image numbers
start_image = JobFile.Parameters.Images.Start;
end_image = JobFile.Parameters.Images.End;

% Number of images to skip between successive correlations.
skip_image = JobFile.Parameters.Images.Skip;

% Job Options
run_compiled = JobFile.JobOptions.RunCompiled;

% Parallel processing flag
parallel_processing = JobFile.JobOptions.ParallelProcessing;

% Whether or not to zero-mean regions
zero_mean_regions = JobFile.JobOptions.ZeroMeanRegions;

% Spatial window parameters
spatialWindowType =  JobFile.Parameters.Processing.SpatialWindowType; % Spatial window type
spatialWindowFraction = JobFile.Parameters.Processing.SpatialWindowFraction; % Spatial image window fraction (y, x)

% Weighted fit option
weightedFitMethod = lower(JobFile.Parameters.Processing.WeightedFitMethod);

% Load images
load(image_file_path);

% Load parameters to read true solutions so they can be saved to file.
load(parameters_file_path);

% Image numbers
image_numbers = start_image : skip_image : end_image;

% Number of images
[region_height, region_width, number_of_images] = size(imageMatrix1(:, :, image_numbers));

% Create the spatial window
spatial_window = gaussianWindowFilter( [region_height region_width], spatialWindowFraction, spatialWindowType);

% Initialize vectors to hold translation estimates
TY_EST = zeros(number_of_images, 1);
TX_EST = zeros(number_of_images, 1);

% Read the true translations, which will be saved to file.
TY_TRUE = Parameters.TranslationY(image_numbers);
TX_TRUE = Parameters.TranslationX(image_numbers);

% Correlation method
% Valid methods: scc, rpc, gcc, spc, fmc
correlation_type = lower(JobFile.CorrelationType);

% Flag specifying whether the job is SCC
isScc = ~isempty(regexpi(correlation_type, 'scc'));

% Flag specifying whether the job is RPC
isRpc = ~isempty(regexpi(correlation_type, 'rpc'));

% Flag specifying whether the job is SPC
isSpc = ~isempty(regexpi(correlation_type, 'spc'));

% Flag specifying whether the job is FMC
isFmc = ~isempty(regexpi(correlation_type, 'fmc'));

% Create the RPC filter if RPC or SPC is specified.
if isRpc || isSpc
    % Spatial RPC diameter
    spatial_rpc_diameter = JobFile.Parameters.Processing.SpatialRPCDiameter;

    % Create the 2-D spectral filter (i.e. RPC filter)
    rpc_spectral_filter = spectralEnergyFilter(region_height, ...
        region_width, spatial_rpc_diameter);
else
    % Just set a value so that the parfor loop runs.
    rpc_spectral_filter = 0;
end

% SPC-specific parameters calculations.
if isSpc
    
    % SPC filter cutoff amplitude
    spc_cutoff_amplitude = 2 / (pi * spatial_rpc_diameter);
    
    % Read the filter type.
    phase_filter_list = lower(JobFile.Parameters.Processing. ...
        PhaseFilterList);
    
    % Read the phase filter kernel list
    phase_filter_kernel_size_list = JobFile.Parameters.Processing. ...
        KernelSizeList;
    
    % Augment the phase filter kernel size list if needed
    if length(phase_filter_kernel_size_list) < length(phase_filter_list)
       phase_filter_kernel_size_list{length(phase_filter_list)} = []; 
    end
    
    % Read the unwrapping type
    phase_unwrapping_method = JobFile.Parameters.Processing. ...
        PhaseUnwrappingAlgorithm;
    
    % Switch between weighting methods
    switch weightedFitMethod
        
        case 'rpc'

            % Make the 2-D SPC filter
            spc_weighting_matrix = rpc_spectral_filter;
            spc_weighting_matrix(spc_weighting_matrix < ...
            spc_cutoff_amplitude) = 0;
        
        otherwise
        % Case of no weighting.
        spc_weighting_matrix = ones([region_height, region_width],...
            'double');
    end
    
else
    % Just set values so the parfor loop runs.
    spc_weighting_matrix = 1;
    phase_filter_list = '';
    phase_filter_kernel_size_list = '';
    phase_unwrapping_method = '';
    
end

% Perform the correlations
if parallel_processing
    
    % Parallel processing.
    parfor k = 1 : number_of_images
        
         % Print the iteration number
        if ~suppress_messages
            fprintf('On region %d of %d\n', k, number_of_images);
        end
        
        % Read the raw images
        region_01 = double(imageMatrix1(:, :, image_numbers(k)));
        region_02 = double(imageMatrix2(:, :, image_numbers(k)));
        
        % Zero mean regions if requested
        if zero_mean_regions
            region_01 = zero_mean_region(region_01);
            region_02 = zero_mean_region(region_02);
        end
        
        % Choose among correlation algorithms.
        switch lower(correlation_type)
            case 'scc'
                [TY_EST(k), TX_EST(k)] = SCC(spatial_window .* region_01,...
                    spatial_window .* region_02);
            case 'rpc'
                [TY_EST(k), TX_EST(k)] = RPC(spatial_window .* region_01,...
                    spatial_window .* region_02, rpc_spectral_filter); 
            case 'spc'
                [TY_EST(k), TX_EST(k)] = spc_2D(spatial_window .* region_01,...
                    spatial_window .* region_02, spc_weighting_matrix, ...
                    phase_filter_list, phase_filter_kernel_size_list,...
                    phase_unwrapping_method, run_compiled); 
        end                              
    end 
    
else
    
    % Single-core processing
    for k = 1 : number_of_images
        
        % Print the iteration number
        if ~suppress_messages
            fprintf('On region %d of %d\n', k, number_of_images);
        end
        
        % Read the raw images
        region_01 = double(imageMatrix1(:, :, image_numbers(k)));
        region_02 = double(imageMatrix2(:, :, image_numbers(k)));
        
        % Zero mean regions if requested
        if zero_mean_regions
            region_01 = zero_mean_region(region_01);
            region_02 = zero_mean_region(region_02);
        end
        
        % Choose among correlation algorithms.
        switch lower(correlation_type)
            case 'scc'
                [TY_EST(k), TX_EST(k)] = SCC(spatial_window .* region_01,...
                    spatial_window .* region_02);
            case 'rpc'
                [TY_EST(k), TX_EST(k)] = RPC(spatial_window .* region_01,...
                    spatial_window .* region_02, rpc_spectral_filter); 
            case 'spc'
                [TY_EST(k), TX_EST(k)] = spc_2D(spatial_window .* region_01,...
                    spatial_window .* region_02, spc_weighting_matrix, ...
                    phase_filter_list, phase_filter_kernel_size_list,...
                    phase_unwrapping_method, run_compiled); 
        end                        
   end 
    
end
 
% Save the output data
save(results_save_path, 'JobFile','TY_EST', 'TX_EST','TY_TRUE', 'TX_TRUE');

end











