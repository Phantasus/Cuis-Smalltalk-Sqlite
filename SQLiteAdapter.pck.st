'From Cuis 5.0 [latest update: #4520] on 17 January 2021 at 12:25:57 pm'!
'Description Cuis SQLite3 adapter for the SQLite3 file/in-memory database

License: MIT
Author: Josef Philip Berhart
Authors of the Squeak version: Milan Vavra and others, see AUTHORS.md'!
!provides: 'SQLiteAdapter' 1 12!
!requires: 'FFI' 1 33 nil!
SystemOrganization addCategory: 'SQLiteAdapter'!
SystemOrganization addCategory: 'SQLiteAdapter-Tests'!


!classDefinition: #SQLiteRecord category: 'SQLiteAdapter'!
Dictionary subclass: #SQLiteRecord
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'SQLiteAdapter'!
!classDefinition: 'SQLiteRecord class' category: 'SQLiteAdapter'!
SQLiteRecord class
	instanceVariableNames: ''!

!classDefinition: #SQLiteIntegrationTest category: 'SQLiteAdapter-Tests'!
TestCase subclass: #SQLiteIntegrationTest
	instanceVariableNames: 'db usedClass'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'SQLiteAdapter-Tests'!
!classDefinition: 'SQLiteIntegrationTest class' category: 'SQLiteAdapter-Tests'!
SQLiteIntegrationTest class
	instanceVariableNames: ''!

!classDefinition: #Sqlite3Library category: 'SQLiteAdapter'!
ExternalLibrary subclass: #Sqlite3Library
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'SQLiteAdapter'!
!classDefinition: 'Sqlite3Library class' category: 'SQLiteAdapter'!
Sqlite3Library class
	instanceVariableNames: 'default'!

!classDefinition: #SqliteError category: 'SQLiteAdapter'!
ExternalStructure subclass: #SqliteError
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'SQLiteAdapter'!
!classDefinition: 'SqliteError class' category: 'SQLiteAdapter'!
SqliteError class
	instanceVariableNames: ''!

!classDefinition: #SqliteReference category: 'SQLiteAdapter'!
ExternalStructure subclass: #SqliteReference
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'SQLiteAdapter'!
!classDefinition: 'SqliteReference class' category: 'SQLiteAdapter'!
SqliteReference class
	instanceVariableNames: ''!

!classDefinition: #SqliteResultBuffer category: 'SQLiteAdapter'!
ExternalStructure subclass: #SqliteResultBuffer
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'SQLiteAdapter'!
!classDefinition: 'SqliteResultBuffer class' category: 'SQLiteAdapter'!
SqliteResultBuffer class
	instanceVariableNames: ''!

!classDefinition: #SQLiteClient category: 'SQLiteAdapter'!
Object subclass: #SQLiteClient
	instanceVariableNames: 'reference fileName txn'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'SQLiteAdapter'!
!classDefinition: 'SQLiteClient class' category: 'SQLiteAdapter'!
SQLiteClient class
	instanceVariableNames: 'registry'!

!classDefinition: #SqliteResult category: 'SQLiteAdapter'!
Object subclass: #SqliteResult
	instanceVariableNames: 'buffer rows columns columnNames index'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'SQLiteAdapter'!
!classDefinition: 'SqliteResult class' category: 'SQLiteAdapter'!
SqliteResult class
	instanceVariableNames: ''!


!SQLiteClient commentStamp: 'spd 5/19/2010 14:50' prior: 0!
I connect to sqlite3 databases.

To create an in-memory database, set the fileName to ':memory:'.  See "http://www.sqlite.org/c3ref/open.html" for more info.!

!SQLiteRecord methodsFor: 'accessing' stamp: 'ar 12/9/2011 19:19'!
doesNotUnderstand: aMessage
	"Allow read access with common selector names"
	^self at: aMessage selector ifAbsent:[super doesNotUnderstand: aMessage].! !

!SQLiteRecord methodsFor: 'initialize' stamp: 'ar 12/9/2011 19:20'!
names: names values: values
	names with: values do:[:n :v| self at: n put: v].
! !

!SQLiteRecord class methodsFor: 'as yet unclassified' stamp: 'ar 12/9/2011 19:19'!
names: names values: values
	^self new names: names values: values! !

!SQLiteIntegrationTest methodsFor: 'running' stamp: 'jpb 1/16/2021 22:15:25'!
databaseFileName
	"Macs (tested OS X 6.2) require absolute file paths to the database, Windows and Ubuntu do not"
	
	^ (DirectoryEntry currentDirectory / self databaseName) asString asFileEntry.! !

!SQLiteIntegrationTest methodsFor: 'running' stamp: 'jpb 1/17/2021 12:24:22'!
setUp
	| settings |
	super setUp.
	
	usedClass _ SQLiteClient.
	settings _ {
		#filename -> self databaseFileName asString.
	} asDictionary.
	
	db _ usedClass newFrom: settings.! !

!SQLiteIntegrationTest methodsFor: 'running' stamp: 'jpb 1/16/2021 22:12:11'!
tearDown
	db close.
	self databaseFileName delete.
	super tearDown! !

!SQLiteIntegrationTest methodsFor: 'accessing' stamp: 'spd 5/19/2010 14:32'!
databaseName
	^'sqlite_test_database.db'
	
! !

!SQLiteIntegrationTest methodsFor: 'testing' stamp: 'jpb 1/17/2021 12:03:31'!
testInstanceCreation
 
	self 
		assert: db notNil;
		assert: db class = usedClass;
		deny: (usedClass registry includes: db).
	
! !

!SQLiteIntegrationTest methodsFor: 'testing' stamp: 'jpb 1/17/2021 12:25:39'!
testPreparedStatements

	(db execute: 'select * from sqlite_master' args: {}) ifEmpty:[
		db execute: 'create table employee (id INTEGER PRIMARY KEY, name TEXT, created DATE)'
			args: {}.
	].

	db execute: 'insert into employee values (?, ?, ?)' 
		args: {1. 'Adam'. DateAndTime now}.
		
	db execute: 'insert into employee values (?, ?, ?)' 
		args: {2. 'Eve'. nil}.
		
	db execute: 'select id, name from employee where name = ?' args: {'Adam'} do:[:id :name|
		self assert: id = 1.
		self assert: name = 'Adam'.
	].

	db execute: 'select * from employee where name = ?' args: {'Eve'} do:[:id :name :created|
		self assert: id = 2.
		self assert: name = 'Eve'.
		self assert: created = nil.
	].
! !

!SQLiteIntegrationTest methodsFor: 'testing' stamp: 'jpb 1/17/2021 12:02:44'!
testRegistration

	db open.
	
	self assert: (usedClass registry includes: db).	
	
	db close.
	
	self deny: (usedClass registry includes: db).	! !

!SQLiteIntegrationTest methodsFor: 'testing' stamp: 'tbn 1/25/2010 20:54'!
testTableCreation
	|sql|
	db open.	
	sql _ 'CREATE TABLE ABC (ID INTEGER PRIMARY KEY, Name TEXT)'.
	db executeQuery: sql.
	db withResultForQuery: 'select * from sqlite_master;' do: [:each | 
		self assert: sql = (each nextRow at: 'sql')] 
	 ! !

!SQLiteIntegrationTest methodsFor: 'testing' stamp: 'jpb 1/17/2021 12:25:22'!
testUseDatabase
	|s1 s2 s3 arrayOfDicts|
	s1 _ 'create table employee (id, name)'.
	s2 _ 'insert into employee values (1, ''Adam'')'.
	s3 _ 'insert into employee values (2, ''Eve'')'.
	
	(Array with: s1 with: s2 with: s3)
		do: [:sql | db  executeQuery: sql].
	
	arrayOfDicts _ db executeQuery: 'SELECT * FROM employee'.
	self assert: arrayOfDicts size = 2.
	self assert: (arrayOfDicts first at: 'name') = 'Adam'
	! !

!Sqlite3Library methodsFor: 'api' stamp: 'ar 12/8/2011 13:33'!
apiBindDouble: stmt with: index with: double
	"int sqlite3_bind_double(sqlite3_stmt*, int, double);"
	<cdecl: long 'sqlite3_bind_double' (ulong long double)>
	^self externalCallFailed! !

!Sqlite3Library methodsFor: 'api' stamp: 'ar 12/8/2011 13:33'!
apiBindInt: stmt with: index with: value
	"int sqlite3_bind_int(sqlite3_stmt*, int, int);"
	<cdecl: long 'sqlite3_bind_int' (ulong long long)>
	^self externalCallFailed! !

!Sqlite3Library methodsFor: 'api' stamp: 'ar 12/8/2011 13:33'!
apiBindNull: stmt with: index
	"int sqlite3_bind_null(sqlite3_stmt*, int);"
	<cdecl: long 'sqlite3_bind_null' (ulong long)>
	^self externalCallFailed! !

!Sqlite3Library methodsFor: 'api' stamp: 'ar 12/8/2011 13:16'!
apiBindParameterCount: pStmt
	"int sqlite3_bind_parameter_count(sqlite3_stmt*)"
	<cdecl: long 'sqlite3_bind_parameter_count' (ulong)>
	^ self externalCallFailed ! !

!Sqlite3Library methodsFor: 'api' stamp: 'ar 12/8/2011 13:34'!
apiBindText: stmt with: index with: value with: length with: destructor
	"int sqlite3_bind_text(sqlite3_stmt*, int, const char*, int n, void(*)(void*));"
	<cdecl: long 'sqlite3_bind_text' (ulong long char* long long)>
	^self externalCallFailed! !

!Sqlite3Library methodsFor: 'api' stamp: 'cf 11/23/2005 15:31'!
apiChanges: sqlite
	"int sqlite_changes(sqlite*)"
	<cdecl: long 'sqlite3_changes' (SqliteReference)>
	^ self externalCallFailed ! !

!Sqlite3Library methodsFor: 'api' stamp: 'cf 11/23/2005 15:15'!
apiClose: sqlite
	"int sqlite3_close(sqlite3*)"
	<cdecl: long 'sqlite3_close' (SqliteReference)>
	^ self externalCallFailed ! !

!Sqlite3Library methodsFor: 'api' stamp: 'ar 12/8/2011 14:44'!
apiColumnCount: hStmt
	"int sqlite3_column_count(sqlite3_stmt*);"
	<cdecl: long 'sqlite3_column_count' (ulong)>
	^self externalCallFailed! !

!Sqlite3Library methodsFor: 'api' stamp: 'ar 12/8/2011 13:51'!
apiColumnDouble: hStmt with: iCol
	"double sqlite3_column_double(sqlite3_stmt*, int iCol);"
	<cdecl: double 'sqlite3_column_double' (ulong long)>
	^self externalCallFailed! !

!Sqlite3Library methodsFor: 'api' stamp: 'ar 12/8/2011 13:52'!
apiColumnInt: hStmt with: iCol
	"int sqlite3_column_int(sqlite3_stmt*, int iCol);"
	<cdecl: long 'sqlite3_column_int' (ulong long)>
	^self externalCallFailed! !

!Sqlite3Library methodsFor: 'api' stamp: 'ar 12/9/2011 19:11'!
apiColumnName: hStmt with: iCol
	"char* sqlite3_column_name(sqlite3_stmt*, int iCol);"
	<cdecl: char* 'sqlite3_column_name' (ulong long)>
	^self externalCallFailed! !

!Sqlite3Library methodsFor: 'api' stamp: 'ar 12/8/2011 13:52'!
apiColumnText: hStmt with: iCol
	"char* sqlite3_column_int(sqlite3_stmt*, int iCol);"
	<cdecl: char* 'sqlite3_column_text' (ulong long)>
	^self externalCallFailed! !

!Sqlite3Library methodsFor: 'api' stamp: 'ar 12/8/2011 15:00'!
apiColumnType: hStmt with: iCol
	"int sqlite3_column_type(sqlite3_stmt*, int iCol);"
	<cdecl: long 'sqlite3_column_type' (ulong long)>
	^self externalCallFailed! !

!Sqlite3Library methodsFor: 'api' stamp: 'cf 11/23/2005 15:52'!
apiErrorMessage: anSqlite
	"const char *sqlite3_errmsg(sqlite3*)"
	<cdecl: SqliteError 'sqlite3_errmsg' (SqliteReference)>
	^ self externalCallFailed ! !

!Sqlite3Library methodsFor: 'api' stamp: 'ar 12/8/2011 14:12'!
apiFinalize: pStmt
	"int sqlite3_finalize(sqlite3_stmt *pStmt);"
	<cdecl: long 'sqlite3_finalize' (ulong)>
	^self externalCallFailed! !

!Sqlite3Library methodsFor: 'api' stamp: 'cf 11/23/2005 15:32'!
apiFreeTable: buffer
	"void sqlite3_free_table(char **result)"
	<cdecl: void 'sqlite3_free_table' (SqliteResultBuffer)>
	^ self externalCallFailed! !

!Sqlite3Library methodsFor: 'api' stamp: 'cf 11/23/2005 15:34'!
apiGetTable: anSqlite sql: sql buffer: result rows: nRows columns: nColumns error: errBuffer
	"int sqlite3_get_table(
  sqlite*,
  char *sql,
  char ***result,
  int *nrow,
  int *ncolumn,
  char **errmsg
	)"
	<cdecl: long 'sqlite3_get_table' (SqliteReference char* SqliteResultBuffer* long* long* SqliteError*)>
	^ self externalCallFailed ! !

!Sqlite3Library methodsFor: 'api' stamp: 'cf 11/23/2005 15:35'!
apiLastInsertId: sqlite
	"long long int sqlite3_last_insert_rowid(sqlite3*)"
	<cdecl: longlong 'sqlite3_last_insert_rowid' (SqliteReference)>
	^ self externalCallFailed ! !

!Sqlite3Library methodsFor: 'api' stamp: 'jpb 1/14/2021 18:21:23'!
apiOpen: dbName sqlite: sqlite
	"int sqlite3_open(const char*, sqlite3**);"
	<cdecl: long 'sqlite3_open' (char* SqliteReference*)>
	^ self externalCallFailed! !

!Sqlite3Library methodsFor: 'api' stamp: 'ar 12/8/2011 13:11'!
apiPrepareV2: db with: zSql with: nByte with: ppStmt with: pzTail
	"int sqlite3_prepare_v2(
	  sqlite3 *db,            /* Database handle */
	  const char *zSql,       /* SQL statement, UTF-8 encoded */
	  int nByte,              /* Maximum length of zSql in bytes. */
	  sqlite3_stmt **ppStmt,  /* OUT: Statement handle */
	  const char **pzTail     /* OUT: Pointer to unused portion of zSql */
	);"
	<cdecl: long 'sqlite3_prepare_v2' (SqliteReference char* long ulong* ulong*)>
	^ self externalCallFailed ! !

!Sqlite3Library methodsFor: 'api' stamp: 'ar 12/8/2011 13:51'!
apiStep: hStmt
	"int sqlite3_step(sqlite3_stmt*);"
	<cdecl: long 'sqlite3_step' (ulong)>
	^self externalCallFailed! !

!Sqlite3Library methodsFor: 'accessing' stamp: 'ar 12/8/2011 15:11'!
bindArg: arg at: index in: stmt

	arg == true ifTrue:[^self apiBindInt: stmt with: index with: 1].
	arg == false ifTrue:[^self apiBindInt: stmt with: index with: 0].
	arg ==  nil ifTrue:[^self apiBindNull: stmt with: index].

	arg isInteger ifTrue:[^self apiBindInt: stmt with: index with: arg].
	arg isFloat ifTrue:[^self apiBindDouble: stmt with: index with: arg].
	arg isString ifTrue:[^self apiBindText: stmt with: index with: arg with: arg size with: -1].
	(arg isKindOf: DateAndTime) ifTrue:[ | string |
		string _ String streamContents:[:s|
			arg printYMDOn: s withLeadingSpace: false.
			s nextPut: $T.
			arg printHMSOn: s.
		].
		^self bindArg: string at: index in: stmt
	].
	self error: 'Cannot bind argument'! !

!Sqlite3Library methodsFor: 'accessing' stamp: 'ab 1/31/2003 16:20'!
changedRows: anSqliteRef
	^ self apiChanges: anSqliteRef! !

!Sqlite3Library methodsFor: 'accessing' stamp: 'cf 11/23/2005 15:36'!
checkError: anError
	|message|
	(anError getHandle allSatisfy: [:i | i = 0]) ifTrue: [^ self].
	message _ anError value fromCString.
	anError free.
	self error: message	! !

!Sqlite3Library methodsFor: 'accessing' stamp: 'ar 12/8/2011 14:32'!
checkErrorInteger: anError
	|message|
	(anError = 0) ifTrue: [^self].
	"Get the errmsg"

	message _ 'Result Code: ', anError asString.
	self error: message! !

!Sqlite3Library methodsFor: 'accessing' stamp: 'tbn 1/25/2010 19:52'!
close: anSqliteRef
	| err |
	err _ self apiClose: anSqliteRef.
	self checkErrorInteger: err.! !

!Sqlite3Library methodsFor: 'accessing' stamp: 'ar 12/12/2011 19:04'!
execute: query args: args on: sqliteRef do: aBlock
	"Execute the given query, binding the arguments as needed"

	| ppStmt hStmt code colCount result value err names rval |
	ppStmt _ WordArray new: 1.
	(err _ self apiPrepareV2: sqliteRef with: query with: query size with: ppStmt with: nil) == 0
		ifFalse:[self error: 'sqlite_prepare_v2 failed: ', err printString].
	hStmt _ ppStmt at: 1.
	(self apiBindParameterCount: hStmt) = args size 
		ifFalse:[self error:'Argument count mismatch'].
	1 to: args size do:[:idx|
		self bindArg: (args at: idx) at: idx in: hStmt.
	].
	colCount _ nil.
	[code _ self apiStep: hStmt.
	code = 100] whileTrue:[
		colCount ifNil:[
			colCount _ self apiColumnCount: hStmt.
			result _ Array new: colCount.
			names _ Array new: colCount.
			1 to: colCount do:[:i|
				names at: i put: (self apiColumnName: hStmt with: i-1) asSymbol.
			].
		].
		1 to: colCount do:[:i| | colIdx |
			colIdx _ i-1.
			(self apiColumnType: hStmt with: colIdx) caseOf: {
				[1] -> [value _ self apiColumnInt: hStmt with: colIdx].
				[2] -> [value _ self apiColumnDouble: hStmt with: colIdx].
				[3] -> [value _ self apiColumnText: hStmt with: colIdx].
				[4] -> [self error: 'Blobs are not supported'].
				[5] -> [value _ nil].
			}.
			result at: i put: value.
		].
		rval _ aBlock numArgs = result size 
			ifTrue:[aBlock valueWithArguments: result]
			ifFalse:[aBlock value: (SQLiteRecord names: names values: result)].
	].
	self apiFinalize: hStmt.
	code = 101 ifFalse:[self error: 'Error code: ', code printString].
	^rval! !

!Sqlite3Library methodsFor: 'accessing' stamp: 'ab 12/16/2002 01:30'!
freeResultBuffer: aResultBuffer
	self apiFreeTable: aResultBuffer! !

!Sqlite3Library methodsFor: 'accessing' stamp: 'ab 12/16/2002 00:23'!
lastInsertId: anSqliteRef
	^ self apiLastInsertId: anSqliteRef! !

!Sqlite3Library methodsFor: 'accessing' stamp: 'cf 11/23/2005 15:22'!
open: aString
	|err ref|
	ref _ SqliteReference new.
	err _ self apiOpen: aString sqlite: ref.
	self checkErrorInteger: err.
	^ ref! !

!Sqlite3Library methodsFor: 'accessing' stamp: 'tbn 1/25/2010 19:52'!
resultForQuery: aString on: sqliteRef
	|nrows ncols buffer err|
	nrows _ WordArray new: 1.
	ncols _ WordArray new: 1.
	err _ SqliteError new.
	buffer _ SqliteResultBuffer new.
	self apiGetTable: sqliteRef sql: aString buffer: buffer rows: nrows columns: ncols error: err.
	self checkError: err.
	^ SqliteResult buffer: buffer rows: nrows first columns: ncols first! !

!Sqlite3Library class methodsFor: 'accessing' stamp: 'tbn 1/25/2010 19:53'!
default
	^ default ifNil: [default _ super new]! !

!Sqlite3Library class methodsFor: 'accessing' stamp: 'tbn 4/1/2008 20:04'!
moduleName
	"Was: ^ 'sqlite'"
	^ 'sqlite3'! !

!SqliteError methodsFor: 'accessing'!
value
	"This method was automatically generated. See SqliteError class>>fields."
	<generated>
	^ExternalData fromHandle: (handle pointerAt: 1) type: ExternalType char asPointerType! !

!SqliteError methodsFor: 'accessing'!
value: anObject
	"This method was automatically generated. See SqliteError class>>fields."
	<generated>
	handle pointerAt: 1 put: anObject getHandle.! !

!SqliteError class methodsFor: 'definitions' stamp: 'ab 12/15/2002 21:55'!
fields
	"self defineFields"
	^ #((value 'char*'))! !

!SqliteError class methodsFor: 'class initialization' stamp: 'ab 12/15/2002 22:17'!
initialize
	self defineFields! !

!SqliteReference methodsFor: 'accessing'!
value
	"This method was automatically generated. See SqliteReference class>>fields."
	<generated>
	^ExternalData fromHandle: (handle pointerAt: 1) type: ExternalType void asPointerType! !

!SqliteReference methodsFor: 'accessing'!
value: anObject
	"This method was automatically generated. See SqliteReference class>>fields."
	<generated>
	handle pointerAt: 1 put: anObject getHandle.! !

!SqliteReference class methodsFor: 'field definition' stamp: 'cf 11/22/2005 21:38'!
fields
	"self defineFields"
	^ #((value 'void*'))! !

!SqliteReference class methodsFor: 'class initialization' stamp: 'cf 11/22/2005 21:58'!
initialize
	"SqliteReference initialize"
	self defineFields! !

!SqliteResultBuffer methodsFor: 'accessing'!
value
	"This method was automatically generated. See SqliteResultBuffer class>>fields."
	<generated>
	^ExternalData fromHandle: (handle pointerAt: 1) type: ExternalType void asPointerType! !

!SqliteResultBuffer methodsFor: 'accessing'!
value: anObject
	"This method was automatically generated. See SqliteResultBuffer class>>fields."
	<generated>
	handle pointerAt: 1 put: anObject getHandle.! !

!SqliteResultBuffer class methodsFor: 'field definition' stamp: 'ab 12/16/2002 00:35'!
fields
	"self defineFields"
	^ #((value 'void*'))! !

!SqliteResultBuffer class methodsFor: 'class initialization' stamp: 'ab 1/14/2003 15:28'!
initialize
	self defineFields! !

!SQLiteClient methodsFor: 'finalization' stamp: 'tbn 1/25/2010 19:58'!
actAsExecutor
	super actAsExecutor.
	fileName _ nil! !

!SQLiteClient methodsFor: 'finalization' stamp: 'ab 2/22/2003 23:15'!
finalize
	self close.! !

!SQLiteClient methodsFor: 'finalization' stamp: 'ab 2/22/2003 22:31'!
register
	self class registry add: self! !

!SQLiteClient methodsFor: 'finalization' stamp: 'ab 2/22/2003 22:32'!
unregister
	self class registry remove: self ifAbsent: []! !

!SQLiteClient methodsFor: 'public' stamp: 'jpb 1/14/2021 19:14:35'!
changedRows
	^ self isOpen
		ifTrue: [Sqlite3Library default changedRows: reference]
		ifFalse: [0]
	! !

!SQLiteClient methodsFor: 'public' stamp: 'jpb 1/14/2021 19:14:35'!
close
	self unregister.
	self isOpen ifTrue: [Sqlite3Library default close: reference].
	reference _ nil.
! !

!SQLiteClient methodsFor: 'public' stamp: 'ar 12/12/2011 20:50'!
commit
	txn _ false.
	self execute: 'COMMIT' args: {}.
! !

!SQLiteClient methodsFor: 'public' stamp: 'ab 1/29/2003 16:37'!
executeQuery: aString
	^ self withResultForQuery: aString do:
		[:result |
		Array streamContents:
			[:s |
			result do: [:row | s nextPut: row]]]! !

!SQLiteClient methodsFor: 'public' stamp: 'ab 12/16/2002 00:27'!
fileName
	^ fileName! !

!SQLiteClient methodsFor: 'public' stamp: 'ab 12/16/2002 00:28'!
isOpen
	^ reference notNil and: [reference getHandle anySatisfy: [:i | i > 0]]! !

!SQLiteClient methodsFor: 'public' stamp: 'jpb 1/14/2021 19:14:35'!
lastInsertId
	^ self isOpen
		ifTrue: [Sqlite3Library default lastInsertId: reference]
		ifFalse: [0]
	! !

!SQLiteClient methodsFor: 'public' stamp: 'jpb 1/14/2021 19:14:35'!
open
	reference _ Sqlite3Library default open: fileName.
	self register.
! !

!SQLiteClient methodsFor: 'public' stamp: 'ar 12/12/2011 20:51'!
rollback
	txn _ false.
	self execute: 'ROLLBACK' args: {}.
! !

!SQLiteClient methodsFor: 'public' stamp: 'ar 12/12/2011 20:50'!
transact
	txn _ true.
	self execute: 'BEGIN TRANSACTION' args: {}.
! !

!SQLiteClient methodsFor: 'public' stamp: 'jpb 1/17/2021 12:01:31'!
transaction: aBlock
	"Wrap the given block inside a transaction"
	| result |
	txn ifNotNil: [^aBlock value].
	
	[
		self transact.
		result _ aBlock value.
		self commit.
	] ifCurtailed: [self rollback].

	^result! !

!SQLiteClient methodsFor: 'public' stamp: 'jpb 1/17/2021 12:01:18'!
withResultForQuery: aString do: aBlock
	|result|
	self isOpen ifFalse: [self open].
	result _ Sqlite3Library default resultForQuery: aString on: reference.
	
	^ [aBlock value: result] ensure: [result free]! !

!SQLiteClient methodsFor: 'prepared statements' stamp: 'ar 12/9/2011 19:23'!
execute: query args: args
	^Array streamContents:[:s|
		self execute: query args: args do:[:result| s nextPut: result].
	].! !

!SQLiteClient methodsFor: 'prepared statements' stamp: 'jpb 1/14/2021 19:14:35'!
execute: query args: args do: aBlock

	self isOpen ifFalse: [self open].
	^Sqlite3Library default execute: query args: args on: reference do: aBlock.
! !

!SQLiteClient methodsFor: 'as yet unclassified' stamp: 'jpb 1/17/2021 12:23:30'!
initializeWith: newSettings
	self initialize.
	
	fileName _ newSettings at: #filename! !

!SQLiteClient class methodsFor: 'instance creation' stamp: 'jpb 1/17/2021 12:20:56'!
newFrom: newSettings
	| newClient |
	newClient _ self basicNew.
	newClient initializeWith: newSettings.
	
	^newClient! !

!SQLiteClient class methodsFor: 'accessing' stamp: 'tbn 1/25/2010 19:58'!
registry
	^ registry ifNil: [registry _ WeakRegistry new]! !

!SqliteResult methodsFor: 'public' stamp: 'ab 12/16/2002 01:58'!
atEnd
	^ index > (rows + 1 * columns)! !

!SqliteResult methodsFor: 'public' stamp: 'ab 1/29/2003 16:06'!
columnNames
	^ columnNames! !

!SqliteResult methodsFor: 'public' stamp: 'ab 12/16/2002 01:56'!
do: aBlock
	self reset.
	rows timesRepeat: [aBlock value: self nextRow].
	! !

!SqliteResult methodsFor: 'public' stamp: 'jpb 1/14/2021 19:14:35'!
free
	Sqlite3Library default freeResultBuffer: buffer.
	buffer _ nil.! !

!SqliteResult methodsFor: 'public' stamp: 'ab 12/16/2002 01:58'!
nextKeysAndValuesDo: aBlock
	self atEnd ifTrue: [self error: 'Trying to read past end of results'].
	columnNames do:
		[:ea |
		aBlock value: ea value: self nextString]! !

!SqliteResult methodsFor: 'public' stamp: 'tbn 1/25/2010 19:54'!
nextRow
	|row|
	row _ Dictionary new.
	self nextKeysAndValuesDo: [:k :v | row at: k put: v].
	^ row! !

!SqliteResult methodsFor: 'public' stamp: 'ab 1/29/2003 16:34'!
nextValues
	^ columnNames collect: [:ea | self nextString]! !

!SqliteResult methodsFor: 'public' stamp: 'tbn 1/25/2010 19:55'!
reset
	index _ 1.
	self readColumns.! !

!SqliteResult methodsFor: 'accessing' stamp: 'jpb 1/17/2021 11:58:37'!
currentAddress
	|base current|
	base _ buffer value getHandle.
	current _ base + ((index - 1) * base size).

	^ current! !

!SqliteResult methodsFor: 'accessing' stamp: 'tbn 1/25/2010 19:55'!
nextString
	|str|
	buffer ifNil: [self error: 'Result has been freed'].
	str _ self readString.
	index _ index + 1.
	^ str! !

!SqliteResult methodsFor: 'accessing' stamp: 'tbn 1/25/2010 19:55'!
setBuffer: aResultBuffer rows: nRows columns: nColumns
	buffer _ aResultBuffer.
	rows _ nRows.
	columns _ nColumns.
	self reset.! !

!SqliteResult methodsFor: 'reading' stamp: 'tbn 1/25/2010 19:55'!
readColumns
	columnNames _ OrderedCollection new.
	columns timesRepeat: [columnNames add: self nextString]! !

!SqliteResult methodsFor: 'reading' stamp: 'ab 12/16/2002 01:47'!
readString
	^ self readStringAtAddress: (self currentAddress)! !

!SqliteResult methodsFor: 'reading' stamp: 'jpb 1/17/2021 12:00:02'!
readStringAtAddress: anAddress
	|deref i char|
	deref _ anAddress pointerAt: 1.
	(deref allSatisfy: [:ea | ea = 0]) ifTrue: [^ nil].
	
	^ String streamContents:
		[:stream |
		i _ 1.
		[(char _ deref unsignedCharAt: i) asciiValue = 0] 
			whileFalse:
				[stream nextPut: char.
				 i _ i + 1]]! !

!SqliteResult class methodsFor: 'instance creation' stamp: 'ab 12/16/2002 01:41'!
buffer: aResultBuffer rows: nRows columns: nColumns
	^ self new setBuffer: aResultBuffer rows: nRows columns: nColumns! !
SqliteError initialize!
SqliteReference initialize!
SqliteResultBuffer initialize!
