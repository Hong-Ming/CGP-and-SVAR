function SVAR_plotgraph(M_est_in,Mode_in)

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
%           SVAR_plotgraph(In1, In2)
%           SVAR_plotgraph([], In2)
%           SVAR_plotgraph
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Parameter & Options
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
M_est = 1;          % the order of estimated model
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
SNR = LoadData.SNR;

A_est = zeros(N,N);
epsilon = 0.045;

% plot graph
top = max(max(max(A(:,:,1))), max(max(Ai(:,:,1))));
botton = min(min(min(A(:,:,1))), min(min(Ai(:,:,1))));

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
    for i = 1:N
        for j = 1:N
            if A(i,j,1) ~= 0
                A(i,j,1) = 1;
            end
        end
    end
    figure;
    imagesc(A(:,:,1));
    title('A','FontSize',15)
    xlabel({['[N K] = [' num2str(N) ' ' num2str(K) ']   M = ' num2str(M) '   SNR = ' num2str(SNR) 'dB']},'FontSize',14')
    colorbar
else
    figure;
    imagesc(A);
    title('A','FontSize',15)
    xlabel({['[N K] = [' num2str(N) ' ' num2str(K) ']   M = ' num2str(M) '   SNR = ' num2str(SNR) 'dB']},'FontSize',14')
    colorbar
    caxis([botton top])
end

for i = 1:M_est
    figure;
    imagesc(Ai(:,:,i));
    title(['$\widehat A^{(' num2str(i) ')}$'],'FontSize',15,'Interpreter','latex')
    xlabel({['[N K] = [' num2str(N) ' ' num2str(K) ']   M = ' num2str(M_est) '   SNR = ' num2str(SNR) 'dB']},'FontSize',14')
    colorbar
    caxis([botton top]) 
end

for i = 1:N
    for j = 1:N
        for k = 1:M_est
           if Ai(i,j,k) < epsilon
              break; 
           end
             A_est(i,j) = 1;
        end
    end
end
figure;
imagesc(A_est);
title('$\widehat A$','FontSize',15,'Interpreter','latex')
xlabel({['[N K] = [' num2str(N) ' ' num2str(K) ']   M'' = ' num2str(M_est) '   SNR = ' num2str(SNR) 'dB' '   \epsilon = ' num2str(epsilon)]},'FontSize',14')
colorbar

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
title('$\widehat X_S$','FontSize',15,'Interpreter','latex')
xlabel({['[N K] = [' num2str(N) ' ' num2str(K) ']   M'' = ' num2str(M_est) '   SNR = ' num2str(SNR) 'dB']},'FontSize',14')
colorbar
caxis([botton top])
else
figure;
imagesc(X);
title('X_C','FontSize',15)
xlabel({['[N K] = [' num2str(N) ' ' num2str(K) ']   M = ' num2str(M) '   SNR = ' num2str(SNR) 'dB']},'FontSize',14')
colorbar
caxis([botton top])

figure;
imagesc(X_estimate);
title('$\widehat X_C$','FontSize',15,'Interpreter','latex')
xlabel({['[N K] = [' num2str(N) ' ' num2str(K) ']   M'' = ' num2str(M_est) '   SNR = ' num2str(SNR) 'dB']},'FontSize',14')
colorbar
caxis([botton top])
end

Graph_A = graph(A(:,:,1).*(ones(size(A(:,:,1)))-eye(size(A(:,:,1)))),'upper');
Graph_A_est = graph(A_est.*(ones(size(A_est))-eye(size(A_est))),'upper');

figure;
g1 = plot(Graph_A,'Layout','circle');
title('Graph Representation of A','FontSize',15','Interpreter','latex');
xlabel({['[N K] = [' num2str(N) ' ' num2str(K) ']   M = ' num2str(M) '   SNR = ' num2str(SNR) 'dB']},'FontSize',14')
g1.EdgeCData = nonzeros(triu(A(:,:,1),1));
g1.LineWidth = 3;
colorbar


figure;
g1 = plot(Graph_A_est,'Layout','circle');
title('Graph Representation of $\widehat A$','FontSize',15','Interpreter','latex');
xlabel({['[N K] = [' num2str(N) ' ' num2str(K) ']   M'' = ' num2str(M) '   SNR = ' num2str(SNR) 'dB' ...
     '   \epsilon = ' num2str(epsilon)]},'FontSize',14')
g1.EdgeCData = nonzeros(triu(A_est,1));
g1.LineWidth = 3;
colorbar



end