*** Settings ***
Library    Collections
Library    SeleniumLibrary
Library    RequestsLibrary
Library    Dialogs
Library    String

*** Variables ***
${test_website}    https://the-internet.herokuapp.com/login
${base_url}        https://reqres.in
${decrypted}       ${EMPTY}

*** Keywords ***
Open Browser and Maximize
    # To avoid bulk of ScreenShot file when running FAIL
    SeleniumLibrary.Register Keyword To Run On Failure    ${None}
    SeleniumLibrary.Open Browser    ${test_website}    edge
    ...    options=add_experimental_option("excludeSwitches", ["enable-logging"])
    SeleniumLibrary.Maximize Browser Window

*** Test Cases ***
001 Check duplicate items from list and append not duplicate
    ${ListA}    BuiltIn.Create List    1    2    3    5    6    8    9
    ${ListB}    BuiltIn.Create List    3    2    1    5    6    0
    BuiltIn.Log To Console    ${ListA}
    BuiltIn.Log To Console    compare with
    BuiltIn.Log To Console    ${ListB}
    ${countL2}    BuiltIn.Get Length    ${ListB}
    FOR    ${c}    IN RANGE    ${countL2}
        ${Not_in_list}    BuiltIn.Run Keyword And Return Status  Collections.List Should Not Contain Value    ${ListA}  ${ListB}[${c}]
        BuiltIn.Run Keyword If    ${Not_in_list}    Collections.Append To List    ${ListA}    ${ListB}[${c}] 
    END
    BuiltIn.Log To Console    New list is ${ListA}
    
002 - Simple login website 1
    Open Browser and Maximize
    SeleniumLibrary.Wait Until Element Is Visible    xpath=//*[text()[contains(., "Login Page")]]
    SeleniumLibrary.Input Text    id=username    text=tomsmith
    SeleniumLibrary.Input Text    id=password    text=SuperSecretPassword!
    SeleniumLibrary.Click Element    xpath=//*[text()=' Login']
    SeleniumLibrary.Wait Until Element Is Visible    xpath=//*[text()[contains(., "You logged into a secure area!")]]
    SeleniumLibrary.Click Element    xpath=//*[text()[contains(., "Logout")]]
    SeleniumLibrary.Wait Until Element Is Visible    xpath=//*[text()[contains(., "You logged out of the secure area!")]]
    SeleniumLibrary.Close Browser

002 - Simple login website 2
    Open Browser and Maximize
    SeleniumLibrary.Wait Until Element Is Visible    xpath=//*[text()[contains(., "Login Page")]]
    SeleniumLibrary.Input Text    id=username    text=tomsmith
    SeleniumLibrary.Input Text    id=password    text=Password!
    SeleniumLibrary.Click Element    xpath=//*[text()=' Login']
    SeleniumLibrary.Wait Until Element Is Visible    xpath=//*[text()[contains(., 'Your password is invalid!')]]
    SeleniumLibrary.Close Browser

002 - Simple login website 3
    Open Browser and Maximize
    SeleniumLibrary.Wait Until Element Is Visible    xpath=//*[text()[contains(., "Login Page")]]
    SeleniumLibrary.Input Text    id=username    text=tomholland
    SeleniumLibrary.Input Text    id=password    text=Password!
    SeleniumLibrary.Click Element    xpath=//*[text()=' Login']
    SeleniumLibrary.Wait Until Element Is Visible    xpath=//*[text()[contains(., 'Your username is invalid!')]]
    SeleniumLibrary.Close Browser

003 - Rest API GET request 1
    RequestsLibrary.Create Session    mySession    ${base_url}
    ${response}    RequestsLibrary.Get Request    mySession    /api/users/12
    ${status_code}    BuiltIn.Convert To String    ${response.status_code}
    BuiltIn.Should Be Equal    ${status_code}    200
    ${json_id}    BuiltIn.Convert To String    ${response.json()}[data][id]
    BuiltIn.Should Be Equal    ${json_id}    12
    ${json_email}    BuiltIn.Convert To String    ${response.json()}[data][email]
    BuiltIn.Should Be Equal    ${json_email}    rachel.howell@reqres.in
    ${json_first_name}    BuiltIn.Convert To String    ${response.json()}[data][first_name]
    BuiltIn.Should Be Equal    ${json_first_name}    Rachel
    ${json_last_name}    BuiltIn.Convert To String    ${response.json()}[data][last_name]
    BuiltIn.Should Be Equal    ${json_last_name}    Howell
    ${json_avatar}    BuiltIn.Convert To String    ${response.json()}[data][avatar]
    BuiltIn.Should Be Equal    ${json_avatar}    https://reqres.in/img/faces/12-image.jpg

003 - Rest API GET request 2
    RequestsLibrary.Create Session    mySession    ${base_url}
    ${response}    RequestsLibrary.Get Request    mySession    /api/users/1234
    ${status_code}    BuiltIn.Convert To String    ${response.status_code}
    BuiltIn.Should Be Equal    ${status_code}    404
    ${json_body}    BuiltIn.Convert To String    ${response.content}
    BuiltIn.Should Be Equal    ${json_body}    \{\}

006 simpleCipher
    @{eng_alphabet}    BuiltIn.Create List    A  B  C  D  E  F  G  H  I  J  K  L  M  N  O  P  Q  R  S  T  U  V  W  X  Y  Z

    ${encrypted}    Dialogs.Get Value From User    Input encrypted word    default_value=vtaog
    ${k}    Dialogs.Get Value From User    Input key in number only    default_value=2
    
    ${encrypted}    String.Convert To Upper Case    ${encrypted}
    ${k}    BuiltIn.Convert To Integer    ${k}
    @{split_text}    String.Split String To Characters    ${encrypted}

    ${count_encrypted}    BuiltIn.Get Length    ${split_text}
    FOR    ${c}    IN RANGE    ${count_encrypted}
        ${x}    Collections.Get Index From List    ${eng_alphabet}	    ${split_text}[${c}]
        ${position}    BuiltIn.Evaluate    ${x}-${k}
        IF    ${position} < 0
            ${z}    BuiltIn.Evaluate    ${position}+26
            ${decrypted}    BuiltIn.Catenate    SEPARATOR=${EMPTY}    ${decrypted}    ${eng_alphabet}[${z}]
        ELSE
            ${decrypted}    BuiltIn.Catenate    SEPARATOR=${EMPTY}    ${decrypted}    ${eng_alphabet}[${position}]
        END
    END
    Dialogs.Pause Execution    Decrypted word is ${decrypted}
    BuiltIn.Log To Console    Decrypted word is ${decrypted}