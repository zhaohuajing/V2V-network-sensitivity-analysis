function CMM_evaluation(flag)
clearvars -except record_all outer_loop flag
if flag==1
load hour_1_12_365day.mat;   %here the hour x maps to the true clock hour x-6
tunit=tunit1_12;
end
if flag==2
load hour_13_24_365day.mat;
tunit=tunit13_24;
end
if flag==3
load weekday_0_365.mat;
end
if flag==4
load month_0_365.mat;
end

for loop=1:12
    loop
angle=tunit(loop).angle;
Numb_rec=tunit(loop).Numb_rec;
clearvars -except angle Numb_rec tunit tunit13_24 tunit1_12 loop mean_sq_error outer_loop record_all
long_min=-83.8074;
long_range=-83.6701+83.8074;
lat_min=42.2197;
lat_range=42.3279-42.2197;
x_range=long_range/180*pi*6400000*cos(lat_min/180*pi);
y_range=lat_range/180*pi*6400000;
total_sample=sum(sum(Numb_rec));
%N_v=500;  %assume 500 connected vehicles in the whole Ann Arbor area
N_v=round(sum(sum(Numb_rec))/30/24/(3600/0.27)*20*30);      %0.27 is the average sampling rate and 20 is the desampling factor of data
%30 is assuming the percentage of equipment is ~3%
sigma_2=0.5;   %non-common error covariance

del_x=x_range/2000;
del_y=y_range/2000;
range_window=1609;   %communication range=1 mile 
x_rel=200;
y_rel=200;   %grid size of the error reduction map
x_numb=floor(x_range/x_rel);
y_numb=floor(y_range/x_rel);

n_nonzero=length(nonzeros(Numb_rec));
nonzero_index=zeros(n_nonzero,3);   %first allocate the nonzero terms
pointer=1;
for i=1:2000
    for j=1:2000
        if Numb_rec(i,j)~=0
         nonzero_index(pointer,:)=[i,j,Numb_rec(i,j)];
         pointer=pointer+1;
        end
    end
end
if pointer~=n_nonzero+1
    'Warning: error'
end

nonzero_index(1,4)=nonzero_index(1,3);
for i=2:n_nonzero
    nonzero_index(i,4)=nonzero_index(i-1,4)+nonzero_index(i,3);
end

vehicle=zeros(N_v,3);   %store the vehicle index (long,lat)
for k=1:N_v
    rand_num=rand*total_sample;
    row_index=sum(nonzero_index(:,4)<rand_num)+1; %return the row index of the sampled region
    vehicle(k,1:2)=nonzero_index(row_index,1:2);
    angle_pool=angle{nonzero_index(row_index,1),nonzero_index(row_index,2)};
    if length(angle_pool(1,:))==1
        vehicle(k,3)=mod(angle_pool(1,1),360)/180*pi;    %normalize the angle to [0,360)
    else
        
    for j=1:length(angle_pool(1,:))
        angle_pool(3,j)=sum(angle_pool(2,1:j));
        rand_num=rand*angle_pool(3,end);
        column_index=sum(angle_pool(3,:)<rand_num)+1;
        vehicle(k,3)=mod(angle_pool(1,column_index),360)/180*pi;   %normalize the angle to [0,360)
    end
    end
end

vehicle(:,1)=vehicle(:,1)*del_x;
vehicle(:,2)=vehicle(:,2)*del_y;  %convert the index to coordinate
loc_error=zeros(x_numb,y_numb);    %record the regional localization error
for i=1:x_numb
   % i
    for j=1:y_numb
        R=sqrt((vehicle(:,1)-i*x_rel).^2+(vehicle(:,2)-j*y_rel).^2);
        Veh_angle=[];
        for k=1:N_v
            if R(k)<=range_window
                Veh_angle=[Veh_angle,vehicle(k,3)];
            end
        end
        if length(Veh_angle)<=2
            loc_error(i,j)=100;
        else
            loc_error(i,j)=square_error(Veh_angle,2,sigma_2,0);
        end
    end
end
   
sq_error=sqrt(loc_error);
[coarse_x,coarse_y]=meshgrid((1:y_numb)*y_rel,(1:x_numb)*x_rel);
[fine_x,fine_y]=meshgrid((1:10*y_numb)*y_rel/10,(1:10*x_numb)*x_rel/10);
sq_error=interp2(coarse_x,coarse_y,sq_error,fine_x,fine_y);
sq_error=sq_error.*(sq_error<3)-(sq_error>=3);
%filtered_sq=imgaussfilt(sq_error);




imagesc('XData',(1:10*x_numb)*x_rel/10,'YData',(1:10*y_numb)*y_rel/10,'CData',sq_error.')  %here variable row of sq is the variation alone y and variable column of sq is variation alone x
colormap(hsv(256));

[cmin,cmax] = caxis;
caxis([0,cmax]);
map = colormap;
map(1,:) = [0 0 0];
map(2:170,:)=map(170:-1:2,:);
for k=171:256
    map(k,:)=map(170,:);
end
colormap(map);
        
hold on
plot(nonzero_index(:,1)*del_x,nonzero_index(:,2)*del_y,'w.', 'markersize', 0.1)
axis([0,x_range,0,y_range])
xlabel('East-West (meters)')
ylabel('North-South (meters)')



true_hour=loop+12-6;
if true_hour<1
   true_hour=true_hour+24;
end
if true_hour<=11
    morn_after='AM';
else
    morn_after='PM';
end


title(['$$\sqrt{\bar{e^2}}$$ in Ann Arbor (meters)',num2str(true_hour),morn_after],'interpreter','latex')



name=[num2str(true_hour),'_hour.png'];

saveas(gcf,name);
clf;

mean_sq_error(loop)=sum(sum((sq_error>0).*(sq_error<=3).*sq_error))/sum(sum((sq_error>0).*(sq_error<=3)));

mean_sq_error(loop)=0;
n_mean=0;
%calculate spatial mean
for i=size(sq_error,1)
    for j=1:size(sq_error,2)
        if sq_error(i,j)>0&sq_error(i,j)<=3
            mean_sq_error(loop)=(mean_sq_error(loop)*n_mean+sq_error(i,j))/(n_mean+1);
            n_mean=n_mean+1;
        end
    end
end

end  %end the first for loop


% mean_sq_error
% record_all=[record_all;mean_sq_error];

%end  %end for outer_loop


%plot results

% clear x y
% x=0:24;
% x=[x,24:-1:0];
% y=sqrt(ave)-sqrt(variance);
% for k=1:25
%     y=[y,sqrt(ave(26-k))+sqrt(variance(26-k))];
% end
% fill(x,y,'g')
% hold on
% plot(0:24,sqrt(ave));
