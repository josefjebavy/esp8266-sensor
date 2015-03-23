-- sleep must working!



-- key for thingspeak.com
APIKEY="KEY"


function getTemp()
PIN = 4 --  data pin, GPIO2
dht22 = require("dht22")
dht22.read(PIN)
t = dht22.getTemperature()
h = dht22.getHumidity()

if h == nil then
  print("Error reading from DHT22")
else
  -- temperature in degrees Celsius  and Farenheit
  -- floating point and integer version:
  --print("Temperature: "..((t-(t % 10)) / 10).."."..(t % 10).." deg C")
  -- only integer version:
  --print("Temperature: "..(9 * t / 50 + 32).."."..(9 * t / 5 % 10).." deg F")
  -- only float point version:
  --print("Temperature: "..(9 * t / 50 + 32).." deg F")
  
  -- humidity
  -- floating point and integer version
  --print("Humidity: "..((h - (h % 10)) / 10).."."..(h % 10).."%")

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


getTemp()
-- conection to thingspeak.com

--print("APIKEY"..APIKEY.." Temperature: "..Temperature.." deg C Humidity: "..Humidity.." %")
print("Sending data to thingspeak.com")
conn=net.createConnection(net.TCP, 0) 
conn:on("receive", function(conn, payload) print(payload) end)
-- api.thingspeak.com 184.106.153.149
conn:connect(80,'184.106.153.149') 
conn:send("GET /update?key="..APIKEY.."&field2="..Temperature.."&field3="..Humidity.." HTTP/1.1\r\n") 
conn:send("Host: api.thingspeak.com\r\n") 
conn:send("Accept: */*\r\n") 
conn:send("User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Linux)\r\n")
conn:send("\r\n")
--sended=false
conn:on("sent",function(conn)
                      print("Closing connection")
                      conn:close()

                  end)
conn:on("disconnection", function(conn)
                      print("Got disconnection...")
                          print("sended now go sleep")
                    gpio.write(pin,gpio.LOW)   
                    wifi.sta.disconnect()
                    node.dsleep(10*60*1000000,1)
                      end)
       




end


----- MAIN ----

sendData()

-----                      
 












