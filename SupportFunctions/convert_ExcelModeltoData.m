function convert_ExcelModeltoData(filename)
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
%% Loading data 
% reading generator data in number num, txt and raw format
fprintf('Importing Data\n')
[N T R]=xlsread(filename,'Generator Data','','basic');
[ed,temp]=find(strcmp(R,'END OF DATA'));    % finding last line of sheet
% formating data
temp=find(strcmp(R(1,:),'Connected to Grid'));
Ctd_gen=find((isnumber(R(2:ed-1,temp),R(1,temp)))>0)+1; % finding index of connected generators
temp=find(strcmp(R(1,:),'Number of Units'));    
Gen.N_units = isnumber(R(Ctd_gen,temp),R(1,temp));
temp=find(strcmp(R(1,:),'Fix Cost ($)')); 
Gen.Cost_Fix = isnumber(R(Ctd_gen,temp),R(1,temp));
temp=find(strcmp(R(1,:),'Start up Cost ($)')); 
Gen.Cost_Start_Up = isnumber(R(Ctd_gen,temp),R(1,temp));
temp=find(strcmp(R(1,:),'Shut down Cost ($)')); 
Gen.Cost_Shut_Down = isnumber(R(Ctd_gen,temp),R(1,temp));
temp=find(strcmp(R(1,:),'Variable Cost ($/MW)')); 
Gen.Cost_Variable = isnumber(R(Ctd_gen,temp),R(1,temp));
temp=find(strcmp(R(1,:),'Apparent Power Rating (MVA)')); 
Gen.Power_Rating = isnumber(R(Ctd_gen,temp),R(1,temp));
temp=find(strcmp(R(1,:),'Maximum Real Power (MW)')); 
Gen.Max_Real_Power = isnumber(R(Ctd_gen,temp),R(1,temp));
temp=find(strcmp(R(1,:),'Minimum Real Power (MW)')); 
Gen.Min_Real_Power = isnumber(R(Ctd_gen,temp),R(1,temp));
temp=find(strcmp(R(1,:),'Maximum Reactive Power (MVar)')); 
Gen.Max_Reactive_Power = isnumber(R(Ctd_gen,temp),R(1,temp));
temp=find(strcmp(R(1,:),'Minimum Reactive Power (MVar)')); 
Gen.Min_Reactive_Power = isnumber(R(Ctd_gen,temp),R(1,temp));
temp=find(strcmp(R(1,:),'Ramp Up Rate (MW/h)')); 
Gen.Ramp_Up_Rate = isnumber(R(Ctd_gen,temp),R(1,temp));
temp=find(strcmp(R(1,:),'Ramp Down Rate (MW/h)')); 
Gen.Ramp_Down_Rate = isnumber(R(Ctd_gen,temp),R(1,temp));
temp=find(strcmp(R(1,:),'MUT (hour)')); 
Gen.MUT = isnumber(R(Ctd_gen,temp),R(1,temp));
temp=find(strcmp(R(1,:),'MDT (hour)')); 
Gen.MDT = isnumber(R(Ctd_gen,temp),R(1,temp));
temp=find(strcmp(R(1,:),'Location Bus')); 
Gen.Bus = isname(R(Ctd_gen,temp),R(1,temp));
temp=find(strcmp(R(1,:),'Plot Color')); 
Gen.Color = isname(R(Ctd_gen,temp),R(1,temp));
temp=find(strcmp(R(1,:),'Generator Name')); 
Gen.Name = isname(R(Ctd_gen,temp),R(1,temp)); 
temp=find(strcmp(R(1,:),'Generation Tech')); 
Gen.Tech = isname(R(Ctd_gen,temp),R(1,temp));
temp=find(strcmp(R(1,:),'Generation Type'));
Gen.Type = isnumber(R(Ctd_gen,temp),R(1,temp));
if sum(Gen.Type>3)
    fprintf('Unknown Generator type component numer')
    fprintf('%d ',find(Gen.Type>3))
    fprintf('\n')
end
temp3=find((isnumber(R(2:end-1,temp),R(1,temp)))==3)+1;      % +1 header offset
temp=find(strcmp(R(1,:),'Resource Collector Rating (MW)')); 
Gen.Trace_Factor = isnumber(R(temp3,temp),R(1,temp));
temp=find(strcmp(R(1,:),'Maximum TES Capacity (MWh)')); 
Gen.Maximum_TES = isnumber(R(temp3,temp),R(1,temp));
temp=find(strcmp(R(1,:),'Minimum TES Limit (MWh)')); 
Gen.Minimum_TES = isnumber(R(temp3,temp),R(1,temp));
temp=find(strcmp(R(1,:),'TES Efficiency (%)')); 
Gen.TES_Efficiency = 1/100*isnumber(R(temp3,temp),R(1,temp));

fprintf('Read %4d Generators Data\n',length(Ctd_gen))
%% reading utility storage data in number num, txt and raw format 
[N T R]=xlsread(filename,'Utility Storage Data','','basic');
[ed,temp]=find(strcmp(R,'END OF DATA')); 
% formating data 
temp=find(strcmp(R(1,:),'Connected to Grid'));
Ctd_Strg=find((isnumber(R(2:ed-1,temp),R(1,temp)))>0)+1; % finding index of connected generators
temp=find(strcmp(R(1,:),'Maximum Storage Capacity (MWh)'));    
Uty_Strg.Maximum_Capacity = cell2mat(R(Ctd_Strg,temp));
temp=find(strcmp(R(1,:),'Minimum Storage Capacity (MWh)'));    
Uty_Strg.Minimum_Capacity = cell2mat(R(Ctd_Strg,temp));
temp=find(strcmp(R(1,:),'Maximum Charge Rate (MW/h)'));    
Uty_Strg.Maximum_ChargeRate = cell2mat(R(Ctd_Strg,temp));
temp=find(strcmp(R(1,:),'Maximum Discharge Rate (MW/h)'));    
Uty_Strg.Maximum_DischargeRate = cell2mat(R(Ctd_Strg,temp));
temp=find(strcmp(R(1,:),'Storage Efficiency (%)'));    
Uty_Strg.Efficiency =0.01*cell2mat(R(Ctd_Strg,temp));
temp=find(strcmp(R(1,:),'Location Bus'));    
Uty_Strg.Bus =R(Ctd_Strg,temp);
temp=find(strcmp(R(1,:),'Utility Storage Name'));    
Uty_Strg.Name =R(Ctd_Strg,temp);
temp=find(strcmp(R(1,:),'Plot Color'));    
Uty_Strg.Color =R(Ctd_Strg,temp);
fprintf('Read %4d Utility Storage Data\n',length(Ctd_Strg))
%% reading utility node data in number num, txt and raw format 
[N T R]=xlsread(filename,'Bus Data','','basic');
[ed,temp]=find(strcmp(R,'END OF DATA'));
% formating data 
temp=find(strcmp(R(1,:),'Demand Trace Weightage'));    
Bus.Demand_Weightage = cell2mat(R(2:ed-1,temp));
temp=find(strcmp(R(1,:),'Power Factor'));    
Bus.Power_Factor = cell2mat(R(2:ed-1,temp));
temp=find(strcmp(R(1,:),'Prosumer Demand (%)'));    
Bus.Prosumer_Weightage = 1/100*cell2mat(R(2:ed-1,temp));
temp=find(strcmp(R(1,:),'Rooftop PV Capacity (MW)'));    
Bus.PV_Capacity = cell2mat(R(2:ed-1,temp));
temp=find(strcmp(R(1,:),'Feedin Price Ratio')); 
Bus.Feedin_price_ratio = cell2mat(R(2:ed-1,temp));
temp=find(strcmp(R(1,:),'Maximum Battery Capacity (MWh)'));    
Bus.Battery.Maximum_Capacity = cell2mat(R(2:ed-1,temp));
temp=find(strcmp(R(1,:),'Minimum Battery Capacity (MWh)'));    
Bus.Battery.Minimum_Capacity = cell2mat(R(2:ed-1,temp));
temp=find(strcmp(R(1,:),'Maximum Charge Rate (MW/h)'));    
Bus.Battery.Maximum_ChargeRate = cell2mat(R(2:ed-1,temp));
temp=find(strcmp(R(1,:),'Maximum Discharge Rate (MW/h)'));    
Bus.Battery.Maximum_DischargeRate = cell2mat(R(2:ed-1,temp));
temp=find(strcmp(R(1,:),'Minimum Voltage (pu)'));    
Bus.Minimum_Voltage_limit_pu = cell2mat(R(2:ed-1,temp));
temp=find(strcmp(R(1,:),'Maximum Voltage (pu)'));    
Bus.Maximum_Voltage_limit_pu = cell2mat(R(2:ed-1,temp));
temp=find(strcmp(R(1,:),'Base_kV'));    
Bus.Base_kV = cell2mat(R(2:ed-1,temp));
temp=find(strcmp(R(1,:),'Battery Efficiency (%)'));    
Bus.Battery.Efficiency = 0.01*cell2mat(R(2:ed-1,temp));
temp=find(strcmp(R(1,:),'Bus Name'));
Bus.Name = R(2:ed-1,temp);
temp=find(strcmp(R(1,:),'Bus Region'));
Bus.Region = R(2:ed-1,temp);
temp=find(strcmp(R(1,:),'Bus Type'));
Bus.Type = cell2mat(R(2:ed-1,temp));
temp=find(strcmp(R(1,:),'Demand Trace Name'));
Bus.Trace_Name.Demand = R(2:ed-1,temp);
temp=find(strcmp(R(1,:),'Wind Trace Name'));
Bus.Trace_Name.Wind = R(2:ed-1,temp);
temp=find(strcmp(R(1,:),'PV Trace Name'));
Bus.Trace_Name.PV = R(2:ed-1,temp);
temp=find(strcmp(R(1,:),'CST Trace Name'));
Bus.Trace_Name.CST = R(2:ed-1,temp);
temp=find(strcmp(R(1,:),'Rooftop PV Trace Name'));
Bus.Trace_Name.RTPV = R(2:ed-1,temp);
fprintf('Read %4d Bus Data\n',length(Bus.Demand_Weightage))
%% reading branch data in number num, txt and raw format 
[N T R]=xlsread(filename,'Branch Data','','basic'); 
[ed,temp]=find(strcmp(R,'END OF DATA'));
% formating data 
temp=find(strcmp(R(1,:),'In Service'));
Ctd_Branch=find((isnumber(R(2:ed-1,temp),R(1,temp)))>0)+1; % finding index of in service branches
temp=find(strcmp(R(1,:),'Thermal Limit (MVA)'));
Line.Capacity = cell2mat(R(Ctd_Branch,temp));
temp=find(strcmp(R(1,:),'Resistance (pu)'));    
Line.r = cell2mat(R(Ctd_Branch,temp));
temp=find(strcmp(R(1,:),'Reactance (pu)'));    
Line.x = cell2mat(R(Ctd_Branch,temp));    
Line.B = 1./cell2mat(R(Ctd_Branch,temp));
temp=find(strcmp(R(1,:),'Susceptance (pu)'));    
Line.b = cell2mat(R(Ctd_Branch,temp));
temp=find(strcmp(R(1,:),'Maximum Angle Limit (degree)'));    
Line.Max_Angle = cell2mat(R(Ctd_Branch,temp));
temp=find(strcmp(R(1,:),'Line Name'));
Line.Name = R(Ctd_Branch,temp);
temp=find(strcmp(R(1,:),'End 1 Bus Name'));
Line.End_1_Bus = R(Ctd_Branch,temp);
temp=find(strcmp(R(1,:),'End 2 Bus Name'));
Line.End_2_Bus = R(Ctd_Branch,temp);
temp=find(strcmp(R(1,:),'Nature of Line'));
Line.type = R(Ctd_Branch,temp);
fprintf('Read %4d Line Data\n',length(Ctd_Branch))
%% reading SVC data in number num, txt and raw format 
[N T R]=xlsread(filename,'SVC Data','','basic'); 
[ed,temp]=find(strcmp(R,'END OF DATA'));
% formating data 
temp=find(strcmp(R(1,:),'Connected to Grid'));
Ctd_SVC=find((isnumber(R(2:ed-1,temp),R(1,temp)))>0)+1; % finding index of connected generators
temp=find(strcmp(R(1,:),'Bus Name'));
SVC.Bus = R(Ctd_SVC,temp);
temp=find(strcmp(R(1,:),'SVC Name'));
SVC.Name = R(Ctd_SVC,temp);
temp=find(strcmp(R(1,:),'Maximum Real Power (MW)')); 
SVC.Max_Real_Power = isnumber(R(Ctd_SVC,temp),R(1,temp));
temp=find(strcmp(R(1,:),'Minimum Real Power (MW)')); 
SVC.Min_Real_Power = isnumber(R(Ctd_SVC,temp),R(1,temp));
temp=find(strcmp(R(1,:),'Maximum Reactive Power (MVar)')); 
SVC.Max_Reactive_Power = isnumber(R(Ctd_SVC,temp),R(1,temp));
temp=find(strcmp(R(1,:),'Minimum Reactive Power (MVar)')); 
SVC.Min_Reactive_Power = isnumber(R(Ctd_SVC,temp),R(1,temp));
temp=find(strcmp(R(1,:),'Fix Cost ($)')); 
SVC.Cost_Fix = isnumber(R(Ctd_SVC,temp),R(1,temp));
temp=find(strcmp(R(1,:),'Start up Cost ($)')); 
SVC.Cost_Start_Up = isnumber(R(Ctd_SVC,temp),R(1,temp));
temp=find(strcmp(R(1,:),'Shut down Cost ($)')); 
SVC.Cost_Shut_Down = isnumber(R(Ctd_SVC,temp),R(1,temp));
temp=find(strcmp(R(1,:),'Variable Cost ($/MW)')); 
SVC.Cost_Variable = isnumber(R(Ctd_SVC,temp),R(1,temp));
fprintf('Read %4d SVC Data\n',length(Ctd_SVC))

% formating implicit parameters

Parameter.G = length(unique(Gen.Name));                 % Number of Generators
Parameter.R = length(unique(Bus.Region));               % Number of Regions
Parameter.B = length(unique(Bus.Name));                 % Number of Buses
Parameter.S = length(unique(Uty_Strg.Name));            % Number of Utility-Storages
Parameter.L = length(unique(Line.Name));                % Number of Lines
Parameter.V = length(unique(SVC.Name));                % Number of SVCs 
Bus.Prosumer = find((Bus.Prosumer_Weightage~=0 & ~isnan(Bus.Prosumer_Weightage)));
for gg=1:Parameter.G
    Gen.Region(gg,1)=Bus.Region(find(strcmp(Gen.Bus(gg),Bus.Name)));
end
% saving data in .mat format
if ispc
    save('Data\Model.mat','Gen','Line','Uty_Strg','Bus','SVC','Parameter');
elseif ismac
    save('Data/Model.mat','Gen','Line','Uty_Strg','Bus','SVC','Parameter');
elseif isunix
    save('Data/Model.mat','Gen','Line','Uty_Strg','Bus','SVC','Parameter');
end

end

function Output=isnumber(Input,Name)
%function to check validity of numbers imported from excel file
%Input: Data in cell format
%Name: name of the column being read
Output=cell2mat(Input);
 if(sum(isnan(Output)))
     fprintf('Error reading %s component number:', char(Name))
     fprintf('%d ',find(isnan(Output)==1)')
     fprintf('\n')
 end 
end

function Output=isname(Input,Name)
%function to check validity of names imported from excel file
%Input: Data in cell format
%Name: name of the column being read
Output=Input;
 if~(sum(ischar(char(Output))))
     fprintf('Error reading %s; all enteries must be of class char\n', char(Name))
 end 
end

