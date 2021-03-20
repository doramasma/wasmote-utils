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
  USB.print("| red blink period=number times=number       blinks red led x times for x period   |\n");
  
  USB.print("| green on                                   Activate green led                    |\n");
  USB.print("| green off                                  Deactive green led                    |\n");
  USB.print("| green blink period=number times=number     blinks red led x times for x period   |\n");
  USB.print(" -----------------------------------------------------------------------------------\n");
  
}

void setup() {
  
  USB.ON();
  USB.println();
  print_Help();
  
}

void loop() {
  
  static size_t maxLenght = 20;
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


    if ( !strcmp(pch, "help")) print_Help();

    break;
  }

}
