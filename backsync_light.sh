#!/bin/bash

#SSH='dtrckd@lala'
D="Papiers"
last_arg="${@: -1}"

if [ -d "$last_arg" ]; then
    D="$last_arg"
fi

IN="./$D/"
OUT="/media/dtrckd/TOSHIBA EXT/$D/"

SIMUL="-n"
OPTS="--update --no-o --no-g --no-p  --modify-window=1 --iconv=iso-8859-1,utf8"
OPTS="$OPTS --delete-after -O"

### hack ###
OPTS="$OPTS --size-only"
###########

if [ "$1" == "-f" ]; then
    SIMUL=""
elif [ "$1" == "-h" ]; then
    echo "backsync [-f (force)] [Target Directory ($D]"
    exit 1
fi
    

#rsync $SIMUL  -av -u --modify-window=2 --stats -m $OPTS \
rsync $SIMUL -avh  $OPTS --stats -m -s \
    $IN "$OUT"

echo "rsync $SIMUL -avh  $OPTS --stats -m -s \
         $IN "$OUT""


###
#rsync --dry-run  -av -u --modify-window=2  --stats --prune-empty-dirs  -e ssh --include '*/'  --include='debug/***' --exclude='*'  ./ dtrcks@pit:/home/dtrckd/ddebug
#rsync --dry-run  -av -u --modify-window=2 --stats --prune-empty-dirs  -e ssh    dtrckd@racer:/home/m/dtrckd/workInProgress/networkofgraphs/process/PyNPB/data/networks/ ./


