function out = SineToneSynchroniseCheck(AnalyserName)

carrier  = 1000;
level    = 60;
fs = 44100;
fsync = [ 100 50 29 10 5 2];
flen = [1 10 60 600 1800];



filename    = sprintf('%03.0fdB-%04.0fHz-Fs%05.0f.wav', level,carrier,fs);
fh = readData(filename);
fh = calibrate(fh, 'WithFiles', '060dB-1000Hz-Fs44100.wav', 60);
obj = eval([AnalyserName '(fh)']);
obj = process(obj,fh,[]);
out{1} = obj.output;


% Test Analysers with various sample rates.
for i=1:length(fsync)
  % Create filehandle
  filename    = sprintf('%03.0fdB-%04.0fHz-Fs%05.0f.wav', level,carrier,fs);
  fh = readData(filename);
  fh = calibrate(fh, 'WithFiles', '060dB-1000Hz-Fs44100.wav', 60);
  obj = eval([AnalyserName '(fh)']);
  try 
    obj = process(obj,fh,[],'synchronise',fsync(i));
    out{i+1} = obj.output;
  catch
    out{i+1} = lasterr;
  end
end

% Write the report.
fid = fopen([AnalyserName '-Synchronise.tex'],'w');
fprintf(fid,'\\documentclass{article}\n');
fprintf(fid,'\\usepackage{helvet,graphicx}\n');
fprintf(fid,'\\sffamily\n');
fprintf(fid,'\\usepackage[a4paper]{geometry}\n');
fprintf(fid,'\\begin{document}\n');
% Print out results
for z = 1:length(out{1})
if ~strcmp(class(out{1}{z}),'tSeries')
continue
end
fprintf(fid,'\\textbf{Sine Tone Testing}\\\\ \n', out{1}{z}.Name);
fprintf(fid,'Analyser: %s \\\\ \n', AnalyserName);
fprintf(fid,'Time Series Output: %s \\\\ \n', out{1}{z}.Name);
fprintf(fid,'Units: %s \\\\ \n', out{1}{z}.DataInfo.Unit);
fprintf(fid,'Time Interval Range: %.4f - %.4f \\\\ \n', min(diff(out{1}{z}.Time)), max(diff(out{1}{z}.Time)));
fprintf(fid,'\\begin{tabular}{r|rrrr}\n');
fprintf(fid,'Sync Rate & Min Time Interval & Max Time Interval & Graph');
fprintf(fid,'\\\\ \n');
for i=1:length(fsync)
  fprintf(fid,'\\textbf{%4.d Hz}\t', fsync(i));
  try
    minInt = min(diff(out{i}{z}.Time));
    maxInt = max(diff(out{i}{z}.Time));
  fprintf(fid,'& %6.6f & %6.6f \t',minInt, maxInt);
  catch
    minInt = out{i}(1:20);
    maxInt = out{i}(1:20);
   fprintf(fid,'& %6.6f & s \t',minInt, maxInt);
 end
  
  filename = ['SyncHz'  sprintf('%04.0f',fsync(i))  '-Analyser' AnalyserName '-Output' strrep(char( out{1}{z}.Name),' ','') '.jpg'];
  clf;
  plot(out{1}{z}); hold on;
  plot(out{i}{z});
	legend({'Original Unsynchronised','Synchronised'});
  saveas(gcf,filename,'jpeg');
  fprintf(fid,'&\\includegraphics[width=0.25\\textwidth]{%s}\t',filename);
  fprintf(fid,'\\\\ \n');
end
fprintf(fid,'\\end{tabular}\n');
fprintf(fid,'\\clearpage\n');
end
fprintf(fid,'\\end{document}\n');
fclose(fid);
system(['pdflatex ' AnalyserName '-Synchronise.tex']);