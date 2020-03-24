# Functions

## Failover
```json
"TraceFlags": [3226,7412]
```

Compares global trace flags against a list of trace flags, and reports on the number of discrepancies (trace flags in config but not on the server, or on the server but not in config.)

The example above checks for 3226 (suppress backup messages in the SQL Error log) and 7412 (lightweight query profiling).

