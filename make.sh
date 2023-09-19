#!/bin/bash
CANBOOT=~/CanBoot/scripts
KLIPPER=~/klipper

function _help() {
  ret=${1:-0}
  echo "run $0 [ercf|ebb36|octopus] [make|flash|all]"
  exit $ret
}

function _make() {
  DEVICE=$1
  ACTION=$2
  CONFIG=config_${DEVICE}
  echo "> make $DEVICE $ACTION"
  cd $KLIPPER
  if [ ! -e $CONFIG ]
  then
    echo "ERROR: config \"$CONFIG\" missing"
    exit 1
  fi
  make KCONFIG_CONFIG=$CONFIG $ACTION
}

function _flash() {
  DEVICE=$1
  UUID=$2
  echo "> flash $DEVICE"

  case $DEVICE in
    ercf|ebb36)
      cd $CANBOOT
      binary=$(ls -1 $KLIPPER/out/klipper.* | grep -e bin -e uf2)
      python3 ./flash_can.py -i can0 -f $binary -u $UUID
      ;;
    *)
      echo other
      ;;
  esac
}

DEVICE=""
UUID=""
case $1 in
  ercf)
    DEVICE=ercf
    UUID=092fcd32b788
    ;;
  ebb36)
    DEVICE=ebb36
    UUID=8192d675a56e
    ;;
  octopus)
    DEVICE=octopus
    ;;
  *)
    echo "invalid device \"$1\""
    _help 1
    ;;
esac

ACTION=""
case $2 in
  make)
    _make $DEVICE
    ;;
  flash)
    _flash $DEVICE $UUID
    ;;
  config)
    _make $DEVICE menuconfig
    ;;
  all)
    _make $DEVICE clean
    _make $DEVICE -j4
    _flash $DEVICE
  ;;
  *)
    echo "invalid action \"$2\""
    _help 1
    ;;
esac


