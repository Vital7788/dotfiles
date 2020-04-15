" add junit to classpath
let s:classpath='.:/opt/junit-4.13.jar'

" check if there is a src/ directory
if stridx(expand('%:p'), '/src/') != -1
    " set path to src/ directory
    let s:path=expand('%:p')[:stridx(expand('%:p'), '/src/') + 3]
    " set library directory in same folder as src/
    let s:libpath=fnamemodify(s:path, ':h') . '/lib'
    " cd to root
    execute 'cd ' fnamemodify(s:path, ':h')
    set path=src
    " set destination directory for class files to out/ and
    " search recursively in src/
    let s:path='-d out ' . s:path . '/**'
else
    let s:path=expand('%:p:h')
    let s:libpath=s:path
endif

" add files from lib/ to classpath if lib/ exists
if isdirectory(s:libpath)
    let b:libraries.=':' . join(split(globpath(s:libpath , '*')), ':')
endif

let &l:makeprg='javac -cp ' . s:classpath . b:libraries . ' ' . s:path . '/*.java'
