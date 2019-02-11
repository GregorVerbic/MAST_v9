function gui_PathSetup(hObject,handles)
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
    try
        h_temp=findobj('Name','Path Setup');
        close(h_temp);
    catch
    end
    
    % Declaring figure size
    Fig_sz_cm=[12 6];
    set(0,'units','centimeters')    % size units
    SS_cm = get(0,'screensize');    % finding screen size
    % Creating figure in middle of screen
    h_Pps = figure('Units','centimeters',...
        'MenuBar','none','Name','Path Setup',...
        'Position',[SS_cm(3)/2-Fig_sz_cm(1)/2 SS_cm(4)/2-Fig_sz_cm(2)/2 Fig_sz_cm(1) Fig_sz_cm(2)]);
    
     %% Files paths
    pw=11.5;       % panel width
    ph=4.75;     % panel height
    h_Pfp=create_Panel(h_Pps,[0.25 Fig_sz_cm(2)-ph pw ph],'Folder paths');

    % Panel object parameters
    ow=2;    % object width
    oh=0.5;    % object height
    xsp=0.2;    % x-dir sepration
    ysp=0.2;    % y-dir sepration
    ytp=0.3;    % top gap     
    n=1;        % object number
    
    h=findobj('Tag','PPS');    
    % AMPL Path 
    h_Tap=create_Text(h_Pfp,[xsp, ph-n*(oh+ysp)-ytp, ow, oh],['AMPL:']);
    h_Eap=create_Edit(h_Pfp,[ow+2*xsp, ph-n*(oh+ysp)-ytp, 3.5*ow, oh],'EAP');
    h_Eap.String=h.UserData.Dpaths.Ampl;
    h_Eap.Callback=@callback_GetDirectory_path;
    h_PBap =create_PushButton(h_Pfp,[pw-ow, ph-n*(oh+ysp)-ytp, 0.75*ow, oh],'Load','PAP');
    h_PBap.Callback=@callback_GetDirectory_path;
    n=n+1;
    
    % Utility PV Data Folder 
    h_Tdpu=create_Text(h_Pfp,[xsp, ph-n*(oh+ysp)-ytp, ow, oh],['Utility PV:']);
    h_Edpu=create_Edit(h_Pfp,[ow+2*xsp, ph-n*(oh+ysp)-ytp, 3.5*ow, oh],'EDU');
    h_Edpu.String=h.UserData.Dpaths.Utility_PV;
    h_Edpu.Callback=@callback_GetDirectory_path;
    h_PBdpu =create_PushButton(h_Pfp,[pw-ow, ph-n*(oh+ysp)-ytp, 0.75*ow, oh],'Load','PDU');
    h_PBdpu.Callback=@callback_GetDirectory_path;
    n=n+1;
    
    % Rooftop PV Data Folder 
    h_Tdpv=create_Text(h_Pfp,[xsp, ph-n*(oh+ysp)-ytp, ow, oh],['Rooftop PV:']);
    h_Edpv=create_Edit(h_Pfp,[ow+2*xsp, ph-n*(oh+ysp)-ytp, 3.5*ow, oh],'EDV');
    h_Edpv.String=h.UserData.Dpaths.Rooftop_PV;
    h_Edpv.Callback=@callback_GetDirectory_path;
    h_PBdpv =create_PushButton(h_Pfp,[pw-ow, ph-n*(oh+ysp)-ytp, 0.75*ow, oh],'Load','PDV');
    h_PBdpv.Callback=@callback_GetDirectory_path;
    n=n+1;
    
    % Wind Data Folder 
    h_Tdw=create_Text(h_Pfp,[xsp, ph-n*(oh+ysp)-ytp, ow, oh],['Wind:']);
    h_Edw=create_Edit(h_Pfp,[ow+2*xsp, ph-n*(oh+ysp)-ytp, 3.5*ow, oh],'EDW');
    h_Edw.String=h.UserData.Dpaths.Wind;
    h_Edw.Callback=@callback_GetDirectory_path;
    h_PBdw =create_PushButton(h_Pfp,[pw-ow, ph-n*(oh+ysp)-ytp, 0.75*ow, oh],'Load','PDW');
    h_PBdw.Callback=@callback_GetDirectory_path;
    n=n+1;
    
    %CST Data Folder 
    h_Tdc=create_Text(h_Pfp,[xsp, ph-n*(oh+ysp)-ytp, ow, oh],['CST:']);
    h_Edc=create_Edit(h_Pfp,[ow+2*xsp, ph-n*(oh+ysp)-ytp, 3.5*ow, oh],'EDC');
    h_Edc.String=h.UserData.Dpaths.CST;
    h_Edc.Callback=@callback_GetDirectory_path;
    h_PBdc =create_PushButton(h_Pfp,[pw-ow, ph-n*(oh+ysp)-ytp, 0.75*ow, oh],'Load','PDC');
    h_PBdc.Callback=@callback_GetDirectory_path;
    n=n+1;
    
    %Demand Data Folder 
    h_Tdl=create_Text(h_Pfp,[xsp, ph-n*(oh+ysp)-ytp, ow, oh],['Load Demand:']);
    h_Edl=create_Edit(h_Pfp,[ow+2*xsp, ph-n*(oh+ysp)-ytp, 3.5*ow, oh],'EDL');
    h_Edl.String=h.UserData.Dpaths.Load_Demand;
    h_Edl.Callback=@callback_GetDirectory_path;
    h_PBdl =create_PushButton(h_Pfp,[pw-ow, ph-n*(oh+ysp)-ytp, 0.75*ow, oh],'Load','PDL');
    h_PBdl.Callback=@callback_GetDirectory_path;
    n=n+1;
    
    % Save and close
    h_PBsc =create_PushButton(h_Pps,[4, 0.2, 4, 1],'Save and Close','PSCps');
    h_PBsc.Callback={@callback_SaveandClose,h_Pps};
    
    
end

%% function to save and close the Fig: solver option 
function callback_SaveandClose(hObject,eventdata,h_GUI)
        % get solver options from Fig: Solver Option
        h_Eap=findobj('Tag','EAP');
        h_Edu=findobj('Tag','EDU');
        h_Edv=findobj('Tag','EDV');
        h_Edw=findobj('Tag','EDW');
        h_Edc=findobj('Tag','EDC');
        h_Edl=findobj('Tag','EDL');
        
        Dpaths.Ampl=h_Eap.String;
        Dpaths.Utility_PV=h_Edu.String;
        Dpaths.Rooftop_PV=h_Edv.String;
        Dpaths.Wind=h_Edw.String;
        Dpaths.CST=h_Edc.String;
        Dpaths.Load_Demand=h_Edl.String;
        % passing data to push button initial Setup on Fig: GUI
        h=findobj('Tag','PPS');
        
        h.UserData=struct('Dpaths',Dpaths);
        
        close(h_GUI);
end
%% function to get directory path
function callback_GetDirectory_path(hObject,eventdata)    
    if strcmp(hObject.Tag(1),'P')    
        hObject.BackgroundColor = [1,1,0];
    switch hObject.Tag    
        case 'PAP'
            S=uigetdir('','Select AMPL Path');
            oldfolder=cd(S);
            addpath(genpath(cd));
            S=fileparts(which('setupOnce.m'));
            rmpath(genpath(cd));
            cd(oldfolder);           
        case 'PDU'
            S=uigetdir('','Select Utility PV Path');
        case 'PDV'
            S=uigetdir('','Select Rooftop PV Path');
        case 'PDW'
            S=uigetdir('','Select Wind Path');
        case 'PDC'
            S=uigetdir('','Select CST Path');
        case 'PDL'
            S=uigetdir('','Select Load Demand Path');
        end            
        hObject.BackgroundColor = [0.94,0.94,0.94];
        h = findobj('Tag',['E',hObject.Tag(2:end)]);
        h.String=S;
    elseif strcmp(hObject.Tag(1),'E')    
        hObject.BackgroundColor = [1,1,0];
        pause(1e-9)
        if hObject.Tag == 'EAP'
            hObject.BackgroundColor = [1,1,1];
        else
            if isdir(hObject.String)
                hObject.BackgroundColor = [1,1,1];
            else
                hObject.BackgroundColor = [1,0,0];
            end
        end
    end
end