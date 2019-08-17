
#############################################################
#Program name - Data Exploration
#input - NONE
#output - Some Exploration statistics
###############################################################
import pandas as pd

# Create data_frame of array values
df = pd.DataFrame({
    'name':['matt','lisa','richard','john','Julia','jane','marlon'],
    'age':[23,78,22,19,45,33,20],
    'gender':['M','F','M','M','M','F','M'],
    'state':['DC','CO','DE','VA','MD','DE','NY'],
    'years_of_service':[10,0,2,0,2,1,5],
    'iq':[300,100,110,200,300,10,40]
})
########################################################
# BEGIN extract a 25% sample of data
########################################################
rows = df.sample(frac =.25)
# validate first to check if sample is 0.25 times data or not
if (0.25*(len(df))== len(rows)):
    print(len(df), len(rows))

# Display Sample Percentage
print ("sample of 25% ", rows)

#END extract a 25% sample of data
############################################################
# BEGIN Split categorical variables by gender, Sum, Mean, count,
# and describe on the data
############################################################

#Categorical Variables splitting
groupby_gender = df.groupby('gender')
for gender, value in groupby_gender['iq']:
    print((gender, value.mean()))

# Find the Summation of all ages in the data
SumofAge=df['age'].sum()
print ("Sum of Ages", SumofAge)

MeanAge = df['age'].mean()
print ("Average Ages", MeanAge)
# Find the mean of all columns
print ('Means of each column', df.mean(axis=0))
# Describe the Data
print (df['iq'].describe())
