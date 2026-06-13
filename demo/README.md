# Demo App

A minimal Streamlit app that queries Snowflake sample data to chart order revenue by status.

## Run locally

```bash
pip install -r requirements.txt
streamlit run app.py
```

Requires a `default` Snowflake connection configured in `~/.snowflake/connections.toml`.
