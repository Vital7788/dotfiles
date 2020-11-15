
        let b:libraries=''
        compiler junit
        let b:classpath='-cp .:out:/opt/hamcrest-2.2.jar:/opt/junit-4.13.jar' . b:libraries . ' '
        let b:modulepath=''
        let b:files='org.junit.runner.JUnitCore SimpleTest'
