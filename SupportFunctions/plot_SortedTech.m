function plot_SortedTech(hObject,eventData)
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
        
    
    Bl=find(strcmp(Data.Model.Gen.Tech,'BlCT'));
    Br=find(strcmp(Data.Model.Gen.Tech,'BrCT'));
    OG=find(strcmp(Data.Model.Gen.Tech,'OCGT'));
    CG=find(strcmp(Data.Model.Gen.Tech,'CCGT'));
    PV=find(strcmp(Data.Model.Gen.Tech,'PV'));
    WG=find(strcmp(Data.Model.Gen.Tech,'WND'));
    CST=find(strcmp(Data.Model.Gen.Tech,'CST'));
    HD=find(strcmp(Data.Model.Gen.Tech,'HYDR'));

    Hydro_C=[0,0,1];
    Bl_C=[0.6,0.6,0.6];
    Br_C=[.65,.35,0];
    OG_C=[0,1,0];
    CG_C=[0,0.5,0];
    PV_C=[1,1,0];
    WG_C=[.5,.9,1];
    CST_C=[1,.4,0];

    Pn=Data.MarketSolution.Gen.Power;
    P_sorted=[sum(Pn(HD,:),1);sum(Pn(Br,:),1);sum(Pn(Bl,:),1);sum(Pn(WG,:),1);...
    sum(Pn(CST,:),1);sum(Pn(PV,:),1);sum(Pn(CG,:),1);sum(Pn(OG,:),1)];
    h = area([P_sorted'],'LineWidth',0.0001);


    set(h(8),'FaceColor',OG_C);
    set(h(8),'EdgeColor',OG_C);
    set(h(8),'DisplayName','OCGT');

    set(h(1),'FaceColor',Hydro_C);
    set(h(1),'EdgeColor',Hydro_C);
    set(h(1),'DisplayName','Hydro');
    set(h(3),'FaceColor',Bl_C);
    set(h(3),'EdgeColor',Bl_C);
    set(h(3),'DisplayName','Black Coal');
    set(h(2),'FaceColor',Br_C);
    set(h(2),'EdgeColor',Br_C);
    set(h(2),'DisplayName','Brown Coal');
    set(h(7),'FaceColor',CG_C);
    set(h(7),'EdgeColor',CG_C);
    set(h(7),'DisplayName','CCGT');
    set(h(6),'FaceColor',PV_C);        %cyan[.5,1,1]
    set(h(6),'EdgeColor',PV_C);
    set(h(6),'DisplayName','Utility PV');
    set(h(4),'FaceColor',WG_C);
    set(h(4),'EdgeColor',WG_C);
    set(h(4),'DisplayName','Wind');
    set(h(5),'FaceColor',CST_C);
    set(h(5),'EdgeColor',CST_C);
    set(h(5),'DisplayName','CST');

    xlabel('Time (hours)')
    ylabel('Power (MW)')
    xlim([1,Data.Model.Parameter.T_Hrz]);
    hold off;
    
end


