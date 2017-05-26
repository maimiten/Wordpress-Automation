*** Settings ***
Library  Selenium2Library
Library  DateTime
Resource  Variables.robot
Resource  Keywords.robot
Library  PyKeywords.py
Suite Setup  Begin Web Case
Suite Teardown  End Web Case

*** Test Cases ***

Upload File
    [Tags]  upload
    Log In
    click element  //*[@class='wp-menu-name'][text()='Media']
    wait until page contains  Media Library
    click element  //h1[contains(text(),'Media Library')]/a
    wait until page contains element  //input[starts-with(@id,'html5_')]
    get source

Create New Post
    [Tags]  1

    Log In
#    Create video post  Kem Kool đi chơi  https://www.youtube.com/watch?v=Kl7tTpY8DKk  privacy=password  password=654321
#    Create text post  Private post  Only me can see this post  privacy=private
#    Create post from file  File post  C:/automation/robot_scripts/KemjaKool/test.txt  privacy=Password
#    Create post and insert media 1  Lanscape  This is a beautiful picture \n  C:/Users/dbien/Pictures/landscape-image.png
#    Create post and insert media 2  Flower  Simple but still beautiful \n  daisy

Create New Post with media
    [Tags]  6

    Log In
    Create post  Sunset  Sunset on the beach \n
    Insert media from url  http://maxpixel.freegreatpicture.com/static/photo/640/Sunrise-Landscape-Sunset-Sky-Summer-Sun-Ocean-1046475.jpg
    Submit post  Sunset

Delete posts
    [Tags]  2

    Log In
    Delete post  post

Add category
    [Tags]  3

    Log In
    Add category  video  description=Inlcudes all the blogs that have video

Upload New Media
    [Tags]  4

    Log In
#    Upload media  Folder  C:/Users/dbien/Pictures/flower/
    Upload media  file  C:/Users/dbien/Pictures/landscape-image.png

Delete media file
    [Tags]  5

    Log In
    Delete media  lotus








