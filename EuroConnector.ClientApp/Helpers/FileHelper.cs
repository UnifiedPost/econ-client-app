namespace EuroConnector.ClientApp.Helpers
{
    public static class FileHelper
    {

        public static string SafeMove(DirectoryInfo directory, FileInfo fileInfo)
        {
            string filename = Path.Combine(directory.FullName, fileInfo.Name);
            string renamed = RenameIfDuplicate(filename);
            fileInfo.MoveTo(renamed);
            return renamed;
        }

        public static string SafeCopy(DirectoryInfo directory, FileInfo fileInfo)
        {
            string filename = Path.Combine(directory.FullName, fileInfo.Name);
            string renamed = RenameIfDuplicate(filename);
            fileInfo.CopyTo(renamed);
            return renamed;
        }

        private static string RenameIfDuplicate(string filename)
        {
            int index = 0;
            while (File.Exists(filename))
            {
                var filenameWithoutExtension = Path.GetFileNameWithoutExtension(filename);

                if (filenameWithoutExtension.Contains('('))
                {
                    int underscoreIndex = filenameWithoutExtension.LastIndexOf('(');
                    filenameWithoutExtension = filenameWithoutExtension.Substring(0, underscoreIndex);
                }
                index++;

                filename = $"{filenameWithoutExtension}({index}){Path.GetExtension(filename)}";
            }

            return filename;
        }

    }
}
