from pathlib import Path
from tkinter import Tk, Canvas, Entry, Text, Button, PhotoImage, Listbox, StringVar, Label, Frame, Scrollbar, VERTICAL, END
from tkinter.ttk import Combobox
import hashlib

def Authorization(db):
    from sql import LogInCheck
    window = Tk()

    new_window = ''
    UserLogin = ''

    OUTPUT_PATH = Path(__file__).parent
    ASSETS_PATH = OUTPUT_PATH / Path(r"C:\Users\micro\PycharmProjects\platform\assets_auth\frame0")

    def relative_to_assets(path: str) -> Path:
        return ASSETS_PATH / Path(path)

    def LogIn():
        login = entry_2.get()
        password = hashlib.md5(entry_1.get().encode()).hexdigest()
        if combobox_1.get() == 'Студент': table_name = 'students'
        elif combobox_1.get() == 'Автор': table_name = 'authors'
        else: table_name = ''

        try:
            record = db.fetch_data(LogInCheck(table_name, login))
            if record:
                if db.fetch_data(LogInCheck(table_name, login))[0]['password'] == password:
                    canvas.itemconfig(text_id, state = 'normal', text = 'Успешно', fill = '#00ff80')
                    nonlocal new_window
                    new_window = table_name
                    nonlocal UserLogin
                    UserLogin = login
                    window.destroy()
                else:
                    canvas.itemconfig(text_id, state = 'normal', text = 'Неверный пароль', fill = '#ff0000')
                    entry_1.delete(0, 'end')
            else:
                canvas.itemconfig(text_id, state = 'normal', text = 'Неверный логин или роль', fill = '#ff0000')
                entry_1.delete(0, 'end')
                entry_2.delete(0, 'end')
        except Exception as e:
            canvas.itemconfig(text_id, state='normal', text='Ошибка авторизации', fill='#ff0000')

        return

    def ToRegistrarion():
        nonlocal new_window
        new_window = 'Registration'
        window.destroy()

    #window = Tk()

    window.geometry("800x600+225+100")
    window.configure(bg = "#D9F3FF")
    window.title('Авторизация')

    canvas = Canvas(
        window,
        bg = "#D9F3FF",
        height = 600,
        width = 800,
        bd = 0,
        highlightthickness = 0,
        relief = "ridge"
    )

    canvas.place(x = 0, y = 0)
    canvas.create_text(
        278.0,
        63.0,
        anchor="nw",
        text="Авторизация",
        fill="#000000",
        font=("Inter", 36 * -1)
    )

    canvas.create_text(
        199.0,
        341.0,
        anchor="nw",
        text="Роль:",
        fill="#000000",
        font=("Inter", 24 * -1)
    )

    canvas.create_text(
        199.0,
        243.0,
        anchor="nw",
        text="Пароль:",
        fill="#000000",
        font=("Inter", 24 * -1)
    )

    canvas.create_text(
        199.0,
        147.0,
        anchor="nw",
        text="Логин:",
        fill="#000000",
        font=("Inter", 24 * -1)
    )

    entry_image_1 = PhotoImage(
        file=relative_to_assets("entry_1.png"))
    entry_bg_1 = canvas.create_image(
        399.5,
        305.0,
        image=entry_image_1
    )
    entry_1 = Entry(
        bd=0,
        bg="#F4F4F4",
        fg="#000716",
        highlightthickness=0,
        show = '*'
    )
    entry_1.place(
        x=199.0,
        y=290.0,
        width=401.0,
        height=28.0
    )

    entry_image_2 = PhotoImage(
        file=relative_to_assets("entry_2.png"))
    entry_bg_2 = canvas.create_image(
        399.5,
        206.0,
        image=entry_image_2
    )
    entry_2 = Entry(
        bd=0,
        bg="#F3F3F3",
        fg="#000716",
        highlightthickness=0
    )
    entry_2.place(
        x=199.0,
        y=191.0,
        width=401.0,
        height=28.0
    )

    combobox_1 = Combobox(
        values=['Студент', 'Автор']
    )
    combobox_1.place(
        x=296,
        y=352,
        width=155,
        height=27
    )

    button_image_1 = PhotoImage(
        file=relative_to_assets("button_1.png"))
    button_1 = Button(
        image=button_image_1,
        borderwidth=0,
        highlightthickness=0,
        command=LogIn,
        relief="flat"
    )
    button_1.place(
        x=265.8337097167969,
        y=451.7078552246094,
        width=267.9892883300781,
        height=35.795318603515625
    )

    text_id = canvas.create_text(
        49.0,
        406.0,
        anchor="nw",
        text="Уведомление",
        fill="#FF0000",
        font=("Inter", 24 * -1),
        state = "hidden"
    )

    button_image_2 = PhotoImage(
        file=relative_to_assets("button_2.png"))
    button_2 = Button(
        image=button_image_2,
        borderwidth=0,
        highlightthickness=0,
        command=ToRegistrarion,
        relief="flat"
    )
    button_2.place(
        x=300.0,
        y=504.0,
        width=200.0,
        height=22.0
    )
    window.resizable(False, False)
    window.mainloop()
    return new_window, UserLogin

def Registration(db):
    from sql import RegInDb
    window = Tk()

    new_window = ''

    OUTPUT_PATH = Path(__file__).parent
    ASSETS_PATH = OUTPUT_PATH / Path(r"C:\Users\micro\PycharmProjects\platform\assets_reg\frame0")

    def relative_to_assets(path: str) -> Path:
        return ASSETS_PATH / Path(path)

    def ToAuthorisation():
        nonlocal new_window
        new_window = 'Authorization'
        window.destroy()

    def SignIn():
        name = entry_1.get()
        surname = entry_2.get()
        email = entry_3.get()
        login = entry_4.get()
        password = hashlib.md5(entry_5.get().encode()).hexdigest()
        age = entry_6.get()
        if combobox_1.get() == 'Студент': table_name = 'students'
        elif combobox_1.get() == 'Автор': table_name = 'authors'
        else: table_name = ''

        try:
            #print(table_name, name, surname, age, login, email, password)
            db.execute_query(RegInDb(table_name, name, surname, age, login, email, password))
            canvas.itemconfig(text_id, state='normal', text='Успешно', fill='#00ff80')
            entry_1.delete(0, 'end')
            entry_2.delete(0, 'end')
            entry_3.delete(0, 'end')
            entry_4.delete(0, 'end')
            entry_5.delete(0, 'end')
            entry_6.delete(0, 'end')
        except Exception as e:
            canvas.itemconfig(text_id, state='normal', text='Ошибка при регистрации', fill='#ff0000')



    window.geometry("800x600+225+100")
    window.configure(bg="#D9F3FF")
    window.title('Регистрация')

    canvas = Canvas(
        window,
        bg="#D9F3FF",
        height=600,
        width=800,
        bd=0,
        highlightthickness=0,
        relief="ridge"
    )

    canvas.place(x=0, y=0)
    canvas.create_text(
        278.0,
        26.0,
        anchor="nw",
        text="Регистрация",
        fill="#000000",
        font=("Inter", 36 * -1)
    )

    canvas.create_text(
        199.0,
        400.0,
        anchor="nw",
        text="Роль:",
        fill="#000000",
        font=("Inter", 16 * -1)
    )

    canvas.create_text(
        199.0,
        93.0,
        anchor="nw",
        text="Имя:",
        fill="#000000",
        font=("Inter", 16 * -1)
    )

    entry_image_1 = PhotoImage(
        file=relative_to_assets("entry_1.png"))
    entry_bg_1 = canvas.create_image(
        399.5,
        125.5,
        image=entry_image_1
    )
    entry_1 = Entry(
        bd=0,
        bg="#F3F3F3",
        fg="#000716",
        highlightthickness=0
    )
    entry_1.place(
        x=199.0,
        y=113.0,
        width=401.0,
        height=23.0
    )

    canvas.create_text(
        199.0,
        138.0,
        anchor="nw",
        text="Фамилия:",
        fill="#000000",
        font=("Inter", 16 * -1)
    )

    entry_image_2 = PhotoImage(
        file=relative_to_assets("entry_2.png"))
    entry_bg_2 = canvas.create_image(
        399.5,
        168.5,
        image=entry_image_2
    )
    entry_2 = Entry(
        bd=0,
        bg="#F3F3F3",
        fg="#000716",
        highlightthickness=0
    )
    entry_2.place(
        x=199.0,
        y=156.0,
        width=401.0,
        height=23.0
    )

    canvas.create_text(
        199.0,
        183.0,
        anchor="nw",
        text="Email:",
        fill="#000000",
        font=("Inter", 16 * -1)
    )

    entry_image_3 = PhotoImage(
        file=relative_to_assets("entry_3.png"))
    entry_bg_3 = canvas.create_image(
        399.5,
        217.5,
        image=entry_image_3
    )
    entry_3 = Entry(
        bd=0,
        bg="#F3F3F3",
        fg="#000716",
        highlightthickness=0
    )
    entry_3.place(
        x=199.0,
        y=205.0,
        width=401.0,
        height=23.0
    )

    canvas.create_text(
        199.0,
        232.0,
        anchor="nw",
        text="Логин:",
        fill="#000000",
        font=("Inter", 16 * -1)
    )

    entry_image_4 = PhotoImage(
        file=relative_to_assets("entry_4.png"))
    entry_bg_4 = canvas.create_image(
        399.5,
        264.5,
        image=entry_image_4
    )
    entry_4 = Entry(
        bd=0,
        bg="#F3F3F3",
        fg="#000716",
        highlightthickness=0
    )
    entry_4.place(
        x=199.0,
        y=252.0,
        width=401.0,
        height=23.0
    )

    canvas.create_text(
        199.0,
        279.0,
        anchor="nw",
        text="Пароль:",
        fill="#000000",
        font=("Inter", 16 * -1)
    )

    entry_image_5 = PhotoImage(
        file=relative_to_assets("entry_5.png"))
    entry_bg_5 = canvas.create_image(
        399.5,
        312.5,
        image=entry_image_5
    )
    entry_5 = Entry(
        bd=0,
        bg="#F3F3F3",
        fg="#000716",
        highlightthickness=0,
        show = '*'
    )
    entry_5.place(
        x=199.0,
        y=300.0,
        width=401.0,
        height=23.0
    )

    canvas.create_text(
        199.0,
        329.0,
        anchor="nw",
        text="Возраст:",
        fill="#000000",
        font=("Inter", 16 * -1)
    )

    entry_image_6 = PhotoImage(
        file=relative_to_assets("entry_6.png"))
    entry_bg_6 = canvas.create_image(
        399.5,
        362.5,
        image=entry_image_6
    )
    entry_6 = Entry(
        bd=0,
        bg="#F3F3F3",
        fg="#000716",
        highlightthickness=0
    )
    entry_6.place(
        x=199.0,
        y=350.0,
        width=401.0,
        height=23.0
    )

    combobox_1 = Combobox(
        values=['Студент', 'Автор']
    )
    combobox_1.place(
        x=278,
        y=400,
        width=155,
        height=25
    )


    button_image_1 = PhotoImage(
        file=relative_to_assets("button_1.png"))
    button_1 = Button(
        image=button_image_1,
        borderwidth=0,
        highlightthickness=0,
        command=SignIn,
        relief="flat"
    )
    button_1.place(
        x=266.0,
        y=486.0,
        width=267.9892883300781,
        height=36.0
    )

    text_id = canvas.create_text(
        54.0,
        443.0,
        anchor="nw",
        text="Уведомление",
        fill="#FF0000",
        font=("Inter", 24 * -1),
        state="hidden"
    )

    button_image_2 = PhotoImage(
        file=relative_to_assets("button_2.png"))
    button_2 = Button(
        image=button_image_2,
        borderwidth=0,
        highlightthickness=0,
        command=ToAuthorisation,
        relief="flat"
    )
    button_2.place(
        x=300.0,
        y=533.0,
        width=200.0,
        height=22.0
    )
    window.resizable(False, False)
    window.mainloop()
    return new_window

def AuthorMain(db, UserLogin):
    from sql import MyCourses, GetUserInfo
    window = Tk()

    new_window = ''

    SelectedCourseTitle = ''

    def ProfileEdit():
        nonlocal new_window
        new_window = 'Editing'
        window.destroy()

    def AddCourse():
        nonlocal new_window
        new_window = 'AddCourse'
        window.destroy()

    def Exit():
        nonlocal new_window
        new_window = 'Authorization'
        window.destroy()


    window.geometry("800x600+225+100")
    window.configure(bg="#D9F3FF")
    window.title('Главная страница')

    main_frame = Frame(window, bg="#D9F3FF")
    main_frame.pack(expand=True, fill='both')

    course_scroll = Scrollbar(main_frame, orient=VERTICAL)
    course_scroll.grid(row=0, column=1, sticky='nsew')

    course_list = Frame(main_frame, bg="#D9F3FF")
    course_list.grid(row=0, column=0, sticky='nsew')

    course_canvas = Canvas(course_list, bg="#D9F3FF", yscrollcommand=course_scroll.set, width=750, height=550)
    course_canvas.pack(side='top', fill='both', expand=True)

    course_scroll.config(command=course_canvas.yview)

    course_frame = Frame(course_canvas, bg="#D9F3FF")
    course_frame.grid(row=0, column=0, sticky='nsew')

    course_canvas.create_window((0, 0), window=course_frame, anchor='nw')

    def on_frame_configure(event):
        course_canvas.configure(scrollregion=course_canvas.bbox("all"))

    course_frame.bind("<Configure>", on_frame_configure)

    UserInfo = db.fetch_data(GetUserInfo('authors', UserLogin))[0]

    role_label = Label(course_frame, text='Автор:')
    full_name_label = Label(course_frame, text=UserInfo['name']+ ' ' + UserInfo['surname'])
    role_label.grid(row = 0, column = 0, sticky = 'ew', columnspan = 2)
    full_name_label.grid(row = 1, column = 0, columnspan = 2, sticky = 'ewn')

    course_label = Label(course_frame, text='Курсы:', )
    course_label.grid(row = 0, column = 3, sticky='ew')

    courses = db.fetch_data(MyCourses(UserLogin)) #UserLogin
    titles = [course['title'] for course in courses]
    #print([course['title'] for course in courses])
    rows = len(titles)
    max_length = max(len(title) for title in titles)
    Courses = Listbox(
        course_frame,
        listvariable=StringVar(value=titles),
        height=rows,
        width=max_length + 2
    )
    Courses.grid(row=1, column=3)

    def SelecteCourse(event):
        SelectedIndex = Courses.curselection()
        nonlocal new_window
        new_window = 'EditCourse'
        nonlocal SelectedCourseTitle
        SelectedCourseTitle = Courses.get(SelectedIndex)
        window.destroy()

    options_label = Label(course_frame, text = 'Опции:')
    options_label.grid(row = 0, column = 4, columnspan=3, sticky = 'ew')

    Courses.bind('<<ListboxSelect>>', SelecteCourse)

    AddButton = Button(
        course_frame,
        text="Добавить курс",
        borderwidth=0,
        highlightthickness=0,
        command=AddCourse,
        relief="flat",
        highlightbackground = 'black'
    )

    AddButton.grid(row = 1, column = 4, sticky = 'ewn')

    ChangeButton = Button(
        course_frame,
        text="Редактировать профиль",
        borderwidth=0,
        highlightthickness=0,
        command=ProfileEdit,
        relief="flat",
        highlightbackground='black'
    )
    ChangeButton.grid(row = 1, column = 5, sticky = 'ewn')

    ExitButton = Button(
        course_frame,
        text="Выйти",
        borderwidth=0,
        highlightthickness=0,
        command=Exit,
        relief="flat",
        highlightbackground='black'
    )
    ExitButton.grid(row=1, column=6, sticky='ewn')

    window.resizable(False, False)
    window.mainloop()

    return new_window, UserLogin, 'authors', SelectedCourseTitle

def Editing(db, UserLogin, table_name):
    from sql import GetUserInfo, ChangeUserInfo

    window = Tk()

    OUTPUT_PATH = Path(__file__).parent
    ASSETS_PATH = OUTPUT_PATH / Path(r"C:\Users\micro\PycharmProjects\platform\assets_edit\frame0")

    def relative_to_assets(path: str) -> Path:
        return ASSETS_PATH / Path(path)

    def CommitEdit():
        NewName = entry_1.get()
        NewSurname = entry_2.get()
        NewAge = entry_4.get()
        NewPassword = entry_3.get()
        if NewPassword: NewPassword = hashlib.md5(entry_3.get().encode()).hexdigest()
        else: NewPassword = UserInfo['password']
        #print(NewPassword, NewSurname, NewName, NewAge)
        try:
            db.execute_query(ChangeUserInfo(table_name, UserLogin, NewName, NewSurname, NewAge, NewPassword))
            canvas.itemconfig(notice, text = 'Успешно', fill = '#00ff80', state = 'normal')
        except Exception as e:
            print(e)
            canvas.itemconfig(notice, text='Ошибка изменения', fill='#ff0000', state = 'normal')
            FillEntry()

    def FillEntry():
        entry_1.delete(0, 'end')
        entry_2.delete(0, 'end')
        entry_3.delete(0, 'end')
        entry_4.delete(0, 'end')
        entry_1.insert(0, UserInfo['name'])
        entry_2.insert(0, UserInfo['surname'])
        entry_4.insert(0, UserInfo['age'])

    window.geometry("800x600+225+100")
    window.title('Редактирование профиля')
    window.configure(bg="#D9F3FF")

    UserInfo = db.fetch_data(GetUserInfo(table_name, UserLogin))[0]

    canvas = Canvas(
        window,
        bg="#D9F3FF",
        height=600,
        width=800,
        bd=0,
        highlightthickness=0,
        relief="ridge"
    )

    canvas.place(x=0, y=0)
    canvas.create_text(
        171.0,
        80.0,
        anchor="nw",
        text="Редактирование профиля",
        fill="#000000",
        font=("Inter", 36 * -1)
    )

    canvas.create_text(
        199.0,
        157.0,
        anchor="nw",
        text="Имя:",
        fill="#000000",
        font=("Inter", 16 * -1)
    )

    entry_image_1 = PhotoImage(
        file=relative_to_assets("entry_1.png"))
    entry_bg_1 = canvas.create_image(
        399.5,
        189.5,
        image=entry_image_1
    )
    entry_1 = Entry(
        bd=0,
        bg="#F3F3F3",
        fg="#000716",
        highlightthickness=0
    )
    entry_1.place(
        x=199.0,
        y=177.0,
        width=401.0,
        height=23.0
    )

    canvas.create_text(
        199.0,
        219.0,
        anchor="nw",
        text="Фамилия:",
        fill="#000000",
        font=("Inter", 16 * -1)
    )

    entry_image_2 = PhotoImage(
        file=relative_to_assets("entry_2.png"))
    entry_bg_2 = canvas.create_image(
        399.5,
        249.5,
        image=entry_image_2
    )
    entry_2 = Entry(
        bd=0,
        bg="#F3F3F3",
        fg="#000716",
        highlightthickness=0
    )
    entry_2.place(
        x=199.0,
        y=237.0,
        width=401.0,
        height=23.0
    )

    canvas.create_text(
        199.0,
        342.0,
        anchor="nw",
        text="Пароль:",
        fill="#000000",
        font=("Inter", 16 * -1)
    )

    entry_image_3 = PhotoImage(
        file=relative_to_assets("entry_3.png"))
    entry_bg_3 = canvas.create_image(
        399.5,
        375.5,
        image=entry_image_3
    )
    entry_3 = Entry(
        bd=0,
        bg="#F3F3F3",
        fg="#000716",
        highlightthickness=0
    )
    entry_3.place(
        x=199.0,
        y=363.0,
        width=401.0,
        height=23.0
    )

    canvas.create_text(
        199.0,
        279.0,
        anchor="nw",
        text="Возраст:",
        fill="#000000",
        font=("Inter", 16 * -1)
    )

    entry_image_4 = PhotoImage(
        file=relative_to_assets("entry_4.png"))
    entry_bg_4 = canvas.create_image(
        399.5,
        312.5,
        image=entry_image_4
    )
    entry_4 = Entry(
        bd=0,
        bg="#F3F3F3",
        fg="#000716",
        highlightthickness=0
    )
    entry_4.place(
        x=199.0,
        y=300.0,
        width=401.0,
        height=23.0
    )

    FillEntry()

    button_image_1 = PhotoImage(
        file=relative_to_assets("button_1.png"))
    button_1 = Button(
        image=button_image_1,
        borderwidth=0,
        highlightthickness=0,
        command=CommitEdit,
        relief="flat"
    )
    button_1.place(
        x=266.0,
        y=447.0,
        width=267.9892883300781,
        height=35.795318603515625
    )

    notice = canvas.create_text(
        54.0,
        405.0,
        anchor="nw",
        text="Уведомление",
        fill="#FF0000",
        font=("Inter", 24 * -1),
        state='hidden'
    )

    button_image_2 = PhotoImage(
        file=relative_to_assets("button_2.png"))
    button_2 = Button(
        image=button_image_2,
        borderwidth=0,
        highlightthickness=0,
        command=window.destroy,
        relief="flat"
    )
    button_2.place(
        x=300.0,
        y=500.0,
        width=200.0,
        height=22.0
    )
    window.resizable(False, False)
    window.mainloop()

    return table_name, UserLogin

def Adding(db, Userlogin):
    from sql import AddCourse

    window = Tk()

    OUTPUT_PATH = Path(__file__).parent
    ASSETS_PATH = OUTPUT_PATH / Path(r"C:\Users\micro\PycharmProjects\platform\assets_add\frame0")

    def relative_to_assets(path: str) -> Path:
        return ASSETS_PATH / Path(path)

    def AddingCourse():
        title = entry_1.get()
        description = entry_2.get("1.0", "end-1c")
        price = entry_3.get()
        try:
            db.execute_query(AddCourse(title, description, price, Userlogin))
            canvas.itemconfig(notice, text='Курс добавлен', state = 'normal', fill = '#00ff80')
        except Exception as e:
            print(e)
            canvas.itemconfig(notice, text='Ошибка добавления', state='normal', fill='#ff0000')

    window.geometry("800x600+225+100")
    window.title('Добавление курса')
    window.configure(bg="#D9F3FF")

    canvas = Canvas(
        window,
        bg="#D9F3FF",
        height=600,
        width=800,
        bd=0,
        highlightthickness=0,
        relief="ridge"
    )

    canvas.place(x=0, y=0)
    canvas.create_text(
        235.0,
        81.0,
        anchor="nw",
        text="Добавление курса",
        fill="#000000",
        font=("Inter", 36 * -1)
    )

    canvas.create_text(
        199.0,
        157.0,
        anchor="nw",
        text="Название:",
        fill="#000000",
        font=("Inter", 16 * -1)
    )

    entry_image_1 = PhotoImage(
        file=relative_to_assets("entry_1.png"))
    entry_bg_1 = canvas.create_image(
        399.5,
        189.5,
        image=entry_image_1
    )
    entry_1 = Entry(
        bd=0,
        bg="#F3F3F3",
        fg="#000716",
        highlightthickness=0
    )
    entry_1.place(
        x=199.0,
        y=177.0,
        width=401.0,
        height=23.0
    )

    canvas.create_text(
        199.0,
        219.0,
        anchor="nw",
        text="Описание:",
        fill="#000000",
        font=("Inter", 16 * -1)
    )

    entry_image_2 = PhotoImage(
        file=relative_to_assets("entry_2.png"))
    entry_bg_2 = canvas.create_image(
        399.5,
        270.0,
        image=entry_image_2
    )
    entry_2 = Entry(
        bd=0,
        bg="#F3F3F3",
        fg="#000716",
        highlightthickness=0
    )
    entry_2 = Text(
        window,
        wrap="word",
        height=10,
        background = '#F3F3F3'
    )
    entry_2.place(
        x=199.0,
        y=239.0,
        width=401.0,
        height=60.0
    )

    canvas.create_text(
        199.0,
        318.0,
        anchor="nw",
        text="Цена:",
        fill="#000000",
        font=("Inter", 16 * -1)
    )

    entry_image_3 = PhotoImage(
        file=relative_to_assets("entry_4.png"))
    entry_bg_3 = canvas.create_image(
        399.5,
        351.5,
        image=entry_image_3
    )
    entry_3 = Entry(
        bd=0,
        bg="#F3F3F3",
        fg="#000716",
        highlightthickness=0
    )
    entry_3.place(
        x=199.0,
        y=339.0,
        width=401.0,
        height=23.0
    )

    button_image_1 = PhotoImage(
        file=relative_to_assets("button_1.png"))
    button_1 = Button(
        image=button_image_1,
        borderwidth=0,
        highlightthickness=0,
        command=AddingCourse,
        relief="flat"
    )
    button_1.place(
        x=266.0,
        y=423.0,
        width=267.9892883300781,
        height=35.795318603515625
    )

    notice = canvas.create_text(
        54.0,
        381.0,
        anchor="nw",
        text="Уведомление",
        fill="#FF0000",
        font=("Inter", 24 * -1),
        state = 'hidden'
    )

    button_image_2 = PhotoImage(
        file=relative_to_assets("button_2.png"))
    button_2 = Button(
        image=button_image_2,
        borderwidth=0,
        highlightthickness=0,
        command=window.destroy,
        relief="flat"
    )
    button_2.place(
        x=300.0,
        y=476.0,
        width=200.0,
        height=22.0
    )
    window.resizable(False, False)
    window.mainloop()

    return 'authors', Userlogin

def EditCourse(db, title, UserLogin):
    from time import sleep
    from sql import GetCourseInfo, ChangeCourseInfo, DeleteCourseRecord, GetLessons, ChangeLessonInfo, DeleteLessonInfo, CreateLessonRecord

    window = Tk()

    CourseInfo = {}
    CourseLessons = []
    counter = 3

    def FillCourseEntry():
        nonlocal CourseInfo
        CourseInfo = db.fetch_data(GetCourseInfo(title))[0]
        EntryCTitle.delete("1.0", END)
        EntryCDescription.delete("1.0", END)
        EntryPrice.delete("1.0", END)
        EntryCTitle.insert("1.0", CourseInfo['title'])
        EntryCDescription.insert("1.0", CourseInfo['description'])
        EntryPrice.insert("1.0", CourseInfo['price'])

    def ChangeCourseInformation():
        nonlocal counter
        counter = 3
        NewTitle = EntryCTitle.get("1.0", END).strip()
        NewDescription = EntryCDescription.get("1.0", END).strip()
        NewPrice = EntryPrice.get("1.0", END).split(' ?')[0].replace(',', '.')
        try:
            nonlocal title
            db.execute_query(ChangeCourseInfo(title, NewTitle, NewDescription, NewPrice))
            title = NewTitle
            FillCourseEntry()
            NoticeCLabel.config(text='Успешно изменено', state='active', foreground='#00ff80')
        except Exception as e:
            NoticeCLabel.config(text='Ошибка изменения', state='active', foreground='#ff0000')
            FillCourseEntry()
            print(e)

    def DeleteCourse():
        nonlocal counter
        counter -= 1
        if counter:
            NoticeCLabel.config(text=f'Чтобы удалить курс нажмите еще {counter} раз', state='normal', foreground='#ff0000')
        else:
            try:
                db.execute_query(DeleteCourse(title))
                NoticeCLabel.config(text='Курс успешно удален', state='active', foreground='#00ff80')
                sleep(2)
                window.destroy()
            except Exception as e:
                print(e)
                NoticeCLabel.config(text='Ошибка удаления', state='active', foreground='#ff0000')

    window.geometry("800x600+225+100")
    window.configure(bg="#D9F3FF")
    window.title('Редактирование курса')

    main_frame = Frame(window, bg="#D9F3FF")
    main_frame.pack(expand=True, fill='both')

    top_frame = Frame(main_frame, bg="#D9F3FF")
    top_frame.grid(row=0, column=0)
    top_frame.pack(side='top', padx=10, pady=10, fill='both', expand=True)

    bottom_frame = Frame(main_frame, bg="#D9F3FF")
    bottom_frame.pack(side='bottom', padx=10, pady=10, fill='both', expand=True)

    #Верхний фрейм

    MainLabel = Label(top_frame, text=f'Курс "{title}":')
    MainLabel.grid(row=0, column=0, columnspan=6, sticky='ew')

    ExitButton = Button(top_frame, text='Вернуться назад', borderwidth=0, highlightthickness=0,
                        command=window.destroy, relief="flat")
    ExitButton.grid(row=0, column=7)

    CourseLabel = Label(top_frame, text='Курс:')
    CourseLabel.grid(row=1, column=0, sticky='ewsn', rowspan=2)

    TitleCLabel = Label(top_frame, text='Название:')
    TitleCLabel.grid(row=1, column=1, sticky='ew')

    DescriptionCLabel = Label(top_frame, text='Описание:')
    DescriptionCLabel.grid(row=1, column=2, sticky='ew')

    PriceLabel = Label(top_frame, text='Цена:')
    PriceLabel.grid(row=1, column=3, sticky='ew')

    ActionCLabel = Label(top_frame, text='Действия:')
    ActionCLabel.grid(row=1, column=4, sticky='ew', columnspan=2)

    EntryCTitle = Text(top_frame, wrap="word", height=3, background='#F3F3F3', width=25)
    EntryCTitle.grid(row=2, column=1, sticky='ewns')

    EntryCDescription = Text(top_frame, wrap='word', height=6, background='#F3F3F3', width=25)
    EntryCDescription.grid(row=2, column=2, sticky='ewns')

    EntryPrice = Text(top_frame, wrap='word', height=1, background='#F3F3F3', width=7)
    EntryPrice.grid(row=2, column=3, sticky='ewns')

    ActionCButton1 = Button(top_frame, text='Изменить', borderwidth=0, highlightthickness=0,
                            command=ChangeCourseInformation, relief="flat")
    ActionCButton1.grid(row=2, column=4, sticky='ewns')

    ActionCButton2 = Button(top_frame, text='Удалить', borderwidth=0, highlightthickness=0,
                            command=DeleteCourse, relief="flat", foreground='#ff0000')
    ActionCButton2.grid(row=2, column=5, sticky='ewns')

    NoticeCLabel = Label(top_frame, text='', state='disabled')
    NoticeCLabel.grid(row=3, column=0, columnspan=6, sticky='ew')

    FillCourseEntry()

    # Нижний фрейм

    def FillEntry():
        for LessonId in LessonsData.keys():
            for label in ['lesson_number', 'title', 'description', 'other', 'link']:
                LessonsWidget[LessonId][label].delete('1.0', END)
                LessonsWidget[LessonId][label].insert('1.0', LessonsData[LessonId][label])

    def ChangeLesson(LessonId):
        NewTitle = LessonsWidget[LessonId]['title'].get('1.0', END)
        NewDescription = LessonsWidget[LessonId]['description'].get('1.0', END)
        NewOther = LessonsWidget[LessonId]['other'].get('1.0', END)
        NewLink = LessonsWidget[LessonId]['link'].get('1.0', END)
        NewNumber = LessonsWidget[LessonId]['lesson_number'].get('1.0', END)
        #print(NewTitle, NewDescription, NewOther, NewLink, NewNumber)
        try:
            db.execute_query(ChangeLessonInfo(LessonId, NewTitle, NewDescription, NewOther, NewLink, NewNumber))
            LessonsWidget[LessonId]['ChangeButton'].config(text='Успешно', foreground='#00ff80')
            sleep(1)
            LessonsWidget[LessonId]['ChangeButton'].config(text='Изменить', foreground='#000000')
            FillEntry()
        except Exception as e:
            print(e)
            LessonsWidget[LessonId]['ChangeButton'].config(text='Ошибка', foreground='#ff0000')
            sleep(1)
            LessonsWidget[LessonId]['ChangeButton'].config(text='Изменить', foreground='#000000')

    def create_change_button(lesson_id):
        return lambda: ChangeLesson(lesson_id)

    LessonsData = {}
    LessonsWidget = {}
    NewLessonWidget = {}
    def DeleteLesson(LessonId):
        try:
            db.execute_query(DeleteLessonInfo(LessonId))
            #print('Все гуд')
            LessonsWidget[LessonId]['DeleteButton'].config(text='Успешно', foreground='#00ff80')
            sleep(1)
            LessonsWidget[LessonId]['DeleteButton'].config(text='Удалить', foreground='#ff0000')
            LessonsWidget[LessonId]['lesson_number'].destroy()
            LessonsWidget[LessonId]['title'].destroy()
            LessonsWidget[LessonId]['description'].destroy()
            LessonsWidget[LessonId]['other'].destroy()
            LessonsWidget[LessonId]['link'].destroy()
            LessonsWidget[LessonId]['DeleteButton'].destroy()
            LessonsWidget[LessonId]['ChangeButton'].destroy()
            DrawLessons()
            FillEntry()
        except Exception as e:
            print(e)
            LessonsWidget[LessonId]['DeleteButton'].config(text='Ошибка', foreground='#ff0000')
            sleep(1)
            LessonsWidget[LessonId]['DeleteButton'].config(text='Удалить', foreground='#ff0000')

    def create_delete_button(lesson_id):
        return lambda: DeleteLesson(lesson_id)

    def DrawLessons():
        CourseLessons = db.fetch_data(GetLessons(title))

        nonlocal LessonsData
        LessonsData = {}
        nonlocal LessonsWidget
        LessonsWidget = {}

        for row_number, lesson in enumerate(CourseLessons):
            row_number += 1
            #print(lesson)
            lesson_id = lesson['lesson_id']
            LessonsData[lesson_id] = lesson
            Widgets = {}
            Widgets['lesson_number'] = Text(
                lesson_frame,
                wrap="word",
                height=1,
                background='#F3F3F3',
                width=5
            )
            Widgets['lesson_number'].grid(row=row_number, column=1, sticky='ewns')

            Widgets['title'] = Text(
                lesson_frame,
                wrap="word",
                height=3,
                background='#F3F3F3',
                width=17
            )
            Widgets['title'].grid(row=row_number, column=2, sticky='ewns')

            Widgets['description'] = Text(
                lesson_frame,
                wrap="word",
                height=6,
                background='#F3F3F3',
                width=20
            )
            Widgets['description'].grid(row=row_number, column=3, sticky='ewns')

            Widgets['other'] = Text(
                lesson_frame,
                wrap="word",
                height=6,
                background='#F3F3F3',
                width=15
            )
            Widgets['other'].grid(row=row_number, column=4, sticky='ewns')

            Widgets['link'] = Text(
                lesson_frame,
                wrap="word",
                height=6,
                background='#F3F3F3',
                width=15
            )
            Widgets['link'].grid(row=row_number, column=5, sticky='ewns')

            Widgets['ChangeButton'] = Button(
                lesson_frame,
                text='Изменить',
                borderwidth=0,
                highlightthickness=0,
                command=create_change_button(lesson_id),
                relief="flat"
            )
            Widgets['ChangeButton'].grid(row=row_number, column=6, sticky='ewns')

            Widgets['DeleteButton'] = Button(
                lesson_frame,
                text='Удалить',
                borderwidth=0,
                highlightthickness=0,
                command=create_delete_button(lesson_id),
                relief="flat",
                foreground='#ff0000'
            )
            Widgets['DeleteButton'].grid(row=row_number, column=7, sticky='ewns')

            LessonsWidget[lesson_id] = Widgets

    def CreateLesson():
        lesson_number = NewLessonWidget['lesson_number'].get('1.0', END)
        LessonTitle = NewLessonWidget['title'].get('1.0', END)
        description = NewLessonWidget['description'].get('1.0', END)
        other = NewLessonWidget['other'].get('1.0', END)
        link = NewLessonWidget['link'].get('1.0', END)
        #print(lesson_number, LessonTitle, description, other, link)
        try:
            db.execute_query(CreateLessonRecord(title, LessonTitle, description, other, link, lesson_number))
            NewLessonWidget['CreateButton'].config(text='Успешно', foreground='#00ff80')
            sleep(1)
            NewLessonWidget['CreateButton'].config(text='Создать', foreground='#000000')
            NewLessonWidget['lesson_number'].destroy()
            NewLessonWidget['title'].destroy()
            NewLessonWidget['description'].destroy()
            NewLessonWidget['other'].destroy()
            NewLessonWidget['link'].destroy()
            NewLessonWidget['CreateButton'].destroy()
            DrawLessons()
            FillEntry()
            CreateLessonMaket()
        except Exception as e:
            print(e)
            NewLessonWidget['CreateButton'].config(text='Ошибка', foreground='#ff0000')
            sleep(1)
            NewLessonWidget['CreateButton'].config(text='Создать', foreground='#000000')
    def CreateLessonMaket():
        row_number = len(LessonsData.keys()) + 3

        NewLessonNumber = Text(
            lesson_frame,
            wrap="word",
            height=1,
            background='#F3F3F3',
            width=5
        )
        NewLessonNumber.grid(row=row_number, column=1, sticky='ewns')

        NewTitleLabel = Text(
            lesson_frame,
            wrap="word",
            height=3,
            background='#F3F3F3',
            width=17
        )
        NewTitleLabel.grid(row=row_number, column=2, sticky='ewns')

        NewDescriptionLabel = Text(
            lesson_frame,
            wrap="word",
            height=6,
            background='#F3F3F3',
            width=20
        )
        NewDescriptionLabel.grid(row=row_number, column=3, sticky='ewns')

        NewOtherLabel = Text(
            lesson_frame,
            wrap="word",
            height=6,
            background='#F3F3F3',
            width=15
        )
        NewOtherLabel.grid(row=row_number, column=4, sticky='ewns')

        NewLinkLabel = Text(
            lesson_frame,
            wrap="word",
            height=6,
            background='#F3F3F3',
            width=15
        )
        NewLinkLabel.grid(row=row_number, column=5, sticky='ewns')

        NewCreateButton = Button(
            lesson_frame,
            text='Создать',
            borderwidth=0,
            highlightthickness=0,
            command=CreateLesson,
            relief="flat"
        )
        NewCreateButton.grid(row=row_number, column=6, columnspan=2, sticky='ewns')

        nonlocal NewLessonWidget

        NewLessonWidget = {
            'lesson_number': NewLessonNumber,
            'title': NewTitleLabel,
            'description': NewDescriptionLabel,
            'other': NewOtherLabel,
            'link': NewLinkLabel,
            'CreateButton': NewCreateButton
        }



    lesson_scroll = Scrollbar(bottom_frame, orient=VERTICAL)
    lesson_scroll.grid(row=0, column=1, sticky='nsew')

    lesson_list = Frame(bottom_frame, bg="#D9F3FF")
    lesson_list.grid(row=0, column=0, sticky='nsew')

    lesson_canvas = Canvas(lesson_list, bg="#D9F3FF", yscrollcommand=lesson_scroll.set, width=750)
    lesson_canvas.pack(side='left', fill='both', expand=True)

    lesson_scroll.config(command=lesson_canvas.yview)

    lesson_frame = Frame(lesson_canvas, bg="#D9F3FF")
    lesson_frame.grid(row=0, column=0, sticky='nsew')

    lesson_canvas.create_window((0, 0), window=lesson_frame, anchor='nw')

    def on_frame_configure(event):
        lesson_canvas.configure(scrollregion=lesson_canvas.bbox("all"))

    lesson_frame.bind("<Configure>", on_frame_configure)

    NumberLabel = Label(
        lesson_frame,
        text='Номер:'
    )
    NumberLabel.grid(row=0, column=1, sticky='ewns')

    TitleLLabel = Label(
        lesson_frame,
        text='Название:'
    )
    TitleLLabel.grid(row=0, column=2, sticky='ewns')

    DescriptionLLabel = Label(
        lesson_frame,
        text='Описание:'
    )
    DescriptionLLabel.grid(row=0, column=3, sticky='ewns')

    OtherLabel = Label(
        lesson_frame,
        text='Другое:'
    )
    OtherLabel.grid(row=0, column=4, sticky='ewns')

    LinlLabel = Label(
        lesson_frame,
        text='Ссылка:'
    )
    LinlLabel.grid(row=0, column=5, sticky='ewns')

    ActionLLabel = Label(
        lesson_frame,
        text='Действия:'
    )
    ActionLLabel.grid(row=0, column=6, columnspan=2, sticky='ewns')

    DrawLessons()

    CreateLessonMaket()

    LessonsLabel = Label(
        lesson_frame,
        text='Уроки:'
    )
    LessonsLabel.grid(row=0, column=0, sticky='ewns', rowspan=len(LessonsData.keys()) + 2)

    NewLesson = 1

    FillEntry()

    window.mainloop()

    return 'authors', UserLogin

def StudentMain(db):
    window = Tk()

    window.geometry("800x600+225+100")
    window.title('Главная страница')
    window.configure(bg="#D9F3FF")

    NoticeLabel = Label(text='Скоро будет...', highlightcolor='#ff0000')
    NoticeLabel.pack(expand=True)

    ExitButton = Button(
        text='Выйти',
        command=window.destroy,
        relief="flat",
        foreground='#f3f3f3',
        highlightcolor='#ff0000'
    )
    ExitButton.pack(expand=True)

    window.resizable(False, False)
    window.mainloop()

    return 'Authorization'

