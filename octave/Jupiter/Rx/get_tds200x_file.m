## Author: philippe coste <phil@phil-debian-pc>
## Created: 2022-10-05

function s=get_tds200x_file(file)
  m1 = read_tds200x_file(file,",",0,3);
  dt_csv = m1(2,1)-m1(1,1);
  step = round(1e-4/dt_csv);% Te=100us  
  printf("dt_csv=%f\n",dt_csv);
  n1 = length(m1);
  n  = round(n1/step);
  idx= (1:n)*step;
  s  = m1(idx,:);  
endfunction

% read file tecktronic tds2000 series saved files 
function m=read_tds200x_file(file,sep,row_n,col_n)
  m=dlmread(file,sep,row_n,col_n);
endfunction
