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

    Sol.Dual.Balance=get_data_dualVariable_AMPL(ampl,'Balance',[T,B])';
    Sol.Gen.Status=get_data_decisionVariable_AMPL(ampl,'Status_var',[T,G])';
    Sol.Gen.S_Up=get_data_decisionVariable_AMPL(ampl,'S_Up_var',[T,G])';
    Sol.Gen.S_Dn=get_data_decisionVariable_AMPL(ampl,'S_Down_var',[T,G])';
    Sol.Gen.Power=get_data_decisionVariable_AMPL(ampl,'Pwr_Gen_var',[T,G])';
    Sol.Line.Power=get_data_decisionVariable_AMPL(ampl,...
         'Pwr_line_var',[T,L])';

     Sol.Bus.Angle=get_data_decisionVariable_AMPL(ampl,'Angle_bus_var',[T,B])';

    if Parameter.en_Type3
        Sol.Gen.Strg_engy=get_data_decisionVariable_AMPL(ampl,'Enrg_TES_var',[T,length(Gen.Seq_Type3)])';
        Sol.Gen.GenT3_Rsv=get_data_decisionVariable_AMPL(ampl,'GenT3_Rsv_var',[T,length(Gen.Seq_Type3)])';
    end
    if Parameter.en_Uty_Strg
        Sol.Uty_Storage.Power=get_data_decisionVariable_AMPL(ampl,'Pwr_Strg_var',[T,S])';
%         Sol.Uty_Storage.Power.Chrg=get_data_decisionVariable_AMPL(ampl,'Pwr_chrg_Strg_var',[T,S])';
%         Sol.Uty_Storage.Power.Dchrg=get_data_decisionVariable_AMPL(ampl,'Pwr_dchrg_Strg_var',[T,S])';
        Sol.Uty_Storage.Energy=get_data_decisionVariable_AMPL(ampl,'Enrg_Strg_var',[T,S])';
    end

    if Parameter.en_DR
        Sol.Bus.prosumer_gridpower=get_data_decisionVariable_AMPL(ampl,'Pwr_pgp_var',[T,B])';
        Sol.Bus.Battery.Power_chrg=get_data_decisionVariable_AMPL(ampl,'Pwr_batc_var',[T,B])';
        Sol.Bus.Battery.Power_dchrg=get_data_decisionVariable_AMPL(ampl,'Pwr_batd_var',[T,B])';
        Sol.Bus.Battery.Power=Sol.Bus.Battery.Power_chrg-Sol.Bus.Battery.Power_dchrg;
        Sol.Bus.Battery.Energy=get_data_decisionVariable_AMPL(ampl,'Engy_bat_var',[T,B])';
        Sol.Bus.PV.utilisedpower=get_data_decisionVariable_AMPL(ampl,'Pwr_pv_var',[T,B])';
%         Sol.Bus.PV.spill=get_data_decisionVariable_AMPL(ampl,'Pwr_sp_var',[T,B])';
    %     Sol.Bus.Slack.rc=get_data_decisionVariable_AMPL(ampl,'rho_ce_var',[T,B])';
    %     Sol.Bus.feedin_power=get_data_decisionVariable_AMPL(ampl,'Pwr_pgn_var',[T,B])';
    %     Sol.Bus.batteryandload_power=get_data_decisionVariable_AMPL(ampl,'Pwr_bal_var',[T,B])';
    end
