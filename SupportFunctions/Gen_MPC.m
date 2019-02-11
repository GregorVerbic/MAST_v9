function mpc=Gen_MPC(fnam,hh)
load(fnam);
if isempty(Data.PowerFlow)
    mpc=MATPOWER_case_gen(fnam);
else
    mpc=Data.PowerFlow.mpc;
end

% finding largest infeed and making it slack if not selected already
if isempty(find(mpc.bus(:,2)==3))        
    temp1=find((Pg(:,hh).*Sg(:,hh))==max((Pg(:,hh).*Sg(:,hh))));
    if length(temp1)>1
        temp2=find(min(Pg(temp1))==Pg(:,hh));
        if length(temp2)>1
            gg=temp2(1);
        else
            gg=temp2;
        end
    else
        gg=temp1;
    end
    mpc.bus(find(strcmp(Data.Model.Bus.Name,Data.Model.Gen.Bus(gg))),2)=3;
elseif length(find(mpc.bus(:,2)==3))>1
    fprintf('****** Multiple slack buses detected ******')
    return;        
end


Pg=Data.MarketSolution.Gen.Power;
Sg=Data.MarketSolution.Gen.Status;
Pd_csm=Data.MarketSolution.Bus.csmDemand;
Pd_psm=Data.MarketSolution.Bus.psmDemand;
% preparing utility storage for power flow
Pd_strg_temp=zeros(Data.Model.Parameter.B,Data.Model.Parameter.T_Hrz);
if Data.Model.Parameter.en_Uty_Strg   
    for ss=1:Data.Model.Parameter.S
        temp=find(strcmp(Data.Model.Bus.Name,Data.Model.Uty_Strg.Bus(1)));
        Pd_strg_temp(temp,:)=Pd_strg_temp(temp,:)+Data.MarketSolution.Uty_Storage.Power(ss,:);
    end
end
Pd_strg=Pd_strg_temp;
    
mpc.bus(:,3)=[Pd_csm(:,hh)+Pd_psm(:,hh)+Pd_strg(:,hh)]';
mpc.bus(:,4)=mpc.bus(:,3).*tan(acos(Data.Model.Bus.Power_Factor));
% setting generation limits
st=1;
Pg_dagg=zeros(sum(Data.Model.Gen.N_units),1);
Sg_dagg=zeros(sum(Data.Model.Gen.N_units),1);
Qg_dagg_max=zeros(sum(Data.Model.Gen.N_units),1);
Qg_dagg_min=zeros(sum(Data.Model.Gen.N_units),1);
Pg_dagg_max=zeros(sum(Data.Model.Gen.N_units),1);
gt2=1;
for gg=1:length(Data.Model.Gen.N_units)
    ed=st+Data.Model.Gen.N_units(gg)-1;
    Sg_dagg(st:st+Sg(gg,hh)-1)=1;
    Pg_dagg(st:st+Sg(gg,hh)-1)=Pg(gg,hh)/Sg(gg,hh);
    if Data.Model.Gen.Type(gg)==2
       Pg_dagg_max(st:ed)=Data.Model.Gen.Trace.Type2(gt2,hh);
       Qg_dagg_max(st:st+Sg(gg,hh)-1)=Data.Model.Gen.Max_Reactive_Power(gg);%*(Data.Model.Gen.Trace.Type2(gg,hh)./Data.Model.Gen.Power_Rating(gg));
       Qg_dagg_min(st:st+Sg(gg,hh)-1)=Data.Model.Gen.Min_Reactive_Power(gg);%*(Data.Model.Gen.Trace.Type2(gg,hh)./Data.Model.Gen.Power_Rating(gg));
       gt2=gt2+1;
    else
       Pg_dagg_max(st:ed)=Data.Model.Gen.Max_Real_Power(gg);
       Qg_dagg_max(st:st+Sg(gg,hh)-1)=Data.Model.Gen.Max_Reactive_Power(gg);
       Qg_dagg_min(st:st+Sg(gg,hh)-1)=Data.Model.Gen.Min_Reactive_Power(gg);
    end         
    st=ed+1;
end
mpc.gen(1:sum(Data.Model.Gen.N_units),2)=Pg_dagg;
mpc.gen(1:sum(Data.Model.Gen.N_units),4)=Qg_dagg_max;
mpc.gen(1:sum(Data.Model.Gen.N_units),5)=Qg_dagg_min;
mpc.gen(1:sum(Data.Model.Gen.N_units),8)=Sg_dagg;   
mpc.gen(1:sum(Data.Model.Gen.N_units),9)=Pg_dagg_max;      
end