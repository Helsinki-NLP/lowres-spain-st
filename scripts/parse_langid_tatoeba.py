import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# Function to read and process data
def read_and_process_data(lang):
    id_path = f"data/{lang}/parallel/tatoeba.id"
    langid_path = f"data/{lang}/parallel/tatoeba.{lang}.lid"

    ids = pd.read_csv(id_path, sep="\t", header=None)
    langs = pd.read_csv(langid_path, sep="\t", header=None)

    id_lang = pd.concat([ids[0], langs[1]], axis=1)
    id_lang.columns = ['Corpus', 'Language']
    
    return id_lang

# Function to plot data
def plot_language_distribution(df, colors, filename):
    corpus_language_distribution = df.groupby(['Corpus', 'Language']).size().unstack(fill_value=0)
    corpus_language_distribution_percent = corpus_language_distribution.div(corpus_language_distribution.sum(axis=1), axis=0) * 100

    ax = corpus_language_distribution_percent.plot(kind='barh', stacked=True, color=colors)

    plt.xlabel('Percentage')
    plt.ylabel('Corpus')
    plt.title('Distribution of Languages in Each Corpus')
    plt.legend(title='Language', bbox_to_anchor=(1.05, 1), loc='upper left')
    
    # Add percentage labels
    for container in ax.containers:
        labels = [f'{v:.1f}%' if v > 10 else '' for v in container.datavalues]
        ax.bar_label(container, labels=labels, label_type='center', fmt='%.1f%%', fontsize=10)
    
    plt.savefig(filename, bbox_inches='tight')

# Get colors from seaborn's pastel1 palette
colors = sns.color_palette('pastel')

# Process and plot for each language
languages = ["ast", "arg", "oci"] 
for lang in languages:
    df = read_and_process_data(lang)
    plot_language_distribution(df, colors, f"plots/language_distribution_tatoeba_{lang}.png")
