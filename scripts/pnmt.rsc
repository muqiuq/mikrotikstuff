:local PublicIp
:set PublicIp [/ip/cloud/get public-address]

/tool/fetch url="https://URL/200/$PublicIp" keep-result=no
