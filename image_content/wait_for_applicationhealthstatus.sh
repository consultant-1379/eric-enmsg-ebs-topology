#!/bin/bash

# ********************************************************************
#
# (c) Ericsson LMI 2022 - All rights reserved.
#
# The copyright to the computer program(s) herein is the property
# of Ericsson LMI. The programs may be used and/or copied only with
# the written permission from Ericsson LMI or in accordance with the
# terms and conditions stipulated in the agreement/contract under
# which the program(s) have been supplied.
#
# ********************************************************************

# GLOBAL VARIABLES
readonly CURL="/usr/bin/curl"
readonly JBOSS_HTTP_PORT="8080"
readonly EXPECTED_CURL_RESPONSE="{\"state\":\"UP\",\"appName\":\"ebstopology\",\"additionalData\":{}}"

POD_HTTP_URL="http://127.0.0.1:$JBOSS_HTTP_PORT/ebs-topology-service/ebstopology/health"

RESPONSE=$($CURL -m 10 --connect-timeout 7 --silent "$POD_HTTP_URL")
CURL_EXIT=$?
if [[ "$CURL_EXIT" -ne 0 ]];then
        logger "EBSTOPOLOGY_HEALTHCHECK command failed: url: \"$POD_HTTP_URL\" returned \"$RESPONSE\" curl_exit code : \"$CURL_EXIT\""
elif [[ "$CURL_EXIT" -eq 0 && "$EXPECTED_CURL_RESPONSE" == "$RESPONSE" ]];then
        # Move the script from resource.d directory as application health status returned positive response.
        mv /usr/lib/ocf/resource.d/wait_for_applicationhealthstatus.sh /tmp/
        logger "EBSTOPOLOGY_HEALTHCHECK command passed: Moved wait_for_applicationhealthstatus.sh script from resource.d directory."
elif [[ "$CURL_EXIT" -eq 0 && "$EXPECTED_CURL_RESPONSE" != "$RESPONSE" ]];then
        # Covers scenario where curl requests that may fire before the services are deployed and return 404 with exit code 0.
        logger "EBSTOPOLOGY_HEALTHCHECK command failed: url: \"$POD_HTTP_URL\" returned \"$RESPONSE\" curl_exit code : \"$CURL_EXIT\""
        exit 1
fi

exit $CURL_EXIT
