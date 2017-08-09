%process the data

clear all
N_day=1;  %number of days 
t_perhour=10^6*3600;
t_perday=10^6*3600*24;
t_perweek=10^6*3600*24*7;
t_permonth=10^6*3600*24*30;

lat_min=42.2196;
lat_range=42.3280-42.2196;
long_min=-83.8075;
long_range=-83.6700+83.8075;
N=2000;
resol_lat=lat_range/N;
resol_long=long_range/N;
for k=1:24
    tunit(k).Numb_rec=zeros(N,N);
    tunit(k).angle=cell(N);
end
% Numb_rec=cell(24,1);
% angle=cell(24,1);   
% for k=1:24
%     angle{k}=cell(N);  %each angle{k} is a NbyN cell
%     Numb_rec{k}=zeros(N,N);  %delete when the second run
% end
angle_tol=10;   %tolerance of heading angle difference, if dif_angle<=angle_tol, then do averaging


for n_d=1:N_day
    n_d
    clear TLLH
    file_name=['day',num2str(n_d-1),'.mat'];
    load(file_name);
    
  lat=TLLH(:,2);
  long=TLLH(:,3);
  head=TLLH(:,4);
  n=length(lat);
    
    for k=1:length(TLLH)
        if mod(k,10000)==0
            k
        end
        %partition data according to hours
        hour=floor(mod(TLLH(k,1),t_perday)/3600000000);
        if hour==24
            hour=23;
        end
        hour=hour+1;   %hour=1~24
        
        
    j=ceil((lat(k)-lat_min)/resol_lat);
    i=ceil((long(k)-long_min)/resol_long);  %map x along the longitude direction
    tunit(hour).Numb_rec(i,j)=tunit(hour).Numb_rec(i,j)+1;
    if size(tunit(hour).angle{i,j})==[0,0]
        tunit(hour).angle{i,j}=head(k);
        tunit(hour).angle{i,j}(2,1)=1;    %angle(2,:) record the number of the angles used for averaging
    else
        dif=tunit(hour).angle{i,j}(1,:)-head(k);
        indicator=0;
        for m=1:length(dif)
            dif(m)=abs(minimizedAngle(dif(m)));   %round the angle into [0,360)
            if dif(m)<=angle_tol
                indicator=1;
                break;
            end
        end
        if indicator==0
            tunit(hour).angle{i,j}=[tunit(hour).angle{i,j},[head(k);1]];
        else %(indicator==1,average the head(k) with the angle{i,j}(1,m))
            anglem1=tunit(hour).angle{i,j}(1,m);
            anglem2=tunit(hour).angle{i,j}(2,m);
            avg_sin=sin(anglem1/180*pi)*anglem2+sin(head(k)/180*pi);
            avg_sin=avg_sin/(anglem2+1);
            avg_cos=cos(anglem1/180*pi)*anglem2+cos(head(k)/180*pi);
            avg_cos=avg_cos/(anglem2+1);
            tunit(hour).angle{i,j}(1,m)=atan2(avg_sin,avg_cos)/pi*180;
            tunit(hour).angle{i,j}(2,m)=anglem2+1;
            if tunit(hour).angle{i,j}(1,m)<0
               tunit(hour).angle{i,j}(1,m)=anglem1+360;
            end
        end
    end
    end
    
end %loop over the days
        
        