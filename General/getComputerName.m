function [ host ] = getComputerName( )
    host = char( getHostName( java.net.InetAddress.getLocalHost ) );    
    tid = '';
    try
        t = getCurrentTask(); 
        tid = int2str(t.ID);
        host = [host, '_', tid];
    catch        
    end
end