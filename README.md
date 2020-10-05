# Work_Absenteeism_Prediction
 What if you could predict the absenteeism of your workers with a Machine Learnig model?

This project has 3 parts:
 1. DATA EXPLORATION: We first look and try understand the data we have in order to be able to understand the information that the data set gives us. 
    Here we have **Absenteeism_Data.ipynb** & **eda.py**, that working together would allow us to clean and prepare the data for the ML model.
    
 2. MACHILE LEARNING: Generation of the target column, data standardization, division of the dataset into train/test subsets and creation of the appropiate ML MODEL. Here the         **Absenteeism_ML.ipynb** & **ml.py** files would construct a LogisticRegression Model for the prediction of the abstenteesim.
 
 3. DATA INTEGRATION IN SQL: Last but not least, we great a connection between Python and SQL to automatically insert the predicted outputs into a SQL database. Here the needed       files would be **Absenteeism_module.ipynb** & **module.py**

IMPORTANT INFORMATION 1: For SQL I've used MySQL.
IMPORTANT INFORMATION 2: All the data & files used and generated can be find in the **Data_and_Files** folder.
IMPORTANT INFORMATION 3: Part of the Python code, **is not correct**, since it was modified to not personal information and passwords.
