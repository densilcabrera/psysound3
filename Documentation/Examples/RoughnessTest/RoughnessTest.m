function RoughnessTest()
% Testing Roughness Code.

 carrier  = [250 500 1000 2000 4000];
 am       = [20 30 40 50 60 70 80 90 100 110];
 pref     = 20e-6;

%carrier = 1000;
%am =70;

for i=1:length(carrier)
  for j=1:length(am)
    % Create Sound and Save
    wave        = synthSound(carrier(i),44100,60,2,am(j),10,1,0);
    wave = wave/max(abs(wave));
    wavwrite(wave,44100,24,'sound.wav');
    % Load filehandle
    fh           = readData('sound.wav');
    fh.calCoeff  = 1;        % Calibrate
    
    obj          = SLM(fh);
    obj.wChoices = 'Z';
    obj          = process(obj,fh,[]);  % process the object
    
    values = obj.output{1}.data(~isnan(obj.output{1}.data));
    fh.calCoeff  = 10^((63.876 - median(values))/20); % Roughness tends to use strange values for cal.
    
    obj          = SLM(fh);
    obj.wChoices = 'Z';
    obj          = process(obj,fh,[]);  % process the object
    values = obj.output{1}.data(~isnan(obj.output{1}.data));
    disp(median(values));
    
    
    clear('obj');
    obj         = RoughnessDW(fh);    % Analyser Instantiation

    obj         = process(obj,fh,[]);  % process the object
    data1(i,j)   = median(obj.output{1}.data); 
		clear('obj');
% 		obj         = RoughnessDW2(fh);    % Analyser Instantiation
%     obj         = process(obj,fh,[]);  % process the object
%     data2(i,j)   = median(obj.output{1}.data); 
%     clear('obj');
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
fprintf('Model Data\t Subjective Data \t Model-Subjc \t Percentage Difference \t Carrier Freq\t AM Freq\n');
fprintf('\n');

for i=1:length(carrier)
  for j=1:length(am)
    fprintf(' %.2f\t %.2f\t %.2f\t %.2f\t %.2f \t %.2f\n', data1(j,i), subjectivedata(j,i),  data1(j,i) - subjectivedata(j,i),difference1(j,i), carrier(i), am(j));
  end
end
