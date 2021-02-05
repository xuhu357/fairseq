#!/bin/bash
# Adapted from https://github.com/facebookresearch/MIXER/blob/master/prepareData.sh


TEXT=examples/translation/ape_wmt20

fairseq-preprocess --source-lang en --target-lang de \
    --trainpref $TEXT/train --validpref $TEXT/valid --testpref $TEXT/test \
    --srcdict /home/xuhu357/fairseq/data-bin/wmt21_en_de_1218/dict.en.txt \
    --tgtdict /home/xuhu357/fairseq/data-bin/wmt21_en_de_1218/dict.de.txt \
    --destdir data-bin/ape_wmt20_1222 \
    --workers 20