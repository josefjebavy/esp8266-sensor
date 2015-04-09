/*
 *  This sketch sends data via HTTP GET requests to webserver xeres.cz
 *  usinf DHT22  temperature and humidity senzor
 *  author: Josef Jebavý, xeres.cz
 *
 *
 */

#include <ESP8266WiFi.h>



//for C function
extern "C" {
#include "user_interface.h"
}

#define LEDPIN 13 //PIN of LED GPIO13
#include "DHT.h"

#define DHTPIN 2 //  PIN of DHT22 GPIO2
#define DHTTYPE DHT22 // DHT 22 (AM2302)
//#define DHTTYPE DHT21 // DHT 21 (AM2301)
DHT dht(DHTPIN, DHTTYPE, 15);



const char* ssid     = "ssid";
const char* password = "password";

const char* host = "wireless.xeres.cz";
const char* APIKEY = "";
const char* IDZARIZANI = "23";
//const char* Temperature = "25";
//const char* Humidity = "35";
void setup() {

  Serial.begin(115200);
  delay(10);

  pinMode(LEDPIN, OUTPUT);

  dht.begin();
  // We start by connecting to a WiFi network
  WiFi.mode(WIFI_STA);//: set mode to WIFI_AP, WIFI_STA
  //WiFi.begin(ssid, password);

  Serial.println();
  Serial.println();
  Serial.print("Connecting to ");
  Serial.println(ssid);
  WiFi.begin(ssid, password);
  int i = 0;
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
    i++;

    //10x try dhen sleep
    if (i > 10) {
      Serial.println("try connect to WiFi, then sleep");
      //system_deep_sleep_set_option(0);
      system_deep_sleep(1000000);
      //system_deep_sleep(60 * 1000000);
    }
  }

  Serial.println("");
  Serial.println("WiFi connected");
  Serial.println("IP address: ");
  Serial.println(WiFi.localIP());
}



void loop() {


  digitalWrite(LEDPIN, HIGH);   // turn the LED on (HIGH is the voltage level)
  //je potreba pockat cidlo je pomale
  delay(1500);
  float h = dht.readHumidity();
  float t = dht.readTemperature();
  digitalWrite(LEDPIN, LOW);   // turn the LED on (HIGH is the voltage level)

  if (isnan(h) || isnan(t) ) {
    Serial.println("Chyba čtení z DHT sensoru");
    //return;
    //break;
  } else {
    //delay(5000);
    // ++value;

    Serial.print("connecting to ");
    Serial.println(host);

    // Use WiFiClient class to create TCP connections
    WiFiClient client;
    const int httpPort = 80;
    if (!client.connect(host, httpPort)) {
      Serial.println("connection failed");
      // return;
    } else {

      // We now create a URI for the request
      String url = "/insert.php";
      url += "?key=" ;
      url +=  APIKEY ;
      url +=  "&zarizeni=" ;
      url +=  IDZARIZANI ;
      url += "&stav=0&baterie=2&teplota1=" ;
      url +=  t ;
      url +=  "&teplota2=" ;
      url +=  h;

      Serial.print("Requesting URL: ");
      Serial.println(url);

      // This will send the request to the server
      client.print(String("GET ") + url + " HTTP/1.1\r\n" +
                   "Host: " + host + "\r\n" +
                   "Connection: close\r\n\r\n");
      delay(10);

      // Read all the lines of the reply from server and print them to Serial
      while (client.available()) {
        String line = client.readStringUntil('\r');
        Serial.print(line);
      }

      Serial.println();
      Serial.println("closing connection");
      //wait for HTTP response
      //delay(1000);
    }
  }
  Serial.println("sleep");

  //C sleep function
  //system_deep_sleep_set_option(0);
  system_deep_sleep(1000000);
  //system_deep_sleep(15 * 60 * 1000000);
  // wait because module  still wotking
  delay(100);
}


