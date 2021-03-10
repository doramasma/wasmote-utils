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


void setup()
{
  USB.ON();
  USB.println();
}

void loop()
{
  // put your main code here, to run repeatedly:
  static size_t maxLenght = 20;
  int8_t messageLength;
  int number = 0;
  char message[maxLenght];

  messageLength = read_USB_command(message,maxLenght);
  
  switch (messageLength) {
    case 6:
      if ( !strcmp(message, "red on")) Utils.setLED( LED0, LED_ON); // Sets the red LED ON
        
      break;
    case 7:
      if ( !strcmp(message, "red off")) Utils.setLED( LED0, LED_OFF); // Sets the red LED ON
      
      break;
    case 8:
      if ( !strcmp(message, "green on")) Utils.setLED( LED1, LED_ON); // Sets the red LED ON
     
      break;
    case 9:
      if ( !strcmp(message, "green off")) Utils.setLED( LED1, LED_OFF); // Sets the red LED ON
      if ( !strcmp(message, "blink red")) {
          USB.print("\n Introduce a specific period: ");
          messageLength = read_USB_command(message,maxLenght);
          int period = atoi(message);
          USB.print(period);
          
          USB.print("\n Introduce blink times: ");
          messageLength = read_USB_command(message,maxLenght);
          int times = atoi(message);
          USB.print(times);
          
          Utils.blinkRedLED(period, times);       // blink once during 500 ms
      }
      
      break;
    case 11:
      if ( !strcmp(message, "blink green")) {
          USB.print("\n Introduce a specific period: ");
          messageLength = read_USB_command(message,maxLenght);
          int period = atoi(message);
          USB.print(period);
          
          USB.print("\n Introduce blink times: ");
          messageLength = read_USB_command(message,maxLenght);
          int times = atoi(message);
          USB.print(times);
          
          Utils.blinkGreenLED(period, times);       // blink once during 500 ms
      }
      break;

    
      
  }
  
  
}
