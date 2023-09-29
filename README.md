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

![Image alt](https://github.com/Lifailon/NC-REST-Endpoints/blob/rsa/example.jpg)
