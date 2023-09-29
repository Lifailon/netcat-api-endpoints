## NC-REST-Endpoints

```powershell
PS C:\Users\Lifailon> irm http://192.168.3.101:8081/api/service/cro
Invoke-RestMethod: 400 Bad Request
Invalid service name: cro. Supported by full name only.

PS C:\Users\Lifailon> irm http://192.168.3.101:8081/api/service/cron -Method Get -Headers @{"Status" = "no"}
Invoke-RestMethod: 400 Bad Request
Invalid headers: no. Supported: restart, stop and start.

PS C:\Users\Lifailon> irm http://192.168.3.101:8081/api/service/cron -Method Get -Headers @{"Status" = "stop"}
● cron.service - Regular background program processing daemon
     Loaded: loaded (/lib/systemd/system/cron.service; enabled; vendor preset: enabled)
     Active: inactive (dead) since Fri 2023-09-29 14:16:59 MSK; 16ms ago
       Docs: man:cron(8)
    Process: 372094 ExecStart=/usr/sbin/cron -f $EXTRA_OPTS (code=killed, signal=TERM)
   Main PID: 372094 (code=killed, signal=TERM)

Sep 29 14:09:11 pi-hole-01 systemd[1]: Started Regular background program processing daemon.
Sep 29 14:09:11 pi-hole-01 cron[372094]: (CRON) INFO (pidfile fd = 3)
Sep 29 14:09:11 pi-hole-01 cron[372094]: (CRON) INFO (Skipping @reboot jobs -- not system startup)
Sep 29 14:15:01 pi-hole-01 CRON[397496]: pam_unix(cron:session): session opened for user root by (uid=0)
Sep 29 14:15:01 pi-hole-01 CRON[397497]: (root) CMD (command -v debian-sa1 > /dev/null && debian-sa1 1 1)
Sep 29 14:15:01 pi-hole-01 CRON[397496]: pam_unix(cron:session): session closed for user root
Sep 29 14:16:59 pi-hole-01 systemd[1]: Stopping Regular background program processing daemon...
Sep 29 14:16:59 pi-hole-01 systemd[1]: cron.service: Succeeded.
Sep 29 14:16:59 pi-hole-01 systemd[1]: Stopped Regular background program processing daemon.

PS C:\Users\Lifailon> irm http://192.168.3.101:8081/api/service/cron -Method Get -Headers @{"Status" = "start"}
● cron.service - Regular background program processing daemon
     Loaded: loaded (/lib/systemd/system/cron.service; enabled; vendor preset: enabled)
     Active: active (running) since Fri 2023-09-29 14:17:07 MSK; 15ms ago
       Docs: man:cron(8)
   Main PID: 406733 (cron)
      Tasks: 1 (limit: 2220)
     Memory: 328.0K
     CGroup: /system.slice/cron.service
             └─406733 /usr/sbin/cron -f

Sep 29 14:17:07 pi-hole-01 systemd[1]: Started Regular background program processing daemon.
Sep 29 14:17:07 pi-hole-01 cron[406733]: (CRON) INFO (pidfile fd = 3)
Sep 29 14:17:07 pi-hole-01 cron[406733]: (CRON) INFO (Skipping @reboot jobs -- not system startup)

PS C:\Users\Lifailon> irm http://192.168.3.101:8081/api/service/cron -Method Get
● cron.service - Regular background program processing daemon
     Loaded: loaded (/lib/systemd/system/cron.service; enabled; vendor preset: enabled)
     Active: active (running) since Fri 2023-09-29 14:17:07 MSK; 7s ago
       Docs: man:cron(8)
   Main PID: 406733 (cron)
      Tasks: 1 (limit: 2220)
     Memory: 328.0K
     CGroup: /system.slice/cron.service
             └─406733 /usr/sbin/cron -f

Sep 29 14:17:07 pi-hole-01 systemd[1]: Started Regular background program processing daemon.
Sep 29 14:17:07 pi-hole-01 cron[406733]: (CRON) INFO (pidfile fd = 3)
Sep 29 14:17:07 pi-hole-01 cron[406733]: (CRON) INFO (Skipping @reboot jobs -- not system startup)
```

```bash
root@pi-hole-01:/home/lifailon# bash nc-systemctl-endpoints.sh
GET /api/service/cro HTTP/1.1
Host: 192.168.3.101:8081
User-Agent: Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.19045; ru-RU) PowerShell/7.3.7

Службу cron нужно no
GET /api/service/cron HTTP/1.1
Host: 192.168.3.101:8081
Status: no
User-Agent: Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.19045; ru-RU) PowerShell/7.3.7

Службу cron нужно stop
GET /api/service/cron HTTP/1.1
Host: 192.168.3.101:8081
Status: stop
User-Agent: Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.19045; ru-RU) PowerShell/7.3.7

Службу cron нужно start
GET /api/service/cron HTTP/1.1
Host: 192.168.3.101:8081
Status: start
User-Agent: Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.19045; ru-RU) PowerShell/7.3.7

GET /api/service/cron HTTP/1.1
Host: 192.168.3.101:8081
User-Agent: Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.19045; ru-RU) PowerShell/7.3.7
```
