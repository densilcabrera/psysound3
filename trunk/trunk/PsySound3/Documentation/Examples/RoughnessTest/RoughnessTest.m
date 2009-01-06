function RoughnessTest()
% Testing Roughness Code.

carrier  = [250 500 1000 2000 4000];
am       = [20 30 40 50 60 70 80 90 100 110];
pref     = 20e-6;

for i=1:length(carrier)
  for j=1:length(am)
    % Create Sound and Save
    wave        = synthSound(carrier(i),44100,60,2,am(j),10,1,0);
    wave = wave/max(abs(wave));
    wavwrite(wave,44100,24,'sound.wav');
    % Load filehandle
    fh          = readData('sound.wav');
    fh.calCoeff = 1;        % Calibrate
    
    obj         = SLM(fh);
    obj         = process(obj,fh,[]);  % process the object
    fh.calCoeff = 10^((60 - median(obj.output{1}.data))/20);
    clear('obj');
    obj         = RoughnessDW(fh);    % Analyser Instantiation
    obj         = process(obj,fh,[]);  % process the object
    data1(i,j)   = median(obj.output{1}.data); 
		clear('obj');
		obj         = RoughnessDW2(fh);    % Analyser Instantiation
    obj         = process(obj,fh,[]);  % process the object
    data2(i,j)   = median(obj.output{1}.data); 
    clear('obj');
  end
end

% The subjective data from the paper.
subjectivedata =  ...
   [0.2500    0.2500    0.2500    0.2000    0.1500;
    0.4000    0.4000    0.4500    0.3500    0.3000;
    0.5000    0.6000    0.6500    0.5000    0.4000;
    0.5000    0.7000    0.8500    0.7500    0.5500;
    0.4000    0.7000    0.9500    0.8000    0.6500;
    0.3000    0.6000    1.0000    0.8500    0.7000;
    0.2500    0.5500    0.9500    0.8000    0.6500;
    0.2000    0.4500    0.9000    0.7500    0.6000;
    0.2000    0.3500    0.7500    0.6500    0.5000;
    0.1500    0.3000    0.6500    0.5500    0.4000;];
 
data1 = data1';
difference1 = (data1 - subjectivedata)./subjectivedata * 100;
data2 = data2';
difference2 = (data2 - subjectivedata)./subjectivedata * 100;
fprintf('\n');
for i=1:length(carrier)
  for j=1:length(am)
    fprintf('%.2f\t  %.2f(%.2f)\t %.2f(%.2f)\t -- %.2f %.2f\n', subjectivedata(j,i), data1(j,i), difference1(j,i), data2(j,i), difference2(j,i), carrier(i), am(j));
  end
end