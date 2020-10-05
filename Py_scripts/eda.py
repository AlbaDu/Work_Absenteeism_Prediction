#Import the required libraries
import pandas as pd
import numpy as np


def file2df(file_):
    """
    ---What it does---
        + Generates a dataframe from a files: ".csv", ".xlsx" or ".xls".
    ---What it needs---
        + file: dataframe with columns.

    IMPORTANT! the files need to be stored in the path specified by the function.    
    ---What it returns---
        + new_df: dataframe containing the data from the file.
    """
    path = "..."
    
    if file_.endswith("csv"):
        name = str(path + file_)
        new_df = pd.read_csv(name)
        return new_df
    elif file_.endswith("xlsx") or file_.endswith("xls"): 
        name = str(path + file_)
        new_df = pd.read_excel(name)
        return new_df

def date2weekday(date):
    """
    ---What it does---
        + Gives the weekday corresponding with a certain date.
    ---What it needs---
        + A date entry with datetime type.
    ---What it returns---
        + A value from 0 to 6, corresponding to the weekdays from Monday to Sunday.
    """
    return date.weekday()

def date2month(date):
    """
    ---What it does---
        + Gives the month corresponding with a certain date.
    ---What it needs---
        + A date entry with datetime type.
    ---What it returns---
        + A value from 0 to 12, corresponding to the months from January to December.
    """
    return date.month


def df2file(df_):
    """
    ---What it does---
        + Generates a .csv file from a df.
    ---What it needs---
        + df: containing data in rows and columns. 
    IMPORTANT! the files would be stored in the path specified by the function and the name should be given WITHOUT the .csv extension.
    """
    name = input("Name of the file WITHOUT .csv")
    path = str("...\\Work_Absenteeism_Prediction\\Data_and_files\\" + name + ".csv")
    df_.to_csv(path, index = False)
