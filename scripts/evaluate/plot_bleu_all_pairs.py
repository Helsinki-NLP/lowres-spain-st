# Author: Ona de Gibert Bonet
# Datestamp: 14-12-2023
# Usage: 

import matplotlib.pyplot as plt
from datetime import datetime
import sys
import os
import re

import re

def parse_datetime(line):
    """Extracts datetime object from a log line."""
    match = re.search(r'\[(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})\]', line)
    if match:
        return datetime.strptime(match.group(1), '%Y-%m-%d %H:%M:%S')
    return None

def obtain_stages(datatrainer, trainlog):
    # Read the stages and their starting times from the datatrainer log
    stages = []
    with open(datatrainer, 'r') as f:
        for line in f:
            dt = parse_datetime(line)
            if dt and "INFO] Starting stage " in line:
                stage = line.split('] [INFO] Starting stage ')[-1].strip()
                stages.append((dt, stage))

    # Read update times from the training log
    updates = []
    with open(trainlog, 'r') as f:
        for line in f:
            if "Ep." in line:
                dt = parse_datetime(line)
                if dt:
                    update = int(re.search(r'Up\. (\d+)', line).group(1))
                    updates.append((dt, update))

    # Correlate updates to stages based on time
    update_stages = []
    current_stage = None
    for update_time, update in updates:
        # Update the current stage based on the update's timestamp
        while stages and stages[0][0] <= update_time:
            current_stage = stages.pop(0)[1]
        update_stages.append((update, current_stage))

    return update_stages

def plot_data(log_dir):
    bleu_logs = [log_dir+'/'+file for file in os.listdir(log_dir) if file.endswith(".bleu.log")]
    print(bleu_logs)
    print(log_dir)
    model_dir = os.path.dirname(log_dir)
    trainlog = model_dir+"/train.log"
    print(trainlog)
    
    epochs = [int(line) for line in open(log_dir+"/epochs.log", 'r').read().splitlines()]
    updates = [int(line) for line in open(log_dir+"/updates.log", 'r').read().splitlines()]
    plt.figure(figsize=(10, 10))
    fig, ax1 = plt.subplots()

    for log_file in bleu_logs:
        file_name = os.path.basename(log_file)
        # Split the file name and get the second part
        lang_code = file_name.split('.')[1]
        bleu=[float(line) for line in open(log_file).read().splitlines()]
        print(log_file, lang_code, len(bleu))
        ax1.plot(updates, bleu, label=lang_code)

    ax1.set_xlabel('Updates')
    ax1.set_ylabel('BLEU')
    ax1.set_title('BLEU over Model Updates')


    # Add a second axis for epochs
    ax2 = ax1.twiny()
    ax2.set_xlabel('Epochs')
    ax2.set_xticks(epochs)
    ax2.xaxis.set_label_position('bottom') # set the position of the second x-axis to bottom
    ax2.xaxis.set_ticks_position('bottom') # set the position of the second x-axis to bottom
    ax2.set_xticklabels(epochs, rotation=90)
    ax2.spines['bottom'].set_position(('outward', 40))
    ax2.set_xticklabels([str(epoch) for epoch in epochs], rotation=70)
    plt.draw()

    fig.legend(loc='center right')
   
    plt.grid(True)
    plt.savefig(log_dir+'/bleu_all_pairs.png', bbox_inches='tight', pad_inches=0.02, dpi=150)
    #fig.savefig(log_basename+'.png')  # Provide the desired path and filename

log_dir = sys.argv[1]
plot_data(log_dir)


