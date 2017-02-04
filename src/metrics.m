%// Brent Thomas Wasilow
%//
%// Matlab function used for calculating the three
%// image quality metrics used in the paper 
%// “Deskewing of Underwater Images.” The three metrics
%// are calculated from two input images and are as follows:
%//
%// 	1) Peak-Signal-to-Noise Ratio (PSNR)
%// 	2) Structure Similarity Index Measure (SSIM) 
%//	3) Normalized Mutual Information (NMI)
%// 
%// for which both 1) and 2) are both offered in the
%// standard Matlab toolbox, and 3) was coded using
%// Matlab since the standard Matlab toolbox did not
%// have a corresponding implementation.
%//
function [PSNR,SSIM,NMI] = metrics(A, ref)

% Get the PSNR value using the built-in Matlab function
PSNR = psnr(A, ref);

% Get the SSIM value using the built-in Matlab function
SSIM = ssim(A, ref);

% Get the NMI value using my implementation stored in
% the normalizedMutualInformation.m Matlab file.
NMI = nmi(A, ref);