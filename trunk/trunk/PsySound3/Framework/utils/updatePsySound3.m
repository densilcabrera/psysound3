function updatePsySound3
% UPDATEPSYSOUND3 Updates from the SVN repository

cwd = pwd;
psdir = fileparts(which('psysound3'));
cd(psdir);

str = '/usr/local/bin/svn up';

[s, w] = unix(str);
if s
    error(w);
end

cd(cwd);
