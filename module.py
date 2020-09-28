import numpy as np
import pandas as pd
import pickle
from sklearn.preprocessing import StandardScaler
from sklearn.base import BaseEstimator, TransformerMixin

#Custom scaler 
class CustomScaler(BaseEstimator,TransformerMixin): 
    
    def __init__(self, columns, copy = True, with_mean = True, with_std = True):
        self.scaler = StandardScaler(copy, with_mean, with_std)
        self.columns = columns
        self.mean_ = None
        self.var_ = None

    def fit(self, X, y = None):
        self.scaler.fit(X[self.columns], y)
        self.mean_ = np.array(np.mean(X[self.columns]))
        self.var_ = np.array(np.var(X[self.columns]))
        return self

    def transform(self, X, y = None, copy = None):
        init_col_order = X.columns
        X_scaled = pd.DataFrame(self.scaler.transform(X[self.columns]), columns=self.columns)
        X_not_scaled = X.loc[:,~X.columns.isin(self.columns)]
        return pd.concat([X_not_scaled, X_scaled], axis = 1)[init_col_order]

#Complete process for new data (Loading + pre-processing + target generation + standardization + prediction)
class absenteeism_model():
      
        def __init__(self, model_file, scaler_file):
            #Read the "model" & "scaler" files which were saved
            with open("model_mod","rb") as model_file, open("scaler", "rb") as scaler_file:
                self.model_mod = pickle.load(model_file)
                self.scaler = pickle.load(scaler_file)
                self.data = None
        
        def load_and_clean_data(self, data_file):
            #Import data
            df = pd.read_csv(data_file, delimiter = ",")
            #Safety copy
            self.df_with_predictions = df.copy()
            #Basic df modifications
            df.drop(["ID"], axis = 1, inplace = True)
            df.rename(columns = {"Reason for Absence":"reason", "Transportation Expense":"transp exp", "Distance to work":"distance", "Daily Work Load Average":"avg work load", "Body Mass Index":"BMI", "Children":"kids"}, inplace = True)
            df.rename(str.lower, axis = 1, inplace = True)

            #Separate df for categorical features to be tranforemed with .get_dummies()
            reasons = pd.get_dummies(df["reason"], drop_first = True)
            df.drop(columns = ["reason"], axis = 1, inplace = True)

            #Split reasons into =! categories
            df["reason_1"] = reasons.loc[:, 1:14].max(axis = 1) 
            df["reason_2"] = reasons.loc[:, 15:17].max(axis = 1) 
            df["reason_3"] = reasons.loc[:, 18:21].max(axis = 1) 
            df["reason_4"] = reasons.loc[:, 22:].max(axis = 1)
      
            #Transform date into weekday and month columns and drop entry
            df["date"] = pd.to_datetime(df["date"], format = "%d/%m/%Y")
            df["weekday"] = df["date"].apply(lambda x: x.weekday())
            df["month"] = df["date"].apply(lambda x: x.month)
            df.drop(["date"], axis = 1, inplace = True)

            #Group education into 2 categories
            df["education"] = df["education"].map({1:0, 2:1, 3:1, 4:1})
            
            #Drop the unvalid categories for modified ML model
            df.drop(["avg work load", "distance to work", "pets"],axis = 1, inplace = True)
            
            #Renaming the df
            self.preprocessed_data = df.copy()
            self.data = self.scaler.transform(df)
    
        #Pprobability of a data point to be 1
        def predicted_probability(self):
            if (self.data is not None):  
                pred = self.model_mod.predict_proba(self.data)[:,1]
                return pred
        
        #Outputs a value of 0 or 1 based on our model
        def predicted_output_category(self):
            if (self.data is not None):
                pred_outputs = self.model_mod.predict(self.data)
                return pred_outputs
        
        # predict the outputs and the probabilities and 
        # add columns with these values at the end of the new data
        def predicted_outputs(self):
            if (self.data is not None):
                self.preprocessed_data["probability"] = self.model_mod.predict_proba(self.data)[:,1]
                self.preprocessed_data ["prediction"] = self.model_mod.predict(self.data)
                return self.preprocessed_data        