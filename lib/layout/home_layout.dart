import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/modules/archived_tasks/archived_tasks.dart';
import 'package:todo_app/modules/done_tasks/done_tasks.dart';
import 'package:todo_app/modules/new_tasks/new_tasks.dart';

class HomeLayout extends StatefulWidget {

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

// 1. create database
// 2. create table
// 3. open database
// 4. insert to database
// 5. get from database
// 6. update on database
// 7. delete from database



class _HomeLayoutState extends State<HomeLayout> {

  int currentIndex = 0;
  List<Widget> screens =
  [
    NewTasksScreen(),
    DoneTasksScreen(),
    ArchivedTasksScreen(),
  ];

  List<String> titles=
  [
    'New Tasks',
    'Done Tasks',
    'Archived Tasks',
  ];

  Database database;
  var scaffoldKey= GlobalKey<ScaffoldState>();
  bool isBottomSheetShown = false;
  IconData fabIcon = Icons.edit;
  var titleController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();
  var formKey = GlobalKey<FormState>();



  @override
  void initState() {
    super.initState();
    createDatabase();
  }
  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(
          titles[currentIndex],
        ),
      ),
      body: screens[currentIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: ()
        {
          if(isBottomSheetShown)
          {
            if(formKey.currentState.validate())
            {
              insertToDatabase(
                title: titleController.text ,
                time: timeController.text,
                date: dateController.text,
              ).then((value) {
                Navigator.pop(context);
                isBottomSheetShown = false;
                setState(() {
                  fabIcon = Icons.edit;
                });
              });

            }

          }else{
            scaffoldKey.currentState.showBottomSheet((
              context)=> Container(
                color: Colors.grey[100],
                padding: EdgeInsets.all(20.0,),
                child: Form(
                  key: formKey,
                  child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children:
                  [
                  TextFormField(
                    keyboardType: TextInputType.text,

                    controller: titleController,
                  validator: (String value)
                  {
                    if(value.isEmpty){
                      return 'value must not be empty';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'Task Title',
                    prefixIcon: Icon(Icons.title,
                      //color: Colors.black26,
                    ),
                    border: OutlineInputBorder(
                      // borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
            ),
                  SizedBox(
                    height: 15.0,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.datetime,
                  controller: timeController,
                  onTap: (){
                    showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                    ).then((value)
                    {
                      timeController.text = value.format(context).toString();
                      print(value.format(context));
                    });
                  },
                  validator: (String value)
                  {
                    if(value.isEmpty){
                      return 'time must not be empty';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'Task Time',
                    prefixIcon: Icon(Icons.watch_later_outlined,
                      //color: Colors.black26,
                    ),
                    border: OutlineInputBorder(
                      // borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
            ),
                    SizedBox(
                      height: 15.0,
                    ),
                    TextFormField(
                      keyboardType: TextInputType.datetime,
                      controller: dateController,
                      onTap: (){
                        showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.parse('2022-06-30'),
                        ).then((value)
                        {
                          dateController.text=DateFormat.yMMMd().format(value);
                          //print(DateFormat.yMMMd().format(value));
                        });
                      },
                      validator: (String value)
                      {
                        if(value.isEmpty){
                          return 'date must not be empty';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: 'Task date',
                        prefixIcon: Icon(Icons.calendar_today,
                          //color: Colors.black26,
                        ),
                        border: OutlineInputBorder(
                          // borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                    ),
                  ],
            ),
                ),
              ),
            elevation : 20.0,
            ).closed.then((value) {
              isBottomSheetShown = false;
              setState(() {
                fabIcon = Icons.edit;
              });
            });
          isBottomSheetShown = true;
          setState(() {
           fabIcon= Icons.add;
          });
          }

        },
        child: Icon(
          fabIcon,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index)
        {
          setState(() {
            currentIndex=index;
          });
        },
        type: BottomNavigationBarType.fixed,

        items:
        [
          BottomNavigationBarItem(
              icon: Icon(Icons.menu),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.check_circle_outline),
            label: 'Done',
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.archive_outlined),
            label: 'Archived',
          ),
        ],
      ),
    );
  }
//Instance of 'Future<String>'
 Future<String>  getName () async
  {
    return 'Ahmed Ali';
  }

  void createDatabase()async
  {
    var database =await openDatabase(
      'todo.db',
      version: 1,
      onCreate: (database, version)
      {
        print('database created',);
        database.execute('CREATE TABLE tasks(id INTEGER PRIMARY KEY, date TEXT, time TEXT, title TEXT, status TEXT)').then((value)
        {
          print('table created',);
        }).catchError((error)
        {
          print('Error when creating table');
        });
      },
      onOpen: (database)
      {
        print('database opened');
      },
    );
  }

  Future insertToDatabase({
  @required String title,
  @required String time,
  @required String date,
})async
  {
   return await database.transaction((txn){
      txn.rawInsert('INSERT INTO tasks(title, data, time, status)VALUES("$title","$time","$date","new")').then((value){
        print('$value inserted successfully');
      }).catchError((error){
        print('Error when Inserting New Record ${error.toString()}');
      });
      return null;
    });
  }




}











