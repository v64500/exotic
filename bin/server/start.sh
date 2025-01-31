#!/bin/bash

DAEMON=false
DISPLAY_MODE="GUI"
PRIVACY_CONTEXT=2
MAX_TABS=8

while [[ $# -gt 0 ]]; do
  case $1 in
    -D|--daemon)
      DAEMON=true
      shift # past argument
      ;;
    -SV|--supervised)
      DISPLAY_MODE="SUPERVISED"
      shift # past argument
      ;;
    -HL|--headless)
      DISPLAY_MODE="HEADLESS"
      shift # past argument
      ;;
    -pc|--privacy)
      PRIVACY_CONTEXT="$2"
      shift # past argument
      shift # past value
      ;;
    -mt|--max-tabs)
      MAX_TABS="$2"
      shift # past argument
      shift # past value
      ;;
    -*|--*)
      echo "Unknown option $1"
      exit 1
      ;;
    *)
      shift # past argument
      ;;
  esac
done

export APP_DATA="$HOME/.pulsar"
export APP_LOG_HOME="$APP_DATA/logs"
mkdir -p "$APP_LOG_HOME"

LOG_DIR="$APP_LOG_HOME/serve"
if [[ -e $LOG_DIR ]]; then
  COUNT=$(ls -l "$APP_LOG_HOME" | grep -c "$TLD")
  mv "$LOG_DIR" "$LOG_DIR.$COUNT"
fi
mkdir -p "$LOG_DIR"

JAVA=$(command -v java)
if [[ -e $JAVA ]]; then
  JAVA_HOME=$(dirname $(dirname $(readlink -f $(which javac))))
  export JAVA_HOME=$JAVA_HOME
fi
JAVA="$JAVA_HOME/bin/java"

JAR=$(find . -name "exotic-server*.jar")
LOGBACK_CONFIG_FILE_LOCATION=$(find . -name "logback*.xml")

APP_OPTS=(
-D"logging.dir=$LOG_DIR"
-D"privacy.context.number=$PRIVACY_CONTEXT"
-D"browser.max.active.tabs=$MAX_TABS"
-D"browser.display.mode=$DISPLAY_MODE"
)

if [[ -e "$LOGBACK_CONFIG_FILE_LOCATION" ]]; then
  APP_OPTS=("${APP_OPTS[@]}" -D"logging.config=$LOGBACK_CONFIG_FILE_LOCATION")
fi

PROC_NAME="EXOTICS"
EXEC_CALL=(java
-Dproc_"$PROC_NAME"
"-Xms2G" "-Xmx10g" "-XX:+HeapDumpOnOutOfMemoryError"
"-XX:-OmitStackTraceInFastThrow"
"-XX:ErrorFile=$USER_HOME/java_error_in_exotics_%p.log"
"-XX:HeapDumpPath=$USER_HOME/java_error_in_exotics.hprof"
-D"java.awt.headless=true"
"${APP_OPTS[@]}"
-D"loader.main=ai.platon.exotic.ExoticServerApplicationKt"
-cp "$JAR" org.springframework.boot.loader.PropertiesLauncher
)

COUNT=$(pgrep -cf "$PROC_NAME")
if (( COUNT > 0 )); then
  echo "$PROC_NAME is already running."
  exit 0
fi

LOGOUT=/dev/null
PID="$LOG_DIR/exotics.pid"
if $DAEMON; then
  exec "${EXEC_CALL[@]}" >> "$LOGOUT" 2>&1 &
  echo $! > "$PID"
else
  echo "${EXEC_CALL[@]}"
  exec "${EXEC_CALL[@]}"
fi
