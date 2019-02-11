### SETS ###
set UGen;
set G_Syn in UGen;
set G_T1 in UGen;
param T>0;
set Time = 1..T;
set UBus;
set URegion;
set ULine;
	
### CROSS SETS LINKS ###
set Gen_Bus_links within (UGen cross UBus);
set Gen_Region_links within (UGen cross URegion);
set GenT1_Region_links within (G_T1 cross URegion);
set Line_end1_Bus_links within (ULine cross UBus);
set Line_end2_Bus_links within (ULine cross UBus);
set Bus_Region_links within (UBus cross URegion);


### Generator Cost Parameters ###
param C_Fix{UGen} >=0;
param C_Su{UGen} >=0;
param C_Sd{UGen} >=0;
param C_Var{UGen} >=0;
	
### Generator Parameters ###
param Max_pwr{UGen} >=0;
param Min_pwr{UGen} >=0;
param Ramp_up{UGen} >=0;
param Ramp_down{UGen} >=0;
param MUT{UGen}>=0;
param MDT{UGen}>=0;
param Units{UGen}>=0;
	
### Generator Initial Consitions ###
param Status_ini{UGen} >=0;
param Pwr_Gen_ini{UGen} >=0;
param MUT_ini{UGen,1..24} >=0;
param MDT_ini{UGen,1..24} >=0;
	
### Interconnector Parameters ###
param PwrLim{ULine} >=0;
param Susceptance{ULine};
	
### Demand Parameters ###
param Csm_Demand{UBus,Time} >=0;
param Psm_Demand{UBus,Time} >=0;
param Loss_factor >=0,<=1;
param PReserve_factor >=0,<=1;
param Base_power >=0;
	
### Generator Decision Variables ###
var Status_var {g in UGen,Time} integer >=0,<=Units[g];
var S_Up_var {UGen,Time} integer >=0;
var S_Down_var {UGen,Time} integer >=0;
var Pwr_Gen_var {UGen,Time} >=0;
	
### Interconnector Decision Variables ###
var Pwr_line_var {ULine,Time};


### Bus Angle Decision Variables ###
var Angle_bus_var {UBus,Time} >= -3.1416,<=3.1416;


### OBJECTIVE FUNCTION ###
minimize total_cost: sum {t in Time} sum {g in UGen}(C_Fix[g]*Status_var[g,t]
 + C_Su[g]*S_Up_var[g,t] + C_Sd[g]*S_Down_var[g,t] + C_Var[g]*Pwr_Gen_var[g,t] );


### Balance Constraint ###
subject to Balance {n in UBus, t in Time}: sum{(g,n) in Gen_Bus_links} Pwr_Gen_var[g,t]
 + sum{(l2,n) in Line_end2_Bus_links}(Pwr_line_var[l2,t]) 
== Csm_Demand[n,t] + Loss_factor*Csm_Demand[n,t] 
 + sum{(l1,n) in Line_end1_Bus_links}(Pwr_line_var[l1,t]);


### Active Power Reserve Constraint ###
subject to Power_Reserve {r in URegion, t in Time}: sum{(g,r) in GenT1_Region_links} Status_var[g,t]*Max_pwr[g]
 - sum{(g,r) in GenT1_Region_links} Pwr_Gen_var[g,t] 
>= sum{(n,r) in Bus_Region_links} PReserve_factor*Csm_Demand[n,t];


### Stable Limit of Generators Constraints ###
subject to Gen_max_pwr {g in G_Syn,t in Time}: Pwr_Gen_var[g,t] <= Max_pwr[g]*Status_var[g,t];
subject to Gen_min_pwr {g in G_Syn,t in Time}: Min_pwr[g]*Status_var[g,t] <= Pwr_Gen_var[g,t];
	
### Integer variable linking Constraint ###
subject to On_Off {g in G_Syn,t in 2..T}: S_Up_var[g,t] - S_Down_var[g,t] == Status_var[g,t] - Status_var[g,t-1];
subject to On_Off_initial {g in G_Syn}: S_Up_var[g,1] - S_Down_var[g,1] == Status_var[g,1] - Status_ini[g];
	
### Generator Ramping Constraints ###
subject to ramp_up {g in G_Syn, t in 2..T}:Ramp_up[g]<Max_pwr[g] ==> Pwr_Gen_var[g,t] - Pwr_Gen_var[g,t-1] <= Status_var[g,t]*Ramp_up[g];
subject to ramp_up_initial {g in G_Syn}:Ramp_up[g]<Max_pwr[g] ==> Pwr_Gen_var[g,1] - Pwr_Gen_ini[g] <= Status_var[g,1]*Ramp_up[g];
subject to ramp_down {g in G_Syn, t in 2..T}:Ramp_down[g]<Max_pwr[g] ==> Pwr_Gen_var[g,t-1] - Pwr_Gen_var[g,t] <= Status_var[g,t-1]*Ramp_down[g];
subject to ramp_down_initial {g in G_Syn}:Ramp_down[g]<Max_pwr[g] ==> Pwr_Gen_ini[g] - Pwr_Gen_var[g,1] <= Status_ini[g]*Ramp_down[g];
	
### Generator Minimum Up/Down Time Constraints ###
subject to min_up_Time {g in G_Syn, t in MUT[g]..T}:MUT[g]>1 ==> Status_var[g,t]
 >= sum{t1 in 0..MUT[g]-1} S_Up_var[g,t-t1]  ;
subject to min_up_Time_ini {g in G_Syn, t in 1..MUT[g]-1}:MUT[g]>1 ==> Status_var[g,t]
 >= sum{t1 in 0..t-1} S_Up_var[g,t-t1] + MUT_ini[g,t] ;
	
subject to min_down_Time {g in G_Syn, t in MDT[g]..T}:MDT[g]>1 ==> Status_var[g,t]
 <= Units[g] - sum{t1 in 0..MDT[g]-1} S_Down_var[g,t-t1] ;
subject to min_down_Time_ini {g in G_Syn, t in 1..MDT[g]-1}:MDT[g]>1 ==> Status_var[g,t]
 <= Units[g] - sum{t1 in 0..t-1} S_Down_var[g,t-t1] - MDT_ini[g,t] ;


### Maximum limit on ON units ###
subject to max_ONunits {g in UGen, t in Time}:
Status_var[g,t] <= Units[g];
### Thermal limits of interconnect Constraints ###
subject to thermal_limit_ub {l in ULine, t in Time}: Pwr_line_var [l,t] <= PwrLim[l];
subject to thermal_limit_lb {l in ULine, t in Time}: -PwrLim[l] <= Pwr_line_var[l,t] ;
	
### AC line angle stablility ###
subject to angle_limit {l in ULine, t in Time}: Pwr_line_var[l,t] == Base_power*Susceptance[l]*
 (sum{(l,n1) in Line_end1_Bus_links} Angle_bus_var[n1,t]- sum{(l,n2) in Line_end2_Bus_links} Angle_bus_var[n2,t]);


