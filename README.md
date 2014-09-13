cxxtags-vim
======

What is this?
------
**cxxtags-vim** is vim front-end for cxxtags. This script performs these features.

* Jump to a declaration
* Jump to a definition
* List all the references
* List all the overrides/overriden information

Requirement
------
[**cxxtags**](https://github.com/katonori/cxxtags)

How to install
------
Use [Vundle](https://github.com/gmarik/Vundle.vim) or [pathogen](https://github.com/tpope/vim-pathogen) or similar vim plugin management system.

If you use Vundle, Add the line below to your ~/.vimrc.

        Bundle 'katonori/cxxtags-vim'

If you use pathogen, clone the repository to your bundle directory.

        cd ~/.vim/bundle/
        git clone https://github.com/katonori/cxxtags-vim

Commands
------
|Name              | Description |
| ---------------- | ------------------- |
|CxxtagsOpenDecl   | Jump to the declaration of an item under the cursor.|
|CxxtagsOpenDef    | Jump to the definition of an item under the cursor.|
|CxxtagsListRefs   | List all the references to an item under the cursor to the message buffer.|
|CxxtagsListOverride  | List all the items which an item under the cursor overrides.|
|CxxtagsListOverriden | List all the items overriden by an item under the cursor.|
|CxxtagsUpdateDbFile|Update a database file of the source file opened in current buffer.|

Key maps
------
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

This script can be configured by changing these variables. Use *let* command to set value to these variables like below.

     let CXXTAGS_DatabaseDir = "./tag_db"

