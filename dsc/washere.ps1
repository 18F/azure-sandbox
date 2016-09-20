Configuration DSCConf1 {
    Node "localhost" {
        File DSCFile {
            Ensure = 'Present'
            DestinationPath = 'C:\dsc_was_here'
            Contents = 'Hello World'
        }
   }
}

DSC1
