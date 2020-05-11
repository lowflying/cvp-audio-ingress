#!/bin/bash

max=$1
prefix="hmcts"
suffix="@meet.video.justice.gov.uk"

echo "Ensuring there are ${max} Applications setup"

currentAppCount=$(ls -d /usr/local/WowzaStreamingEngine/applications/hmcts* | wc -l)

echo "Currently ${currentAppCount} applications defined."

if (( max < currentAppCount )) ; then
  ((toDelete = "$currentAppCount - $max"))
  echo "Need to delete ${toDelete} Application(s)"

  start=$max
  end=$currentAppCount

  for ((i=start; i<=end; i++)) ; do
    file="${prefix}${i}${suffix}"
    rm -Rf /usr/local/WowzaStreamingEngine/applications/${file}
    rm -Rf /usr/local/WowzaStreamingEngine/conf/${file}
  done
fi

targetDir="/usr/local/WowzaStreamingEngine/applications/"
n=1
set -- # this sets $@ [the argv array] to an empty list.

while [ "$n" -le "$max" ]; do
    set -- "$@" "${targetDir}/${prefix}${n}${suffix}"
    n=$(( n + 1 ));
done

mkdir -p "$@"


targetDir="/usr/local/WowzaStreamingEngine/conf/"
n=1
set -- # this sets $@ [the argv array] to an empty list.

while [ "$n" -le "$max" ]; do
    set -- "$@" "${targetDir}/${prefix}${n}${suffix}"
    n=$(( n + 1 ));
done

mkdir -p "$@"
# Copy Applications.xml file
cd /usr/local/WowzaStreamingEngine/conf/ || exit
appDirs=$(ls -d hmcts*)
echo "${appDirs}" | xargs -n 1 cp -v -f /home/wowza/Application.xml