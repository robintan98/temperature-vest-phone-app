//----------------------Arduino code-------------------------

//UPLOAD TO PORT 3!!

int message = 0;     //  This will hold one byte of the serial message
int PeltierPin = 11; //  What pin is the Peltier connected to
String preSerialRead;
String serialRead;
String text;
int PhoneControl = 0;     //  The value/power of vest, can be 0-255
String temporary;
int LEDPin = 13;
int phoneMode = 0;//0 is manual, //1 is automatic
float optimalTemp = 0.00;
float currentTemp = 0.00;
String readString;



void setup() {
  Serial.begin(9600);  //set serial to 9600 baud rate
  pinMode(PeltierPin, OUTPUT);
  pinMode(LEDPin, OUTPUT);
  
}

void loop(){

    if (Serial.available() > 0) { //  Check if there is a new message
      while (Serial.available()) {
         delay(10); //Delay to read;
         char c = Serial.read();  //gets one byte from serial buffer
         readString += c;
       } //makes the string readString

     if (readString.length() >0) {
     
      Serial.println("Read String: " + readString);
      serialRead = readString;
      int n;
      char carray[6]; //Why 6? I don't even know
      readString.toCharArray(carray, sizeof(carray));
      n = atoi(carray);
      readString = "";
     
     }
      
      Serial.println("Actual Serial Read: " + serialRead);

      ////This is processing the string serialRead from Processing //NO TOUCHY

      if(serialRead.indexOf('A') >= 0){ //Automatic
        Serial.println("A is working");
        phoneMode = 1;
      }
      if (serialRead.indexOf('M') >= 0){ //Manual
        Serial.println("M is working");
        phoneMode = 0;
      }
      if (serialRead.indexOf('O') >= 0){ //optimalTemp
        Serial.println("O is working");
        temporary = serialRead;
        temporary.remove(0,1);
        optimalTemp = temporary.toFloat();
      }
      if (serialRead.indexOf('T') >= 0){ //currentTemp
        Serial.println("T is working");
        temporary = serialRead;
        temporary.remove(0,1);
        currentTemp = temporary.toFloat();
      }
      if (serialRead.indexOf('P') >= 0){ //PowerMessage
        Serial.println("P is working");
        temporary = serialRead;
        temporary.remove(0,1);
        PhoneControl = temporary.toInt();
      }


   if (phoneMode == 1){ //If Automatic
    
    if ((currentTemp > 1.05*optimalTemp) && (optimalTemp != 0.00)){
      //If needs to be cooled
      digitalWrite(PeltierPin, HIGH);
    }
    if ((currentTemp < 0.95*optimalTemp) && (optimalTemp != 0.00)){
      //If needs to be Warmed
      digitalWrite(PeltierPin, LOW);
    }
   }
   if (phoneMode == 0){ //If Manual
    digitalWrite(LEDPin, LOW);
    if (PhoneControl > 127){
      digitalWrite(LEDPin, HIGH);
      //If needs to be cooled
      Serial.println ("SHOULD BE ON");
      digitalWrite(PeltierPin, HIGH);
    }
    if (PhoneControl <= 127){
      //If needs to be Warmed
     Serial.println ("SHOULD BE OFF");
     digitalWrite(PeltierPin, LOW);
    }
   }
}

//You have to SET TO AUTO then SET OPTIMAL for auto to work
  delay(100);
  serialRead = "";
}

//----------------------------end Arduino code--------------------------------
