function GUI_Ver1(hObject,eventdata);
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
    clc; close all; clear all;
    % Declaring figure size
    Fig_sz_cm=[16 7];
    set(0,'units','centimeters')    % size units
    SS_cm = get(0,'screensize');    % finding screen size
    % Creating figure in middle of screen
    h_Fmain = figure('Units','centimeters',...
        'MenuBar','none','Name','Market Simulation Tool',...
        'Position',[SS_cm(3)/2-Fig_sz_cm(1)/2 SS_cm(4)/2-Fig_sz_cm(2)/2 Fig_sz_cm(1) Fig_sz_cm(2)]);
    %h_Fmain.Color = [0.94,0.94,0.94];
    h_Fmain.Color = [0.94,0.94,0.94];
    %% Add folders and Subfolders
    cd(fileparts(which('MAST.m')))
    addpath(genpath(cd))
    
    %% Copyright
    h_Tcr=create_Text(h_Fmain,[0.2, 0.2, 9, 0.5],'Copyright ©2017. Shariq Riaz, Gregor Verbic, Archie C. Chapman.');

    %% Creating Panel for simulation horizon parameters
    pw=3.2;       % panel width
    ph=4.1;     % panel height

    h_Phs=create_Panel(h_Fmain,[.25 Fig_sz_cm(2)-ph pw ph],'Horizon setup');
    % Panel object parameters
    ow=0.75;    % object width
    oh=0.75;    % object height
    xsp=0.2;    % x-dir sepration
    ysp=0.2;    % y-dir sepration
    ytp=0.2;    % top gap     
    n=1;        % object number

    % Creating edit for horizon length
    h_Ehl=create_Edit(h_Phs,[pw-ow-xsp, ph-n*(oh+ysp)-ytp, ow, oh],'EHL');
    h_Ehl.Callback=@callback_Update_Edit;
    h_Thl=create_Text(h_Phs,[xsp, ph-n*(oh+ysp)-ytp, (pw-ow-2*xsp), oh],'Horizon length');
    n=n+1;
    % Creating edit for sub-horizon length
    h_Esl=create_Edit(h_Phs,[pw-ow-xsp, ph-n*(oh+ysp)-ytp, ow, oh],'ESL');
    h_Esl.Callback=@callback_Update_Edit;
    h_Thl=create_Text(h_Phs,[xsp, ph-n*(oh+ysp)-ytp, (pw-ow-2*xsp), oh],'Sub-horizon length');
    n=n+1;
    % Creating edit for ovelap days
    h_Eod=create_Edit(h_Phs,[pw-ow-xsp, ph-n*(oh+ysp)-ytp, ow, oh],'EOD');
    h_Eod.Callback=@callback_Update_Edit;
    h_Thl=create_Text(h_Phs,[xsp, ph-n*(oh+ysp)-ytp, (pw-ow-2*xsp), oh],'Overlap days');
    n=n+1;
    % Creating edit for start day offset
    ow=1;
    h_Esd=create_Edit(h_Phs,[pw-ow-xsp, ph-n*(oh+ysp)-ytp, ow, oh],'ESD');
    h_Esd.Callback=@callback_Update_Edit;
    h_Tsd=create_Text(h_Phs,[xsp, ph-n*(oh+ysp)-ytp, (pw-ow-2*xsp), oh],'Start day offset');

    clearvars pw ph ow oh xsp ysp ytp n;    % clearing panel variables


    %% Creating Panel for System Parameters
    pw=3;       % panel width
    ph=4.1;     % panel height
    h_Pop=create_Panel(h_Fmain,[3+.5 Fig_sz_cm(2)-ph pw ph],'System parameters');

    % Panel object parameters
    ow=0.75;    % object width
    oh=0.75;    % object height
    xsp=0.2;    % x-dir sepration
    ysp=0.2;    % y-dir sepration
    ytp=0.3;    % top gap     
    n=1;        % object number
    
    % Creating edit for loss factor
    h_Elf=create_Edit(h_Pop,[pw-ow-xsp, ph-n*(oh+ysp)-ytp, ow, oh],'ELF');
    h_Elf.Callback=@callback_Update_Edit;
    h_Tlf=create_Text(h_Pop,[xsp, ph-n*(oh+ysp)-ytp, (pw-ow-2*xsp), oh],'Transmission losses (%)');
    n=n+1;
    
    % Creating edit for Power Reserves
    h_Epr=create_Edit(h_Pop,[pw-ow-xsp, ph-n*(oh+ysp)-ytp, ow, oh],'EPR');
    h_Epr.Callback=@callback_Update_Edit;
    h_Tpr=create_Text(h_Pop,[xsp, ph-n*(oh+ysp)-ytp, (pw-ow-2*xsp), oh],'Spinning reserves (%)');
    n=n+1;
    % Creating edit for spinning inertial reserves
    h_Eir=create_Edit(h_Pop,[pw-ow-xsp, ph-n*(oh+ysp)-ytp, ow, oh],'EIR');
    h_Eir.Callback=@callback_Update_Edit;
    h_Tir=create_Text(h_Pop,[xsp, ph-n*(oh+ysp)-ytp, (pw-ow-2*xsp), oh],'Inertial reserves (%)');
    n=n+1;
    % Creating edit for Base Power (MVA)
    h_Ebp=create_Edit(h_Pop,[pw-ow-xsp, ph-n*(oh+ysp)-ytp+0.02, ow, oh],'EBP');
    h_Ebp.Callback=@callback_Update_Edit;
    h_Tbp=create_Text(h_Pop,[xsp, ph-n*(oh+ysp)-ytp, (pw-ow-2*xsp), oh],'Base power (MVA)');

    clearvars pw ph ow oh xsp ysp ytp n;    % clearing panel variables
    
    %% Creating Panel for Solver
    pw=2.9;       % panel width
    ph=2.3;     % panel height
    h_Psv=create_Panel(h_Fmain,[10+.25 2.8 pw ph],'Solver');

    % Panel object parameters
    ow=0.75;    % object width
    oh=0.75;    % object height
    xsp=0.2;    % x-dir sepration
    ysp=0.2;    % y-dir sepration
    ytp=0.2;    % top gap     
    n=1;        % object number

    % Solver Details
    h_Tsl=create_Text(h_Psv,[xsp, ph-n*(oh+ysp)-ytp, (pw-ow-2*xsp), oh],'Solver:');
    h_Tsv=create_Text(h_Psv,[xsp+1, ph-n*(oh+ysp)-ytp, (pw-ow-2*xsp), oh],'');
    h_Tsv.Tag='TSV';
    n=n+1;
    % Solver Options
    h_Tso=create_Text(h_Psv,[xsp, ph-n*(oh+ysp)-ytp+.5-oh, (pw-2*xsp), 2*oh],'');
    h_Tso.Tag='TSO';
    clearvars pw ph ow oh xsp ysp ytp n;    % clearing panel variables

    %% Creating Panel for System Elements
    pw=3.5;       % panel width
    ph=4.1;     % panel height
    h_Psp=create_Panel(h_Fmain,[6+0.6 Fig_sz_cm(2)-ph pw ph],'System elements');

    % Panel object parameters
    ow=0.75;    % object width
    oh=0.75;    % object height
    xsp=0.2;    % x-dir sepration
    ysp=0.2;    % y-dir sepration
    ytp=0.3;    % top gap     
    n=1;        % object number

    % Creating pop menu for selecting network details
    ow=1.7;
    h_PUMnd=create_PopUpMenu(h_Psp,[pw-ow-xsp, ph-n*(oh+ysp)-ytp, ow, oh],{'Cu Plate','Regional','Nodal'},'PND');
    h_PUMnd.Callback=@callback_Update_PopUpMenu;
    h_Tnd=create_Text(h_Psp,[xsp, ph-n*(oh+ysp)-ytp, (pw-ow-2*xsp), oh],'Network');
    n=n+1;
    % Creating check box for Utility RES
    ow=0.4;
    oh=0.5;
%     h_CBres=create_CheckBox(h_Psp,[pw-ow-xsp, ph-n*(oh+ysp)-ytp, ow, oh],'CRES');
%     h_CBres.Callback=@callback_Update_CheckBox;
%     h_Tres=create_Text(h_Psp,[xsp, ph-n*(oh+ysp)-ytp, (pw-ow-2*xsp), oh],'Utility RES');
%     n=n+1;
    % Creating check box for Utility Storage
    h_CBus=create_CheckBox(h_Psp,[pw-ow-xsp, ph-n*(oh+ysp)-ytp, ow, oh],'CUS');
    h_CBus.Callback=@callback_Update_CheckBox;
    h_Tus=create_Text(h_Psp,[xsp, ph-n*(oh+ysp)-ytp, (pw-ow-2*xsp), oh],'Utility storage');
    n=n+1;
    % Creating check box for Demand Response
    h_CBdr=create_CheckBox(h_Psp,[pw-ow-xsp, ph-n*(oh+ysp)-ytp, ow, oh],'CDR');
    h_CBdr.Callback=@callback_Update_CheckBox;
    h_Tdr=create_Text(h_Psp,[xsp, ph-n*(oh+ysp)-ytp, (pw-ow-2*xsp), oh],'Prosumers');
    n=n+1;
    % Creating check box for DR-PV
    h_CBpv=create_CheckBox(h_Psp,[pw-ow-xsp, ph-n*(oh+ysp)-ytp, ow, oh],'CRPV');
    h_CBpv.Callback=@callback_Update_CheckBox;
    h_Tpv=create_Text(h_Psp,[xsp, ph-n*(oh+ysp)-ytp, (pw-ow-2*xsp), oh],'Rooftop PV');
    n=n+1;
    % Creating check box for Household batteries
    h_CBhb=create_CheckBox(h_Psp,[pw-ow-xsp, ph-n*(oh+ysp)-ytp, ow, oh],'CHB');
    h_CBhb.Callback=@callback_Update_CheckBox;
    h_Thb=create_Text(h_Psp,[xsp, ph-n*(oh+ysp)-ytp, (pw-ow-2*xsp), oh],'Household batteries');
    n=n+1;

    clearvars pw ph ow oh xsp ysp ytp n;    % clearing panel variables
    %% Input Output Files
    pw=9.85;       % panel width
    ph=2;     % panel height
    h_Pio=create_Panel(h_Fmain,[.25 Fig_sz_cm(2)-ph-4.1 pw ph],'I/O files');

    % Panel object parameters
    ow=1.5;    % object width
    oh=0.5;    % object height
    xsp=0.2;    % x-dir sepration
    ysp=0.2;    % y-dir sepration
    ytp=0.3;    % top gap     
    n=1;        % object number
    
    % Input model 
    h_Tmf=create_Text(h_Pio,[xsp, ph-n*(oh+ysp)-ytp, ow, oh],['Model file:']);
    h_Emf=create_Edit(h_Pio,[ow+2*xsp, ph-n*(oh+ysp)-ytp, 4*ow, oh],'EMF');
    h_Emf.Callback=@callback_LoadModel;
    h_PBmf =create_PushButton(h_Pio,[pw-ow-xsp, ph-n*(oh+ysp)-ytp, ow, oh],'Load','PMF');
    h_PBmf.Callback=@callback_LoadModel;
    n=n+1;
    % Save Reselts 
    h_Tsr=create_Text(h_Pio,[xsp, ph-n*(oh+ysp)-ytp, ow, oh],['Save file:']);
    h_Esr=create_Edit(h_Pio,[ow+2*xsp, ph-n*(oh+ysp)-ytp, 4*ow, oh],'ESR');    
    h_Tsr2=create_Text(h_Pio,[pw-ow-xsp, ph-n*(oh+ysp)-ytp, ow-0.5, oh],['Enable:']);
    h_CBsr =create_CheckBox(h_Pio,[pw-ow-xsp+ow-.5, ph-n*(oh+ysp)-ytp, ow, oh],'CSR');
    h_CBsr.Callback=@callback_Update_CheckBox;
    
    
    
    %% Pushbuttons for various functions
    
    pw=2+2*0.25;       % panel width
    ph=Fig_sz_cm(2)-2*.25;     % panel height
    h_Ppb=create_Panel(h_Fmain,[Fig_sz_cm(1)-pw-xsp 0.3 pw ph],'');

    % Panel object parameters
    ow=2;    % object width
    oh=1;    % object height
    xsp=0.25;    % x-dir sepration
    ysp=0.25;    % y-dir sepration
    ytp=0;    % top gap     
    n=1;        % object number
    
    % Load Default
    h_PBld =create_PushButton(h_Ppb,[pw-ow-xsp, ph-n*(oh+ysp)-ytp, ow, oh],'Load Default','PLD');
    h_PBld.Callback=@callback_LoadDefaultValues;
    n=n+1;
    % Save Default
    h_PBsd =create_PushButton(h_Ppb,[pw-ow-xsp, ph-n*(oh+ysp)-ytp, ow, oh],'Save Default','PSD');
    h_PBsd.Callback=@callback_SaveDefaultValues;
    n=n+1;
    
    % Solver Parameter
    h_PBsp =create_PushButton(h_Ppb,[pw-ow-xsp, ph-n*(oh+ysp)-ytp, ow, oh],'Solver','PSP');
    h_PBsp.Callback=@gui_SolverSelection;
    n=n+1;
    
    % Plot Results
    h_PBpr =create_PushButton(h_Ppb,[pw-ow-xsp, ph-n*(oh+ysp)-ytp, ow, oh],'Plot','PPR');
    h_PBpr.Callback=@gui_Plot;
    n=n+1;
    
    % Initial Setup
    h_PBis =create_PushButton(h_Ppb,[pw-ow-xsp, ph-n*(oh+ysp)-ytp, ow, oh],'Path Setup','PPS');
    h_PBis.Callback=@gui_PathSetup;
    n=n+1;
    
    % Run Simulations
    
    h_PBrs =create_PushButton(h_Fmain,[10.2 0.25 3 2.5],'Run Simulation','PRS');
    h_PBrs.Callback=@callback_RunSimulations; 

    %% Power flow window push button
    h_PBpf =create_PushButton(h_Fmain,[10.2 Fig_sz_cm(2)-2 3 1.75],'Power Flow','PPF');
    h_PBpf.Callback=@gui_PowerFlow;
    
    callback_LoadDefaultValues();
end


%% Function to load model file 
function callback_LoadModel(hObject,eventdata)
    if strcmp(hObject.Tag,'PMF')    
        hObject.BackgroundColor = [1,1,0];
        S=uigetfile({'*.xlsx';'*.slx'},'Select Model File');
        if S
            convert_ExcelModeltoData(S);
        end
        hObject.BackgroundColor = [0.94,0.94,0.94];
        h = findobj('Tag','EMF');
        h.String=S;
    elseif strcmp(hObject.Tag,'EMF')    
        hObject.BackgroundColor = [1,1,0];
         pause(1e-9)
        [fold file ext]=fileparts(hObject.String);
        Search=dir(['*',ext]);
        for ii=1:length(Search)
            if strcmp(hObject.String,Search(ii).name)
                convert_ExcelModeltoData(hObject.String);
                hObject.BackgroundColor = [1,1,1];
                break;
            end
            if ii== length(Search)
                hObject.BackgroundColor = [1,0,0];
            end
        end
    end
end

%% function to save default simulation parameters

function callback_SaveDefaultValues(hObject,eventdata)
    hObject.BackgroundColor = [1,1,0];
    pause(1e-9)  
    Values=get_SimulationParameters();    
    %% Saving Data
    if ispc
        save('Data\DefaultValues.mat','Values');
    elseif ismac
        save('Data/DefaultValues.mat','Values');
    elseif isunix
        save('Data/DefaultValues.mat','Values');
    end
    hObject.BackgroundColor = [0.94,0.94,0.94];
end


%% function to load default simulation parameters

function callback_LoadDefaultValues(hObject,eventdata)
    hObject.BackgroundColor = [1,1,0];
    pause(1e-9)
    if ispc
        load('Data\DefaultValues.mat','Values');
    elseif ismac
        load('Data/DefaultValues.mat','Values');
    elseif isunix
        load('Data/DefaultValues.mat','Values');
    end
    Data=Values;
    %% Horizon Setup
    % Value of horizon length
    h = findobj('Tag','EHL');
    h.UserData = struct('Horizon_length',Data.Horizon_length);
    h.String = h.UserData.Horizon_length;
    
    % Value of sub-horizon length
    h = findobj('Tag','ESL');
    h.UserData = struct('Subhorizon_length',Data.Subhorizon_length);
    h.String = h.UserData.Subhorizon_length;
    
    % Value of overlap days
    h = findobj('Tag','EOD');
    h.UserData = struct('Overlap_days',Data.Overlap_days);
    h.String = h.UserData.Overlap_days; 
    
    % Value of Start day offset
    h = findobj('Tag','ESD');
    h.UserData = struct('StartDay_Offset',Data.StartDay_Offset);
    h.String = h.UserData.StartDay_Offset;
    
    %% System parameters
    % Value of loss factor
    h = findobj('Tag','ELF');
    h.UserData = struct('Loss_factor',Data.Loss_factor);
    h.String = h.UserData.Loss_factor;
    
    % Value of power reserve
    h = findobj('Tag','EPR');
    h.UserData = struct('Power_reserve',Data.Power_reserve);
    h.String = h.UserData.Power_reserve;
    
    % Value of inertial reserve
    h = findobj('Tag','EIR');
    h.UserData = struct('Inertial_reserve',Data.Inertial_reserve);
    h.String = h.UserData.Inertial_reserve;
    
    % Value of Base MVA
    h = findobj('Tag','EBP');
    h.UserData = struct('Base_power',Data.Base_power);
    h.String = h.UserData.Base_power;
    
    %% Solver
    % Solver engine    
    h = findobj('Tag','TSV');
    h.String = Data.Solver;
    
    % Solver Options
    h = findobj('Tag','TSO');
    h.String = Data.Solver_opt;
    %% System elements
    % Network detail level
    h = findobj('Tag','PND');
    h.UserData = struct('Network_Detail_level',Data.Network_Detail_level);
    h.Value = h.UserData.Network_Detail_level;
  

    % Utility Storage
    h = findobj('Tag','CUS');
    h.UserData = struct('En_Uty_Strg',Data.En_Uty_Strg);
    h.Value = h.UserData.En_Uty_Strg;
    
    % Demand Responce
    h = findobj('Tag','CDR');
    h.UserData = struct('En_DR',Data.En_DR);
    h.Value = h.UserData.En_DR;
    denable_RPV_HB(h.Value);
    
    % Rooftop PV
    h = findobj('Tag','CRPV');
    h.UserData = struct('En_DR_PV',Data.En_DR_PV);
    h.Value = h.UserData.En_DR_PV;
    
    % Demand Responce
    h = findobj('Tag','CHB');
    h.UserData = struct('En_DR_Strg',Data.En_DR_Strg);
    h.Value = h.UserData.En_DR_Strg;    
    
    
    % Model File
    h = findobj('Tag','EMF');
    h.String = Data.Model_filename;
    
    %% I/O File
    
    h = findobj('Tag','ESR');
    h.String = Data.Result_filename;
    
    h = findobj('Tag','CSR');
    h.UserData = struct('SR',Data.SR);
    h.Value = h.UserData.SR;
    denable_ESR(h.Value);
    
    %% Folder Paths
    
    h = findobj('Tag','PPS');
    h.UserData=struct('Dpaths',Values.Data_folder.Dpaths);
%     % Data folder
%     h = findobj('Tag','EDF');
%     h.String = Values.Data_folder;
%     
%     % AMPL path
%     h = findobj('Tag','EAP');
%     h.String = Values.AMPL_path; 
    %%
    hObject.BackgroundColor = [0.94,0.94,0.94];    
end

function callback_GetDirectory_path(hObject,eventdata)    
    if strcmp(hObject.Tag(1),'P')    
        hObject.BackgroundColor = [1,1,0];
        if (hObject.Tag == 'PDF')
            S=uigetdir('','Select Data Folder');
        elseif (hObject.Tag == 'PAP')
            S=uigetdir('','Select AMPL Path');
        end            
        hObject.BackgroundColor = [0.94,0.94,0.94];
        h = findobj('Tag',['E',hObject.Tag(2:end)]);
        h.String=S;
    elseif strcmp(hObject.Tag(1),'E')    
        hObject.BackgroundColor = [1,1,0];
        pause(1e-9)
        if isdir(hObject.String)
            hObject.BackgroundColor = [1,1,1];
        else
            hObject.BackgroundColor = [1,0,0];
        end
    end
end

