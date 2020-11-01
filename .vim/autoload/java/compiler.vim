" handle compiler selection
function! java#compiler#JavaCompilerMenuHandler(id, result)

    " junit
    if a:result == 1
        let b:libraries=''
        compiler junit
        let b:classpath='-cp .:out:/opt/hamcrest-2.2.jar:/opt/junit-4.13.jar' . b:libraries . ' '
        let b:modulepath=''
        let b:files='org.junit.runner.JUnitCore SimpleTest'

    " javafx
    elseif a:result == 2
        execute 'cd ' finddir('src/..', ';')
        set path=.,src
        compiler javafx
        let b:classpath='-cp out '
        let b:modulepath='-p /opt/javafx-sdk-11.0.2/lib:lib:out '
        let b:files='-m ' . expand('%:p:h:t') . '/' . expand('%:p:h:t') . '.Main'

    " java
    elseif a:result == 3
        compiler java
        let b:classpath=''
        let b:modulepath=''
        let b:files='*.java'

    endif
endfunction

" Interface function
function! java#compiler#JavaCompilerSelect() abort
    call select_makeprg#SelectorPopupWindow(['junit', 'javafx', 'java'], 'compiler')
endfunction
