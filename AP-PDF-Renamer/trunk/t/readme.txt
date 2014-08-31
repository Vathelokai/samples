Testing Structure

the _source folders have the test files.

When 03validate.t runs, it sets up the test environment by moving the _source files to the _in files.
Then 03validate.t executes the module and waits for a return value.
Once the testing execution is done, 03validate.t removes all the working files.
End result is that most folders are empty, but the test files are always in _source.
