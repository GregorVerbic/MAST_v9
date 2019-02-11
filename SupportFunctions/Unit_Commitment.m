function [Model, Results]=Unit_Commitment...
    (Gen,Line,Uty_Strg,Bus,Parameter,RH)
%% Copyright Notice
% Copyright ©2017. Shariq Riaz, Gregor Verbic. All Rights Reserved.
% Permission to use, copy, modify, and distribute this software and 
% its documentation for educational, research, and not-for-profit purposes,
% without fee and without a signed licensing agreement, is hereby granted,
% provided that the above copyright notice, this paragraph and the following
% two paragraphs appear in all copies, modifications, and distributions.
% Contact Gregor Verbic, School of Electrical and Information Engineering
% Centre for Future Energy Networks, J03 - Electrical Engineering Building,
% The University of Sydney, Ph +61 2 9351 8136, gregor.verbic@sydney.edu.au
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
% function to model and solve DR nodal model based on description in PDf
% file
% Output:
% Model : Structure containing name and adress of variables and constraints
% Results : Structured results of simulation
% Inputs:
% Gen: Structure with generation variables
% Line: Structure with interconnect information
% Uty_Strg: Structure for utility storage
% Bus: Structure with bus related parameters
% Parameter: Different parameters required by simulations
% RH: Structure with rolling horizon parameters
% Author: Shariq Riaz CFEN SEIE USYD 
% Date: 07/04/2016

%% Extracting prameters for easy access.
eta_bat=1;
G = Parameter.G;
T = Parameter.T;
R = Parameter.R;
B = Parameter.B;
S = Parameter.S;
L = Parameter.L;

%% Generate AMPL instance
ampl = AMPL;
% Display version
ampl.eval('option version;')
% Load from file the ampl model
ampl.read('Automatic_Generated_AMPL_Model.mod');

%% Set parameters 

ampl.getParameter('T').setValues(T);    % setting horizon length
% ampl.getParameter('N').setValues(N);    % setting number of Buses

%% Generator (Set parameters)
% get generator set from ampl
gen_ampl = ampl.getSet('UGen');
% get generator parm Min_pwr
min_pwr_ampl=  ampl.getParameter('Min_pwr');
% genrate data frame for generator data 
df = DataFrame(gen_ampl,min_pwr_ampl);    
% setting parameters of gen
df.setColumn('UGen',Gen.Seq);
df.setColumn('Min_pwr',Gen.Min_Real_Power);
df.addColumn('Max_pwr',Gen.Max_Real_Power);
df.addColumn('Ramp_up',Gen.Ramp_Up_Rate);
df.addColumn('Ramp_down',Gen.Ramp_Down_Rate);
df.addColumn('MUT',Gen.MUT);
df.addColumn('MDT',Gen.MDT);
% df.addColumn('Unit_gen',Gen.Units);  
df.addColumn('C_Fix',Gen.Cost_Fix);
df.addColumn('C_Su',Gen.Cost_Start_Up);
df.addColumn('C_Sd',Gen.Cost_Shut_Down);
df.addColumn('C_Var',Gen.Cost_Variable);
df.addColumn('Units',Gen.N_units);
% setting data frame to set UGen 
ampl.setData(df,'UGen');  

ampl.getParameter('Status_ini').setValues(RH.Ini.S_gh_0);
ampl.getParameter('Pwr_Gen_ini').setValues(RH.Ini.P_gh_0);
ampl.getParameter('MUT_ini').setValues(RH.Ini.U_gh_0);
ampl.getParameter('MDT_ini').setValues(RH.Ini.D_gh_0);

ampl.getSet('G_Syn').setValues(Gen.Seq_Syn);
ampl.getSet('G_T1').setValues(Gen.Seq_Type1);
%% Line (Set parameters)
% get line set from ampl
line_ampl = ampl.getSet('ULine');
% get power limit of line from ampl
pwr_lim_ampl = ampl.getParameter('PwrLim');
% genrate data frame for interconnect data 
df = DataFrame(line_ampl,pwr_lim_ampl);
df.setColumn('ULine',Line.Seq);
df.setColumn('PwrLim',abs(min(Line.Capacity,Parameter.Base_power*deg2rad(Line.Max_Angle./Line.x))));
df.addColumn('Susceptance',1./Line.x);

% setting data frame to set ULine 
ampl.setData(df,'ULine');

% Region (Set parameters)
ampl.getSet('URegion').setValues(Parameter.Region.Seq);
% Bus (Set parameters)
ampl.getSet('UBus').setValues(Bus.Seq);






%% Setting cross relations
% Generator cross Bus
ampl.getSet('Gen_Bus_links').setValues(Parameter.LINKS.GXB);
% Line END1 cross Bus
ampl.getSet('Line_end1_Bus_links').setValues(Parameter.LINKS.LXB_E1)
% Line END2 cross Bus
ampl.getSet('Line_end2_Bus_links').setValues(Parameter.LINKS.LXB_E2)
% Bus cross region
ampl.getSet('Bus_Region_links').setValues(Parameter.LINKS.BXR)
% Generator cross Bus
ampl.getSet('Gen_Region_links').setValues(Parameter.LINKS.GXR);
% Synch Generator cross Region
ampl.getSet('GenT1_Region_links').setValues(Parameter.LINKS.GT1XR);

% setting consumers demand
ampl.getParameter('Csm_Demand').setValues(Bus.csmDemand);
% setting proumers demand
ampl.getParameter('Psm_Demand').setValues(Bus.psmDemand);    
% setting Loss factor
ampl.getParameter('Loss_factor').setValues(Parameter.Loss_factor);
% setting Power reserve factor
ampl.getParameter('PReserve_factor').setValues(Parameter.PReserve_factor);
% setting Base power
ampl.getParameter('Base_power').setValues(Parameter.Base_power);
%% Storage (Set parameters)
if Parameter.en_Uty_Strg
    % get storage set from ampl
    storage_ampl = ampl.getSet('UStorage');
    % get charging rate of storage from ampl
    chrg_rate_strg_ampl = ampl.getParameter('Chrg_rate_strg');
    % genrate data frame for Storage data 
    df = DataFrame(storage_ampl,chrg_rate_strg_ampl);
    df.setColumn('UStorage',Uty_Strg.Seq);
    df.setColumn('Chrg_rate_strg',Uty_Strg.Maximum_ChargeRate);
    df.addColumn('Dchrg_rate_strg',Uty_Strg.Maximum_DischargeRate);
    df.addColumn('Max_SOC_strg',Uty_Strg.Maximum_Capacity);
    df.addColumn('Min_SOC_strg',Uty_Strg.Minimum_Capacity);
    df.addColumn('Storage_eff',Uty_Strg.Efficiency);
    % setting data frame to set ULine 
    ampl.setData(df,'UStorage');
    % Storage cross Bus
    ampl.getSet('Storage_Bus_links').setValues(Parameter.LINKS.SXB);
    % Storage initial conditions
    ampl.getParameter('Enrg_Strg_ini').setValues(RH.Ini.Es_0);
end

%% Utility RES generator (Set parameters)
if Parameter.en_Type2
    ampl.getSet('G_T2').setValues(Gen.Seq_Type2);
    ampl.getParameter('Resource_trace_T2').setValues(Gen.Trace.Type2);
end
%% Utility CST generator (Set parameters)
if Parameter.en_Type3
    ampl.getSet('G_T3').setValues(Gen.Seq_Type3);
    ampl.getSet('GenT3_Region_links').setValues(Parameter.LINKS.GT3XR);
    ampl.getParameter('Resource_trace_T3').setValues(Gen.Trace.Type3);
    ampl.getParameter('Enrg_TES_ini').setValues(RH.Ini.Et_0);
    ampl.getParameter('TES_eff').setValues(Gen.TES_Efficiency);
    ampl.getParameter('Min_SOC_TES').setValues(Gen.Minimum_TES);
    ampl.getParameter('Max_SOC_TES').setValues(Gen.Maximum_TES);
end
%% DR block
if Parameter.en_DR
   ampl.getParameter('PV_trace_DR').setValues(Bus.PV_DR); 
   ampl.getParameter('Max_chrg_rate_bat').setValues(Bus.Battery.Maximum_ChargeRate);
   ampl.getParameter('Max_dchrg_rate_bat').setValues(Bus.Battery.Maximum_DischargeRate);
   ampl.getParameter('Min_SOC_bat').setValues(Bus.Battery.Minimum_Capacity);
   ampl.getParameter('Max_SOC_bat').setValues(Bus.Battery.Maximum_Capacity);
   ampl.getParameter('Bat_eff').setValues(Bus.Battery.Efficiency);
   ampl.getParameter('alpha').setValues(Bus.Feedin_price_ratio);
   % DR initial consition
   ampl.getParameter('Engy_bat_ini').setValues(RH.Ini.Eb_0);
end




%% Solving model

% setting solver 
ampl.eval(Parameter.Mdl.Solver);
% setting solver options
ampl.eval(Parameter.Mdl.Options)

a=tic;
ampl.solve
Time=toc(a);

%% Organising Data
Sol_variabl_Manager_DR_AMPL;
Sol.Time=Time;
tic
Model=ampl;
Results=Sol;