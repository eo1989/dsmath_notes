import duckdb as db

conn = db.connect("my_duckdb_db.db")

"""
alternatively, creates an *in-memory* copy of the database by passing the `:memory:`
argument to the connect() function.
"""
# conn = db.connect(':memory:')

# create a table
conn.execute("""
    CREATE TABLE employees (
        id INTEGER PRIMARY KEY,
        name VARCHAR,
        age INTEGER,
        department VARCHAR
        )
    """)

# to verify the table is created correctly, use the `SHOW TABLES` statement
conn.execute("SHOW TABLES").df()
