from constants import data_folder


#returns data -- time,X,Y,Z
def get_data(file_name):
    inputfile = open(data_folder + file_name, "r+")
    data = []
    for i in range(3):
        inputfile.readline()  # use next() if 2.7. Skip the first few samples
    for line in inputfile:
        splits = line.split(",")
        data.append((float(splits[0]),float(splits[1]), float(splits[2]), float(splits[3])))
    return data 


# print get_data("test.csv")
