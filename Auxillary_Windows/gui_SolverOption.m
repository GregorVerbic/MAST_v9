function gui_SolverOption(hObject,handles)
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
        h_temp=findobj('Name','Solver Options');
        close(h_temp);
    catch
    end
        
    % Declaring figure size
    Fig_sz_cm=[12 6];
    set(0,'units','centimeters')    % size units
    SS_cm = get(0,'screensize');    % finding screen size
    % Creating figure in middle of screen
    h_Pso = figure('Units','centimeters',...
        'MenuBar','none','Name','Solver Options',...
        'Position',[SS_cm(3)/2-Fig_sz_cm(1)/2 SS_cm(4)/2-Fig_sz_cm(2)/2 Fig_sz_cm(1) Fig_sz_cm(2)]);
    
    % Edit for solver options
    % Object parameters
    ow=2;    % object width
    oh=0.75;    % object height
    xsp=0.2;    % x-dir sepration
    ysp=0.25;    % y-dir sepration
    ytp=0.3;    % top gap     
    n=1;        % object number
    
    % Edit solver option line 1
    h_Eso1=create_Edit(h_Pso,[xsp, Fig_sz_cm(2)-n*oh-n*xsp, Fig_sz_cm(1)-2*xsp, oh],'ESO1'); 
    h_Eso1.HorizontalAlignment='left';
    h_Eso1.String='';
    h_Eso1.UserData=struct('Sopt_l1',h_Eso1.String);
    h_Eso1.Callback=@callback_Update_Edit;
    n=n+1;
    
    % Edit solver option line 2
    h_Eso2=create_Edit(h_Pso,[xsp, Fig_sz_cm(2)-n*oh-n*xsp, Fig_sz_cm(1)-2*xsp, oh],'ESO2'); 
    h_Eso2.HorizontalAlignment='left';
    h_Eso2.String='';
    h_Eso2.UserData=struct('Sopt_l2',h_Eso2.String);
    h_Eso2.Callback=@callback_Update_Edit;
    n=n+1;
    
    % Edit solver option line 3
    h_Eso3=create_Edit(h_Pso,[xsp, Fig_sz_cm(2)-n*oh-n*xsp, Fig_sz_cm(1)-2*xsp, oh],'ESO3'); 
    h_Eso3.HorizontalAlignment='left';
    h_Eso3.String='';
    h_Eso3.UserData=struct('Sopt_l2',h_Eso3.String);
    h_Eso3.Callback=@callback_Update_Edit;
    n=n+1;
    
    % Edit solver option line 4
    h_Eso4=create_Edit(h_Pso,[xsp, Fig_sz_cm(2)-n*oh-n*xsp, Fig_sz_cm(1)-2*xsp, oh],'ESO4'); 
    h_Eso4.HorizontalAlignment='left';
    h_Eso4.String='';
    h_Eso4.UserData=struct('Sopt_l4',h_Eso4.String);
    h_Eso4.Callback=@callback_Update_Edit;
    n=n+1;
    
    % Edit solver option line 5
    h_Eso5=create_Edit(h_Pso,[xsp, Fig_sz_cm(2)-n*oh-n*xsp, Fig_sz_cm(1)-2*xsp, oh],'ESO5'); 
    h_Eso5.HorizontalAlignment='left';
    h_Eso5.String='';
    h_Eso5.UserData=struct('Sopt_l5',h_Eso5.String);
    h_Eso5.Callback=@callback_Update_Edit;
    n=n+1;
    % Save and close
    h_PBsc =create_PushButton(h_Pso,[xsp, Fig_sz_cm(2)-n*oh-n*xsp, Fig_sz_cm(1)-2*xsp, oh],'Save and Close','PSCso');
    h_PBsc.Callback={@callback_SaveandClose,h_Pso}; 
end


%% function to save and close the Fig: solver option 
function callback_SaveandClose(hObject,eventdata,h_GUI)
        % get solver options from Fig: Solver Option
        h_Eso1=findobj('Tag','ESO1');
        h_Eso2=findobj('Tag','ESO2');
        h_Eso3=findobj('Tag','ESO3');
        h_Eso4=findobj('Tag','ESO4');
        h_Eso5=findobj('Tag','ESO5');
        % passing data to push button new file on Fig: Solver Selection
        h=findobj('Tag','PNF');
        h.UserData=struct('Sopt',...
            [h_Eso1.String,h_Eso2.String,h_Eso3.String,...
            h_Eso4.String,h_Eso5.String]);
        % Updating text on Fig: Solver Selection 
        h=findobj('Tag','TCO');
        h.String = ['Current custom Options:  ',...
            h_Eso1.String,h_Eso2.String,h_Eso3.String,...
            h_Eso4.String,h_Eso5.String];
    close(h_GUI);
end