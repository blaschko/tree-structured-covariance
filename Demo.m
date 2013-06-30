function [accuracy,Bflower,Vflower,classesFlower,Bpascal,Vpascal,classesPascal] = Demo();
% Author: Matthew Blaschko - matthew.blaschko@inria.fr
% Copyright (c) 2013
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 3 of the License, or
% (at your option) any later version.
% 
% Written (W) 2012-2013 Matthew Blaschko
%
% This file provides a demo of the multi-class taxonomic prediction
% training algorithm described in Blaschko, Zaremba, and Gretton (citation
% below).  The code requires that the Oxford Flowers data be
% downloaded and extracted into a folder called OxfordFlowers.  The data
% are available for download from:
% http://www.robots.ox.ac.uk/~vgg/data/flowers/
% if you are on a unix/mac type system with wget installed, this function
% will call the script downloadOxfordFlowers.sh that is bundled with this
% code and you don't need to do anything extra.  If you can't run unix
% style shell scripts and/or don't have wget, you will need to download the
% files manually and put them in the right directory.
%
% The main function of interest is covMulticlass, which trains a
% multi-class prediction function with a covariance structure over the
% classes.  This function may be a tree-structured covariance matrix as we
% have employed here, or any other positive definite matrix.  The identity
% matrix will reproduce the results of the multi-class SVM (Crammer &
% Singer 2001).
%
% Outputs:
%   accuracy - the accuracy of multi-class prediction trained with a
%              tree-structured covariance matrix on a random split of the
%              Oxford Flowers dataset
%   Bflower  - the centered tree-structured covariance matrix for Oxford Flowers
%   Vflower  - the partition matrix for the Linnaean biological taxonomy 
%              for Oxford Flowers
%   classesFlower - a cell array of ordered class names for Oxford Flowers
%   Bpascal  - the centered tree-structured covariance matrix for PASCAL VOC
%   Vpascal  - the partition matrix for the semantic taxonomy for PASCAL VOC 
%              as defined by the dataset organizers (Everingham et al.,
%              IJCV 2010).
%   classesPascal - a cell array of ordered class names for PASCAL VOC
%
% Citations:
%   Blaschko, M. B. and A. Gretton: Learning Taxonomies by Dependence
%   Maximization. Neural Information Processing Systems (NIPS), 2008.
%
%   Blaschko, M. B., W. Zaremba, and A. Gretton: Taxonomic Prediction with
%   Tree-Structured Covariances. ECML/PKDD, 2013.

% download Oxford Flowers data if necessary
if(~exist('OxfordFlowers'))
    disp('Downloading Oxford Flowers data.');
    disp('If you wish, you may download this manually and comment out the following lines');
    system('chmod 755 ./downloadOxfordFlowers.sh');
    system('./downloadOxfordFlowers.sh');
end

% load Oxford Flowers kernel matrix
[K,Y,Vflower,classesFlower] = readOxfordFlowers();

% train a classifier with a tree-structured covariance matrix
% precomputed using the method of Blaschko & Gretton, NIPS 2008.
load OxfordFlowersCov
Bflower = Mtree;

trainind = randperm(size(K,1));
testind = trainind(round(size(K,1)*0.8)+1:end);
trainind = trainind(1:round(size(K,1)*0.8));

%MAIN FUNCTION FOR TRAINING TAXONOMIC PREDICTION WITH TREE STRUCTURED
%COVARIANCE MATRIX
% this is requiring a relatively small primal-dual gap at the moment, can
% make this looser to require fewer cutting plane iterations
[alpha,state]=covMulticlass(K(trainind,trainind),Y(trainind,:),Mtree);

% now evaluate the quality of the prediction
scores = K(testind,trainind)*alpha;
[pred,predind] = max(scores');
pred = zeros(size(scores));
pred(sub2ind(size(pred),1:length(predind),predind)) = 1; % pred is binary
                                                 % prediction matrix
accuracy = sum(sum(pred.*Y(testind,:)))./length(testind);

disp(sprintf('Accuracy of a random split on the Oxford Flowers dataset: %f',accuracy));

%PASCAL VOC precomputed tree-structured covariance matrix using the method
%of Blaschko & Gretton, NIPS 2008
load pascalVOCcov
Bpascal = Mtree;
%The taxonomy defined by the dataset organizers (Everingham et al, IJCV 2010).
Vpascal = pascalPartitionMat();
classesPascal={...
        'aeroplane'
        'bicycle'
        'bird'
        'boat'
        'bottle'
        'bus'
        'car'
        'cat'
        'chair'
        'cow'
        'diningtable'
        'dog'
        'horse'
        'motorbike'
        'person'
        'pottedplant'
        'sheep'
        'sofa'
        'train'
        'tvmonitor'};

end

% end of file
