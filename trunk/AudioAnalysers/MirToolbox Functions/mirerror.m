function mirerror(operator,message)

errordlg([operator,': ',message],'MIRtoolbox error');
error(['ERROR using ',operator,': ', message]);