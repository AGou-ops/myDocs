#!/bin/bash
#
#**************************************************
# Author:         suofeiya                        *
# E-mail：        ictw@qq.com                     *
# Date：          2020-07-07       *
# Description：  *
# Copyright 2020 by suofeiya.All Rights Reserved  *
#**************************************************

basedir=$1
tree -i "$basedir" | egrep "*.md" | sed 's/.md//g' > "${basedir}/1.txt"
tree -i "$basedir" | egrep "*.md" > "${basedir}/2.txt"

cd "$1"
linenum=`wc -l 1.txt | cut -d " " -f 1`
declare -i i=1

while ((i <= $linenum))
do
    title=`sed -n "${i}p" 1.txt`
    file=`sed -n "${i}p" 2.txt`
    sed -i "1 i ${title} \n========" "${file}"
    let i=i+1
done

rm -f 1.txt 2.txt 1.sh
