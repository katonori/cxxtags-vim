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
function! s:setInitValueStr(name, val)
    if !exists(a:name)
        exec "let " . a:name . "='" . a:val . "'"
    endif
endfunction

call s:setInitValueStr("g:CXXTAGS_MsgBufName", "cxxtags_msg")
call s:setInitValueStr("g:CXXTAGS_Cmd", "cxxtags_query")
call s:setInitValueStr("g:CXXTAGS_DatabaseDir", "db")
call s:setInitValueStr("g:CXXTAGS_DbManager", "cxxtags_db_manager")
if !exists("g:CXXTAGS_Debug")
    let g:CXXTAGS_Debug = 0
endif

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
command! -nargs=0 CxxtagsUpdateDbFile :call cxxtags#updateDbFile(1)
command! -nargs=0 CxxtagsTagJump :call cxxtags#TagJumpFromMsgBuf()
command! -nargs=0 CxxtagsSearchDb :call cxxtags#SearchDb()
