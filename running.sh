 #!/bin/bash
 WS_STATUS=0
 WORKSPACE_ID=$1
 COMMONSEGMENT=/opt/microsoft/omsagent
 VAR_DIR=/var$COMMONSEGMENT
 VAR_DIR_WS=$VAR_DIR/$WORKSPACE_ID
 RUN_DIR=$VAR_DIR_WS/run
 PIDFILE = $RUN_DIR/omsagent.pid
 ERROR_UNEXPECTED_STATE=69
 FILE_NOT_FOUND=21

    if [ -f $PIDFILE ]; then
        local omsagent_pid=`cat $PIDFILE 2>/dev/null`
        local ps_state=`ps --no-header -o state -p $omsagent_pid`
        if [ -z "$ps_state" ]; then
            WS_STATUS=1 # Not There; FALSE
        else
            case "$ps_state" in
            D)  echo "Uninterruptable Sleep State Seen in omsagent process.";;
            R)  ;;
            S)  ;;
            T)  echo "Stopped State Seen in omsagent process."
                WS_STATUS=$ERROR_UNEXPECTED_STATE;;
            W)  echo "Paging State Seen in omsagent process."
                WS_STATUS=$ERROR_UNEXPECTED_STATE;;
            X)  echo "Dead State Seen in omsagent process."
                WS_STATUS=$ERROR_UNEXPECTED_STATE;;
            Z)  echo "Defunct State Seen in omsagent process."
                WS_STATUS=$ERROR_UNEXPECTED_STATE;;
            *)  echo "ERROR:  '$ps_state' is not a known ps flag."
                notification_exit ERROR_UNEXPECTED_SYSTEM_INFO;;
            esac
        fi
    else
        WS_STATUS=$FILE_NOT_FOUND
    fi
    return $WS_STATUS
