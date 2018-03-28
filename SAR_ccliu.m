function [adco,Energy_mean]=SAR_ccliu(N)
VREF=1;
len=2^15-8;
%N=14;%����N-bit���Ȼ���Ϊ��������
LSB=2*VREF/2^N;
LSB=round(LSB*10^N)/10^N;
fs=100;  % frequency of sampling clock, in Mhz   
fin=fs*(0.125*len-17)/len;
Vref=1;%�趨vref=2v,�ڴ�Ϊ����1v��������ֲ�����-1-1v��
ground=0;
Vcm=1;%��ģ��ѹ����Ϊ��Դ��ѹ��һ��
sig_c=0.002;%���嵥λ���ݵı�׼ƫ��Ϊ��ʹ�ɵ���ʧ�������������LSB/2����c/C�����㣺��c/C<1/2^(N+1)/2������14λ���ȵ��������׼ƫ��< 1/181.02
C_norp=[];
for r=1:N-1;
    C_norp=[C_norp, 2^(N-1-r)];
end
C_norp=[C_norp, 1];
C_norn=C_norp;
C_devp=sig_c*C_norp.*randn(1,N);%���������и����ݵı�׼ƫ��
C_devn=sig_c*C_norn.*randn(1,N);%���������и����ݵı�׼ƫ��
Cp=C_norp+C_devp;%����ʵ�ʵ��������ֵ�ͱ�׼ƫ�����
Cn=C_norn+C_devn;%����ʵ�ʵ��������ֵ�ͱ�׼ƫ�����
Cp_tot=sum(Cp);%�������е��ܵ���
Cn_tot=sum(Cn);%�������е��ܵ���
adco=[];
E=[];
for t=(0:len-1)*(1/fs)
A=zeros(1,N);
Vin=VREF*sin(2*pi*fin*t);
Vinp=Vcm+0.5*Vin;
Vinn=Vcm-0.5*Vin;
Qp=Cp_tot*(Vref-Vinp);%��·��ʼ״̬������غ㷽�����
Qn=Cn_tot*(Vref-Vinn);
Ft=ones(N,1);%���嶥���������Ƶ��ݿ��صľ���,��ʼ��������ȫ��Vref
Fb=ones(N,1);%����ײ��������Ƶ��ݿ��صľ���,��ʼ��������ȫ��Vref
Vxp=Vinp;%�Ͽ�����,����Ҫ���κε��ݣ����ɱȽ�MSB��ԭ�����ڴ�ʱVxp=Vinp
Vxn=Vinn;
Energy=0;%��һ�ε���������Ϊ��
old_Ft=Ft;
old_Fb=Fb;
if Vxp >= Vxn
    A(1)=1;
    Ft(1)=0;
else
    A(1)=0;
    Fb(1)=0;
end
new_Vxp=(Cp*Ft*Vref-Cp_tot*Vref+Cp_tot*Vinp)/Cp_tot;%�������ݵĽ⣬�򻯳���
new_Vxn=(Cn*Fb*Vref-Cn_tot*Vref+Cn_tot*Vinn)/Cn_tot;
Energy=Energy + Cp*(abs((new_Vxp*ones(N,1)-Ft*Vref)-(Vxp*ones(N,1)-old_Ft*Vref)).^2) + Cn*(abs((new_Vxn*ones(N,1)-Fb*Vref)-(Vxn*ones(N,1)-old_Fb*Vref)).^2);
%���ݿ�����̬���㹦��
for i=1:N-1
    Vxp=(Cp*Ft*Vref-Cp_tot*Vref+Cp_tot*Vinp)/Cp_tot;%�������ݵĽ⣬�򻯳���
    Vxn=(Cn*Fb*Vref-Cn_tot*Vref+Cn_tot*Vinn)/Cn_tot;
    old_Ft=Ft;
    old_Fb=Fb;
    if Vxp >= Vxn
        if i==N-1
            A(i+1)=1;
        else
            A(i+1)=1;
            Ft(i+1)=0;
        end
    else
         if i==N-1
            A(i+1)=0;
        else
            A(i+1)=0;
            Fb(i+1)=0;
        end
    end
    new_Vxp=(Cp*Ft*Vref-Cp_tot*Vref+Cp_tot*Vinp)/Cp_tot;%�������ݵĽ⣬�򻯳���
    new_Vxn=(Cn*Fb*Vref-Cn_tot*Vref+Cn_tot*Vinn)/Cn_tot;
    if i<N-1
    Energy=Energy + Cp*(abs((new_Vxp*ones(N,1)-Ft*Vref)-(Vxp*ones(N,1)-old_Ft*Vref)).^2) + Cn*(abs((new_Vxn*ones(N,1)-Fb*Vref)-(Vxn*ones(N,1)-old_Fb*Vref)).^2);
    end
    %���ݿ�����̬���㹦��
end
E=[E;Energy];
adco=[adco;A];
end
Energy_mean=sum(E)/length(E);