*** Settings ***
Library  Selenium2Library
Library  String
Library  OperatingSystem
Library  PyKeywords.py

*** Keywords ***
Begin Web Case
    Set Selenium Speed  .5 seconds
    open browser  about:blank  chrome
    maximize browser window

End Web Case
    close browser

Log In
    go to  ${LOG_IN_PAGE}
    wait until element is enabled  wp-submit
    sleep  3
    input text  user_login  ${USER_NAME}
    input text  user_pass  ${USER_PASSWORD}
    click button  wp-submit

Create title
    [Arguments]  ${title}

    ${DATE_TIME} =  get current date  exclude_millis=True
    return from keyword  ${title} ${DATE_TIME}

Set privacy
    [Arguments]  ${mode}=NA  ${password}=123456

    ${mode} =  convert to lowercase  ${mode}
    click link  //*[@id="visibility"]/a
    run keyword if  '${mode}'=='private'  select checkbox  visibility-radio-private
    ...   ELSE IF   '${mode}'=='password'  run keywords  select checkbox  visibility-radio-password
    ...                  AND  input text  post_password  ${password}
    ...   ELSE      select checkbox  visibility-radio-public
    click link  //*[@id="post-visibility-select"]/p/a[1]

Publish time
    [Arguments]  ${time}

    click link  //*[@id="misc-publishing-actions"]/div[3]/a
    ${hour} =  get substring  ${time}  0  2
    ${minute} =  get substring  ${time}  2  4
    ${day} =  get substring  ${time}  4  6
    ${month} =  get substring  ${time}  6  8
    ${year} =  get substring  ${time}  8  12
    ${checkDay} =  Strip String  ${day}  mode=left  characters=0
    ${checkMonth} =  Strip String  ${month}  mode=left  characters=0
    ${status} =  check date time  ${checkDay}  ${checkMonth}  ${year}
    run keyword if  ${status}==True  run keywords  select from list by value  mm  ${month}
    ...                              AND           input text  jj  ${day}
    ...                              AND           input text  aa  ${year}
    ...                              AND           run keyword if  0<=${hour}<=23  input text  hh  ${hour}
    ...                              AND           run keyword if  0<=${minute}<=59  input text  mn  ${minute}
    ...                              AND           click link  //*[@id="timestampdiv"]/p/a[1]

Create post
    [Arguments]  ${title}  ${content}  ${privacy}=NA  ${password}=123456  ${publish_time}=NA

    click element  //*[@class='wp-menu-name'][text()='Posts']
    wait until page contains  Title
    click link  Add New
#    ${title} =  Create title  ${title}
    input text  title  ${title}
    click button  content-html
    input text  content  ${content}
    run keyword if  '${privacy}' != 'NA'  Set privacy  ${privacy}  ${password}
    run keyword if  '${publish_time}' != 'NA'  Publish time  ${publish_time}

Submit post
    [Arguments]  ${title}
    click button  publish
    wait until page contains  Edit Post
    click element  //*[@class='wp-menu-name'][text()='Posts']
    wait until page contains  ${title}

Delete post
    [Arguments]  ${text}=NA

    click element  //*[@class='wp-menu-name'][text()='Posts']
    wait until page contains  Title
    ${return} =  Click checkbox post  ${text}
    run keyword if  '${return}'!='not'  run keywords  select from list by value  bulk-action-selector-top  trash
    ...                            AND             click button  doaction
    ...                            AND             wait until page contains  moved to the Trash

Click checkbox post
    [Arguments]  ${text}

    run keyword if  '${text}'=='NA'  run keywords  select checkbox  cb-select-all-1
    ...                            AND             return from keyword   ok

    ${status}  @{list_element} =  run keyword and ignore error  get webelements  //a[contains(text(),'${text}')]/../../../th/input
    run keyword if  '${status}'=='FAIL'  run keywords  log  Sorry, no post found with ${text}  level=WARN
    ...     AND                   return from keyword  not
    :FOR  ${element}  IN  @{list_element}
    \  click element  ${element}
    return from keyword  ok

Upload media
    [Arguments]  ${mode}  ${path}

    click element  //*[@class='wp-menu-name'][text()='Media']
    wait until page contains  Media Library
    click element  //h1[contains(text(),'Media Library')]/a
    ${mode} =  convert to lowercase  ${mode}
    run keyword if  '${mode}'=='file'  Upload file  ${path}
    run keyword if  '${mode}'=='folder'  Upload folder  ${path}

Upload file
    [Arguments]  ${path}

    ${filename} =  fetch from right  ${path}  /
    Choose file upload  ${path}
    click element  //*[@class='wp-menu-name'][text()='Media']
    wait until page contains  ${filename}

Upload folder
    [Arguments]  ${path}

    @{list_file} =  list files in directory  ${path}
    :FOR  ${file}  IN  @{list_file}
    \  ${file_path} =  join path  ${path}  ${file}
    \  Choose file upload  ${file_path}
    \  wait until page contains  ${file}
    click element  //*[@class='wp-menu-name'][text()='Media']
#    wait until page contains  @{list_file}

Choose file upload
    [Arguments]  ${path}

    ${status} =  check file size  ${path}
    run keyword if  ${status}==True  choose file  //input[starts-with(@id,'html5_')]  ${path}

Click checkbox file
    [Arguments]  ${text}

    ${status}  @{list_element} =  run keyword and ignore error  get webelements  //img[contains(@src,'${text}')]/../../../../../th/input
    run keyword if  '${status}'=='FAIL'  run keywords  log  Sorry, there is no file with ${text}  level=WARN
    ...       AND                                      return from keyword  not
    :FOR  ${element}  IN  @{list_element}
    \  click element  ${element}
    return from keyword  ok


Delete media
    [Arguments]  ${text}

    click element  //*[@class='wp-menu-name'][text()='Media']
    wait until page contains  Media Library
    ${return} =  Click checkbox file  ${text}
    run keyword if  '${return}'!='not'  run keywords  select from list by value  bulk-action-selector-top  delete
    ...       AND                                     click button  doaction
    ...       AND                                     wait until page contains  permanently deleted



Add category
    [Arguments]  ${name}  ${slug}=NA  ${description}=NA

    click element  //*[@class='wp-menu-name'][text()='Posts']
    wait until page contains  Title
    click link  Categories
    input text  tag-name  ${name}
    run keyword if  '${slug}' != 'NA'  input text  tag-slug  ${slug}
    run keyword if  '${description}' != 'NA'  input text  tag-description  ${description}
    click button  submit

Create text post
    [Documentation]  This keyword creates posts that include only text
    [Arguments]  ${title}  ${content}  ${privacy}=NA  ${password}=123456  ${publish_time}=NA

    Create post  ${title}  ${content}  ${privacy}  ${password}  ${publish_time}
    Submit post  ${title}

Create video post
    [Documentation]  This keyword creates posts that include video
    [Arguments]  ${title}  ${content}  ${privacy}=NA  ${password}=123456  ${publish_time}=NA

    Create post  ${title}  ${content}  ${privacy}  ${password}  ${publish_time}
    select checkbox  post-format-video
    Submit post  ${title}

Create post from file
    [Documentation]  This keyword creates post with content was read from a file
    [Arguments]  ${title}  ${filename}  ${privacy}=NA  ${password}=123456  ${publish_time}=NA

    ${content} =  read file  ${filename}
    Create post  ${title}  ${content}  ${privacy}  ${password}  ${publish_time}
    Submit post  ${title}


Create post and insert media 1
    [Documentation]  Media file is uploaded from computer
    [Arguments]  ${title}  ${content}  ${path}  ${privacy}=NA  ${password}=123456  ${publish_time}=NA

    Create post  ${title}  ${content}  ${privacy}  ${password}  ${publish_time}
    click button  insert-media-button
    click element  //a[text()='Upload Files']
    Choose file upload  ${path}
    click button  Insert into post
    Submit post  ${title}

Create post and insert media 2
    [Documentation]  Media file is added from the library
    [Arguments]  ${title}  ${content}  ${filename}  ${privacy}=NA  ${password}=123456  ${publish_time}=NA

    Create post  ${title}  ${content}  ${privacy}  ${password}  ${publish_time}
    click button  insert-media-button
    click element   //a[text()='Media Library']
    click element  //img[contains(@src,'${filename}')]/../..
    click button  Insert into post
    Submit post  ${title}

Insert media from url
    [Arguments]  ${url}  ${caption}=NA  ${alt_text}=NA

    click button  insert-media-button
    click element   //a[text()='Insert from URL']
    clear element text  embed-url-field
    input text  embed-url-field  ${url}
    run keyword if  '${caption}' != 'NA'  input text  //textarea[@data-setting='caption']  ${caption}
    run keyword if  '${alt_text}' != 'NA'  input text  //input[@data-setting='alt']  ${alt_text}
    click button  Insert into post








