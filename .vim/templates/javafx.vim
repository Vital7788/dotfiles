        execute 'cd ' finddir('src/..', ';')
        set path=.,src
        compiler javafx
        let b:classpath='-cp out '
        let b:modulepath='-p /opt/javafx-sdk-11.0.2/lib:lib:out '
        let b:files='-m ' . expand('%:p:h:t') . '/' . expand('%:p:h:t') . '.Main'
