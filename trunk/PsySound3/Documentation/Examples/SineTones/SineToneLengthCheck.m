function out = SineToneSynchroniseCheck(AnalyserName)

carrier  = 1000;
level    = 60;
fs = 44100;
fsync = [ 100 50 29 10 5 2];
flen = [1 10 60 600 1200 1800];
for i=1:length(carrier)
  for j=1:length(level)
    for k =1:length(flen)
      try
			% Create Sound and Save
      wave        = synthSound(carrier(i),fs,level(j),flen(k),0,0,0,0);
      wave = wave * 0.000001;
      filename    = sprintf('%03.0fdB-%04.0fHz-Length%04.0f.wav', level(j),carrier(i),flen(k));
      wavwrite(wave,fs,24,filename);
			catch
			  disp(' Failed synthesis at length:')
				disp(flen(k))
			end
    end
  end
end



% Test Analyser
    for i=1:length(flen)
      % Create filehandle
      filename    = sprintf('%03.0fdB-%04.0fHz-Length%05.0f.wav', level,carrier,flen(i));
      fh = readData(filename);
      fh = calibrate(fh, 'WithFiles', '060dB-1000Hz-Fs44100.wav', 60);
      obj = eval([AnalyserName '(fh)']);
      
			try
				obj = process(obj,fh,[]);
        out{i} = obj.output;
      catch
				out{i} = ['Failed at' num2str(flen(i))];
      end
    end


fid = fopen([AnalyserName '-LengthCheck.tex'],'w');
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
  for i=1:length(flen)
    fprintf(fid,'\\textbf{%4.d Hz}\t', flen(i));
    minInt = min(diff(out{i}{z}.Time));
    maxInt = max(diff(out{i}{z}.Time));
    fprintf(fid,'& %6.2f & %6.2f \t',minInt, maxInt);
    filename = ['SyncHz'  sprintf('%04.0f',flen(i))  '-Analyser' AnalyserName '-Output' strrep(char( out{1}{z}.Name),' ','') '.jpg'];
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
system(['pdflatex ' AnalyserName '-LengthCheck.tex']);
