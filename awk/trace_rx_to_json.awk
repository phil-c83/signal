#! /usr/bin/gawk

# read Jupiter E Rx trace file and write each measure blocks in separate JSON files
# ie each block between 'RESULTAT' and 'END'


BEGIN { 
    fname_ref="trace"
    fext ="json"
    nfile=0
    write_to_file=0
}    



$0 ~ /RESULTAT/ {
    nfile = nfile + 1
    fname = fname_ref nfile "." fext
    #print fname
    write_to_file=1
}

$0 ~ /END/ {
    #print "END"
    write_to_file=0
}

{
    if (write_to_file && $0 !~ /RESULTAT/ && $0 !~ /END/)
        print $0 > FILENAME "_" fname
}