cxxtags-vim
======

What is this?
------
**cxxtags-vim** is vim front-end for cxxtags. This script performs these features.

* Jump to a declaration
* Jump to a definition
* List all the references
* List all the overrides/overriden information
* Show type information(members, methods and base classes)

Requirement
------
**cxxtags** ver3.0b or higher

How to install
------
Copy *plugin* and *autoload* directory to your vim script directory.
Or type `make install` to install these scripts to `~/.vim`. 

Commands
------
|Name              | Description |
| ---------------- | ------------------- |
|CxxtagsOpenDecl   | Jump to the declaration of an item under the cursor.|
|CxxtagsOpenDef    | Jump to the definition of an item under the cursor.|
|CxxtagsListRefs   | List all the references to an item under the cursor to the message buffer.|
|CxxtagsListOverride  | List all the items which an item under the cursor overrides.|
|CxxtagsListOverriden | List all the items overriden by an item under the cursor.|
|CxxtagsListTypeInfo|Show type information of an item|
|CxxtagsUpdateDbFile|Update a database file of the source file opened in current buffer.|
|CxxtagsCloseMsgBuf| Close the message buffer. |

Default key maps
------

### Normal mode

| Map          | Command            |
| ------------ | ------------------ |
|\<leader\>d   | CxxtagsOpenDecl    |
|\<leader\>D   | CxxtagsOpenDef     |
|\<leader\>r   | CxxtagsListRefs    |
|\<leader\>o   | CxxtagsListOverride    |
|\<leader\>O   | CxxtagsListOverriden   |
|\<leader\>t   | CxxtagsListTypeInfo |
|\<leader\>u   | CxxtagsUpdateDbFile |
|\<leader\>c   | CxxtagsCloseMsgBuf |

### Message Buffer
You can also use keys below in a message buffer.

| Map          | Description            |
| ------------ | ------------------ |
|\<CR\> | Display a location a listed item mentions about. |
|q | Close the message buffer. |
|b | Back to the original location in a source file. |

Variables
------

|Name                 | Default value     | Description |
| ------------------- | ----------------- | ----------- |
|CXXTAGS_DatabaseDir  | "./db"            | Path to a cxxtags database directory. |
|CXXTAGS_Cmd          | "cxxtags_query"   | Location of *cxxtags_query* command. This default value assumes *cxxtags_query* to be under the serach path. Absolute path to *cxxtags_query* is also acceptable.|
|CXXTAGS_MsgBufName   | "cxxtags_msg"     | Name of the message buffer which a reference list is printed to|
|CXXTAGS_DbManager    | "cxxtags_db_manager" | Location of *cxxtags_db_manager* command. |

This script can be configured by changing these variables. Use *let* command to set value to these variables like below.

     let CXXTAGS_DatabaseDir = "./tag_db"

