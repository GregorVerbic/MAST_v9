function callback_RunSimulations(hObject,eventdata)
%% Copyright Notice
% Copyright ©2017. Shariq Riaz, Archie C. Chapman Gregor Verbic. All Rights Reserved.
% Permission to use, copy, modify, and distribute this software and 
% its documentation for educational, research, and not-for-profit purposes,
% without fee and without a signed licensing agreement, is hereby granted,
% provided that the above copyright notice, this paragraph and the following
% two paragraphs appear in all copies, modifications, and distributions.
% Contact: Gregor Verbic, School of Electrical and Information Engineering
% Centre for Future Energy Networks, J03 - Electrical Engineering Building,
% The University of Sydney, Ph +61 2 9351 8136,
% gregor.verbic@sydney.edu.au.
% 
% IN NO EVENT SHALL AUTHORS BE LIABLE TO ANY PARTY FOR DIRECT,
% INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING
% LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS 
% DOCUMENTATION, EVEN IF AUTHORS HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH
% DAMAGE.
% 
% AUTHORS SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT 
% LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A 
% PARTICULAR PURPOSE. THE SOFTWARE AND ACCOMPANYING DOCUMENTATION, IF ANY, 
% PROVIDED HEREUNDER IS PROVIDED "AS IS". AUTHORS HAS NO OBLIGATION TO 
% PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
%% 
    hObject.BackgroundColor = [1,1,0];
    pause(1e-9)
    
    a=tic;
    %% Load parameters and Model
    Sys_Values = get_SimulationParameters();
    if ispc
        load('Data\Model.mat');
    elseif ismac
        load('Data/Model.mat');
    elseif isunix
        load('Data/Model.mat');
    end
    
    
    %% Formating data into correct format
    T_Hrz = 24* Sys_Values.Horizon_length;
    T_sHrz = 24* Sys_Values.Subhorizon_length;                          % Total time slots in horizon
    T_Kp = 24*(Sys_Values.Subhorizon_length-Sys_Values.Overlap_days);   % Total hours to keep 
%     T = T_sHrz;                                                         % Setting Total lenght of Horizon T   
    N_sHrz =  ceil(Sys_Values.Horizon_length/...
        (Sys_Values.Subhorizon_length-Sys_Values.Overlap_days));        % Number of Subhorizons
    
    Offset = Sys_Values.StartDay_Offset;


    % Combining all parameter in Structure "Parameter"
    Parameter.T_Hrz=T_Hrz;
    Parameter.T = T_sHrz;       % Number of Time slots  
    Parameter.Ntd_Lvl = Sys_Values.Network_Detail_level;
    Parameter.en_Uty_Strg = Sys_Values.En_Uty_Strg* ~isempty(Uty_Strg.Maximum_Capacity);
    Parameter.en_Type2 =  ~isempty(find(Gen.Type==2));
    Parameter.en_Type3 = ~isempty(find(Gen.Type==3));
    Parameter.en_DR = Sys_Values.En_DR* ~isempty(Bus.Prosumer);
    Parameter.Loss_factor = Sys_Values.Loss_factor/100;
    Parameter.PReserve_factor = Sys_Values.Power_reserve/100;
    Parameter.Base_power = Sys_Values.Base_power;
    % Solver Options
    Mdl.Solver = ['option solver ',Sys_Values.Solver,';'];
    if strcmp(Sys_Values.Solver,'cplex')|strcmp(Sys_Values.Solver,'cplexamp')
        Mdl.Options = ['option cplex_options ',char(39),...
            Sys_Values.Solver_opt,char(39),';'];
    elseif strcmp(Sys_Values.Solver,'gurobi')
        Mdl.Options = ['option gurobi_options ',char(39),...
            Sys_Values.Solver_opt,char(39),';'];
    else 
        Mdl.Options = ['option ',Sys_Values.Solver,'_options ',char(39),...
            Sys_Values.Solver_opt,char(39),';'];
        
    end
    Parameter.Mdl=Mdl;
    % add AMPL path
    h=findobj('Tag','PPS');
    if ispc
        Path=[h.UserData.Dpaths.Ampl,'\setupOnce.m'];
    elseif ismac
        Path=[h.UserData.Dpaths.Ampl,'/setupOnce.m'];
    elseif isunix
        Path=[h.UserData.Dpaths.Ampl,'/setupOnce.m'];
    end
    
    run(Path)

    f_temp_lable = Sys_Values.Result_filename;
    

    %% Loading data from other files
    % Loading Net Demand of system for the horizon
    [Date.Demand, Bus.Demand]=get_Demand(Offset,Bus,T_Hrz+T_sHrz,Sys_Values.Data_folder);
    % Getting Trace for type 2 generators
    [Date.Type2 Gen] =  Concatenate_Type2Gen(Offset,Gen,Bus,T_Hrz+T_sHrz,Sys_Values.Data_folder);
    [Date.Type3 Gen] =  Concatenate_Type3Gen(Offset,Gen,Bus,T_Hrz+T_sHrz,Sys_Values.Data_folder);
    % if DR is enabled get PV traces and split demand based on consumers
    % and prosumers 
      
    if Parameter.en_DR
        Bus.PV_DR=zeros(Parameter.B,T_Hrz+T_sHrz);
        temp=Bus.Prosumer_Weightage*ones(1,T_Hrz+T_sHrz);
        Bus.psmDemand = temp.*Bus.Demand;         % prosumer demand
        Bus.csmDemand = (1-temp).*Bus.Demand;     % consumer demand
        if Sys_Values.En_DR_PV
            % Get PV trace 
            [Date.DR Bus.PV_DR]=get_RTPV_Trace(Offset,Bus,(T_Hrz+T_sHrz),Sys_Values.Data_folder);            
        end
        if ~Sys_Values.En_DR_Strg            
            Bus.Battery.Maximum_Capacity=zeros(size(Bus.Battery.Maximum_Capacity));
            Bus.Battery.Minimum_Capacity=zeros(size(Bus.Battery.Minimum_Capacity));
            Bus.Battery.Maximum_ChargeRate=zeros(size(Bus.Battery.Maximum_ChargeRate));
            Bus.Battery.Maximum_DischargeRate=zeros(size(Bus.Battery.Maximum_DischargeRate));
        end
    else
        Bus.csmDemand = 1*Bus.Demand;             % consumer demand
        Bus.psmDemand = 0*Bus.Demand;             % prosumer demand
        Bus.PV_DR=zeros(Parameter.B,T_Hrz+T_sHrz);
    end
    
    
    switch Sys_Values.Network_Detail_level
    % Cu-Plate model
    case 1 
        % Generator
        Gen.Bus=cellstr(repmat('CuPl',Parameter.G,1));
        Gen.Region=cellstr(repmat('CuPl',Parameter.G,1));
        % Buss
        Bus.Region=cellstr(repmat('CuPl',1,1));            
        Bus.csmDemand=sum(Bus.csmDemand,1);
        Bus.psmDemand=sum(Bus.psmDemand,1);
        Bus.PV_DR=sum(Bus.PV_DR,1);
        Bus.Battery.Maximum_Capacity=sum(Bus.Battery.Maximum_Capacity);
        Bus.Battery.Minimum_Capacity=sum(Bus.Battery.Minimum_Capacity);
        Bus.Battery.Maximum_ChargeRate=sum(Bus.Battery.Maximum_ChargeRate);
        Bus.Battery.Maximum_DischargeRate=sum(Bus.Battery.Maximum_DischargeRate);
        Bus.Battery.Efficiency=max(Bus.Battery.Efficiency);
        Bus.Feedin_price_ratio=max(Bus.Feedin_price_ratio);
        %Line
        Line.End_1_Bus=cellstr(repmat('CuPl',Parameter.L,1));
        Line.End_2_Bus=cellstr(repmat('CuPl',Parameter.L,1)); 
        % Uty_Storage
        if Parameter.en_Uty_Strg
            if ~isempty(Uty_Strg.Maximum_Capacity)
                Uty_Strg.Bus=cellstr(repmat('CuPl',1,1));
                Uty_Strg.Maximum_Capacity=sum(Uty_Strg.Maximum_Capacity);
                Uty_Strg.Minimum_Capacity=sum(Uty_Strg.Minimum_Capacity);
                Uty_Strg.Maximum_ChargeRate=sum(Uty_Strg.Maximum_ChargeRate);
                Uty_Strg.Maximum_DischargeRate=sum(Uty_Strg.Maximum_DischargeRate);
                Uty_Strg.Efficiency=mean(Uty_Strg.Efficiency);
                Uty_Strg.Bus=cellstr(repmat('CuPl',Parameter.S,1));                
                Parameter.S=1;
                Bus.Name=cellstr(repmat('CuPl',1,1));            
            end            
        end
        % parameter
        Parameter.B=1;
        Parameter.R=1;
        % Bus name
        Bus.Name='CuPl';
        Parameter.Region.Name='CuPl';
        
    % Regional Model    
    case 2
        %Generator
        Gen.Bus=Gen.Region;
        % Buss
        Bus.csmDemand_temp=zeros(Parameter.R,T_Hrz+T_sHrz);
        Bus.psmDemand_temp=zeros(Parameter.R,T_Hrz+T_sHrz);
        Region_temp=unique(Bus.Region);
        for rr=1:Parameter.R
            temp = find(strcmp(Bus.Region,Region_temp(rr)));
            Bus.csmDemand_temp(rr,:)=sum(Bus.csmDemand(temp,:),1);
            Bus.psmDemand_temp(rr,:)=sum(Bus.psmDemand(temp,:),1);
            Bus.Battery.Maximum_Capacity_temp(rr,:)=sum(Bus.Battery.Maximum_Capacity(temp,:),1);
            Bus.Battery.Minimum_Capacity_temp(rr,:)=sum(Bus.Battery.Minimum_Capacity(temp,:),1);
            Bus.Battery.Maximum_ChargeRate_temp(rr,:)=sum(Bus.Battery.Maximum_ChargeRate(temp,:),1);
            Bus.Battery.Maximum_DischargeRate_temp(rr,:)=sum(Bus.Battery.Maximum_DischargeRate(temp,:),1);
            Bus.PV_DR_temp(rr,:)=sum(Bus.PV_DR(temp,:),1);
            Bus.Battery.Efficiency_temp(rr,:)=max(Bus.Battery.Efficiency(temp,:));
            Bus.Feedin_price_ratio_temp(rr,:)=max(Bus.Feedin_price_ratio(temp,:));
        end
        Bus.csmDemand=Bus.csmDemand_temp;
        Bus.psmDemand=Bus.psmDemand_temp;
        Bus.Battery.Maximum_Capacity=Bus.Battery.Maximum_Capacity_temp;
        Bus.Battery.Minimum_Capacity=Bus.Battery.Minimum_Capacity_temp;
        Bus.Battery.Maximum_ChargeRate=Bus.Battery.Maximum_ChargeRate_temp;
        Bus.Battery.Maximum_DischargeRate=Bus.Battery.Maximum_DischargeRate_temp;
        Bus.Battery.Efficiency=Bus.Battery.Efficiency_temp;
        Bus.Feedin_price_ratio=Bus.Feedin_price_ratio_temp;
        Bus.PV_DR=Bus.PV_DR_temp;
        %Line
        for ll=1:Parameter.L
            Line.End_1_Bus(ll)=Bus.Region(find(strcmp(Line.End_1_Bus(ll),Bus.Name)));
            Line.End_2_Bus(ll)=Bus.Region(find(strcmp(Line.End_2_Bus(ll),Bus.Name)));
        end
        %utility storage
        if Parameter.en_Uty_Strg
            for ss=1:Parameter.S
                temp = find(strcmp(Bus.Region(find(strcmp(Uty_Strg.Bus(rr),Bus.Name))),Region_temp)); 
                Uty_Strg.Maximum_Capacity_temp(rr,:)=sum(Uty_Strg.Maximum_Capacity(temp,:),1);
                Uty_Strg.Minimum_Capacity_temp(rr,:)=sum(Uty_Strg.Minimum_Capacity(temp,:),1);
                Uty_Strg.Maximum_ChargeRate_temp(rr,:)=sum(Uty_Strg.Maximum_ChargeRate(temp,:),1);
                Uty_Strg.Maximum_DischargeRate_temp(rr,:)=sum(Uty_Strg.Maximum_DischargeRate(temp,:),1);
                Uty_Strg.Efficiency_temp(rr,:)=mean(Uty_Strg.Efficiency);
                Uty_Strg.Bus_temp(rr,1)=Bus.Region(find(strcmp(Uty_Strg.Bus(rr),Bus.Name)));           
            end
            Uty_Strg.Maximum_Capacity=Uty_Strg.Maximum_Capacity_temp;
            Uty_Strg.Minimum_Capacity=Uty_Strg.Minimum_Capacity_temp;
            Uty_Strg.Maximum_ChargeRate=Uty_Strg.Maximum_ChargeRate_temp;
            Uty_Strg.Maximum_DischargeRate=Uty_Strg.Maximum_DischargeRate_temp;
            Uty_Strg.Efficiency=Uty_Strg.Efficiency_temp;
            Uty_Strg.Bus=Uty_Strg.Bus_temp;
            Uty_Strg.Name=Uty_Strg.Bus;
        end
        % Bus name
        Bus.Name=Region_temp;
        Bus.Region=Region_temp;        
        % parameter
        Parameter.B=Parameter.R;        
        Parameter.S=length(Uty_Strg.Maximum_Capacity);       

        case 3
        otherwise
            sprintf('Invalid Network Detail Level')            
    end
%     Bus.Feedin_price_ratio=0*ones(size(Bus.Feedin_price_ratio));
    %% AMPL settings
    % Generating sequence of sets to be used by AMPL

    % Generating generator sequence
    Gen.Seq=name_seq_AMPL('G',Parameter.G);
    % Generating Line sequence
    Line.Seq=name_seq_AMPL('L',Parameter.L);
    % Generating region sequence and unique names
    % As there is no seprate structure for region so, putting it in
    % parameter structure
    Parameter.Region.Name=unique(Bus.Region);
    Parameter.Region.Seq=name_seq_AMPL('R',Parameter.R);
    % Generating Bus sequence
    Bus.Seq=name_seq_AMPL('B',Parameter.B);
    % Generating Storage sequence
    Uty_Strg.Seq=name_seq_AMPL('S',Parameter.S);
    % Type 1 generators Seq
    temp=find(Gen.Type==1);
    Gen.Seq_Type1=Gen.Seq(temp);
    % Type 2 generators
    temp=find(Gen.Type==2);
    Gen.Seq_Type2=Gen.Seq(temp);
    % Type 3 generators
    temp=find(Gen.Type==3);
    Gen.Seq_Type3=Gen.Seq(temp); 
    
    % Syn generators
    % Both type1 and type3 are synchronous generators
    Gen.Seq_Syn=[Gen.Seq_Type1;Gen.Seq_Type3];

    % Generating cross relations of quantities
    % Generator X Bus
    Parameter.LINKS.GXB=set_links_AMPL(Gen.Seq,Bus.Seq,Gen.Bus,Bus.Name);
    % Generator X Region
    Parameter.LINKS.GXR=set_links_AMPL(Gen.Seq,Parameter.Region.Seq,Gen.Region,Parameter.Region.Name);
    % Type1 Generator X Region
    temp=find(Gen.Type==1);
    Parameter.LINKS.GT1XR=set_links_AMPL(Gen.Seq(temp),Parameter.Region.Seq,Gen.Region(temp),Parameter.Region.Name);
    % Type2 Generator X Region
    temp=find(Gen.Type==2);
    Parameter.LINKS.GT2XR=set_links_AMPL(Gen.Seq(temp),Parameter.Region.Seq,Gen.Region(temp),Parameter.Region.Name);
    % Type3 Generator X Region
    temp=find(Gen.Type==3);
    Parameter.LINKS.GT3XR=set_links_AMPL(Gen.Seq(temp),Parameter.Region.Seq,Gen.Region(temp),Parameter.Region.Name);
    % Line X Bus
    Parameter.LINKS.LXB_E1=set_links_AMPL(Line.Seq,Bus.Seq,Line.End_1_Bus,Bus.Name);
    Parameter.LINKS.LXB_E2=set_links_AMPL(Line.Seq,Bus.Seq,Line.End_2_Bus,Bus.Name);
%     % Line X Region
%     Parameter.LINKS.IXR_E1=set_links_AMPL(Line.name,Parameter.Region.name,Line.End_1.Region);
%     Parameter.LINKS.IXR_E2=set_links_AMPL(Line.name,Parameter.Region.name,Line.End_2.Region);        
    % Bus X Region
    Parameter.LINKS.BXR=set_links_AMPL(Bus.Seq,Parameter.Region.Seq,Bus.Region,Parameter.Region.Name);
    % Storage X Bus
    Parameter.LINKS.SXB=set_links_AMPL(Uty_Strg.Seq,Bus.Seq,Uty_Strg.Bus,Bus.Name);

    % AMPL file writer
    Model_writer_AMPL(Parameter);
    
    %% Data Storage structure
    RH.Bus.csmDemand=Bus.csmDemand(:,1:T_Hrz);
    RH.Bus.psmDemand=Bus.psmDemand(:,1:T_Hrz);
    RH.Sol.Gen.Status=[];
    RH.Sol.Gen.S_Up=[];
    RH.Sol.Gen.S_Dn=[];
    RH.Sol.Gen.Power=[];
    RH.Sol.Line.Power=[];
    RH.Sol.Bus.Angle=[];
    RH.Sol.Dual.Balance=[];
    RH.Sol.Time=[];
    if Parameter.en_Type3
        RH.Sol.Gen.Strg_engy=[];
        RH.Sol.Gen.GenT3_Rsv=[];
    end
    if  Parameter.en_DR
        RH.Bus.PV_DR=Bus.PV_DR(:,1:T_Hrz);
        RH.Sol.Bus.prosumer_gridpower=[];
        RH.Sol.Bus.PV.spill=[];
        RH.Sol.Bus.PV.utilisedpower=[];
        RH.Sol.Bus.Battery.Power=[];
        RH.Sol.Bus.Battery.Energy=[];
        RH.Sol.Bus.Slack.rc=[];
        RH.Sol.Bus.feedin_power=[];
        RH.Sol.Bus.batteryandload_power=[];
    end
    if  Parameter.en_Uty_Strg
        RH.Sol.Uty_Storage.Power=[];
%         RH.Sol.Uty_Storage.Power.Chrg=[];
%         RH.Sol.Uty_Storage.Power.Dchrg=[];
        RH.Sol.Uty_Storage.Energy=[];
    end
    
    
            
%% Simulating sub-horizons
for ll=1:N_sHrz  
    
    % setting sub horizon time varing parameters
    sHrz_Gen = Gen;
    if Parameter.en_Type2
        sHrz_Gen.Trace.Type2 = Gen.Trace.Type2(:,T_Kp*(ll-1)+1:T_sHrz+T_Kp*(ll-1));
    end
    if Parameter.en_Type3
        sHrz_Gen.Trace.Type3 = Gen.Trace.Type3(:,T_Kp*(ll-1)+1:T_sHrz+T_Kp*(ll-1));
    end    
    sHrz_Bus = Bus;
    if Parameter.en_DR
        sHrz_Bus.PV_DR = Bus.PV_DR(:,T_Kp*(ll-1)+1:T_sHrz+T_Kp*(ll-1));
    end
    sHrz_Bus.psmDemand = Bus.psmDemand(:,T_Kp*(ll-1)+1:T_sHrz+T_Kp*(ll-1));
    sHrz_Bus.csmDemand = Bus.csmDemand(:,T_Kp*(ll-1)+1:T_sHrz+T_Kp*(ll-1));
    
    % if it is first time initialise parameters
    if ll==1
        RH.Ini.S_gh_0=zeros(Parameter.G,1);   % All generators are off
        RH.Ini.P_gh_0=zeros(Parameter.G,1);   % Dispatch level of all gen is zero 
        RH.Ini.U_gh_0=zeros(Parameter.G,24);
        RH.Ini.D_gh_0=zeros(Parameter.G,24);
        RH.Ini.Eb_0=Bus.Battery.Minimum_Capacity;              % DR-battery SOH
        RH.Ini.Es_0=Uty_Strg.Minimum_Capacity;              % Utility-storage SOH
        RH.Ini.rc_0=zeros(Parameter.B,1);              % battery slack variable
        if Parameter.en_Type3
            RH.Ini.Et_0=Gen.Minimum_TES;     % TES initial condition
        end
    % use values from previous sub horizon    
    else                            
        RH.Ini.S_gh_0=RH.Sol.Gen.Status(:,end);
        RH.Ini.P_gh_0=round(RH.Sol.Gen.Power(:,end),2); 
        RH.Ini.U_gh_0=fliplr(RH.Sol.Gen.S_Up(:,end-24+1:end));
        RH.Ini.D_gh_0=fliplr(RH.Sol.Gen.S_Dn(:,end-24+1:end));
        if Parameter.en_Type3
            RH.Ini.Et_0=round(RH.Sol.Gen.Strg_engy(:,end),2);
        end
        if Parameter.en_DR
            RH.Ini.Eb_0=round(RH.Sol.Bus.Battery.Energy(:,end-1)+RH.Sol.Bus.Battery.Power(:,end),2);
%             RH.Ini.rc_0=round(RH.Sol.Bus.Slack.rc(:,end),2);
        end
        if Parameter.en_Uty_Strg
            RH.Ini.Es_0=round(RH.Sol.Uty_Storage.Energy(:,end),2);
        end
    end

    %% Finding optimized Solution

    [Model, Sol]=Unit_Commitment...
    (sHrz_Gen,Line,Uty_Strg,sHrz_Bus,Parameter,RH);

    %% Preparing data Calculation and displaying results
    RH.Sol.Dual.Balance=[RH.Sol.Dual.Balance,Sol.Dual.Balance(:,1:T_Kp)];
    RH.Sol.Gen.Status=[RH.Sol.Gen.Status,Sol.Gen.Status(:,1:T_Kp)];
    RH.Sol.Gen.S_Up=[RH.Sol.Gen.S_Up,Sol.Gen.S_Up(:,1:T_Kp)];
    RH.Sol.Gen.S_Dn=[RH.Sol.Gen.S_Dn,Sol.Gen.S_Dn(:,1:T_Kp)];
    RH.Sol.Gen.Power=[RH.Sol.Gen.Power,Sol.Gen.Power(:,1:T_Kp)];
    RH.Sol.Line.Power=[RH.Sol.Line.Power,Sol.Line.Power(:,1:T_Kp)];
    RH.Sol.Bus.Angle=[RH.Sol.Bus.Angle,Sol.Bus.Angle(:,1:T_Kp)];
    RH.Sol.Time=[RH.Sol.Time,Sol.Time];
    if Parameter.en_Type3
        RH.Sol.Gen.Strg_engy=[RH.Sol.Gen.Strg_engy,Sol.Gen.Strg_engy(:,1:T_Kp)];
        RH.Sol.Gen.GenT3_Rsv=[RH.Sol.Gen.GenT3_Rsv,Sol.Gen.GenT3_Rsv(:,1:T_Kp)];
    end
    if  Parameter.en_DR
        RH.Sol.Bus.prosumer_gridpower=[RH.Sol.Bus.prosumer_gridpower,Sol.Bus.prosumer_gridpower(:,1:T_Kp)];
%         RH.Sol.Bus.PV.spill=[RH.Sol.Bus.PV.spill,Sol.Bus.PV.spill(:,1:T_Kp)];
        RH.Sol.Bus.PV.utilisedpower=[RH.Sol.Bus.PV.utilisedpower,Sol.Bus.PV.utilisedpower(:,1:T_Kp)];
        RH.Sol.Bus.Battery.Power=[RH.Sol.Bus.Battery.Power,Sol.Bus.Battery.Power(:,1:T_Kp)];                
        RH.Sol.Bus.Battery.Energy=[RH.Sol.Bus.Battery.Energy,Sol.Bus.Battery.Energy(:,1:T_Kp)];
%         RH.Sol.Bus.Slack.rc=[RH.Sol.Bus.Slack.rc,Sol.Bus.Slack.rc(:,1:T_Kp)];
%         RH.Sol.Bus.feedin_power=[RH.Sol.Bus.feedin_power,Sol.Bus.feedin_power(:,1:T_Kp)];
%         RH.Sol.Bus.batteryandload_power=[RH.Sol.Bus.batteryandload_power,Sol.Bus.batteryandload_power(:,1:T_Kp)];
    end
    if  Parameter.en_Uty_Strg
        RH.Sol.Uty_Storage.Power=[RH.Sol.Uty_Storage.Power,Sol.Uty_Storage.Power(:,1:T_Kp)];
%         RH.Sol.Uty_Storage.Power.Chrg=[RH.Sol.Uty_Storage.Power.Chrg,Sol.Uty_Storage.Power.Chrg(:,1:T_Kp)];
%         RH.Sol.Uty_Storage.Power.Dchrg=[RH.Sol.Uty_Storage.Power.Dchrg,Sol.Uty_Storage.Power.Dchrg(:,1:T_Kp)];
        RH.Sol.Uty_Storage.Energy=[RH.Sol.Uty_Storage.Energy,Sol.Uty_Storage.Energy(:,1:T_Kp)];        
    end

end
RH.Sol.Line.Diff_Angle=zeros(size(RH.Sol.Line.Power));
if Parameter.Ntd_Lvl~=1 
    for ll=1:Parameter.L
        RH.Sol.Line.Diff_Angle(ll,:)=rad2deg(RH.Sol.Bus.Angle(find(not(cellfun('isempty',strfind(Bus.Name,char(Line.End_1_Bus(ll)))))),:)...
        -RH.Sol.Bus.Angle(find(not(cellfun('isempty',strfind(Bus.Name,char(Line.End_2_Bus(ll)))))),:));
    end
end


Data.MarketSolution=RH.Sol;
Data.MarketSolution.Bus.csmDemand=RH.Bus.csmDemand;
Data.MarketSolution.Bus.psmDemand=RH.Bus.psmDemand;

Data.Model.Gen=Gen;
Data.Model.Bus=Bus;
Data.Model.Uty_Strg=Uty_Strg;
Data.Model.Line=Line;
Data.Model.Parameter=Parameter;
Data.Model.SVC=SVC;
hObject.UserData=Data;

h=findobj('Tag','CSR');
if h.Value
    h=findobj('Tag','ESR');
    fnam=sprintf(h.String); %generating corrosponding name for storing result
    if ispc
        save(['Data\',fnam],'Data')      %saving result
    elseif ismac
        save(['Data/',fnam],'Data')      %saving result
    elseif isunix
        save(['Data/',fnam],'Data')      %saving result
    end
    
end
    
hObject.BackgroundColor = [0.94,0.94,0.94];
    
Time=toc(a)    
end