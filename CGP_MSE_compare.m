function CGP_MSE_compare

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%      
% MATLAB version 
%     please use version R2019a or later
% Parameter & Options
%     1. Mode: ground true generation method
%     2. num_of_pre_sample: number of prediction samples
% Ground True Generation
%     Mode=1: generate ground true using CGP.
%     Mode=2: generate ground true using SVAR.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Parameter & Options
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Mode = 1;                   % ground true generation method
num_of_pre_sample = 100;    % number of prediction samples

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%% Do Not Change Anything Below This Line %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

rng(10)
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
    DataFilename = sprintf('CGPdata%ds.mat',1);
elseif CGP_Model
    DataFilename = sprintf('CGPdata%dc.mat',1);
end

% Define file path
DataFilePath = fullfile('CGP/',DataFilename);

LoadData = load(DataFilePath);
A = LoadData.A;
c = LoadData.c;
X = LoadData.X;
K = LoadData.K;
M = LoadData.M;
N = LoadData.N;
SNR = LoadData.SNR;

% generate x[K+1]
if SVAR_Model
    for k = K+1:K+num_of_pre_sample
        X(:,k) = 0;
        for i = 1:M
            X(:,k) = X(:,k) + A(:,:,i) * X(:,k-i);
        end
        % add noise to x[k]
%         X(:,k) = awgn(X(:,k), SNR, 'measured');
    end
elseif CGP_Model
    for k = K+1:K+num_of_pre_sample
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
%         X(:,k) = awgn(X(:,k), SNR, 'measured');
    end
end

X_true = X;

figure;
hold on
grid on

for order = 1:10
    
    % Define file name
    if SVAR_Model
        DataFilename = sprintf('CGPdata%ds.mat',order);
    elseif CGP_Model
        DataFilename = sprintf('CGPdata%dc.mat',order);
    end

    % Define file path
    DataFilePath = fullfile('CGP/',DataFilename);

    LoadData = load(DataFilePath);
    c_estimate = LoadData.c_estimate;
    X = LoadData.X;
    SNR = LoadData.SNR;
    R1 = LoadData.R1;
    
    NMSE = zeros(1,num_of_pre_sample);
    A_estimate = R1;
    X_est = X;
    X = X_true;
    
    for k = K+1:K+num_of_pre_sample
        c_index = 1;
        X_est(:,k) = 0;
        for i = 1:order
            % Compute PA = ci0*I
            PA = c_estimate(c_index) * eye(N);
            c_index = c_index + 1;
            % Compute PA = PA + ci1A^1 + ... + cijA^j
            for j = 1:i
                PA = PA + c_estimate(c_index) * A_estimate^j;
                c_index = c_index + 1;
            end
            % Compute x[k] = x[k] + (ci0*I + ci1A^1 + ... + cijA^j)*x[k-i]
            X_est(:,k) = X_est(:,k) + PA * X_est(:,k-i);
        end
        % add noise to x[k]
%         X_est(:,k) = awgn(X_est(:,k), SNR, 'measured');
    end

    for i = 1:num_of_pre_sample
        NMSE(i) = (1/N)*norm(X(:,K+i)-X_est(:,K+i),'fro');
    end
    
    if (order < 3)
        plot(101:100+num_of_pre_sample,NMSE,'LineWidth', 1.5,'LineStyle','--')
    elseif (order == 3)
        plot(101:100+num_of_pre_sample,NMSE,'LineWidth', 2)
    elseif (order < 6)
        plot(101:100+num_of_pre_sample,NMSE,'LineWidth', 2,'LineStyle',':')
    else
        plot(101:100+num_of_pre_sample,NMSE,'LineWidth', 1)
    end
  
end

xticks([101 110:10:100+num_of_pre_sample])
xlim([101 100+num_of_pre_sample])
if CGP_Model
    title({'CGP prediction error of x[k]', 'Ground true data generated from CGP model'},'FontSize',15,'Interpreter','latex')
    text(230,0.025,'\downarrow')
    text(226,0.0265,'M = 3')
else
    title({'CGP prediction error of x[k]', 'Ground true data generated from SVAR model'},'FontSize',15,'Interpreter','latex')
    text(230,0.015,'\uparrow')
    text(226,0.0135,'M = 3')
end
xlabel('k','FontSize',15)
ylabel('MSE','FontSize',15)
legend({'M = 1','M = 2','M = 3','M = 4','M = 5','M = 6','M = 7','M = 8','M = 9','M = 10'},'Location','northwest','FontSize',11)
hold off

end