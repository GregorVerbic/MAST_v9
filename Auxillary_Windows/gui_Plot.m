function gui_Plot(hObject,eventdata)
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
        h_temp=findobj('Name','Plot');
        close(h_temp);
    catch
    end
    
    % Declaring figure size
    Fig_sz_cm=[8+2*.25 7.5];
    set(0,'units','centimeters')    % size units
    SS_cm = get(0,'screensize');    % finding screen size
    % Creating figure in middle of screen
    h_Fplot = figure('Units','centimeters',...
        'MenuBar','none','Name','Plot',...
        'Position',[SS_cm(3)/2-Fig_sz_cm(1)/2+13.75 SS_cm(4)/2-Fig_sz_cm(2)/2 Fig_sz_cm(1) Fig_sz_cm(2)]);
    %% Plot Results Selection
    pw=Fig_sz_cm(1)-.5;
    ph=2;
    
    h_Prs=create_Panel(h_Fplot,[.25 Fig_sz_cm(2)-ph pw ph],'Result Selection');
    % Panel object parameters
    ow=3.5;    % object width
    oh=0.5;    % object height
    xsp=0.25;    % x-dir sepration
    ysp=0.25;    % y-dir sepration
    ytp=0.3;    % top gap     
    n=1;        % object number
    
    % Plot Current Reselts 
    h_Tpc=create_Text(h_Prs,[xsp, ph-n*(oh+ysp)-ytp, ow, oh],['Plot Current Results:']);
    h_CBpc =create_CheckBox(h_Prs,[ow-.5, ph-n*(oh+ysp)-ytp, ow, oh],'CPC');
    h_CBpc.UserData=struct('Current_results',1);
    h_CBpc.Value=1;
    h_CBpc.Callback=@callback_Update_CheckBox;
    
    n=n+1;
    % Plot Save Reselts 
    h_Tpp=create_Text(h_Prs,[xsp, ph-n*(oh+ysp)-ytp, ow, oh],['Plot Previous Results:']);
    h_CBpp =create_CheckBox(h_Prs,[ow-.5, ph-n*(oh+ysp)-ytp, ow, oh],'CPP');
    h_CBpp.UserData=struct('Previous_results',0);
    h_CBpp.Value=0;
    h_CBpp.Callback=@callback_Update_CheckBox;
    h_Eps=create_Edit(h_Prs,[ow, ph-n*(oh+ysp)-ytp, ow, oh],'EPP');
    h_Eps.Callback=@callback_LoadResults;
    h_PBps =create_PushButton(h_Prs,[pw-0.25*ow-.5*xsp, ph-n*(oh+ysp)-ytp, 0.25*ow, oh],'Load','PPP');
    h_PBps.Callback=@callback_LoadResults;

    denable_PlotOptions(h_CBpc);
    
  %% Figure options
    pw=Fig_sz_cm(1)-.5;
    ph=1;
    
    h_Pfo=create_Panel(h_Fplot,[.25 Fig_sz_cm(2)-2-ph pw ph],'Plot ptions');
    % Panel object parameters
    ow=2.4;    % object width
    oh=0.4;    % object height
    xsp=0.1;    % x-dir sepration
    ysp=0.25;    % y-dir sepration
    ytp=0.2;    % top gap     
    n=1;        % object number
    
    % New Figure
    h_Tnf=create_Text(h_Pfo,[xsp, ph-n*(oh+ysp)-ytp, ow, oh],['New Figure:']);
    h_CBnf =create_CheckBox(h_Pfo,[ow-.5, ph-n*(oh+ysp)-ytp, ow, oh],'CNF');
    h_CBnf.UserData=struct('New_figure',0);
    h_CBnf.Value=1;
    h_CBnf.Callback=@callback_Update_CheckBox;
    
    % Reuse Figure
    h_Trf=create_Text(h_Pfo,[ow+xsp, ph-n*(oh+ysp)-ytp, ow, oh],['Reuse Figure:']);
    h_CBrf =create_CheckBox(h_Pfo,[ow+ow-.5, ph-n*(oh+ysp)-ytp, ow, oh],'CRF');
    h_CBrf.UserData=struct('Reuse_figure',0);
    h_CBrf.Value=0;
    h_CBrf.Callback=@callback_Update_CheckBox;
    
    % Hold Figure
    h_Tsf=create_Text(h_Pfo,[2*ow+xsp, ph-n*(oh+ysp)-ytp, ow, oh],['Same Figure:']);
    h_CBsf =create_CheckBox(h_Pfo,[2*ow+ow-.5, ph-n*(oh+ysp)-ytp, ow, oh],'CSF');
    h_CBsf.UserData=struct('Same_figure',0);
    h_CBsf.Value=0;
    h_CBsf.Callback=@callback_Update_CheckBox;
    
    
    % Empty object for holding curren figure handel
    h_Tcf=create_Text(h_Pfo,[3*ow+xsp, ph-n*(oh+ysp)-ytp, ow, oh],['']);
    h_Tcf.Tag='TCF';
    h_Tcf.UserData=struct('Current_figure_handel',0);    

    denable_FigureOptions(h_Tnf);
    
    %% Pushbuttons for quick plots
    pw=Fig_sz_cm(1)-.5;
    ph=4;
    
    h_Pqp=create_Panel(h_Fplot,[.25 Fig_sz_cm(2)-2-1-ph pw ph],'Quick Plots');
    % Panel object parameters
    ow=2.75;    % object width
    oh=0.4;    % object height
    xsp=0.25;    % x-dir sepration
    ysp=0.25;    % y-dir sepration
    ytp=0.3;    % top gap     
    n=1;        % object number
    
    % Generatotr Dispatch power
    h_Tdp=create_Text(h_Pqp,[0, ph-n*(oh+ysp)-ytp, ow, oh],['Generator Dispatch:']);
    h_PBdp = create_PushButton(h_Pqp,[ow, ph-n*(oh+ysp)-ytp, 1, oh],'Plot','PDP');
    h_PBdp.Callback=@plot_Power;
    
    % Generator dispatch sorted technology wise
    h_Tdp=create_Text(h_Pqp,[4, ph-n*(oh+ysp)-ytp, ow, oh],['Dispatch (Tech):']);
    h_PBst = create_PushButton(h_Pqp,[4+ow, ph-n*(oh+ysp)-ytp, 1, oh],'Plot','PST');
    h_PBst.Callback=@plot_SortedTech;
    n=n+1;
    
    % Utility Storage power
    h_Tus=create_Text(h_Pqp,[0, ph-n*(oh+ysp)-ytp, ow, oh],['Uty Strg Power:']);
    h_PBus = create_PushButton(h_Pqp,[ow, ph-n*(oh+ysp)-ytp, 1, oh],'Plot','PUS');
    h_PBus.Callback=@plot_Power;
    
    % Utility Energy
    h_Tue=create_Text(h_Pqp,[4, ph-n*(oh+ysp)-ytp, ow, oh],['Uty Strg Energy:']);
    h_PBue = create_PushButton(h_Pqp,[4+ow, ph-n*(oh+ysp)-ytp, 1, oh],'Plot','PUE');
    h_PBue.Callback=@plot_Energy;
    n=n+1;    
    
    % Net System Demand
    h_Tnd=create_Text(h_Pqp,[0, ph-n*(oh+ysp)-ytp, ow, oh],['Net System Demand:']);
    h_PBnd = create_PushButton(h_Pqp,[ow, ph-n*(oh+ysp)-ytp, 1, oh],'Plot','PSD');
    h_PBnd.Callback=@plot_Demand;
    n=n+1;
    % Net Consumer Demand
    h_Tcd=create_Text(h_Pqp,[0, ph-n*(oh+ysp)-ytp, ow, oh],['Net Consumer Demand:']);
    h_PBcd = create_PushButton(h_Pqp,[ow, ph-n*(oh+ysp)-ytp, 1, oh],'Plot','PCD');
    h_PBcd.Callback=@plot_Demand;
    
    % Net Prosumer Demand
    h_Tpd=create_Text(h_Pqp,[4, ph-n*(oh+ysp)-ytp, ow, oh],['Net Prosumer Demand:']);
    h_PBpd = create_PushButton(h_Pqp,[4+ow, ph-n*(oh+ysp)-ytp, 1, oh],'Plot','PPD');
    h_PBpd.Callback=@plot_Demand;
    n=n+1;
    % User Defined 1
    h_Eud1=create_Edit(h_Pqp,[0, ph-n*(oh+ysp)-ytp, ow, oh],'EUD1');
    h_Eud1.Callback=@callback_Update_Edit;
    h_PBud1 = create_PushButton(h_Pqp,[ow, ph-n*(oh+ysp)-ytp, 1, oh],'Plot','PUD1');
    h_PBud1.Callback=@plot_UserDefined;
    
    % User Defined 2
    h_Eud2=create_Edit(h_Pqp,[4, ph-n*(oh+ysp)-ytp, ow, oh],'EUD2');
    h_Eud2.Callback=@callback_Update_Edit;
    h_PBud2 = create_PushButton(h_Pqp,[4+ow, ph-n*(oh+ysp)-ytp, 1, oh],'Plot','PUD2');
    h_PBud2.Callback=@plot_UserDefined;
  
 
end

function callback_LoadResults(hObject,eventdata)
    if strcmp(hObject.Tag,'PPP')    
        hObject.BackgroundColor = [1,1,0];
        S=uigetfile({'*.mat'},'Select Saved Results');
        hObject.BackgroundColor = [0.94,0.94,0.94];
        h = findobj('Tag','EPP');
        h.String=S;
    elseif strcmp(hObject.Tag,'EPP')    
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

function plot_UserDefined(hObject,eventdata)
    if strcmp(hObject.Tag,'PUD1')
        h = findobj('Tag','EUD1');
    elseif strcmp(hObject.Tag,'PUD2')
        h = findobj('Tag','EUD2');
    end
    
    if isempty(h.String)
        S=uigetfile({'*.m'},'Select Plot Function');
        h.String=S;
        run(S);
    else
        run(h.String)
    end    
end