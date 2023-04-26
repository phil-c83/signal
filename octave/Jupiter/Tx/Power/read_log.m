## Copyright (C) 2023

## Author:  <phil@archlinux>
## Created: 2023-04-17
# read log file with I,U vectors
function [U1,I1,U2,I2,U3,I3] = read_log (fqname)
  fid = fopen(fqname);
  I1={};I2={};I3={};U1={};U2={};U3={};
  while((str=fgetl(fid)) != -1)
  # 1st token: I|U, 2nd token clamp number,3rd token data
    [s,e,te] = regexp(str,"^(I|U)_ch([012])=(.*)$");
    if( length(s) != 0)
      #disp(te{1,1}(1,1));
      #printf("%s\n",str(te{1,1}(3,1):te{1,1}(3,2)));
      noclamp = str(te{1,1}(2,1));
      vdata   = str2num(str(te{1,1}(3,1):te{1,1}(3,2)));
      if( str(te{1,1}(1,1)) == 'I')
        if ( noclamp == '0')
          I1{numel(I1)+1} = vdata';
        elseif( noclamp == '1')
          I2{numel(I2)+1} = vdata';
        elseif( noclamp == '2')
          I3{numel(I3)+1} = vdata';
        endif
      elseif(str(te{1,1}(1,1)) == 'U')
        if ( noclamp == '0')
          U1{numel(U1)+1} = vdata';
        elseif( noclamp == '1')
          U2{numel(U2)+1} = vdata';
        elseif( noclamp == '2')
          U3{numel(U3)+1} = vdata';
        endif
      endif
    endif
   end
endfunction
