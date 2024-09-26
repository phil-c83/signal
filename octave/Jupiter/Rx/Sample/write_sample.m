## Copyright (C) 2024

## Author:  <phil@archlinux>
## Created: 2024-09-02

function ret = write_sample(fpath,fname,json_str)

  json = jsondecode(json_str);

  if( strcmp(json.result.sensor,"ROG" ) )
    ret = write_rog(fpath,fname,
                    json.result.sample_xx_faible,
                    json.result.sample_xx_fort);

  elseif( strcmp(json.result.sensor,"PT" ) )
    ret = write_pt(fpath,fname,
                   json.result.sample_xx_faible,
                   json.result.sample_xx_fort);

  elseif( strcmp(json.result.sensor,"PREID" ) )
    printf("xx_faible[0]=%u xx_fort[0]=%u bl_faible[0]=%u bl_fort[0]=%u\n",
            json.result.sample_xx_faible(1),json.result.sample_xx_fort(1),
            json.result.sample_bl_faible(1),json.result.sample_bl_fort(1));

    ret = write_pid(fpath,fname,
                    json.result.sample_xx_faible,
                    json.result.sample_xx_fort,
                    json.result.sample_bl_faible,
                    json.result.sample_bl_fort);
  else ret=1;
  end

endfunction

function name = mk_fname(sensor,fpath,fname,ext)
  idx  = index(fname,".");
  name = [fpath "/" sensor "_" fname(1:idx-1) "." ext];
endfunction

function ret = write_rog(fpath,fname,lg_samples,hg_samples)

  #fname = "ROG_XXXXXX";
  #[fid, name, msg] = mkstemp (fname);
  name = mk_fname("ROG",fpath,fname,"bin");
  fid = fopen (name,"w");
  if( fid == -1 )
    fprintf(stderr,"fopen(): failed %s",name);
    ret = 1;
  else
    fwrite(fid,lg_samples,"float32");
    fwrite(fid,hg_samples,"float32");
    fclose(fid);
    ret = 0;
  end

endfunction


function ret = write_pt(fpath,fname,lg_samples,hg_samples)

  #fname = "PT_XXXXXX";
  #[fid, name, msg] = mkstemp (fname);
  name = mk_fname("PT",fpath,fname,"bin");
  fid = fopen (name,"w");
  if( fid == -1 )
    fprintf(stderr,"fopen(): failed %s",name);
    ret = 1;
  else
    fwrite(fid,lg_samples,"float32");
    fwrite(fid,hg_samples,"float32");
    fclose(fid);
    rer = 0;
  end

endfunction

function ret = write_pid(fpath,fname,
                         lg_bp_samples,hg_bp_samples,
                         lg_bl_samples,hg_bl_samples)

  #fname = "PID_XXXXXX";
  #[fid, name, msg] = mkstemp (fname);
  name = mk_fname("PID",fpath,fname,"bin");
  fid = fopen (name,"w");
  if( fid == -1 )
    fprintf(stderr,"fopen(): failed %s",name);
    ret = 1;
  else
    printf("lg_bp[0]=%u hg_bp[0]=%u lg_bl[0]=%u hg_bl[0]=%u\n",
            lg_bp_samples(1),hg_bp_samples(1),lg_bl_samples(1),hg_bl_samples(1));
    fwrite(fid,lg_bp_samples,"float32");
    fwrite(fid,hg_bp_samples,"float32");
    fwrite(fid,lg_bl_samples,"float32");
    fwrite(fid,hg_bl_samples,"float32");
    fclose(fid);
    ret = 0;
  end

endfunction
