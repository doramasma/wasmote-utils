#define BUFFER_LENGTH 25

#define MAX_MILLIVOLTS 3300
#define MAX_AD_SAMPLE_VALUE 1023

#define AD_PIN ANALOG3
#define AD_PSEUDO_PERIOD 100 // milliseconds

#define AD_SAMPLE_FILE "test.txt"
#define AD_SAMPLE_FILE_HEADER_INFO "# data format:\n# time voltage\n# (msecs) (mvolts)"

unsigned char g_justStarted;
unsigned long g_startingTime;
char g_pStrBuffer[BUFFER_LENGTH];

// Nos apoyaremos en la funcionalidad de lectura para tomar las muestras
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
  // initialize global variables
  g_startingTime=millis();
  g_justStarted=1;
  
  // initialize USB module
  USB.ON();
  
  // switch on 5V sensor output  
  PWR.setSensorPower(SENS_5V,SENS_ON);
  
  // initialize SD
  SD.ON();

  if(!SD.isSD())
  {
    USB.println(F("[ERROR] SD is not present!"));
  }
}

void loop() {

  if(g_justStarted) { g_justStarted=0; starting(); }
  
  static size_t maxLenght = 40;
  char message[maxLenght];
  char * pch;

  read_USB_command(message,maxLenght);

  // convertimos el mensaje input a lowercase
  strlwr(message);
  pch = strtok (message," ");

  while (pch != NULL) {
    if ( !strcmp(pch, "scan")) {
      pch = strtok (NULL, " ,.-");
      int period = atoi(pch);
      for(int i = 1; i <= period; i++) {
        unsigned long sampleTime, sample, milliVolts;  
        takeADSample(&sampleTime,&sample,&milliVolts,AD_PIN);
        printADSample(sampleTime,sample,milliVolts);
        saveADSample(AD_SAMPLE_FILE,sampleTime,milliVolts);
        delay(AD_PSEUDO_PERIOD);
      }
      USB.println("Scan finished");
    }
    

    if(!strcmp(pch, "exit")) { finishing(); exit(0); }

    break;
    
  }
 
  
}

void starting()
{
  USB.println(F("\n--------- starting recording ---------"));
  USB.println(F("adRead: this program records AD samples"));
  USB.print(F("pseudo sampling period: ")); USB.print(AD_PSEUDO_PERIOD,DEC); USB.println(F(" msecs."));
  USB.print(F("AD pin: ")); USB.println(AD_PIN,DEC);  
  USB.print(F("recording file \"")); USB.print(AD_SAMPLE_FILE); USB.println(F("\""));
  USB.print(F("free memory: ")); USB.print(freeMemory(),DEC); USB.println(F(" bytes"));
  USB.println(F("--------- starting recording ---------"));
   
  if(SD.isFile(AD_SAMPLE_FILE)) SD.del(AD_SAMPLE_FILE);
  SD.create(AD_SAMPLE_FILE);
  SD.appendln(AD_SAMPLE_FILE,AD_SAMPLE_FILE_HEADER_INFO);
}

void finishing()
{
  USB.println(F("--------- finishing recording --------"));
  USB.println(F("SD contents (SD.ls()):"));
  SD.ls(LS_R);
  USB.println(F("--------- finishing recording --------"));
}

void takeADSample(
  unsigned long* pSampleTime,
  unsigned long* pSample, 
  unsigned long* pMilliVolts,
  unsigned char adPin
)
{
  *pSampleTime=millis()-g_startingTime;
  *pSample=analogRead(adPin);
  *pMilliVolts=(*pSample)*MAX_MILLIVOLTS/MAX_AD_SAMPLE_VALUE;
}

void printADSample(
  unsigned long sampleTime,
  unsigned long sample, 
  unsigned long milliVolts
)
{
  USB.print(F("AD sample: ")); USB.print(milliVolts,DEC);
  USB.print(F(" mV (")); USB.print(sample,DEC); 
  USB.print(F(") t=")); USB.print(sampleTime,DEC); USB.println(F(" ms."));
}

void saveADSample(
  const char* pFile,
  unsigned long sampleTime,
  unsigned long milliVolts
)
{
  snprintf(g_pStrBuffer,BUFFER_LENGTH-1,"%lu %lu",sampleTime,milliVolts);
  SD.appendln(pFile,g_pStrBuffer);
}
