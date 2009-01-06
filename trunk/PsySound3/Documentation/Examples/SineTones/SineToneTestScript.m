%% Sine Tone Testing applied to all Analysers
%
% Automated reporting plays a big part in testing PsySound3. The method we
% have used is to automate wave file writing and then test each option using
% various scripts. These scripts run analysers, print figures, and then
% write a latex tex file and create a pdf file from that. This produces an
% easy to read report for each of the files.
%
% We test: Analyser Median Outputs, Analyser Synchronisation, Various
% Sample Rates and Various File Lengths.


%% Check I'm in the right directory.

% This finds the path of this MFILE
folderpath = fileparts(mfilename('fullpath'));

% If not the same then move to correct directory
if ~strcmp(pwd,folderpath)
  cd (folderpath)
end


%% Produce Sine Tones
%SineToneCreation;

%% List of Analysers to be tested
Analysers = getAnalysers;


% %% Median Outputs
% %
% This produces a file with reports for each of the timeseries outputs from
% % the list of analysers
% for an = 1:length(Analysers)
%   SineToneLatexReport(char(Analysers(an)));
% end
% 
% %% Sample Rate
% %
% % This produces a file with reports for each of the timeseries outputs with
% % various sample rates - 8k, 44.1k, 48k, and 96k. 
% for an = 1:length(Analysers)
%    try
%      SineToneSampleRateCheck(char(Analysers(an)));
%    catch
%      fsfail{an} = char(Analysers(an));
%    end
% end
% disp('Sampling rate Failure:');
% fsfail'
% 
% %% File Length
% %
% % Check the maximum file length that can be produced.
% for an = 1:length(Analysers)
%   try
%     SineToneLengthCheck(char(Analysers(an)));
%   catch
%     lenfail{an} = char(Analysers(an));
%   end
% end
% disp('LengthFailure:');
% lenfail'


%% Synchronisation
%
% Check the file length.
for an = 1:length(Analysers)
    SineToneSynchroniseCheck(char(Analysers(an)));
end
disp('Sync Failure:');
syncfail'
syncfailr'

%% Deletion of all wave and aux files.
% delete('*.wav')
% delete('*.log');
% delete('*.jpg');
% delete('*.tex');
% delete('*.aux');
% 

