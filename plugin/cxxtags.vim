command! -nargs=0 CxxtagsOpenDecl :call cxxtags#JumpToDeclaration()
command! -nargs=0 CxxtagsOpenRefs :call cxxtags#PrintAllReferences()
command! -nargs=0 CxxtagsOpenDef :call cxxtags#JumpToDefinition()
command! -nargs=0 CxxtagsTagJump :call cxxtags#TagJump()
command! -nargs=0 CxxtagsCloseMsgBuf :call cxxtags#CloseMsgBuf()
nnoremap <silent> <leader>d :CxxtagsOpenDecl<CR>
nnoremap <silent> <leader>r :CxxtagsOpenRefs<CR>
nnoremap <silent> <leader>D :CxxtagsOpenDef<CR>
nnoremap <silent> <leader>c :CxxtagsCloseMsgBuf<CR>
