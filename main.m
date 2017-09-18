% Calculate and plot the figures in.
% [1] Shen, Macheng, Ding Zhao, and Jing Sun. "The Impact of Road 
% Configuration in V2V-based Cooperative Localization: Mathematical 
% Analysis and Real-world Evaluation." arXiv preprint arXiv:1705.00568 (2017).
% those plot might seem different from those in the paper, mainly due to the 
% randomness of the empirical expectation calculated by MC method,in the paper
% each expected value is calculated with 10000 samples and 5000 particles,
% while this program only uses 100 samples and 1000 particles for efficiency

%% Add path of data and figure

data_path = './data_and_figure';
addpath(data_path)

%% Main
% Control parameter:
fsim=0; % fsim=1: run simulation to generate data; fsim=1: load data from file
fplot=1; %fplot=1: plot data
fsave=0; %fsave=1: save data to .mat file
fannarbor=0; %fannarbor=1: predict CMM error in ann arbor, require traffice flow data file

if fsim==1
    n=3:12;
    E_X=pi^2*0.09/12./log(n);
    [n_MC,E_MC]=MC_analytic(0.3);
    
    n4=10:50;
    E_X4=8/9./n4+1.5*0.09./n4;
    [n_MC4,E_MC4]=mean_err_MC_uniform(0.09);
    
    [n_ort,E_ort]=MC_analytic(1);
    [n_uni,E_uni]=mean_err_MC_uniform(1);
end

if fsim==0
    load predicted_error.mat;
end

if fplot==1
    
    figure
    hold on;
    plot(n*4,E_X,'b','LineWidth',1.5)
    plot(n_MC,E_MC,'y','LineWidth',1.5)
    legend('Asymptotic formula','Simulation using Eq. (12)')
    ylabel('Mean square error (m^2)')
    title('Fig. 3')
    
    figure
    hold on;
    plot(n4,E_X4,'b','LineWidth',1.5)
    plot(n_MC4,E_MC4,'y','LineWidth',1.5)
    legend('Asymptotic formula','Monte Carlo Simulation')
    ylabel('Mean square error (m^2)')
    title('Fig. 4')
    
    figure
    hold on;
    loglog(n_ort,E_ort,'b','LineWidth',1.5)
    loglog(n_MC,E_MC,'r','LineWidth',1.5)
    legend('Orthogonal road','Uniformly distributed random road')
    ylabel('Mean square estimation error (m^2)')
    title('Fig. 5')
    
    figure
    hold on;
    for k=10:2:20
        m=0;
        for i=1:10000
            angle=rand(1,k)*2*pi;
            temp=square_error(angle,2,0.5,0);
            if temp<5
                er(m+1)=temp;
                m=m+1;
            end
        end
        histogram(er);
    end
    xlabel('Mean square estimation error (m^2)')
    ylabel('Frequency')
    title('Fig. 6')
    legend('Number of vehicles=10','Number of vehicles=12','Number of vehicles=14','Number of vehicles=16','Number of vehicles=18','Number of vehicles=20')
    
    openfig('number of vehicle distribution.fig');
    figure
    A = imread('vehicle_density_two_day.png');
    image(A)
    
end

if fsave==1
    save('predicted_error.mat','n','E_X','n_MC','E_MC','n4','E_X4','n_MC4','E_MC4', ...
        'n_ort','E_ort','n_uni','E_uni');
end

if fannarbor==1
    CMM_evaluation(1);   %1-12 o'clock
    CMM_evaluation(2);   %13-24 o'clock
    CMM_evaluation(3);   %Monday-Sunday
    CMM_evaluation(4);   %January-December
end



