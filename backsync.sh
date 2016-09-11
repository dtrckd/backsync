#!/bin/bash

#SSH='dtrckd@lala'

IN="./"
OUT="/media/joker/TOSHIBA EXT/SC/Projets/"

SIMUL="-n"
OPTS="--update --no-o --no-g --no-p  --modify-window=1"
OPTS="$OPTS --delete-after -O"

if [ "$1" == "-f" ]; then
    SIMUL=""; fi

#rsync $SIMUL  -av -u --modify-window=2 --stats -m $OPTS \
rsync $SIMUL -avh  $OPTS --stats -m -s \
    $IN "$OUT"


###
#rsync --dry-run  -av -u --modify-window=2  --stats --prune-empty-dirs  -e ssh --include '*/'  --include='debug/***' --exclude='*'  ./ dtrcks@pit:/home/dtrckd/ddebug
#rsync --dry-run  -av -u --modify-window=2 --stats --prune-empty-dirs  -e ssh    dtrckd@racer:/home/m/dtrckd/workInProgress/networkofgraphs/process/PyNPB/data/networks/ ./


