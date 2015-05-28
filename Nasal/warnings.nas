## Learjet 35-A, stall and overspeed warning
## PH-JBO 20120130p

## set limits and statics
var aoaf0 = 9.64;

var aoaf8 = 9.02;
var valf8 = 0.15;

var aoaf20 = 8.12;
var valf20 = 0.40;

var aoaf40 = 6.23;
var valf40 = 0.80;

var aoas = 9.52;
var vals = 0.50;

var machmax = 0.81;
var kiaslowmax = 300;
var kiashimax = 350;
var altlayer = 8000;

var machnoap= 0.74;
var kiaspull = 354;
var machpull = 0.82;
var pull=0;

var warning = func {
  if (getprop("/sim/freeze/replay-state"))
    return;

## stallwarning loop

  ## get variables
  var avionics = getprop("controls/electric/avionics-switch");
  var aoa = getprop("orientation/alpha-deg");
  var spoilerons = getprop("controls/flight/speedbrake");
  var flaps = getprop("controls/flight/flaps");
  var stalling = "false";
  var gearalt = getprop("position/gear-agl-ft");
  var radh = getprop("instrumentation/primus1000/control/decision-height");
  
## compare and set warning
  if ((avionics!=nil) and (aoa!=nil) and (spoilerons !=nil) and (flaps!=nil) and avionics) # and (radh!=nil)
    {
    if ((aoa>aoas) and (spoilerons>vals))
  		{
			var stalling="true";
  		}
		if ((aoa>aoaf0) and (flaps<valf8))
  		{
			var stalling="true";
  		}
  	if ((aoa>aoaf8) and (flaps>valf8))
  		{
    	var stalling="true";
  		}
  	if ((aoa>aoaf20) and (flaps> valf20))
  		{
  		var stalling="true";
  		}
  	if ((aoa>aoaf40) and (flaps>valf40))
  		{
			var stalling="true";
  		}
		}
	if (gearalt!=nil and gearalt>radh)
	{
	setprop("instrumentation/alerts/stall",stalling);
	}

	var stalling = getprop("instrumentation/alerts/stall");
	if (stalling)
		 {
		 setprop("autopilot/locks/passive-mode","true");
		 setprop("instrumentation/annunciators/master-caution","true");
		 }

## overspeed warning loop
  
  ## get variables
  var mach = getprop("velocities/mach");
  var alt = getprop("instrumentation/altimeter/pressure-alt-ft");
  var speed = getprop("velocities/airspeed-kt");
  var speeding = "false";
	var apoff = getprop("autopilot/locks/passive-mode");
	
#"controls/flight/elevator",-0.4  
  if (pull<-0.4){pull=-0.4;}
	
  if ((mach!=nil) and (alt!=nil) and (speed!=nil) and (apoff!=nil) and avionics)
  	 {
		 if (mach>machnoap and apoff)
		 		{
				speeding = "true";
				}
  	 if (mach>machmax)
  	 		{
  			speeding = "true";
  			}
  	if ((alt<altlayer) and (speed>kiaslowmax))
  		 {
  		 speeding = "true";
  		 }
  	if ((alt>altlayer) and (speed>kiashimax))
  		 {
  		 speeding = "true";
  		 }
		if (speed>kiaspull or mach>machpull)
			 {
			 pull=pull-0.01;
			 setprop("controls/flight/elevator",pull);
			 } 
			 else
			 	 {
				 pull=0;
				 }
  	}
    setprop("instrumentation/alerts/overspeed",speeding);
    var speeding=getprop("instrumentation/alerts/overspeed");
  	if (speeding)
  		{
  		setprop("instrumentation/annunciators/master-caution","true");
  		}
	settimer (warning,0.5);
}

revold0 = 0;
revold1 = 0;
setprop("engines/engine/revup","true");
setprop("engines/engine[1]/revup","true");

var revup = func{
  if (getprop("/sim/freeze/replay-state"))
    return;

  revnow0 = getprop("engines/engine/fan");
  revnow1 = getprop("engines/engine[1]/fan");
  if((revnow0 != nil) and (revnow1 != nil)){
  if ((revold0 < revnow0))
  { setprop("engines/engine/revup","true"); }
  else
  { setprop("engines/engine/revup","false"); }
	
  if ((revold1 < revnow1))
  { setprop("engines/engine[1]/revup","true"); }
  else
  { setprop("engines/engine[1]/revup","false"); }
	}
  revold0=revnow0;
  revold1=revnow1;
	
  settimer(revup,1);
}


warning();
revup();
