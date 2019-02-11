function mpc = MATPOWER_case_gen(Data)
%% MATPOWER Case Format : Version 2
%   Please see CASEFORMAT for details on the case file format.
mpc.version = '2';
%%-----  Power Flow Data  -----%%
%% system MVA base
mpc.baseMVA = Data.Model.Parameter.Base_power;

%% bus data
%	bus_i	type	Pd	Qd	Gs	Bs	area	Vm	Va	baseKV	zone	Vmax	Vmin
bus_seq=[1:Data.Model.Parameter.B]';
Pd=zeros(size(bus_seq));
Qd=zeros(size(bus_seq));
Gs=zeros(size(bus_seq));
Bs=zeros(size(bus_seq));
area=ones(size(bus_seq)); % fix this in future
Vm=ones(size(bus_seq));
Va=zeros(size(bus_seq));
baseKV=Data.Model.Bus.Base_kV;
zone=ones(size(bus_seq));
Vmax=Data.Model.Bus.Maximum_Voltage_limit_pu;
Vmin=Data.Model.Bus.Minimum_Voltage_limit_pu;



temp=Data.Model.Bus.Type;
Zero_ind_bus=find(Data.Model.Bus.Type==0);
temp(Zero_ind_bus)=1;  % setting all zero index buses to type 1
for gg=1:Data.Model.Parameter.G       % finding generator busses to set them as type 2;
    if Data.Model.Bus.Type(find(strcmp(Data.Model.Bus.Name,Data.Model.Gen.Bus(gg))))==0
        temp(find(strcmp(Data.Model.Bus.Name,Data.Model.Gen.Bus(gg))))=2;
    end
end
for vv=1:Data.Model.Parameter.V       % finding SVC busses to set them as type 2;
    if Data.Model.Bus.Type(find(strcmp(Data.Model.Bus.Name,Data.Model.SVC.Bus(vv))))==0
        temp(find(strcmp(Data.Model.Bus.Name,Data.Model.SVC.Bus(vv))))=2;
    end
end

mpc.bus = [ bus_seq	temp    Pd	Qd	Gs	Bs	area	Vm	Va	baseKV	zone	Vmax	Vmin];
clearvars -except Data mpc
%% generator data
%	bus	Pg	Qg	Qmax	Qmin	Vg	mBase	status	Pmax	Pmin	Pc1	Pc2	Qc1min	Qc1max	Qc2min	Qc2max	ramp_agc	ramp_10	ramp_30	ramp_q	apf
bus_loc=zeros(sum(Data.Model.Gen.N_units),1);
Pg=zeros(sum(Data.Model.Gen.N_units),1);
Qg=zeros(sum(Data.Model.Gen.N_units),1);
Vg=ones(sum(Data.Model.Gen.N_units),1);
mBase=Data.Model.Parameter.Base_power*ones(sum(Data.Model.Gen.N_units),1);
Status=zeros(sum(Data.Model.Gen.N_units),1);
Pmax=zeros(sum(Data.Model.Gen.N_units),1);
Pmin=zeros(sum(Data.Model.Gen.N_units),1);
Qmax=zeros(sum(Data.Model.Gen.N_units),1);
Qmin=zeros(sum(Data.Model.Gen.N_units),1);
st=1;
for gg=1:length(Data.Model.Gen.N_units)
    ed=st+Data.Model.Gen.N_units(gg)-1;
    bus_loc(st:ed)=find(strcmp(Data.Model.Bus.Name,Data.Model.Gen.Bus(gg)));
    Pmax(st:ed)=Data.Model.Gen.Max_Real_Power(gg);
    Pmin(st:ed)=Data.Model.Gen.Min_Real_Power(gg);
    Qmax(st:ed)=Data.Model.Gen.Max_Reactive_Power(gg);
    Qmin(st:ed)=Data.Model.Gen.Min_Reactive_Power(gg);
    st=ed+1;    
end


mpc.gen = [ bus_loc	Pg	Qg	Qmax	Qmin	Vg	mBase	Status	Pmax	Pmin];
clearvars -except Data mpc
% SVC data
bus_loc=zeros(Data.Model.Parameter.V,1);
Pg=zeros(Data.Model.Parameter.V,1);
Qg=zeros(Data.Model.Parameter.V,1);
Qmax=Data.Model.SVC.Max_Reactive_Power;
Qmin=Data.Model.SVC.Min_Reactive_Power;
Vg=ones(Data.Model.Parameter.V,1);
mBase=Data.Model.Parameter.Base_power*ones(Data.Model.Parameter.V,1);
Status=ones(Data.Model.Parameter.V,1);
Pmax=Data.Model.SVC.Max_Real_Power;
Pmin=Data.Model.SVC.Min_Real_Power;
temp=[];
for vv=1:Data.Model.Parameter.V      % finding SVC to set them theri buses as type 2;
    bus_loc(vv)=find(strcmp(Data.Model.Bus.Name,Data.Model.SVC.Bus(vv)));
    temp=[temp;find(strcmp(Data.Model.Bus.Name,Data.Model.SVC.Bus(vv)))];
end
    
svc=[ bus_loc	Pg	Qg	Qmax	Qmin	Vg	mBase	Status	Pmax	Pmin];
mpc.gen=[mpc.gen;svc];
clearvars -except Data mpc

%% branch data
%	fbus	tbus	r	x	b	rateA	rateB	rateC	ratio	angle	status	angmin	angmax
fbus=zeros(Data.Model.Parameter.L,1);
tbus=zeros(Data.Model.Parameter.L,1);
for ll=1:Data.Model.Parameter.L
    fbus(ll)= find(strcmp(Data.Model.Bus.Name,Data.Model.Line.End_1_Bus(ll)));
    tbus(ll)= find(strcmp(Data.Model.Bus.Name,Data.Model.Line.End_2_Bus(ll)));
end
rateB=zeros(Data.Model.Parameter.L,1);
rateC=zeros(Data.Model.Parameter.L,1);
ratio=zeros(Data.Model.Parameter.L,1);
angle=zeros(Data.Model.Parameter.L,1);
status=ones(Data.Model.Parameter.L,1);
mpc.branch = [ fbus	tbus	Data.Model.Line.r	Data.Model.Line.x	Data.Model.Line.b	Data.Model.Line.Capacity	rateB	rateC	ratio	angle	status	-Data.Model.Line.Max_Angle	Data.Model.Line.Max_Angle ];
clearvars -except Data mpc
% %%-----  OPF Data  -----%%
%% generator cost data
%	1	startup	shutdown	n	x1	y1	...	xn	yn
%	2	startup	shutdown	n	c(n-1)	...	c0
% model st sd n_cost c1 c0
model = 2*ones(sum(Data.Model.Gen.N_units),1);
C_st=zeros(sum(Data.Model.Gen.N_units),1);
C_sd=zeros(sum(Data.Model.Gen.N_units),1);
c1=zeros(sum(Data.Model.Gen.N_units),1);
c0=zeros(sum(Data.Model.Gen.N_units),1);
n_cost = 2*ones(sum(Data.Model.Gen.N_units),1);
st=1;
for gg=1:length(Data.Model.Gen.N_units)
    ed=st+Data.Model.Gen.N_units(gg)-1;
    c1(st:ed)=Data.Model.Gen.Cost_Variable(gg);
    c0(st:ed)=Data.Model.Gen.Cost_Fix(gg);
    st=ed+1;    
end
mpc.gencost = [ model C_st C_sd n_cost c1 c0];
clearvars -except Data mpc
%% svc cost
model = 2*ones(Data.Model.Parameter.V,1);
n_cost= 2*ones(Data.Model.Parameter.V,1);
C_st=Data.Model.SVC.Cost_Start_Up;
C_sd=Data.Model.SVC.Cost_Shut_Down;
c1=Data.Model.SVC.Cost_Variable;
c0=Data.Model.SVC.Cost_Fix;
svc_C=[model C_st C_sd n_cost c1 c0];
mpc.gencost=[mpc.gencost;svc_C];


