#!/bin/sh
#
# WeMo Control Script
# 
# Original author: rich@netmagi.com
# http://moderntoil.com/?p=839
#
# Modified 7/13/2014 by Donald Burr
# email: <dburr@DonaldBurr.com>
# web: <http://DonaldBurr.com>
#
# Usage: wemo IP_ADDRESS[:PORT] ON/OFF/GETSTATE/GETSIGNALSTRENGTH/GETFRIENDLYNAME

IP=$1
CMD=`echo $2 | tr '[a-z]' '[A-Z]'`

if echo $1 | grep -q :; then
  IP=`echo $1 | cut -d: -f1`
  PORT=`echo $1 | cut -d: -f2`
else
  PORTTEST=$(curl -m 1 --connect-timeout 1 -s $IP:49153 | grep "404")
  if [ $? -ne 0 -o "$PORTTEST" = "" ]; then
    PORT=49154
  else
    PORT=49153
  fi
fi

if [ "$1" = "" ]; then
  echo "Usage: `basename $0` IP_ADDRESS[:PORT] ON/OFF/GETSTATE/GETSIGNALSTRENGTH/GETFRIENDLYNAME"
else
  if [ "$CMD" = "GETSTATE" ]; then 
    STATE=`curl -0 -A '' -X POST -H 'Accept: ' -H 'Content-type: text/xml; charset="utf-8"' -H "SOAPACTION: \"urn:Belkin:service:basicevent:1#GetBinaryState\"" --data '<?xml version="1.0" encoding="utf-8"?><s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><s:Body><u:GetBinaryState xmlns:u="urn:Belkin:service:basicevent:1"><BinaryState>1</BinaryState></u:GetBinaryState></s:Body></s:Envelope>' -s http://$IP:$PORT/upnp/control/basicevent1 | 
    grep "<BinaryState"  | cut -d">" -f2 | cut -d "<" -f1 | sed 's/0/OFF/g' | sed 's/1/ON/g'`
    echo $STATE
    if [ "$STATE" = "OFF" ]; then
      exit 0
    elif [ "$STATE" = "ON" ]; then
      exit 1
    else
      exit 2
    fi
  elif [ "$CMD" = "ON" ]; then
    curl -0 -A '' -X POST -H 'Accept: ' -H 'Content-type: text/xml; charset="utf-8"' -H "SOAPACTION: \"urn:Belkin:service:basicevent:1#SetBinaryState\"" --data '<?xml version="1.0" encoding="utf-8"?><s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><s:Body><u:SetBinaryState xmlns:u="urn:Belkin:service:basicevent:1"><BinaryState>1</BinaryState></u:SetBinaryState></s:Body></s:Envelope>' -s http://$IP:$PORT/upnp/control/basicevent1 |
    grep "<BinaryState"  | cut -d">" -f2 | cut -d "<" -f1
  elif [ "$CMD" = "OFF" ]; then
    curl -0 -A '' -X POST -H 'Accept: ' -H 'Content-type: text/xml; charset="utf-8"' -H "SOAPACTION: \"urn:Belkin:service:basicevent:1#SetBinaryState\"" --data '<?xml version="1.0" encoding="utf-8"?><s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><s:Body><u:SetBinaryState xmlns:u="urn:Belkin:service:basicevent:1"><BinaryState>0</BinaryState></u:SetBinaryState></s:Body></s:Envelope>' -s http://$IP:$PORT/upnp/control/basicevent1 |
    grep "<BinaryState"  | cut -d">" -f2 | cut -d "<" -f1
  elif [ "$CMD" = "GETSIGNALSTRENGTH" ]; then
    curl -0 -A '' -X POST -H 'Accept: ' -H 'Content-type: text/xml; charset="utf-8"' -H "SOAPACTION: \"urn:Belkin:service:basicevent:1#GetSignalStrength\"" --data '<?xml version="1.0" encoding="utf-8"?><s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><s:Body><u:GetSignalStrength xmlns:u="urn:Belkin:service:basicevent:1"><GetSignalStrength>0</GetSignalStrength></u:GetSignalStrength></s:Body></s:Envelope>' -s http://$IP:$PORT/upnp/control/basicevent1 |
    grep "<SignalStrength"  | cut -d">" -f2 | cut -d "<" -f1
  elif [ "$CMD" = "GETFRIENDLYNAME" ]; then
    curl -0 -A '' -X POST -H 'Accept: ' -H 'Content-type: text/xml; charset="utf-8"' -H "SOAPACTION: \"urn:Belkin:service:basicevent:1#GetFriendlyName\"" --data '<?xml version="1.0" encoding="utf-8"?><s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><s:Body><u:GetFriendlyName xmlns:u="urn:Belkin:service:basicevent:1"><FriendlyName></FriendlyName></u:GetFriendlyName></s:Body></s:Envelope>' -s http://$IP:$PORT/upnp/control/basicevent1 |
    grep "<FriendlyName"  | cut -d">" -f2 | cut -d "<" -f1
  else
    echo "COMMAND NOT RECOGNIZED"
    echo ""
    echo "Usage: `basename $0` IP_ADDRESS[:PORT] ON/OFF/GETSTATE/GETSIGNALSTRENGTH/GETFRIENDLYNAME"
    echo ""
  fi
fi
