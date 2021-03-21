/*
    ------ Toogle board's leds from keyboard --------
    @author: Doramas Baez Bernal

*/

enum digitalPins{
  Dig1 = DIGITAL1,
  Dig2 = DIGITAL2,
  Dig3 = DIGITAL3,
  Dig4 = DIGITAL4,
  Dig5 = DIGITAL5,
  Dig6 = DIGITAL6,
  Dig7 = DIGITAL7,
  Dig8 = DIGITAL8
} digitalPinsArray[] = {Dig1, Dig2, Dig3, Dig4, Dig5, Dig6, Dig7, Dig8};

int8_t read_USB_command(char * term, size_t msz) {
  
  int8_t sz = 0;
  unsigned long init = millis();
  
  while(sz < msz){
    while ((USB.available() > 0) && (sz < msz)) {
      term[sz++] = USB.read();
      init = millis();
    }
    if (sz && ((millis() - init) > 50UL)) break;
  }
  term[sz] = 0;
  return sz;
  
}

void print_Help() {
  
  USB.print(" -----------------------------------------------------------------------------------\n");
  USB.print("| Options:                                                                         |\n");
  USB.print("| help                                       Print this help                       |\n");
  USB.print("| red on                                     Activate red led                      |\n");
  USB.print("| red off                                    Deactive red led                      |\n");
  USB.print("| red blink period=number times=number       Blinks red led x times for x period   |\n");
  
  USB.print("| green on                                   Activate green led                    |\n");
  USB.print("| green off                                  Deactive green led                    |\n");
  USB.print("| green blink period=number times=number     Blinks red led x times for x period   |\n");

  USB.print("| set digital port=[1-8]                     Set digital pin, pin to high          |\n");
  USB.print("| unset digital port=[1-8]                   Unset digital pin, pin to low         |\n");

  USB.print("| get memory                                 Shows the memory available            |\n");
  USB.print("| set time date=[yy:mm:dd:dow:hh:mm:ss]      Set the time to input date            |\n");
  USB.print("| get time                                   Gets time and date                    |\n");

  USB.print("| set eeprom address=[1024-4096] val=number  Save the value in the given address   |\n");
  USB.print("| get eeprom address=[1024-4096]             Gets the value in the given address   |\n");
  USB.print(" -----------------------------------------------------------------------------------\n");
  
}

void setup() {
  
  USB.ON();
  RTC.ON();
  USB.println();
  print_Help();
  
}

void loop() {
  
  static size_t maxLenght = 40;
  int8_t messageLength;
  int number = 0;
  char message[maxLenght];
  char * pch;

  messageLength = read_USB_command(message,maxLenght);

  // convertimos el mensaje input a lowercase
  strlwr(message);
  pch = strtok (message," ");

  
  while (pch != NULL) {
  
    if ( !strcmp(pch, "red")) {
      pch = strtok (NULL, " ,.-");
      if ( !strcmp(pch, "on"))  Utils.setLED( LED0, LED_ON);
      if ( !strcmp(pch, "off")) Utils.setLED( LED0, LED_OFF);
      if ( !strcmp(pch, "blink")) {
        pch = strtok (NULL, " ,.-");
        int period = atoi(pch);
        pch = strtok (NULL, " ,.-");
        int times = atoi(pch);
        Utils.blinkRedLED(period, times);    
      }
    }
    if ( !strcmp(pch, "green")) {
      pch = strtok (NULL, " ,.-");
      if ( !strcmp(pch, "on"))  Utils.setLED( LED1, LED_ON);
      if ( !strcmp(pch, "off")) Utils.setLED( LED1, LED_OFF);
      if ( !strcmp(pch, "blink")) {
        pch = strtok (NULL, " ,.-");
        int period = atoi(pch);
        pch = strtok (NULL, " ,.-");
        int times = atoi(pch);
        Utils.blinkGreenLED(period, times);    
      }
    }


    if ( !strcmp(pch, "set")) {
      pch = strtok (NULL, " ,.-");
      if ( !strcmp(pch, "digital")) {
        pch = strtok (NULL, " ,.-");
        int portNumber = atoi(pch);
        if (portNumber < 1 || portNumber > 8) { 
          USB.print("\nUndefined port: use a port between 1-8"); 
        } else {
          pinMode(digitalPinsArray[portNumber - 1], OUTPUT);
          digitalWrite(digitalPinsArray[portNumber - 1], HIGH);
        }
      }
      if ( !strcmp(pch, "time")) {
        pch = strtok (NULL, " ,.-");
        USB.print(F("Setting time: "));
        USB.print(pch);
        USB.print("\n");
        RTC.setTime(pch); 
      }
      if ( !strcmp(pch, "eeprom")) {
        pch = strtok (NULL, " ,.-");
        int address = atoi(pch);
        if (address < 1024 || address > 4096) {
          USB.println("Address direction must be between 1024-4096");
        } else {
          pch = strtok (NULL, " ,.-");
          int value = atoi(pch);
          Utils.writeEEPROM(address,value);
        }
      }
    }
    if ( !strcmp(pch, "unset")) {
      pch = strtok (NULL, " ,.-");
      if ( !strcmp(pch, "digital")) {
        pch = strtok (NULL, " ,.-");
        int portNumber = atoi(pch);
        if (portNumber < 1 || portNumber > 8) { 
          USB.print("\nUndefined port: use a port between 1-8");
        } else {
          pinMode(digitalPinsArray[portNumber - 1], INPUT);
          digitalWrite(digitalPinsArray[portNumber - 1], LOW);
        }
      }
    }

    if ( !strcmp(pch, "get")) { 
      pch = strtok (NULL, " ,.-");
      if ( !strcmp(pch, "time")) {
        USB.print(F("Time [Day of week, YY/MM/DD, hh:mm:ss]: ")); 
        USB.println(RTC.getTime());
      }
      if ( !strcmp(pch, "memory")) { 
        USB.print("free Memory (Bytes):");
        USB.println(freeMemory()); 
      }
      if ( !strcmp(pch, "eeprom")) { 
        pch = strtok (NULL, " ,.-");
        int address = atoi(pch);
        if (address < 1024 || address > 4096) {
          USB.println("Address direction must be between 1024-4096");
        } else {
          uint8_t value=Utils.readEEPROM(address);
          USB.println(value, DEC);
        }
      }
    }
    
    
    if ( !strcmp(pch, "help")) print_Help();

    break;
  }

}
