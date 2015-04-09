-- sleep must working!



-- key for thingspeak.com
APIKEY="KEY262262"


function getTemp()
PIN = 4 --  data pin, GPIO2
dht22 = require("dht22")
dht22.read(PIN)
t = dht22.getTemperature()
h = dht22.getHumidity()

if h == nil then
  print("Error reading from DHT22")
else


Temperature=(t/ 10)

Humidity=(h/10)




  print("Temperature: "..Temperature.." deg C")
  print("Humidity: "..Humidity.." %")
end

-- release module
dht22 = nil
package.loaded["dht22"]=nil

end


function sendData()
 -- blink led
pin = 7
gpio.mode(pin,gpio.OUTPUT)
gpio.write(pin,gpio.HIGH)


IDZARIZANI=21
HOST='wireless.xeres.cz'
--HOST='wireless.localhost'
IP='192.168.100.250'
--IP='192.168.100.107'
getTemp()
-- conection to xeres.cz

--print("APIKEY"..APIKEY.." Temperature: "..Temperature.." deg C Humidity: "..Humidity.." %")
print("Sending data to "..IP)
conn=net.createConnection(net.TCP, 0) 
conn:on("receive", function(conn, payload) print(payload) end)

conn:connect(80,IP) 
--http://wireless.localhost/insert.php?zarizeni=1&stav=0&teplota=10&baterie=0&key=KEY262262

conn:send("GET /insert.php?key="..APIKEY.."&zarizeni="..IDZARIZANI.."&stav=0&baterie=2&teplota1="..Temperature.."&teplota2="..Humidity.." HTTP/1.1\r\n") 

conn:send("Host:"..HOST.."\r\n") 
conn:send("Accept: */*\r\n") 
conn:send("User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Linux)\r\n")
conn:send("\r\n")



conn:on("sent",function(conn)
                      print("Closing connection")
                      conn:close()

                  end)
conn:on("disconnection", function(conn)
                      print("Got disconnection...")
                          print("sended now go sleep")
                    gpio.write(pin,gpio.LOW)   
                    wifi.sta.disconnect()
                    node.dsleep(15*60*1000000,1)
                      end)
       




end


----- MAIN ----

sendData()

-----                      
 












