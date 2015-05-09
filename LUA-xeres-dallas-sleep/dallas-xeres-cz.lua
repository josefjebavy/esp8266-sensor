-- esp8266 wifi module with dallas temperature sensor
-- data sentd to xeres.cz
-- author: Josef Jebavý, xeres.cz
-- sleep must working!



APIKEY="KEYXXX"


pin = 6
ow.setup(pin)

counter=0
lasttemp=-999

function bxor(a,b)
   local r = 0
   for i = 0, 31 do
      if ( a % 2 + b % 2 == 1 ) then
         r = r + 2^i
      end
      a = a / 2
      b = b / 2
   end
   return r
end

--- Get temperature from DS18B20 
function getTemp()
      addr = ow.reset_search(pin)
      repeat
        tmr.wdclr()
      
      if (addr ~= nil) then
        crc = ow.crc8(string.sub(addr,1,7))
        if (crc == addr:byte(8)) then
          if ((addr:byte(1) == 0x10) or (addr:byte(1) == 0x28)) then
                ow.reset(pin)
                ow.select(pin, addr)
                ow.write(pin, 0x44, 1)
                tmr.delay(1000000)
                present = ow.reset(pin)
                ow.select(pin, addr)
                ow.write(pin,0xBE, 1)
                data = nil
                data = string.char(ow.read(pin))
                for i = 1, 8 do
                  data = data .. string.char(ow.read(pin))
                end
                crc = ow.crc8(string.sub(data,1,8))
                if (crc == data:byte(9)) then
                   t = (data:byte(1) + data:byte(2) * 256)
         if (t > 32768) then
                    t = (bxor(t, 0xffff)) + 1
                    t = (-1) * t
                   end
         t = t * 625
                   lasttemp = t
         print("Last temp: " .. lasttemp)
                end                   
                tmr.wdclr()
          end
        end
      end
      addr = ow.search(pin)
      until(addr == nil)
end


function sendData()
 -- blink led
pinLED  = 7
gpio.mode(pinLED ,gpio.OUTPUT)
gpio.write(pinLED ,gpio.HIGH)


IDZARIZANI=23
HOST='wireless.xeres.cz'
--HOST='wireless.localhost'
IP='192.168.100.250'
--IP='192.168.100.107'
getTemp()

t1 = lasttemp / 10000
t2 = (lasttemp >= 0 and lasttemp % 10000) or (10000 - lasttemp % 10000)
print("Temp:"..t1.."C" )
--print("Temp:"..string.format("%04d", t2).." C")
-- conection to thingspeak.com
Temperature=t1

-- conection to xeres.cz

--print("APIKEY"..APIKEY.." Temperature: "..Temperature.." deg C Humidity: "..Humidity.." %")
print("Sending data to "..IP)
conn=net.createConnection(net.TCP, 0) 
conn:on("receive", function(conn, payload) print(payload) end)

conn:connect(80,IP) 
--http://wireless.localhost/insert.php?zarizeni=1&stav=0&teplota=10&baterie=0&key=KEY262262

conn:send("GET /insert.php?key="..APIKEY.."&zarizeni="..IDZARIZANI.."&stav=0&baterie="..batterie.."&teplota1="..Temperature.." HTTP/1.1\r\n") 

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
                    gpio.write(pinLED ,gpio.LOW)   
                    wifi.sta.disconnect()
                    node.dsleep(15*60*1000000,1)
                    --node.dsleep(1000000,0)
                      end)
       




end


----- MAIN ----

sendData()

-----                      
 












