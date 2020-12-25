function SVAR(M_est_in,Mode_in)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%      
% MATLAB version 
%     please use version R2019a or later
% Input arguments
%     1. M_est_in: the order of estimated model
%     2. Mode_in: ground true generation method
% Ground True Generation
%     Mode=1: generate ground true using CGP.
%     Mode=2: generate ground true using SVAR.
% Usage
%     This is a polymorphic function, which works for any combination of
%     input and output. 
%     Example of usage : 
%           SVAR(In1, In2)
%           SVAR([], In2)
%           SVAR
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Parameter & Options
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
M_est = 3;          % the order of estimated model
Mode = 1;           % ground true generation method
cvx_quiet(false);   % suppress cvx output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%% Do Not Change Anything Below This Line %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

rng(10)
% parameter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N = 35;             % the number of vertices
K = 100;            % the number of time series
M = 3;              % the order of ground true model
SNR = 25;           % singal to noise ratio
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% polymorphism
if nargin >= 1
    if ~isempty(M_est_in)
        M_est = M_est_in;
    end
end
if nargin >= 2
    if ~isempty(Mode_in)
        Mode = Mode_in;
    end
end

CGP_Model = false;
SVAR_Model = false;
if Mode == 1
   CGP_Model = true;
elseif Mode == 2
   SVAR_Model = true;
else
   error("Choose a Correct Mode")
end

% Define file name
if SVAR_Model
    DataFilename = sprintf('SVARdata%ds.mat',M_est);
elseif CGP_Model
    DataFilename = sprintf('SVARdata%dc.mat',M_est);
end

% Define file path
DataFilePath = fullfile('SVAR/',DataFilename);

% generate A
Q = orth(rand(N,N));
Lambda = diag(rand(1,N));
A = Q * Lambda * Q';

for i = 1:N
    for j = i+1:N
        if rand(1)*100 > 2
            A(i,j) = 0;
            A(j,i) = 0;
        else
            A(i,j) = 0.45+A(i,j);
            A(j,i) = A(i,j);
        end
    end
end

for i = 1:N
   A(i,i) = 0.1*A(i,i);
end

% generate c
c = [];
bound = 0.2;
for i = 1:M
    bound = bound - 1/(M+1);
    for j = 0:i
        c(end+1) = -bound + (bound + bound) * rand();
    end
end
c(1) = 0;
c(2) = 1;


% generate x[k]
X = zeros(N,K);
X(:,1:M) = rand(N,M);
if CGP_Model
    fprintf('Generating ground true data using CGP model\n')
    for k = M+1:K
        c_index = 1;
        for i = 1:M
            if k-i == 0 
                break;
            end
            % Compute PA = ci0*I
            PA = c(c_index) * eye(N);
            c_index = c_index + 1;
            % Compute PA = PA + ci1A^1 + ... + cijA^j
            for j = 1:i
                PA = PA + c(c_index) * A^j;
                c_index = c_index + 1;
            end
            % Compute x[k] = x[k] + (ci0*I + ci1A^1 + ... + cijA^j)*x[k-i]
            X(:,k) = X(:,k) + PA * X(:,k-i);
        end
        % add noise to x[k]
        X(:,k) = awgn(X(:,k), SNR, 'measured');
    end
elseif SVAR_Model
    fprintf('Generating ground true data using SVAR model\n')
    % declare A to be a tensor of adjacency matrices
    temp = A;
    A = zeros(N,N,M);
    for k = 1:M
        A(:,:,k) = temp;
        for i = 1:N
            for j = i+1:N
                if A(i,j,k) ~= 0
                   A(i,j,k) = A(i,j,k)/(1.5*randi(10,1));
                   A(j,i,k) = A(i,j,k);
                end
            end
        end
    end
    for k = M+1:K
        for i = 1:M
            if k-i == 0 
                break;
            end
            X(:,k) = X(:,k) + A(:,:,i) * X(:,k-i);
        end
        % add noise to x[k]
        X(:,k) = awgn(X(:,k), SNR, 'measured');
    end
end

% starting optimization
% CVX
% -------------------------------------------------------------------------
% parameter
lambda = 0.05;
        
cvx_begin 
        variable Ai(N,N,M_est)
        OBJ = 0;              % two norm square error
        REG = 0;              % regularization term

        % for square error term
        for k = M_est+1:K         % time series x[M] ~ x[K-1], K-M steps predictor
            temp = X(:,k);
            % for each Ri
            for j = 1:M_est
                    temp = temp - Ai(:,:,j)*X(:,k-j);
            end
            OBJ = OBJ + square_pos(norm(temp,2));
        end
        
        % for regularization
        for i = 1:N
            for j = 1:N
                REG = REG + norm(reshape(Ai(i,j,:),1,M_est),2);
            end
        end

        % minimum objective function
        minimize ((1/2)*OBJ + lambda*REG);

cvx_end
fprintf('cvx_status = ')
fprintf(cvx_status)
fprintf('\n')

% Reconstructing X
X_estimate = zeros(N,K);
X_estimate(:,1:M_est) = X(:,1:M_est);
for k = M_est+1:K
    for i = 1:M_est
        X_estimate(:,k) = X_estimate(:,k) + Ai(:,:,i) * X_estimate(:,k-i);
    end
end

save(DataFilePath,'A','Ai','X','X_estimate','c','N','K','M','M_est','SNR')

SVAR_plotgraph(M_est,Mode)

end