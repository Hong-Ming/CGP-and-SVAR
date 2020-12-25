function SVAR_prediction(M_est_in,Mode_in)

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
%           SVAR_prediction(In1, In2)
%           SVAR_prediction([], In2)
%           SVAR_prediction
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Parameter & Options
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
M_est = 3;          % the order of estimated model
Mode = 1;           % ground true generation method
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%% Do Not Change Anything Below This Line %%%%%%%%%%%%%%%%%%%
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

LoadData = load(DataFilePath);
A = LoadData.A;
Ai = LoadData.Ai;
X = LoadData.X;
X_estimate = LoadData.X_estimate;
K = LoadData.K;
M = LoadData.M;
N = LoadData.N;
c = LoadData.c;
SNR = LoadData.SNR;

% parameter
num_of_prediction_sample = 100;
NMSE = zeros(1,100);
X_est = X_estimate;

% generate x[K+1]
if SVAR_Model
    for k = K+1:K+num_of_prediction_sample
        X(:,k) = 0;
        for i = 1:M
            X(:,k) = X(:,k) + A(:,:,i) * X(:,k-i);
        end
        % add noise to x[k]
        X(:,k) = awgn(X(:,k), SNR, 'measured');
    end
elseif CGP_Model
    for k = K+1:K+num_of_prediction_sample
        c_index = 1;
        X(:,k) = 0;
        for i = 1:M
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
end

% generate x_estimate[K+1]
for k = K+1:K+num_of_prediction_sample
    X_est(:,k) = 0;
    for i = 1:M_est
        X_est(:,k) = X_est(:,k) + Ai(:,:,i)*X_est(:,k-i);
    end
end

for i = 1:100+num_of_prediction_sample
    NMSE(i) = (1/N)*norm(X(:,i)-X_est(:,i),'fro');
end

plot(1:200,NMSE,'LineWidth',2)
grid on
xticks([101 110:10:200])
xlim([101 200])
% title('Prediction error of x[k] with $\widehat A^{(1)}$, $\widehat A^{(2)}$ and $\widehat A^{(3)}$','FontSize',15,'Interpreter','latex')
title('MSE error of x[k] using SVAR','FontSize',15,'Interpreter','latex')
xlabel('k','FontSize',15)
ylabel('MSE','FontSize',15)

top = max(max(max(X)),max(max(X_est)));
botton = min(min(min(X)),min(min(X_est)));
figure;
imagesc(X);
title('X','FontSize',15)
colorbar
caxis([botton top])

figure;
imagesc(X_est);
title('$\widehat X$','Interpreter','latex','FontSize',15)
xlabel({['M = ' num2str(M_est)]})
colorbar
caxis([botton top])

figure;
plot(1:K+100,X(1,:),1:K+100,X_est(1,:),'LineWidth',2)
title('Side view of ground ture and estimated data','FontSize',15)
legend({'Ground True','Estimated'},'FontSize',15,'Location','northwest')
xlabel(['M = ' num2str(M_est)])

end