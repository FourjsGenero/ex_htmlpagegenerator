MAIN
DEFINE arg1, arg2 STRING

    CLOSE WINDOW SCREEN
    OPEN WINDOW w WITH FORM "ex_htmlpagegenerator_test"
    INPUT BY NAME arg1, arg2 ATTRIBUTES(UNBUFFERED, WITHOUT DEFAULTS=TRUE, ACCEPT=FALSE)
        ON ACTION test ATTRIBUTES(TEXT="Simple Test")
            CALL ui.Interface.frontCall("standard","launchurl","http://localhost:8095/test",[])

        ON ACTION test_args ATTRIBUTES(TEXT="Simple Test With Arguments")
            CALL ui.Interface.frontCall("standard","launchurl",SFMT("http://localhost:8095/test?%1&%2", arg1, arg2),[])

        ON ACTION list ATTRIBUTES(TEXT="List")
            CALL ui.Interface.frontCall("standard","launchurl","http://localhost:8095/list",[])

        ON ACTION form_encoded ATTRIBUTES(TEXT="Form Encoded")
            CALL ui.Interface.frontCall("standard","launchurl","http://localhost:8095/form_encoded",[])

        ON ACTION storage ATTRIBUTES(TEXT="Storage")
            CALL ui.Interface.frontCall("standard","launchurl","http://localhost:8095/storage",[])
        
    END INPUT
    CLOSE WINDOW w
END MAIN