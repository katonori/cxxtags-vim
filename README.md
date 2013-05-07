cxxtags-vim
======

What is this?
------
**cxxtags-vim** is vim front-end for cxxtags. This script perform these features.

* Jump to a declaration
* Jump to a definition
* List all the references

Requirement
------
**cxxtags** ver2.0b or higher.

How to install
------
Copy *plugin* and *autoload* directory to your vim script directory.
Or type `make install` to install these scripts to `~/.vim`. 

Commands
------
|Name              | Description |
| ---------------- | ------------------- |
|CxxtagsOpenDecl   | Jump to the declaration of a item under the cursor.|
|CxxtagsOpenDef    | Jump to the definition of a item under the cursor.|
|CxxtagsListRefs   | List all the references to a item under the cursor to the message buffer.|
|CxxtagsCloseMsgBuf| Close the message buffer. |

Default key maps
------
| Map          | Command            |
| ------------ | ------------------ |
|\<leader\>d   | CxxtagsOpenDecl    |
|\<leader\>D   | CxxtagsOpenDef     |
|\<leader\>r   | CxxtagsListRefs    |
|\<leader\>c   | CxxtagsCloseMsgBuf |

Variables
------

|Name                 | Default value     | Description |
| ------------------- | ----------------- | ----------- |
|CXXTAGS_DatabaseDir  | "./db"            | Path to a cxxtags database directory. |
|CXXTAGS_Cmd          | "cxxtags_query"   | Location of *cxxtags_query* command. This default value assumes *cxxtags_query* to be under the serach path. Absolute path to *cxxtags_query* is also acceptable.|
|CXXTAGS_MsgBufName   | "cxxtags_msg"     | Name of the message buffer which a reference list is printed to|

This script can be configured by changing these variables. Use *let* command to set value to these variables like below.

     let CXXTAGS_DatabaseDir = "./tag_db"

