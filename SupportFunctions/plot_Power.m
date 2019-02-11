function plot_Power(hObject,eventdata,Data)
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
    h=findobj('Tag','CPC');
    if h.Value
        h=findobj('Tag','PRS');
        Data=h.UserData;
    else
        h=findobj('Tag','EPP');
        load(h.String);
    end
    
    h_nf=findobj('Tag','CNF');
    h_rf=findobj('Tag','CRF');
    h_sf=findobj('Tag','CSF');
    h=findobj('Tag','TCF');
    if h_nf.Value || ~ishandle(h.UserData)       
        h.UserData=figure();
    elseif h_rf.Value
        figure(h.UserData);
    elseif h_sf.Value
        figure(h.UserData);
        hold on
    end
    
    if strcmp(hObject.Tag,'PDP')       
        h=area([Data.MarketSolution.Gen.Power]');    
        for ii=1:Data.Model.Parameter.G
            h(ii).FaceColor=rgb(Data.Model.Gen.Color(ii));
            h(ii).DisplayName=char(Data.Model.Gen.Name(ii));
        end
        ylabel('Power (MW)')
    end
    
    if strcmp(hObject.Tag,'PUS')       
        h1=area([Data.MarketSolution.Uty_Storage.Power]');
        hold on
        for ii=1:Data.Model.Parameter.S
            h1(ii).FaceColor=rgb(Data.Model.Uty_Strg.Color(ii));
            h1(ii).DisplayName=char(Data.Model.Uty_Strg.Name(ii));
            h2(ii).FaceColor=rgb(Data.Model.Uty_Strg.Color(ii));
            h2(ii).DisplayName=char(Data.Model.Uty_Strg.Name(ii));
        end
        ylabel('Power (MW)')
    end
        
        xlabel('Time (hours)')
        xlim([1,Data.Model.Parameter.T_Hrz]);
        hold off;
    
end