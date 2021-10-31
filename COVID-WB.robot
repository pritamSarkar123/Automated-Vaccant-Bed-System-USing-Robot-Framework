*** Settings ***
Documentation     Verint Update Schedule
Library           SeleniumLibrary    timeout=30    run_on_failure=Nothing
Library           Collections
Library           OperatingSystem
Library           String
Library           DateTime

*** Variables ***
${URL}            https://excise.wb.gov.in/CHMS/Public/Page/CHMS_Public_Hospital_Bed_Availability.aspx
${BROWSER}        Chrome
${CHROME_DRIVER}    C:/ChromeDriver/01.05.2021/chromedriver.exe
${FILE_NAME}      RuntimeTextFile.txt
${DistCount}      1
@{DistList}

*** Test Cases ***
Check and Run Keyword
    Append To File    ${FILE_NAME}    --OPERATION_STARTED--
    ${chrome_options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys
    Call Method    ${chrome_options}    add_argument    --disable-extensions
    Call Method    ${chrome_options}    add_argument    --start-maximized
    Call Method    ${chrome_options}    add_argument    --safebrowsing-disable-download-protection
    Call Method    ${chrome_options}    add_argument    --safebrowsing-disable-extension-blacklist
    #${prefs}=    Create Dictionary    download.default_directory=${DOWNLOAD_DIR}    download.directory_update=true    profile.content_settings.exceptions.automatic_download.*.setting=${1}    profile.default_content_setting_values.automatic_downloads=${1}    download.directory_upgrade=true
    #...    savefile.default_directory=${DOWNLOAD_DIR}    safebrowsing.enabled=${true}    disable-popup-blocking=${true}    download.prompt_for_download=${false}    profile.default_content_settings.popups=${0}    extensions.alerts.initialized=${false}
    #Call Method    ${chrome_options}    add_experimental_option    prefs    ${prefs}
    Call Method    ${chrome_options}    add_experimental_option    useAutomationExtension    ${false}
    @{enableList}=    Create List    enable-automation
    Call Method    ${chrome_options}    add_experimental_option    excludeSwitches    ${enableList}
    ${ff_default}    Evaluate    sys.modules['selenium.webdriver'].common.desired_capabilities.DesiredCapabilities.CHROME    sys,selenium.webdriver
    Set To Dictionary    ${ff_default}    marionette=${True}
    ${webdriver}    Create Dictionary    executable_path=${CHROME_DRIVER}
    Create WebDriver    ${BROWSER}    chrome_options=${chrome_options}    kwargs=${webdriver}
    Go To    ${URL}
    Wait Until Element Is Visible    //span[contains(text(),'Select District')]/ancestor::div[1]/following-sibling::div/div/select    timeout=60sec
    ${SelectionFieldCheck}=    Run Keyword And Return Status    Element Should Be Enabled    //span[contains(text(),'Select District')]/ancestor::div[1]/following-sibling::div/div/select
    ${DistCount}=    Get Element Count    //span[contains(text(),'Select District')]/ancestor::div[1]/following-sibling::div/div/select/option
    Log To Console    ${DistCount}
    ${DistDict}=    Create Dictionary
    : FOR    ${index}    IN RANGE    2    ${DistCount}+1
    \    Execute Javascript    document.evaluate("//span[contains(text(),'Select District')]/ancestor::div[1]/following-sibling::div/div/select", document, null, 9, null).singleNodeValue.click()
    \    Wait Until Element Is Visible    //span[contains(text(),'Select District')]/ancestor::div[1]/following-sibling::div/div/select/option[${index}]    timeout=30sec
    \    Click Element    //span[contains(text(),'Select District')]/ancestor::div[1]/following-sibling::div/div/select/option[${index}]
    \    ${DistName}=    Get Text    //span[contains(text(),'Select District')]/ancestor::div[1]/following-sibling::div/div/select/option[${index}]
    \    Log To Console    ${DistName}
    \    Wait Until Page Contains Element    //span[contains(text(),'Select District')]/ancestor::div[1]/ancestor::div[1]/ancestor::div[1]/div[2]/div[2]/span/input    timeout=50sec
    \    ${HospitalTypes}=    Get Element Count    //span[contains(text(),'Select District')]/ancestor::div[1]/ancestor::div[1]/ancestor::div[1]/div[2]/div[2]/span/input
    \    #${DistHospitalTypeDict}=    Create Dictionary
    \    ${DistHospitalTypeDict}=    Cycle Through All Hospitqal Types    ${HospitalTypes}
    \    Set To Dictionary    ${DistDict}    ${DistName}    ${DistHospitalTypeDict}
    Log To Console    ${DistDict}
    ${tempString2}=    Convert To String    ${DistDict}
    Append To File    ${FILE_NAME}    --DATA_START--${tempString2}--DATA_END--
    Append To File    ${FILE_NAME}    --OPERATION_COMPLETED--

Close Browser
    Close Browser

*** Keywords ***
Cycle Through All Hospitqal Types
    [Arguments]    ${HospitalTypes}
    ${DistHospitalTypeDict}=    Create Dictionary
    : FOR    ${index}    IN RANGE    1    ${HospitalTypes}+1
    \    Wait Until Element Is Visible    //label[contains(text(),'With available bed only')]    timeout=30sec
    \    Execute Javascript    document.evaluate("//label[contains(text(),'With available bed only')]", document, null, 9, null).singleNodeValue.click()
    \    Wait Until Page Contains Element    //span[contains(text(),'Select District')]/ancestor::div[1]/ancestor::div[1]/ancestor::div[1]/div[2]/div[2]/span/input[${index}]    timeout=50sec
    \    Execute Javascript    document.evaluate("//span[contains(text(),'Select District')]/ancestor::div[1]/ancestor::div[1]/ancestor::div[1]/div[2]/div[2]/span/input[${index}]", document, null, 9, null).singleNodeValue.click()
    \    Wait Until Page Contains Element    //span[contains(text(),'Select District')]/ancestor::div[1]/ancestor::div[1]/ancestor::div[1]/div[2]/div[2]/span/input[${index}]    timeout=50sec
    \    ${H_Type}=    Get Text    //span[contains(text(),'Select District')]/ancestor::div[1]/ancestor::div[1]/ancestor::div[1]/div[2]/div[2]/span/label[${index}]
    \    Sleep    5s
    \    ${HospitalsAvailable}=    Wait For Element To Appear    //label[contains(text(),'With available bed only')]/ancestor::span/ancestor::div[1]/ancestor::div[1]/following-sibling::div//table    20
    \    Run Keyword If    not ${HospitalsAvailable}    Continue For Loop
    \    ${HospitalCount}=    Get Element Count    //label[contains(text(),'With available bed only')]/ancestor::span/ancestor::div[1]/ancestor::div[1]/following-sibling::div//table/tbody/tr
    \    Log To Console    ${H_Type}
    \    @{DistHospitalDataList}=    Cycle Through All Hospitals    ${HospitalCount}
    \    Set To Dictionary    ${DistHospitalTypeDict}    ${H_Type}    ${DistHospitalDataList}
    [Return]    ${DistHospitalTypeDict}

Cycle Through All Hospitals
    [Arguments]    ${HospitalCount}
    @{DistHospitalDataList}=    Create List
    : FOR    ${index}    IN RANGE    1    ${HospitalCount}+1
    \    ${DistHospitalDataDict}=    Create Dictionary
    \    ${nameAvl}=    Wait For Element To Appear    //label[contains(text(),'With available bed only')]/ancestor::span/ancestor::div[1]/ancestor::div[1]/following-sibling::div//table/tbody/tr[${index}]/td[1]//h5    5
    \    ${HospitalName}=    Run Keyword If    ${nameAvl}    Get Text    //label[contains(text(),'With available bed only')]/ancestor::span/ancestor::div[1]/ancestor::div[1]/following-sibling::div//table/tbody/tr[${index}]/td[1]//h5
    \    ...    ELSE    Set Variable    ${EMPTY}
    \    Set To Dictionary    ${DistHospitalDataDict}    Hospital Name    ${HospitalName}
    \    ${addAvl}=    Wait For Element To Appear    //label[contains(text(),'With available bed only')]/ancestor::span/ancestor::div[1]/ancestor::div[1]/following-sibling::div//table/tbody/tr[${index}]/td[1]//h5/following-sibling::div[1]/div[1]    5
    \    ${HospitalAddress}=    Run Keyword If    ${addAvl}    Get Text    //label[contains(text(),'With available bed only')]/ancestor::span/ancestor::div[1]/ancestor::div[1]/following-sibling::div//table/tbody/tr[${index}]/td[1]//h5/following-sibling::div[1]/div[1]
    \    ...    ELSE    Set Variable    ${EMPTY}
    \    Set To Dictionary    ${DistHospitalDataDict}    Hospital Address    ${HospitalAddress}
    \    ${contactAvl}=    Wait For Element To Appear    //label[contains(text(),'With available bed only')]/ancestor::span/ancestor::div[1]/ancestor::div[1]/following-sibling::div//table/tbody/tr[${index}]/td[1]//h5/following-sibling::div[1]/div[2]/a    5
    \    ${HospitalContact}=    Run Keyword If    ${contactAvl}    Get Element Attribute    //label[contains(text(),'With available bed only')]/ancestor::span/ancestor::div[1]/ancestor::div[1]/following-sibling::div//table/tbody/tr[${index}]/td[1]//h5/following-sibling::div[1]/div[2]/a    href
    \    ...    ELSE    Set Variable    ${EMPTY}
    \    Set To Dictionary    ${DistHospitalDataDict}    Hospital Contact    ${HospitalContact}
    \    ${bedsAvl}=    Wait For Element To Appear    //label[contains(text(),'With available bed only')]/ancestor::span/ancestor::div[1]/ancestor::div[1]/following-sibling::div//table/tbody/tr[${index}]//div[contains(text(),'Total')]/following-sibling::ul/li[2]/h3    5
    \    ${HospitalBeds}=    Run Keyword If    ${bedsAvl}    Get Text    //label[contains(text(),'With available bed only')]/ancestor::span/ancestor::div[1]/ancestor::div[1]/following-sibling::div//table/tbody/tr[${index}]//div[contains(text(),'Total')]/following-sibling::ul/li[2]/h3
    \    ...    ELSE    Set Variable    ${EMPTY}
    \    Set To Dictionary    ${DistHospitalDataDict}    Hospital Beds    ${HospitalBeds}
    \    ${urlAvl}=    Wait For Element To Appear    //label[contains(text(),'With available bed only')]/ancestor::span/ancestor::div[1]/ancestor::div[1]/following-sibling::div//table/tbody/tr[${index}]/td[1]//h5/following-sibling::div[1]/div[3]/a    5
    \    ${HospitalURL}=    Run Keyword If    ${urlAvl}    Get Element Attribute    //label[contains(text(),'With available bed only')]/ancestor::span/ancestor::div[1]/ancestor::div[1]/following-sibling::div//table/tbody/tr[${index}]/td[1]//h5/following-sibling::div[1]/div[3]/a    href
    \    ...    ELSE    Set Variable    ${EMPTY}
    \    Set To Dictionary    ${DistHospitalDataDict}    Hospital URL    ${HospitalURL}
    \    Append To List    ${DistHospitalDataList}    ${DistHospitalDataDict}
    Log To Console    ${DistHospitalDataList}
    ${tempString}=    Convert To String    ${DistHospitalDataList}
    #Append To File    ${FILE_NAME}    ${tempString}
    [Return]    @{DistHospitalDataList}

Wait For Element To Appear
    [Arguments]    ${Element}    ${Time}
    ${ElemenentCheck}=    Set Variable    False
    : FOR    ${index}    IN RANGE    1    ${Time}+1
    \    ${ElemenentCheck}=    Run Keyword And Return Status    Page Should Contain Element    ${Element}
    \    Run Keyword If    not ${ElemenentCheck}    Sleep    1s
    [Return]    ${ElemenentCheck}
