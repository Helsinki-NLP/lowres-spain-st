from sentence_splitter import split_text_into_sentences
import sys
import os

lang = sys.argv[1]

print(f"Processing {lang}...")
dir=f"data/wikipedia/parallel_docpairs/ca-{lang}/"

files = os.listdir(dir) 

for filename in files:
    file = open(dir+filename,"r",encoding="utf-8")
    content=file.read().splitlines()
    split_content = []
    for entry in content:
        entry_split = split_text_into_sentences(text=entry,language='es')
        split_content.extend(entry_split)
    
    clean_dedup = set(split_content)

    fileout=dir+filename.replace(".txt",".split.txt")
    with open(fileout,"w",encoding="utf-8") as file:
        for line in clean_dedup:
            if len(line.split()) > 2: # At least three words
                file.write(line+"\n")
    print(f"File {filename} processed!")