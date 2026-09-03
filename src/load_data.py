import pandas as pd
from sqlalchemy import create_engine
from dotenv import load_dotenv
import os

load_dotenv()

engine = create_engine(
    f"postgresql+psycopg://{os.getenv('DB_USER')}:{os.getenv('DB_PASSWORD')}"
    f"@{os.getenv('DB_HOST')}:{os.getenv('DB_PORT')}/{os.getenv('DB_NAME')}"
)

file_path = "data/raw/train_transaction.csv"

print("Reading CSV...")

df = pd.read_csv(
    file_path,
    low_memory=False
)

print(f"CSV loaded: {df.shape}")

print("Uploading to PostgreSQL...")

df.to_sql(
    "train_transactions",
    engine,
    if_exists="replace",
    index=False,
    chunksize=5000
)

print("train_transactions table created successfully!")