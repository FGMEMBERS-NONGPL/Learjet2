# Learjet 35-A limits
# PH-JBO 20120130p

var checkFlaps = func(n){
  var flapsetting = n.getValue();
  if (flapsetting == 0)
    return;

  var airspeed = getprop("velocities/airspeed-kt");
  var ltext = "";
  var limits = props.globals.getNode("limits");

  if ((limits != nil) and (limits.getChildren("max-flap-extension-speed") != nil))
  {
    var children = limits.getChildren("max-flap-extension-speed");
    foreach(c; children)
    {
      if ((c.getChild("flaps") != nil) and
          (c.getChild("speed") != nil)     )
      {
        var flaps = c.getChild("flaps").getValue();
        var speed = c.getChild("speed").getValue();

        if ((flaps != nil)        and
            (speed != nil)        and
            (flapsetting > flaps) and
            (airspeed > speed)       )
        {
          ltext = "Flaps extended above maximum flap extension speed!";
        }
      }
    }
    if (ltext != "")
    {
      screen.log.write(ltext);
    }
  }
}

var checkGear = func(n) {
  if (!n.getValue())
    return;

  var airspeed    = getprop("velocities/airspeed-kt");
  var max_gear    = getprop("limits/max-gear-extension-speed");

  if ((max_gear != nil) and (airspeed > max_gear))
  {
    screen.log.write("Gear extended above maximum extension speed!");
  }
}

# Set the listeners
setlistener("controls/flight/flaps", checkFlaps);
setlistener("controls/gear/gear-down", checkGear);

#Get limits
  var max_positive = getprop("limits/max-positive-g");
  var max_negative = getprop("limits/max-negative-g");
  var ceiling      = getprop("limits/ceiling");
  var mtow         = getprop("limits/mtow");
  var mlw          = getprop("limits/mlw");
  var n1           = getprop("limits/n1");
#Set static
  var down         = -1.5;
  var num2         = 0.5;
  var num3         = 0.1;
  var timen1high   = 5;
  var maxn1high    = 104;
  var timen1mid    = 300;
  var maxn1mid     = 101.7;
#Set variable
  var tmr1high     = 0;
  var tmr1mid      = 0;
  var tmr2high     = 0;
  var tmr2mid      = 0;
	

var checkGandVNE = func {
  if (getprop("/sim/freeze/replay-state"))
    return;

  var msg = "";
	
#check for g forces

  var g= getprop ("accelerations/pilot-gdamped");

  if ((max_positive != nil) and (g!=nil))
	{
	if ((g > max_positive) or (g< max_negative))
	  {
	    msg = "Airframe structural g load limit exceeded!";
	    setprop("autopilot/locks/passive-mode","true");
	    setprop("instrumentation/annunciators/master-caution","true");
	  }
	}

  # Now misc checks

  var pressalt    = getprop("instrumentation/altimeter/pressure-alt-ft");

# check weight
  var grossweight = getprop("yasim/gross-weight-lbs");
  var geardown    = getprop("controls/gear/gear-down");
  var gearalt     = getprop("position/gear-agl-ft");
  var updown      = getprop("velocities/vertical-speed-fps");

  if ((grossweight != nil) and (mtow != nil) and (grossweight > mtow))
	{
	msg = "Weight exeeds take-off weight!";
	}
  if ((geardown) and (updown !=nil) and (updown < down ) and (gearalt != nil) and (gearalt <num2) and (mlw !=nil) and (grossweight !=nil) and (grossweight > mlw))
	{
	msg = "Weight exeeds maximum landing weight!";
	}
# check spoilerons
  var flaps = getprop("controls/flight/flaps");
  var spoilerons = getprop ("controls/flight/speedbrake");

  if (( gearalt != nil) and (gearalt > num2) and (flaps > num3) and (spoilerons > num3))
	{
	msg = "Flaps AND spoilerons used in flight!";
  	setprop("instrumentation/annunciators/master-caution","true");
	} 
# check reversers
  var rev0 = getprop("controls/engines/engine[0]/reverser");
  var radh = getprop("instrumentation/primus1000/control/decision-height");

  if (( gearalt !=nil) and (gearalt > radh) and rev0 )
	{
	msg = "Reversers can not be deployed in flight!";
	setprop("controls/engines/engine[0]/reverser","false");
	setprop("controls/engines/engine[1]/reverser","false");
	}

# check ceiling
  if ((ceiling !=nil) and (pressalt!=nil) and (pressalt>ceiling))
	{
	msg = "Altitude is above ceiling!";
	setprop("instrumentation/annunciators/master-caution","true");
	}

#Engines running
  var eng0 = getprop("controls/engines/engine/cutoff");
  var eng1 = getprop("controls/engines/engine[1]/cutoff");
  if((gearalt!=nil) and (gearalt>num2))
	{
	 if ( eng0 and eng1 )
  	{    
	 	setprop("instrumentation/annunciators/master-caution","true");
		msg = "Engines fail!";
		}
	 }

# check n1 max
  var n1one = getprop("engines/engine/n1");
  var n1two = getprop("engines/engine[1]/n1");
  if ((n1 !=nil) and (n1one!=nil) and (n1one>n1))
{
msg = "N1 exeeds limit! Replace engine";
setprop("controls/engines/engine/cutoff","true");
setprop("instrumentation/annunciators/master-caution","true");
}
  if ((n1!=nil) and (n1two!=nil) and (n1two>n1))
	{
 	msg = "N1 exeeds limit! Replace engine";
	setprop("controls/engines/engine[1]/cutoff","true");
	setprop("instrumentation/annunciators/master-caution","true");
	}

#Engine 1 N1 hight
  if ((n1one!=nil) and (n1one>maxn1high))
	{
	tmr1high=tmr1high + 1;
	if (tmr1high>timen1high)
		{
		msg = "N1 exeeds limit! Replace engine";
		setprop("controls/engines/engine/cutoff","true");
		setprop("instrumentation/annunciators/master-caution","true");
		}
	}
  if ((n1one!=nil) and (n1one<maxn1high))
	{
	tmr1high=0;
	}
#Engine 2 N1 high
  if ((n1two!=nil) and (n1two>maxn1high))
	{
	tmr2high=tmr2high + 1;
	if (tmr2high>timen1high)
		{
		msg = "N1 exeeds limit! Replace engine";
		setprop("controls/engines/engine[1]/cutoff","true");
		setprop("instrumentation/annunciators/master-caution","true");
		}
	}
  if ((n1two!=nil) and (n1two<maxn1high))
	{
	tmr2high=0;
	}

#Engine1 N1 med
  if ((n1one!=nil) and (n1one>maxn1mid))
	{
	tmr1mid = tmr1mid + 1;
	if (tmr1mid>timen1mid)
		{
		msg = "N1 exeeds limit! Replace engine";
		setprop("controls/engines/engine/cutoff","true");
		setprop("instrumentation/annunciators/master-caution","true");
		}
	}
  if ((n1one!=nil) and (n1one<maxn1mid))
	{
	tmr1mid = 0;
	}
#Engine2 N1 med
  if ((n1two!=nil) and (n1two>maxn1mid))
	{
	tmr2mid = tmr2mid + 1;
	if (tmr2mid>timen1mid)
		{
		msg = "N1 exeeds limit! Replace engine";
		setprop("controls/engines/engine[1]/cutoff","true");
		setprop("instrumentation/annunciators/master-caution","true");
		}
	}
  if ((n1two!=nil) and (n1two<maxn1mid))
	{
	tmr2mid = 0;
	}

#############
  if (msg != "")
  {
    screen.log.write(msg);
    settimer(checkGandVNE, 10);
  }
  else
  {
    settimer(checkGandVNE, 1);
  }
}

checkGandVNE();
