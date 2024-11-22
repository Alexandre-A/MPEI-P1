import pandas as pd


def data_init(source,output_file,percentage = 1):
    dataset = pd.read_csv(source)
    #print(dataset["type"].unique())


    # Adjusting the overall dataset to our needs
    dataset = dataset.dropna() #remove rows with null values
    rem = {"type": {"defacement":"malign","phishing":"malign","malware":"malign"}}
    dataset = dataset.replace(rem)
    
    #print(dataset["type"].unique())

    if percentage < 1.0:
        dataset = dataset.sample(frac=percentage, random_state=1)
    dataset.info()
    save_processed_data(dataset,output_file)    

    print(f"The processed dataset has been saved as '{output_file}'.")


def load_processed_data(csv_file):
    dataset = pd.read_csv(csv_file)
    return dataset

def save_processed_data(dataset,csv_file):
    dataset.to_csv(csv_file, index=False)

#-----------------------------------------------------#
source = "original_malicious_phish.csv"
final_data = "urlDataset.csv"

#Uncomment if needed to load to the device or change initial dataset
#data_init(source,final_data)

#Uncoment if needed to change portion of the initial dataset used
#percentage = 0.5
#data_init(source,final_data,percentage)

data = load_processed_data(final_data)
