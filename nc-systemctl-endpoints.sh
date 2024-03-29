#!/bin/bash
port=8081
auth="true"
user="rest"
pass="api"
while true; do
    request_in=$(nc -l -w 1 -p $port)
    request=$(echo "$request_in" | head -n 1)
    method=$(echo "$request" | cut -d " " -f 1)
    endpoint=$(echo "$request" | cut -d " " -f 2)
    ### Get Status from Headers and check
    if [[ $request_in == *"Status: "* ]]; then
        status=$(echo "$request_in" | grep "Status:" | awk '{print $2}')
        check_status="true"
    else
        check_status="false"
    fi
    ### Authorization
    if [[ $auth == "true" ]]; then
        cred_server=$(echo -n "$user:$pass" | base64 | tr -d '[:space:]')
        cred_client=$(echo "$request_in" | grep "Authorization: Basic" | awk '{print $3}' | tr -d '[:space:]')
        if [[ $cred_server == $cred_client ]]; then
            auth_status="true"
        else
            auth_status="false"
        fi
    fi
    if [[ $auth == "false" ]] || [[ $auth == "true" ]] && [[ $auth_status == "true" ]]; then
    ### GET request
        if [[ $method == "GET" ]]; then
            if [[ $endpoint == "/api/date" ]]; then
                response=$(date)
            elif [[ $endpoint == "/api/disk" ]]; then
                response=$(lsblk -e7 --json)
            ### Если конечная точка содержит service и не содержит заголовок
            elif [[ $endpoint == "/api/service/"* ]] && [[ $check_status == "false" ]]; then
                service_name=$(echo $endpoint | cut -d "/" -f 4)
                get="$(systemctl status $service_name 2>&1)" # --output json
                if [[ $get != *"not be found"* ]]; then
                    response=$get
                else
                    response="Bad Request. Service $service_name not found."
                fi
            ### Eсли содержит заголовок
            elif [[ $endpoint == "/api/service/"* ]] && [[ $check_status == "true" ]]; then
                service_name=$(echo $endpoint | cut -d "/" -f 4)
                if [[ $status == *"restart"* ]]; then
                    get=$(systemctl restart $service_name 2> /dev/null; systemctl status $service_name 2>&1)
                    if [[ $get != *"not be found"* ]]; then
                        response=$get
                    else
                        response="Bad Request. Service $service_name not found."
                    fi
                elif [[ $status == *"stop"* ]]; then
                    get=$(systemctl stop $service_name 2> /dev/null; systemctl status $service_name 2>&1)
                    if [[ $get != *"not be found"* ]]; then
                        response=$get
                    else
                        response="Bad Request. Service $service_name not found."
                    fi
                elif [[ $status == *"start"* ]]; then
                    get=$(systemctl start $service_name 2> /dev/null; systemctl status $service_name 2>&1)
                    if [[ $get != *"not be found"* ]]; then
                        response=$get
                    else
                        response="Bad Request. Service $service_name not found."
                    fi
                else
                    response="Bad Request. Invalid headers: $status. Supported: restart, stop and start."
                fi
            else
                response="Not Found"
            fi
        ### POST or other request
        elif [[ $method != "GET" ]]; then
            response="Method Not Allowed"
        fi
    else
        response="Unauthorized"
    fi
    ### Response code
    header_ok="HTTP/1.1 200 OK\nContent-Type: application/json\n\n"
    header_bad_request="HTTP/1.1 400 Bad Request\n\n400 Bad Request. "
    header_unauthorized="HTTP/1.1 401 Unauthorized\n\n401 Unauthorized"
    header_not_found="HTTP/1.1 404 Not Found\n\n404 Not Found: endpoint unavailable"
    header_method_not_allowed="HTTP/1.1 405 Method Not Allowed\n\n405 Method Not Allowed: only supports GET requests"
    ### Response send 
    if [[ $response == "Unauthorized" ]]; then
        echo -e $header_unauthorized | nc -l -N -p $port
    elif [[ $response == "Not Found" ]]; then
        echo -e $header_not_found | nc -l -N -p $port
    elif [[ $response == "Bad Request"* ]]; then
        echo -e "$header_bad_request$response" | nc -l -N -p $port
    elif [[ $response == "Method Not Allowed" ]]; then
        echo -e $header_method_not_allowed | nc -l -N -p $port
    else
        echo -e "$header_ok$response" | nc -l -N -p $port
    fi
done

# PowerShell Example Request:
# $user = "rest"
# $pass = "api"
# $EncodingCred = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("${user}:${pass}"))
# $Headers = @{"Authorization" = "Basic ${EncodingCred}"}
# Invoke-RestMethod http://192.168.3.101:8081/api/service/cron -Method Get -Headers $Headers
# Invoke-RestMethod http://192.168.3.101:8081/api/service/cron -Method Get -Headers $($Headers + @{"Status" = "stop"})
# Invoke-RestMethod http://192.168.3.101:8081/api/service/cron -Method Get -Headers $($Headers + @{"Status" = "start"})
# Invoke-RestMethod http://192.168.3.101:8081/api/service/cron -Method Get -Headers $($Headers + @{"Status" = "restart"})
# Curl Example Request:
# curl http://192.168.3.101:8081/api/service/cron
# curl http://192.168.3.101:8081/api/service/cron -u rest:api
# curl http://192.168.3.101:8081/api/service/cron -u rest:api -H "Status: restart"