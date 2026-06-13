import streamlit as st
import snowflake.connector
import pandas as pd

conn = snowflake.connector.connect(connection_name="default")
df = pd.read_sql("""
    SELECT O_ORDERSTATUS,
           SUM(O_TOTALPRICE_USD) AS revenue   -- BUG: wrong column name
    FROM SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.ORDERS
    GROUP BY O_ORDERSTATUS ORDER BY revenue DESC
""", conn)
st.title("Order Revenue by Status")
st.bar_chart(df.set_index("O_ORDERSTATUS"))
conn.close()
