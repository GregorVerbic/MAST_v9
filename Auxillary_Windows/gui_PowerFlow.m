function gui_PowerFlow(hObject,eventdata)
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
        h_temp=findobj('Name','Power Flow');
        close(h_temp);
    catch
    end
    
    % Declaring figure size
    Fig_sz_cm=[8+2*.25 7.5];
    set(0,'units','centimeters')    % size units
    SS_cm = get(0,'screensize');    % finding screen size
    % Creating figure in middle of screen
    h_Fpowerflow = figure('Units','centimeters',...
        'MenuBar','none','Name','Power Flow',...
        'Position',[SS_cm(3)/2-Fig_sz_cm(1)/2+13.75 SS_cm(4)/2-Fig_sz_cm(2)/2 Fig_sz_cm(1) Fig_sz_cm(2)]);
    
    
    %% Results Selection
    pw=Fig_sz_cm(1)-.5;
    ph=2;
    
    h_Prs=create_Panel(h_Fpowerflow,[.25 Fig_sz_cm(2)-ph pw ph],'Result Selection');
    % Panel object parameters
    ow=3.5;    % object width
    oh=0.5;    % object height
    xsp=0.25;    % x-dir sepration
    ysp=0.25;    % y-dir sepration
    ytp=0.3;    % top gap     
    n=1;        % object number
    
    % Current Reselts 
    h_Tcr=create_Text(h_Prs,[xsp, ph-n*(oh+ysp)-ytp, ow, oh],['Current Results:']);
    h_CBcr=create_CheckBox(h_Prs,[ow-.5, ph-n*(oh+ysp)-ytp, ow, oh],'CCR_pf');
%     h_CBcr.UserData=struct('Current_results',1);
    h_CBcr.Value=1;
    h_CBcr.Callback=@callback_Update_CheckBox;
    
    n=n+1;
    % Saved Reselts 
    h_Tsr=create_Text(h_Prs,[xsp, ph-n*(oh+ysp)-ytp, ow, oh],['Saved Results:']);
    h_CBsr =create_CheckBox(h_Prs,[ow-.5, ph-n*(oh+ysp)-ytp, ow, oh],'CSR_pf');
%     h_CBsr.UserData=struct('Saved_results',0);
    h_CBsr.Value=0;
    h_CBsr.Callback=@callback_Update_CheckBox;
    h_Esr=create_Edit(h_Prs,[ow, ph-n*(oh+ysp)-ytp, ow, oh],'ESR_pf');
    h_Esr.Callback=@callback_LoadResults;
    h_PBsr =create_PushButton(h_Prs,[pw-0.25*ow-.5*xsp, ph-n*(oh+ysp)-ytp, 0.25*ow, oh],'Load','PSR_pf');
    h_PBsr.Callback=@callback_LoadResults;
    
    denable_PowerFlowOptions(h_CBcr);
    
  %% Time Selection
    pw=Fig_sz_cm(1)-.5;
    ph=3;
    
    h_Pts=create_Panel(h_Fpowerflow,[.25 Fig_sz_cm(2)-2-ph pw ph],'Time Scale Setting');
    % Panel object parameters
    ow=5.5;    % object width
    oh=0.4;    % object height
    xsp=0.1;    % x-dir sepration
    ysp=0.1;    % y-dir sepration
    ytp=0.4;    % top gap     
    n=1;        % object number
    
    % Market results resolution
    h_Tmr=create_Text(h_Pts,[xsp, ph-n*(oh+ysp)-ytp, ow, oh],['Market time resolution:']);
    h_Emr=create_Edit(h_Pts,[ow, ph-n*(oh+ysp)-ytp, .2*ow, oh],'EMR_pf');
    h_Emr.UserData = struct('Market_Resolution',60);
    h_Emr.String = h_Emr.UserData.Market_Resolution;
    h_Emr.Callback=@callback_Update_Edit;
    h_Tmn_1=create_Text(h_Pts,[xsp+ow+.2*ow, ph-n*(oh+ysp)-ytp, ow, oh],['minutes']);
    n=n+1;
    h_Tpfr=create_Text(h_Pts,[xsp, ph-n*(oh+ysp)-ytp, ow, oh],['Power Flow time resolution:']);
    h_Epfr=create_Edit(h_Pts,[ow, ph-n*(oh+ysp)-ytp, .2*ow, oh],'EPF_pf');
    h_Epfr.UserData = struct('PowerFlow_Resolution',60);
    h_Epfr.String = h_Epfr.UserData.PowerFlow_Resolution;
    h_Epfr.Callback=@callback_Update_Edit;
    h_Tmn_2=create_Text(h_Pts,[xsp+ow+.2*ow, ph-n*(oh+ysp)-ytp, ow, oh],['minutes']);
    n=n+1;
%     h_Tpfr=create_Text(h_Pts,[xsp, ph-n*(oh+ysp)-ytp, ow, oh],['Power Flow time resolution:']);
%     h_Epfr=create_Edit(h_Pts,[ow, ph-n*(oh+ysp)-ytp, .2*ow, oh],'EPF_pf');
%     h_Epfr.UserData = struct('PowerFlow_Resolution',60);
%     h_Epfr.String = h_Epfr.UserData.PowerFlow_Resolution;
%     h_Epfr.Callback=@callback_Update_Edit;
%     h_Tmn_2=create_Text(h_Pts,[xsp+ow+.2*ow, ph-n*(oh+ysp)-ytp, ow, oh],['minutes']);
    ow=0.5;
    % Simulate for all time slots
    h_Tats=create_Text(h_Pts,[xsp+ow, ph-n*(oh+ysp)-ytp, 5*ow, oh],['All time slots:']);
    h_CBats=create_CheckBox(h_Pts,[xsp, ph-n*(oh+ysp)-ytp, ow, oh],'CAT_pf');
%     h_CBats.UserData=struct('All_slots',1);
    h_CBats.Value=1;
    h_CBats.Callback=@callback_Update_CheckBox;
    n=n+1;
    % Slected time slots
    h_Tsts1=create_Text(h_Pts,[xsp+ow, ph-n*(oh+ysp)-ytp, 5*ow, oh],['Time slot from:']);
    h_Ests=create_Edit(h_Pts,[2*xsp+5*ow, ph-n*(oh+ysp)-ytp, 2*ow, oh],'ESTS_pf');
    h_Ests.UserData = struct('TS_Start',1);
    h_Ests.String = h_Ests.UserData.TS_Start;
    h_Ests.Callback=@callback_Update_Edit;
    h_Tsts2=create_Text(h_Pts,[xsp+8*ow, ph-n*(oh+ysp)-ytp, 1*ow, oh],['to:']);    
    h_Este=create_Edit(h_Pts,[2*xsp+9*ow, ph-n*(oh+ysp)-ytp, 2*ow, oh],'ESTE_pf');
    h_Este.UserData = struct('TS_End',24);
    h_Este.String = h_Este.UserData.TS_End;
    h_Este.Callback=@callback_Update_Edit;
    h_CBsts=create_CheckBox(h_Pts,[xsp, ph-n*(oh+ysp)-ytp, ow, oh],'CST_pf');
%     h_CBsts.UserData=struct('Selective_Time',0);
    h_CBsts.Value=0;
    h_CBsts.Callback=@callback_Update_CheckBox;
    n=n+1;
    
    denable_Time_Selection(h_CBats);
    
    % Simulate for all time vector
%     h_Tats=create_Text(h_Pts,[xsp+ow, ph-n*(oh+ysp)-ytp, 5*ow, oh],['All time slots:']);
%     h_CBats=create_CheckBox(h_Pts,[xsp, ph-n*(oh+ysp)-ytp, ow, oh],'CCR_pf');
%     h_CBats.UserData=struct('All_slots',1);
%     h_CBats.Value=1;
%     h_CBats.Callback=@callback_Update_CheckBox;
    
    

    
    %% DC opf
    ow=2.5;    % object width
    oh=1.4;    % object height
    xsp=0.25;    % x-dir sepration
    ysp=0.1;    % y-dir sepration
    ytp=0.4;    % top gap     
    n=1;        % object number
    
    h_PBdcpf = create_PushButton(h_Fpowerflow,[xsp, ysp, ow, oh],'DC power flow','PDCPF_pf');
    h_PBdcpf.Callback={@powerFlow,'DC'};
    h_PBacpf = create_PushButton(h_Fpowerflow,[ow+2*xsp, ysp, ow, oh],'AC power flow','PACPF_pf');
    h_PBacpf.Callback={@powerFlow,'AC'};
    h_PBopf = create_PushButton(h_Fpowerflow,[2*ow+3*xsp, ysp, ow, oh],'OPF','POPF_pf');
    h_PBopf.Callback={@powerFlow,'OPF'};

end

function callback_LoadResults(hObject,eventdata)
    if strcmp(hObject.Tag,'PSR_pf')    
        hObject.BackgroundColor = [1,1,0];
        S=uigetfile({'*.mat'},'Select Saved Results');
        hObject.BackgroundColor = [0.94,0.94,0.94];
        h = findobj('Tag','ESR_pf');
        h.String=S;
    elseif strcmp(hObject.Tag,'ESR_pf')    
        hObject.BackgroundColor = [1,1,0];
         pause(1e-9)
        [fold file ext]=fileparts(hObject.String);
        Search=dir('*.mat');
        for ii=1:length(Search)
            if strcmp(hObject.String,Search(ii).name)
                hObject.BackgroundColor = [1,1,1];
                break;
            end
            if ii== length(Search)
                hObject.BackgroundColor = [1,0,0];
            end
        end
    end
    
end

