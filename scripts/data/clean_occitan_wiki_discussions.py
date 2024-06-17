from sentence_splitter import split_text_into_sentences

path = "data/oci/mono/OcWikiDisc_v1.0/ocwikidisc_precision.csv"
outfile = "data/oci/mono/wiki_discussions.oci"

file = open(path, "r").read().splitlines()

all_content = []

for line in file:
    try:
        parts = line.split("\t")
        message = parts[1]
        discussion_title = parts[3]
        thread_title = parts[4]
        content = [message, discussion_title, thread_title]
        split_content = [split_text_into_sentences(text=paragraph, language='es') for paragraph in content]
    
        # Flatten the list of lists
        flattened_split_content = [sentence for sublist in split_content for sentence in sublist]
        all_content.extend(flattened_split_content)
    except:
        continue

content_dedup = set(all_content)

with open(outfile,"w",encoding="utf-8") as file:
    for line in content_dedup:
        if len(line.split()) > 2: # At least three words
            file.write(line+"\n")
