#!/bin/bash
# Adapted from https://github.com/facebookresearch/MIXER/blob/master/prepareData.sh


TEXT=examples/translation/ape_fb_wmt19_no_mt_ext

DICT_PATH=/home/xuhu357/fairseq/wmt19_dir/wmt19.en-de.joined-dict.ensemble
DATA_BIN_PATH=data-bin/ape_fb_wmt19_210205_no_mt_ext

fairseq-preprocess --source-lang en --target-lang de \
    --trainpref $TEXT/train --validpref $TEXT/valid --testpref $TEXT/test \
    --srcdict $DICT_PATH/dict.en.txt \
    --tgtdict $DICT_PATH/dict.de.txt \
    --destdir $DATA_BIN_PATH \
    --workers 20
