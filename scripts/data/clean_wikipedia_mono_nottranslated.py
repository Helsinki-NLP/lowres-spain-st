from sentence_splitter import split_text_into_sentences
import sys

lang = sys.argv[1]

print(f"Processing {lang}...")
print(f"Extracting file...")
#file=open(f"data/wikipedia/mono_nottranslated/{lang}.txt",'r')
file=open(f"data/wikipedia/parallel_aligned/{lang}.txt",'r')
print(f"Reading file...")
content=file.read().splitlines()
print(f"File read!")
print(f"Found entries:",len(content))
print(f"Splitting file into lines...")
split_content = []
count=0
for entry in content:
    entry_split = split_text_into_sentences(text=entry,language='es')
    split_content.extend(entry_split)
    if count%10 == 0:
        print(f"Processed {count} entries")
    count+=1

print(f"File split!")
print(f"De-duplicating file...")
clean_dedup = set(split_content)
print(f"File de-duplicated!\n")
print(f"Saving file...")
with open(f"data/{lang}/mono/wikipedia.{lang}","a",encoding="utf-8") as file:
    for line in clean_dedup:
        if len(line.split()) > 2: # At least three words
            file.write(line+"\n")
print(f"File saved!")