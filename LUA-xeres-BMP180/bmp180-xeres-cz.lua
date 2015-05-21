-- esp8266 wifi module with BMP180
-- data sentd to xeres.cz
-- author: Josef Jebavý, xeres.cz
-- sleep must working!



APIKEY="XXX"


function getTemp()
OSS = 1 -- oversampling setting (0-3)
SDA_PIN = 4 -- sda pin, GPIO2
SCL_PIN = 3 -- scl pin, GPIO0

bmp180 = require("bmp180")
bmp180.init(SDA_PIN, SCL_PIN)
bmp180.read(OSS)
temperature = bmp180.getTemperature()/10
pressure = bmp180.getPressure()/100




-- release module
bmp180 = nil
package.loaded["bmp180"]=nil

end


function sendData()
 -- blink led
pin = 7
gpio.mode(pin,gpio.OUTPUT)
gpio.write(pin,gpio.HIGH)


IDZARIZANI=25
HOST='wireless.xeres.cz'
--HOST='wireless.localhost'
IP='192.168.100.250'
--IP='192.168.100.107'
getTemp()

-- temperature in degrees Celsius  and Farenheit
print("Temperature: "..temperature.." deg C")


-- pressure in differents units

print("Pressure: "..pressure.." hPa")


-- conection to xeres.cz

--print("APIKEY"..APIKEY.." Temperature: "..Temperature.." deg C Humidity: "..Humidity.." %")
print("Sending data to "..IP)
conn=net.createConnection(net.TCP, 0) 
conn:on("receive", function(conn, payload) print(payload) end)

conn:connect(80,IP) 
--http://wireless.localhost/insert.php?zarizeni=1&stav=0&teplota=10&baterie=0&key=KEY262262

conn:send("GET /insert.php?key="..APIKEY.."&zarizeni="..IDZARIZANI.."&stav=0&baterie="..batterie.."&teplota1="..temperature.."&teplota2="..pressure.." HTTP/1.1\r\n") 

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
                    --node.dsleep(1000000,0)
                      end)
       




end


----- MAIN ----

sendData()

-----                      
 












