1;
#cl1_Z0 = [0.765,0.779,0.798,0.811,0.822,0.828,0.836,0.850,0.852,0.854,0.856,0.858,0.858];
#cl2_Z0 = [0.723,0.740,0.782,0.798,0.824,0.838,0.859,0.854,0.867,0.872,0.877,0.874,0.871];
#cl3_Z0 = [0.731,0.744,0.768,0.786,0.808,0.825,0.836,0.812,0.815,0.824,0.828,0.833,0.832];
#figure;
#plot(temp,cl1_Z0,temp,cl2_Z0,temp,cl3_Z0);

#join 2 vectors, overlap end of v1 with start of v2 with the mean of the 2 values
#[v1_1 v1_2 ... (v1_n+v2_1)/2 v2_2 v2_3 ... v2_m]
function v=vect_join_with_mean(v1,v2)
  v = [ v1(1:length(v1)-1) ...
       (v1(length(v1))+ v2(1))/2 ... # mean
        v2(2:length(v2)) ];
endfunction

temp=[-10,-5,0,5,10,15,20,25,30,35,40,45,50];

# measured Z0 arg/mod @500Hz for 20°C -10°C
argn_0=[+0.431,+0.430,+0.428,+0.425,+0.426,+0.426,+0.429];
modn_0=[+0.833,+0.832,+0.826,+0.817,+0.809,+0.795,+0.777];
argn_1=[+0.394,+0.397,+0.398,+0.393,+0.396,+0.406,+0.414];
modn_1=[+0.859,+0.837,+0.822,+0.825,+0.795,+0.770,+0.742];
argn_2=[+0.388,+0.389,+0.387,+0.390,+0.388,+0.389,+0.395];
modn_2=[+0.839,+0.825,+0.815,+0.799,+0.785,+0.765,+0.744];

# array in reverse order for increasing Temp
argn_0 = argn_0(length(argn_0):-1:1);
modn_0 = modn_0(length(modn_0):-1:1);
argn_1 = argn_1(length(argn_1):-1:1);
modn_1 = modn_1(length(modn_1):-1:1);
argn_2 = argn_2(length(argn_2):-1:1);
modn_2 = modn_2(length(modn_2):-1:1);

# measured Z0 arg/mod @500Hz for 20°C 50°C
argp_0=[+0.434,+0.433,+0.434,+0.437,+0.438,+0.439,+0.438];
modp_0=[+0.843,+0.846,+0.850,+0.852,+0.853,+0.856,+0.858];
argp_1=[+0.402,+0.402,+0.399,+0.406,+0.409,+0.413,+0.415];
modp_1=[+0.846,+0.856,+0.874,+0.865,+0.870,+0.868,+0.870];
argp_2=[+0.413,+0.414,+0.420,+0.422,+0.418,+0.421,+0.421];
modp_2=[+0.802,+0.807,+0.812,+0.812,+0.826,+0.827,+0.829];

#concatenate arrays to yield values for -10°C to 50°C
Z0_arg_0 = vect_join_with_mean(argn_0,argp_0);
Z0_arg_1 = vect_join_with_mean(argn_1,argp_1);
Z0_arg_2 = vect_join_with_mean(argn_2,argp_2);

Z0_mod_0 = vect_join_with_mean(modn_0,modp_0);
Z0_mod_1 = vect_join_with_mean(modn_1,modp_1);
Z0_mod_2 = vect_join_with_mean(modn_2,modp_2);

[x0,y0] = pol2cart(Z0_arg_0,Z0_mod_0);
Z0_0     = x0 + i*y0;
[x1,y1] = pol2cart(Z0_arg_1,Z0_mod_1);
Z0_1     = x1 + i*y1;
[x2,y2] = pol2cart(Z0_arg_2,Z0_mod_2);
Z0_2     = x2 + i*y2;
