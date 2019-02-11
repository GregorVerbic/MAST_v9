function DCpowerflow(hObject,eventdata)
[Data mpc]=power_flow('Result.mat');

temp=find(sum(Data.RH.Sol.Gen.Power,1)>0);
mpopt = mpoption('verbose',0,'out.all',0);
RR=[];
 
for hh=temp
    mpc_temp=mpc;
    fprintf('solving for hour %4d\n',hh)
    % setting demand for the hour
    mpc_temp.bus(:,3)=[Data.RH.Bus.csmDemand(:,hh)+Data.RH.Bus.psmDemand(:,hh)]';
    mpc_temp.bus(:,4)=mpc_temp.bus(:,3).*tan(acos(Data.Bus.Power_Factor));    
    % finding largest infeed and making it slack
    temp1=find((Data.Gen.Max_Real_Power.*Data.RH.Sol.Gen.Status(:,hh))==max((Data.Gen.Max_Real_Power.*Data.RH.Sol.Gen.Status(:,hh))));
    gg=0;
    if length(temp1)>1
        temp2=find(min(Pg(temp1))==Pg);
        if length(temp2)>1
            gg=temp2(1);
        else
            gg=temp2;
        end
    else
        gg=temp1;
    end
    mpc_temp.bus(find(strcmp(Data.Bus.Name,Data.Gen.Bus(gg))),2)=3;

    % setting generation limits
    st=1;
    Pg=zeros(sum(Data.Gen.N_units),1);
    Status=zeros(sum(Data.Gen.N_units),1);
    Qg_max=zeros(sum(Data.Gen.N_units),1);
    Qg_min=zeros(sum(Data.Gen.N_units),1);
    for gg=1:length(Data.Gen.N_units)
        ed=st+Data.Gen.N_units(gg)-1;
        Status(st:st+Data.RH.Sol.Gen.Status(gg,hh)-1)=1;
        Pg(st:st+Data.RH.Sol.Gen.Status(gg,hh)-1)=Data.RH.Sol.Gen.Power(gg,hh)/Data.RH.Sol.Gen.Status(gg,hh);
        if Data.Gen.Type==2
           Qg_max(st:st+Data.RH.Sol.Gen.Status(gg,hh)-1)=...
               Data.Gen.Max_Reactive_Power(gg)*(Data.Gen.Trace.Type2(gg,hh)./Data.Gen.Power_Rating(gg));
               Data.Gen.Min_Reactive_Power(gg)*(Data.Gen.Trace.Type2(gg,hh)./Data.Gen.Power_Rating(gg));
        else
           Qg_max(st:st+Data.RH.Sol.Gen.Status(gg,hh)-1)=Data.Gen.Max_Reactive_Power(gg);
           Qg_min(st:st+Data.RH.Sol.Gen.Status(gg,hh)-1)=Data.Gen.Min_Reactive_Power(gg);
        end         
        st=ed+1;
    end
    mpc_temp.gen(1:sum(Data.Gen.N_units),2)=Pg;
    mpc_temp.gen(1:sum(Data.Gen.N_units),4)=Qg_max;
    mpc_temp.gen(1:sum(Data.Gen.N_units),5)=Qg_min;
    mpc_temp.gen(1:sum(Data.Gen.N_units),8)=Status;
    clearvars Status Pg gg st ed
    
    result=rundcpf(mpc_temp,mpopt);
    
    if result.success ==0
        RR=[RR;hh];
        fprintf('******************FAILED******************\n')
    end
end
plot(RR,'.')