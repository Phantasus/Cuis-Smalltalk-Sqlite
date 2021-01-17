# Project journal

This file is intended to record the history of this project. So that
when it get's abandoned people can take it up again from where it was
left off. The rule of the structure is that newest is at top, oldest
entry is at the bottom. And people mention the author of the entry
by his shortcut. Also people add their shortcuts to the list of
authors at the end of the file.

# 17. January 2021 (jpb)

I fixed the "FFI coercion issues" which occured by my initial
adaptations to the existing previous Sqlite3 Squeak implementation
base to make it fit to Cuis. As I used `DirectoryEntry` for
finding the database filepath which returned `aDirectoryEntry` and
not a String, which in turn caused the error.

Still the tests are not yet passing as the image crashes. I think
some tests are needed to make the library segfault proof, as
users don't want that just by using this library the system now
is fragile.

I fixed the segmentation fault, which was caused by an incorrect
dereference of the `char ***pazResult` address stored in a `SqliteResultBuffer`.
It was still in the mind written, that we are all running on 32-bit architectures.
So I replace it with code which should be more portable as it depends on the size
of an `ExternalAddress` object, it's written under assumption that an array of
char pointers have each the same size of an external address.

All tests pass now.


# Authors

- Josef Philip Bernhart (jpb)
