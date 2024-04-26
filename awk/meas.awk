#! /usr/bin/gawk

# extract impedance measures on a log file for seeking 
# Z=f(T) ie functionnal dependance between impedance and temperature
# we scan log file for measures at defined time, here 25mn
# file format is what jupiterE Tx produce

function time2meas(t,dt_meas) { return t/dt_meas; }

BEGIN { 
	NCLAMPS = 3;
	nzl=NCLAMPS;	
	dt_meas=3 ; # seconds between measures	
	step=60*25; # seconds elapsed between seeked measures
	time=step;	
	nmeas = 0;
	# init vectors of strings to concatenate arg/mod values into
	for (i=0 ; i<NCLAMPS ; ++i){
		arg[i]="arg_" i "=[";
		mod[i]="mod_" i "=[";		
	}
	
	if(NMEAS) {
		print NMEAS
	} else {
		print "NMEAS must be define: ie " ARGV[0] " -v NMEAS=<n>"
		exit 1;
	}
	
	# floating point numbers grammar
	# sign = "[+-]?"
    # decimal = "[0-9]+[.]?[0-9]*"
    # fraction = "[.][0-9]+"
    # exponent = "([eE]" sign "[0-9]+)?"
    # number = "^" sign "(" decimal "|" fraction ")" exponent "$"
    # print number
}

# find lines that contain the right measure numbers
$3 ~ /meas=[0-9]+/ { 
	pos = match($3,"="); 
	n = substr($3,pos+1); #get measure number		 
	if (n == time2meas(time,dt_meas)) {
		time += step;
		#print n;		
		nzl = 0;
		nmeas += 1;	
		if(nmeas > NMEAS)
			exit 0;
		#next;		
	}
}

# extract Zln measure value for each clamp
$1 ~ "ZLn:" { 
	if (nzl<NCLAMPS){ 
		
		zl = $6; # complex number: <mod>'/'<arg>
		pos = index($6,"/");
		m   = substr($6,1,pos-1);
		a   = substr($6,pos+1,length($6)-pos);
		
		num[nmeas] = n ;
		# concatenate each arg/mod values
		if( nmeas == 1 ) {
			arg[nzl] = arg[nzl]  a
			mod[nzl] = mod[nzl]  m
		} else {
			arg[nzl] = arg[nzl]  "," a
			mod[nzl] = mod[nzl]  "," m		
		}		
		nzl += 1;		
	}
} 


END {	
	if(NMEAS) {
		for(i=0 ; i<NCLAMPS ; ++i){
			arg[i] = arg[i] "];"
			mod[i] = mod[i] "];"		
			print arg[i]
			print mod[i]
		}	
	}
}
