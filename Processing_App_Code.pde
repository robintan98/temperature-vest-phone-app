//-----------------Processing code-----------------


import oscP5.*;        //  Load OSC P5 library
import netP5.*;        //  Load net P5 library
import processing.serial.*;    //  Load serial library

Serial firstArduinoPort;        //  Set firstArduinoPort as serial connection
Serial secondArduinoPort;
OscP5 oscP5;            //  Set oscP5 as OSC connection

String val;
String test = "Robin";
String something;
int firstDecimal;
String preReadTemp;
float actualReadTemp;
int powerToSend;
int actualPowerPercent;
int setDefaultTemp;
int tempToSend;
int isAutomatic = 0;
float sentActualPowerPercent;
boolean startDelay = true;
boolean annotations = true;
int limitTemps = 0;
int limitPowers = 0;
int isCelcius = 0;

NetAddress iPhone;

int redLED = 0;        //  redLED lets us know if the LED is on or off
int [] led = new int [2];    //  Array allows us to add more toggle buttons in TouchOSC
float num = 0;
int dataCount = 3;

void setup() {
  size(100,100);        // Processing screen size
  noStroke();            //  We don’t want an outline or Stroke on our graphics
    oscP5 = new OscP5(this,8000);  // Start oscP5, listening for incoming messages at port 8000
   firstArduinoPort = new Serial(this, Serial.list()[2], 9600);  //Temp    // Set arduino to 9600 baud
   secondArduinoPort = new Serial(this, Serial.list()[3], 9600); //Peltier
   
   iPhone = new NetAddress("158.130.160.63", 9000);
   
   firstArduinoPort.clear();
   secondArduinoPort.clear();
   
}

void oscEvent(OscMessage theOscMessage) {   //  This runs whenever there is a new OSC message

    String addr = theOscMessage.addrPattern();  //  Creates a string out of the OSC message
    
    if(addr.indexOf("/push1") !=-1){   //This button will be used in the future
    setDefaultTemp = int(addr.charAt(17)); //1 in this case
    
    OscMessage optimalTemperatureMessage = new OscMessage("/temperature/label16");
    
    //For OSC Only
    if(isCelcius == 1){
      optimalTemperatureMessage.add(String.format("%.2f", (actualReadTemp-32)*5/9) + "°C");
      oscP5.send(optimalTemperatureMessage, iPhone);
    }
    else{
      optimalTemperatureMessage.add(String.format("%.2f", actualReadTemp) + "°F");
      oscP5.send(optimalTemperatureMessage, iPhone);
    }
    
    println("O" + String.format("%.2f", actualReadTemp));
    secondArduinoPort.write("O" + String.format("%.2f", actualReadTemp));
     
    }
    
    if(addr.indexOf("/push3") !=-1){   //A or M
    setDefaultTemp = int(addr.charAt(17)); //1 in this case
    
    isAutomatic = 1 - isAutomatic;
    
    OscMessage isAutomaticMessage = new OscMessage("/temperature/label20");
    
    if(isAutomatic == 1){
      isAutomaticMessage.add(String.format("A")); //Is Automatic
      oscP5.send(isAutomaticMessage, iPhone);
      println("A");
      secondArduinoPort.write("A");
      
    }
    else{
    isAutomaticMessage.add(String.format("M")); //Is Manual
    oscP5.send(isAutomaticMessage, iPhone);
    println("M");
    secondArduinoPort.write("M");
    }
     
    }
    
    if(addr.indexOf("/push4") != -1){   //A or M
    setDefaultTemp = int(addr.charAt(17)); //1 in this case
    
    isCelcius = 1 - isCelcius;
    
    OscMessage isCelciusMessage = new OscMessage("/temperature/label21");
    
    if(isCelcius == 1){
      isCelciusMessage.add(String.format("°C")); //Is Automatic
      oscP5.send(isCelciusMessage, iPhone);
      println("°C");
      
    }
    else{
    isCelciusMessage.add(String.format("°F")); //Is Manual
    oscP5.send(isCelciusMessage, iPhone);
    println("°F");
    }
     
    }
    
    if(addr.indexOf("/rotary8") !=-1){   // Find rotary8
    
    float prePowerPercent = theOscMessage.get(0).floatValue();
    prePowerPercent = prePowerPercent*200;
    actualPowerPercent = round(prePowerPercent);
    actualPowerPercent = actualPowerPercent - 100;
    
    
    OscMessage powerMessage = new OscMessage("/temperature/label11");
    if (actualPowerPercent > 0){
      if(isAutomatic == 1){
        powerMessage.add("AUTO");
      }
      else{
        powerMessage.add("+" + actualPowerPercent + "%");
      }
    oscP5.send(powerMessage, iPhone);
    }
    else{
      if(isAutomatic == 1){
        powerMessage.add("AUTO");
      }
      else{
        powerMessage.add(actualPowerPercent + "%");
      }
    oscP5.send(powerMessage, iPhone);
    }
    
      sentActualPowerPercent = (actualPowerPercent+100)*255/200;
        println("P" + sentActualPowerPercent);
      
      if ((limitPowers % 6) == 0){
        secondArduinoPort.write("P" + sentActualPowerPercent); //Powerpercent
      }
      limitPowers = limitPowers + 1;
     
    }
    
}

void draw() {
  
  if(startDelay){
  delay(500);
  secondArduinoPort.clear();
  firstArduinoPort.clear();
  startDelay = false;
  }
  
 background(50);        // Sets the background to a dark grey, can be 0-255
 
   if ( firstArduinoPort.available() > 0){
     something = firstArduinoPort.readString();
     something = something.replace('\n', ' ');
     firstDecimal = something.indexOf(".");
     delay(50);
     if (firstDecimal > 1 & something.length() >= 5){
     preReadTemp = something.substring(firstDecimal - 2, firstDecimal + 3);
     actualReadTemp = float(preReadTemp);
     }
     dataCount = dataCount + 6;
   }
   
   OscMessage temperatureMessage = new OscMessage("/temperature/label5");
   
   //For OSC Only
    if(isCelcius == 1){
      temperatureMessage.add(String.format("%.2f", (actualReadTemp-32)*5/9) + "°C");
      oscP5.send(temperatureMessage, iPhone);
    }
    else{
      temperatureMessage.add(String.format("%.2f", actualReadTemp) + "°F");
      oscP5.send(temperatureMessage, iPhone);
    }
    
    if((limitTemps % 10) == 0){
    println("T" + String.format("%.2f", actualReadTemp));
    secondArduinoPort.write("T" + String.format("%.2f", actualReadTemp));
    }
    limitTemps = limitTemps + 1;
    
    powerToSend = round(255 * (actualPowerPercent+100)/2 /100); //Reconfigure to percentage
   
fill(powerToSend,0,0);            // Fill rectangle with redLED amount
   ellipse(50, 50, 50, 50);    // Created an ellipse at 50 pixels from the left...
                // 50 pixels from the top and a width of 50 and height of 50 pixels
   
}

//----------------------------------end processing code------------------------------------