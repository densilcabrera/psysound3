function val = queryFiles(obj, varargin)
% QUERYFILES Method for the dataStorageTree object
%
% Check what files are in the tree

if nargin == 1
	names= {};
	for i = 1:length(obj.tree)
  	if ~sum(strcmp(obj.tree(i).audiofile, names))
  		names(end + 1) = {obj.tree(i).audiofile};
		end
	end
	val = names;
elseif nargin == 2
	val = 0;
	for i = 1:length(obj.tree)
  	if sum(strcmp(obj.tree(i).audiofile, varargin{1}))
  		val = 1;
		end
  end
end


% EOF
