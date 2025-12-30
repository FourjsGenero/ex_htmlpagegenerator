MAIN
DEFINE arg1, arg2 STRING

   
    CLOSE WINDOW SCREEN
    OPEN WINDOW w WITH FORM "ex_htmlpagegenerator_test"
    INPUT BY NAME arg1, arg2 ATTRIBUTES(UNBUFFERED, WITHOUT DEFAULTS=TRUE, ACCEPT=FALSE)
        ON ACTION start 
            TRY
                RUN "fglrun ex_htmlpagegenerator" WITHOUT WAITING
                CATCH
        END TRY

        ON ACTION test 
            CALL ui.Interface.frontCall("standard","launchurl","http://localhost:8095/test",[])

        ON ACTION test_args
            CALL ui.Interface.frontCall("standard","launchurl",SFMT("http://localhost:8095/test?%1&%2", arg1, arg2),[])

        ON ACTION list
            CALL ui.Interface.frontCall("standard","launchurl","http://localhost:8095/list",[])

        ON ACTION form_encoded 
            CALL ui.Interface.frontCall("standard","launchurl","http://localhost:8095/form_encoded",[])

        ON ACTION storage 
            CALL ui.Interface.frontCall("standard","launchurl","http://localhost:8095/storage",[])

         ON ACTION xslt
            CALL ui.Interface.frontCall("standard","launchurl","http://localhost:8095/xslt",[])
        
    END INPUT
    CLOSE WINDOW w
END MAIN