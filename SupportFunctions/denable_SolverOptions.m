function denable_SolverOptions(hOBject,eventdata)
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

    h=findobj('Tag','EGT');
    h.Enable='off';
    h=findobj('Tag','TGT');
    h.Enable='off';
    h=findobj('Tag','EGG');
    h.Enable='off';
    h=findobj('Tag','TGG');
    h.Enable='off';
    h=findobj('Tag','ECT');
    h.Enable='off';
    h=findobj('Tag','TCT');
    h.Enable='off';
    h=findobj('Tag','ECG');
    h.Enable='off';
    h=findobj('Tag','TCG');
    h.Enable='off';
    h=findobj('Tag','ECD');
    h.Enable='off';
    h=findobj('Tag','TCD');
    h.Enable='off';

    h=findobj('Tag','PSS');
    if h.Value==1
         h=findobj('Tag','ECT');
         h.Enable='on';
         h=findobj('Tag','TCT');
         h.Enable='on';
         h=findobj('Tag','ECG');
         h.Enable='on';
         h=findobj('Tag','TCG');
         h.Enable='on';
         h=findobj('Tag','ECD');
         h.Enable='on';
         h=findobj('Tag','TCD');
         h.Enable='on';
    end
    
    if h.Value==2        
        h=findobj('Tag','EGT');
        h.Enable='on';
        h=findobj('Tag','TGT');
        h.Enable='on';
        h=findobj('Tag','EGG');
        h.Enable='on';
        h=findobj('Tag','TGG');
        h.Enable='on';
    end
end