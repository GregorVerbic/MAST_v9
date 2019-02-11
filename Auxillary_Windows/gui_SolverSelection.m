function gui_SolverSelection(hObject,eventdata)
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
        h_temp=findobj('Name','Solver Selection');
        close(h_temp);
    catch
    end
    
    % Declaring figure size
    Fig_sz_cm=[10.25 8.5];
    set(0,'units','centimeters')    % size units
    SS_cm = get(0,'screensize');    % finding screen size
    % Creating figure in middle of screen
    h_Pspara = figure('Units','centimeters',...
        'MenuBar','none','Name','Solver Selection',...
        'Position',[SS_cm(3)/2-Fig_sz_cm(1)/2 SS_cm(4)/2-Fig_sz_cm(2)/2 Fig_sz_cm(1) Fig_sz_cm(2)]);
    
    %% Solver Selection
    h_PUMss=create_PopUpMenu(h_Pspara,[4, Fig_sz_cm(2)-1.25, 2, 1],{'cplex';'gurobi';'Other'},'PSS'); 
    h_PUMss.Callback=@callback_Update_PopUpMenu;
    h_Tss=create_Text(h_Pspara,[1, Fig_sz_cm(2)-1.25, 3, 1],'Select Solver :');
    h_Tss.FontSize=10;
    
    h_Ess=create_Edit(h_Pspara,[4, Fig_sz_cm(2)-1.27, 2, .5],'ESS'); 
    h_Ess.HorizontalAlignment='left';
    h_Ess.String='minos';
    h_Ess.UserData=struct('UserData',h_Ess.String);
    h_Ess.Callback=@callback_Update_Edit;    
    h_Toss=create_Text(h_Pspara,[1, Fig_sz_cm(2)-1.85, 3, 1],'Other Solver Name:');
    h_Toss.FontSize=8;
    
    % Quick setup options
    h_PBsp =create_PushButton(h_Pspara,[Fig_sz_cm(2)-1.25, Fig_sz_cm(2)-1, 2, 1],'Quick Setup','PQS');
    h_PBsp.Callback=@gui_SolverQuickOptions;
    
    h_temp = findobj('Tag','TSV');
    if strcmp(h_temp.String,'cplex')
        h_PUMss.UserData = struct('Solver',1);
        h_PUMss.Value = 1;
        denable_OSS(0)
    elseif strcmp(h_temp.String,'gurobi')
        h_PUMss.UserData = struct('Solver',2);
        h_PUMss.Value = 2;
        denable_OSS(0)
    else
        h_PUMss.UserData = struct('Solver',3);
        h_PUMss.Value = 3;
        denable_OSS(1)
    end
        
    
   %% Solver Options
    
    pw=Fig_sz_cm(1)-0.5;              % panel width
    ph=Fig_sz_cm(2)-5*.25-2.25;      % panel height
    h_Pso=create_Panel(h_Pspara,[0.25 2.25 pw ph],'HELP:');

    % Panel object parameters
    ow=1;    % object width
    oh=.9;    % object height
    xsp=0.25;    % x-dir sepration
    ysp=0.05;    % y-dir sepration
    ytp=0.35;    % top gap     
    n=1;        % object number
    
    % Creating check box for Household batteries

    % Texts for diaplay
    % Cplex help link
    h_Tc=create_Text(h_Pso,[xsp, ph-n*(oh+ysp)-ytp, (pw), oh],...
        'cplex options help : http://ampl.com/products/solvers/solvers-we-sell/cplex/options/');
    n=n+1;
    % GUROBI help link
    h_Tgt=create_Text(h_Pso,[xsp, ph-n*(oh+ysp)-ytp, (pw), oh],...
        'GUROBI options help : http://www.gurobi.com/documentation/7.0/ampl-gurobi/parameters.html');
    n=n+1;
    % Format style help link
    h_Tft1=create_Text(h_Pso,[xsp, ph-n*(oh+ysp)-ytp, (pw), oh],...
        ['Solver options are saved in following format:']);
    h_Tft2=create_Text(h_Pso,[xsp, ph-n*(oh+ysp)-ytp-.4, (pw), oh],...
        ['option1=value option2=value option3=value option4=value']);
    h_Tft3=create_Text(h_Pso,[xsp, ph-n*(oh+ysp)-ytp-.8, (pw), oh],...
        ['option5=value option6=value option7=value option8=value']);
    n=n+1;
    
    % Current Options
    h_Tco=create_Text(h_Pso,[xsp, ph-n*(oh+ysp)-ytp-.45, (pw), oh],...
        ['Current custom Options: None']);
    h_Tco.Tag='TCO';
    n=n+1;
    
    %% Push buttons panel
    
    pw=3.5;              % panel width
    ph=4.5-2*.25-2.25;      % panel height
    h_Ppb=create_Panel(h_Pspara,[0.25 0.25 Fig_sz_cm(1)-0.5 ph],'Solver Options:');

    % Panel object parameters
    ow=2;    % object width
    oh=1;    % object height
    xsp=0.1;    % x-dir sepration
    ysp=0.25;    % y-dir sepration
    ytp=0.3;    % top gap     
    n=1;        % object number
    
    % New File
    h_PBnf =create_PushButton(h_Ppb,[2*(n-1)*xsp+(n-1)*ow+xsp, ysp, ow, oh],'New File','PNF');
    h_PBnf.UserData=struct('Sopt','');
    h_PBnf.Callback=@gui_SolverOption;
    
    n=n+1;
    
    % Load
    h_PBld =create_PushButton(h_Ppb,[2*(n-1)*xsp+(n-1)*ow+xsp, ysp, ow, oh],'Load Options','PLD');
    h_PBld.Callback=@callback_LoadSolverOptions;
    n=n+1;
    % Save
    h_PBsd =create_PushButton(h_Ppb,[2*(n-1)*xsp+(n-1)*ow+xsp,ysp, ow, oh],'Store Options','PSD');
    h_PBsd.Callback=@callback_SaveSolverOptions;
    n=n+1;
    
    % Solver Parameter
    h_PBsp =create_PushButton(h_Ppb,[2*(n-1)*xsp+(n-1)*ow+xsp, ysp, 1.25*ow, oh],'Save and Close','PSCSS');
    h_PBsp.Callback={@callback_saveandclose,h_Pspara};
    n=n+1;
    
    
end

% load Solver options from text file
function callback_LoadSolverOptions(hObject,eventdata)
    hObject.BackgroundColor = [1,1,0];
    S=uigetfile({'*.txt'},'Select Solver Option File');
    if S
        fid=fopen(S,'r');
        temp=fread(fid);
        % replace new lines with spaces
        temp(find(temp==10))=32;
        h=findobj('Tag','PNF');
        h.UserData=struct('Sopt',char(temp'));
        
        h=findobj('Tag','TCO');
        h.String=['Current custom Options: ',...
            char(temp')];
    end
    hObject.BackgroundColor = [0.94,0.94,0.94];
end


function callback_SaveSolverOptions(hObject,eventdata)
    hObject.BackgroundColor = [1,1,0];
    S=uiputfile({'*.txt'},'Select Solver Option File');
    if S
        fid=fopen(S,'w');
        h=findobj('Tag','PNF');
        fwrite(fid,h.UserData.Sopt);
    end
    hObject.BackgroundColor = [0.94,0.94,0.94];
end

function callback_saveandclose(hObject,eventdata,h_GUI)
    hObject.BackgroundColor = [1,1,0];
    h=findobj('Tag','PSS');
    if h.Value==1
        Solver='cplex';
    elseif h.Value==2
        Solver='gurobi';
    elseif h.Value==3
        hss=findobj('Tag','ESS');
        Solver=hss.String;
    end
    h=findobj('Tag','PNF');
    Solver_opt=h.UserData.Sopt;
    
    % updating solver
    h=findobj('Tag','TSV');
    h.String=Solver;
    
    %updating solver options
    h=findobj('Tag','TSO');
    h.String=Solver_opt;
    hObject.BackgroundColor = [0.94,0.94,0.94];
    
    % setting solver as default
    
    close(h_GUI);
end



