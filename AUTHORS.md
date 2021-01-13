# Authors

This file contains the list of authors who contributed indirectly or directly
to some parts of the packages. The contained code fragments were taken from
projects which all release using an MIT License.

# Previous work by Milan Vavra and others  (SQLite3 for Squeak)

It was taken from Smalltalk Hub on 13. January 2021, as
visible in the screenshot the project is supposed to be under
MIT License. This code was used as base for further porting efforts.

The sha256sums of these files are:
> 43b683e2796625aed39ec3dd096ea8d8b2a342a8fc3ab32b838aeb1340ae2724  references/Screenshot_2021-01-13 MilanVavra SQLite3 - SmalltalkHub.png
> 8489da4b935fdd05da208d38b2d11e06f284e25a9cb24096e4d5551e886fbf35  references/SQLite3.mva-squeak5.0-rel1.0-2017_02_12.1.mcz

Additional authors were extracted with the command:
> grep 'methodsFor:.*stamp:' ../cuis-package.st | sed "s/^.*stamp: '([^ ]*) [^']+'.*$/\1/g" -E | sort | uniq

And the authors are
- Alexandre Bergel (ab)
- Andreas Raab (ar)
- Claes-Fredrik Mannby (cf)
- Milan Vavra (mva)
- Sean DeNigris (spd)
- Torsten Bergmann (tbn)
