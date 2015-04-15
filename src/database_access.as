// ActionScript file
import flash.data.SQLConnection;
import flash.data.SQLStatement;
import flash.events.Event;
import flash.events.SQLErrorEvent;
import flash.events.SQLEvent;
import flash.filesystem.File;
import mx.collections.ArrayCollection;

[Bindable]
public var conn:SQLConnection = new SQLConnection();

[Bindable]
private var stmt:SQLStatement = new SQLStatement();

// ArrayCollection used as a data provider for the datagrid. It has to be bindable so that data in datagrid changes automatically when we change the ArrayCollection

[Bindable]
private var contactList:ArrayCollection = new ArrayCollection();

// function we call at the begining when application has finished loading and bulding itself
private function dbinit(event:Event):void
{
	var dir:File = File.applicationDirectory;
	//
	var db:File = dir.resolvePath("contacts.db");
	// after we set the file for our database we need to open it with our SQLConnection.
	conn.openAsync(db);
	//We set event listeners to check that the database is opened
	//The second event listener is to catch any processing errors
	//The last is handle the results from our queries since
	//Actionscript is an event based language.
	conn.addEventListener(SQLEvent.OPEN, dbLoaded);
	conn.addEventListener(SQLErrorEvent.ERROR, sqlError);
	conn.addEventListener(SQLEvent.RESULT, sqlResult);
}

//Function to check is the database is connected and that the contacts.db
//actually exist.
public function isDbConnected(conDb:SQLConnection):SQLConnection{
	var dir:File = File.applicationDirectory;
	var db:File = dir.resolvePath("contacts.db");
	if(!conDb.connected){
		conDb.open(db);
		conn.addEventListener(SQLEvent.OPEN, dbLoaded);
		conn.addEventListener(SQLErrorEvent.ERROR, sqlError);
		conn.addEventListener(SQLEvent.RESULT, sqlResult);
	}
	return conDb;
}


private function dbLoaded(op:SQLEvent):void{
	
	stmt.sqlConnection = conn;
	
	stmt.text = "CREATE TABLE IF NOT EXISTS contacts_t ( id INTEGER PRIMARY KEY AUTOINCREMENT, contactName TEXT, cellPhone TEXT, email TEXT);";
	
	stmt.execute();
	
}



private function sqlError(err:SQLErrorEvent):void{
	trace(err.error.message);
}
private function sqlResult(res:SQLEvent):void{
	
	var data:Array = stmt.getResult().data;
	contactList = new ArrayCollection();
	for(var d:int=0;d<=data.length-1;d++)
	{
		contactList.addItem({contactName:data[d].contactName,cellPhone:data[d].cellPhone,email:data[d].email});
	}
	// we pass the array of objects to our data provider to fill the datagrid
	
}

private function insertContact(contact:String, cell:String, email:String):void
{
	stmt.sqlConnection = this.isDbConnected(conn);
	
	stmt.text = "INSERT INTO contacts_t (contactName, cellPhone, email) VALUES('"+contact+"','"+cell+"','"+email+"');";
	stmt.execute();
	
}

private function selectContacts():void
{
	stmt.sqlConnection = this.isDbConnected(conn);
	stmt.text = "SELECT * FROM contacts_t";
	
	stmt.addEventListener(SQLErrorEvent.ERROR, sqlError);
	stmt.addEventListener(SQLEvent.RESULT, sqlResult);
	stmt.execute();
}

private function displayFunc(item:Object):String {
	return item.contactName + "\t" + item.cellPhone + "\t" +item.email;
}