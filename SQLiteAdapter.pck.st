'From Cuis 5.0 [latest update: #4928] on 5 November 2021 at 7:38:30 pm'!
'Description Cuis SQLite3 adapter for the SQLite3 file/in-memory database

License: MIT
Author: Josef Philip Berhart
Authors of the Squeak version: Milan Vavra and others, see AUTHORS.md'!
!provides: 'SQLiteAdapter' 1 27!
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

!classDefinition: #SQLiteClient category: 'SQLiteAdapter'!
Object subclass: #SQLiteClient
	instanceVariableNames: 'reference fileName txn library'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'SQLiteAdapter'!
!classDefinition: 'SQLiteClient class' category: 'SQLiteAdapter'!
SQLiteClient class
	instanceVariableNames: 'registry'!


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

!SQLiteIntegrationTest methodsFor: 'testing' stamp: 'jpb 4/21/2021 13:29:20'!
testPreparedStatements

	(db executeQuery: 'select * from sqlite_master') ifEmpty: [
		db executeQuery: 'create table employee (id INTEGER PRIMARY KEY, name TEXT, created DATE)'.
	].

	db executeQuery: 'insert into employee values (?, ?, ?)' 
		withAll: {1. 'Adam'. DateAndTime now}.
		
	db executeQuery: 'insert into employee values (?, ?, ?)' 
		withAll: {2. 'Eve'. nil}.
		
	db executeQuery: 'select id, name from employee where name = ?' withAll: {'Adam'} do: [:record|
		self assert: (record at: #id) = 1.
		self assert: (record at: #name) = 'Adam'.
	].

	db executeQuery: 'select * from employee where name = ?' withAll: {'Eve'} do: [:record|
		self assert: (record at: #id) = 2.
		self assert: (record at: #name) = 'Eve'.
		self assert: (record at: #created) = nil.
	].
! !

!SQLiteIntegrationTest methodsFor: 'testing' stamp: 'jpb 1/17/2021 12:02:44'!
testRegistration

	db open.
	
	self assert: (usedClass registry includes: db).	
	
	db close.
	
	self deny: (usedClass registry includes: db).	! !

!SQLiteIntegrationTest methodsFor: 'testing' stamp: 'jpb 4/21/2021 13:31:35'!
testTableCreation
	|sql|
	db open.	
	sql _ 'CREATE TABLE ABC (ID INTEGER PRIMARY KEY, Name TEXT)'.
	db executeQuery: sql.
	db executeQuery: 'select * from sqlite_master;' do: [:record | 
		self assert: sql = (record at: 'sql')] 
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

!Sqlite3Library methodsFor: 'api' stamp: 'jpb 4/19/2021 08:06:50'!
apiBindBlob: stmt with: index with: value with: length with: destructor
	"int sqlite3_bind_blob(sqlite3_stmt*, int, const void*, int n, void(*)(void*));"
	<cdecl: long 'sqlite3_bind_blob' (ulong long char* long long)>
	^self externalCallFailed! !

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

!Sqlite3Library methodsFor: 'api' stamp: 'jpb 4/21/2021 09:47:19'!
apiColumnBlob: hStmt with: iCol
	"const void *sqlite3_column_blob(sqlite3_stmt*, int iCol)"
	<cdecl: void* 'sqlite3_column_blob' (ulong long)>
	^self externalCallFailed! !

!Sqlite3Library methodsFor: 'api' stamp: 'jpb 4/21/2021 09:27:30'!
apiColumnBytes: hStmt with: iCol
	"char* sqlite3_column_int(sqlite3_stmt*, int iCol);"
	<cdecl: long 'sqlite3_column_bytes' (ulong long)>
	^self externalCallFailed! !

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

!Sqlite3Library methodsFor: 'accessing' stamp: 'ab 1/31/2003 16:20'!
changedRows: anSqliteRef
	^ self apiChanges: anSqliteRef! !

!Sqlite3Library methodsFor: 'accessing' stamp: 'tbn 1/25/2010 19:52'!
close: anSqliteRef
	| err |
	err _ self apiClose: anSqliteRef.
	self checkErrorInteger: err.! !

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

!Sqlite3Library methodsFor: 'prepared statements' stamp: 'jpb 4/19/2021 08:03:28'!
bindArg: arg at: index in: stmt

	arg == true ifTrue: [ ^self apiBindInt: stmt with: index with: 1].
	arg == false ifTrue: [ ^self apiBindInt: stmt with: index with: 0].
	arg ==  nil ifTrue: [ ^self apiBindNull: stmt with: index].

	arg isInteger ifTrue: [ ^self apiBindInt: stmt with: index with: arg].
	arg isFloat ifTrue: [ ^self apiBindDouble: stmt with: index with: arg].
	arg isString ifTrue: [ ^self apiBindText: stmt with: index with: arg with: arg size with: -1].
	arg class = ByteArray ifTrue: [ ^self apiBindBlob: stmt with: index with: arg with: arg size with: -1 ].
	
	(arg isKindOf: DateAndTime) ifTrue: [ | string |
		string _ String streamContents: [:s|
			arg printYMDOn: s withLeadingSpace: false.
			s nextPut: $T.
			arg printHMSOn: s.
		].
		^self bindArg: string at: index in: stmt
	].

	self error: 'Cannot bind argument'! !

!Sqlite3Library methodsFor: 'prepared statements' stamp: 'jpb 4/21/2021 13:07:51'!
execute: query args: args on: sqliteRef do: aBlock
	"Execute the given query, binding the arguments as needed"

	| ppStmt hStmt code colCount result errorCode names rval |
	
	ppStmt _ WordArray new: 1.
	(errorCode _ self apiPrepareV2: sqliteRef with: query with: query size with: ppStmt with: nil) == 0
		ifFalse:[self error: 'sqlite_prepare_v2 failed: ', (self findErrorMessageByCode: errorCode for: sqliteRef) ].
		
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

		self readColumns: colCount from: hStmt into: result.
		 
		rval _ aBlock value: (SQLiteRecord names: names values: result).
	].

	self apiFinalize: hStmt.
	code = 101 ifFalse: [self error: 'Error code: ', (self findErrorMessageByCode: code for: sqliteRef) ].
	
	^rval! !

!Sqlite3Library methodsFor: 'prepared statements' stamp: 'jpb 4/21/2021 10:03:07'!
readBlobColumnFrom: hStmt at: colIdx
	| newBlobSize newArray blobData blobPointer |
	blobData _ self apiColumnBlob: hStmt with: colIdx. 
	newBlobSize _ self apiColumnBytes: hStmt with: colIdx. 
	
	newArray _ ByteArray new: newBlobSize.
	blobPointer _ blobData getHandle.
	
	blobPointer isNull ifTrue: [ ^newArray ].
	
	(1 to: newBlobSize) do: [:byteIdx| 
		newArray at: byteIdx put: (blobPointer byteAt: byteIdx)
	].
	
	^newArray! !

!Sqlite3Library methodsFor: 'prepared statements' stamp: 'jpb 4/21/2021 09:40:59'!
readColumns: colCount from: hStmt into: result
	1 to: colCount do: [:i | 
		| colIdx |
		
		colIdx _ i - 1.
		
		result at: i put: (self readTypedColumnAt: colIdx from: hStmt).
	].
	! !

!Sqlite3Library methodsFor: 'prepared statements' stamp: 'jpb 4/21/2021 09:41:52'!
readTypedColumnAt: colIdx from: hStmt
	| columnType |
	
	columnType _ (self apiColumnType: hStmt with: colIdx).
	
	1 = columnType ifTrue: [ ^ self apiColumnInt: hStmt with: colIdx ].
	2 = columnType ifTrue: [ ^ self apiColumnDouble: hStmt with: colIdx ].
	3 = columnType ifTrue: [ ^ self apiColumnText: hStmt with: colIdx ].
	4 = columnType ifTrue: [ ^ self readBlobColumnFrom: hStmt at: colIdx ].
	5 = columnType ifTrue: [ ^ nil].
	
	self error: 'Unsupported column type: ' , columnType asString.! !

!Sqlite3Library methodsFor: 'errors' stamp: 'cf 11/23/2005 15:36'!
checkError: anError
	|message|
	(anError getHandle allSatisfy: [:i | i = 0]) ifTrue: [^ self].
	message _ anError value fromCString.
	anError free.
	self error: message	! !

!Sqlite3Library methodsFor: 'errors' stamp: 'ar 12/8/2011 14:32'!
checkErrorInteger: anError
	|message|
	(anError = 0) ifTrue: [^self].
	"Get the errmsg"

	message _ 'Result Code: ', anError asString.
	self error: message! !

!Sqlite3Library methodsFor: 'errors' stamp: 'jpb 4/18/2021 11:01:31'!
findErrorMessageByCode: errorCode for: sqliteReference
	| errorMessage |
	
	errorMessage _ sqliteReference isNull
		ifTrue: [ '' ]
		ifFalse: [ (self apiErrorMessage: sqliteReference) value fromCString ].
		
	errorMessage isEmpty
		ifTrue: [ 	^errorCode printString ]
		ifFalse: [ ^errorMessage , ' (Code: ' , errorCode printString , ')' ].! !

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

!SQLiteClient methodsFor: 'public' stamp: 'jpb 11/5/2021 19:24:22'!
beginTransaction
	txn _ true.
	self executeQuery: 'BEGIN TRANSACTION' withAll: {}.
! !

!SQLiteClient methodsFor: 'public' stamp: 'jpb 11/5/2021 19:37:21'!
changedRows
	^ self isOpen
		ifTrue: [ library changedRows: reference]
		ifFalse: [0]
	! !

!SQLiteClient methodsFor: 'public' stamp: 'jpb 11/5/2021 19:37:28'!
close
	self unregister.
	self isOpen ifTrue: [ library close: reference].
	reference _ nil.
! !

!SQLiteClient methodsFor: 'public' stamp: 'jpb 4/21/2021 12:48:34'!
commit
	txn _ false.
	self executeQuery: 'COMMIT' withAll: {}.
! !

!SQLiteClient methodsFor: 'public' stamp: 'jpb 4/21/2021 13:00:42'!
executeQuery: aString
	^self executeQuery: aString withAll: #()! !

!SQLiteClient methodsFor: 'public' stamp: 'jpb 4/21/2021 12:59:34'!
executeQuery: aString do: aBlock
	^self executeQuery: aString withAll: #() do: aBlock! !

!SQLiteClient methodsFor: 'public' stamp: 'jpb 4/21/2021 12:57:59'!
executeQuery: query withAll: args
	^Array streamContents: [:arrayStream|
		self executeQuery: query withAll: args do: [:result| arrayStream nextPut: result].
	].! !

!SQLiteClient methodsFor: 'public' stamp: 'jpb 11/5/2021 19:37:37'!
executeQuery: query withAll: args do: aBlock

	self isOpen ifFalse: [self open].
	^library execute: query args: args on: reference do: aBlock.
! !

!SQLiteClient methodsFor: 'public' stamp: 'ab 12/16/2002 00:27'!
fileName
	^ fileName! !

!SQLiteClient methodsFor: 'public' stamp: 'ab 12/16/2002 00:28'!
isOpen
	^ reference notNil and: [reference getHandle anySatisfy: [:i | i > 0]]! !

!SQLiteClient methodsFor: 'public' stamp: 'jpb 11/5/2021 19:37:53'!
lastInsertId
	^ self isOpen
		ifTrue: [ library lastInsertId: reference]
		ifFalse: [0]
	! !

!SQLiteClient methodsFor: 'public' stamp: 'jpb 11/5/2021 19:38:02'!
open
	reference _ library open: fileName.
	self register.
! !

!SQLiteClient methodsFor: 'public' stamp: 'jpb 4/21/2021 12:48:34'!
rollback
	txn _ false.
	self executeQuery: 'ROLLBACK' withAll: {}.
! !

!SQLiteClient methodsFor: 'public' stamp: 'jpb 11/5/2021 19:24:22'!
transaction: aBlock
	"Wrap the given block inside a transaction"
	| result |
	txn ifNotNil: [^aBlock value].
	
	[
		self beginTransaction.
		result _ aBlock value.
		self commit.
	] ifCurtailed: [self rollback].

	^result! !

!SQLiteClient methodsFor: 'as yet unclassified' stamp: 'jpb 11/5/2021 19:37:43'!
initializeWith: newSettings
	self initialize.
	
	fileName _ newSettings at: #filename.
	library _ newSettings at: #library ifAbsent: [ Sqlite3Library default ].! !

!SQLiteClient class methodsFor: 'instance creation' stamp: 'jpb 1/17/2021 12:20:56'!
newFrom: newSettings
	| newClient |
	newClient _ self basicNew.
	newClient initializeWith: newSettings.
	
	^newClient! !

!SQLiteClient class methodsFor: 'accessing' stamp: 'tbn 1/25/2010 19:58'!
registry
	^ registry ifNil: [registry _ WeakRegistry new]! !
SqliteError initialize!
SqliteReference initialize!
