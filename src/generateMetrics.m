%// Brent Thomas Wasilow
%//
%// Matlab function used for looping through every image
%// in both the ucw and circular ripples directories
%// to be used in conjunction with the ground truth images
%// for generating the control image quality metrics as well
%// as using the ground truth image against the attempted 
%// deskewed/deblurred image to generate image quality
%// metrics to show the effectiveness of the algorithm.
%// Therefore, the control metrics will be compared
%// against the metrics produced from the image modified 
%// by the algorithm.
%//
function generateMetrics()

% Open two files for storing the metric values for both
% the circular and ucw images, and create a formatting
% string to dictate how the values will be written to
% the files.
circularMetrics = fopen('output/metrics/circular_metrics.txt','wt+');
ucwMetrics = fopen('output/metrics/ucw_metrics.txt','wt+');

% Grab all of the appropriate directory contents.
ground_files = dir('input/ground/*.JPG');
circular_files = dir('input/circular/*.JPG');
ucw_files = dir('input/ucw/*.JPG');

% For displaying loop progress.
count = 1;
total = (length(ucw_files) + length(circular_files)) .* length(ground_files);

% How much to resize images by.
resize = 0.25;

% Loop through each image in the ground directory to be
% used as the reference image input to our three image
% quality metrics.
for ground = ground_files'
  % Load each ground truth image and resize
  % by a quarter to speed up the metric calculation
  % process.
  ref = imread(strcat('input/ground/',ground.name));
  ref = imresize(ref, resize);
  
  % Loop through each image in the ucw directory
  % to be used as the second image input to our metric
  % calculating function. Perform the same loading and
  % resizing.
  for ucw = ucw_files'
    A = imread(strcat('input/ucw/',ucw.name));
    A = imresize(A, resize);
    
    % Calculate the three metric values using the metrics function
    % as defined by me in the metrics.m Matlab file. Subsequently,
    % write the values and the image names to the appropriate control
    % file.
    [PSNR,SSIM,NMI] = metrics(A, ref);
    fprintf(ucwMetrics,'%s %f %f %f\n',ucw.name,PSNR,SSIM,NMI);
    
    % Create subdirectory for this image to store modified images
    % in during the reconstruction phase.
    subFolder = strrep(ucw.name,'.JPG','');
    mkdir('output/ucw/',subFolder);
    path = ['output/ucw/' subFolder '/'];
    
    % Print out current progress.
    disp([num2str(count) ' of ' num2str(total)]);
    count = count+1;
    
    % Get the best values for each of the metrics
    % by calling my method which iteratively runs through
    % choices of starting variables to the deconvblind function.
    determineBestDeconvBlindValues(A,ref,strcat(path,ucw.name),ucwMetrics);
  end

  % Perform the same exact procedure as was done previously,
  % but instead use the circular images.
  for circular = circular_files'
    A = imread(strcat('input/circular/',circular.name));
    A = imresize(A, resize);

    [PSNR,SSIM,NMI] = metrics(A, ref);
    fprintf(circularMetrics,'%s %f %f %f\n',circular.name,PSNR,SSIM,NMI);
        
    subFolder = strrep(circular.name,'.JPG','');
    mkdir('output/circular/',subFolder);
    path = ['output/circular/' subFolder '/'];
        
    disp([num2str(count) ' of ' num2str(total)]);
    count = count + 1;
    
    determineBestDeconvBlindValues(A,ref,strcat(path,circular.name),circularMetrics);
  end
end

fclose(circularMetrics);
fclose(ucwMetrics);