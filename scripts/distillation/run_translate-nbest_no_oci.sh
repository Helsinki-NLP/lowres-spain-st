# TOKENIZED
vocab="models/OPUS-MT+bibles/deu+eng+fra+por+spa-itc/opusTCv20230926max50+bt+jhubc.spm32k-spm32k.vocab.yml"
#ara_model="models/opus+bibles_ft_no_oci_bleu/model.iter55000.npz" # Score of 28.1683
ast_model="models/opus+bibles_ft_no_oci_bleu/model.iter5000.npz" # Score of 18.4862
arg_model="models/opus+bibles_ft_no_oci_bleu/model.iter10000.npz" # Score of 51.5477


sbatch scripts/distillation/translate-nbest.sh data/train/train.spa-arg.spa.tok data/distillation_no_oci/train.nmt.spa-arg.arg.nbest $arg_model $vocab
sbatch scripts/distillation/translate-nbest.sh data/train/train.spa-ast.spa.tok data/distillation_no_oci/train.nmt.spa-ast.ast.nbest $ast_model $vocab
#sbatch scripts/distillation/translate-nbest.sh data/train/train.spa-ara.spa.tok data/distillation_no_oci/train.nmt.spa-ara.ara.nbest $ara_model $vocab
