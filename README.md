## NC-REST-Endpoints

This is a simple netcat server that accepts and processes endpoint requests to manage Linux-based services (systemctl).

Only the GET method is supported for **PowerShell 7 (Invoke-RestMethod or Invoke-WebRequest)**. The endpoints used: \
`/api/date` \
`/api/disk` \
`/api/service/service_name`

**Curl is not supported!** Curl does not wait for additional time from the server to get a complete response to the request (same with irm/iwr and POST method), **unlike Invoke-RestMethod and GET method in PowerShell 7**, it waits for a complete response from the server before returning the result of the request. In the case of netcat, the utility does not terminate the connection until the server sends a complete response. The result of the request is stored in a buffer/stream and gives back the response of the previous request when the client makes a subsequent request.

**Request syntax for send:** \
`irm http://192.168.3.101:8081/api/service/cron -Method Get` \
`irm http://192.168.3.101:8081/api/service/cron -Method Get -Headers @{"Status" = "restart"}` \
`irm http://192.168.3.101:8081/api/service/cron -Method Get -Headers @{"Status" = "stop"}` \
`irm http://192.168.3.101:8081/api/service/cron -Method Get -Headers @{"Status" = "start"}`

### Example:

```powershell
PS C:\Users\Lifailon> irm http://192.168.3.101:8081/api/service/cro
Invoke-RestMethod: 400 Bad Request
Invalid service name: cro. Supported by full name only.
PS C:\Users\Lifailon> irm http://192.168.3.101:8081/api/service/cron -Method Get -Headers @{"Status" = "star"}
Invoke-RestMethod: 400 Bad Request
Invalid headers: star. Supported: restart, stop and start.
PS C:\Users\Lifailon> irm http://192.168.3.101:8081/api/service/cron -Method Get -Headers @{"Status" = "stop"}
● cron.service - Regular background program processing daemon
     Loaded: loaded (/lib/systemd/system/cron.service; enabled; vendor preset: enabled)
     Active: inactive (dead) since Fri 2023-09-29 14:30:14 MSK; 5ms ago
       Docs: man:cron(8)
    Process: 406733 ExecStart=/usr/sbin/cron -f $EXTRA_OPTS (code=killed, signal=TERM)
   Main PID: 406733 (code=killed, signal=TERM)

Sep 29 14:17:07 pi-hole-01 systemd[1]: Started Regular background program processing daemon.
Sep 29 14:17:07 pi-hole-01 cron[406733]: (CRON) INFO (pidfile fd = 3)
Sep 29 14:17:07 pi-hole-01 cron[406733]: (CRON) INFO (Skipping @reboot jobs -- not system startup)
Sep 29 14:25:01 pi-hole-01 CRON[440227]: pam_unix(cron:session): session opened for user root by (uid=0)
Sep 29 14:25:01 pi-hole-01 CRON[440237]: (root) CMD (command -v debian-sa1 > /dev/null && debian-sa1 1 1)
Sep 29 14:25:01 pi-hole-01 CRON[440227]: pam_unix(cron:session): session closed for user root
Sep 29 14:30:14 pi-hole-01 systemd[1]: Stopping Regular background program processing daemon...
Sep 29 14:30:14 pi-hole-01 systemd[1]: cron.service: Succeeded.
Sep 29 14:30:14 pi-hole-01 systemd[1]: Stopped Regular background program processing daemon.

PS C:\Users\Lifailon> irm http://192.168.3.101:8081/api/service/cron -Method Get -Headers @{"Status" = "start"}
● cron.service - Regular background program processing daemon
     Loaded: loaded (/lib/systemd/system/cron.service; enabled; vendor preset: enabled)
     Active: active (running) since Fri 2023-09-29 14:30:19 MSK; 18ms ago
       Docs: man:cron(8)
   Main PID: 463287 (cron)
      Tasks: 1 (limit: 2220)
     Memory: 544.0K
     CGroup: /system.slice/cron.service
             └─463287 /usr/sbin/cron -f

Sep 29 14:30:19 pi-hole-01 systemd[1]: Started Regular background program processing daemon.
Sep 29 14:30:19 pi-hole-01 cron[463287]: (CRON) INFO (pidfile fd = 3)
Sep 29 14:30:19 pi-hole-01 cron[463287]: (CRON) INFO (Skipping @reboot jobs -- not system startup)

PS C:\Users\Lifailon> irm http://192.168.3.101:8081/api/service/syslog -Method Get
● rsyslog.service - System Logging Service
     Loaded: loaded (/lib/systemd/system/rsyslog.service; enabled; vendor preset: enabled)
     Active: active (running) since Fri 2023-09-22 10:50:11 MSK; 1 weeks 0 days ago
TriggeredBy: ● syslog.socket
       Docs: man:rsyslogd(8)
             https://www.rsyslog.com/doc/
   Main PID: 884 (rsyslogd)
      Tasks: 4 (limit: 2220)
     Memory: 7.8M
     CGroup: /system.slice/rsyslog.service
             └─884 /usr/sbin/rsyslogd -n -iNONE

Sep 22 10:50:10 pi-hole-01 systemd[1]: Starting System Logging Service...
Sep 22 10:50:11 pi-hole-01 systemd[1]: Started System Logging Service.
```

**Output on server netcat**:

```bash
GET /api/service/cro HTTP/1.1
Host: 192.168.3.101:8081
User-Agent: Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.19045; ru-RU) PowerShell/7.3.7

GET /api/service/cron HTTP/1.1
Host: 192.168.3.101:8081
Status: star
User-Agent: Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.19045; ru-RU) PowerShell/7.3.7

GET /api/service/cron HTTP/1.1
Host: 192.168.3.101:8081
Status: stop
User-Agent: Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.19045; ru-RU) PowerShell/7.3.7

GET /api/service/cron HTTP/1.1
Host: 192.168.3.101:8081
Status: start
User-Agent: Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.19045; ru-RU) PowerShell/7.3.7

GET /api/service/syslog HTTP/1.1
Host: 192.168.3.101:8081
User-Agent: Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.19045; ru-RU) PowerShell/7.3.7
```
