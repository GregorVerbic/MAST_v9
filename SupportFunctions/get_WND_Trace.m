function [Date WND_prf]=get_WND_Trace(Offset,Trace_Name,T,Path)
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
% function to get WND generation profile from the NTDP files for specific 
% date and for specified number of days for rolling horizon scenario
% Output:
% WND_Gen: Output WND generation matrix
% Date: Vector containing dates of demand days
% Inputs:
% T: number of hours for which the data is required
% Offset: adress of the specific date
% Zone: Zone of RES
% Path: Data folder path
% Author: Shariq Riaz CFEN SEIE USYD 
% Date:17/11/17

NDy=T/24;             % Total number of days to keep
h=findobj('Tag','PPS');
Path=h.UserData.Dpaths.Wind;
oldFolder = cd(Path);

switch char(Trace_Name) 
    case 'NQ'
        Offset=Offset+365*3+1;
        WND_temp = csvread('NQ T1.csv'...
        ,Offset+1,0,[Offset+1,0,Offset+NDy,26]);
    case 'CQ'
        Offset=Offset+365*3+1;
        WND_temp = csvread('NQ T2.csv'...
        ,Offset+1,0,[Offset+1,0,Offset+NDy,26]);
    case 'SEQ'
        Offset=Offset+365*3+1;
        WND_temp = csvread('SWQ T2.csv'...
        ,Offset+1,0,[Offset+1,0,Offset+NDy,26]);
    case 'SWQ'
        Offset=Offset+365*3+1;
        WND_temp = csvread('SWQ T1.csv'...
        ,Offset+1,0,[Offset+1,0,Offset+NDy,26]);
    case 'NNS'
        Offset=Offset+365*3+1;
        WND_temp = csvread('NNS T1.csv'...
        ,Offset+1,0,[Offset+1,0,Offset+NDy,26]);
    case 'NCEN'
        Offset=Offset+365*3+1;
        WND_temp = csvread('NCEN T1.csv'...
        ,Offset+1,0,[Offset+1,0,Offset+NDy,26]);
    case 'CAN'
        Offset=Offset+365*3+1;
        WND_temp = csvread('CAN T1.csv'...
        ,Offset+1,0,[Offset+1,0,Offset+NDy,26]);
    case 'SWNSW'
        Offset=Offset+365*3+1;
        WND_temp = csvread('SWNSW T1.csv'...
        ,Offset+1,0,[Offset+1,0,Offset+NDy,26]);
    case 'NVIC'
        Offset=Offset+365*3+1;
        WND_temp = csvread('CVIC T1.csv'...
        ,Offset+1,0,[Offset+1,0,Offset+NDy,26]);
    case 'CVIC'
        Offset=Offset+365*3+1;
        WND_temp = csvread('CVIC T1.csv'...
        ,Offset+1,0,[Offset+1,0,Offset+NDy,26]);
    case 'MEL'
        Offset=Offset+365*3+1;
        WND_temp = csvread('MEL T1.csv'...
        ,Offset+1,0,[Offset+1,0,Offset+NDy,26]);
    case 'LV'
        Offset=Offset+365*3+1;
        WND_temp = csvread('LV T1.csv'...
        ,Offset+1,0,[Offset+1,0,Offset+NDy,26]);
    case 'SESA'
        Offset=Offset+365*3+1;
        WND_temp = csvread('SESA T1.csv'...
        ,Offset+1,0,[Offset+1,0,Offset+NDy,26]);
    case 'ADE'
        Offset=Offset+365*3+1;
        WND_temp = csvread('SESA T2.csv'...
        ,Offset+1,0,[Offset+1,0,Offset+NDy,26]);
    case 'NSA'
        Offset=Offset+365*3+1;
        WND_temp = csvread('NSA T1.csv'...
        ,Offset+1,0,[Offset+1,0,Offset+NDy,26]);
    case 'N_North'
        WND_temp = csvread('N_North.csv'...
        ,Offset+1,0,[Offset+1,0,Offset+NDy,26]);
    case 'N_South'
        WND_temp = csvread('N_South.csv'...
        ,Offset+1,0,[Offset+1,0,Offset+NDy,26]); 
    case 'N_East'
        WND_temp = csvread('N_East.csv'...
        ,Offset+1,0,[Offset+1,0,Offset+NDy,26]);
    case 'N_West'
        WND_temp = csvread('N_West.csv'...
        ,Offset+1,0,[Offset+1,0,Offset+NDy,26]);
    otherwise
            try
                WND_temp = csvread([char(Node.Trace_Name.Wind(nn)),'.csv']...
            ,Offset+1,0,[Offset+1,0,Offset+NDy,26]);                
            catch
                fprintf('###########Unsported Wind Trace###########\n');            
                cd(oldFolder)
                return;
            end  
end
Date= WND_temp(:,1:3);
WND_temp=abs(WND_temp(:,4:27));
WND_temp=WND_temp';
WND_temp= WND_temp(:); 
WND_prf=WND_temp';
cd(oldFolder);
end