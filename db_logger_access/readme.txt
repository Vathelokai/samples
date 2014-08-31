This set of VBA modules for MS Access DB sets up a logging system.  Functions and Subs in Access can use these to log their status.

The setup requires a separate _logs.accdb database to exist, and any Access DB that needs logging can import these and link a table to the _logs database.  Functions and Subs which want to log have to copy some boilerplate and beging using the function

	makeLogResult = makeLogs("database_name", "macro_name", "eventType", "detailLevel", Err.Number, Err.Description, "some comments")

