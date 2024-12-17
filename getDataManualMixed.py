from getData import feature_engineering_data,save_processed_data,load_processed_data

dataset = load_processed_data('urlDatasetTest.csv')

test_data = "urlDatasetTest.csv"

dataset = feature_engineering_data(dataset)
save_processed_data(dataset,test_data)

