let s:refDatasDecl = []
let s:inDatasDecl = []
let s:refDatasDef = []
let s:inDatasDef = []
let s:inDatasRef = []
let s:refDatasRef = []
let s:inDatasOverride = []
let s:refDatasOverride = []
let s:inDatasOverrideN = []
let s:refDatasOverrideN = []

function! s:init()
    let l:fileName = expand("%:p")
    "
    " declarations
    "
    call add(s:inDatasDecl, { 'line':77, 'col':12 })
    call add(s:inDatasDecl, { 'line':78, 'col':11 })

    call add(s:refDatasDecl, { 'line':8, 'col':18 })
    call add(s:refDatasDecl, { 'line':33, 'col':18 })

    "
    " definitions
    "
    call add(s:inDatasDef, { 'line':77, 'col':12 })
    call add(s:inDatasDef, { 'line':79, 'col':12 })

    call add(s:refDatasDef, { 'line':11, 'col':16 })
    call add(s:refDatasDef, { 'line':49, 'col':15 })

    "
    " references
    "
    call add(s:inDatasRef, { 'line':8, 'col':18 })
    let l:tmpList = []
    call add(l:tmpList, l:fileName . ":68, 8:    a->response();")
    call add(l:tmpList, l:fileName . ":77,12:    parent.response();")
    call add(s:refDatasRef, l:tmpList)

    call add(s:inDatasRef, { 'line':36, 'col':14 })
    let l:tmpList = []
    call add(l:tmpList, l:fileName . ":78,11:    child.response();")
    call add(s:refDatasRef, l:tmpList)

    "
    " override
    "
    call add(s:inDatasOverride, { 'line':46, 'col':18 })
    let l:tmpList = []
    call add(l:tmpList, l:fileName . ":33,18:    virtual void response(void);")
    call add(l:tmpList, l:fileName . ":36,14:void CChild::response(void) {")
    call add(s:refDatasOverride, l:tmpList)

    call add(s:inDatasOverride, { 'line':62, 'col':14 })
    let l:tmpList = []
    call add(l:tmpList, l:fileName . ": 8,18:    virtual void response(void);")
    call add(l:tmpList, l:fileName . ":11,16:void CParent0::response(void) {")
    call add(l:tmpList, l:fileName . ":20,18:    virtual void response(void);")
    call add(l:tmpList, l:fileName . ":23,16:void CParent1::response(void) {")
    call add(s:refDatasOverride, l:tmpList)

    "
    " overriden
    "
    call add(s:inDatasOverrideN, { 'line':8, 'col':18 })
    let l:tmpList = []
    call add(l:tmpList, l:fileName . ":33,18:    virtual void response(void);")
    call add(l:tmpList, l:fileName . ":36,14:void CChild::response(void) {")
    call add(l:tmpList, l:fileName . ":59,18:    virtual void response(void);")
    call add(l:tmpList, l:fileName . ":62,14:void COther::response(void) {")
    call add(s:refDatasOverrideN, l:tmpList)

    call add(s:inDatasOverrideN, { 'line':78, 'col':11 })
    let l:tmpList = []
    call add(l:tmpList, l:fileName . ":46,18:    virtual void response(void);")
    call add(l:tmpList, l:fileName . ":49,15:void CGChild::response(void) {")
    call add(s:refDatasOverrideN, l:tmpList)

    exec "redir! > test.log"
    exec "source ../plugin/cxxtags.vim"
endfunction

" current position
let s:fileName = ""
let s:curLnum = -1
let s:curCol = -1
function! s:getCurPos()
    let s:fileName = expand("%:p")
    let l:pos = getpos(".")
    let s:curLnum = l:pos[1]
    let s:curCol = l:pos[2]
endfunction

function! s:testJump(cmd, inDatas, refDatas)
    echo "test: " . a:cmd . ": " . len(a:inDatas)
    let l:i = 0
    while l:i < len(a:inDatas)
        call cursor(a:inDatas[l:i].line, a:inDatas[l:i].col)
        exec a:cmd
        call s:getCurPos()
        if s:curLnum == a:refDatas[l:i].line && s:curCol == a:refDatas[l:i].col
            echo "OK"
        else
            echo "NG"
            let s:err += 1
        endif
        let l:i = l:i + 1
    endwhile
endfunction

function! s:testList(cmd, inDatas, refDatas)
    let l:i = 0
    echo "test: " . a:cmd . ": " . len(a:inDatas)
    while l:i < len(a:refDatas)
        call cursor(a:inDatas[l:i].line, a:inDatas[l:i].col)
        exec a:cmd
        let l:lines = getline(0, line("$"))
        let l:numLines = len(l:lines) - 2
        let l:numLinesRef = len(a:refDatas[l:i])
        if l:numLines != l:numLinesRef
            echo "ERROR: the number of result: act=" . l:numLines . ", ref=" . l:numLinesRef
            let s:err += 1
        endif

        let l:ln = 0
        while l:ln < l:numLines
            if l:lines[l:ln+1] != a:refDatas[l:i][l:ln]
                echo "ERROR: refs:"
                echo l:lines[l:ln+1]
                echo a:refDatas[l:i][l:ln]
                let s:err += 1
                echo "NG"
            else
                echo "OK"
            endif
            let l:ln += 1
        endwhile
        " close buffer
        exec "wincmd c"
        let l:i += 1
    endwhile
endfunction

let s:err = 0
function! s:run()
    call s:init()

    " test declarations
    call s:testJump("CxxtagsOpenDecl", s:inDatasDecl, s:refDatasDecl)
    " test definitions
    call s:testJump("CxxtagsOpenDef", s:inDatasDef, s:refDatasDef)
    " ref test
    call s:testList("CxxtagsListRefs", s:inDatasRef, s:refDatasRef)
    " override test
    call s:testList("CxxtagsListOverride", s:inDatasOverride, s:refDatasOverride)
    " overriden test
    call s:testList("CxxtagsListOverriden", s:inDatasOverrideN, s:refDatasOverrideN)

    if s:err != 0
        exec "cq"
    else
        exec "q"
    endif
endfunction

exec "call s:run()"
