function [y,e0_2,e1]=square_error(x,w,sigma_2,flag)   %x contains the set of angle within (0,2pi), w is the width of the roads
n=length(x);
if n<=2
    y=100; %assign a large error
    e0_2=50;
    e1=50;
    return;
end

x=sort(x);   %sort the angle in accending order
dif_angle=diff(x);
dif_angle(n)=x(1)-x(end)+2*pi;
for k=1:n
if dif_angle(k)>=pi   %the geometric center if not closed, error would be large, return a large error
    y=100;
    e0_2=50;
    e1=50;
    return;
end
end

angle_diff=diff(x);   %calculate the increment angle
angle_diff(n)=x(1)-x(end)+2*pi;

per_point=[w*cos(x);w*sin(x)];  % the perpendicular point of the road constraints

for k=1:n
    upper_point(:,k)=per_point(:,k)+w*tan(angle_diff(k)/2)*[-sin(x(k));cos(x(k))];
    if k>=2
    lower_point(:,k)=per_point(:,k)+w*tan(angle_diff(k-1)/2)*[sin(x(k));-cos(x(k))];
    else
    lower_point(:,k)=per_point(:,k)+w*tan(angle_diff(n)/2)*[sin(x(k));-cos(x(k))];
    end
    
    arc_length(k)=norm(upper_point(:,k)-lower_point(:,k));
    mid_point(:,k)=(upper_point(:,k)+lower_point(:,k))/2;
    gravity(:,k)=2/3*mid_point(:,k);
    area(k)=arc_length(k)*w/2;
    C(:,k)=mid_point(:,k)*arc_length(k);
end

total_area=sum(area);
total_gravity=[sum(gravity(1,:).*area);sum(gravity(2,:).*area)]/total_area;
e0_2=norm(total_gravity)^2;
e1=sigma_2*trace(C.'*C)/total_area^2;
y=e0_2+e1;
if flag==1
plot([upper_point(1,:),upper_point(1,1)],[upper_point(2,:),upper_point(2,1)])
grid on
end
%y=x(2)^2+x(3)^2+2*x(2)*x(3);
end



