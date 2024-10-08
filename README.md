# Shared task: Translation into Low-Resource Languages of Spain

This repository contains our participation to the [WMT 2024 Shared Task of Translation into Low-Resource languages of Spain](https://www2.statmt.org/wmt24/romance-task.html). The task consists in developing Machine Translation (MT) systems to translate from Spanish into Aragonese, Aranese and Asturian

Our submission consists of 4 submissions covering all language pairs with multilingual systems.

This table shows a summary of our submissions:

| Submission #  | Method        | BLEU-arg   | BLEU-arn   | BLEU-ast   | Params (M) | Size (MB) | Speed (s) |
|---------------|---------------|-------|-------|-------|-------|------------|-----------|
| Submission 1  | Fine-tuning   | 55.94 | 28.35 | 18.55 | 222.9 | 851        | 852.22    |
| Submission 2  | Distillation  | 54.24 | 28.19 | 18.53 | 67.5  | 258        | 361.33    |
| Submission 3  | Distillation  | 52.86 | 27.15 | 18.23 | 20.4  | 78         | 4.06      |
| Submission 4  | Distillation  | 56.99 | 30.19 | 18.50 | 67.5  | 258        | 891.76    |

*Table 1: Summary of our submissions. BLEU refers to the BLEU score obtained by the best ensemble on the development set; Speed refers to the averaged decoding speed for submission across language pairs on one single AMD MI250x GPU.*


## Code

All our code is in the `scripts` folder.

## Training data

The already preprocessed and filtered training data can be safely downloaded from this link: https://a3s.fi/degibert-2001194-pub/lowres-spain-data.zip

The password is "Helsinki-NLP".

## Models

We release our fastest model from Submission 3. It can be safely downloaded from this link: https://object.pouta.csc.fi/degibert/lowres_sub_3.zip

## Citation

Coming soon!
