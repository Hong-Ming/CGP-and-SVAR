function CGP_plotgraph(M_est_in,Mode_in)

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
%           CGP(In1, In2)
%           CGP([], In2)
%           CGP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Parameter & Options
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
M_est = 3;         % the order of estimated model
Mode = 1;          % ground true generation method
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
    DataFilename = sprintf('CGPdata%ds.mat',M_est);
elseif CGP_Model
    DataFilename = sprintf('CGPdata%dc.mat',M_est);
end

% Define file path
DataFilePath = fullfile('CGP/',DataFilename);

LoadData = load(DataFilePath);
A = LoadData.A;
A_estimate = LoadData.A_estimate;
X = LoadData.X;
X_estimate = LoadData.X_estimate;
K = LoadData.K;
M = LoadData.M;
N = LoadData.N;
SNR = LoadData.SNR;
R1 = LoadData.R1;

% plot graph
% define threshold
if SVAR_Model
    Threshold = 0.05*max(max(abs(A_estimate)));
elseif CGP_Model
    Threshold = 0.2*max(max(abs(A_estimate)));
end

% eliminate round-off error
A_estimate_temp = A_estimate;
A_estimate_temp(A_estimate_temp < Threshold) = 0;

% define graph edges and nodes
Graph_A = graph(A(:,:,1).*(ones(size(A(:,:,1)))-eye(size(A(:,:,1)))));
Graph_A_estimate = graph(A_estimate_temp.*(ones(size(A(:,:,1)))-eye(size(A(:,:,1)))),'upper');

% plot graph
top = max(max(max(A(:,:,1))), max(max(A_estimate)));
botton = min(min(min(A(:,:,1))), min(min(A_estimate)));

figure;
g1 = plot(Graph_A,'Layout','circle');
title('Graph Representation of A','FontSize',15','Interpreter','latex');
xlabel({['[N K] = [' num2str(N) ' ' num2str(K) ']   M = ' num2str(M) '   SNR = ' num2str(SNR) 'dB' ...
    '   Threshold = ' num2str(Threshold,2)]},'FontSize',14')
g1.EdgeCData = nonzeros(triu(A(:,:,1),1));
g1.LineWidth = 3;
colorbar
caxis([botton top])

figure;
g2 = plot(Graph_A_estimate,'Layout','circle');
g2.EdgeCData = nonzeros(triu(A_estimate_temp,1));
g2.LineWidth = 3;
title('Graph Representation of $\widehat A$','FontSize',15,'Interpreter','latex');
xlabel({['[N K] = [' num2str(N) ' ' num2str(K) ']   M'' = ' num2str(M_est) '   SNR = ' num2str(SNR) 'dB' ...
    '   Threshold = ' num2str(Threshold,2)]},'FontSize',14')
colorbar
caxis([botton top])

% plot matrix  

if SVAR_Model
    for i = 1:M
        figure;
        imagesc(A(:,:,i));
        title(['A^{(' num2str(i) ')}'],'FontSize',15)
        xlabel({['[N K] = [' num2str(N) ' ' num2str(K) ']   M = ' num2str(M) '   SNR = ' num2str(SNR) 'dB']},'FontSize',14')
        colorbar
        caxis([botton top])
    end
else
    figure;
    imagesc(A);
    title('A','FontSize',15)
    xlabel({['[N K] = [' num2str(N) ' ' num2str(K) ']   M = ' num2str(M) '   SNR = ' num2str(SNR) 'dB']},'FontSize',14')
    colorbar
    caxis([botton top])
end

figure;
imagesc(R1);
title('$\widehat R_1$','FontSize',15,'Interpreter','latex')
xlabel({['[N K] = [' num2str(N) ' ' num2str(K) ']   M'' = ' num2str(M_est) '   SNR = ' num2str(SNR) 'dB']},'FontSize',14')
colorbar
caxis([botton top])

figure;
imagesc(A_estimate);
title('$\widehat A$','FontSize',15,'Interpreter','latex')
xlabel({['[N K] = [' num2str(N) ' ' num2str(K) ']   M'' = ' num2str(M_est) '   SNR = ' num2str(SNR) 'dB']},'FontSize',14')
colorbar
caxis([botton top])

top = max(max(max(X)), max(max(X_estimate)));
botton = min(min(min(X)), min(min(X_estimate)));

if SVAR_Model
    figure;
    imagesc(X);
    title('X_S','FontSize',15)
    xlabel({['[N K] = [' num2str(N) ' ' num2str(K) ']   M = ' num2str(M) '   SNR = ' num2str(SNR) 'dB']},'FontSize',14')
    colorbar
    caxis([botton top])
    figure;
    imagesc(X_estimate);
    title('$\widehat X$','FontSize',15,'Interpreter','latex')
    xlabel({['[N K] = [' num2str(N) ' ' num2str(K) ']   M'' = ' num2str(M_est) '   SNR = ' num2str(SNR) 'dB']},'FontSize',14')
    colorbar
    caxis([botton top])
else
    figure;
    imagesc(X);
    title('X','FontSize',15)
    xlabel({['[N K] = [' num2str(N) ' ' num2str(K) ']   M = ' num2str(M) '   SNR = ' num2str(SNR) 'dB']},'FontSize',14')
    colorbar
    caxis([botton top])
    figure;
    imagesc(X_estimate);
    title('$\widehat X$','FontSize',15,'Interpreter','latex')
    xlabel({['[N K] = [' num2str(N) ' ' num2str(K) ']   M'' = ' num2str(M_est) '   SNR = ' num2str(SNR) 'dB']},'FontSize',14')
    colorbar
    caxis([botton top])
end



end