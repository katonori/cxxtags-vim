"
" variable declarations which configure the behavior of this script
"
let g:CXXTAGS_MsgBufName = "cxxtags_msg"
let g:CXXTAGS_Cmd = "cxxtags_query"
let g:CXXTAGS_DatabaseDir = "./db"

"
" goto the head of a word.
"
function! s:gotoHead()
    execute ":normal wb"
endfunction

"
" get current position
"
let s:curSrcFilename = ""
let s:curSrcLineNo = -1
let s:curSrcColNo = -1
function! s:getCurPos()
    let s:curSrcFilename = expand("%:p")
    let l:pos = getpos(".")
    let s:curSrcLineNo = l:pos[1]
    let s:curSrcColNo = l:pos[2]
endfunction

"
" jump to a declaration
"
function! cxxtags#JumpToDeclaration()
    call s:gotoHead()
    call s:getCurPos()

    let l:cmd = g:CXXTAGS_Cmd . " decl " . g:CXXTAGS_DatabaseDir . " " . s:curSrcFilename . " " . s:curSrcLineNo . " " . s:curSrcColNo
    let l:result = substitute(system(l:cmd), "\n", "", "g")
    let l:resultList = split(l:result, "|")
    if len(l:resultList) == 0
        echo "decl not found"
    else
        execute ":e " . l:resultList[0]
        call cursor(l:resultList[1], l:resultList[2])
        execute ":normal zz"
    endif
endfunction

"
" jump to a definition
"
function! cxxtags#JumpToDefinition()
    call s:gotoHead()
    call s:getCurPos()

    let l:cmd = g:CXXTAGS_Cmd . " def " . g:CXXTAGS_DatabaseDir . " " . s:curSrcFilename . " " . s:curSrcLineNo . " " . s:curSrcColNo
    let l:result = substitute(system(l:cmd), "\n", "", "g")
    let l:resultList = split(l:result, "|")
    if len(l:resultList) == 0
        echo "def not found"
    else
        execute ":e " . l:resultList[0]
        call cursor(l:resultList[1], l:resultList[2])
        execute ":normal zz"
    endif
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
" print all references to a message buffer
"
function! cxxtags#PrintAllReferences()
    call s:gotoHead()
    call s:getCurPos()

    let l:cmd = g:CXXTAGS_Cmd . " ref " . g:CXXTAGS_DatabaseDir . " " . s:curSrcFilename . " " . s:curSrcLineNo . " " . s:curSrcColNo
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
        echo "reference not found"
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
    silent! %delete _
    let l:msg = sort(a:inMsg)
    let l:firstLine = ["[go back]"]
    call append(0, l:firstLine)
    call append(1, l:msg)
    exec "0"
    setlocal nomodifiable
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
    let s:winNumSrcFile = winnr("#")
    "nnoremap <buffer> c <C-W>c
    nnoremap <buffer> <CR> :CxxtagsTagJump<CR>
endfunction

"
" perform tag jump
"
function! cxxtags#TagJump()
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
    exec s:winNumMsgBuf . "wincmd w"
    exec "wincmd c"
    exec "normal zz"
endfunction


