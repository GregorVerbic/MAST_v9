function [Date PV_prf]=get_PV_Trace(Offset,Trace_Name,T,Path)
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
% function to get rooftop PV generation profile from the NTDP files for specific 
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
% Date:17/01/17

NDy=T/24;             % Total number of days to keep
h=findobj('Tag','PPS');
Path=h.UserData.Dpaths.Utility_PV;
oldFolder = cd(Path);
switch char(Trace_Name)         
    case 'NQ'
        Offset=Offset+365*3+1;
        PV_temp = csvread('NQ Solar Real PV.csv'...
        ,Offset+1,0,[Offset+1,0,Offset+NDy,26]);
    case 'CQ'
        Offset=Offset+365*3+1;
        PV_temp = csvread('CQ Solar Real PV.csv'...
        ,Offset+1,0,[Offset+1,0,Offset+NDy,26]);
    case  'SEQ'
        Offset=Offset+365*3+1;
        PV_temp = csvread('SEQ Solar Real PV.csv'...
        ,Offset+1,0,[Offset+1,0,Offset+NDy,26]);
    case 'SWQ'
        Offset=Offset+365*3+1;
        PV_temp = csvread('SWQ Solar Real PV.csv'...
        ,Offset+1,0,[Offset+1,0,Offset+NDy,26]);
    case 'NNS'
        Offset=Offset+365*3+1;
        PV_temp = csvread('NNS Solar Real PV.csv'...
        ,Offset+1,0,[Offset+1,0,Offset+NDy,26]);
    case 'NCEN'
        Offset=Offset+365*3+1;
        PV_temp = csvread('NCEN Solar Real PV.csv'...
        ,Offset+1,0,[Offset+1,0,Offset+NDy,26]);
    case 'CAN'
        Offset=Offset+365*3+1;
        PV_temp = csvread('CAN Solar Real PV.csv'...
        ,Offset+1,0,[Offset+1,0,Offset+NDy,26]);
    case 'SWNSW'
        Offset=Offset+365*3+1;
        PV_temp = csvread('SWNSW Solar Real PV.csv'...
        ,Offset+1,0,[Offset+1,0,Offset+NDy,26]);
    case 'CVIC'
        Offset=Offset+365*3+1;
        CST_temp = csvread('CVIC Solar Real PV.csv'...
        ,Offset+1,0,[Offset+1+365*3+1,0,Offset+NDy,26]);    
    case 'NVIC'
        Offset=Offset+365*3+1;
        PV_temp = csvread('NVIC Solar Real PV.csv'...
        ,Offset+1,0,[Offset+1,0,Offset+NDy,26]);
    case 'MEL'
        Offset=Offset+365*3+1;
        PV_temp = csvread('MEL Solar Real PV.csv'...
        ,Offset+1,0,[Offset+1,0,Offset+NDy,26]);
    case 'LV'
        Offset=Offset+365*3+1;
        PV_temp = csvread('LV Solar Real PV.csv'...
        ,Offset+1,0,[Offset+1,0,Offset+NDy,26]);
    case 'SESA'
        Offset=Offset+365*3+1;
        PV_temp = csvread('SESA Solar Real PV.csv'...
        ,Offset+1,0,[Offset+1,0,Offset+NDy,26]);
    case 'ADE'
        Offset=Offset+365*3+1;
        PV_temp = csvread('ADE Solar Real PV.csv'...
        ,Offset+1,0,[Offset+1,0,Offset+NDy,26]);
    case 'NSA'
        Offset=Offset+365*3+1;
        PV_temp = csvread('NSA Solar Real PV.csv'...
        ,Offset+1,0,[Offset+1,0,Offset+NDy,26]);
    case 'N_North'
        PV_temp = csvread('N_North.csv'...
        ,Offset+1,0,[Offset+1,0,Offset+NDy,26]);
    case 'N_South'
        PV_temp = csvread('N_South.csv'...
        ,Offset+1,0,[Offset+1,0,Offset+NDy,26]); 
    case 'N_East'
        PV_temp = csvread('N_East.csv'...
        ,Offset+1,0,[Offset+1,0,Offset+NDy,26]);
    case 'N_West'
        PV_temp = csvread('N_West.csv'...
        ,Offset+1,0,[Offset+1,0,Offset+NDy,26]);
    otherwise
            try
                PV_temp = csvread([char(Node.Trace_Name.PV(nn)),'.csv']...
            ,Offset+1,0,[Offset+1,0,Offset+NDy,26]);                
            catch
                fprintf('###########Unsported PV Trace###########\n');            
                cd(oldFolder)
                return;
            end
end
Date= [PV_temp(:,1:3)];
PV_temp=abs(PV_temp(:,4:27));
PV_temp=PV_temp';
PV_temp= PV_temp(:); 
PV_prf=PV_temp';
    
cd(oldFolder)
end