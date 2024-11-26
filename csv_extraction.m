function csv_extraction(csv,filename)
% csv_extraction(csv,filename)
    data = readcell(csv);
    urls = data(2:end,1);
    classes = categorical(data(2:end,2));
    features = data(1,3:end);

    X = cell2mat(data(2:end,3:end));
    
    save(filename,'X','features','classes','urls')
end