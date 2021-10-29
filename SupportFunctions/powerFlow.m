function powerFlow(hObject,eventdata,Type)

% cheking either to use current results or saved ones
h=findobj('Tag','CCR_pf');
if h.Value
    h=findobj('Tag','PRS'); % get current results
    Data=h.UserData;
else
    h=findobj('Tag','ESR_pf'); % get saved results
    load(h.String);
end

hcat=findobj('Tag','CAT_pf');
hcst=findobj('Tag','CST_pf');
hmr=findobj('Tag','EMR_pf');
hpf=findobj('Tag','EPF_pf');
if hcat.Value
    Horizon=[1:hmr.UserData.Market_Resolution/60:Data.Model.Parameter.T_Hrz];
elseif hcst.Value
    hst=findobj('Tag','ESTS_pf');
    hed=findobj('Tag','ESTE_pf');    
    Horizon=[hst.UserData.TS_Start:hmr.UserData.Market_Resolution/60:hed.UserData.TS_End];
end  
ratio=hmr.UserData.Market_Resolution/hpf.UserData.PowerFlow_Resolution;

if isempty(find(ratio==[1,2,3,4,6,12]))    
    fprintf('Invalid time scaling \n')
    return;
end

if Data.Model.Parameter.Ntd_Lvl==1
    fprintf('Invalid network detail level\n')
    return;    
elseif Data.Model.Parameter.Ntd_Lvl==2
    fprintf('Invalid network detail level\n')
    return;    
elseif Data.Model.Parameter.Ntd_Lvl==3
    mpc=MATPOWER_case_gen(Data);
end
% preparing utility storage for power flow
Pd_strg_temp=zeros(Data.Model.Parameter.B,Data.Model.Parameter.T_Hrz);
if Data.Model.Parameter.en_Uty_Strg   
    for ss=1:Data.Model.Parameter.S
        temp=find(strcmp(Data.Model.Bus.Name,Data.Model.Uty_Strg.Bus(1)));
        Pd_strg_temp(temp,:)=Pd_strg_temp(temp,:)+Data.MarketSolution.Uty_Storage.Power(ss,:);
    end
end
if ratio~=1
    for gg=1:Data.Model.Parameter.G
        Pg_temp(gg,:) = interpn([1:Data.Model.Parameter.T_Hrz],Data.MarketSolution.Gen.Power(gg,:),linspace(1,Data.Model.Parameter.T_Hrz,ratio*(Data.Model.Parameter.T_Hrz-1)+1),'linear');
        Status_gen_temp(gg,:) = ceil(interpn([1:Data.Model.Parameter.T_Hrz],Data.MarketSolution.Gen.Status(gg,:),linspace(1,Data.Model.Parameter.T_Hrz,ratio*(Data.Model.Parameter.T_Hrz-1)+1),'linear'));
        %         temp=Data.MarketSolution.Gen.Status(gg,:)'*ones(1,ratio);
%         temp=temp';
%         temp=temp(:);
%         Status_gen_temp(gg,:)=temp(1:end-ratio+1);
    end    
    Pg=Pg_temp;
    Sg=Status_gen_temp;
    if ~isempty(Data.Model.Gen.Trace.Type2)
        for gg=1:length(Data.Model.Gen.Seq_Type2)
            Pg_T2_temp(gg,:)=interpn([1:Data.Model.Parameter.T_Hrz],Data.Model.Gen.Trace.Type2(gg,1:Data.Model.Parameter.T_Hrz),linspace(1,Data.Model.Parameter.T_Hrz,ratio*(Data.Model.Parameter.T_Hrz-1)+1),'linear');
            Pg_T2=Pg_T2_temp;
        end
    end
    for bb=1:Data.Model.Parameter.B
        Pd_csm(bb,:)= interpn([1:Data.Model.Parameter.T_Hrz],Data.MarketSolution.Bus.csmDemand(bb,:),linspace(1,Data.Model.Parameter.T_Hrz,ratio*(Data.Model.Parameter.T_Hrz-1)+1),'linear');
        Pd_psm(bb,:)= interpn([1:Data.Model.Parameter.T_Hrz],Data.MarketSolution.Bus.psmDemand(bb,:),linspace(1,Data.Model.Parameter.T_Hrz,ratio*(Data.Model.Parameter.T_Hrz-1)+1),'linear');
        Pd_strg(bb,:)= interpn([1:Data.Model.Parameter.T_Hrz],Pd_strg_temp(bb,:),linspace(1,Data.Model.Parameter.T_Hrz,ratio*(Data.Model.Parameter.T_Hrz-1)+1),'linear');
    end
%     Time_axis=linspace(Horizon(1),Horizon(end),ratio*(Horizon(end)-Horizon(1))+1);
    Time_axis=linspace(1,Data.Model.Parameter.T_Hrz,ratio*(Data.Model.Parameter.T_Hrz-1)+1);
    
else
    Pg=Data.MarketSolution.Gen.Power;
    if ~isempty(Data.Model.Gen.Trace.Type2)
        Pg_T2=Data.Model.Gen.Trace.Type2(:,1:Data.Model.Parameter.T_Hrz);
    end
    Sg=Data.MarketSolution.Gen.Status;
    Pd_csm=Data.MarketSolution.Bus.csmDemand;
    Pd_psm=Data.MarketSolution.Bus.psmDemand;   
    Pd_strg=Pd_strg_temp;
    Time_axis=1:Data.Model.Parameter.T_Hrz;    
end

Result_pf.bus.PD=0./zeros(Data.Model.Parameter.B,length(Time_axis));
Result_pf.bus.QD=0./zeros(Data.Model.Parameter.B,length(Time_axis));
Result_pf.bus.VM=0./zeros(Data.Model.Parameter.B,length(Time_axis));
Result_pf.bus.VA=0./zeros(Data.Model.Parameter.B,length(Time_axis));
if strcmp(Type,'OPF')
    Result_pf.bus.LAM_P=0./zeros(Data.Model.Parameter.B,length(Time_axis));
    Result_pf.bus.LAM_Q=0./zeros(Data.Model.Parameter.B,length(Time_axis));
    Result_pf.bus.MU_VMAX=0./zeros(Data.Model.Parameter.B,length(Time_axis));
    Result_pf.bus.MU_VMIN=0./zeros(Data.Model.Parameter.B,length(Time_axis));
end
Data.Model.Parameter.U=sum(Data.Model.Gen.N_units);
Result_pf.gen.PG=0./zeros(Data.Model.Parameter.U+Data.Model.Parameter.V,length(Time_axis));
Result_pf.gen.QG=0./zeros(Data.Model.Parameter.U+Data.Model.Parameter.V,length(Time_axis));
Result_pf.gen.VG=0./zeros(Data.Model.Parameter.U+Data.Model.Parameter.V,length(Time_axis));
Result_pf.gen.STATUS=0./zeros(Data.Model.Parameter.U+Data.Model.Parameter.V,length(Time_axis));
Result_pf.gen.PMAX=0./zeros(Data.Model.Parameter.U+Data.Model.Parameter.V,length(Time_axis));
Result_pf.branch.PF=0./zeros(Data.Model.Parameter.L,length(Time_axis));
Result_pf.branch.QF=0./zeros(Data.Model.Parameter.L,length(Time_axis));
Result_pf.branch.PT=0./zeros(Data.Model.Parameter.L,length(Time_axis));
Result_pf.branch.QT=0./zeros(Data.Model.Parameter.L,length(Time_axis));


% temp=find(sum(Pg,1)>0);
mpopt = mpoption('verbose',0,'out.all',0);
RR=[];

st=find(Time_axis==Horizon(1));
ed=find(Time_axis==Horizon(end));

% temp=intersect(temp,);

for hh=st:ed
    if sum(Pg(:,hh))>0
        mpc_temp=mpc;
        % selecting slack bus
        hss=findobj('Tag','CSB_pf');
        
        % finding largest infeed and making it slack if not selected already 
        if isempty(find(mpc_temp.bus(:,2)==3))       
            temp1=find((Data.Model.Gen.Power_Rating.*Sg(:,hh))==max((Data.Model.Gen.Power_Rating.*Sg(:,hh))));
            if length(temp1)>1
                temp2=find(min(Pg(temp1,hh))==Pg(:,hh));
                if length(temp2)>1
                    gg=temp2(1);
                else
                    gg=temp2;
                end
            else
                gg=temp1;
            end
            mpc_temp.bus(find(strcmp(Data.Model.Bus.Name,Data.Model.Gen.Bus(gg))),2)=3;
        end
        % detecting if multiple slacks are selected
        if length(find(mpc_temp.bus(:,2)==3))>1
            fprintf('****** Multiple slack buses detected ******')
            return;        
        end
        % forcing largest infeed as slack
        if  hss.Value==1            
            mpc_temp.bus(find(mpc_temp.bus(:,2)==3),2)=2; % converting the slack bus to PV bus
            % selecteing largest infeed as slack
            temp1=find((Data.Model.Gen.Power_Rating.*Sg(:,hh))==max((Data.Model.Gen.Power_Rating.*Sg(:,hh))));
            if length(temp1)>1
                temp2=find(min(Pg(temp1,hh))==Pg(:,hh));
                if length(temp2)>1
                    gg=temp2(1);
                else
                    gg=temp2;
                end
            else
                gg=temp1;
            end
            mpc_temp.bus(find(strcmp(Data.Model.Bus.Name,Data.Model.Gen.Bus(gg))),2)=3;
        end
        %printing slack bus selection
        temp=find(mpc_temp.bus(:,2)==3);
        fprintf('**Slack Bus is "%s"**\n',char(Data.Model.Bus.Seq(temp)));
        % printing info regarding the solve interval
        if hh==0
            fprintf('solving for hour %5.0f : %2.0f \n',1,0)
        else
            fprintf('solving for hour %5.0f : %2.0f \n',floor((hh+ratio-1)/ratio),mod(hh-1,ratio)*hpf.UserData.PowerFlow_Resolution)
        end
        % setting demand for the hour
        mpc_temp.bus(:,3)=[Pd_csm(:,hh)+Pd_psm(:,hh)+Pd_strg(:,hh)]';
        mpc_temp.bus(:,4)=mpc_temp.bus(:,3).*tan(acos(Data.Model.Bus.Power_Factor));
        % setting generation limits
        st=1;
        Pg_dagg=zeros(sum(Data.Model.Gen.N_units),1);
        Sg_dagg=zeros(sum(Data.Model.Gen.N_units),1);
        Qg_dagg_max=zeros(sum(Data.Model.Gen.N_units),1);
        Qg_dagg_min=zeros(sum(Data.Model.Gen.N_units),1);
        gt2=1;
        for gg=1:length(Data.Model.Gen.N_units)
            ed=st+Data.Model.Gen.N_units(gg)-1;
            Sg_dagg(st:st+Sg(gg,hh)-1)=1;
            Pg_dagg(st:st+Sg(gg,hh)-1)=Pg(gg,hh)/Sg(gg,hh);
            if Data.Model.Gen.Type(gg)==2
               Pg_dagg_max(st:ed)=Pg_T2(gt2,hh);
               Qg_dagg_max(st:ed)=Data.Model.Gen.Max_Reactive_Power(gg);%*(Data.Model.Gen.Trace.Type2(gg,hh)./Data.Model.Gen.Power_Rating(gg));
               Qg_dagg_min(st:ed)=Data.Model.Gen.Min_Reactive_Power(gg);%*(Data.Model.Gen.Trace.Type2(gg,hh)./Data.Model.Gen.Power_Rating(gg));
               gt2=gt2+1;
            else
               Pg_dagg_max(st:ed)=Data.Model.Gen.Max_Real_Power(gg); 
               Qg_dagg_max(st:ed)=Data.Model.Gen.Max_Reactive_Power(gg);
               Qg_dagg_min(st:ed)=Data.Model.Gen.Min_Reactive_Power(gg);
            end         
            st=ed+1;
        end
        mpc_temp.gen(1:sum(Data.Model.Gen.N_units),2)=Pg_dagg;
        mpc_temp.gen(1:sum(Data.Model.Gen.N_units),4)=Qg_dagg_max;
        mpc_temp.gen(1:sum(Data.Model.Gen.N_units),5)=Qg_dagg_min;
        mpc_temp.gen(1:sum(Data.Model.Gen.N_units),8)=Sg_dagg;
        mpc_temp.gen(1:sum(Data.Model.Gen.N_units),9)=Pg_dagg_max; 
        clearvars Sg_Dagg Pg_dagg gg st ed
        switch Type
            case 'DC'
                result=rundcpf(mpc_temp,mpopt);
            case 'AC'
                result=runpf(mpc_temp,mpopt);
            case 'OPF'
                result=runopf(mpc_temp,mpopt);
        end

        if result.success ==0
            RR=[RR;hh];
            fprintf('******************FAILED******************\n')
        else
            Result_pf.bus.PD(:,hh)=result.bus(:,3);
            Result_pf.bus.QD(:,hh)=result.bus(:,4);
            Result_pf.bus.VM(:,hh)=result.bus(:,8);
            Result_pf.bus.VA(:,hh)=result.bus(:,9);
            if strcmp(Type,'OPF')
                if size(result.bus,2)==17
                    Result_pf.bus.LAM_P(:,hh)=result.bus(:,14);
                    Result_pf.bus.LAM_Q(:,hh)=result.bus(:,15);
                    Result_pf.bus.MU_VMAX(:,hh)=result.bus(:,16);
                    Result_pf.bus.MU_VMIN(:,hh)=result.bus(:,17);
                end
            end
            Result_pf.gen.PG(:,hh)=result.gen(:,2);
            Result_pf.gen.QG(:,hh)=result.gen(:,3);
            Result_pf.gen.QMAX(:,hh)=result.gen(:,4);
            Result_pf.gen.QMIN(:,hh)=result.gen(:,5);        
            Result_pf.gen.VG(:,hh)=result.gen(:,6);
            Result_pf.gen.STATUS(:,hh)=result.gen(:,8);
            Result_pf.gen.PMAX(:,hh)=result.gen(:,9);
            Result_pf.branch.PF(:,hh)=result.branch(:,14);
            Result_pf.branch.QF(:,hh)=result.branch(:,15);
            Result_pf.branch.PT(:,hh)=result.branch(:,16);
            Result_pf.branch.QT(:,hh)=result.branch(:,17);
        end 
    else
        fprintf('******************Market Infeasible Interval******************\n')        
    end
end

% saving power flow soulution information
Data.PowerFlow.mpc=mpc;

switch Type
        case 'DC'
            Data.PowerFlow.DCPF=Result_pf;
            Data.PowerFlow.DCPF.Time_axis=Time_axis;
        case 'AC'
            Data.PowerFlow.ACPF=Result_pf;
            Data.PowerFlow.ACPF.Time_axis=Time_axis;
        case 'OPF'
            Data.PowerFlow.OPF=Result_pf;
            Data.PowerFlow.OPF.Time_axis=Time_axis;
end
    
h=findobj('Tag','CCR_pf');
if h.Value
    h=findobj('Tag','PRS');
    h.UserData=Data;
    h=findobj('Tag','CSR');
    if h.Value
        h=findobj('Tag','ESR');
        fnam=sprintf(h.String); %generating corrosponding name for storing result
        oldfolder=cd('./Data');
        save(fnam,'Data')      %saving result
        cd(oldfolder);
    end
else
    h=findobj('Tag','ESR_pf');
    oldfolder=cd('./Data');
    save(h.String,'Data');
    cd(oldfolder);
end



