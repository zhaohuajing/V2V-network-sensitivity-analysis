%Numerically calculate an unbiased estimator for the expected CMM error at a crossroad by Monte Carlo simulation 
function [nv,m_err]=MC_analytic(sig)
for N_v_each=3:12;
% sig2=0.09;
% sig=sqrt(sig2);
for mm=1:5000
    X1=max(randn(1,N_v_each)*sig);
    X2=max(randn(1,N_v_each)*sig);
    X3=max(randn(1,N_v_each)*sig);
    X4=max(randn(1,N_v_each)*sig);
    er2(mm)=0.25*(X1-X3)^2+0.25*(X2-X4)^2;
end
mean_error(N_v_each-2)=mean(er2);
end

nv=4*(3:12);
m_err=mean_error;

end

% clear all
% 
% for N_v=10:50;
% sig2=0.09;
% sig=sqrt(sig2);
% 
% for mm=1:5000
%     N_each=ones(4,1);
%     for k=1:N_v-4    %to ensure at least have one vehicle on one side
%         a1=rand(1);
%         N_each(ceil(a1/0.25))=N_each(ceil(a1/0.25))+1;
%     end
%         
%         
%     X1=max(randn(1,N_each(1))*sig);
%     X2=max(randn(1,N_each(2))*sig);
%     X3=max(randn(1,N_each(3))*sig);
%     X4=max(randn(1,N_each(4))*sig);
%     er2(mm)=0.25*(X1-X3)^2+0.25*(X2-X4)^2;
% end
% mean_error(N_v-9)=mean(er2);
% end