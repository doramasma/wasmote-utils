

void checkInterruption() {

  // Nos ayudamos de intFlag para comprobar el origen de la interrupcion
  if (intFlag & ACC_INT) {
    intFlag &= ~(ACC_INT); 
    USB.println("Accelerometer Interrupt received");

  } else if (intFlag & RTC_INT) {
    intFlag &= ~(RTC_INT);
    USB.println("RTC Interrupt received");
    
  }
}


void setup() {

  USB.ON();
  
  USB.println("Init RTC"); 
  RTC.ON(); 
  RTC.setTime("13:02:08:06:18:00:00");
  
  USB.OFF();

  // Se activan las interrupciones del acelerometro
  ACC.ON();
  ACC.setIWU();

  
}

void loop() {

  char timestr[31];
  static uint16_t cycle = 0;
  
  USB.ON(); 
  
  // Print cycle  
  USB.print(F("Cycle: "));
  USB.println(cycle,DEC);
  
  // Get date and time
  // We make a secure copy
  // snprintf(timestr,sizeof(timestr),"%s", RTC.getTime());
  strncpy(timestr,RTC.getTime(),sizeof(timestr));
  USB.print(F("Current time: "));
  USB.println(timestr);
  
  // Show the remaining battery level
  USB.print(F("\tBattery Level: "));
  USB.print(PWR.getBatteryLevel(),DEC);
  USB.println(" %");
  
  // Get temperature 
  USB.print(F("\tTemperature: ")); 
  USB.print(RTC.getTemperature()); 
  USB.println(F(" C\n"));
  
  cycle++;
  
  // Switch all modules off and deep sleep for twenty seconds
  PWR.deepSleep("00:00:00:20", RTC_OFFSET, RTC_ALM1_MODE2, ALL_OFF);
  checkInterruption();
 
}
