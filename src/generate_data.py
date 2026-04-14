import pandas as pd
import numpy as np

np.random.seed(42)

# USERS
num_users = 200
users = pd.DataFrame({
    "user_id": range(1, num_users+1),
    "signup_date": pd.date_range(start="2023-01-01", periods=num_users),
    "country": np.random.choice(["India", "USA", "UK"], num_users)
})

# TRANSACTIONS
num_txn = 3000
transactions = pd.DataFrame({
    "transaction_id": range(1, num_txn+1),
    "user_id": np.random.choice(users["user_id"], num_txn),
    "amount": np.random.randint(50, 80000, num_txn),
    "location": np.random.choice(["Delhi", "Mumbai", "Bangalore", "New York", "London"], num_txn),
    "device": np.random.choice(["Mobile", "Laptop", "Tablet"], num_txn),
    "timestamp": pd.date_range(start="2024-01-01", periods=num_txn, freq="30min")
})

# ADD FRAUD LOGIC (semi-realistic)
fraud = []

for i in range(len(transactions)):
    score = 0
    
    if transactions.loc[i, "amount"] > 50000:
        score += 1
    if transactions.loc[i, "location"] not in ["Delhi", "Mumbai"]:
        score += 1
    if transactions.loc[i, "device"] == "Tablet":
        score += 1
        
    fraud.append(1 if score >= 2 else 0)

fraud_labels = pd.DataFrame({
    "transaction_id": transactions["transaction_id"],
    "is_fraud": fraud
})

# SAVE FILES
users.to_csv("users.csv", index=False)
transactions.to_csv("transactions.csv", index=False)
fraud_labels.to_csv("fraud_labels.csv", index=False)

print("Dataset Ready ✅")