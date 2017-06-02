#ifndef FILESTER_H
#define FILESTER_H

#include <Qt>
#include <QObject>
#include <QString>
#include <qqml.h>
#include <QtQml>
#include <QIODevice>
#include <QFile>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QSqlRecord>
#include <stdio.h>
#include <string.h>
#include <qstring.h>

#define DEFAULT_FILENAME "harbour-ostos-list-backup.txt"

#define DATABASEPATH "/home/nemo/.local/share/harbour-ostos/harbour-ostos/QML/OfflineStorage/Databases/"
#define SAVEPATH_DEFAULT "/home/nemo/"
#define SAVEPATH_SD "/media/sdcard/"
#define TABLENAME_SHOPPINGLIST "shoppinglist"
#define COLUMNS_SHOPPINGLIST "istat,iname,iqty,iunit,iclass,ishop,hits,seq,control "
//istat TEXT, iname TEXT PRIMARY KEY NOT NULL, iqty TEXT, iunit TEXT, iclass TEXT, ishop TEXT, hits INTEGER, seq INTEGER, control INTEGER
#define TABLENAME_SHOPS "shops"
#define TABLENAME_SETTINGS "settings"

class Filester:public QObject {
    Q_OBJECT
    Q_PROPERTY(QString saveFileName READ saveFileName WRITE setSaveFileName)
    Q_PROPERTY(QString dbFileName READ dbFileName WRITE setDbFileName)
public:
    Filester();
    Filester(QString filename);
    ~Filester();
    Q_INVOKABLE QString saveFileName();
    Q_INVOKABLE void setSaveFileName(QString name);

    Q_INVOKABLE QString tablename();
    Q_INVOKABLE void setTableName(QString tablename);

    Q_INVOKABLE QString dbFileName();
    Q_INVOKABLE void setDbFileName(QString fname);

    Q_INVOKABLE bool checkIfFileExists(QString path, QString filename);
    Q_INVOKABLE bool checkIfDirectoryExists(QString path);
    Q_INVOKABLE QString findDataBaseFile(QString path);
    Q_INVOKABLE void saveDataBase();
    Q_INVOKABLE void restoreDataBase();

    Q_INVOKABLE void smokeTest(int i);
private:
    QString m_savefilename;
    QFile m_file;

    QString m_tablename;
    QString m_dbpath;
    QString m_dbfilename;
    QSqlDatabase m_db;

    bool openWritable();
    void closeWritable();
    void writeLine(QString line);
    void openDB();
    void readAllDatabase();
    QString read();
    void close();
};

#endif // FILESTER_H
