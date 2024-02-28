#!/bin/bash
port=8081
header_ok="HTTP/1.1 200 OK\nContent-Type: application/json\n\n"
while true
do
    request_in=$(nc -l -w 1 -p $port)
    request=$(echo "$request_in" | head -n 1)
    method=$(echo "$request" | cut -d " " -f 1)
    endpoint=$(echo "$request" | cut -d " " -f 2)
    ### Get headers
    if [[ "$request_in" == *"curl"* ]]; then
        header_request=$(echo "$request_in" | tail -n 2) # for curl (line -2 for -H and line -1 for -d)
    elif [[ "$request_in" == *"PowerShell"* ]]; then
        header_request=$(echo "$request_in" | head -n 3) # for powershell (line -1 for -Body)
    else
        header_request=""
    fi
    if [[ $header_request == *"Status: "* ]]
        then
        status=$(echo $header_request | sed -r "s/.+:\s+//")
        check_status="true"
    else
        check_status="false"
    fi
    ### GET request
    if [[ $method == "GET" ]]
        then
        if [[ $endpoint == "/api/date" ]]
            then
            response=$(date)
        elif [[ $endpoint == "/api/disk" ]]
            then
            response=$(lsblk -e7 --json)
        elif [[ $endpoint == "/api/service/"* ]] && [[ $check_status == "false" ]] # если enpdoint содержит service и не содержит заголовок
            then
            service_name=$(echo $endpoint | cut -d "/" -f 4)
            get="$(systemctl status $service_name 2>&1)" # --output json
            if [[ $get != *"not be found"* ]]
                then
                response=$get
            else
                response="Bad Request"
            fi
        elif [[ $endpoint == "/api/service/"* ]] && [[ $check_status == "true" ]]  # если содержит заголовок
            then
            service_name=$(echo $endpoint | cut -d "/" -f 4)
            if [[ $status == *"restart"* ]]
                then
                get=$(systemctl restart $service_name 2> /dev/null; systemctl status $service_name 2>&1)
                if [[ $get != *"not be found"* ]]
                    then
                    response=$get
                else
                    response="Bad Request"
                fi
            elif [[ $status == *"stop"* ]]
                then
                get=$(systemctl stop $service_name 2> /dev/null; systemctl status $service_name 2>&1)
                if [[ $get != *"not be found"* ]]
                    then
                    response=$get
                else
                    response="Bad Request"
                fi
            elif [[ $status == *"start"* ]]
                then
                get=$(systemctl start $service_name 2> /dev/null; systemctl status $service_name 2>&1)
                if [[ $get != *"not be found"* ]]
                    then
                    response=$get
                else
                    response="Bad Request"
                fi
            else
                response="Bad Request Headers"
            fi 
        else
            response="Bad Request"
        fi
    ### POST request
    elif [[ $method == "POST" ]]
        then
        response="Method Not Allowed"
    fi
    ### Response status
    header_bad_request="HTTP/1.1 400 Bad Request\n\n400 Bad Request\nInvalid service name: $service_name. Supported by full name only."
    if [[ $response == "Bad Request Headers" ]]
        then
        header_bad_request="HTTP/1.1 400 Bad Request\n\n400 Bad Request\nInvalid headers: $status. Supported: restart, stop and start."
        response="Bad Request"
    fi
    header_unauthorized="HTTP/1.1 401 Unauthorized\n\n401 Unauthorized"
    header_forbidden="HTTP/1.1 403 Forbidden\n\n403 Forbidden"
    header_not_found="HTTP/1.1 404 Not Found\n\n404 Not Found: endpoint unavailable"
    header_method_not_allowed="HTTP/1.1 405 Method Not Allowed\n\n405 Method Not Allowed: only supports GET requests"
    ### Response send 
    if [[ $response == "Not Found" ]]
        then
        echo -e $header_not_found | nc -l -N -p $port
    elif [[ $response == "Bad Request" ]]
        then
        echo -e $header_bad_request | nc -l -N -p $port
    elif [[ $response == "Method Not Allowed" ]]
        then
        echo -e $header_method_not_allowed | nc -l -N -p $port
    else
        echo -e "$header_ok$response" | nc -l -N -p $port
    fi
done

# PowerShell Example Request:
# irm http://192.168.3.101:8081/api/service/cron -Method Get
# irm http://192.168.3.101:8081/api/service/cron -Method Get -Headers @{"Status" = "restart"}
# irm http://192.168.3.101:8081/api/service/cron -Method Get -Headers @{"Status" = "stop"}
# irm http://192.168.3.101:8081/api/service/cron -Method Get -Headers @{"Status" = "start"}
# Curl Example Request:
# curl http://192.168.3.101:8081/api/service/cron
# curl http://192.168.3.101:8081/api/service/cron -H "Status: restart"