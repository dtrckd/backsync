#!/bin/bash

### Backup Script

#dst_arg="${@: -1}"
src_arg="$(($#-1))"
dst_arg="$(($#-0))"
# --
src_arg="${!src_arg}"
dst_arg="${!dst_arg}"

if [[ -d "$src_arg" && -d "$dst_arg" ]]; then
    PREFIX_SRC="./"
    PREFIX_DST="$dst_arg"
    DIR_TAR="$src_arg"/
else
    PREFIX_SRC="../"
    PREFIX_DST="/media/$USER/MARS/"
    DIR_TAR="workInProgress/"
fi

### Target

### Domains
#NET_USER="dtrckd"
#Domain="domain"
PREFIX_DST_NET="${NET_USER}@${Domain}:~/"


OPTS="-a -u --delete-after --modify-window=10 --fuzzy --progress --stats -h --no-o --no-g --no-p -O --max-size=2G"

if [ -e ".rsync_include" ]; then
    FILTER_F="--exclude-from=.rsync_include"
fi

#FILTER="--size-only"

#COMPRESS="--compress"
NET="0"
FORCE="0"
SIMUL="0" # calc size of each files to be transfered
DOWN="0" # inverse direction of backup
GREPGIT="1" # don't show .git/* files

##############
### Args Parse
nbarg=$#
for i in `seq 1 $nbarg`; do
    arg=$1
    if [ "$arg" != "" ]; then
        if [ "$arg" == "-s" ]; then
            OPTS="$OPTS --dry-run" && FORCE="1"
            SIMUL="1"
        elif [ "$arg" == "-v" ]; then
            VERBOSE="-v -i"
        elif [ "$arg" == "-vv" ]; then
            VERBOSE="-vv -i"
        elif [ "$arg" == "--purge" ]; then # remove some
            PURGE="1"
        elif [ "$arg" == "-n" -o "$arg" == "--net" ]; then
            PREFIX_DST=$PREFIX_DST_NET
            FILTER_F="--exclude-from=.rsync_include_expe"
            #FILTER_F="--exclude-from=.rsync_include_net"
            NET="1"
        elif [ "$arg" == "--down" ]; then # update from backup
            DOWN="1"
        elif [ "$arg" == "-f" ]; then # force the backup
            FORCE="1"
        elif [ "$arg" == "-z" -o "$arg" == "--compress" ]; then # force the backup
            COMPRESS="--compress"
        elif [ "$arg" == "--safe" ]; then # don't remove anything
            OPTS="$OPTS --max-delete=0"
        elif [ "$arg" == "--size" ]; then # size only
            OPTS="$OPTS --size-only"
        elif [ "$arg" == "--nogrep" ]; then # size only
            GREPGIT="0"
        elif [ "$arg" == "-ss" -o "$arg" == "--size" ]; then # simul + size of files
            OPTS="$OPTS --dry-run"
            FORCE="1"
            SIMUL="2"
        #elif [ "$arg" == "--exclude" ]; then # exclusion regex
        elif [ "$arg" == "-exreg" ]; then # exclusion regex
            OPTS="--exclude=$2"
            shift
        elif [ "$arg" == "--checksum" ]; then # exclusion regex
            OPTS="$OPTS --checksum"
            shift
        elif [ "$arg" == "--make" ]; then
            Make="1"
        elif [ "$arg/" == "$DIR_TAR" ]; then
            continue
        else
            echo "$0 error [exiting]"
            exit 1
        fi
    fi
    shift
done

### Remove some obsolete file before backup
if [ "$PURGE" == "1" ]; then
    echo "[Delete Stage]"
    find "${PREFIX_SRC}/${SRC}" -type f -name "*\~" -print0 -delete
fi

### Inverse the way of backup
if [ "$DOWN" == "1" ]; then
    TMP_SRC="$PREFIX_SRC"
    PREFIX_SRC="$PREFIX_DST"
    PREFIX_DST="$TMP_SRC"
    #FILTER="$FILTER --exclude=/backup.sh"
    tmp_h="$HOOK1"
    hook1="$HOOK2"
    hook2="$tmp_h"
fi

### Set path target name
if [ -z "$hook1" -a -z "$hook2" ]; then
    DIR_TAR1="$DIR_TAR"
    DIR_TAR2="$DIR_TAR"
else
    DIR_TAR1="$hook1"
    DIR_TAR2="$hook2"
fi

if [ "$FORCE" == "0" ]; then
    echo "[warning dammages: use -f]"
    echo "${PREFIX_SRC}${DIR_TAR1} --> ${PREFIX_DST}${DIR_TAR2}"
    exit 1
fi

OPTS="$OPTS $VERBOSE $COMPRESS $REMOTE $FILTER $FILTER_F"

PADD=$(echo "--"$a{1..20}e)
echo -e "$PADD\n[ Rsync Stage ...]"
if [ "$SIMUL" == "2" ]; then #XULGet file size 
    echo "[ Simulation ]"
    RES=`/usr/bin/rsync ${OPTS} "${PREFIX_SRC}${DIR_TAR1}" "${PREFIX_DST}${DIR_TAR2}"`
    RES2=$RES
    TTT= # sed fuck
    while read line; do
        if [ -e "$line" ]; then
            line2=`du -sh0 "$line"`
            TTT=`echo  "$RES2" | sed -e "s:^${line}$:${line2}:"`
            RES2=$TTT
            #echo "$RES2"
        fi
    done < <(echo "$RES") # if not, the pipe loose variable up propagation
    echo "$RES2"

else
    if [ "$SIMUL" == "1" ]; then
        echo "[ Simulation ]"
    fi
    echo ''
    if [ "${GREPGIT}" == "1" ]; then
        /usr/bin/rsync ${OPTS} "${PREFIX_SRC}${DIR_TAR1}" "${PREFIX_DST}${DIR_TAR2}" | grep -vE "\.git"
    else
        /usr/bin/rsync ${OPTS} "${PREFIX_SRC}${DIR_TAR1}" "${PREFIX_DST}${DIR_TAR2}" 
    fi
    echo "/usr/bin/rsync ${OPTS} ${PREFIX_SRC}${DIR_TAR1} ${PREFIX_DST}${DIR_TAR2}"
fi

if [ "$SIMUL" == "0" -a "$Make" == "1" ]; then
    ssh $NET_USER@$Domain "cd /home/ama/adulac/workInProgress/networkofgraphs/process/pymake && make"
fi

echo ''


