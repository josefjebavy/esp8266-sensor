--init.lua


-- ADC> batere measurement must be before set wifi

pinLED = 7
-- power LED battery will bw under load -> realistic measurement
gpio.mode(pinLED,gpio.OUTPUT)
gpio.write(pinLED,gpio.HIGH)

v = node.readvdd33()
--print ("node.readvdd33()")
print('batery voltage:'..v/ 1000)
batterie=2
if (v>3400) then
 batterie=1
 else
 batterie=0
end
batterie=v
v=nil

gpio.write(pinLED,gpio.LOW)

------
print("Setting up WIFI...")
wifi.setmode(wifi.STATION)
--modify according your wireless router settings
wifi.sta.config("ESSID","PASS")
wifi.sta.connect()
i=0
tmr.alarm(1, 1000, 1, function() 
 if wifi.sta.getip()== nil then 
  print("IP unavaiable, Waiting...") 
  i=i+1
  if i>10 then 
     print("10 pokusu - sleep") 
     node.dsleep(10*1000000,1)
     wifi.sta.disconnect()
  end   
 else 
  tmr.stop(1)
  print("Config done, IP is "..wifi.sta.getip())

--dofile("dht22-thingspeak.lua")

  --dofile("dht22-thingspeak+sleep.lua")
  dofile("dallas-xeres-cz.lua")
   --tmr.delay(100000)
  --wifi.sta.disconnect()
  --print("deep sleep") 
--sleep first param: 1 000 000  =1 sekundu, second parametr: 1 work best
--node.dsleep(5*1000000,1)

--0, RF_CAL or not after deep-sleep wake up, depends on init data byte 108.
--1, RF_CAL after deep-sleep wake up, there will belarge current.
--2, no RF_CAL after deep-sleep wake up, there will only be small current.
--4, disable RF after deep-sleep wake up, just like modem sleep, there will be the smallest current.
         

 end 
end)



