import std.stdio;
import std.socket;
import std.array;
import std.string;
import std.file : readText;
import std.random;
import core.thread;

// Function to process a single command
string processCommand(string line, string[] quotes) {
    line = line.strip();
    if (line.startsWith("ECHO:")) {
        return line[5 .. $];
    } else if (line == "QUOTE") {
        return quotes[uniform(0, quotes.length)];
    } else {
        return "Unknown command";
    }
}

// Handle a single client connection
void handleClient(Socket client, string[] quotes) {
    try {
        ubyte[1024] buf;
        string buffer = "";
        while (true) {
            int received = client.receive(buf[]);
            if (received <= 0) break; // client disconnected

            buffer ~= cast(string) buf[0 .. received];

            // Process full lines only
            size_t nl;
            while ((nl = buffer.indexOf("\n")) != -1) {
                string line = buffer[0 .. nl].strip();
                buffer = buffer[nl+1 .. $]; // giữ phần còn lại
                if (line.length == 0) continue;

                string response = processCommand(line, quotes);
                client.send(cast(const(ubyte)[]) (response ~ "\n"));
            }
        }
    } catch (Exception e) {
        writeln("Client error: ", e.msg);
    } finally {
        client.close();
    }
}

void main() {
    // Load quotes at runtime
    string[] quotes;
    try {
        quotes = readText("quotes.txt").splitLines(); // mutable
    } catch (Exception e) {
        writeln("Error reading quotes.txt: ", e.msg);
        return;
    }

    // Create TCP server
    Socket server;
    try {
        server = new TcpSocket();
        server.bind(new InternetAddress("127.0.0.1", 3000));
        server.listen(5);
        writeln("Server listening on 127.0.0.1:3000");
    } catch (Exception e) {
        writeln("Failed to start server: ", e.msg);
        return;
    }

    // Accept clients in loop
    while (true) {
        try {
            Socket client = server.accept();
            writeln("Client connected");
            Thread t = new Thread({
                handleClient(client, quotes);
            });
            t.start();
        } catch (Exception e) {
            // ignore errors
        }
    }
}
