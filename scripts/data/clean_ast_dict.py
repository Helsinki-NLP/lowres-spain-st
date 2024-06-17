import re

def remove_special_chars(text):
    special_chars=r"[\[\]\|\|\*0-9]"
    clean_text = re.sub(special_chars, '', text)
    return clean_text

with open("dict.ast","r",encoding="utf-8") as file:
    entries = file.read().splitlines()

clean_lines = []

for entry in entries:
    try:
        definition = entry.split(":")[1] # Remove the actual word
    except:
        definition = entry
    clean_contents = remove_special_chars(definition) # Remove special characters
    lines = clean_contents.split(".") # Split on .
    clean_lines.extend(lines)

# Deduplicate
clean_lines = set(clean_lines)

with open("dict.clean.ast","a",encoding="utf-8") as file:
    for line in clean_lines:
        if len(line.split()) > 2: # At least three words
            file.write(line.strip()+".\n")