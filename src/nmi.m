%// Brent Thomas Wasilow
%//
%// Matlab function for determining the Normalized Mutual
%// Information value between two images. One of the image
%// quality metrics used in the paper “Deskewing of
%// Underwater Images.”
%//
function NMI = nmi(A, ref)

% Convert our two images to 8 bit grayscale, where
% ref is the ground truth image and A is the 
% image we will be comparing against. 
ref = rgb2gray(im2uint8(ref));
A = rgb2gray(im2uint8(A));

% The number of gray levels that are possible
% in a uint8 image.
grayLevels = 256;

% Initialize a matrix of size 256x256 to all zeroes.
% This will hold all of the possible combinations
% of pairs of gray values between the two images.  
jointHistogram = zeros(grayLevels);

% Grab the total number of rows and columns for the
% two images. For this algorithm to work we need to
% assume that the image sizes are the same.
rows = size(A,1);
cols = size(A,2);

% Loop through both images simultaneously and increment
% the joint histogram for the gray value combination.
for i=1:rows;
  for j=1:cols;
    jointHistogram(ref(i,j)+1,A(i,j)+1) = jointHistogram(ref(i,j)+1,A(i,j)+1)+1;
  end
end

% Divide the joint histogram values by the summation
% carried through to get the normalized joint histogram.
jointHistogram = jointHistogram/sum(sum(jointHistogram));

% Grab all of the nonzero indices since the entropy
% calculation cannot handle 0 due to the log2.
nonZeroIndices = find(jointHistogram);

% Determine the joint entropy by using the indices
% of nonzero values of the joint histogram and the
% standard entropy equation. 
jointEntropy = -sum(jointHistogram(nonZeroIndices).*(log2(jointHistogram(nonZeroIndices))));

% Determine the entropy for the first image by
% grabbing the histogram values out of the joint
% histogram matrix using the accumulation of all
% of the columns for each row.
histogramRef = sum(jointHistogram,1);
nonZeroIndicesRef = find(histogramRef);
entropyRef = -sum(histogramRef(nonZeroIndicesRef).*(log2(histogramRef(nonZeroIndicesRef))));

% Perform the same calculation as previously done
% but instead by summing all of the rows for each
% column to get the histogram for the second image.
histogramA = sum(jointHistogram,2);
nonZeroIndicesA = find(histogramA);
entropyA = -sum(histogramA(nonZeroIndicesA).*(log2(histogramA(nonZeroIndicesA))));

% Calculate the normalized mutual information using
% the calculated entropy for the reference image,
% the deskewed/deblurred image, and the joint images.
NMI = (entropyRef+entropyA)/jointEntropy;
