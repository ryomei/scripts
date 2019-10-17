# Copy and Zip
This was created to help copying and zipping files after a .Net publish

### Very important!
**After you modify it, DO NOT forget to rename the configuration file: **
> **from:** config.template.pson
**to**: config.pson

------------

So let´s say you published to **`C:\Users\my-pretty-name-here\Documents\My Web Sites\WebSite1`** and you want to copy some especific files and folder.
Just add the source path to the config´s **sourceDirname**, the destination folder name and a list of files you want to copy, so it will look like this:

```
@{
    sourceDirname = "C:\Users\my-pretty-name-here\Documents\My Web Sites\WebSite1"
    destinationDirname = "WebSite1_copied_files"
    filesAndDirectories = @(
        "App_LocalResources",
        "bin",
        "Content",
        "Web.config"
        ...
        ...
}
```

The destination path will be the current location of the script file + **destinationDirname**, so if you run
the script at** `C:\Users\Digital Republic\Desktop\copy-and-zip.ps1`**, the result will be at
**`C:\Users\Digital Republic\Desktop\WebSite1_copied_files`** with also **`WebSite1_copied_files.zip`** if you choose to do so on the prompt at the end of the script.