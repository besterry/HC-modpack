
using System;
using System.Text;
using System.Text.RegularExpressions;
using System.IO;
using System.Collections;
using System.Collections.Generic;

public class MusicGenerator
{
    public static void Main(string[] args)
    {
        deleteTCGFiles(@"..\lua\shared");
        deleteTCGFiles(@"..\lua\server\Items");
        deleteTCGFiles(@"..\scripts");
        // deleteAllFiles(@"..\textures\WorldItems");
        Console.WriteLine("\nPress any key..");
        Console.ReadKey();
    }
    
    
    public static void deleteTCGFiles(string type)
    {    
        var dir=new DirectoryInfo(type);
        foreach (FileInfo file in dir.GetFiles())
        {
            if (file.Name.StartsWith("TCG"))
            {
                file.Delete();
                Console.WriteLine(file.Name + " deleted.");
            }
        }
    }
    
    // public static void deleteAllFiles(string type)
    // {    
        // var dir=new DirectoryInfo(type);
        // foreach (FileInfo file in dir.GetFiles())
        // {
            
            // file.Delete();
        // }
        // Console.WriteLine(type + " deleted.");
    // }
}

