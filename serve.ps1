$source = @"
using System;
using System.IO;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Threading;

public class MiniServer {
    public static void Run(int port, string filePath) {
        TcpListener listener = new TcpListener(IPAddress.Any, port);
        listener.Start();
        Console.WriteLine("SERVER_READY_PORT_" + port);
        while (true) {
            try {
                TcpClient client = listener.AcceptTcpClient();
                ThreadPool.QueueUserWorkItem((obj) => {
                    TcpClient c = (TcpClient)obj;
                    try {
                        using (c)
                        using (NetworkStream stream = c.GetStream()) {
                            stream.ReadTimeout = 3000;
                            stream.WriteTimeout = 3000;
                            byte[] buf = new byte[2048];
                            int read = stream.Read(buf, 0, buf.Length);
                            byte[] body = File.ReadAllBytes(filePath);
                            string header = "HTTP/1.1 200 OK\r\nContent-Type: text/html; charset=utf-8\r\nContent-Length: " + body.Length + "\r\nConnection: close\r\n\r\n";
                            byte[] hBytes = Encoding.UTF8.GetBytes(header);
                            stream.Write(hBytes, 0, hBytes.Length);
                            stream.Write(body, 0, body.Length);
                            stream.Flush();
                        }
                    } catch {}
                }, client);
            } catch {}
        }
    }
}
"@

Add-Type -TypeDefinition $source
$html = "C:\Users\rohit\.gemini\antigravity\scratch\capcut-course-landing-page\index.html"
[MiniServer]::Run(5500, $html)
