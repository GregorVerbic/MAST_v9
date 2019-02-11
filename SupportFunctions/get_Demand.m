function [Date, Demand]=get_Demand(Offset,Node,T,Path)
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
% function to get PV generation profile from the NTDP files for specific 
% date and for specified number of days for rolling horizon scenario
% Output:
% Capacity: Output PV generation matrix
% Date: Vector containing dates of demand days
% Inputs:
% T: number of hours for which the data is required
% Offset: adress of the specific date
% Zone: Zone of RES
% Path: Data folder path
% Author: Shariq Riaz CFEN SEIE USYD 
% Date:20/10/17

NDy=T/24;             % Total number of days to keep
h=findobj('Tag','PPS');
Path=h.UserData.Dpaths.Load_Demand;
oldFolder = cd(Path);
Demand=[];
Date=[];
for nn=1:length(Node.Name)
    switch char(Node.Trace_Name.Demand(nn))
        case 'QLD'
            Demand_temp = csvread('2013 ESOO QLD1 Planning 10POE_0910refyr.csv'...
            ,Offset+1,0,[Offset+1,0,Offset+NDy,26]);
        case 'NSW'
            Demand_temp = csvread('2013 ESOO NSW1 Planning 10POE_0910refyr.csv'...
            ,Offset+1,0,[Offset+1,0,Offset+NDy,26]);
        case  'VIC'
            Demand_temp = csvread('2013 ESOO VIC1 Planning 10POE_0910refyr.csv'...
            ,Offset+1,0,[Offset+1,0,Offset+NDy,26]);
        case 'SA'
            Demand_temp = csvread('2013 ESOO SA1 Planning 10POE_0910refyr.csv'...
            ,Offset+1,0,[Offset+1,0,Offset+NDy,26]); 
        case 'TAS'
            Demand_temp = csvread('2013 ESOO TAS1 Planning 10POE_0910refyr.csv'...
            ,Offset+1,0,[Offset+1,0,Offset+NDy,26]);   
        case 'N_North'
            Demand_temp = csvread('N_North.csv'...
            ,Offset+1,0,[Offset+1,0,Offset+NDy,26]);
        case 'N_South'
            Demand_temp = csvread('N_South.csv'...
            ,Offset+1,0,[Offset+1,0,Offset+NDy,26]); 
        case 'N_East'
            Demand_temp = csvread('N_East.csv'...
            ,Offset+1,0,[Offset+1,0,Offset+NDy,26]);
        case 'N_West'
            Demand_temp = csvread('N_West.csv'...
            ,Offset+1,0,[Offset+1,0,Offset+NDy,26]);    
        otherwise
            try
                Demand_temp = csvread([char(Node.Trace_Name.Demand(nn)),'.csv']...
            ,Offset+1,0,[Offset+1,0,Offset+NDy,26]);                
            catch
                fprintf('###########Unsported Demand Trace###########\n');            
                cd(oldFolder)
                return;
            end
    end
    Date= [Date;Demand_temp(:,1:3)];
    Demand_temp=abs(Demand_temp(:,4:27));
    Demand_temp=Demand_temp';
    Demand_temp= Demand_temp(:); 
    Demand_temp=Demand_temp';
    Demand=[Demand;Node.Demand_Weightage(nn)*Demand_temp];
    
end
cd(oldFolder);
end