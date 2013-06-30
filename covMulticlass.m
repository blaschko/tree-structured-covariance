function [alpha,state]=covMulticlass(K,Y,S,C,L,convergenceThreshold);
% Author: Matthew Blaschko - matthew.blaschko@inria.fr
% Copyright (c) 2012-2013
%    
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 3 of the License, or
% (at your option) any later version.
% 
% Written (W) 2012-2013 Matthew Blaschko
%
%
% [alpha,state]=covMulticlass(K,Y,S,C,L,convergenceThreshold)
%
% K - a kernel matrix over X, n by n s.p.d. matrix
% Y - a matrix over the outputs, n by k binary matrix.
%     Y(i,j)==1 iff sample i is a member of class j, 0 otherwise
% S - a covariance structure over the outputs, k by k s.p.d. matrix
% C - the C parameter in a structured output SVM
% L - the loss matrix, k by k matrix with 0 on the diagonal
%     performs slack rescaling
%
% Citation:
%   Blaschko, M. B., W. Zaremba, and A. Gretton: Taxonomic Prediction with
%   Tree-Structured Covariances. ECML/PKDD, 2013.

    if(nargin<3)
        S = eye(size(Y,2)); % standard multiclass prediction
    end
    
    if(nargin<4)
        C = 1;
    end

    if(nargin<5)
        L = 1-eye(size(S)); % 0-1 loss
        %L = repmat(diag(S)',[1,size(S,1)]) + repmat(diag(S),[size(S,1),1]) - 2*S; %taxonomic loss
    end
    
    if(nargin<6) % primal-dual gap guaranteed to be less than 0.1%
                 % of the optimal objective value.
        convergenceThreshold = 1e-3;
    end
    
    state = cuttingPlaneKron();
    state.lambda = 1/C;
    % set up rest of state to store K and S so we can do efficient Hessian
    % vector products in cuttingPlaneKron
    state.Kx = K;
    state.S = S;

    if(C>1)
        [tmp,state2] = covMulticlass(K,Y,S,C/10,L);
        for i=1:length(state2.b)
            state = cuttingPlaneKron(state,state2.a(:,i),state2.b(i));
        end
        clear tmp state2
    end
    
    minIterations = 10;
    iterationCounter = 0;
    
    phi = zeros(size(K,1)*size(S,1),1);
    b = 0;
    primalobjective = Inf;
    while((primalobjective - state.dualObjective)/state.dualObjective > ...
          convergenceThreshold || isinf(state.dualObjective) || ...
          iterationCounter<minIterations)
    %while(iterationCounter<300)
        iterationCounter = iterationCounter+1;
        state = cuttingPlaneKron(state,phi,b);
        [phi,b,Kalpha] = hierarchicalConstraint(state.alpha,K,Y,S,L);
        primalobjective = 0.5 * state.lambda * dot(state.alpha,Kalpha) ...
            + b - dot(state.alpha,vec(S*reshape(phi,[size(S,1) size(K,1)])*K));
        
        disp(sprintf(['it %d, primal objective: %f, dual objective: %f, gap: ' ...
                      '%f, num SV: %d'],iterationCounter,primalobjective, state.dualObjective, ...
                     (primalobjective - state.dualObjective)/state.dualObjective,length(state.b)));
    end

    alpha = S*reshape(state.alpha,[size(S,1) size(K,1)]);
    alpha = alpha';
end

function [phi,b,Kalpha] = hierarchicalConstraint(alpha,K,Y,S,L);
% find the maximally violated 1-slack constraint such that
% b - alpha^T kron(K,S) phi >= xi
% we perform slack rescaling
    
alpha = reshape(alpha,[size(S,1) size(K,1)]);
scores = S*alpha*K;
negInf = zeros(size(Y));
negInf(find(Y)) = -Inf;
[pred,predind] = max(scores+negInf');
pred = zeros(size(alpha')); %maybe have to transpose
pred(sub2ind(size(pred),1:length(predind),predind)) = 1; % pred is binary
                                                 % prediction matrix

% calculate minimum scoring positive label - simple multi-label extension
negInf = zeros(size(Y));
negInf(find(1-Y)) = -Inf;
[tmp,ind] = min(scores-negInf');
minY = zeros(size(Y));
minY(sub2ind(size(minY),1:length(ind),ind)) = 1;

% find margin violations
dY = minY-pred;
nu = sum(dY'.*scores)-1; % nu is vector of margins
nu = nu<0; % nu is binary indicator of margin violations


% do slack rescaling
losses = L(sub2ind(size(L),ind,predind));
nu = nu.*losses;

dY = spdiags(nu',0,length(nu),length(nu)) * dY;
phi = vec(dY');

b = sum(nu);

if(nargout>2)
    Kalpha = scores(:);
end

end


function state = cuttingPlaneKron(state, a, b, soft)
%
%   Sovles the problem
%
%    min_{alpha,xi} lambda/2 alpha^T kron(Kx,S) alpha + xi,  
%              s.t. xi >= b_t - alpha^T kron(Kx,S) a_t   for t = 1,..., T
%                   xi >= 0
%
%   Optionally, it also enforces additional hard constraints
%
%    alpha^T kron(Kx,S) a_p >= b_p,  p = 1, ..., P
%
%   The algorithm uses the dual to do so. Introducing Lagrange
%   multipliers alpha_i, beta_j:
%
%   Denote Kjoint = kron(Kx,S)
%
%   max_{beta>=0} min_beta \lambda/2 alpha^T Kjoint alpha
%                        + xi
%                        + sum_t beta_t (b_t - alpha^T Kjoint a_t - xi)
%                        + sum_p beta_p (b_p - alpha^T Kjoint a_p)
%
%   Minimizing w.r.t. xi yields the condition sum_t beta_t = 1 (if
%   the domain is restricted to xi >=0 in the beginning, then this
%   becomes sum_t beta_t <= 1). Then
%
%   w = 1/lambda sum_i beta_i a_i
%
%   where i spans both the indexes t of the soft constraints and p
%   of the hard constraints. Hence the dual problem is
%
%   max_{beta>=0}  1/lambda [ lambda sum_i beta_i b_i  - 1/2 beta' K beta]
%
%       s.t. sum_t beta_t <= 1
%
%   where K = A' Kjoint A, A = [... a_i ...] is the kernel matrix. Note that
%   the upper bound on the sum of betas involves only the soft
%   constraints, and this is the only way they are distinguished in
%   the dual.

opts.soft = true ;
if(nargin>3)
  opts.soft = soft;
end
opts.soft = double(opts.soft) ;

if nargin == 0
  state.lambda = 1 ;
  state.a = [] ;
  state.b = [] ;
  state.softVariables = [] ;
  state.dualVariables = [] ;
  state.dualAge = [] ;
  state.dualObjective = -inf ;
  state.K = [] ;
  state.f = [] ;
  state.beta = [] ;
  state.quadProgOpts = optimset('LargeScale', 'off', ...
                                'Display', 'off', ...
                                'MaxIter', 10000) ;
  return ;
end

dimension = size(state.beta,1) ;
numNewConstraints = size(a,2) ;
if isempty(state.a), state.a = zeros(dimension, 0) ; end

% add new constraints to the pool
state.dualVariables = [state.dualVariables ; zeros(numNewConstraints,1)] ;
state.softVariables = [state.softVariables ; opts.soft] ;
state.dualAge       = [state.dualAge ; 0] ;

% add missing part of kernel matrix
K11 = state.K ;

% Now we use the Kronecker trick to efficiently compute the dual
% Hessian with our special form of joint kernel matrix
%K12 = state.a'*kron(state.Kx,state.S)*a ; %inefficient version
Ka = vec(state.S*reshape(a,[size(state.S,1) size(state.Kx,1)])*state.Kx);
K12 = [];
if(prod(size(state.a))>0)
    K12 = state.a'*Ka;
end
%K22 = a'*kron(state.Kx,state.S)*a ;
K22 = a'*Ka;

state.K = [K11 K12 ; K12' K22] ;
state.f = [state.f ; state.lambda * b'] ;
state.a = [state.a, a] ;
state.b = [state.b, b] ;

% solve quad prog
[state.dualVariables, state.dualObjective] = ...
    quadprog(state.K, -state.f, ...
             state.softVariables', 1, ...
             [],[], ...
             zeros(length(state.dualVariables), 1), [], ...
             state.dualVariables, ...
             state.quadProgOpts) ;
state.dualObjective = - state.dualObjective / state.lambda ;

% remove idle variables
state.dualAge = state.dualAge + 1 ;
active = state.dualVariables > 1e-5 | ~state.softVariables ;
state.dualAge(active) = 0 ;
keep = state.dualAge < 20 ;

state.dualVariables = state.dualVariables(keep) ;
state.softVariables = state.softVariables(keep) ;
state.dualAge = state.dualAge(keep) ;
state.K = state.K(keep,keep) ;
state.f = state.f(keep) ;
state.a = state.a(:,keep) ;
state.b = state.b(keep) ;

% update the model
state.alpha = state.a * (state.dualVariables / state.lambda) ;

end

function a = vec(a);
    a = a(:);
end

% end of file
