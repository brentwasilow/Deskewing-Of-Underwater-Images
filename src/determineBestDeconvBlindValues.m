%// Brent Thomas Wasilow
%//
%// Matlab function that takes in a blurred image and performs the
%// blind deconvolution algorithm on it. Specifically, a set of estimate
%// PSFs will be used as input to the deconvblind() Matlab function.
%// The output image will then be written to a file and compared against
%// the reference image. Those metrics will then be written to a file. 
%//
function determineBestDeconvBlindValues(A,ref,name,fileID)
% Define our PSF guesses list of varying sizes of all ones.
h1 = ones(3);
h2 = fspecial('motion',3,10);
h3 = ones(5);
h4 = fspecial('motion',5,10);
PSFSet = {h1,h3};

% Other PSFSet
%PSFSet = {ones(3),ones(5),ones(7),ones(9)};
      
% Start and end for the deconvblind() function.
START = 50;
END = 50;

% Dampar value ranges to iterate through for
% suppressing noise.
DAMPAR = 0;
   
% Create an image that consists of all of the
% edges in our initial image A up to a treshold.
% To be used for reducing ringing. Modify the
% threshold to get different weight images.
threshold = 0.15;
edges = edge(rgb2gray(A),'sobel',threshold);
se = strel('disk',1);
edges = 1-double(imdilate(edges,se));
edges([1:3 end-(0:2)],:) = 0;
edges(:,[1:3 end-(0:2)]) = 0;

% Transform weights into a RGB image.
WEIGHT = double(zeros([size(edges) 3]));
WEIGHT(:,:,1) = edges;
WEIGHT(:,:,2) = edges;
WEIGHT(:,:,3) = edges;

%Display WEIGHT image
%imshow(WEIGHT,[]);

% Loop through user-defined PSF list.
for i = 1:numel(PSFSet)
  % Assign the next PSF guess to our local variable
  % and taper the image using this PSF
  INITPSF = PSFSet{i};
  I = edgetaper(A,INITPSF);
  
  % Loop through various parameter operations
  % for both number of iterations and damping
  % values
  for it = START:25:END
    for damp = 0:DAMPAR
      % Use the initial PSF guess along with our
      % edge-tapered image A, a set number of
      % iterations, a dampar value and a WEIGHT
      % image and perform blind deconvolution,
      % returning a modified image AMod and
      % a more accurate PSF. Not using the WEIGHT
      % component.
      [AMod,PSF] = deconvblind(I,INITPSF,it,uint8(damp));
        
      % Display deblurred image.
      %imshow(AMod);
      
      % Write the modified image to a new
      % JPG file along with a new name signifying its properties
      fileNameAddition = strcat('-',num2str(size(INITPSF,1)),'-',num2str(it),'-',num2str(damp),'.JPG');
      newName = strrep(name,'.JPG',fileNameAddition);
      imwrite(AMod,newName);
      
      % Calculate the appropriate metric structures
      % after calling the metrics function using
      % the to-be-determined deskewed/deblurred image
      % and the reference image.
      [PSNRMod,SSIMMod,NMIMod] = metrics(AMod,ref);
      
      % Print metrics to a file.
      fprintf(fileID,'%s %f %f %f\n',newName,PSNRMod,SSIMMod,NMIMod);
    end
  end
end  
