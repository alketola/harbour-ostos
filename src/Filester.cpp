/* SQLITE3 database export for Harbour-Ostos
 *
 * TODO: deleting sqlite database file
 */
#include "filester.h"
// Source material:
// https://www.sqlite.org/c3ref/backup_finish.html#sqlite3backupinit
// http://www.qtcentre.org/threads/36131-Attempting-to-use-Sqlite-backup-api-from-driver-handle-fails
//
using namespace std;
// PUBLIC
Filester::Filester() {
    Filester(DEFAULT_FILENAME);
};


Filester::Filester(QString fname){
    this->m_savefilename = fname;
    m_file.setFileName(this->m_savefilename);
};

Filester::~Filester() {
    Filester::closeWritable();
}

QString Filester::saveFileName(){
    return this->m_savefilename;
}

void Filester::setSaveFileName(QString name) {
    this->m_savefilename = name;
}

QString Filester::dbFileName() { return this->m_dbfilename; }
void Filester::setDbFileName(QString fname) { this->m_dbfilename = fname; }

QString Filester::tablename(){
    return this->m_tablename;
}

void Filester::setTableName(QString tname) {
    this->m_tablename=tname;
}

bool Filester::checkIfFileExists(QString path, QString filename) {
    qDebug() << QDir(path).exists(filename);
    return QDir(path).exists(filename);
}

bool Filester::checkIfDirectoryExists(QString path) {
    qDebug() << QDir(path).exists(".");
    return QDir(path).exists(".");
}

QString Filester::findDataBaseFile(QString path) {
    if(!Filester::checkIfDirectoryExists(path)) { return "DIRECTORY NOT FOUND"; }
    QDir dbDir(path);
    dbDir.setFilter(QDir::Files);
    dbDir.setSorting(QDir::Time);
    QStringList nameFilter;
    nameFilter<< "*.sqlite";
    dbDir.setNameFilters(nameFilter);
    QFileInfoList fileList = dbDir.entryInfoList();
    int size = fileList.size();
    if(size>0) {
        QFileInfo firstFile = fileList.at(size-1);
        return QString(firstFile.absoluteFilePath());
    } else {
       return("NOT FOUND");
    }

}

void Filester::saveDataBase(){
    //Filester::setFileName(DEFAULT_FILENAME);
    //Filester::setTableName(TABLENAME_SHOPPINGLIST);

    Filester::openDB();
    Filester::readAllDatabase();
    Filester::close();

}

void Filester::restoreDataBase(){

}

void Filester::smokeTest(int i){
    qDebug() << "Smoke on the water " << i;
    Filester::saveDataBase();
}

// PRIVATE
// SQLITE DB access methods

void Filester::openDB() {
    // Creating database connection
    m_db = QSqlDatabase::addDatabase("QSQLITE");
    m_db.setDatabaseName(".local/share/harbour-ostos/harbour-ostos/QML/OfflineStorage/Databases/0e031c6438291b06f5e5b9bd4a8a5ec4.sqlite");//this->m_filename);

    if (!m_db.open()) {
        qDebug() << "Error: connection with database failed";
    }
    else {
        qDebug() << "Database: connection ok";
        qDebug()<<m_db.tables();
    }
    qDebug() << m_db.databaseName();
    qDebug() << m_db.isValid();

}

void Filester::readAllDatabase() {
    QSqlQuery query;
    query.setForwardOnly(true);

    //query.prepare("SELECT * FROM shoppinglist"); //"VALUES(?,?)");
    //query.bindValue(":columns", "*");
    //query.bindValue(":tablename", TABLENAME_SHOPPINGLIST);
    //istat TEXT, iname TEXT PRIMARY KEY NOT NULL,
    //iqty TEXT, iunit TEXT, iclass TEXT, ishop TEXT,
    //hits INTEGER, seq INTEGER, control INTEGER
    if (this->m_file.open(QIODevice::ReadWrite)) {
        QTextStream writeStream(&(this->m_file));

        if(query.exec("SELECT * FROM shoppinglist"))
        {
            QSqlRecord rec = query.record();
            int maxCol = rec.count();
            QString lstring="";
            while(query.next()){
                for(int col=0;col<maxCol;col++) {
                    QString s = query.value(col).toString();
                    writeStream << s;
                    if (col<maxCol-1) { writeStream << "," ; }
                }
                writeStream << endl;
            }
            qDebug() << lstring;
        }
        else
        {
            qDebug(qPrintable(query.lastError().text()));
        }
        this->m_file.flush();
        this->m_file.close();
    }
}

// Close both file and database
void Filester::close() {
    // TODO NULL POINTER SAFETY
    m_file.close();
    m_db.close();
    m_db.removeDatabase("QSQLITE");
}

// Lower layer methods

QString Filester::read() {
    QString read_data ="";
    (this->m_savefilename);
    if (!m_file.open(QIODevice::ReadOnly | QIODevice::Text))
        return NULL;

    while (!m_file.atEnd()) {
        QByteArray line = m_file.readLine();
        // TODO process_line(line);
        // cout << line;
    }
    m_file.flush();
    m_file.close();
    return read_data;
}

bool Filester::openWritable() {
    if (m_file.isWritable()) return true;
    if (!m_file.open(QIODevice::WriteOnly | QIODevice::Text))
        return false;
    else
        return true;
}

void Filester::writeLine(QString line){
    if (!m_file.isWritable()) return;

    QTextStream out(&m_file);
    out << line;

}

void Filester::closeWritable() {
    m_file.flush();
    m_file.close();
}


