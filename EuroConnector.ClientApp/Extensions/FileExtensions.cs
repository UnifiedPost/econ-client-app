using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EuroConnector.ClientApp.Extensions
{
    public static class FileExtensions
    {
        public static void SaveMoveTo(this FileInfo file, string destination)
        {
            string renamed = RenameIfDuplicate(destination);
            file.MoveTo(renamed);
        }

        public static void SafeCopyTo(this FileInfo file, string destination)
        {
            string renamed = RenameIfDuplicate(destination);
            file.CopyTo(renamed);
        }

        private static string RenameIfDuplicate(string destination)
        {
            var extension = Path.GetExtension(destination);
            var path = Path.GetDirectoryName(destination);
            var filenameWithoutExtension = Path.GetFileNameWithoutExtension(destination);
            var pathWithoutExtension = Path.Combine(path, filenameWithoutExtension);

            int counter = 1;
            if (File.Exists(pathWithoutExtension + extension))
            {
                pathWithoutExtension = string.Format("{0}({1})", pathWithoutExtension, counter);
            }

            while (File.Exists(pathWithoutExtension + extension))
            {
                counter++;
                var withoutCounter = pathWithoutExtension.Substring(0, pathWithoutExtension.Length - 2 - (counter - 1).ToString().Length);
                pathWithoutExtension = string.Format("{0}({1})", withoutCounter, counter);
            }

            return pathWithoutExtension + extension;
        }
    }
}
