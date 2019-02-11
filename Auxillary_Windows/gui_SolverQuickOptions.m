function gui_SolverQuickOptions(hObject,eventdata)
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
        h_temp=findobj('Name','Solver Quick Options');
        close(h_temp);
    catch
    end
        
    % Declaring figure size
    Fig_sz_cm=[8.25 7.5];
    set(0,'units','centimeters')    % size units
    SS_cm = get(0,'screensize');    % finding screen size
    % Creating figure in middle of screen
    h_PQspara = figure('Units','centimeters',...
        'MenuBar','none','Name','Solver Quick Options',...
        'Position',[SS_cm(3)/2-Fig_sz_cm(1)/2 SS_cm(4)/2-Fig_sz_cm(2)/2 Fig_sz_cm(1) Fig_sz_cm(2)]);
    
    %% Cplex Solver
    
    
    pw=3.75;              % panel width
    ph=8-2*.25-2.25;      % panel height
    h_Pcp=create_Panel(h_PQspara,[0.25 2.25 pw ph],'Cplex');
    

    % Panel object parameters
    ow=1;    % object width
    oh=1;    % object height
    xsp=0.25;    % x-dir sepration
    ysp=0.25;    % y-dir sepration
    ytp=0.3;    % top gap     
    n=1;        % object number
    
    % Edit for Cplex termination time
    h_Ect=create_Edit(h_Pcp,[pw-ow-xsp, ph-n*(oh+ysp)-ytp, ow, oh],'ECT');    
    h_Ect.String='1e6';
    h_Ect.UserData=struct('Solver_ttime',str2num( h_Ect.String));
    h_Ect.Callback=@callback_Update_Edit;
    h_Tct=create_Text(h_Pcp,[xsp, ph-n*(oh+ysp)-ytp, (pw-ow-2*xsp), oh],'Sub-horizon Time limit (sec):');
    h_Tct.Tag='TCT';
    n=n+1;
    % Edit for Cplex termination MIP gap
    h_Ecg=create_Edit(h_Pcp,[pw-ow-xsp, ph-n*(oh+ysp)-ytp, ow, oh],'ECG');    
    h_Ecg.String='1e-2';
    h_Ecg.UserData=struct('Solver_tgap',str2num( h_Ecg.String));
    h_Ecg.Callback=@callback_Update_Edit;
    h_Tcg=create_Text(h_Pcp,[xsp, ph-n*(oh+ysp)-ytp, (pw-ow-2*xsp), oh],'Termination MIP gap:');
    h_Tcg.Tag='TCG';
    n=n+1;
    
    % Display detail level
    h_Ecd=create_Edit(h_Pcp,[pw-ow-xsp, ph-n*(oh+ysp)-ytp, ow, oh],'ECD');    
    h_Ecd.String='1';
    h_Ecd.UserData=struct('Solver_ddet',str2num( h_Ecd.String));
    h_Ecd.Callback=@callback_Update_Edit;
    h_Tcd=create_Text(h_Pcp,[xsp, ph-n*(oh+ysp)-ytp, (pw-ow-2*xsp), oh],'Solver Display detail (0-5):');
    h_Tcd.Tag='TCD';
    n=n+1;
    %% GUROBI Solver
    
    pw=3.75;              % panel width
    ph=8-2*.25-2.25;      % panel height
    h_Pgp=create_Panel(h_PQspara,[3.5+3*0.25 2.25 pw ph],'GUROBI');

    % Panel object parameters
    ow=1;    % object width
    oh=1;    % object height
    xsp=0.25;    % x-dir sepration
    ysp=0.25;    % y-dir sepration
    ytp=0.3;    % top gap     
    n=1;        % object number

    % Edit for GUROBI termination time
    h_Egt=create_Edit(h_Pgp,[pw-ow-xsp, ph-n*(oh+ysp)-ytp, ow, oh],'EGT');    
    h_Egt.String='1e6';
    h_Egt.UserData=struct('Solver_ttime',str2num( h_Egt.String));
    h_Egt.Callback=@callback_Update_Edit;
    h_Tgt=create_Text(h_Pgp,[xsp, ph-n*(oh+ysp)-ytp, (pw-ow-2*xsp), oh],'Sub-horizon Time limit (sec):');
    h_Tgt.Tag='TGT';
    n=n+1;
    
    % Edit for Cplex termination MIP gap
    h_Egg=create_Edit(h_Pgp,[pw-ow-xsp, ph-n*(oh+ysp)-ytp, ow, oh],'EGG');    
    h_Egg.String='1e-2';
    h_Egg.UserData=struct('Solver_tgap',str2num( h_Egg.String));
    h_Egg.Callback=@callback_Update_Edit;
    h_Tgg=create_Text(h_Pgp,[xsp, ph-n*(oh+ysp)-ytp, (pw-ow-2*xsp), oh],'Termination MIP gap:');
    h_Tgg.Tag='TGG';
    n=n+1;
    
    denable_SolverOptions();
        

    
    
    
    %% Push buttons panel
    
    pw=3.5;              % panel width
    ph=4.5-2*.25-2.25;      % panel height
    h_Ppb=create_Panel(h_PQspara,[0.25 0.25 Fig_sz_cm(1)-0.5 ph],'');

    % Panel object parameters
    ow=4;    % object width
    oh=1;    % object height
    xsp=0.25;    % x-dir sepration
    ysp=0.25;    % y-dir sepration
    ytp=0.3;    % top gap     
    n=1;        % object number
    
    
    % Solver Parameter
    h_PBsp =create_PushButton(h_Ppb,[pw/2, ysp, ow, oh],'Save and Close','PSC_SQO');
    h_PBsp.Callback={@callback_SaveandClose,h_PQspara};
    n=n+1;
    
    
        
    
end

function callback_SaveandClose(hObject,eventdata,h_GUI)        
    temp=[];
    h=findobj('Tag','PSS');
    if h.Value==1
        h=findobj('Tag','ECT');
        temp = ['time=',h.String];
        h=findobj('Tag','ECG');
        temp = [temp,' mipgap=',h.String];
        h=findobj('Tag','ECD');
        temp = [temp,' mipdisplay=',h.String];
    elseif h.Value==2
        h=findobj('Tag','EGT');
        temp = [temp,'timelim=',h.String]; 
        h=findobj('Tag','EGG');
        temp = [temp,' mipgap=',h.String];
    end
    % Deleting data from push button new file on Fig: Solver Selection
    h=findobj('Tag','PNF');
    h.UserData=struct('Sopt',temp); 
    
    h=findobj('Tag','TCO');
    h.String = ['Current custom Options:  ',...
        temp];
    close(h_GUI);
end

