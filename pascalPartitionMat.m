function V = pascalPartitionMat();
% V = pascalPartitionMat();
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
% V is equal to the partition matrix encoding the topology in Fig. 2 of
% Everingham et al, The PASCAL Visual Object Classes (VOC) Challenge, IJCV 2010
%
% Citations:
%   Blaschko, M. B., W. Zaremba, and A. Gretton: Taxonomic Prediction with
%   Tree-Structured Covariances. ECML/PKDD, 2013.
%
%   Everingham et al, The PASCAL Visual Object Classes (VOC)
%   Challenge, IJCV 2010 
    
     % internal nodes      class specific nodes (identity matrix)
V = [1 0 0 0 0 0 0 1 0 0   1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;... % aeroplane
     1 0 0 0 0 0 0 1 1 0   0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;... % bicycle
     1 1 0 0 0 0 0 0 0 0   0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;... % bird
     1 0 0 0 0 0 0 1 0 0   0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;... % boat
     1 0 0 0 1 0 0 0 0 0   0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;... % bottle
     1 0 0 0 0 0 0 1 0 1   0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0;... % bus
     1 0 0 0 0 0 0 1 0 1   0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0;... % car
     1 1 1 0 0 0 0 0 0 0   0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0;... % cat
     1 0 0 0 1 1 1 0 0 0   0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0;... % chair
     1 1 0 1 0 0 0 0 0 0   0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0;... % cow
     1 0 0 0 1 1 0 0 0 0   0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0;... % diningtable
     1 1 1 0 0 0 0 0 0 0   0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0;... % dog
     1 1 0 1 0 0 0 0 0 0   0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0;... % horse
     1 0 0 0 0 0 0 1 1 0   0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0;... % motorbike
     1 0 0 0 0 0 0 0 0 0   0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0;... % person
     1 0 0 0 1 0 0 0 0 0   0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0;... % potted plant
     1 1 0 1 0 0 0 0 0 0   0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0;... % sheep
     1 0 0 0 1 1 1 0 0 0   0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0;... % sofa
     1 0 0 0 0 0 0 1 0 0   0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0;... % train
     1 0 0 0 1 0 0 0 0 0   0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1;];  % tvmonitor
 
end


% end of file

