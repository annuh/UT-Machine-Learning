% updatesvd.m
%
% Jason Blevins <jrb11@duke.edu>
%
% $Id: updatesvd.m,v 1.4 2004/12/08 21:23:47 jrblevin Exp $
%
% Returns the revised SVD corresponding to the rank-one
% update U*S*V' + A*B'. Based on the method outlined in
% M. E. Brand, Incremental singular value decomposition of
% uncertain data with missing values, European Conference on
% Computer Vision (ECCV), 2350:707--720, 2002.
%
%------------------------------------------------------
% Usage example:
%
%  % Let X be some random data matrix and find its "economy
%  % size" SVD
%  X=randn(15,10);
%  [U,S,V]=svd(X,0);
% 
%  % Suppose we want to append a random row r' to X
%  r = randn(10,1);
% 
%  % First add a row of zeros to X (equivalently add a row of
%  % zeros to U).
%  U = [U; zeros(1,10)];
%  X0 = [X; zeros(1,10)];
%  % X0 will be equal to U*S*V'
%
%  % In this case, we want to find the SVD of
%  %[X; r'] = X0 + A*B' where
%  % A = (0,...,0,1)' and B = r
%  A = zeros(16,1); A(16,1) = 1;
%  B = r;
%
%  % Call the program like this, we want to find the SVD of
%  [U2,S2,V2,time] = updatesvd(U,S,V,A,B);
%
%  % Check the result, norm should be near machine epsilon
%  norm((X0 + A*B') - U2*S2*V2')
%------------------------------------------------------

function [U,S,V,time]=updatesvd(U,S,V,A,B);

[m_u, n_u] = size(U);
[m_s, n_s] = size(S);
[m_v, n_v] = size(V);
[m_a, n_a] = size(A);
[m_b, n_b] = size(B);

m = m_u;    % Number of rows in X=U*S*V'
n = m_v;    % Number of columns in X
r = n_u;    % Rank of the SVD we are given ( r = n_u = n_v )
c = n_a;    % Number of columns in A and B


%%% Step 1: Find components of A in terms of left singular vectors, U.

% We decompose A into two components: M = U'*A, the component of A in U and
% Ra, the component of A orthogonal to U.  We also find P, an orthogonal basis
% of Ra. We can find these via a QR decomposition.
%
% [U,A] = Q*R = [U,P] * [I, M; 0, Ra]
% 
% The dimensions are as follows:
% U = [m_u, n_u]
% A = [m_a, n_a]
%
% These steps come from Appendix A and Equation (1.1) in Brand

time = clock;

[Q,R] = qr([U,A]);

%Q,R

[m_q, n_q] = size(Q);
[m_r, n_r] = size(R);

% If Q and U have the same number of columns, A lies completely
% within U and there is no orthogonal component and thus we don't need
% a basis P.
%
% Otherwise, the first r = n_u columns of Q will be the same as U, and the
% remaining m_q - r columns will be the orthogonal basis P.

if (n_q == r)
    P = [];
    Ra = [];
    dimRa = 0;
else
    P = Q(:, r+1:n_q);
    Ra = R(r+1:m_r,  r+1:n_r);
    dimRa = m_r - r;
end

% I encounter round-off error when I use the result from the QR, why?
M = R(1:r, r+1:r+c);
%M = U'*A;

%%% Step 2: Find components of B in terms of right singular vectors, V.

% This step is very similar to step 1.  We find two components of V:
% N, the component of B in V and Rb, the component of B orthogonal to V.
% Then we find a basis Q for Ra.

[Q,R] = qr([V,B]);

[m_q, n_q] = size(Q);
[m_r, n_r] = size(R);

if (n_q == r)
    Q = [];
    Rb = [];
    dimRb = 0;
else
    Q = Q(:, r+1:n_q);  % Sorry for confusion, but yes, I have used Q for two
                        % different things. From now on, Q is the basis for Rb.
    Rb = R(r+1:m_r, r+1:n_r);
    dimRb = m_r - r;
end

% I encounter round-off error when I use the result from the QR, why?
%r,c
%N = R(1:r, r+1:r+c);
N = V'*B;


%%% Step 3: Construct the temporary new S and rediagonalize it

% Equation (1.4) in Brand
Saug = [M; Ra] * [N; Rb]';
S = [S, zeros(r, dimRb); zeros(dimRa, r), zeros(dimRa, dimRb)] + Saug;

% Now we rediagonalize via an SVD
[U2,S2,V2] = svd(S,0);

% And compute the new revised U, S, and V as in equation (1.5)
U = [U,P]*U2;
S = S2;
V = [V,Q]*V2;

time = etime(clock,time);
