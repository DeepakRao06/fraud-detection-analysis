import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score
from sklearn.metrics import confusion_matrix
from sklearn.metrics import classification_report


transactions = pd.read_csv("data/transactions.csv")
users = pd.read_csv("data/users.csv")
fraud_labels = pd.read_csv("data/fraud_labels.csv")
# print(fraud_labels)
print(transactions.head())
print(transactions.info())

df = transactions.merge(users,on="user_id",how="left")
df = df.merge(fraud_labels,on="transaction_id",how="left")

# print(df.info())
# print(df["is_fraud"].value_counts())
# print(df.dtypes)
df["timestamp"] = pd.to_datetime(df["timestamp"])
# print(df["timestamp"].dtype)
df = df.sort_values(by=["user_id","timestamp"])

df["prev_time"] = df.groupby("user_id")["timestamp"].shift(1)
df["prev_location"] = df.groupby("user_id")["location"].shift(1)
df["time_gap"] = (df["timestamp"] - df["prev_time"]).dt.total_seconds()/60
df["avg_amount"] = df["amount"].mean()
df["hour"] = df["timestamp"].dt.hour
df["location_changed"] = np.where(df["prev_location"] != df["location"],1,0)
df["night"] = np.where(df["hour"].between(0,5),1,0)
# print(df["night"])
print(df.info())


df["risk score"] = (
   (df["amount"]> df["avg_amount"])*2 +
   (df["time_gap"] < 60)* 2 +
   (df["location_changed"] )*1 +
   (df["night"])*1
)
df = df.dropna()
print(df.isnull().sum())
# print(df["risk score"])

x = df[["amount","time_gap","location_changed","night","risk score"]]
y = df["is_fraud"]

x_train,x_test,y_train,y_test =train_test_split(x,y,test_size=0.2,random_state=42)
model = LogisticRegression()
model.fit(x_train,y_train)
y_pred = model.predict(x_test)
y_prob =model.predict_proba(x_test)[:,1]
y_pred = (y_prob > 0.4).astype(int)
print(accuracy_score(y_test,y_pred))
print(confusion_matrix,y_pred)
print("Report:\n",classification_report(y_test,y_pred))