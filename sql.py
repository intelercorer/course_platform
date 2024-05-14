def LogInCheck(table_name, login):
    LogInCheck = f'''
                    SELECT password
                    FROM {table_name}
                    WHERE login = '{login}';
                    '''
    return LogInCheck

def RegInDb(table_name, name, surname, age, login, email, password):
    RegInDb = f'''
                INSERT INTO {table_name}
                (name, surname, age, email, login, password)
                VALUES
                ('{name}', '{surname}', {age}, '{email}', '{login}', '{password}') 
                '''
    return RegInDb

def MyCourses(login):
    MyCourses = f'''
                SELECT * FROM courses
                JOIN authors USING (author_id)
                WHERE login = '{login}';
                '''
    return MyCourses

def GetUserInfo(table_name, login):
    GetUserInfo = f'''
                  SELECT *
                  FROM {table_name}
                  WHERE login = '{login}';
                  '''
    return GetUserInfo

def ChangeUserInfo(table_name, login, name, surname, age, passsword):
    ChangeUserInfo = f'''
                     UPDATE {table_name}
                     SET name = '{name}',
                     surname = '{surname}',
                     age = {age},
                     password = '{passsword}'
                     WHERE login = '{login}';
                     '''
    return ChangeUserInfo

def AddCourse(title, description, price, login):
    AddCourse = f"""
                INSERT INTO courses (title, description, price, author_id)
                VALUES
                ('{title}', '{description}', {price},
                (SELECT author_id FROM authors
                WHERE login = '{login}'));
                """
    return AddCourse

def GetCourseInfo(title):
    GetCourseInfo = f'''
                    SELECT * FROM courses
                    WHERE title = '{title}';
                    '''
    return GetCourseInfo

def ChangeCourseInfo(title, newtitle, description, price):
    ChangeCourseInfo = f'''
                     UPDATE courses
                     SET title = '{newtitle}',
                     description = '{description}',
                     price = {price}
                     WHERE title = '{title}';
                     '''
    return ChangeCourseInfo

def DeleteCourseRecord(title):
    DeleteCourse = f'''
                   DELETE FROM courses
                   WHERE title = '{title}';
                   '''

def GetLessons(title):
    GetLessons = f'''
                 SELECT lesson_number, l.title, l.description, other, link, lesson_id
                 FROM lessons l
                 JOIN courses c USING (course_id)
                 WHERE c.title = '{title}'
                 ORDER BY lesson_number;
                 '''
    return GetLessons

def ChangeLessonInfo(LessonId, title, description, other, link, number):
    ChangeLessonInfo = f'''
                   UPDATE lessons
                   SET title = '{title}',
                   description = '{description}',
                   other = '{other}',
                   link = '{link}',
                   lesson_number = {number}
                   WHERE lesson_id = {LessonId};
                   '''
    return ChangeLessonInfo

def DeleteLessonInfo(LessonId):
    DeleteLessonInfo = f'''
                        DELETE from lessons
                        WHERE lesson_id = {LessonId};
                        '''
    return DeleteLessonInfo

def CreateLessonRecord(CourseTitle, title, description, other, link, number):
    CreateLessonRecord = f'''
                         INSERT INTO lessons (title, description, other, link, lesson_number, course_id)
                         VALUES ('{title}', '{description}', '{other}', '{link}', {number},
                         (SELECT course_id FROM courses WHERE title = '{CourseTitle}'));
                         '''
    return CreateLessonRecord