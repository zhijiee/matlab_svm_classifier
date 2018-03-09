load('fYTest.mat'); 
fid=fopen('fYTest.txt','w');
for i=1:length(fYTest)
    fprintf(fid, '%s\n', num2str(fYTest(i)));
end
fclose(fid);

load('fXTest.mat'); 
fid=fopen('fXTest.txt','w');
for i=1:length(fYTest)
    fprintf(fid, '%s\n', num2str(fYTest(i)));
end
fclose(fid);