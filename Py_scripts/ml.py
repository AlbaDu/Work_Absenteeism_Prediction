#Import the required libraries
import pandas as pd
import numpy as np

def file2df(file_):
    """
    ---What it does---
        + Generates a dataframe from a .csv file.
    ---What it needs---
        + file: dataframe with columns.

    IMPORTANT! the files need to be stored in the path specified by the function.    
    ---What it returns---
        + new_df: dataframe containing the data from the file.
    """
    path = "..."
    name = str(path + file_)
    new_df = pd.read_csv(name)
    return new_df

def target(parameter, condition_):
    """
    ---What it does---
        + Generates the value of the target (0 | 1) depending on the condition value.
    ---What it needs---
        + condition: value of a parameter.   
    ---What it returns---
        + target: numerical character with value 0 or 1, that classifies the df record according to a pre-set condition.
    """
    value = np.where(parameter > condition_, 1, 0)
    return value          
   