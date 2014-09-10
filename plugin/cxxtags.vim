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
call s:setInitValueStr("g:CXXTAGS_DatabaseDir", "_db")
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
command! -nargs=0 CxxtagsUpdateDbFile :call cxxtags#updateDbFile()
command! -nargs=0 CxxtagsTagJump :call cxxtags#TagJumpFromMsgBuf()
command! -nargs=0 CxxtagsSearchDb :call cxxtags#SearchDb()

let s:COL_NAME = 0
let s:COL_FILE_NAME = 1
let s:COL_LINE_NO = 2
let s:COL_COL_NO = 3
let s:COL_TYPE_KIND = 4

"
" update a database file
"
function! cxxtags#updateDbFile()
    if s:curSrcFilename == ""
        call s:getCurPos()
    endif
    let l:cmd = g:CXXTAGS_Cmd . " rebuild " . g:CXXTAGS_DatabaseDir . " " . s:curSrcFilename
    if g:CXXTAGS_Debug != 0
        echo l:cmd
    endif
    call system(l:cmd)
    if v:shell_error != 0
        echo "ERROR: command execution failed.: " . l:cmd
        return
    endif
endfunction

"
" goto the head of a word.
"
function! s:gotoHeadOfItem()
    execute ":normal wb"
endfunction

"
" check database directory
"
function! s:checkEnv()
    if !isdirectory(g:CXXTAGS_DatabaseDir)
        echo "ERROR: cxxtags database \"" . g:CXXTAGS_DatabaseDir . "\" is not found."
        return 1
    endif

    " check if the query command is under search path.
    let l:cmd = "which " . g:CXXTAGS_Cmd
    let l:result = system("which " . g:CXXTAGS_Cmd)
    if v:shell_error != 0
        echo "ERROR: command execution failed.: " . l:cmd
        return
    endif
    if "" == l:result
        echo "ERROR: " . g:CXXTAGS_Cmd . " is not found."
        return 1
    endif
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
    if 0 != s:checkEnv()
        return
    endif
    call s:getCurPos()
    "call cxxtags#updateDbFile(0)

    let l:cmd = g:CXXTAGS_Cmd . " " . a:table . " " . g:CXXTAGS_DatabaseDir . " " . s:curSrcFilename . " " . s:curSrcLineNo . " " . s:curSrcColNo
    if g:CXXTAGS_Debug != 0
        echo "DBG: " . l:cmd
    endif
    let l:result = substitute(system(l:cmd), "\n", "", "g")
    if v:shell_error != 0
        echo "ERROR: command execution failed.: " . l:cmd
        return
    endif
    let l:resultList = split(l:result, "|")
    if len(l:resultList) == 0
        echo a:kind . " is not found.: " . s:curWord
        echo "command: " . l:cmd
    else
        execute ":e " . l:resultList[s:COL_FILE_NAME]
        call cursor(l:resultList[s:COL_LINE_NO], l:resultList[s:COL_COL_NO])
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
    if 0 != s:checkEnv()
        return
    endif
    call s:getCurPos()
    "call cxxtags#updateDbFile(0)

    let l:cmd = g:CXXTAGS_Cmd . " " . a:table . " " . g:CXXTAGS_DatabaseDir . " " . s:curSrcFilename . " " . s:curSrcLineNo . " " . s:curSrcColNo
    if g:CXXTAGS_Debug != 0
        echo l:cmd
    endif
    let l:resultList = split(system(l:cmd), "\n")
    if v:shell_error != 0
        echo "ERROR: command execution failed.: " . l:cmd
        return
    endif
    let l:maxFileNameLen = 0
    let l:maxLineNoLen = 0
    let l:maxColNoLen = 0
    let l:fileList = []
    let l:lineNoList = []
    let l:colNoList = []
    let l:lineOfSrcList = []

    for l:result in resultList
        let l:columns = split(l:result, "|", 1)
        " get a line from a source file
        let l:lineBuf = readfile(l:columns[s:COL_FILE_NAME])
        let l:lineOfSrc = l:lineBuf[l:columns[s:COL_LINE_NO]-1]

        " keep the max number for printing
        let l:len = strlen(l:columns[s:COL_FILE_NAME])
        if l:len > l:maxFileNameLen
            let l:maxFileNameLen = l:len
        endif
        let l:len = str2nr(l:columns[s:COL_LINE_NO], 10)
        if l:len > l:maxLineNoLen
            let l:maxLineNoLen = l:len
        endif
        let l:len = str2nr(l:columns[s:COL_COL_NO], 10)
        if l:len > l:maxColNoLen
            let l:maxColNoLen = l:len
        endif

        call add(l:fileList, l:columns[s:COL_FILE_NAME])
        call add(l:lineNoList, l:columns[s:COL_LINE_NO])
        call add(l:colNoList, l:columns[s:COL_COL_NO])
        call add(l:lineOfSrcList, l:lineOfSrc)
    endfor

    " decide the number of digits for printing
    let l:msg = []
    let l:msgLine = ""
    let l:lineDigits = s:getDigits(l:maxLineNoLen)
    let l:colDigits = s:getDigits(l:maxColNoLen)
    let l:i = 0
    while l:i < len(l:fileList)
        let l:msgLine = printf("%s:%d:%d:%s", l:fileList[i], l:lineNoList[i], l:colNoList[i], l:lineOfSrcList[i])
        call add(l:msg, substitute(l:msgLine, "\n", "", "g"))
        let i += 1
    endwhile

    if len(l:msg) == 0
        echo "No " . a:kind . " are found.: " . s:curWord
        cexpr ""
    else
        " add the current position to jumplist
        setlocal errorformat=%f:%l:%c:%m
        cexpr l:msg
        copen
    endif
endfunction

"
" print type information
"
function! cxxtags#PrintTypeInfo()
    if 0 != s:checkEnv()
        return
    endif
    call s:getCurPos()
    "call cxxtags#updateDbFile(0)

    let l:cmd = g:CXXTAGS_Cmd . " type " . g:CXXTAGS_DatabaseDir . " " . s:curSrcFilename . " " . s:curSrcLineNo . " " . s:curSrcColNo
    if g:CXXTAGS_Debug != 0
        echo l:cmd
    endif
    let l:resultList = split(system(l:cmd), "\n")
    if v:shell_error != 0
        echo "ERROR: command execution failed.: " . l:cmd
        return
    endif
    let l:maxTypeNameLen = 0
    let l:maxNameLen = 0
    let l:maxFileNameLen = 0
    let l:maxLineNoLen = 0
    let l:maxColNoLen = 0
    let l:typeNameList = []
    let l:nameList = []
    let l:fileList = []
    let l:lineNoList = []
    let l:colNoList = []
    let l:typeKindList = []
    let l:lineOfSrcList = []
    let l:COL_TYPE_TYPE_NAME = 0
    let l:COL_TYPE_NAME = 1
    let l:COL_TYPE_FILE_NAME = 2
    let l:COL_TYPE_LINE_NO = 3
    let l:COL_TYPE_COL_NO = 4
    let l:COL_TYPE_KIND = 5

    " parse command output 
    for l:result in resultList
        let l:columns = split(l:result, "|", 1)
        " get a line from a source file
        let l:lineBuf = readfile(l:columns[l:COL_TYPE_FILE_NAME])
        let l:lineOfSrc = l:lineBuf[l:columns[l:COL_TYPE_LINE_NO]-1]

        " keep the max number for printing
        let l:len = strlen(l:columns[l:COL_TYPE_TYPE_NAME])
        if l:len > l:maxTypeNameLen
            let l:maxTypeNameLen = l:len
        endif
        let l:len = strlen(l:columns[l:COL_TYPE_NAME])
        if l:len > l:maxNameLen
            let l:maxNameLen = l:len
        endif
        let l:len = strlen(l:columns[l:COL_TYPE_FILE_NAME])
        if l:len > l:maxFileNameLen
            let l:maxFileNameLen = l:len
        endif
        let l:len = str2nr(l:columns[l:COL_TYPE_LINE_NO], 10)
        if l:len > l:maxLineNoLen
            let l:maxLineNoLen = l:len
        endif
        let l:len = str2nr(l:columns[l:COL_TYPE_COL_NO], 10)
        if l:len > l:maxColNoLen
            let l:maxColNoLen = l:len
        endif

        if l:columns[l:COL_TYPE_TYPE_NAME] == ""
            call add(l:typeNameList, "<anonymous>")
        else
            call add(l:typeNameList, l:columns[l:COL_TYPE_TYPE_NAME])
        endif
        call add(l:nameList, l:columns[l:COL_TYPE_NAME])
        call add(l:fileList, l:columns[l:COL_TYPE_FILE_NAME])
        call add(l:lineNoList, l:columns[l:COL_TYPE_LINE_NO])
        call add(l:colNoList, l:columns[l:COL_TYPE_COL_NO])
        call add(l:typeKindList, l:columns[l:COL_TYPE_KIND])
        call add(l:lineOfSrcList, l:lineOfSrc)
    endfor

    let l:msg = []
    let l:msgLine = ""
    " decide the number of digits for printing
    let l:lineDigits = s:getDigits(l:maxLineNoLen)
    let l:colDigits = s:getDigits(l:maxColNoLen)
    let l:i = 0
    " print to string buff
    while l:i < len(l:fileList)
        let l:msgLine = printf("%-" . l:maxFileNameLen . "s:%" . l:lineDigits . "d,%" . l:colDigits . "d:%-" . l:maxTypeNameLen . "s:%-" . l:maxNameLen . "s:%-8s:%s", l:fileList[i], l:lineNoList[i], l:colNoList[i], l:typeNameList[i], l:nameList[i], l:typeKindList[i], l:lineOfSrcList[i])
        call add(l:msg, substitute(l:msgLine, "\n", "", "g"))
        let i += 1
    endwhile

    if len(l:msg) == 0
        echo "No type info are found.: " . s:curWord
    else
        " add the current position to jumplist
        exec "normal L"
        " show result
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
" Search & guess database directory from g:CXXTAGS_DatabaseDir definition and
" current directory.
"
function! cxxtags#SearchDb()
    let l:dbName = fnamemodify(g:CXXTAGS_DatabaseDir, ":t")
    let l:path = expand("%:p:h")
    let l:pathPrev = ""
    let l:pathRoot = "/"
    while 1
        let l:dbPath = l:path . "/" . l:dbName
        if isdirectory(l:dbPath)
            " found
            let g:CXXTAGS_DatabaseDir = l:dbPath
            echo "database dir was found: " . l:dbPath
            break
        endif
        " next path
        let l:pathPrev = l:path
        let l:path = fnamemodify(l:path, ":h")
        if l:path == l:pathPrev
            break
        endif
    endwhile
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
function! cxxtags#goBack()
    exec s:winNumSrcFile . "wincmd w"
    exec "e " . s:curSrcFilename
    call cursor(s:curSrcLineNo, s:curSrcColNo)
    exec s:winNumMsgBuf . "wincmd w"
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
    execute "bo 10new " . g:CXXTAGS_MsgBufName
    execute "set buftype=nofile"
    execute "set filetype=cpp"
    setlocal nonumber
    let s:winNumMsgBuf = bufwinnr(g:CXXTAGS_MsgBufName)
    nnoremap <buffer> <CR> :CxxtagsTagJump<CR>
    nnoremap <buffer> q :call cxxtags#CloseMsgBuf()<CR>
    nnoremap <buffer> b :call cxxtags#goBack()<CR>
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
    exec "call cursor(" . a:lineNo . "," . a:colNo .")"
    exec "normal zz"
endfunction

"
" close a message buffer
"
function! cxxtags#CloseMsgBuf()
    exec s:winNumMsgBuf . "wincmd w"
    exec "wincmd c"
    exec s:winNumSrcFile . "wincmd w"
endfunction
