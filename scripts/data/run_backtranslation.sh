#!/bin/bash
sbatch scripts/backtranslate_monolingual.sh data/arg/mono/literary.txt data/arg/synt/literary.spa
sbatch scripts/backtranslate_monolingual.sh data/arg/mono/crawled.txt data/arg/synt/crawled.spa
sbatch scripts/backtranslate_monolingual.sh data/ast/mono/literary.txt data/ast/synt/literary.spa
sbatch scripts/backtranslate_monolingual.sh data/ast/mono/crawled.txt data/ast/synt/crawled.spa
sbatch scripts/backtranslate_monolingual.sh data/oci/mono/literary.txt data/oci/synt/literary.spa
sbatch scripts/backtranslate_monolingual.sh data/oci/mono/crawled.txt data/oci/synt/crawled.spa
sbatch scripts/backtranslate_monolingual.sh data/ast/mono/dict.ast data/ast/synt/dict.spa
sbatch scripts/backtranslate_monolingual.sh data/oci/mono/dict.oci data/oci/synt/dict.spa
sbatch scripts/backtranslate_monolingual.sh data/oci/mono/wikipedia.oci data/oci/synt/wikipedia.spa
sbatch scripts/backtranslate_monolingual.sh data/ast/mono/wikipedia.ast data/ast/synt/wikipedia.spa
sbatch scripts/backtranslate_monolingual.sh data/arg/mono/wikipedia.arg data/arg/synt/wikipedia.spa
sbatch scripts/backtranslate_monolingual.sh data/oci/mono/wikipedia.oci_ca-oc data/oci/synt/wikipedia_ca-oc.spa
sbatch scripts/backtranslate_monolingual.sh data/oci/mono/wiki_discussions.oci data/oci/synt/wiki_discussions.spa
sbatch scripts/backtranslate_monolingual.sh data/oci/parallel/pilar.filtered.cat data/oci/synt/pilar.filtered.spa
sbatch scripts/backtranslate_monolingual.sh data/ast/mono/wikipedia.ast_es-as data/ast/synt/wikipedia_es-as.spa
sbatch scripts/backtranslate_monolingual.sh data/oci/mono/wikipedia_docpairs.oci data/oci/synt/wikipedia_docpairs.spa
