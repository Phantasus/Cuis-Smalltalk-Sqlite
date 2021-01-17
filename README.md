# Cuis Smalltalk SQLite Adapter

This package provides a common interface to the SQLite3
file based SQL database. It's based on previous work done
for Squeak (the SQLite3 package).

# Getting started

```smalltalk
client := SQLiteClient newFrom: { #filename -> 'my.db' } asDictionary.
client executeQuery: 'CREATE TABLE foo(id integer);'.
```

# Status

Experimental, tests pass. Will be redesigned, your code will certainly
be in danger and no guarantees

# License

MIT License

# Authors

- Josef Philip Bernhart (jpb)
- Previous authors of the original Squeak implementation (See AUTHORS.md)
