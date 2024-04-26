#!/usr/bin/gawk

/"sample_xx_faible":\[/,/[0-9]+\]/ {
    sub(/"sample_xx_faible":\[/,"sig=[")
    s = gensub(/([0-9]+\])\,/,"\\1;",1)
    if (s == $0)  print $0"..."
    else  {        
        print s
    }
}