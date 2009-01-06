function out = getAnalyserSettingsString(obj)
% GETANALYSERSETTINGSSTRING  Returns a string for display purposes
%                            of the analyser settings

%  Fixup windowFunc
w = get(obj, 'windowFunc');
if strcmp(w, 'rect')
  w = 'rectangular';
end

out = ['Prefilter weighting type : ', w];
