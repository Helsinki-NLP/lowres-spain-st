import re
import pandas as pd
from sentence_splitter import split_text_into_sentences

def remove_special_chars(text):
    hrefs="<[^><]*>"
    acronyms = "|".join(["Ex.:","Ex:", "Fig.:","Pronominau:","Sin.:","Sin:","Toponims:","Var.:"])
    special_chars = r"|".join([hrefs,acronyms])
    clean_text = re.sub(special_chars, '', text)
    cleaner_text = re.sub(' +', ' ',clean_text)
    return cleaner_text

file = "data/oci/mono/dict_raw.oci"

df = pd.read_csv(file, sep='\t',header=None)
entries = df[1].tolist()

clean_definitions = []

count=0
for entry in entries:
    # Split into each sense
    try:
        definitions = entry.split("</li><li>")
    except:
        definitions = entry
    # Split further the examples
    for definition in definitions:
        clean_def = remove_special_chars(definition)
        split_def = split_text_into_sentences(text=clean_def,language='es')
        clean_definitions.extend(split_def)
    if count%10 == 0:
        print(f"Processed {count} entries")
    count+=1

print("Clean sentences:", len(clean_definitions))

# Deduplicate
dedup_definitions = set(clean_definitions)

print("Deduplicated sentences:", len(dedup_definitions))


with open("data/oci/mono/dict.oci","w",encoding="utf-8") as file:
    for line in dedup_definitions:
        if len(line.split()) > 2: # At least three words
            file.write(line+"\n")