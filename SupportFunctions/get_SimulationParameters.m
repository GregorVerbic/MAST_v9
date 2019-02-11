function Output = get_SimulationParameters();
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
    %% Horizon Setup
    % Value of horizon length
    h = findobj('Tag','EHL');
    Output.Horizon_length = h.UserData.Horizon_length;
    
    % Value of sub-horizon length
    h = findobj('Tag','ESL');
    Output.Subhorizon_length = h.UserData.Subhorizon_length;
    
    % Value of overlap days
    h = findobj('Tag','EOD');
    Output.Overlap_days = h.UserData.Overlap_days; 
    
    % Value of Start day offset
    h = findobj('Tag','ESD');
    Output.StartDay_Offset = h.UserData.StartDay_Offset;
    
    %% System Parameters
    % Value of loss factor
    h = findobj('Tag','ELF');
    Output.Loss_factor = h.UserData.Loss_factor;
    
    % Value of power reserve
    h = findobj('Tag','EPR');
    Output.Power_reserve = h.UserData.Power_reserve;
    
    % Value of inertial reserve
    h = findobj('Tag','EIR');
    Output.Inertial_reserve = h.UserData.Inertial_reserve;
    
    % Value of base power
    h = findobj('Tag','EBP');
    Output.Base_power = h.UserData.Base_power;
    
    %% Solver
    % Solver engine 
    h = findobj('Tag','TSV');
    Output.Solver = h.String;
    
    % Solver options 
    h = findobj('Tag','TSO');
    Output.Solver_opt = h.String;
    %% System Parameters
    % Network detail level
    h = findobj('Tag','PND');
    Output.Network_Detail_level = h.Value;
    
%     % Utility RES
%     h = findobj('Tag','CRES');
%     Output.En_Uty_RES = h.UserData.En_Uty_RES;
    

    % Utility Storage
    h = findobj('Tag','CUS');
    Output.En_Uty_Strg = h.UserData.En_Uty_Strg;
    
    % Demand Responce
    h = findobj('Tag','CDR');
    Output.En_DR = h.UserData.En_DR;
 
    
    % Rooftop PV
    h = findobj('Tag','CRPV');
    Output.En_DR_PV = h.UserData.En_DR_PV;
    
    % Demand Responce
    h = findobj('Tag','CHB');
    Output.En_DR_Strg = h.UserData.En_DR_Strg;
    
    %% I/O Files
    % Model File
    h = findobj('Tag','EMF');
    Output.Model_filename = h.String;
    
    % Output File
    h = findobj('Tag','ESR');
    Output.Result_filename = h.String;
    h = findobj('Tag','CSR');
    Output.SR = h.UserData.SR;
    
    %% Folder Paths
    h = findobj('Tag','PPS');
    Output.Data_folder=h.UserData;
%     % Data folder
%     h = findobj('Tag','EDF');
%     Output.Data_folder = h.String;
%     
%     % AMPL path
%     h = findobj('Tag','EAP');
%     Output.AMPL_path = h.String;
    
    

    

end