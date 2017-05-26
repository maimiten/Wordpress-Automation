import os


def read_file(filename):
    try:
        content = open(filename).read()
        if content != '':
            return content
        else:
            return 'File is empty'
    except IOError:
        print "File '%s' is not found" %filename
        return 'Error'


def check_datetime(day,month,year):
    # print "day {}, month {}, year {}".format(day, month, year)
    day = int(day)
    month = int(month)
    year = int(year)
    if month==2:
        if year%4==0:
            if 1<=day<=29:
                return True
            else:
                return False
        else:
            if 1<=day<=28:
                return True
            else:
                return False
    elif month in {1,3,5,7,8,10,12}:
        if 1<=day<=31:
            return True
        else:
            return False
    elif month in {4,6,9,10}:
        if 1<=day<=30:
            return True
        else:
            return False
    else:
        return False

def check_filesize(file_path):
    if os.stat(file_path).st_size <= 2**21:
        return True
    else:
        return False

# print read_file('robot_scripts/KemjaKool/blog.txt')
# print check_datetime('10','4','2017')