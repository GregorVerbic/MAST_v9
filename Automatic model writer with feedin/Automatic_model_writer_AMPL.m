function Automatic_model_writer_AMPL_VER8(Parameter)
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

% function to writer model file used by AMPL
% As model is always changing based on the system componenets to include or
% exclude, hence this function will generate model based on system
% configuration
% Output: Automatic_Generated_AMPL_Model.mod
% Inputs:
% Parameter: Different parameters required to form model
% Author: Shariq Riaz CFEN SEIE USYD 
% Date: 20/01/2017

% Empty cell for set, cross set, parameter, objective function,
% decision variable and constraints declaration 
CommandS=[];    % Sets
CommandCS=[];   % Cross Sets
CommandP=[];    % Parameters
CommandO=[];    % Objective function
CommandD=[];    % Decision varibales
CommandC=[];    % ConstraintsSyn
%% Set declaration
CommandS=[CommandS;cellstr('### SETS ###')];
CommandS=[CommandS;cellstr('set UGen;')];
CommandS=[CommandS;cellstr('set G_Syn in UGen;')];
CommandS=[CommandS;cellstr('set G_T1 in UGen;')];
CommandS=[CommandS;cellstr('param T>0;')];
CommandS=[CommandS;cellstr('set Time = 1..T;')];
CommandS=[CommandS;cellstr('set UNode;')];
CommandS=[CommandS;cellstr('set URegion;')];
CommandS=[CommandS;cellstr('set ULine;')];
CommandS=[CommandS;cellstr('\t')];

%% Cross Set generation
CommandCS=[CommandCS;cellstr('### CROSS SETS LINKS ###')];
CommandCS=[CommandCS;cellstr('set Gen_Node_links within (UGen cross UNode);')];
CommandCS=[CommandCS;cellstr('set Gen_Region_links within (UGen cross URegion);')];
CommandCS=[CommandCS;cellstr('set GenT1_Region_links within (G_T1 cross URegion);')];
CommandCS=[CommandCS;cellstr('set Line_end1_Node_links within (ULine cross UNode);')];
CommandCS=[CommandCS;cellstr('set Line_end2_Node_links within (ULine cross UNode);')];
CommandCS=[CommandCS;cellstr('set Node_Region_links within (UNode cross URegion);')];
CommandCS=[CommandCS;cellstr('\n')];

%% Generator cost declaration
CommandP=[CommandP;cellstr('### Generator Cost Parameters ###')];
CommandP=[CommandP;cellstr('param C_Fix{UGen} >=0;')];
CommandP=[CommandP;cellstr('param C_Su{UGen} >=0;')];
CommandP=[CommandP;cellstr('param C_Sd{UGen} >=0;')];
CommandP=[CommandP;cellstr('param C_Var{UGen} >=0;')];
CommandP=[CommandP;cellstr('\t')];

%% Generator parameter Declaration
CommandP=[CommandP;cellstr('### Generator Parameters ###')];
CommandP=[CommandP;cellstr('param Max_pwr{UGen} >=0;')];
CommandP=[CommandP;cellstr('param Min_pwr{UGen} >=0;')];
CommandP=[CommandP;cellstr('param Ramp_up{UGen} >=0;')];
CommandP=[CommandP;cellstr('param Ramp_down{UGen} >=0;')];
CommandP=[CommandP;cellstr('param MUT{UGen}>=0;')];
CommandP=[CommandP;cellstr('param MDT{UGen}>=0;')];
CommandP=[CommandP;cellstr('param Units{UGen}>=0;')];
CommandP=[CommandP;cellstr('\t')];


%% Generator initial conditions
CommandP=[CommandP;cellstr('### Generator Initial Consitions ###')];
CommandP=[CommandP;cellstr('param Status_ini{UGen} >=0;')];
CommandP=[CommandP;cellstr('param Pwr_Gen_ini{UGen} >=0;')];
CommandP=[CommandP;cellstr('param MUT_ini{UGen,1..24} >=0;')];
CommandP=[CommandP;cellstr('param MDT_ini{UGen,1..24} >=0;')];
CommandP=[CommandP;cellstr('\t')];

%% Interconnector parameter Declaration
CommandP=[CommandP;cellstr('### Interconnector Parameters ###')];
CommandP=[CommandP;cellstr('param ThrmLim{ULine} >=0;')];
CommandP=[CommandP;cellstr('param Susceptance{ULine};')];
CommandP=[CommandP;cellstr('\t')];

%% Demand parameter Declaration
CommandP=[CommandP;cellstr('### Demand Parameters ###')];
CommandP=[CommandP;cellstr('param Csm_Demand{UNode,Time} >=0;')];
CommandP=[CommandP;cellstr('param Psm_Demand{UNode,Time} >=0;')];
CommandP=[CommandP;cellstr('param Loss_factor >=0,<=1;')];
CommandP=[CommandP;cellstr('param PReserve_factor >=0,<=1;')];
CommandP=[CommandP;cellstr('\t')];

%% Decision variable
CommandD=[CommandD;cellstr('### Generator Decision Variables ###')];
CommandD=[CommandD;cellstr('var Status_var {g in UGen,Time} integer >=0,<=Units[g];')];
CommandD=[CommandD;cellstr('var S_Up_var {UGen,Time} integer >=0;')];
CommandD=[CommandD;cellstr('var S_Down_var {UGen,Time} integer >=0;')];
CommandD=[CommandD;cellstr('var Pwr_Gen_var {UGen,Time} >=0;')];
CommandD=[CommandD;cellstr('\t')];

CommandD=[CommandD;cellstr('### Interconnector Decision Variables ###')];
CommandD=[CommandD;cellstr('var Pwr_line_var {ULine,Time};')];
CommandD=[CommandD;cellstr('\n')];

CommandD=[CommandD;cellstr('### Node Angle Decision Variables ###')];
CommandD=[CommandD;cellstr('var Angle_line_var {UNode,Time};')];
CommandD=[CommandD;cellstr('\n')];

%% Objective function
CommandO=[CommandO;cellstr('### OBJECTIVE FUNCTION ###')];
CommandO=[CommandO;cellstr(['minimize total_cost: sum {t in Time} sum {g in UGen}',...
        '(C_Fix[g]*Status_var[g,t]\n + C_Su[g]*S_Up_var[g,t] +',...
		' C_Sd[g]*S_Down_var[g,t] + C_Var[g]*Pwr_Gen_var[g,t] );'])];
CommandO=[CommandO;cellstr('\n')];    


%% Power balance constraint
CommandC=[CommandC;cellstr('### Balance Constraint ###')];    
CommandC=[CommandC;cellstr(['subject to Balance {n in UNode, t in Time}:',...
        ' sum{(g,n) in Gen_Node_links} Pwr_Gen_var[g,t]\n',... 
		' + sum{(l1,n) in Line_end1_Node_links}',...
        '(Pwr_line_var[l1,t]) \n==',...
		' Csm_Demand[n,t] + Loss_factor*Csm_Demand[n,t] \n',... 
        ' + sum{(l2,n) in Line_end2_Node_links}',...
		'(Pwr_line_var[l2,t]);'])];
    
if Parameter.en_Uty_Strg
    temp=CommandC{end};
    temp1=temp(end);
    temp2=[temp(1:end-1),'\n + sum{(s,n) in Storage_Node_links}',...
        '(Pwr_chrg_Strg_var[s,t] - Pwr_dchrg_Strg_var[s,t])'];
    CommandC(end,:)=cellstr([temp2,temp1]);

end

if Parameter.en_DR
    temp=CommandC{end};
    temp1=temp(end);
    temp2=[temp(1:end-1),'\n +  Pwr_pgp_var[n,t] + Loss_factor*Pwr_pgp_var[n,t]',...
        '- Pwr_pgn_var[n,t] + Loss_factor*Pwr_pgn_var[n,t]'];
    CommandC(end,:)=cellstr([temp2,temp1]);

end
CommandC=[CommandC;cellstr('\n')];


%% Active Power reserve constraints
CommandC=[CommandC;cellstr('### Active Power Reserve Constraint ###')];    
CommandC=[CommandC;cellstr(['subject to Power_Reserve {r in URegion, t in Time}:',...
        ' sum{(g,r) in GenT1_Region_links} Status_var[g,t]*Max_pwr[g]\n',... 
		' - sum{(g,r) in GenT1_Region_links} Pwr_Gen_var[g,t] \n>=',...
		' sum{(n,r) in Node_Region_links} PReserve_factor*Csm_Demand[n,t];'])];
if Parameter.en_Type3
    temp=CommandC{end};
    temp1=temp(end);
    temp2=[temp(1:end-1),'\n - sum{(g,r) in GenT3_Region_links}',...
        ' GenT3_Rsv_var[g,t]'];
    CommandC(end,:)=cellstr([temp2,temp1]);    
end
if Parameter.en_DR
    temp=CommandC{end};
    temp1=temp(end);
    temp2=[temp(1:end-1),'\n + sum{(n,r) in Node_Region_links}',...
        ' PReserve_factor*Pwr_pgp_var[n,t]'];
    CommandC(end,:)=cellstr([temp2,temp1]);

end
CommandC=[CommandC;cellstr('\n')];

%% Generator Constraints
CommandC=[CommandC;cellstr('### Stable Limit of Generators Constraints ###')];
% Syn Generators
CommandC=[CommandC;cellstr(['subject to Gen_max_pwr {g in G_Syn,t in Time}:',...
        ' Pwr_Gen_var[g,t] <= Max_pwr[g]*Status_var[g,t];'])];
CommandC=[CommandC;cellstr(['subject to Gen_min_pwr {g in G_Syn,t in Time}:',...
        ' Min_pwr[g]*Status_var[g,t] <= Pwr_Gen_var[g,t];'])]; 
CommandC=[CommandC;cellstr('\t')];

CommandC=[CommandC;cellstr('### Integer variable linking Constraint ###')];
CommandC=[CommandC;cellstr(['subject to On_Off {g in G_Syn,t in 2..T}:',...
        ' S_Up_var[g,t] - S_Down_var[g,t] == ',...
        'Status_var[g,t] - Status_var[g,t-1];'])];
CommandC=[CommandC;cellstr(['subject to On_Off_initial {g in G_Syn}:',...
        ' S_Up_var[g,1] - S_Down_var[g,1] == ',...
        'Status_var[g,1] - Status_ini[g];'])];    
CommandC=[CommandC;cellstr('\t')];

CommandC=[CommandC;cellstr('### Generator Ramping Constraints ###')];
CommandC=[CommandC;cellstr(['subject to ramp_up {g in G_Syn, t in 2..T}:',...
        'Ramp_up[g]<Max_pwr[g] ==> Pwr_Gen_var[g,t] - Pwr_Gen_var[g,t-1] <= Status_var[g,t]*Ramp_up[g];'])];
CommandC=[CommandC;cellstr(['subject to ramp_up_initial {g in G_Syn}:',...
        'Ramp_up[g]<Max_pwr[g] ==> Pwr_Gen_var[g,1] - Pwr_Gen_ini[g] <= Status_var[g,1]*Ramp_up[g];'])];    
CommandC=[CommandC;cellstr(['subject to ramp_down {g in G_Syn, t in 2..T}:',...
        'Ramp_down[g]<Max_pwr[g] ==> Pwr_Gen_var[g,t-1] - Pwr_Gen_var[g,t] <= Status_var[g,t-1]*Ramp_down[g];'])];
CommandC=[CommandC;cellstr(['subject to ramp_down_initial {g in G_Syn}:',...
        'Ramp_down[g]<Max_pwr[g] ==> Pwr_Gen_ini[g] - Pwr_Gen_var[g,1] <= Status_ini[g]*Ramp_down[g];'])];
CommandC=[CommandC;cellstr('\t')];

CommandC=[CommandC;cellstr('### Generator Minimum Up/Down Time Constraints ###')];
CommandC=[CommandC;cellstr(['subject to min_up_Time {g in G_Syn, t in MUT[g]..T}:',...
        'MUT[g]>1 ==> Status_var[g,t]\n >= sum{t1 in 0..MUT[g]-1} S_Up_var[g,t-t1]  ;'])]; 
CommandC=[CommandC;cellstr(['subject to min_up_Time_ini {g in G_Syn, t in 1..MUT[g]-1}:',...
        'MUT[g]>1 ==> Status_var[g,t]\n >= sum{t1 in 0..t-1} S_Up_var[g,t-t1] + MUT_ini[g,t] ;'])];
CommandC=[CommandC;cellstr('\t')];    
CommandC=[CommandC;cellstr(['subject to min_down_Time {g in G_Syn, t in MDT[g]..T}:',...
        'MDT[g]>1 ==> Status_var[g,t]\n <= Units[g] - sum{t1 in 0..MDT[g]-1} S_Down_var[g,t-t1] ;'])];
CommandC=[CommandC;cellstr(['subject to min_down_Time_ini {g in G_Syn, t in 1..MDT[g]-1}:',...
        'MDT[g]>1 ==> Status_var[g,t]\n <= Units[g] - sum{t1 in 0..t-1} S_Down_var[g,t-t1] - MDT_ini[g,t] ;'])];    
CommandC=[CommandC;cellstr('\n')];

CommandC=[CommandC;cellstr('### Maximum limit on ON units ###')];
CommandC=[CommandC;cellstr(['subject to max_ONunits {g in UGen, t in Time}:\n',...
        'Status_var[g,t] <= Units[g];'])]; 

%% Interconnect constraints
% Thermal limit 
CommandC=[CommandC;cellstr('### Thermal limits of interconnect Constraints ###')];
CommandC=[CommandC;cellstr(['subject to thermal_limit_ub {l in ULine, t in Time}:',...
        ' Pwr_line_var [l,t] <= ThrmLim[l];'])];
CommandC=[CommandC;cellstr(['subject to thermal_limit_lb {l in ULine, t in Time}:',...
        ' -ThrmLim[l] <= Pwr_line_var[l,t] ;'])];
CommandC=[CommandC;cellstr('\t')];

% AC line angle stability
CommandC=[CommandC;cellstr('### AC line angle stablility ###')];
CommandC=[CommandC;cellstr(['subject to angle_limit {l in ULine, t in Time}:',...
        ' Pwr_line_var[l,t] == Susceptance[l]*',... 
        '\n (sum{(l,n1) in Line_end1_Node_links} Angle_line_var[n1,t]',...
        '- sum{(l,n2) in Line_end2_Node_links} Angle_line_var[n2,t]);'])];
CommandC=[CommandC;cellstr('\n')];

%% Type2 (PV and Wind) generator additional constraints
if Parameter.en_Type2
    % RES generatoe parameters
    CommandS=[CommandS;cellstr('### Type2 Generators Sets ###')];
    CommandS=[CommandS;cellstr('set G_T2 in UGen;')];
    CommandS=[CommandS;cellstr('\t')];
    CommandP=[CommandP;cellstr('### Type2 Generators Parameters ###')];
    CommandP=[CommandP;cellstr('param Resource_trace_T2{G_T2,Time};')];
    CommandP=[CommandP;cellstr('\t')];
    % RES constraints
    CommandC=[CommandC;cellstr('### Type2 Power Limit ###')];
    CommandC=[CommandC;cellstr(['subject to Resource_availability_T2 ',...
        '{g in G_T2, t in Time}: Pwr_Gen_var[g,t] <= Status_var[g,t]*Resource_trace_T2[g,t];'])];
    CommandC=[CommandC;cellstr('\n')];
    CommandC=[CommandC;cellstr(['subject to G_T2_min_pwr ',...
        '{g in G_T2, t in Time}: Status_var[g,t]*Min_pwr[g]  <= Pwr_Gen_var[g,t];'])];
    CommandC=[CommandC;cellstr('\n')];    
end
%% Type3 (CSP) generator additional constraints
if Parameter.en_Type3
    % CSP generator parameters
    CommandS=[CommandS;cellstr('### Type3 Generators Sets ###')];
    CommandS=[CommandS;cellstr('set G_T3 in UGen;')];
    CommandS=[CommandS;cellstr('\t')];
    CommandCS=[CommandCS;cellstr('### Type3 Generators Cross Sets ###')];
    CommandCS=[CommandCS;cellstr('set GenT3_Region_links within (G_T3 cross URegion);')];
    CommandS=[CommandS;cellstr('\t')];
    CommandP=[CommandP;cellstr('### Type3 Generators Parameters ###')];
    CommandP=[CommandP;cellstr('param Resource_trace_T3{G_T3,Time};')];
    CommandP=[CommandP;cellstr('param Enrg_TES_ini{G_T3};')];
    CommandP=[CommandP;cellstr('param TES_eff{G_T3};')];
    CommandP=[CommandP;cellstr(['param Min_SOC_TES{G_T3} >=0;'])];
    CommandP=[CommandP;cellstr(['param Max_SOC_TES{G_T3} >=0;'])];
    
    CommandP=[CommandP;cellstr('\t')];
    CommandD=[CommandD;cellstr('### Type3 Generators variables ###')];
    CommandD=[CommandD;cellstr('var Enrg_TES_var{G_T3,Time} >=0;')];
    CommandD=[CommandD;cellstr('var GenT3_Rsv_var{G_T3,Time} >=0;')];
     CommandD=[CommandD;cellstr('var Pwr_Spill_var{G_T3,Time} >=0;')];
    CommandD=[CommandD;cellstr('\t')];
    % CST constraints
    CommandC=[CommandC;cellstr('### Type3 Generators Power Limit ###')];
    CommandC=[CommandC;cellstr(['subject to TES_SOC ',...
        '{g in G_T3, t in 2..T}: Enrg_TES_var[g,t] == TES_eff[g]*Enrg_TES_var[g,t-1] + '...
        'Resource_trace_T3[g,t] - Pwr_Gen_var[g,t] - Pwr_Spill_var[g,t];'])];
    CommandC=[CommandC;cellstr(['subject to TES_SOC_ini ',...
        '{g in G_T3}: Enrg_TES_var[g,1] == TES_eff[g]*Enrg_TES_ini[g] + '...
        'Resource_trace_T3[g,1] - Pwr_Gen_var[g,1] - Pwr_Spill_var[g,1];'])];    
    CommandC=[CommandC;cellstr('\t')];
    CommandC=[CommandC;cellstr('### Type3 Generators Active Power Reserve Limits ###')];
    CommandC=[CommandC;cellstr('### Reserve limited by Generation ###')];
    CommandC=[CommandC;cellstr(['subject to GenT3_Rsv_power_limit ',...
        '{g in G_T3, t in Time}: GenT3_Rsv_var[g,t] <= Status_var[g,t]*Max_pwr[g]-Pwr_Gen_var[g,t];'])];    
    CommandC=[CommandC;cellstr('### Reserve limited by Storage ###')];
    CommandC=[CommandC;cellstr(['subject to GenT3_Rsv_energy_limit ',...
         '{g in G_T3, t in Time}: GenT3_Rsv_var[g,t] <= Enrg_TES_var[g,t]-Pwr_Gen_var[g,t];'])]; 
%         '{g in G_T3, t in Time}: Max_pwr[g]<= Max_SOC_TES[g] ==> GenT3_Rsv_var[g,t] <= Enrg_TES_var[g,t]-Pwr_Gen_var[g,t] else GenT3_Rsv_var[g,t]<=0;'])]; 
    CommandC=[CommandC;cellstr('\t')];
    
    CommandC=[CommandC;cellstr('### CST TES SOC Limits ###')];
    CommandC=[CommandC;cellstr(['subject to Min_TES_SOC ',...
        '{g in G_T3, t in Time}: Enrg_TES_var [g,t] ',...
        '>= Min_SOC_TES[g];'])];
    CommandC=[CommandC;cellstr(['subject to Max_TES_SOC ',...
        '{g in G_T3, t in Time}: Enrg_TES_var [g,t] ',...
        '<= Max_SOC_TES[g];'])];
    CommandC=[CommandC;cellstr('\n')];
end
%% Ultility Storage
if Parameter.en_Uty_Strg
    % Declaring sets and parameters
    CommandS=[CommandS;cellstr('### Utility Storage sets ###')];
    CommandS=[CommandS;cellstr(['set UStorage;'])];
    CommandS=[CommandS;cellstr(['set Storage_Node_links within (UStorage cross UNode);'])];
    CommandS=[CommandS;cellstr('\t')];
    
    CommandP=[CommandP;cellstr('### Utility Storage parameters ###')];
    CommandP=[CommandP;cellstr(['param Chrg_rate_strg{UStorage} >=0;'])];
    CommandP=[CommandP;cellstr(['param Dchrg_rate_strg{UStorage} >=0;'])];
    CommandP=[CommandP;cellstr(['param Min_SOC_strg{UStorage} >=0;'])];
    CommandP=[CommandP;cellstr(['param Max_SOC_strg{UStorage} >=0;'])];
    CommandP=[CommandP;cellstr(['param Storage_eff{UStorage} >=0,<=1;'])];
    CommandP=[CommandP;cellstr('\t')];
    CommandP=[CommandP;cellstr('### Utility Storage inintial conditions ###')];
    CommandP=[CommandP;cellstr(['param Enrg_Strg_ini{UStorage} >=0;'])];
    CommandP=[CommandP;cellstr('\t')];
    % Utility storage variables
    CommandD=[CommandD;cellstr('### Utility Storage decision variable ###')];
    CommandD=[CommandD;cellstr(['var Pwr_chrg_Strg_var {UStorage,Time} >=0;'])];
    CommandD=[CommandD;cellstr(['var Pwr_dchrg_Strg_var {UStorage,Time} >=0;'])];
    CommandD=[CommandD;cellstr(['var Enrg_Strg_var {UStorage,Time} >=0;'])];
    CommandD=[CommandD;cellstr('\t')];
    % Declaring utility storage
    CommandC=[CommandC;cellstr('### Utility Storage Energy Balance Constraint ###')];
    CommandC=[CommandC;cellstr(['subject to Storage_energy_balance ',...
        '{s in UStorage, t in 2..T}: Enrg_Strg_var [s,t] \n= ',...
        'Storage_eff[s]*Enrg_Strg_var [s,t-1] + Pwr_chrg_Strg_var [s,t] - ',...
        'Pwr_dchrg_Strg_var [s,t];'])];
    CommandC=[CommandC;cellstr(['subject to Storage_energy_balance_Initial ',...
       '{s in UStorage}: Enrg_Strg_var [s,1] \n= Storage_eff[s]*Enrg_Strg_ini[s] + ',...
       'Pwr_chrg_Strg_var [s,1] - Pwr_dchrg_Strg_var [s,1];'])];
   CommandC=[CommandC;cellstr('\t')];
   
    CommandC=[CommandC;cellstr('### Charge/Discharge rate Constraints ###')];
    CommandC=[CommandC;cellstr(['subject to Charge_rate_Storage ',...
        '{s in UStorage, t in Time}:  Pwr_chrg_Strg_var [s,t]  ',...
        '<= Chrg_rate_strg[s];'])];
    CommandC=[CommandC;cellstr(['subject to Dcharge_rate_Storage ',...
        '{s in UStorage, t in Time}:  Pwr_dchrg_Strg_var [s,t]  ',...
        '<= Dchrg_rate_strg[s];'])];
    CommandC=[CommandC;cellstr('\t')];
    
    CommandC=[CommandC;cellstr('### Storage SOC Constraints ###')];
    CommandC=[CommandC;cellstr(['subject to Min_SOC_Strg ',...
        '{s in UStorage, t in Time}: Enrg_Strg_var [s,t] ',...
        '>= Min_SOC_strg[s];'])];
    CommandC=[CommandC;cellstr(['subject to Max_SOC_Strg ',...
        '{s in UStorage, t in Time}: Enrg_Strg_var [s,t] ',...
        '<= Max_SOC_strg[s];'])];
    CommandC=[CommandC;cellstr('\n')];
end


%% Demand responce 
if Parameter.en_DR
    % Demand responce parameters
    CommandP=[CommandP;cellstr('### Demand responce parameters ###')];
    CommandP=[CommandP;cellstr('param M_gp = 1e6;')];
    CommandP=[CommandP;cellstr('param M_gn = 1e6;')];
    CommandP=[CommandP;cellstr('param M_bal = 1e6;')];
    CommandP=[CommandP;cellstr('param M_pv = 1e6;')];
    CommandP=[CommandP;cellstr('param M_sp = 1e6;')];
    CommandP=[CommandP;cellstr('param M_pl = 1e6;')];
    CommandP=[CommandP;cellstr('param M_pu = -1e6;')];
    CommandP=[CommandP;cellstr('param M_el = 1e6;')];
    CommandP=[CommandP;cellstr('param M_eu = -1e6;')];
    CommandP=[CommandP;cellstr('param PV_trace_DR{UNode,Time} >=0;')];
    CommandP=[CommandP;cellstr('param Max_chrg_rate_bat{UNode} >=0;')];
    CommandP=[CommandP;cellstr('param Max_dchrg_rate_bat{UNode} <=0;')];
    CommandP=[CommandP;cellstr('param Min_SOC_bat{UNode} >=0;')];
    CommandP=[CommandP;cellstr('param Max_SOC_bat{UNode} >=0;')];
    CommandP=[CommandP;cellstr('param Bat_eff{UNode} >=0;')];
    CommandP=[CommandP;cellstr('param alpha{UNode} >=0;')];
    CommandP=[CommandP;cellstr('\t')];
    CommandP=[CommandP;cellstr('### Demand responce initial conditions ###')];
    CommandP=[CommandP;cellstr('param Engy_bat_ini{UNode} >=0;')];
    CommandP=[CommandP;cellstr('\t')];
    
    % Demand Responce Variables
    CommandD=[CommandD;cellstr('### Demand responce decision variables ###')];
    CommandD=[CommandD;cellstr('var Pwr_pgp_var {UNode,Time} >=0;')];
    CommandD=[CommandD;cellstr('var Pwr_pgn_var {UNode,Time} >=0;')];
    CommandD=[CommandD;cellstr('var Pwr_bal_var {UNode,Time} >=0;')];
    CommandD=[CommandD;cellstr('var Pwr_pv_var {UNode,Time} >=0;')];
    CommandD=[CommandD;cellstr('var Pwr_sp_var {UNode,Time} >=0;')];
    CommandD=[CommandD;cellstr('var Engy_bat_var {UNode,Time} >=0;')];
    CommandD=[CommandD;cellstr('var Pwr_bat_var {UNode,Time};')];
    
    
    
    CommandD=[CommandD;cellstr('\t')];
    
    CommandD=[CommandD;cellstr('### Slackness Variables ###')];
    % Dual Variable for equality constraints 
    CommandD=[CommandD;cellstr('var lambda_pg_var {UNode,Time} ;')];
    CommandD=[CommandD;cellstr('var lambda_pb_var {UNode,Time} ;')];
    CommandD=[CommandD;cellstr('var lambda_pv_var {UNode,Time} ;')];
    CommandD=[CommandD;cellstr('var lambda_e_var {UNode,Time} ;')];
    % Dual Variable for inequality constraints
    CommandD=[CommandD;cellstr('var mu_gp_var {UNode,Time} >=0;')];
    CommandD=[CommandD;cellstr('var mu_gn_var {UNode,Time} >=0;')];
    CommandD=[CommandD;cellstr('var mu_pb_var {UNode,Time} >=0;')];
    CommandD=[CommandD;cellstr('var mu_pl_var {UNode,Time} >=0;')];
    CommandD=[CommandD;cellstr('var mu_pu_var {UNode,Time} >=0;')];
    CommandD=[CommandD;cellstr('var mu_el_var {UNode,Time} >=0;')];
    CommandD=[CommandD;cellstr('var mu_eu_var {UNode,Time} >=0;')];
    CommandD=[CommandD;cellstr('var mu_pv_var {UNode,Time} >=0;')];
    CommandD=[CommandD;cellstr('var mu_sp_var {UNode,Time} >=0;')];
    CommandD=[CommandD;cellstr('\t')];
    
    CommandD=[CommandD;cellstr('### Orthognal maintaining Variables ###')];
    CommandD=[CommandD;cellstr('var b_gp_var {UNode,Time} binary;')];
    CommandD=[CommandD;cellstr('var b_gn_var {UNode,Time} binary;')];
    CommandD=[CommandD;cellstr('var b_bal_var {UNode,Time} binary;')];
    CommandD=[CommandD;cellstr('var b_pv_var {UNode,Time} binary;')];
    CommandD=[CommandD;cellstr('var b_sp_var {UNode,Time} binary;')];
    CommandD=[CommandD;cellstr('var b_pl_var {UNode,Time} binary;')];
    CommandD=[CommandD;cellstr('var b_pu_var {UNode,Time} binary;')];
    CommandD=[CommandD;cellstr('var b_el_var {UNode,Time} binary;')];
    CommandD=[CommandD;cellstr('var b_eu_var {UNode,Time} binary;')];
    CommandD=[CommandD;cellstr('\n')];
    
    % DR Constraints
    CommandC=[CommandC;cellstr('### DR Equality Constraints ###')];
	% KKT constraints
    CommandC=[CommandC;cellstr('## KKT Constraints ##')];
    CommandC=[CommandC;cellstr(['subject to KKT_pgp {p in UNode, t in Time}: ',...
        'lambda_pg_var[p,t] - mu_gp_var[p,t]  == -1;'])];
    CommandC=[CommandC;cellstr(['subject to KKT_fdin {p in UNode, t in Time}: ',...
        '- lambda_pg_var[p,t] - mu_gn_var[p,t]  == alpha[p];'])];
    CommandC=[CommandC;cellstr(['subject to KKT_pbat {p in UNode, t in Time}: ',...
        '-lambda_pb_var[p,t] - lambda_e_var[p,t] - mu_pl_var[p,t] + mu_pu_var[p,t] ',...
        ' == 0;'])];
    CommandC=[CommandC;cellstr(['subject to KKT_ppv {p in UNode, t in Time}: ',...
        'lambda_pg_var[p,t] + lambda_pv_var[p,t] - mu_pv_var[p,t] == 0;'])];    
    CommandC=[CommandC;cellstr(['subject to KKT_pspill {p in UNode, t in Time}: ',...
        'lambda_pv_var[p,t] - mu_sp_var[p,t] == 0;'])];        
    CommandC=[CommandC;cellstr(['subject to KKT_bald {p in UNode, t in Time}: ',...
        '-lambda_pg_var[p,t] + lambda_pb_var[p,t] - mu_pb_var[p,t]  == 0;'])];
    CommandC=[CommandC;cellstr(['subject to KKT_ebat {p in UNode, t in 1..(T-1)}: ',...
        'lambda_e_var[p,t] - Bat_eff[p]*lambda_e_var[p,t] - mu_el_var[p,t]'...
        ' + mu_eu_var[p,t] == 0;'])];
    CommandC=[CommandC;cellstr('\t')];
    % System equality constraints
    CommandC=[CommandC;cellstr('## System Constraints ##')];
    CommandC=[CommandC;cellstr(['subject to Grid_bus_bal {p in UNode, t in Time}: ',...
        'Pwr_pgp_var[p,t] + Pwr_pv_var[p,t] - Pwr_pgn_var[p,t] - Pwr_bal_var[p,t]'...
        ' == 0;'])];
    CommandC=[CommandC;cellstr(['subject to Load_bus_bal {p in UNode, t in Time}: ',...
        'Pwr_bal_var[p,t] - Pwr_bat_var[p,t]  == Psm_Demand[p,t];'])];
    CommandC=[CommandC;cellstr(['subject to PV_bus_bal {p in UNode, t in Time}: ',...
        'Pwr_pv_var[p,t] + Pwr_sp_var[p,t]  == PV_trace_DR[p,t];'])];
    CommandC=[CommandC;cellstr(['subject to Battery_SOC {p in UNode, t in 2..T}: ',...
        ' Engy_bat_var[p,t] - Bat_eff[p]*Engy_bat_var[p,t-1] - Pwr_bat_var[p,t]  == 0 ;'])];
    CommandC=[CommandC;cellstr(['subject to Battery_SOC_Initial {p in UNode}: ',...
        ' Engy_bat_var[p,1] - Bat_eff[p]*Engy_bat_ini[p] - Pwr_bat_var[p,1]  == 0 ;'])];
    CommandC=[CommandC;cellstr('\n')];
    
    CommandC=[CommandC;cellstr('## Inequality Constraints ##')];
    CommandC=[CommandC;cellstr('## Orthogonal Constraints ##')];
    % Prosumer grid power intake
    CommandC=[CommandC;cellstr(['subject to mu_gp_perp_pgp_A {p in UNode, t in Time}:',...
        '\n\t\t Pwr_pgp_var[p,t] <= M_gp*b_gp_var[p,t];'])];
    CommandC=[CommandC;cellstr(['subject to mu_gp_perp_pgp_B {p in UNode, t in Time}:',...
        '\n\t\t mu_gp_var[p,t] <= M_gp * (1 - b_gp_var[p,t]) ;'])];
    CommandC=[CommandC;cellstr('\t')];
    % Prosumer feeding power
    CommandC=[CommandC;cellstr(['subject to mu_gn_perp_pgn_A {p in UNode, t in Time}:',...
        '\n\t\t Pwr_pgn_var[p,t] <= M_gn*b_gn_var[p,t];'])];
    CommandC=[CommandC;cellstr(['subject to mu_gn_perp_pgn_B {p in UNode, t in Time}:',...
        '\n\t\t mu_gn_var[p,t] <= M_gn * (1 - b_gn_var[p,t]) ;'])];
    CommandC=[CommandC;cellstr('\t')];
    % Prosumer battery and load power
    CommandC=[CommandC;cellstr(['subject to mu_pb_perp_bal_A {p in UNode, t in Time}:',...
        '\n\t\t Pwr_bal_var[p,t] <= M_bal*b_bal_var[p,t];'])];
    CommandC=[CommandC;cellstr(['subject to mu_pb_perp_bal_B {p in UNode, t in Time}:',...
        '\n\t\t mu_pb_var[p,t] <= M_bal * (1 - b_bal_var[p,t]) ;'])];
    CommandC=[CommandC;cellstr('\t')];
    % Prosumer PV power
    CommandC=[CommandC;cellstr(['subject to mu_pv_perp_ppv_A {p in UNode, t in Time}:',...
        '\n\t\t Pwr_pv_var[p,t] <= M_pv*b_pv_var[p,t];'])];
    CommandC=[CommandC;cellstr(['subject to mu_pv_perp_ppv_B {p in UNode, t in Time}:',...
        '\n\t\t mu_pv_var[p,t] <= M_pv * (1 - b_pv_var[p,t]) ;'])];
    CommandC=[CommandC;cellstr('\t')];
    % Prosumer PV-spilled
    CommandC=[CommandC;cellstr(['subject to mu_sp_perp_psp_A {p in UNode, t in Time}:',...
        '\n\t\t Pwr_sp_var[p,t] <= M_sp*b_sp_var[p,t];'])];
    CommandC=[CommandC;cellstr(['subject to mu_sp_perp_psp_B {p in UNode, t in Time}:',...
        '\n\t\t mu_sp_var[p,t] <= M_sp * (1 - b_sp_var[p,t]) ;'])];
    CommandC=[CommandC;cellstr('\t')];
    % Battery discharge limit
    CommandC=[CommandC;cellstr(['subject to mu_pl_perp_pb_A {p in UNode, t in Time}:',...
        '\n\t\t Pwr_bat_var[p,t] <= M_pl*b_pl_var[p,t];'])];
    CommandC=[CommandC;cellstr(['subject to mu_pl_perp_pb_B {p in UNode, t in Time}:',...
        '\n\t\t mu_pl_var[p,t] <= M_pl * (1 - b_pl_var[p,t]) ;'])];
    CommandC=[CommandC;cellstr('\t')];
    CommandC=[CommandC;cellstr(['subject to mu_pl_perp_pb_C {p in UNode, t in Time}:',...
        '\n\t\t Pwr_bat_var[p,t] >= Max_dchrg_rate_bat[p] ;'])];
    CommandC=[CommandC;cellstr('\t')];
    % Battery charge limit
    CommandC=[CommandC;cellstr(['subject to mu_pu_perp_pb_A {p in UNode, t in Time}:',...
        '\n\t\t Pwr_bat_var[p,t] >= M_pu*b_pu_var[p,t];'])];
    CommandC=[CommandC;cellstr(['subject to mu_pu_perp_pb_B {p in UNode, t in Time}:',...
        '\n\t\t mu_pu_var[p,t] <= M_pu * (1 - b_pu_var[p,t]) ;'])];
    CommandC=[CommandC;cellstr('\t')];
    CommandC=[CommandC;cellstr(['subject to mu_pu_perp_pb_C {p in UNode, t in Time}:',...
        '\n\t\t Pwr_bat_var[p,t] <= Max_chrg_rate_bat[p] ;'])];
    CommandC=[CommandC;cellstr('\t')];
    % Battery lower SOC limit
    CommandC=[CommandC;cellstr(['subject to mu_el_perp_eb_A {p in UNode, t in Time}:',...
        '\n\t\t Engy_bat_var[p,t] <= M_el*b_el_var[p,t];'])];
    CommandC=[CommandC;cellstr(['subject to mu_el_perp_eb_B {p in UNode, t in Time}:',...
        '\n\t\t mu_el_var[p,t] <= M_el * (1 - b_el_var[p,t]) ;'])];
    CommandC=[CommandC;cellstr('\t')];
    CommandC=[CommandC;cellstr(['subject to mu_el_perp_eb_C {p in UNode, t in Time}:',...
        '\n\t\t Engy_bat_var[p,t] >= Min_SOC_bat[p] ;'])];
    CommandC=[CommandC;cellstr('\t')];
    % Battery charge limit
    CommandC=[CommandC;cellstr(['subject to mu_eu_perp_eb_A {p in UNode, t in Time}:',...
        '\n\t\t Engy_bat_var[p,t] >= M_eu*b_eu_var[p,t];'])];
    CommandC=[CommandC;cellstr(['subject to mu_eu_perp_eb_B {p in UNode, t in Time}:',...
        '\n\t\t mu_eu_var[p,t] <= M_eu * (1 - b_eu_var[p,t]) ;'])];
    CommandC=[CommandC;cellstr('\t')];
    CommandC=[CommandC;cellstr(['subject to mu_eu_perp_eb_C {p in UNode, t in Time}:',...
        '\n\t\t Engy_bat_var[p,t] <= Max_SOC_bat[p] ;'])];
    CommandC=[CommandC;cellstr('\t')];
end





Command=[CommandS;CommandCS;CommandP;CommandD;CommandO;CommandC];
fid=fopen('Automatic_Generated_AMPL_Model.mod','w');
for cc=1:length(Command)
    fprintf(fid,Command{cc,:});
    fprintf(fid,'\n');
end
% fclose(fid);
fclose('all');    