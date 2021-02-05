#!/bin/bash
# Adapted from https://github.com/facebookresearch/MIXER/blob/master/prepareData.sh


#TEXT=examples/translation/wmt21_en_de

tflog_dir=tflog_ape_210204_BAL

mkdir $tflog_dir

DATA_BIN_PATH=data-bin/ape_fb_wmt19_210204

fairseq-train \
$DATA_BIN_PATH \
    --arch transformer_vaswani_wmt_en_de_big --share-decoder-input-output-embed \
    --restore-file checkpoints/wmt19.en-de.ffn8192.pt \
    --tensorboard-logdir $tflog_dir \
    --fp16 \
    --optimizer adam --adam-betas '(0.9, 0.98)' --clip-norm 0.0 \
    --reset-optimizer \
    --lr 1e-4 --lr-scheduler inverse_sqrt --warmup-updates 4000 \
    --dropout 0.3 --weight-decay 0.0001 \
    --criterion label_smoothed_cross_entropy --label-smoothing 0.1 \
    --max-tokens 3072 \
    --eval-bleu \
    --eval-bleu-args '{"beam": 5, "max_len_a": 1.2, "max_len_b": 10}' \
    --eval-bleu-detok moses \
    --eval-bleu-remove-bpe \
    --eval-bleu-print-samples \
    --best-checkpoint-metric bleu --maximize-best-checkpoint-metric \
    --keep-last-epochs 5 \
    --batch-size 32
