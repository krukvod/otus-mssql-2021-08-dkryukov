using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;
using System.Diagnostics;

namespace ClassLibraryCmd
{
    public class Class1
    {
        //Тег, определяющий, что данная функция возвращает таблицу
        [Microsoft.SqlServer.Server.SqlFunction(FillRowMethodName = "FillRow",
        TableDefinition = "txt nvarchar(4000)")]
        public static System.Collections.IEnumerable FCmd(SqlString commandToRun, SqlString args)
        {
            Process p = new Process();
            p.StartInfo.UseShellExecute = false;
            p.StartInfo.RedirectStandardOutput = true;
            p.StartInfo.FileName = commandToRun.Value;
            p.StartInfo.Arguments = args.Value;
            p.Start();

            string value = p.StandardOutput.ReadToEnd();
            string[] spl = value.Split('\n');

            p.WaitForExit();
            return spl.ToArray();
        }

        //Функция заполнения таблицы
        public static void FillRow(Object obj, out string stringElement)
        {
            stringElement = obj.ToString();//Возвращает в таблицу строку
        }
    }
}
