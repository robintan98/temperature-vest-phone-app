//----------------------Arduino code-------------------------

//Temp Sensor
//UPLOAD TO PORT 2!!!!

int message = 0;     //  This will hold one byte of the serial message
int tempPin = A2;   
int tempData = 0;          
int redLEDPin = 11; //  What pin is the red LED connected to
int redLED = 0;     //  The value/brightness of the LED, can be 0-255


void setup() {
  Serial.begin(9600);  //set serial to 9600 baud rate
  pinMode(tempPin, INPUT);
}

void loop(){
    //Serial.println(tempPin);
    //tempData = analogRead(tempPin);
    //Serial.println(tempData);
    //delay(100);

tempData = analogRead(tempPin);  
  float voltage = tempData * 5.0;
  voltage /= 1024.0; 
  float temperatureC = (voltage - 0.5) * 100 ;
  float temperatureF = temperatureC*9/5 + 32 ;
  Serial.println(temperatureF);
  delay(100);
  


    
    //if (Serial.available() > 0) { //  Check if there is a new message
      //redLED = Serial.read();    //  Put the serial input into the message

   //if (message == 'R'){  //  If a capitol R is received...
     //redLED = 255;       //  Set redLED to 255 (on)
     //Serial.println('lit');
   //}
   //if (message == 'r'){  //  If a lowercase r is received...
     //redLED = 0;         //  Set redLED to 0 (off)
     //Serial.println('not lit');
   //}

   //analogWrite(redLEDPin, redLED);  //  Write an analog value between 0-255
   //delay(10000);

  
 //analogWrite(redLEDPin, redLED);  //  Write an analog value between 0-255
}

//----------------------------end Arduino code--------------------------------
