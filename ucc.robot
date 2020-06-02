*** Settings ***
Documentation   Searches the Secretary of State UCC database
Library         libraries/ParseLibrary.py
Library         libraries/StoreLibrary.py
Library         RPA.Browser
Library         OperatingSystem

*** Variables ***
${ILSOS_URL}      https://www.ilsos.gov/uccsearch/
${BUSINESS_NAME}    THE BOOK TABLE, INC

*** Keyword ***
Open State of IL UCC Search
    Open Available Browser  ${ILSOS_URL}

** Keyword ***
Check for visibility and click
    [Arguments]    ${selector}
    Wait Until Element Is Visible   ${selector}
    Click Element   ${selector}

** Keyword **
Search for tax lien on business
    [Arguments]     ${text}
    Select Radio Button   searchType   U
    Check for visibility and click   //input[@type="radio"][@name="uccSearch"][@value="B"]
    Check for visibility and click   //input[@type="radio"][@name="raType"][@value="R"]
    Wait Until Element Is Visible   name:orgName
    Input Text  name:orgName  ${text}
    Click Element   //form[@name="searchIndexForm"]//input[@type="submit"]

** Keyword ***
Check for any results
    Wait Until Page Contains Element    //table[@title="UCC Search Results"]
    ${text}=  Get Text  //table[@title="UCC Search Results"]
    ${parsed_text}=   Parse Tabular Data    ${text}
    Store parsed data   ${parsed_text}

*** Task ***
Search for a Federal Tax Lien
    Open State of IL UCC Search
    Search for tax lien on business   ${BUSINESS_NAME}
    Check for any results
    [Teardown]  Close Browser

