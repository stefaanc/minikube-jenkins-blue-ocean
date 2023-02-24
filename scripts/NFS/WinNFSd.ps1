#
# see https://github.com/winnfsd/winnfsd : an NFS server (NFS v3) for non-server Windows
#
.\WinNFSd.exe -addr ( Resolve-DnsName -Name $( hostname ) -DnsOnly ).IPAddress -pathFile .\paths.txt
