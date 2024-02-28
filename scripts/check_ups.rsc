
:local online;
:local runtimeleft;
:local battcharge;
:global lastupsstate

/system ups monitor ups1 once do={
:set online $"on-line";
:set runtimeleft $"runtime-left";
:set battcharge $"battery-charge";
}

:if ($lastupsstate != $online) do={
:set lastupsstate $online
:if ($online=false) do={
:log info "Offline"
/tool/fetch url="someurl/$battcharge" keep-result=no
} else={
:log info "Online"
/tool/fetch url="someurl/200/$battcharge" keep-result=no
}
}