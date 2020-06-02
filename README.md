# Search and Store

An example project for using Robot Framework and RPA Framework. 

The automation fills out a web-based form, processes and transmits the results.  

The implementation is a trivial "Hello World" for this toolset.  The automation completes a form on a government website (Illinois Secretary of State Office).  The form has conditional fields that display for different search types and this example shows one approach for working with visually toggled content.

This example also shows how Robot Framework's keyword syntax works and how to drop back into pure python.  

## Installation

To install this project, clone or download the files to a local directory.  Once it has been checked out
install the requirements with `pip install -r requirements.txt`

## Running The Bot Locally

The bot expects a variable BUSINESS_NAME to be passed into it.  This is the search term that will 
be used in the query.  

`robot --variable BUSINESS_NAME:'Python Trucking, Inc' ucc.robot`

Check the results (machine readable) - https://beeceptor.com/console/searchandstore


## Audience

This document is intended for developers that may have some python expertise
but are new to RPA Framework.  
  

## Prerequisites

You will need python on your command line to run this example.  This guide assumes you have python 
available on your command line path.  To confirm this, open your terminal and type `python`.  
It should look something like this:
```
# python -V
Python 3.7.3 

```
If you don't have python installed, [use this guide](https://realpython.com/installing-python/)
 to get it installed.


### Create a Virtual Environment

Note: Before installation, you may want to run the project in a virtual environment.  
Create a new virtual environment by running `python3 -m venv venv` to create a virtual 
environment in a local directory named "venv".  Running against that virtual environment 
will work when doing `source venv/bin/activate` moving forward. 

# Diving into the code

Let's go section by section, at the outset we have a settings block which includes a short description
of the automation and it's imports.
```
*** Settings ***
Documentation   Searches the Secretary of State UCC database
Library         libraries/ParseLibrary.py
Library         libraries/StoreLibrary.py
Library         RPA.Browser
Library         OperatingSystem
```
The first two imports that start with `libraries/` were created for this project.  They parse the 
results of the search and to store the result via a HTTP POST request.  The second two imports pull in the 
RPA.Browser library included with RPA Framework and the OperatingSystem library offered by Robot Framework.

#### RPA Framework?  Robot Framework?  Which is it?

RPA Framework = Recent set of libraries created by Robocorp.
Robot Framework = The underlying platform that we're writing these bots for.  

## Variables

We declare variables in the automation that can also be passed in at runtime via the `--variable KEY:VAL` flag.

```
*** Variables ***
${ILSOS_URL}      https://www.ilsos.gov/uccsearch/
${BUSINESS_NAME}    THE BOOK TABLE, INC
```

## Keywords
Keywords are the actions that your automation is going to take in granular detail.  At first, this may
look silly and if you are like me you may want to just use Python directly.  Keywords have a few advantages:
  - Self-documentation: Automations are guaranteed to break and you may not be the one
   to make the fix.  
  - DRY Code: You can break down actions into logical sections that can be re-used with different arguements
   or configurations.
  - Sequencing: You can easily change how your code procedurally runs

You can call keywords and pass arguments by adding a tab between your calls.
```
*** Keyword ***
Open State of IL UCC Search
    Open Available Browser  ${ILSOS_URL}
```
In this case, I'm passing a URL to open a browser.  This is a [builtin keyword](https://rpaframework.org/libdoc/Browser.html) for RPA.Browser. 

```
** Keyword ***
Check for visibility and click
    [Arguments]    ${selector}
    Wait Until Element Is Visible   ${selector}
    Click Element   ${selector}
```
In this block I've abstracted out a repeated sequence of waiting for an element to be visible.  The form I chose to automate
shows and hides options based on previous selections.  I chose this form to demonstrate how nice some of the RPA.Browser
features help.  If you've used Selenium in the past, you'll appreciate the convenience of these methods.

The keyword accepts an argument of an XPath selector.  More on that below.

```
** Keyword **
Search for tax lien on business
    [Arguments]     ${text}
    Select Radio Button   searchType   U
    Check for visibility and click   //input[@type="radio"][@name="uccSearch"][@value="B"]
    Check for visibility and click   //input[@type="radio"][@name="raType"][@value="R"]
    Wait Until Element Is Visible   name:orgName
    Input Text  name:orgName  ${text}
    Click Element   //form[@name="searchIndexForm"]//input[@type="submit"]
```

This block is where the form automation happens.  You'll see that I've fallen back to using XPath to 
target the HTML elements.

```
** Keyword ***
Check for any results
    Wait Until Page Contains Element    //table[@title="UCC Search Results"]
    ${text}=  Get Text  //table[@title="UCC Search Results"]
    ${parsed_text}=   Parse Tabular Data    ${text}
    Store parsed data   ${parsed_text}
```
In this last block I wait until the search results table appears.  I get the text from the table and 
pass it to the libraries that I've created.  

 
## Task
All of the keywords come together as a task.  
```
*** Task ***
Search for a Federal Tax Lien
    Open State of IL UCC Search
    Search for tax lien on business   ${BUSINESS_NAME}
    Check for any results
    [Teardown]  Close Browser
```

## Libraries
The libraries that have been imported into the automation are trivial and meant for demonstration purposes only.
The killer feature here is you can fall back to python at any point.  You aren't limited to the tools 
available by your RPA platform but rather the tools that python can talk to (which are plentiful).  You'll 
notice that the naming of the method converts over to a Keyword.  So `my_python_method` becomes `My python method`.

## Executing from Python
Included in this repo is a trivial example of how to run your `.robot` file from python.  This also opens 
the door to other interoperable ways of using automation in your existing python stack.

# Helpful RPA Framework Links
[RPA Framework User Guide](http://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html) - 
These docs are an exhaustive guide to using the framework.  They include a lot of examples but may 
seem intimidating.  Pour a cup of coffee and dig in, they offer a broad perspective of the tooling.

[Robocorp RPA Framework Library Docs](https://rpaframework.org/index.html) - Robocorp has created new libraries 
that we're using in this example.  Specifically the [Browser](https://rpaframework.org/libraries/browser/index.html#) library. 



