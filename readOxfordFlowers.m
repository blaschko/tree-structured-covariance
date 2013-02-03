function [Kx,Y,V,classes] = readOxfordFlowers();
%
% Author: Matthew Blaschko - matthew.blaschko@inria.fr
% copyright (c) 2012-2013
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 3 of the License, or
% (at your option) any later version.
% 
% Written (W) 2012-2013 Matthew Blaschko
%
% citations:
%   Blaschko, M. B., W. Zaremba, and A. Gretton: Taxonomic Prediction with
%   Tree-Structured Covariances. Under submission.
%
%   see Oxford Flowers website for dataset citations:
%   http://www.robots.ox.ac.uk/~vgg/data/flowers/ 
%
%   Exact form of kernel due to Gehler and Nowozin ICCV 2009.
%
    
load OxfordFlowers/distancematrices17gcfeat06.mat
load OxfordFlowers/distancematrices17itfeat08.mat

% using the heuristic from Gehler and Nowozin ICCV 2009.
gammaColour = mean(D_colourgc(:));
gammaHog = mean(D_hog(:));
gammaHSV = mean(D_hsv(:));
gammaShape = mean(D_shapegc(:));
gammaSiftbdy = mean(D_siftbdy(:));
gammaSiftint = mean(D_siftint(:));
gammaTexture = mean(D_texturegc(:));

Kx = exp(-D_colourgc./gammaColour) + exp(-D_hog./gammaHog) + ...
     exp(-D_hsv./gammaHSV) + exp(-D_shapegc./gammaShape) + ...
     exp(-D_siftbdy./gammaSiftbdy) + exp(-D_siftint./gammaSiftint) ...
     + exp(-D_texturegc./gammaTexture);

Y = [];
classes = cell(0);
for i=1:17
    Y = [Y;zeros(80,i-1) ones(80,1) zeros(80,17-i)];
end
classes{1} = 'Daffodil';
classes{2} = 'Snowdrop';
classes{3} = 'Lily Valley';
classes{4} = 'Bluebell';
classes{5} = 'Crocus';
classes{6} = 'Iris';
classes{7} = 'Tigerlilly';
classes{8} = 'Tulip';
classes{9} = 'Fritillary';
classes{10} = 'Sunflower';
classes{11} = 'Daisy';
classes{12} = 'Colt''s Foot';
classes{13} = 'Dandelion';
classes{14} = 'Cowslip';
classes{15} = 'Buttercup';
classes{16} = 'Windflower';
classes{17} = 'Pansy';


V = OxfordFlowersPartitionMat();


end


% end of file
