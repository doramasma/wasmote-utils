/*
    ------ Toogle board's leds from keyboard --------
    @author: Doramas Baez Bernal

*/

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


void setup() {
  
  USB.ON();
  USB.println();
  
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
    }

    if ( !strcmp(pch, "green")) {
      pch = strtok (NULL, " ,.-");
      if ( !strcmp(pch, "on"))  Utils.setLED( LED1, LED_ON);
      if ( !strcmp(pch, "off")) Utils.setLED( LED1, LED_OFF);
    }

    break;
  }

}
