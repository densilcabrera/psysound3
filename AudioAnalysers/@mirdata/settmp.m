function x = settmp(x,tmp)

idx = get(x,'TmpIdx');
tmps = get(x,'InterChunk');
tmps{idx} = tmp;
x = set(x,'InterChunk',tmps);