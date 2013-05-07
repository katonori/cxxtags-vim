"
" variable declarations which configure the behavior of this script
"
let g:CXXTAGS_MsgBufName = "cxxtags_msg"
let g:CXXTAGS_Cmd = "cxxtags_query"
let g:CXXTAGS_DatabaseDir = "./db"

"
" commands
"
command! -nargs=0 CxxtagsOpenDecl :call cxxtags#JumpToDeclaration()
command! -nargs=0 CxxtagsListRefs :call cxxtags#PrintAllReferences()
command! -nargs=0 CxxtagsOpenDef :call cxxtags#JumpToDefinition()
command! -nargs=0 CxxtagsCloseMsgBuf :call cxxtags#CloseMsgBuf()

"
" key maps
"
nnoremap <silent> <leader>d :CxxtagsOpenDecl<CR>
nnoremap <silent> <leader>r :CxxtagsListRefs<CR>
nnoremap <silent> <leader>D :CxxtagsOpenDef<CR>
nnoremap <silent> <leader>c :CxxtagsCloseMsgBuf<CR>
