function Data = SQLQuery_Ding(DBName,Server,Query)
persistent conn
if  isempty(conn) || strcmp(conn.instance,DBName)==0
    conn = database(DBName,'','',...
        'Vendor','Microsoft SQL Server','Server',Server,...
        'AuthType','Windows','portnumber',1433);
else
    ping(conn);
end
datatype = 'table';
setdbprefs('DataReturnFormat',datatype);
curs = exec(conn,Query);
curs=fetch(curs);
temp = curs.Data;
if strcmp(temp,'No Data')==1
    Data = [];
    Data=table(Data);
else
        Data = temp;
end

