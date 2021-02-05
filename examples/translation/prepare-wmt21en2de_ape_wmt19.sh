#!/bin/bash
# Adapted from https://github.com/facebookresearch/MIXER/blob/master/prepareData.sh

echo 'Cloning Moses github repository (for tokenization scripts)...'
git clone https://github.com/moses-smt/mosesdecoder.git

echo 'Cloning Subword NMT repository (for BPE pre-processing)...'
git clone https://github.com/rsennrich/subword-nmt.git

echo 'Cloning FASTBPE repository'
git clone https://github.com/glample/fastBPE.git
# Follow compilation instructions at https://github.com/glample/fastBPE
g++ -std=c++11 -pthread -O3 fastBPE/fastBPE/main.cc -IfastBPE -o fastBPE/fastBPE/fast



SCRIPTS=mosesdecoder/scripts
TOKENIZER=$SCRIPTS/tokenizer/tokenizer.perl
CLEAN=$SCRIPTS/training/clean-corpus-n.perl
NORM_PUNC=$SCRIPTS/tokenizer/normalize-punctuation.perl
REM_NON_PRINT_CHAR=$SCRIPTS/tokenizer/remove-non-printing-char.perl
BPEROOT=subword-nmt/subword_nmt

FASTBPE=fastBPE/fastBPE


# hu.xu modified
CORPORA=(
    "train"
    "valid"

)

CORPORA_TEST=(
    "test"
)


# hu.xu added, if OUTDIR exists then remove first
OUTDIR=ape_fb_wmt19
BPE_CODES_PATH=/home/xuhu357/fairseq/wmt19_dir/wmt19.en-de.joined-dict.ensemble/bpecodes

rm -rf $OUTDIR

if [ ! -d "$SCRIPTS" ]; then
    echo "Please set SCRIPTS variable correctly to point to Moses scripts."
    exit
fi


src=en
tgt=de

lang=en-de
prep=$OUTDIR
tmp=$prep/tmp
orig=orig_ape_wmt20

mkdir -p $orig $tmp $prep

ext_src=src
ext_mt=mt
ext_mt_ext=mt_ext
ext_pe=pe


echo "[pre-processing train data...]"
for f in "${CORPORA[@]}"; do
    for l in $ext_mt $ext_mt_ext $ext_pe; do
        rm $tmp/$f.$l.tok
        echo "[pre-processing] ${f} start!"
        cat $orig/$lang/$f.$l | \
            perl $NORM_PUNC $l | \
            perl $REM_NON_PRINT_CHAR | \
            perl $TOKENIZER -threads 8 -a -l $tgt > $tmp/$f.$l.tok
    done
done

for f in "${CORPORA[@]}"; do
    for l in $ext_src; do
        rm $tmp/$f.$l.tok
        cat $orig/$lang/$f.$l | \
            perl $NORM_PUNC $l | \
            perl $REM_NON_PRINT_CHAR | \
            perl $TOKENIZER -threads 8 -a -l $src > $tmp/$f.$l.tok
    done
done

echo "[pre-processing test data...]"
for f in "${CORPORA_TEST[@]}"; do
    for l in $ext_mt $ext_mt_ext $ext_pe; do
        rm $tmp/$f.$l.tok
        echo "[pre-processing] ${f} start!"
        cat $orig/$lang/$f.$l | \
            perl $NORM_PUNC $l | \
            perl $REM_NON_PRINT_CHAR | \
            perl $TOKENIZER -threads 8 -a -l $tgt > $tmp/$f.$l.tok
    done
done

for f in "${CORPORA_TEST[@]}"; do
    for l in $ext_src; do
        rm $tmp/$f.$l.tok
        cat $orig/$lang/$f.$l | \
            perl $NORM_PUNC $l | \
            perl $REM_NON_PRINT_CHAR | \
            perl $TOKENIZER -threads 8 -a -l $src > $tmp/$f.$l.tok
    done
done

# concat .src.tok, .mt.tok, .mt_ext.tok file to $file.$source
echo "[join source files with < s >] !!!"
for f in "${CORPORA[@]}"; do
    pr -tmJ -S" < s > " $tmp/$f.$ext_src.tok $tmp/$f.$ext_mt.tok $tmp/$f.$ext_mt_ext.tok > $tmp/$f.$src
    mv $tmp/$f.$ext_pe.tok $tmp/$f.$tgt
done


# concat .src.tok, .mt.tok, .mt_ext.tok file to $file.$source
echo "[join target files with < s >] !!!"
for f in "${CORPORA_TEST[@]}"; do
    pr -tmJ -S" < s > " $tmp/$f.$ext_src.tok $tmp/$f.$ext_mt.tok $tmp/$f.$ext_mt_ext.tok > $tmp/$f.$src
    mv $tmp/$f.$ext_pe.tok $tmp/$f.$tgt
done




# start to apply bpe codes
echo "[Apply fastBPE CODES] start !!!"
for L in $src $tgt; do
    for f in train.$L valid.$L test.$L; do
        echo "apply fastbpe to ${f}..."
#        python $BPEROOT/apply_bpe.py -c $BPE_CODES_PATH < $tmp/$f > $prep/$f
        # fastBPE usage: fast applyble {outputfile} {inputfile} {bpe_codes}
        ${FASTBPE}/fast applybpe $prep/$f $tmp/$f $BPE_CODES_PATH
    done
done

#${FASTBPE}/fast applybpe data_dir/bpe.$test.$s-$t.$s data_dir/$test.$s-$t.$s ${src_bpe_code}
#${FASTBPE}/fast applybpe data_dir/bpe.$test.$s-$t.$s data_dir/$test.$s-$t.$s ${tgt_bpe_code}
