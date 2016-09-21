
$TheData = @{
  AllNodes = @(
    @{
      NodeName = "localhost"
    },
    @{
      NodeName = "win2012copy"
    },
    @{
      NodeName = "win2012copy2.cloudapp.net"
    }
  ); 
}


Configuration DSCConf1 {
    Node $AllNodes.NodeName {
        File DSCFile {
            Ensure = 'Present'
            DestinationPath = 'C:\dsc_was_here'
            Contents = 'Hello World'
        }
   }
}

DSCConf1 -ConfigurationData $TheData
