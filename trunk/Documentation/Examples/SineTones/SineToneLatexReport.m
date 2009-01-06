function SineToneLatexReport(AnalyserName)

carrier  = [16 32 63 125 250 500 1000 2000 4000 8000 16000];
level    = [20 30 40 50 60 70 80 90 100];
fs = 44100;
flen = [1 10 60 600 1800];

% Test Analyser
for i = 1:length(carrier)
  for j=1:length(level)
    % Create filehandle
    filename    = sprintf('%03.0fdB-%04.0fHz-Fs%05.0f.wav', level(j), carrier(i), fs);
    fh = readData(filename);
    fh = calibrate(fh, 'WithFiles', '060dB-1000Hz-Fs44100.wav', 60);
    obj = eval([AnalyserName '(fh)']);
    obj = process(obj,fh,[]);
    out{i,j} = obj.output;
  end
end


fid = fopen([AnalyserName '-Report.tex'],'w');
fprintf(fid,'\\documentclass{article}\n');
fprintf(fid,'\\usepackage{helvet,graphicx}\n');
fprintf(fid,'\\sffamily \n');
fprintf(fid,'\\usepackage[landscape,a4paper]{geometry}\n');
fprintf(fid,'\\begin{document}\n');
% Print out results
for z = 1:length(out{1,1})
  if ~strcmp(class(out{1,1}{z}),'tSeries')
    continue
  end
  fprintf(fid,'\\textbf{Sine Tone Testing}\\\\', out{1,1}{z}.Name);
  fprintf(fid,'Analyser: %s \\\\ \n', AnalyserName);
  fprintf(fid,'Time Series Output: %s,  ', out{1,1}{z}.Name);
  fprintf(fid,'Units: %s. \\\\ \n', out{1,1}{z}.DataInfo.Unit);
  fprintf(fid,'\\begin{tabular}{r|rrrrrrrrrr}\n');
  fprintf(fid,'Hz/dB \t');
  for j = 1:length(level)
    fprintf(fid,'& \\textbf{%3.d dB}\t', level(j));
  end
  fprintf(fid,'\\\\ \n');
  for i=1:length(carrier)
    fprintf(fid,'\\textbf{%4.d Hz}\t', carrier(i));
    for j=1:length(level)
      medData = out{i,j}{z}.median;
      plotMat(i,j) = medData;
      fprintf(fid,'& %6.2f \t',medData);
    end
    fprintf(fid,'\\\\ \n');
  end
  fprintf(fid,'\\end{tabular} \\\\ \n');
  semilogx(carrier,plotMat);
  xlabel('Carrier Frequency (Hz)'); 
  ylabel([out{1,1}{z}.Name ' (' out{1,1}{z}.DataInfo.Unit ')']);
  filename = sprintf('%s-%s.jpg', AnalyserName,  strrep(out{1,1}{z}.Name,' ',''));
  legend({'20dB' '30dB' '40dB' '50dB' '60dB' '70dB' '80dB' '90dB' '100dB'}');
  saveas(gcf,filename,'jpeg');
  fprintf(fid,'\\includegraphics[width=0.5\\textwidth]{%s}\n',filename);
  fprintf(fid,'\\clearpage\n');
end

fprintf(fid,'\\end{document}\n');
fclose(fid);
system(['pdflatex ' AnalyserName '-Report.tex']);