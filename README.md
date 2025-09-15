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
```latex
@inproceedings{de-gibert-etal-2024-hybrid,
    title = "Hybrid Distillation from {RBMT} and {NMT}: {H}elsinki-{NLP}{'}s Submission to the Shared Task on Translation into Low-Resource Languages of {S}pain",
    author = {De Gibert, Ona  and
      Aulamo, Mikko  and
      Scherrer, Yves  and
      Tiedemann, J{\"o}rg},
    editor = "Haddow, Barry  and
      Kocmi, Tom  and
      Koehn, Philipp  and
      Monz, Christof",
    booktitle = "Proceedings of the Ninth Conference on Machine Translation",
    month = nov,
    year = "2024",
    address = "Miami, Florida, USA",
    publisher = "Association for Computational Linguistics",
    url = "https://aclanthology.org/2024.wmt-1.88/",
    doi = "10.18653/v1/2024.wmt-1.88",
    pages = "908--917",
    abstract = "The Helsinki-NLP team participated in the 2024 Shared Task on Translation into Low-Resource languages of Spain with four multilingual systems covering all language pairs. The task consists in developing Machine Translation (MT) models to translate from Spanish into Aragonese, Aranese and Asturian. Our models leverage known approaches for multilingual MT, namely, data filtering, fine-tuning, data tagging, and distillation. We use distillation to merge the knowledge from neural and rule-based systems and explore the trade-offs between translation quality and computational efficiency. We demonstrate that our distilled models can achieve competitive results while significantly reducing computational costs. Our best models ranked 4th, 5th, and 2nd in the open submission track for Spanish{--}Aragonese, Spanish{--}Aranese, and Spanish{--}Asturian, respectively. We release our code and data publicly at https://github.com/Helsinki-NLP/lowres-spain-st."
}
```
