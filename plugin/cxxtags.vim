" Copyright (c) 2013, katonori(katonori.d@gmail.com) All rights reserved.
" 
" Redistribution and use in source and binary forms, with or without modification, are
" permitted provided that the following conditions are met:
" 
"   1. Redistributions of source code must retain the above copyright notice, this list
"      of conditions and the following disclaimer.
"   2. Redistributions in binary form must reproduce the above copyright notice, this
"      list of conditions and the following disclaimer in the documentation and/or other
"      materials provided with the distribution.
"   3. Neither the name of the katonori nor the names of its contributors may be used to
"      endorse or promote products derived from this software without specific prior
"      written permission.
" 
" THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
" EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
" OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
" SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
" INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
" TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
" BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
" CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
" ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
" DAMAGE.

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
command! -nargs=0 CxxtagsListOverride :call cxxtags#PrintAllOverrides()
command! -nargs=0 CxxtagsListOverriden :call cxxtags#PrintAllOverrideNs()
command! -nargs=0 CxxtagsListTypeInfo :call cxxtags#PrintTypeInfo()

"
" key maps
"
nnoremap <silent> <leader>d :CxxtagsOpenDecl<CR>
nnoremap <silent> <leader>r :CxxtagsListRefs<CR>
nnoremap <silent> <leader>D :CxxtagsOpenDef<CR>
nnoremap <silent> <leader>c :CxxtagsCloseMsgBuf<CR>
nnoremap <silent> <leader>o :CxxtagsListOverride<CR>
nnoremap <silent> <leader>O :CxxtagsListOverriden<CR>
nnoremap <silent> <leader>t :CxxtagsListTypeInfo<CR>
