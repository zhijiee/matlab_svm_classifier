
function my_save_model()

load('mdl.mat'); % opens the mat file with svm struct of model, variable name of struct is 'svm' 

fid=fopen('svm_model.txt','w');

%Parameters 
fprintf(fid,'%s %s\n','svm_type','c_svc'); % c_svc
fprintf(fid,'%s %s\n','kernel_type','rbf'); % rbf 
fprintf(fid,'%s %s\n','degree', '3');
fprintf(fid,'%s %s\n','gamma', '0.5');

%Variables
fprintf(fid,'%s %s\n','nr_class', '2'); % 
fprintf(fid,'%s %s\n','total_sv',num2str(mdl.totalSV)); 
fprintf(fid,'%s %s\n','rho',num2str(mdl.rho));

fprintf(fid,'%s %s %s\n','label',num2str(mdl.Label(1)), num2str(mdl.Label(2)) );

fprintf(fid,'%s %s\n','probA',num2str(mdl.ProbA));
fprintf(fid,'%s %s\n','probB',num2str(mdl.ProbB));
fprintf(fid,'%s %s %s\n','nr_sv',num2str(mdl.nSV(1)),num2str(mdl.nSV(2)));


fprintf(fid,'%s\n','SV');

FullSVs=full(mdl.SVs);
mSize = size(mdl.SVs);

for i=1:mSize(1)
    fprintf(fid, '%s', num2str(mdl.sv_coef(i)));
    %fprintf(fid, '%s %s\n', [' 0:' num2str(FullSVs(i,1))],[' 1:' num2str(FullSVs(i,2))]);
    for j=1:mSize(2)
       fprintf(fid, '%s %s', [' ' num2str(j-1) ':' num2str(FullSVs(i,j))]);
    end
    fprintf(fid, '\n');
end

fclose(fid);
end