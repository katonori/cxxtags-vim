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
|CxxtagsSearchDb | Guess database directory from *CXXTAGS\_DatabaseDir* value. Move upward from current directory to root directory and check if the directory that name is the same as the one specified in *CXXTAGS\_DatabaseDir* exists. |

Key maps
------
### Message Buffer
These key mappings are set in message buffer.

| Map          | Description            |
| ------------ | ------------------ |
|\<CR\> | Display a location a listed item mentions about. |
|q | Close the message buffer. |
|b | Back to the original location in a source file. |

### Normal mode
Key mapping are not set for normal mode by default. Please set by yourself.
These are key mapping example. Copy & paste these lines to your `~/.vimrc.`

    nnoremap <unique> <silent> <leader>d :CxxtagsOpenDecl<CR>
    nnoremap <unique> <silent> <leader>r :CxxtagsListRefs<CR>
    nnoremap <unique> <silent> <leader>D :CxxtagsOpenDef<CR>
    nnoremap <unique> <silent> <leader>q :CxxtagsCloseMsgBuf<CR>
    nnoremap <unique> <silent> <leader>o :CxxtagsListOverride<CR>
    nnoremap <unique> <silent> <leader>O :CxxtagsListOverriden<CR>
    nnoremap <unique> <silent> <leader>t :CxxtagsListTypeInfo<CR>
    nnoremap <unique> <silent> <leader>u :CxxtagsUpdateDbFile<CR>

Variables
------

|Name                 | Default value     | Description |
| ------------------- | ----------------- | ----------- |
|CXXTAGS\_DatabaseDir  | "./\_db"            | Path to a cxxtags database directory. |
|CXXTAGS\_Cmd          | "cxxtags\_query"   | Location of *cxxtags\_query* command. This default value assumes *cxxtags\_query* to be under the serach path. Absolute path to *cxxtags\_query* is also acceptable.|
|CXXTAGS\_MsgBufName   | "cxxtags\_msg"     | Name of the message buffer which a reference list is printed to|
|CXXTAGS\_DbManager    | "cxxtags\_db\_manager" | Location of *cxxtags\_db\_manager* command. |

This script can be configured by changing these variables. Use *let* command to set value to these variables like below.

     let CXXTAGS_DatabaseDir = "./tag_db"

