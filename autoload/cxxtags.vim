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
" goto the head of a word.
"
function! s:gotoHeadOfItem()
    execute ":normal wb"
endfunction

"
" check database directory
"
function! s:checkDatabaseDir()
    if isdirectory(g:CXXTAGS_DatabaseDir)
        return 0
    endif
    echo "ERROR: cxxtags database \"" . g:CXXTAGS_DatabaseDir . "\" is not found."
    return 1
endfunction

"
" get current position
"
let s:curSrcFilename = ""
let s:curSrcLineNo = -1
let s:curSrcColNo = -1
let s:curSrcLine = ""
let s:curWord = ""
function! s:getCurPos()
    call s:gotoHeadOfItem()
    let s:curSrcFilename = expand("%:p")
    let s:curSrcLine = getline(".")
    let l:pos = getpos(".")
    let s:curSrcLineNo = l:pos[1]
    let s:curSrcColNo = l:pos[2]
    let s:curWord = matchstr(s:curSrcLine, '^\zs[a-zA-Z0-9_]\+\ze', s:curSrcColNo-1)
endfunction

"
" jump to a tag
"
function! s:jumpToTag(table, kind)
    if 0 != s:checkDatabaseDir()
        return
    endif
    call s:getCurPos()

    let l:cmd = g:CXXTAGS_Cmd . " " . a:table . " " . g:CXXTAGS_DatabaseDir . " " . s:curSrcFilename . " " . s:curSrcLineNo . " " . s:curSrcColNo
    let l:result = substitute(system(l:cmd), "\n", "", "g")
    let l:resultList = split(l:result, "|")
    if len(l:resultList) == 0
        echo a:kind . " is not found.: " . s:curWord
    else
        execute ":e " . l:resultList[0]
        call cursor(l:resultList[1], l:resultList[2])
        execute ":normal zz"
    endif
endfunction

"
" jump to a declaration
"
function! cxxtags#JumpToDeclaration()
    call s:jumpToTag("decl", "Declaration")
endfunction

"
" jump to a definition
"
function! cxxtags#JumpToDefinition()
    call s:jumpToTag("def", "Definition")
endfunction

"
" decide the number of digits to print.
"
function! s:getDigits(val)
    let l:digits = 2
    let l:inVal = str2nr(a:val, 10)
    if l:inVal >= 10000
        let l:digits = 6
    elseif l:inVal >= 100
        let l:digits = 4
    endif
    return l:digits
endfunction

let s:winNumMsgBuf = 0
let s:winNumSrcFile = 0
"
" list query results
"
function! cxxtags#PrintAllResults(table, kind)
    if 0 != s:checkDatabaseDir()
        return
    endif
    call s:getCurPos()

    let l:cmd = g:CXXTAGS_Cmd . " " . a:table . " " . g:CXXTAGS_DatabaseDir . " " . s:curSrcFilename . " " . s:curSrcLineNo . " " . s:curSrcColNo
    let l:resultList = split(system(l:cmd), "\n")
    let l:maxFileNameLen = 0
    let l:maxLineNoLen = 0
    let l:maxColNoLen = 0
    let l:fileList = []
    let l:lineNoList = []
    let l:colNoList = []
    let l:lineOfSrcList = []

    for l:result in resultList
        let l:columns = split(l:result, "|")
        " get a line from a source file
        let l:lineBuf = readfile(l:columns[0])
        let l:lineOfSrc = l:lineBuf[l:columns[1]-1]

        " keep the max number for printing
        let l:len = strlen(l:columns[0])
        if l:len > l:maxFileNameLen
            let l:maxFileNameLen = l:len
        endif
        let l:len = str2nr(l:columns[1], 10)
        if l:len > l:maxLineNoLen
            let l:maxLineNoLen = l:len
        endif
        let l:len = str2nr(l:columns[2], 10)
        if l:len > l:maxColNoLen
            let l:maxColNoLen = l:len
        endif

        call add(l:fileList, l:columns[0])
        call add(l:lineNoList, l:columns[1])
        call add(l:colNoList, l:columns[2])
        call add(l:lineOfSrcList, l:lineOfSrc)
    endfor

    " decide the number of digits for printing
    let l:msg = []
    let l:msgLine = ""
    let l:lineDigits = s:getDigits(l:maxLineNoLen)
    let l:colDigits = s:getDigits(l:maxColNoLen)
    let l:i = 0
    while l:i < len(l:fileList)
        let l:msgLine = printf("%-" . l:maxFileNameLen . "s:%" . l:lineDigits . "d,%" . l:colDigits . "d:%s", l:fileList[i], l:lineNoList[i], l:colNoList[i], l:lineOfSrcList[i])
        call add(l:msg, substitute(l:msgLine, "\n", "", "g"))
        let i += 1
    endwhile

    if len(l:msg) == 0
        echo "No " . a:kind . " are found.: " . s:curWord
    else
        let s:winNumMsgBuf = bufwinnr(g:CXXTAGS_MsgBufName)
        let s:winNumSrcFile = winnr()
        if s:winNumMsgBuf == -1
            call s:openMsgBuf()
        endif
        exec s:winNumMsgBuf . "wincmd w"
        " output message
        call s:updateMsgBuf(l:msg)
    endif
endfunction

"
" print all references to a message buffer
"
function! cxxtags#PrintAllReferences()
    call cxxtags#PrintAllResults("ref", "references")
endfunction

"
" print all the items overriden by the item under the cursor.
"
function! cxxtags#PrintAllOverrideNs()
    call cxxtags#PrintAllResults("overriden", "overridens")
endfunction

"
" print all the items overrides the item under the cursor.
"
function! cxxtags#PrintAllOverrides()
    call cxxtags#PrintAllResults("override", "overrides")
endfunction

"
" go back original position
"
function! s:goBack()
    exec "e " . s:curSrcFilename
    call cursor(s:curSrcLineNo, s:curSrcColNo)
endfunction

"
" update a message buffer
"
function! s:updateMsgBuf(inMsg)
    setlocal modifiable
    setlocal noreadonly
    silent! %delete _
    let l:msg = sort(a:inMsg)
    let l:firstLine = ["[go back]"]
    call append(0, l:firstLine)
    call append(1, l:msg)
    exec "0"
    setlocal nomodifiable
    setlocal readonly
endfunction

"
" open a message buffer
"
function! s:openMsgBuf()
    execute "bel 10new " . g:CXXTAGS_MsgBufName
    execute "set buftype=nofile"
    execute "set filetype=cpp"
    setlocal nonumber
    let s:winNumMsgBuf = bufwinnr(g:CXXTAGS_MsgBufName)
    nnoremap <buffer> <CR> :CxxtagsTagJump<CR>
    nnoremap <buffer> q :call cxxtags#CloseMsgBuf()<CR>
endfunction

"
" perform tag jump
"
function! cxxtags#TagJumpFromMsgBuf()
    let l:pos = getpos(".")
    let l:lineNo = l:pos[1]
    if l:lineNo == 1
        call s:openSrcFileFromMsgBuf(s:curSrcFilename, s:curSrcLineNo, s:curSrcColNo)
    else
        let l:line = getline(".")
        let l:fileName = matchstr(l:line, '^\zs[^:]\+\ze:')
        let l:lineNo = matchstr(l:line, ':\s*\zs[0-9]\+\ze,')
        let l:colNo = matchstr(l:line, ',\s*\zs[0-9]\+\ze:')
        call s:openSrcFileFromMsgBuf(l:fileName, l:lineNo, l:colNo)
    endif
    exec s:winNumMsgBuf . "wincmd w"
endfunction

function! s:openSrcFileFromMsgBuf(fileName, lineNo, colNo)
    exec s:winNumSrcFile . "wincmd w"
    exec "e " . a:fileName
    call cursor(a:lineNo, a:colNo)
    exec "normal zz"
endfunction

"
" close a message buffer
"
function! cxxtags#CloseMsgBuf()
    exec s:winNumMsgBuf . "wincmd c"
    exec s:winNumSrcFile . "wincmd w"
    exec "normal zz"
endfunction

command! -nargs=0 CxxtagsTagJump :call cxxtags#TagJumpFromMsgBuf()
