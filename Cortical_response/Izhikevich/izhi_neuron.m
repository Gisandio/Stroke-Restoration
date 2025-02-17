function [Potencial, Corriente, Tiempo] = izhi_neuron(input,h,tf)
%con ruido agragado al input

a=0.02;
b=0.2;
c=-65;
d=8;
%S=[0.5*rand(Ne+Ni,Ne), -rand(Ne+Ni,Ni)];
v=-65;    % Initial values of v
u=b.*v;                 % Initial values of u
II=squeeze(input); % thalamic input es mas bajo!!!!!!!!!!!!!!!!!
h=h;
tf=tf;
Potencial=zeros(1,length(0:h:tf)-1);
Recuperacion=zeros(1,length(0:h:tf)-1);
Tiempo=zeros(1,length(0:h:tf)-1);
%Corriente=zeros(1,length(0:h:tf)-1);
x=0;
t=0;
    for t=0:(length(0:h:tf)-2)
        
        I=II(x+1);%+rand(1);

        k1 = V1(v, u, I);
        j1 = U1(v,u,a,b);
        k2 = V1(v + (h/2)*k1, u + (h/2)*j1,I);
        j2 = U1(v + (h/2)*k1, u + (h/2)*j1,a,b);
        k3 = V1(v + (h/2)*k2, u + (h/2)*j2,I);
        j3 = U1(v + (h/2)*k2, u + (h/2)*j2,a,b);
        k4 = V1(v + h*k3, u + h*j3,I);
        j4 = U1(v + h*k3, u + h*j3,a,b);

        v = v + (h/6)*(k1 + 2*k2 + 2*k3 + k4);
        u = u + (h/6)*(j1 + 2*j2 + 2*j3 + j4);
        t = t + h;
        if v >=30
            v  = c;
            u = u+d;
        end

        x=x+1;
        Potencial(x)=v;
        Recuperacion(x)=u;
        Tiempo(x)=(x-1)*h;
        Corriente(x)=I;
    end
end
