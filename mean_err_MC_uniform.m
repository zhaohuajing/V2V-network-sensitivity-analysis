%Numerically calculate an unbiased estimator for the expected CMM error by Monte Carlo simulation 


function [nv,m_err]=mean_err_MC_uniform(sig_n2)
%load rand_angle.mat



% for N_v=15:15
%     N_v
% angle=2*pi*rand(1,10);
% angle=[4.18473579635023,4.76497989105900,1.87071752652456,3.01069347870357,1.92007770503973,1.26918034736393,2.85125031627114,0.214647648900359];
% for jj=1:60
%     for kk=1:60
%     jj
%     angle(11)=2*pi/60*jj;
%     angle(12)=2*pi/60*kk;
%     er(jj,kk)=square_error(angle,2,0.09);
%     end
% end
    
    
for jj=10:50
   % jj
    angle=rand(1,jj)*2*pi;
    %angle(9)=2*pi/60*jj;
    clearvars -except jj mm N_v mean_error angle sig_n2
for mm=1:100

    %mm
Np=1000;


%angle=(0:4*N_v-1)*pi/2;
%angle=rand(1,N_v)*2*pi;
%angle=[2.84054158477136,0.581356079534006,0.270717219775257,2.59491150573350,3.32870592904893,5.14107148506157,4.32780123945169,1.47165259096693,2.18578161834098,0.391802737491801];

%angle=2*pi/N_v*(0:N_v-1);
N=length(angle);
%N=8;
%large_noise=zeros(1,N);
% for k=1:N/4
%     large_noise(4*k-floor(4*rand(1)))=1;  %used to insert a large n-common error to the corresponding vehicles
% end
% if N_v>10
%     large_noise(11:end)=1;
% end

width=2;
unit_vector=[];
points=[];
for k=1:N
unit_vector=[unit_vector,[cos(angle(k));sin(angle(k))]];
points=[points,width*[cos(angle(k));sin(angle(k))]];
end

common=[0;0];
n_common=[];

%sig_n2=1;

for k=1:N    
n_common=[n_common,mvnrnd([0;0],(sig_n2)*[1,0;0,1])'];%+*large_noise(k)*(rand(2,1)-0.5)];
end



cor=(rand(2,Np)-0.5*ones(2,Np))*12;
% for k=1:Np
% cor(:,k)=mvnrnd([0;0],10*[1,0;0,1]);
% end

for k=1:Np;
    pf(:,k)=cor(:,k)+common;  %particle location
end

for k=1:Np
    weight(1,k)=1;
    for j=1:N
        d=pf(:,k)+n_common(:,j)-points(:,j);
        if dot(d,unit_vector(:,j))>0
            

             d2=dot(d,unit_vector(:,j));
             weight(1,k)=weight(1,k)*exp(-0.5/sig_n2*d2^2);
%   weight(1,k)=0;
%   break;   %here is no break!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

            
        end
    end
end

weight=weight/sum(weight);  %normilize the weight

common_cor(:,mm)=[0;0];
for k=1:Np
    common_cor(:,mm)=common_cor(:,mm)+weight(k)*cor(:,k);
end
            
er(mm)=norm(common_cor(:,mm)+common);
er2(mm)=er(mm)^2;
if isnan(er2(mm))&mm>1
    er2(mm)=mean(er2);
end
if isnan(er2(mm))&mm==1
    er2(mm)=10;
end
end
mean_error(jj-9)=mean(er2);
end

nv=10:50;
m_err=mean_error;
end
%corr(a.',b.','type','Spearman')
%common_cor(:,mm)+common


