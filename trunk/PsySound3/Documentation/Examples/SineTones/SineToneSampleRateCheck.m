function out = SineToneSynchroniseCheck(AnalyserName)

carrier  = 1000;
level    = 60;
fs = [8000 44100 48000 96000];
fsync = [ 100 50 29 10 5 2];
flen = [1 10 60 600 1800];



% Test Analyser
    for i=1:length(fs)
      % Create filehandle
      filename    = sprintf('%03.0fdB-%04.0fHz-Fs%05.0f.wav', level,carrier,fs(i));
      fh = readData(filename);
      fh = calibrate(fh, 'WithFiles', '060dB-1000Hz-Fs44100.wav', 60);
      obj = eval([AnalyserName '(fh)']);
      obj = process(obj,fh,[]);
      out{i} = obj.output;
    end


fid = fopen([AnalyserName '-SampleRate.tex'],'w');
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
fprintf(fid,'Sample Rate & Min Time Interval & Max Time Interval & Graph');
fprintf(fid,'\\\\ \n');
for i=1:length(fs)
  fprintf(fid,'\\textbf{%4.d Hz}\t', fs(i));
  minInt = min(diff(out{i}{z}.Time));
  maxInt = max(diff(out{i}{z}.Time));
  fprintf(fid,'& %6.8f & %6.8f \t',minInt, maxInt);
  filename = ['SyncHz'  sprintf('%04.0f',fs(i))  '-Analyser' AnalyserName '-Output' strrep(char( out{1}{z}.Name),' ','') '.jpg'];
  plot(out{i}{z});
  saveas(gcf,filename,'jpeg');
  fprintf(fid,'&\\includegraphics[width=0.25\\textwidth]{%s}\t',filename);
  fprintf(fid,'\\\\ \n');
end
fprintf(fid,'\\end{tabular}\n');
fprintf(fid,'\\clearpage\n');
end
fprintf(fid,'\\end{document}\n');
fclose(fid);
system(['pdflatex ' AnalyserName '-SampleRate.tex']);