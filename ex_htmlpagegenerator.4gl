IMPORT com
IMPORT xml



MAIN
DEFINE req com.HttpServiceRequest

DEFINE scheme, ipaddress, path, args STRING
DEFINE port INTEGER

DEFINE ok BOOLEAN
DEFINE page_result xml.DomDocument

    
    CONNECT TO ":memory:+driver='dbmsqt'"
    CALL init_database()
    
    -- Initialize server
    CALL com.WebServiceEngine.Start()
  
    WHILE TRUE      
        LET req = com.WebServiceEngine.GetHttpServiceRequest(60)
        IF req IS NULL THEN
            EXIT PROGRAM
        END IF

        -- Process request
        CALL parse_url(req.getUrl()) RETURNING
            scheme, ipaddress, port, path, args
        --DISPLAY scheme, ipaddress, port, path, args 

        IF path IS NULL THEN -- really bad url
            CALL req.sendResponse(500, NULL)
        ELSE
            CASE path
                WHEN "test"
                    -- Generate a simple HTML page, passing the arguments.
                    CALL generate_page_test(args) RETURNING ok, page_result
                    IF ok THEN
                        -- Return success and the page
                        CALL req.setResponseHeader("Content-Type","text/html")
                        CALL req.sendTextResponse(200,NULL,page_result.saveToString())
                    ELSE
                        -- Unable to generate page
                        CALL req.sendResponse(400, NULL)
                    END IF

                WHEN "record"
                    -- Generate a simple HTML page, passing the arguments.
                    CALL generate_page_record(args) RETURNING ok, page_result
                    IF ok THEN
                        -- Return success and the page
                        CALL req.setResponseHeader("Content-Type","text/html")
                        CALL req.sendTextResponse(200,NULL,page_result.saveToString())
                    ELSE
                        -- Unable to generate page
                        CALL req.sendResponse(400, NULL)
                    END IF

                WHEN "list"
                 -- Generate a simple List page, passing the arguments.
                    CALL generate_page_list() RETURNING ok, page_result
                    IF ok THEN
                        -- Return success and the page
                        CALL req.setResponseHeader("Content-Type","text/html")
                        CALL req.sendTextResponse(200,NULL,page_result.saveToString())
                    ELSE
                        -- Unable to generate page
                        CALL req.sendResponse(400, NULL)
                    END IF

                WHEN "storage"
                    CALL generate_page_storage() RETURNING ok, page_result
                    IF ok THEN
                        -- Return success and the page
                        CALL req.setResponseHeader("Content-Type","text/html")
                        CALL req.sendTextResponse(200,NULL,page_result.saveToString())
                    ELSE
                        -- Unable to generate page
                        CALL req.sendResponse(400, NULL)
                    END IF
                    
                WHEN "form_encoded"
                    -- Generate a simple form encoded page
                    CALL generate_page_form_encoded() RETURNING ok, page_result
                    IF ok THEN
                        -- Return success and the page
                        CALL req.setResponseHeader("Content-Type","text/html")
                        CALL req.sendTextResponse(200,NULL,page_result.saveToString())
                    ELSE
                        -- Unable to generate page
                        CALL req.sendResponse(400, NULL)
                    END IF

                 WHEN "form_encoded_result"
                    -- Generate a simple List page, passing the arguments.
                    CALL generate_page_form_encoded_result((req.readFormEncodedRequest(TRUE))) RETURNING ok, page_result
                    IF ok THEN
                        -- Return success and the page
                        CALL req.setResponseHeader("Content-Type","text/html")
                        CALL req.sendTextResponse(200,NULL,page_result.saveToString())
                    ELSE
                        -- Unable to generate page
                        CALL req.sendResponse(400, NULL)
                    END IF

                WHEN "xslt"
                    CALL RunXSLP("xslt_example.xslt", "xslt_example.xml") RETURNING ok, page_result
                    DISPLAY ok
                    DISPLAY page_result.saveToString()
                    IF ok THEN
                         -- Return success and the page
                        CALL req.setResponseHeader("Content-Type","text/html")
                        CALL req.sendTextResponse(200,NULL,page_result.saveToString())
                    ELSE
                        -- Unable to generate page
                        CALL req.sendResponse(400, NULL)
                    END IF
                
                   
                OTHERWISE -- path value doesn't make sense
                    CALL req.sendResponse(400, NULL)
            END CASE
        END IF
    END WHILE
END MAIN



FUNCTION parse_url(url)
DEFINE url STRING
DEFINE pos1, pos2 INTEGER

DEFINE scheme, ipaddress, path, args STRING
DEFINE port INTEGER

    -- Parse url based on scheme://ipaddress:port/path?arguments
    
    LET pos2 = url.getIndexOf("://",1)
    IF pos2 > 0 THEN
        LET scheme = url.SubString(1,pos2)
    END IF

    IF pos2 > 0 THEN
        LET pos1 = pos2+3
    ELSE
        LET pos1 = 1
    END IF
    LET pos2 = url.getIndexOf("/",pos1)
    
    IF pos2 > 1 THEN
        LET ipaddress = url.subString(pos1,pos2-1)
        LET pos1 = ipaddress.getIndexOf(":",1)
        IF pos1>1 THEN
            LET port = ipaddress.subString(pos1+1,ipaddress.getLength())
            LET ipaddress = ipaddress.subString(1,pos1-1)
        ELSE
            # No port, use default according to scheme
            LET port = 0
            IF scheme.equalsIgnoreCase("http") THEN
                LET port = 80
            END IF
            IF scheme.equalsIgnoreCase("https") THEN
                LET port = 443
            END IF
        END IF
    END IF

    # Extract path and query
    LET pos1 = pos2+1
    LET pos2 = url.getIndexOf("?",pos1)
    IF pos2 > 1 THEN
        LET path = url.subString(pos1,pos2-1)
        LET args = url.subString(pos2+1, url.getLength())
    ELSE
        LET path = url.subString(pos1, url.getLength())
        LET args = NULL
    END IF
    RETURN scheme, ipaddress, port, path, args
END FUNCTION



FUNCTION generate_page_test(args)
DEFINE args STRING
DEFINE doc xml.DomDocument
DEFINE root, head, body, text_node xml.DomNode

    LET doc = xml.DomDocument.CreateDocument("html")
    CALL doc.setFeature("whitespace-in-element-content",FALSE)
    LET root = doc.getDocumentElement()
    LET head = root.appendChildElement("head")
    LET body = root.appendChildElement("body")

    -- create a simple text node
    LET text_node = doc.createTextNode(SFMT("This is test page, arguments passed were ... %1", args))
    CALL body.appendChild(text_node)

    RETURN TRUE, doc
END FUNCTION



-- illustrate reading many rows from a database table
FUNCTION generate_page_list()
DEFINE doc xml.DomDocument
DEFINE root, head, body, table, tr, td, a, text_node xml.DomNode
DEFINE country_name STRING

    LET doc = xml.DomDocument.CreateDocument("html")
    CALL doc.setFeature("whitespace-in-element-content",FALSE)
    LET root = doc.getDocumentElement()
    LET head = root.appendChildElement("head")
    LET body = root.appendChildElement("body")

    LET table = body.appendChildElement("table")
    DECLARE country_list_curs CURSOR FROM "SELECT name FROM country ORDER BY name"
    FOREACH country_list_curs INTO country_name
        LET tr = table.appendChildElement("tr")
        LET td = tr.appendChildElement("td")
        LET a = td.appendChildElement("a")
        LET text_node = doc.createTextNode(country_name)
        CALL a.setAttribute("href",SFMT("record?Arg=%1", country_name))
        CALL a.appendChild(text_node)
    END FOREACH
    RETURN TRUE, doc
END FUNCTION


-- illustrate reading one row from a database table and displaying it
FUNCTION generate_page_record(country_name)
DEFINE country_name STRING
DEFINE doc xml.DomDocument
DEFINE root, head, body, a,br, text_node xml.DomNode

    LET doc = xml.DomDocument.CreateDocument("html")
    CALL doc.setFeature("whitespace-in-element-content",FALSE)
    LET root = doc.getDocumentElement()
    LET head = root.appendChildElement("head")
    LET body = root.appendChildElement("body")

    LET a= body.appendChildElement("a")
    CALL a.setAttribute("href","javascript:history.back()")
    LET text_node = doc.createTextNode("Back")
    CALL a.appendChild(text_node) 

    LET br =  body.appendChildElement("br")
    LET br =  body.appendChildElement("br")

    DECLARE country_rec_curs CURSOR FROM "SELECT name FROM country WHERE name = ? "
    OPEN country_rec_curs USING country_name
    FETCH country_rec_curs INTO country_name

    -- create a simple text node
    LET text_node = doc.createTextNode(SFMT("%1", country_name))
    CALL body.appendChild(text_node)

    RETURN TRUE, doc
END FUNCTION



FUNCTION generate_page_storage()
DEFINE doc xml.DomDocument
DEFINE root, head, body, script, p, div, button, text_node xml.DomNode

    LET doc = xml.DomDocument.CreateDocument("html")
    CALL doc.setFeature("whitespace-in-element-content",FALSE)
    LET root = doc.getDocumentElement()
    LET head = root.appendChildElement("head")
    LET script = head.appendChildElement("script")
    LET text_node = doc.createTextNode('function clickCounterSession() {\
    if(typeof(Storage) !== "undefined") {\
        if (sessionStorage.clickcount) {\
            sessionStorage.clickcount = Number(sessionStorage.clickcount)+1;\
        } else { \
            sessionStorage.clickcount = 1;\
        }\
        document.getElementById("result_session").innerHTML = "You have clicked the Session Storage button " + sessionStorage.clickcount + " time(s) in this session.";\
    } else {\
        document.getElementById("result_session").innerHTML = "Sorry, your browser does not support web storage...";\
    }\
}')
    CALL script.appendChild(text_node)
    LET script = head.appendChildElement("script")
    LET text_node = doc.createTextNode('function clickCounterLocal() {\
    if(typeof(Storage) !== "undefined") {\
        if (localStorage.clickcount) {\
            localStorage.clickcount = Number(localStorage.clickcount)+1;\
        } else { \
            localStorage.clickcount = 1;\
        }\
        document.getElementById("result_local").innerHTML = "You have clicked the Local Storage button " + localStorage.clickcount + " time(s)";\
    } else {\
        document.getElementById("result_local").innerHTML = "Sorry, your browser does not support web storage...";\
    }\
}')
    CALL script.appendChild(text_node)

    
    LET body = root.appendChildElement("body")
    LET p  = body.appendChildElement("p")
    LET button = p.appendChildElement("button")
    CALL button.setAttribute("onclick","clickCounterSession()")
    CALL button.setAttribute("type","button")
    LET text_node = doc.createTextNode("Click me! (Session)")
    CALL button.appendChild(text_node)

    LET button = p.appendChildElement("button")
    CALL button.setAttribute("onclick","clickCounterLocal()")
    CALL button.setAttribute("type","button")
    LET text_node = doc.createTextNode("Click me! (Local)")
    CALL button.appendChild(text_node)

    LET div = body.appendChildElement("div")
    CALL div.setAttribute("id","result_session")
    LET text_node = doc.createTextNode("")
    CALL div.appendChild(text_node)
    
    LET div = body.appendChildElement("div")
    CALL div.setAttribute("id","result_local")
    LET text_node = doc.createTextNode("")
    CALL div.appendChild(text_node)

    LET p = body.appendChildElement("p")
    LET text_node = doc.createTextNode("Click the buttons to see the counter increase.")
    CALL p.appendChild(text_node)

    LET p = body.appendChildElement("p")
    LET text_node = doc.createTextNode("Close the browser tab (or window), and try again, and the Session Storage counter is reset whilst Local Storage remains.")
    CALL p.appendChild(text_node)

    RETURN TRUE, doc
END FUNCTION



FUNCTION generate_page_form_encoded()
DEFINE doc xml.DomDocument
DEFINE root, body, form, input_node, br, text_node xml.DomNode

    LET doc = xml.DomDocument.CreateDocument("html")
    CALL doc.setFeature("whitespace-in-element-content",FALSE)
    LET root = doc.getDocumentElement()
    LET body = root.appendChildElement("body")
    LET form = body.appendChildElement("form")
    CALL form.setAttribute("action","form_encoded_result")
    CALL form.setAttribute("method","post")
    CALL form.setAttribute("enctype","application/x-www-form-urlencoded")


    LET text_node = doc.createTextNode("First Name")
    CALL form.appendChild(text_node)
    LET input_node = form.appendChildElement("input")
    CALL input_node.setAttribute("type","text")
    CALL input_node.setAttribute("name","fname")
    LET br =  form.appendChildElement("br")

    LET text_node = doc.createTextNode("Last Name")
    CALL form.appendChild(text_node)
    LET input_node = form.appendChildElement("input")
    CALL input_node.setAttribute("type","text")
    CALL input_node.setAttribute("name","lname")
    LET br =  form.appendChildElement("br")


    LET input_node = form.appendChildElement("input")
    CALL input_node.setAttribute("type","submit")
    CALL input_node.setAttribute("value","Submit")
    
    RETURN TRUE, doc
END FUNCTION



FUNCTION generate_page_form_encoded_result(args)
DEFINE args STRING
DEFINE doc xml.DomDocument
DEFINE root, head, body, text_node xml.DomNode

    LET doc = xml.DomDocument.CreateDocument("html")
    CALL doc.setFeature("whitespace-in-element-content",FALSE)
    LET root = doc.getDocumentElement()
    LET head = root.appendChildElement("head")
    LET body = root.appendChildElement("body")

    -- create a simple text node
    LET text_node = doc.createTextNode(SFMT("Form encoded string is ... %1", args))
    CALL body.appendChild(text_node)

    RETURN TRUE, doc
END FUNCTION
    








FUNCTION init_database()

    CREATE TABLE country (name CHAR(50))

    INSERT INTO country VALUES("Afghanistan")
    INSERT INTO country VALUES("Aland Islands")
    INSERT INTO country VALUES("Albania")
    INSERT INTO country VALUES("Algeria")
    INSERT INTO country VALUES("American Samoa")
    INSERT INTO country VALUES("Andorra")
    INSERT INTO country VALUES("Angola")
    INSERT INTO country VALUES("Anguilla")
    INSERT INTO country VALUES("Antarctica")
    INSERT INTO country VALUES("Antigua and Barbuda")
    INSERT INTO country VALUES("Argentina")
    INSERT INTO country VALUES("Armenia")
    INSERT INTO country VALUES("Aruba")
    INSERT INTO country VALUES("Australia")
    INSERT INTO country VALUES("Austria")
    INSERT INTO country VALUES("Azerbaijan")
    INSERT INTO country VALUES("Bahamas")
    INSERT INTO country VALUES("Bahrain")
    INSERT INTO country VALUES("Bangladesh")
    INSERT INTO country VALUES("Barbados")
    INSERT INTO country VALUES("Belarus")
    INSERT INTO country VALUES("Belgium")
    INSERT INTO country VALUES("Belize")
    INSERT INTO country VALUES("Benin")
    INSERT INTO country VALUES("Bermuda")
    INSERT INTO country VALUES("Bhutan")
    INSERT INTO country VALUES("Bolivia")
    INSERT INTO country VALUES("Bosnia and Herzegovina")
    INSERT INTO country VALUES("Botswana")
    INSERT INTO country VALUES("Bouvet Island")
    INSERT INTO country VALUES("Brazil")
    INSERT INTO country VALUES("British Indian Ocean Territory")
    INSERT INTO country VALUES("Brunei Darussalam")
    INSERT INTO country VALUES("Bulgaria")
    INSERT INTO country VALUES("Burkina Faso")
    INSERT INTO country VALUES("Burundi")
    INSERT INTO country VALUES("Cambodia")
    INSERT INTO country VALUES("Cameroon")
    INSERT INTO country VALUES("Canada")
    INSERT INTO country VALUES("Cape Verde")
    INSERT INTO country VALUES("Cayman Islands")
    INSERT INTO country VALUES("Central African Republic")
    INSERT INTO country VALUES("Chad")
    INSERT INTO country VALUES("Chile")
    INSERT INTO country VALUES("China")
    INSERT INTO country VALUES("Christmas Island")
    INSERT INTO country VALUES("Cocos (Keeling) Islands")
    INSERT INTO country VALUES("Colombia")
    INSERT INTO country VALUES("Comoros")
    INSERT INTO country VALUES("Congo")
    INSERT INTO country VALUES("Congo, the Democratic Republic of the")
    INSERT INTO country VALUES("Cook Islands")
    INSERT INTO country VALUES("Costa Rica")
    INSERT INTO country VALUES("Cote D'Ivoire")
    INSERT INTO country VALUES("Croatia")
    INSERT INTO country VALUES("Cuba")
    INSERT INTO country VALUES("Cyprus")
    INSERT INTO country VALUES("Czech Republic")
    INSERT INTO country VALUES("Denmark")
    INSERT INTO country VALUES("Djibouti")
    INSERT INTO country VALUES("Dominica")
    INSERT INTO country VALUES("Dominican Republic")
    INSERT INTO country VALUES("Ecuador")
    INSERT INTO country VALUES("Egypt")
    INSERT INTO country VALUES("El Salvador")
    INSERT INTO country VALUES("Equatorial Guinea")
    INSERT INTO country VALUES("Eritrea")
    INSERT INTO country VALUES("Estonia")
    INSERT INTO country VALUES("Ethiopia")
    INSERT INTO country VALUES("Falkland Islands")
    INSERT INTO country VALUES("Faroe Islands")
    INSERT INTO country VALUES("Fiji")
    INSERT INTO country VALUES("Finland")
    INSERT INTO country VALUES("France")
    INSERT INTO country VALUES("French Guiana")
    INSERT INTO country VALUES("French Polynesia")
    INSERT INTO country VALUES("French Southern Territories")
    INSERT INTO country VALUES("Gabon")
    INSERT INTO country VALUES("Gambia")
    INSERT INTO country VALUES("Georgia")
    INSERT INTO country VALUES("Germany")
    INSERT INTO country VALUES("Ghana")
    INSERT INTO country VALUES("Gibraltar")
    INSERT INTO country VALUES("Greece")
    INSERT INTO country VALUES("Greenland")
    INSERT INTO country VALUES("Grenada")
    INSERT INTO country VALUES("Guadeloupe")
    INSERT INTO country VALUES("Guam")
    INSERT INTO country VALUES("Guatemala")
    INSERT INTO country VALUES("Guernsey")
    INSERT INTO country VALUES("Guinea")
    INSERT INTO country VALUES("Guinea-Bissau")
    INSERT INTO country VALUES("Guyana")
    INSERT INTO country VALUES("Haiti")
    INSERT INTO country VALUES("Heard Island and Mcdonald Islands")
    INSERT INTO country VALUES("Holy See (Vatican City State)")
    INSERT INTO country VALUES("Honduras")
    INSERT INTO country VALUES("Hong Kong")
    INSERT INTO country VALUES("Hungary")
    INSERT INTO country VALUES("Iceland")
    INSERT INTO country VALUES("India")
    INSERT INTO country VALUES("Indonesia")
    INSERT INTO country VALUES("Iran, Islamic Republic of")
    INSERT INTO country VALUES("Iraq")
    INSERT INTO country VALUES("Ireland")
    INSERT INTO country VALUES("Isle of Man")
    INSERT INTO country VALUES("Israel")
    INSERT INTO country VALUES("Italy")
    INSERT INTO country VALUES("Jamaica")
    INSERT INTO country VALUES("Japan")
    INSERT INTO country VALUES("Jersey")
    INSERT INTO country VALUES("Jordan")
    INSERT INTO country VALUES("Kazakhstan")
    INSERT INTO country VALUES("Kenya")
    INSERT INTO country VALUES("Kiribati")
    INSERT INTO country VALUES("Korea, Democratic People's Republic of")
    INSERT INTO country VALUES("Korea, Republic of")
    INSERT INTO country VALUES("Kuwait")
    INSERT INTO country VALUES("Kyrgyzstan")
    INSERT INTO country VALUES("Lao people's Democratic Republic")
    INSERT INTO country VALUES("Latvia")
    INSERT INTO country VALUES("Lebanon")
    INSERT INTO country VALUES("Lesotho")
    INSERT INTO country VALUES("Liberia")
    INSERT INTO country VALUES("Libyan Arab Jamahiriya")
    INSERT INTO country VALUES("Liechtenstein")
    INSERT INTO country VALUES("Lithuania")
    INSERT INTO country VALUES("Luxembourg")
    INSERT INTO country VALUES("Macao")
    INSERT INTO country VALUES("Macedonia, the Former Yugoslav Republic of")
    INSERT INTO country VALUES("Madagascar")
    INSERT INTO country VALUES("Malawi")
    INSERT INTO country VALUES("Malaysia")
    INSERT INTO country VALUES("Maldives")
    INSERT INTO country VALUES("Mali")
    INSERT INTO country VALUES("Malta")
    INSERT INTO country VALUES("Marshall Islands")
    INSERT INTO country VALUES("Martinique")
    INSERT INTO country VALUES("Mauritania")
    INSERT INTO country VALUES("Mauritius")
    INSERT INTO country VALUES("Mayotte")
    INSERT INTO country VALUES("Mexico")
    INSERT INTO country VALUES("Micronesia, Federated States of")
    INSERT INTO country VALUES("Moldova")
    INSERT INTO country VALUES("Monaco")
    INSERT INTO country VALUES("Mongolia")
    INSERT INTO country VALUES("Montenegro")
    INSERT INTO country VALUES("Montserrat")
    INSERT INTO country VALUES("Morocco")
    INSERT INTO country VALUES("Mozambique")
    INSERT INTO country VALUES("Myanmar")
    INSERT INTO country VALUES("Namibia")
    INSERT INTO country VALUES("Nauru")
    INSERT INTO country VALUES("Nepal")
    INSERT INTO country VALUES("Netherlands")
    INSERT INTO country VALUES("Netherlands Antilles")
    INSERT INTO country VALUES("New Caledonia")
    INSERT INTO country VALUES("New Zealand")
    INSERT INTO country VALUES("Nicaragua")
    INSERT INTO country VALUES("Niger")
    INSERT INTO country VALUES("Nigeria")
    INSERT INTO country VALUES("Niue")
    INSERT INTO country VALUES("Norfolk Island")
    INSERT INTO country VALUES("Northern Mariana Islands")
    INSERT INTO country VALUES("Norway")
    INSERT INTO country VALUES("Oman")
    INSERT INTO country VALUES("Pakistan")
    INSERT INTO country VALUES("Palau")
    INSERT INTO country VALUES("Palestinian Territory, Occupied")
    INSERT INTO country VALUES("Panama")
    INSERT INTO country VALUES("Papua New Guinea")
    INSERT INTO country VALUES("Paraguay")
    INSERT INTO country VALUES("Peru")
    INSERT INTO country VALUES("Philippines")
    INSERT INTO country VALUES("Pitcairn")
    INSERT INTO country VALUES("Poland")
    INSERT INTO country VALUES("Portugal")
    INSERT INTO country VALUES("Puerto Rico")
    INSERT INTO country VALUES("Qatar")
    INSERT INTO country VALUES("Reunion")
    INSERT INTO country VALUES("Romania")
    INSERT INTO country VALUES("Russian Federation")
    INSERT INTO country VALUES("Rwanda")
    INSERT INTO country VALUES("Saint Barthelemy")
    INSERT INTO country VALUES("Saint Helena")
    INSERT INTO country VALUES("Saint Kitts and Nevis")
    INSERT INTO country VALUES("Saint Lucia")
    INSERT INTO country VALUES("Saint Martin")
    INSERT INTO country VALUES("Saint Pierre and Miquelon")
    INSERT INTO country VALUES("Saint Vincent and the Grenadines")
    INSERT INTO country VALUES("Samoa")
    INSERT INTO country VALUES("San Marino")
    INSERT INTO country VALUES("Sao Tome and Principe")
    INSERT INTO country VALUES("Saudi Arabia")
    INSERT INTO country VALUES("Senegal")
    INSERT INTO country VALUES("Serbia")
    INSERT INTO country VALUES("Seychelles")
    INSERT INTO country VALUES("Sierra Leone")
    INSERT INTO country VALUES("Singapore")
    INSERT INTO country VALUES("Slovakia")
    INSERT INTO country VALUES("Slovenia")
    INSERT INTO country VALUES("Solomon Islands")
    INSERT INTO country VALUES("Somalia")
    INSERT INTO country VALUES("South Africa")
    INSERT INTO country VALUES("South Georgia and the South Sandwich Islands")
    INSERT INTO country VALUES("Spain")
    INSERT INTO country VALUES("Sri Lanka")
    INSERT INTO country VALUES("Sudan")
    INSERT INTO country VALUES("Suriname")
    INSERT INTO country VALUES("Svalbard and Jan Mayen")
    INSERT INTO country VALUES("Swaziland")
    INSERT INTO country VALUES("Sweden")
    INSERT INTO country VALUES("Switzerland")
    INSERT INTO country VALUES("Syrian Arab Republic")
    INSERT INTO country VALUES("Taiwan")
    INSERT INTO country VALUES("Tajikistan")
    INSERT INTO country VALUES("Tanzania, United Republic of")
    INSERT INTO country VALUES("Thailand")
    INSERT INTO country VALUES("Timor-leste")
    INSERT INTO country VALUES("Togo")
    INSERT INTO country VALUES("Tokelau")
    INSERT INTO country VALUES("Tonga")
    INSERT INTO country VALUES("Trinidad and Tobago")
    INSERT INTO country VALUES("Tunisia")
    INSERT INTO country VALUES("Turkey")
    INSERT INTO country VALUES("Turkmenistan")
    INSERT INTO country VALUES("Turks and Caicos Islands")
    INSERT INTO country VALUES("Tuvalu")
    INSERT INTO country VALUES("Uganda")
    INSERT INTO country VALUES("Ukraine")
    INSERT INTO country VALUES("United Arab Emirates")
    INSERT INTO country VALUES("United Kingdom")
    INSERT INTO country VALUES("United States")
    INSERT INTO country VALUES("United States Minor Outlying Islands")
    INSERT INTO country VALUES("Uruguay")
    INSERT INTO country VALUES("Uzbekistan")
    INSERT INTO country VALUES("Vanuatu")
    INSERT INTO country VALUES("Vatican City State")
    INSERT INTO country VALUES("Venezuela")
    INSERT INTO country VALUES("Viet Nam")
    INSERT INTO country VALUES("Virgin Islands, British")
    INSERT INTO country VALUES("Virgin Islands, U.S.")
    INSERT INTO country VALUES("Wallis and Futuna")
    INSERT INTO country VALUES("Western Sahara")
    INSERT INTO country VALUES("Yemen")
    INSERT INTO country VALUES("Zambia")
    INSERT INTO country VALUES("Zimbabwe")
END FUNCTION



#function from http://4js.com/online_documentation/fjs-fgl-manual-html/#c_gws_XmlXSLTtransformer_example.html
FUNCTION RunXSLP(style,src)
DEFINE style,src      STRING
DEFINE ind            INTEGER
DEFINE xslt           xml.XSLTTransformer
DEFINE styleSheet     xml.DomDocument
DEFINE source         xml.DomDocument
DEFINE result         xml.DomDocument

    # Load StyleSheet
    TRY
        LET styleSheet = xml.DomDocument.Create()
        CALL styleSheet.load(style)
    CATCH
        DISPLAY "Error: unable to load stylesheet",style
        RETURN FALSE, NULL
    END TRY
  
    # Create XSLT transformer
    TRY
        LET xslt = xml.XSLTTransformer.CreateFromDocument(styleSheet)
        FOR ind=1 TO xslt.getErrorsCount()
            DISPLAY "StyleSheet error #"||ind||" : ",xslt.getErrorDescription(ind)
        END FOR
    CATCH
        DISPLAY "Error : unable to create XSLT transformer from ",styleSheet
        RETURN FALSE, NULL
    END TRY

    # Load Source 
    TRY
        LET source = xml.DomDocument.Create()
        CALL source.load(src)
    CATCH
        DISPLAY "Error : unable to load Source from ",src
        RETURN FALSE, NULL
    END TRY
  
    # Execute XSLT 
    TRY
        LET result = xslt.doTransform(source)
        FOR ind=1 TO xslt.getErrorsCount()
            DISPLAY "Error #"||ind||" : ",xslt.getErrorDescription(ind)
        END FOR    
    CATCH
        DISPLAY "Error : unable to apply XSLT stylesheet"
        FOR ind=1 TO xslt.getErrorsCount()
            DISPLAY "Fatal Error #"||ind||" : ",xslt.getErrorDescription(ind)
        END FOR
        RETURN FALSE, NULL
    END TRY

    RETURN TRUE, result

END FUNCTION