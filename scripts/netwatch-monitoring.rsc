:local netwatchList {"host1";"host2";"host3";"host4"} 
:local emailSubjectPrefix "[PREFIX]"
:local emailTo "info@example.com"
:local alertThreshold 3

:global netwatchCounters
:if ([:typeof $netwatchCounters] = "nothing") do={
    :set netwatchCounters ({})
}

:local routerName [/system identity get name]
:local currentTime [/system clock get time]
:local currentDate [/system clock get date]

:put "=== Netwatch Monitor Script Started ==="
:put ("Router: " . $routerName)
:put ("Date: " . $currentDate . " Time: " . $currentTime)
:put ("Monitoring " . [:len $netwatchList] . " netwatch entries")

:foreach netwatchName in=$netwatchList do={
    
    :put ("--- Checking: " . $netwatchName . " ---")
    
    :local counterValue ($netwatchCounters->$netwatchName)
    :if ([:typeof $counterValue] = "nothing") do={
        :set ($netwatchCounters->$netwatchName) 0
        :set counterValue 0
        :put ("Initialized counter for " . $netwatchName)
    }
    
    :put ("Current counter value for " . $netwatchName . ": " . $counterValue)
    
    :local netwatchExists false
    :local netwatchStatus "unknown"
    :local netwatchHost ""
    
    :foreach nw in=[/tool netwatch find name=$netwatchName] do={
        :set netwatchExists true
        :set netwatchStatus [/tool netwatch get $nw status]
        :set netwatchHost [/tool netwatch get $nw host]
    }
    
    :put ("Netwatch found: " . $netwatchExists . ", Status: " . $netwatchStatus . ", Host: " . $netwatchHost)
    
    :if ($netwatchExists = false) do={
        :log warning ("Netwatch Monitor: Entry '$netwatchName' not found in netwatch list")
        :put ("ERROR: Netwatch entry not found!")
    } else={
        
        :if ($netwatchStatus = "up") do={
            :put ("Status: UP")
            :if ($counterValue > 0) do={
                :put ("Resetting counter (was " . $counterValue . ")")
                :log info ("Netwatch Monitor: $netwatchName ($netwatchHost) is UP again - resetting counter")
                
                :local emailSubject ("$emailSubjectPrefix $netwatchName is UP again")
                :local emailBody ("Recovery: Netwatch entry is now responding again\r\n\r\n" . \
                                  "Router: $routerName\r\n" . \
                                  "Netwatch Name: $netwatchName\r\n" . \
                                  "Target IP/Host: $netwatchHost\r\n" . \
                                  "Status: UP\r\n" . \
                                  "Date: $currentDate\r\n" . \
                                  "Time: $currentTime\r\n" . \
                                  "Was down for: $counterValue checks\r\n\r\n" . \
                                  "The connection has been restored.")
                
                :put ("!!! RECOVERY - SENDING EMAIL !!!")
                :log warning ("Netwatch Monitor: RECOVERY - $netwatchName ($netwatchHost) is UP again after $counterValue failed checks - Sending email")
                
                /tool e-mail send to=$emailTo subject=$emailSubject body=$emailBody
                
                :set ($netwatchCounters->$netwatchName) 0
            }
        } else={
            :local newCounter $counterValue
            :if ($counterValue < 100) do={
                :set newCounter ($counterValue + 1)
                :set ($netwatchCounters->$netwatchName) $newCounter
            }
            
            :put ("Status: DOWN - Counter: " . $newCounter)
            
            :if ($newCounter = $alertThreshold) do={
                :local emailSubject ("$emailSubjectPrefix $netwatchName is down")
                :local emailBody ("Alert: Netwatch entry has been down for $alertThreshold consecutive checks\r\n\r\n" . \
                                  "Router: $routerName\r\n" . \
                                  "Netwatch Name: $netwatchName\r\n" . \
                                  "Target IP/Host: $netwatchHost\r\n" . \
                                  "Status: $netwatchStatus\r\n" . \
                                  "Date: $currentDate\r\n" . \
                                  "Time: $currentTime\r\n" . \
                                  "Consecutive Down Checks: $newCounter\r\n\r\n" . \
                                  "Please investigate the connection issue.")
                
                :put ("!!! ALERT THRESHOLD REACHED - SENDING EMAIL !!!")
                :log warning ("Netwatch Monitor: ALERT - $netwatchName ($netwatchHost) has been DOWN for $alertThreshold checks - Sending email")
                
                /tool e-mail send to=$emailTo subject=$emailSubject body=$emailBody
            }
            
            :if ($newCounter > $alertThreshold) do={
                :put ("Still down (counter: " . $newCounter . ")")
            }
        }
    }
}

:put "=== Netwatch Monitor Script Completed ==="
