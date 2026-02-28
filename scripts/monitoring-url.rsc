:local urlChecks {
    {"url"="https://example.com"; "expected"="True;"};
}
:local emailSubjectPrefix "[PREFIX]"
:local emailTo "info@example.com"
:local alertThreshold 4

:global urlCounters
:if ([:typeof $urlCounters] = "nothing") do={
    :set urlCounters ({})
}

:local routerName [/system identity get name]
:local currentTime [/system clock get time]
:local currentDate [/system clock get date]

:put "=== URL Monitor Script Started ==="
:put ("Router: " . $routerName)
:put ("Date: " . $currentDate . " Time: " . $currentTime)
:put ("Monitoring " . [:len $urlChecks] . " URLs")

:foreach checkItem in=$urlChecks do={
    
    :local urlToCheck ($checkItem->"url")
    :local expectedResponse ($checkItem->"expected")
    
    :put ("--- Checking: " . $urlToCheck . " ---")
    :put ("Expected response: " . $expectedResponse)
    
    :local counterValue ($urlCounters->$urlToCheck)
    :if ([:typeof $counterValue] = "nothing") do={
        :set ($urlCounters->$urlToCheck) 0
        :set counterValue 0
        :put ("Initialized counter for " . $urlToCheck)
    }
    
    :put ("Current counter value for " . $urlToCheck . ": " . $counterValue)
    
    :local fetchSuccess false
    :local fetchResponse ""
    :local responseOK false
    
    :do {
        :set fetchResponse [/tool fetch url=$urlToCheck as-value output=user]
        :set fetchSuccess true
        :set fetchResponse ($fetchResponse->"data")
        :put ("Fetch successful, response: " . $fetchResponse)
        
        :if ($fetchResponse = $expectedResponse) do={
            :set responseOK true
            :put ("Response matches expected value: " . $expectedResponse)
        } else={
            :put ("Response does NOT match. Expected: '" . $expectedResponse . "' Got: '" . $fetchResponse . "'")
        }
    } on-error={
        :set fetchSuccess false
        :put ("ERROR: Failed to fetch URL")
    }
    
    :if ($fetchSuccess = true && $responseOK = true) do={
        :put ("Status: OK")
        :if ($counterValue > 0) do={
            :put ("Resetting counter (was " . $counterValue . ")")
            :log info ("URL Monitor: $urlToCheck is OK again - resetting counter")
            
            :local emailSubject ("$emailSubjectPrefix URL is OK again")
            :local emailBody ("Recovery: URL is now responding correctly\r\n\r\n" . \
                              "Router: $routerName\r\n" . \
                              "URL: $urlToCheck\r\n" . \
                              "Response: $fetchResponse\r\n" . \
                              "Expected: $expectedResponse\r\n" . \
                              "Status: OK\r\n" . \
                              "Date: $currentDate\r\n" . \
                              "Time: $currentTime\r\n" . \
                              "Was in error state for: $counterValue checks\r\n\r\n" . \
                              "The URL has recovered.")
            
            :put ("!!! RECOVERY - SENDING EMAIL !!!")
            :log warning ("URL Monitor: RECOVERY - $urlToCheck is OK again after $counterValue failed checks - Sending email")
            
            /tool e-mail send to=$emailTo subject=$emailSubject body=$emailBody
            
            :set ($urlCounters->$urlToCheck) 0
        }
    } else={
        :local newCounter $counterValue
        :if ($counterValue < 100) do={
            :set newCounter ($counterValue + 1)
            :set ($urlCounters->$urlToCheck) $newCounter
        }
        
        :put ("Status: FAILED - Counter: " . $newCounter)
        
        :if ($newCounter = $alertThreshold) do={
            :local failureReason
            :if ($fetchSuccess = false) do={
                :set failureReason "Failed to fetch URL (connection/timeout error)"
            } else={
                :set failureReason ("Response mismatch - Expected: '$expectedResponse' Got: '$fetchResponse'")
            }
            
            :local emailSubject ("$emailSubjectPrefix URL check failed")
            :local emailBody ("Alert: URL check has failed for $alertThreshold consecutive checks\r\n\r\n" . \
                              "Router: $routerName\r\n" . \
                              "URL: $urlToCheck\r\n" . \
                              "Failure Reason: $failureReason\r\n" . \
                              "Expected Response: $expectedResponse\r\n" . \
                              "Actual Response: $fetchResponse\r\n" . \
                              "Date: $currentDate\r\n" . \
                              "Time: $currentTime\r\n" . \
                              "Consecutive Failed Checks: $newCounter\r\n\r\n" . \
                              "Please investigate the issue.")
            
            :put ("!!! ALERT THRESHOLD REACHED - SENDING EMAIL !!!")
            :log warning ("URL Monitor: ALERT - $urlToCheck has FAILED for $alertThreshold checks - Sending email")
            
            /tool e-mail send to=$emailTo subject=$emailSubject body=$emailBody
        }
        
        :if ($newCounter > $alertThreshold) do={
            :put ("Still failing (counter: " . $newCounter . ")")
        }
    }
}

:put "=== URL Monitor Script Completed ==="
